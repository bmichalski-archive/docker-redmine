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

RUN \
  apt-get install -y \
    make \
    zlib1g-dev \
    patch \
    libmariadbclient-dev \
    imagemagick \
    libmagickcore-dev \
    libmagickwand-dev

COPY conf/opt/redmine/redmine/config/configuration.yml /opt/redmine/redmine/config/configuration.yml
COPY conf/opt/redmine/redmine/config/database.yml /opt/redmine/redmine/config/database.yml

RUN \
  su - redmine -c "cd /opt/redmine/redmine && bundle install --without development test"

RUN \
  cd /opt/redmine/redmine && \
  mkdir -p tmp public/plugin_assets && \
  chown -R redmine:redmine files log tmp public/plugin_assets && \
  chmod -R 755 files log tmp public/plugin_assets

RUN \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7 && \
  apt-get install -y \
    apt-transport-https \
    ca-certificates \
  && \
  echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list && \
  chown root: /etc/apt/sources.list.d/passenger.list && \
  chmod 600 /etc/apt/sources.list.d/passenger.list

COPY conf/opt/redmine/redmine/config/secrets.yml /opt/redmine/redmine/config/secrets.yml

#RUN \
#  apt-get update && \
#  apt-get install -y \
#    nginx \
#    nginx-extras \
#    passenger

#RUN \
#  mv /usr/bin/ruby /usr/bin/ruby.bak && \
#  ln -s /etc/alternatives/ruby /usr/bin/ruby

#COPY conf/etc/nginx /etc/nginx