FROM ubuntu:14.04

ENV HOME /root

WORKDIR /root

RUN \
  apt-get update && \
  apt-get install -y \
    software-properties-common

RUN \
  add-apt-repository ppa:brightbox/ruby-ng && \
  apt-get update && \
  apt-get install -y \
    ruby2.2 \
    ruby2.2-dev

RUN \
  apt-get install -y wget

RUN \
  wget http://www.redmine.org/releases/redmine-3.0.1.tar.gz

RUN \
  adduser --disabled-login --gecos 'redmine' redmine && \
  usermod -a -G sudo redmine && \
  echo "redmine ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN \
  tar -xf redmine-3.0.1.tar.gz && \
  mkdir -p /opt/redmine && \
  mv redmine-3.0.1 /opt/redmine && \
  ln -s /opt/redmine/redmine-3.0.1 /opt/redmine/redmine

RUN \
  cd /opt/redmine/redmine && \
  gem install bundler

COPY conf/opt/redmine/redmine/config /opt/redmine/redmine/config

RUN \
  apt-get install -y \
    make \
    zlib1g-dev \
    patch \
    libmariadbclient-dev \
    imagemagick \
    libmagickcore-dev \
    libmagickwand-dev

RUN \
  su - redmine -c "cd /opt/redmine/redmine && bundle install --without development test"

RUN \
  cd /opt/redmine/redmine && \
  mkdir -p tmp public/plugin_assets && \
  chown -R redmine:redmine files log tmp public/plugin_assets && \
  chmod -R 755 files log tmp public/plugin_assets

COPY conf/home/redmine /home/redmine

RUN \
  chmod u+x /home/redmine/init.sh