#!/bin/bash
apk update
apk add openvpn easy-rsa iptables openvpn-auth-pam
apk add pam
cat > /etc/openvpn/server.conf << EOF
port 1194
proto tcp
dev tun
local 172.20.10.1  # Bind to the local IP
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist /etc/openvpn/ipp.txt
keepalive 10 120
persist-key
persist-tun
status /dev/null
log /dev/null
verb 3
push "dhcp-option DNS 1.1.1.1"

plugin /usr/lib/openvpn/plugins/openvpn-plugin-auth-pam.so openvpn
EOF
cat > /etc/openvpn/check_login.sh << EOF
#!/bin/sh

exit 0
EOF
chmod +x /etc/openvpn/check_login.sh
echo "auth required pam_unix.so" > /etc/pam.d/openvpn
echo 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf' >> ~/.profile
echo 'sysctl -p' >> ~/.profile
echo "cat /dev/location > /dev/null &" >> ~/.profile
echo "openvpn --config /etc/openvpn/server.conf" >> ~/.profile
source ~/.profile
