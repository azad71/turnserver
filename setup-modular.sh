#!/bin/bash

# initialize setup

initialize() {
    echo "Initiating turnserver configuration..."
    echo "Assuming that you are using a digitalocean droplet and bash"
    
    sudo apt update
}

# get server variables
echo "Enter domain name: "
read domain_name
ip=$(hostname -I)
server_ip=(${ip// / })
username=a"azad71"
password="cefd9faf8"

# find vm provider
checkProvider() {
    sudo apt install facter -y
    provider=$(facter manufacturer)
    
    if [ $provider != "DigitalOcean" ]; then
        echo "This setup is configured only for digitalocean instances"
        echo "Exiting setup..."
        exit 0
    fi
}

# install nodejs
installNodejs() {
    cd ~
    curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh | sudo -E bash -
    if [ $? -eq 0 ]; then
        /bin/bash /root/nodesource_setup.sh
        apt install nodejs -y
        echo "Nodejs installed successfully"
        rm /root/nodesource_setup.sh
    else
        echo "Nodejs installation failed..."
        echo "Exiting setup..."
        exit 0
    fi
}

# install python2
installPython2() {
    apt install python2 -y
    cd /usr/bin
    ln -sf python2 python
    cd ~
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py | sudo -E bash -
    python get-pip.py
    rm /root/get-pip.py
}

# install coturn
installCoturn() {
    echo "Installing coturn..."
    apt-get install coturn -y
    mv /etc/turnserver.conf /etc/turnserver.original
    touch /etc/turnserver.conf
}

# clone apprtc
cloneAppRTC() {
    cd /root
    
    echo "Downloading AppRTC..."
    git clone https://github.com/webrtc/apprtc.git
    
    if [ $? -eq 0 ]; then
        echo "AppRTC repository downloaded successfully..."
    else
        echo "AppRTC repository download failed..."
        echo "Exiting setup..."
        exit 0
    fi
}

# build apprtc
buildAppRTC() {
    constantDir=/root/apprtc/src/app_engine/constants.py
    cd /root/apprtc
    apt install make -y
    npm i
    npm audit fix --force
    npm i -g grunt
    npm i grunt
    pip install -r requirements.txt
    npm i --dev coffeescript
    cat constants.py >  $constantDir
    sed -i "s/example.com/$domain_name/" $constantDir
    sed -i "s/server_ip/$server_ip/" $constantDir
    sed -i "s/user_name/$username/" $constantDir
    sed -i "s/user_password/$password/" $constantDir
    grunt build
    if [ $? -eq 0 ]; then
        echo "AppRTC built successfully"
    else
        echo "AppRTC build failed..."
        echo "Exiting setup..."
        exit 0
    fi
}

# install golang
installGolang() {
    sudo apt install golang -y
    sudo mkdir /root/goWorkspace
    echo "export GOPATH=$HOME/goWorkspace" >> ~/.bashrc
    PS1="$ "
    source ~/.bashrc
    mkdir $GOPATH/src
    
    ln -s /root/apprtc/src/collider/collider $GOPATH/src
    ln -s /root/apprtc/src/collider/collidermain $GOPATH/src
    ln -s /root/apprtc/src/collider/collidertest $GOPATH/src
    
    go get collidermain
    go install collidermain
    
}

configureSSL() {
    rm -rf "/cert"
    mkdir "/cert"
    
    snap install core
    snap refresh core
    apt-get remove certbot
    snap install --classic certbot
    ln -s /snap/bin/certbot /usr/bin/certbot
    
    rm -rf "/etc/coturn/certs"
    mkdir -p "/etc/coturn/certs"
    
    
    mkdir -p /etc/coturn/certs
    chown -R turnserver:turnserver /etc/coturn/
    chmod -R 700 /etc/coturn/
    
    renewal_path=/etc/letsencrypt/renewal-hooks
    renewal_deploy="$renewal_path/deploy/certbot-coturn-deploy.sh"
    renewal_post="$renewal_path/post/000-copy-cert.sh"
    domain_path="/etc/letsencrypt/live/$domain_name"
    
    rm -rf "$renewal_path"
    mkdir "/etc/letsencrypt"
    mkdir "$renewal_path"
    mkdir "$renewal_path/deploy"
    mkdir "$renewal_path/post"
    
    touch "$renewal_deploy"
    chmod 700 "$renewal_deploy"
    chmod +x "$renewal_deploy"
    cat certbot-coturn-deploy.sh >> "$renewal_deploy"
    sed -i "s/example.com/$domain_name/" $renewal_deploy
    
    
    touch "$renewal_post"
    chmod 700 "$renewal_post"
    chmod +x "$renewal_post"
    cat copy-cert.sh >>  "$renewal_post"
    
    
    certbot certonly --standalone -d "$domain_name"
}

# copy certificates in /cert and /etc/coturn/certs
copyCertificates() {
    
    cp "/etc/letsencrypt/live/$domain_name/cert.pem" /cert/cert.pem
    cp "/etc/letsencrypt/live/$domain_name/fullchain.pem" /cert/full.pem
    cp "/etc/letsencrypt/live/$domain_name/privkey.pem" /cert/key.pem
    
    cp "/etc/letsencrypt/live/$domain_name/cert.pem" /etc/coturn/certs/cert.pem
    cp "/etc/letsencrypt/live/$domain_name/fullchain.pem" /etc/coturn/certs/full.pem
    cp "/etc/letsencrypt/live/$domain_name/privkey.pem" /etc/coturn/certs/key.pem
}

# write to turnserver.conf
writeToTurnserverConf() {
    printf '%s\n\n' 'cert=/etc/coturn/certs/cert.pem' 'pkey=/etc/coturn/certs/key.pem' 'listening-port=3478' 'tls-listening-port=5349' "listening-ip=$server_ip" "relay-ip=$server_ip" "external-ip=$server_ip" "realm=$domain_name" "server-name=$domain_name" "lt-cred-mech" "userdb=/etc/turnuserdb.conf" 'oauth' 'user=$username:$password' 'no-stdout-log' 'cli-password=$password' >> /etc/turnserver.conf
}


# install google cloud sdk
installGoogleCloudSDK() {
    cd /root
    wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-330.0.0-linux-x86_64.tar.gz
    tar xzvf google-cloud-sdk-330.0.0-linux-x86_64.tar.gz
    ./google-cloud-sdk/install.sh
    
    # install gcloud python plugins
    /root/google-cloud-sdk/bin/dev_appserver.py /root/apprtc/out/app_engine/
    
    # copy wsgi_server.py to directory
    gcdPath=/root/google-cloud-sdk/platform/google_appengine/google/appengine/tools/devappserver2/wsgi_server.py
    cat wsgi_server.py > $gcdPath
}

# cleaning up
cleaningUp() {
    printf "\nCleaning up..."
    rm -rf google-cloud-sdk-330.0.0-linux-x86_64.tar.gz
    pkill python
    
}

setup() {
    initialize
    checkProvider
    
    # installation step
    installNodejs
    installPython2
    installCoturn
    installGoogleCloudSDK
    
    # clone and build apprtc
    cloneAppRTC
    buildAppRTC
    
    # install collidermain
    installGolang
    
    # issue certificates
    configureSSL
    copyCertificates
    
    # write turnserver.conf
    writeToTurnserverConf
    
    cleaningUp
    
    printf "\nSuccessfully setup turnserver...\n"
    
}

# run setup
setup
