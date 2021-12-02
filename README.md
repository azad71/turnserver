## TURNSERVER INSTALLATION GUIDE

#### Requirements

- valid domain
- server credential
- digitalocean server (this script is configured only for digitalocean server)

#### Installation steps

- log into server
- copy setup.sh and start.sh file into server
- run ./setup on terminal
  - it will ask for domain name, email and several permissions
  - provide input accordingly
- if setup is successful, it will show **"Successfully setup turnserver..."**
- run ./start.sh on terminal to start turnserver
- visit https://domain_name, it will show the turnserver
