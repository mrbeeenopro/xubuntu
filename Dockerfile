FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
# Pterodactyl sử dụng thư mục này
ENV HOME=/home/container
WORKDIR /home/container

RUN apt update && apt install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime && \
    apt install -y --no-install-recommends \
    xfce4 xfce4-goodies tigervnc-standalone-server tigervnc-common \
    novnc websockify sudo xterm vim net-tools curl wget git \
    btop python3 python3-pip openssh-server dbus-x11 x11-xserver-utils \
    x11-utils x11-apps ca-certificates gnupg lsb-release

# Cài Firefox (PPA)
RUN apt install software-properties-common -y && \
    add-apt-repository ppa:mozillateam/ppa -y && \
    apt update && apt install -y firefox

# Cấp quyền cho user container
RUN useradd -m -d /home/container container
RUN chown -R container:container /home/container

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Chuyển sang dùng user container để tránh lỗi Root
USER container
ENV USER=container

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
