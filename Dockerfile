FROM ubuntu:latest
MAINTAINER "pretty@pleasemarkdarkly.com"

RUN apt-get update
RUN apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LC_ALL en_US.UTF-8 
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  

RUN   apt-get update && \
      DEBIAN_FRONTEND=noninteractive && \
      apt-get install -y \
      build-essential \
      software-properties-common \
      tzdata \
      psmisc \
      curl \
      git \
      wget \
      tmux \
      vim \
      zsh \
      ledger \
      mosh \
      ruby \
      ruby-dev \
      mosquitto \
      mosquitto-clients \
      postgresql-client \
      jq \
      rsync \
      lastpass-cli \
      sudo \
      && \
      rm -rf /var/lib/apt/lists/*

RUN chsh -s /usr/bin/zsh
RUN curl -L http://install.ohmyz.sh | sh || true
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/themes/powerlevel10k
RUN echo "ZSH_THEME=powerlevel10k/powerlevel10k" >> ~/zshrc
RUN exec zsh

ADD . /root/
ADD docker_shell/.bashrc /root/.bashrc

ENV HOME /root
WORKDIR /root

ENV TERM=xterm-256color

# CMD ["zsh"]


# -------------------------------------------------------------------------------------------------------------------------
# 
# End of Dockerfile
#
#
# -------------------------------------------------------------------------------------------------------------------------

