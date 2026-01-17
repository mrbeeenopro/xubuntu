#!/bin/bash

# Định nghĩa lại thư mục Home cho chắc chắn
export HOME=/home/container
cd /home/container

# 1. Lấy mật khẩu từ Server ID
VNC_PASS=$(echo "$HOSTNAME" | sed 's+-.*++g' | cut -c1-8)

# 2. Tạo thư mục cấu hình trong /home/container
mkdir -p /home/container/.vnc
echo "$VNC_PASS" | vncpasswd -f > /home/container/.vnc/passwd
chmod 600 /home/container/.vnc/passwd

# 3. Tạo file xstartup
cat <<EOF > /home/container/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
dbus-launch --exit-with-session xfce4-session &
EOF
chmod +x /home/container/.vnc/xstartup

# 4. Dọn dẹp lock file cũ
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1

# 5. Khởi động VNC (Bỏ qua Netdata và SSH vì Pterodactyl thường chặn các dịch vụ này nếu không có quyền root)
# Chạy VNC trên port 5901
vncserver :1 -localhost no -geometry 1920x1080 -depth 24 -rfbauth /home/container/.vnc/passwd

# 6. Khởi động Websockify (noVNC)
# Vì /usr/share/novnc là read-only, chúng ta trỏ web trực tiếp tới thư mục cài đặt
echo "---------------------------------------------------"
echo "VNC Password: $VNC_PASS"
echo "Đang chạy trên Port: $SERVER_PORT"
echo "---------------------------------------------------"

# Chạy websockify không cần SSL để tránh lỗi Permission khi tạo file .pem
websockify --web=/usr/share/novnc/ $SERVER_PORT localhost:5901
