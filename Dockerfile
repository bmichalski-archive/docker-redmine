FROM ubuntu:14.04

ENV HOME /root

WORKDIR /root

RUN \
  apt-get update && \
  apt-get install -y \
    autoconf \
    git \
    subversion \
    curl \
    bison \
    imagemagick \
    libmagickwand-dev \
    build-essential \
    libmariadbclient-dev \
    libssl-dev \
    libreadline-dev \
    libyaml-dev \
    zlib1g-dev \
    software-properties-common

RUN \
  adduser --disabled-login --gecos 'redmine' redmine

RUN \
  add-apt-repository ppa:brightbox/ruby-ng && \
  apt-get update && \
  apt-get install -y ruby2.2

RUN \
  apt-get install -y nginx
