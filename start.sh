#!/bin/bash

# kill three old processes
pkill collidermain
pkill turnserver
pkill python

printf "Enter domain name: "
read domain_name


# remove apprtc log
rm -f nohup.out

# run again

echo starting collidermain
nohup $GOPATH/bin/collidermain -tls=true -port=8443 -room-server="https://$domain_name"  &
sleep 2

echo starting turnserver
nohup turnserver &
sleep 2

echo starting apprtc room server
nohup /root/google-cloud-sdk/bin/dev_appserver.py --ssl_certificate_path /cert/full.pem --ssl_certificate_key_path /cert/key.pem --enable_host_checking false --dev_appserver_log_level debug --go_debugging true  --admin_host 0.0.0.0 --host 0.0.0.0 --specified_service_ports default:442 /root/apprtc/out/app_engine/ &

sleep 2

echo Deploy successfully.
