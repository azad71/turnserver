#!/bin/sh

if [ ! -d "/cert" ]; then
    mkdir "/cert"
fi

if [ ! -d "/etc/coturn/certs" ]; then
    mkdir "/etc/coturn/certs"
fi

colliderPath=/cert
coturnPath=/etc/coturn/certs


cp "$RENEWED_LINEAGE/fullchain.pem" "$colliderPath/full.pem"
cp "$RENEWED_LINEAGE/privkey.pem" "$colliderPath/key.pem"
cp "$RENEWED_LINEAGE/certificate.pem" "$colliderPath/cert.pem"

cp "$RENEWED_LINEAGE/fullchain.pem" "$coturnPath/full.pem"
cp "$RENEWED_LINEAGE/privkey.pem" "$coturnPath/key.pem"


chown turnserver "$coturnPath/full.pem" \
"$coturnPath/full.pem"
chmod 400 "$coturnPath/key.pem" \
"$coturnPath/key.pem"

#service coturn restart >/dev/null

service coturn restart
