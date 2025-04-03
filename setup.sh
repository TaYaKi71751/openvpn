#!/bin/bash
apk update
apk add openvpn easy-rsa
apk add apache2
apk add nodejs npm
cat > /etc/openvpn/server.conf << EOF
port 1194
proto tcp
dev tun
local 172.20.10.1  # Your server's local IP
ifconfig 10.8.0.1 10.8.0.2  # Static IP assignment
keepalive 10 120
persist-key
persist-tun
status /dev/null
log /dev/null
verb 3

# Use static key authentication (NO TLS, NO username/password)
secret /etc/openvpn/static.key
EOF
npm i -g serve
openvpn --genkey --secret /etc/openvpn/static.key
cat > ~/hotspot.ovpn << EOF
client
dev tun
proto tcp
remote 172.20.10.1 1194  # Your OpenVPN server IP
resolv-retry infinite
nobind
persist-key
persist-tun
verb 3

<secret>
$(cat /etc/openvpn/static.key)
</secret>
EOF
echo 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf' >> ~/.profile
echo 'sysctl -p' >> ~/.profile
echo "cat /dev/location > /dev/null &" >> ~/.profile
echo "serve &" >> ~/.profile
echo "openvpn --config /etc/openvpn/server.conf" >> ~/.profile
source ~/.profile
