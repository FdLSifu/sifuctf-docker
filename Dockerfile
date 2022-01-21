FROM debian:stable-slim

# Packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y \
        build-essential \
        binwalk \
        curl \
        gdb \
        git \
        ipython3 \
        jupyter-notebook \
        python3-pip \
        tmux \
        vim \
        z3 \
        zsh \
        && \
    rm -rf /var/lib/apt/lists/*

# Python packages
RUN pip install pwntools numpy matplotlib scipy 

# ohmyzsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"mh-custom\"/g" /root/.zshrc
RUN chsh -s /bin/zsh root

# conf
COPY files/vimrc /root/.vimrc
COPY files/tmux.conf /etc/
COPY files/mh-custom.zsh-theme /root/.oh-my-zsh/themes/

# gdb peda
RUN mkdir -p /root/tools
RUN git clone https://github.com/longld/peda.git /root/tools/peda
RUN echo "source /root/tools/peda/peda.py" >> /root/.gdbinit

# timezone
RUN apt update && apt install htop tzdata -y && rm -rf /var/lib/apt/lists/*
ENV TZ="Europe/Paris"


WORKDIR /root
CMD ["/bin/zsh","-c","/usr/bin/tmux"]
