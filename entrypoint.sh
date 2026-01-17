#!/bin/bash

# Vnc password
VNC_PASS=$(echo "$HOSTNAME" | sed 's+-.*++g' | cut -c1-8)

# 2. vnc password for root
mkdir -p /root/.vnc
echo "$VNC_PASS" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd

# 3. Xstartup
cat <<EOF > /root/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
dbus-launch --exit-with-session xfce4-session &
EOF
chmod +x /root/.vnc/xstartup

echo "<!DOCTYPE html><html><head><title>VNC</title><script>window.location.replace('vnc.html?autoconnect=1&resize=scale&password=$VNC_PASS');</script></head></html>" > /usr/share/novnc/index.html

rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1

/usr/sbin/sshd &
/usr/sbin/netdata &

vncserver :1 -localhost no -geometry 1920x1080 -depth 24

openssl req -new -subj "/C=VN" -x509 -days 365 -nodes -out /self.pem -keyout /self.pem 2>/dev/null

echo "---------------------------------------------------"
echo "Server ID: $HOSTNAME"
echo "VNC Password (8 ký tự đầu): $VNC_PASS"
echo "Đang lắng nghe trên Port: $SERVER_PORT"
echo "Truy cập: http://<IP_SERVER>:$SERVER_PORT"
echo "---------------------------------------------------"

websockify --web=/usr/share/novnc/ --cert=/self.pem --vnc localhost:5901 --listen 0.0.0.0:$SERVER_PORT 
