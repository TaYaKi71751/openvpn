#!/bin/bash
apk update
apk add openvpn easy-rsa iptables openvpn-auth-pam
apk add pam
cat > /etc/openvpn/server.conf << EOF
port 1194
proto udp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
auth-user-pass-verify /etc/openvpn/check_login.sh via-env
script-security 3
server 0.0.0.0 255.255.255.0
ifconfig-pool-persist /etc/openvpn/ipp.txt
keepalive 10 120
persist-key
persist-tun
status /dev/null
log /dev/null
verb 3
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 1.1.1.1"
EOF
cat > /etc/openvpn/check_login.sh << EOF
#!/bin/sh

exit 0
EOF
chmod +x /etc/openvpn/check_login.sh
echo "auth required pam_unix.so" > /etc/pam.d/openvpn
echo "plugin /usr/lib/openvpn/plugins/openvpn-plugin-auth-pam.so openvpn" >> /etc/openvpn/server.conf
echo "cat /dev/location > /dev/null &" >> ~/.profile
echo "rc-service openvpn start" >> ~/.profile
echo "rc-update add openvpn" >> ~/.profile
source ~/.profile
