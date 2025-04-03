#!/bin/bash
apk update
apk add openvpn easy-rsa
apk add apache2
cat > /etc/openvpn/server.conf << EOF
port 1194
proto tcp
dev tun
local 172.20.10.1
ifconfig 10.8.0.1 10.8.0.2
keepalive 10 120
persist-key
persist-tun
status /dev/null
log /dev/null
verb 3

# Use static key authentication (NO TLS, NO DH file)
secret /etc/openvpn/static.key

# Define a cipher explicitly to avoid warnings
cipher BF-CBC
data-ciphers-fallback BF-CBC
EOF
openvpn --genkey --secret /etc/openvpn/static.key
cat > /var/www/localhost/htdocs/hotspot.ovpn << EOF
client
dev tun
proto tcp
remote 172.20.10.1 1194
resolv-retry infinite
nobind
persist-key
persist-tun
verb 3

<secret>
$(cat /etc/openvpn/static.key)
</secret>

cipher BF-CBC
data-ciphers-fallback BF-CBC
EOF
chmod 644 /var/www/localhost/htdocs/hotspot.ovpn
cat >> /etc/apache2/httpd.conf << EOF
<Directory "/var/www/localhost/htdocs">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>

AddType application/x-openvpn-profile .ovpn
EOF

echo 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf' >> ~/.profile
echo 'sysctl -p' >> ~/.profile
echo "cat /dev/location > /dev/null &" >> ~/.profile
echo "httpd -f &" >> ~/.profile
echo "openvpn --config /etc/openvpn/server.conf" >> ~/.profile
source ~/.profile
