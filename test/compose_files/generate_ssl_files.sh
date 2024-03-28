#!/bin/bash

mkdir ./ssl/tmp

openssl req -new -x509 -keyout ./ssl/ca.key -out ./ssl/ca.crt -days 3650 -subj '/CN=localhost/OU=klife_protocol/O=klife/L=brazil/C=br' -passin pass:klifeprotocol -passout pass:klifeprotocol

keytool -genkey -noprompt \
                 -alias localhost \
				 -dname "CN=localhost, OU=klife_protocol, O=klife, L=brazil, C=br" \
				 -keystore ./ssl/localhost.keystore.jks \
				 -keyalg RSA \
				 -storepass klifeprotocol \
				 -keypass klifeprotocol \
                 -validity 3650

keytool -keystore ./ssl/localhost.keystore.jks -alias localhost -certreq -file ./ssl/tmp/localhost.csr -storepass klifeprotocol -keypass klifeprotocol

openssl x509 -req -CA ./ssl/ca.crt -CAkey ./ssl/ca.key -in ./ssl/tmp/localhost.csr -out ./ssl/tmp/localhost-ca-signed.crt -days 3650 -CAcreateserial -passin pass:klifeprotocol

keytool -keystore ./ssl/localhost.keystore.jks -alias CARoot -import -noprompt -file ./ssl/ca.crt -storepass klifeprotocol -keypass klifeprotocol

keytool -keystore ./ssl/localhost.keystore.jks -alias localhost -import -file ./ssl/tmp/localhost-ca-signed.crt -storepass klifeprotocol -keypass klifeprotocol

keytool -keystore ./ssl/localhost.truststore.jks -alias CARoot -import -noprompt -file ./ssl/ca.crt -storepass klifeprotocol -keypass klifeprotocol

rm -rf ./ssl/tmp