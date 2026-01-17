FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /home/container

RUN apt update && apt install -y \
    xfce4 xfce4-goodies tigervnc-standalone-server \
    novnc websockify curl wget git procps \
    dbus-x11 x11-xserver-utils x11-utils ca-certificates

# Cài Firefox (không dùng Snap)
RUN apt install software-properties-common -y && \
    add-apt-repository ppa:mozillateam/ppa -y && \
    apt update && apt install -y firefox

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Không set USER ở đây, để Pterodactyl tự quyết định
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
