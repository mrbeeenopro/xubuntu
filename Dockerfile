FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
WORKDIR /root

# Install Desktop
RUN apt update && apt install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime && \
    apt install -y --no-install-recommends \
    xfce4 xfce4-goodies \
    tigervnc-standalone-server tigervnc-common \
    novnc websockify \
    sudo xterm vim net-tools curl wget git \
    btop python3 python3-pip openssh-server \
    dbus-x11 x11-xserver-utils x11-utils x11-apps ca-certificates \
    gnupg lsb-release

# Netdata
RUN wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && \
    sh /tmp/netdata-kickstart.sh --release-channel stable --non-interactive && \
    mkdir -p /var/lib/netdata/cloud.d/ && touch /var/lib/netdata/cloud.d/cloud.conf

# Firefox
RUN apt install software-properties-common -y && \
    add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt update && apt install -y firefox

# ssh setup
RUN mkdir -p /var/run/sshd && \
    echo 'root:lemem1234' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Copy file
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Pterodactyl
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
