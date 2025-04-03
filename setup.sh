#!/bin/bash
apk update
apk add openvpn easy-rsa
apk add apache2
cd /etc/openvpn/
/usr/share/easy-rsa/easyrsa init-pki << EOF
yes
EOF
/usr/share/easy-rsa/easyrsa build-ca nopass << EOF
yes
YES
EOF
/usr/share/easy-rsa/easyrsa build-server-full server nopass << EOF
yes
YES
EOF
/usr/share/easy-rsa/easyrsa build-client-full client nopass << EOF
yes
YES
EOF
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

# Use TLS authentication instead of static key
ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/issued/server.crt
key /etc/openvpn/pki/private/server.key
dh /etc/openvpn/pki/dh.pem
tls-server
EOF
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

<ca>
$(cat /etc/openvpn/pki/ca.crt)
</ca>
<cert>
$(cat /etc/openvpn/pki/issued/client.crt)
</cert>
<key>
$(cat /etc/openvpn/pki/private/client.key)
</key>
tls-client
EOF

chown root:root /var/www/localhost/htdocs/hotspot.ovpn
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
echo "httpd &" >> ~/.profile
echo "openvpn --config /etc/openvpn/server.conf" >> ~/.profile
source ~/.profile
