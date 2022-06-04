FROM debian:stable-slim

# Packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y --no-install-recommends \
        apulse \
        build-essential \
        binwalk \
        bsdextrautils \
        curl \
        file \
        firefox-esr \
        gdb \
        git \
        gnupg \
        hexchat \
        hexyl \
        htop \
        iproute2 \
        ipython3 \ 
        iputils-ping \
        jupyter-notebook \
        libegl1 \
        libpci3 \
        mlocate \
        netcat \
        nmap \
        openjdk-11-jdk \
        openssh-client \
        php \
        procps \
        python3-pip \
        sagemath \
        socat \
        sudo \
        tmux \
        tzdata \
        unzip \
        vim \
        wget \
        xmlstarlet \
        z3 \
        zsh \
        && \
    rm -rf /var/lib/apt/lists/*


# User $DOCKER_USER
ENV DOCKER_USER="sifuctf"
ENV DOCKER_HOME="/home/"$DOCKER_USER
RUN groupadd -r -g 1000 $DOCKER_USER && useradd -u 1000 -m -r -g 1000 -G audio $DOCKER_USER
RUN echo "$DOCKER_USER:$DOCKER_USER" | chpasswd
RUN chsh -s /bin/zsh $DOCKER_USER
RUN echo "$DOCKER_USER ALL=(ALL:ALL) ALL" >> /etc/sudoers

# tmux conf
COPY files/tmux.conf /etc/

ENV TOOLS_DIR="/opt/tools"
RUN mkdir -p $TOOLS_DIR
# gdb peda
RUN git clone https://github.com/longld/peda.git $TOOLS_DIR/peda

# Ghidra
RUN curl -iL https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.1.1_build/ghidra_10.1.1_PUBLIC_20211221.zip -o $TOOLS_DIR/ghidra.zip
RUN unzip $TOOLS_DIR/ghidra.zip -d $TOOLS_DIR || :
RUN rm $TOOLS_DIR/ghidra.zip
RUN ln -s $TOOLS_DIR/ghidra_10.1.1_PUBLIC/ghidraRun /usr/local/bin

# radare2
RUN wget -O /tmp/radare2.deb https://github.com/radareorg/radare2/releases/download/5.5.4/radare2_5.5.4_amd64.deb 
RUN dpkg -i /tmp/radare2.deb
RUN rm /tmp/radare2.deb

# burp suite
RUN wget -O $TOOLS_DIR/burp.jar 'https://portswigger.net/DownloadUpdate.ashx?Product=Free' \
    && chmod +x $TOOLS_DIR/burp.jar
RUN echo "#!/bin/bash \n\
java -jar $TOOLS_DIR/burp.jar > /dev/null 2>&1 & \n" > /usr/local/bin/burpsuite \
    && chmod +x /usr/local/bin/burpsuite

# zap proxy
RUN wget -qO- https://raw.githubusercontent.com/zaproxy/zap-admin/master/ZapVersions.xml | xmlstarlet sel -t -v //url |grep -i Linux | wget --content-disposition -i - -O - | tar zxv && \
    mv ZAP* $TOOLS_DIR
RUN ln -s $TOOLS_DIR/ZAP*/zap.sh /usr/local/bin/zap && chmod +x /usr/local/bin/zap

# Python packages
RUN pip install pwntools numpy matplotlib scipy pycryptodome 

ENV TZ="Europe/Paris"
