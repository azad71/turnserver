#!/bin/sh

set -e

for domain in $RENEWED_DOMAINS; do
    case $domain in
        example.com)
            daemon_cert_root=/etc/coturn/certs
            
            # Make sure the certificate and private key files are
            # never world readable, even just for an instant while
            # we're copying them into daemon_cert_root.
            umask 077
            
            cp "$RENEWED_LINEAGE/fullchain.pem" "$daemon_cert_root/full.pem"
            cp "$RENEWED_LINEAGE/privkey.pem" "$daemon_cert_root/key.pem"
            
            # copying for collidermain
            cp "$RENEWED_LINEAGE/fullchain.pem" "/cert/full.pem"
            cp "$RENEWED_LINEAGE/privkey.pem" "/cert/key.pem"
            cp "$RENEWED_LINEAGE/cert.pem" "/cert/cert.pem"
            
            # Apply the proper file ownership and permissions for
            # the daemon to read its certificate and key.
            chown turnserver "$daemon_cert_root/full.pem" \
            "$daemon_cert_root/full.pem"
            chmod 400 "$daemon_cert_root/key.pem" \
            "$daemon_cert_root/key.pem"
            
            service coturn restart >/dev/null
        ;;
    esac
done
