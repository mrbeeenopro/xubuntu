#!/bin/bash

# 1. Cấu hình biến môi trường
export HOME=/tmp
export DISPLAY=:1
VNC_PASS=$(echo "$HOSTNAME" | sed 's+-.*++g' | cut -c1-8)

# 2. Tạo thư mục cấu hình VNC trong /tmp
mkdir -p /tmp/.vnc

# Thiết lập mật khẩu
echo "$VNC_PASS" | vncpasswd -f > /tmp/.vnc/passwd
chmod 600 /tmp/.vnc/passwd

# Tạo file chạy XFCE4
cat <<EOF > /tmp/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF
chmod +x /tmp/.vnc/xstartup

# 3. Dọn dẹp file cũ để tránh lỗi "A VNC server is already running"
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1

# 4. Khởi động VNC Server
# Sử dụng -rfbauth trỏ trực tiếp vào file mật khẩu ở /tmp
vncserver :1 -localhost no -geometry 1280x720 -depth 24 -rfbauth /tmp/.vnc/passwd

echo "---------------------------------------------------"
echo "Mật khẩu VNC là: $VNC_PASS"
echo "Đang chạy Websockify trên Port: $SERVER_PORT"
echo "---------------------------------------------------"

# 5. Khởi động noVNC (Websockify)
# Trỏ trực tiếp localhost:5901 (VNC) ra SERVER_PORT (Panel)
websockify --web=/usr/share/novnc/ $SERVER_PORT localhost:5901
