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
        htop \
        ipython3 \
        jupyter-notebook \
        openjdk-11-jdk \
        python3-pip \
        sagemath \
        tmux \
        tzdata \
        vim \
        wget \
        unzip \
        z3 \
        zsh \
        && \
    rm -rf /var/lib/apt/lists/*

# Python packages
RUN pip install pwntools numpy matplotlib scipy 

ENV DOCKER_USER="sifuctf"
ENV DOCKER_HOME="/home/"$DOCKER_USER
# User $DOCKER_USER
RUN groupadd -r $DOCKER_USER && useradd -m -r -g $DOCKER_USER $DOCKER_USER
RUN chsh -s /bin/zsh $DOCKER_USER
USER $DOCKER_USER

# ohmyzsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"mh-custom\"/g" $DOCKER_HOME/.zshrc

# conf
COPY files/vimrc $DOCKER_HOME/.vimrc
COPY files/tmux.conf /etc/
COPY files/mh-custom.zsh-theme $DOCKER_HOME/.oh-my-zsh/themes/

# gdb peda
RUN mkdir -p $DOCKER_HOME/tools
RUN git clone https://github.com/longld/peda.git $DOCKER_HOME/tools/peda
RUN echo "source $DOCKER_HOME/tools/peda/peda.py" >> $DOCKER_HOME/.gdbinit

# Ghidra
RUN curl -iL https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.1.1_build/ghidra_10.1.1_PUBLIC_20211221.zip -o $DOCKER_HOME/tools/ghidra.zip
RUN unzip $DOCKER_HOME/tools/ghidra.zip -d $DOCKER_HOME/tools || :

# Volatility
RUN git -C $DOCKER_HOME/tools clone https://github.com/volatilityfoundation/volatility.git 
# Fix colors for sage
RUN mkdir $DOCKER_HOME/.sage/
RUN echo "%colors Linux" >> $DOCKER_HOME/.sage/init.sage

# radare2
RUN wget -O /tmp/radare2.deb https://github.com/radareorg/radare2/releases/download/5.5.4/radare2_5.5.4_amd64.deb 
USER root
RUN dpkg -i /tmp/radare2.deb
USER $DOCKER_USER
RUN rm /tmp/radare2.deb

ENV TZ="Europe/Paris"

WORKDIR $DOCKER_HOME
CMD ["/bin/zsh","-c","/usr/bin/tmux"]
