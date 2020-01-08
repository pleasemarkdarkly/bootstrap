FROM ubuntu:disco
MAINTAINER "Please Mark Darkly pretty@pleasemarkdarkly.com"

RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive && \
  apt-get -y upgrade && \
  apt-get install -y \
    curl \
    git  \
    wget \
    zsh  && \
  rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8
ENV LANG en_US.UTF-8 
ENV HOME /root

ADD docker_shell/.bashrc /root/.bashrc
ADD . /root/

WORKDIR /root

CMD ["bash"]





