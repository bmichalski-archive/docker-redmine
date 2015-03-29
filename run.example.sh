#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

REDMINE_MARIADB_EXISTS=`docker inspect --format="{{ .Id }}" redmine-mariadb 2> /dev/null`
REDMINE_MARIADB_DATA_EXISTS=`docker inspect --format="{{ .Id }}" redmine-mariadb-data 2> /dev/null`

FIRST_RUN=false

if [ -z "$REDMINE_MARIADB_DATA_EXISTS" ]
then
  FIRST_RUN=true

  docker run \
    -d \
    -v /var/lib/mysql \
    --name redmine-mariadb-data \
    ubuntu:14.04
fi

if ! [ -z "$REDMINE_MARIADB_EXISTS" ]
then
  docker kill redmine-mariadb
  docker rm redmine-mariadb
fi

docker run \
  --volumes-from mariadb-data \
  --name redmine-mariadb \
  -d bmichalski/mariadb

REDMINE_EXISTS=`docker inspect --format="{{ .Id }}" redmine 2> /dev/null`
REDMINE_DATA_EXISTS=`docker inspect --format="{{ .Id }}" redmine-data 2> /dev/null`

if [ -z "$REDMINE_DATA_EXISTS" ]
then
  docker run \
    -d \
    -v /opt/redmine/redmine/files \
    -v /opt/redmine/redmine/log \
    --name redmine-data \
    ubuntu:14.04
fi

if ! [ -z "$REDMINE_EXISTS" ]
then
  docker kill redmine && \
  docker rm redmine
fi

docker run \
  -p 80:80 \
  -e "REDMINE_WEB_HOST=localhost" \
  -e "REDMINE_WEB_PORT=80" \
  -e "REDMINE_DATABASE_HOST=redmine-mariadb" \
  -e "REDMINE_DATABASE_NAME=redmine" \
  -e "REDMINE_DATABASE_USERNAME=redmine" \
  -e "REDMINE_DATABASE_PASSWORD=redmine" \
  -e "REDMINE_DATABASE_ENCODING=utf8" \
  -e "REDMINE_SECRET_TOKEN=__CHANGE_ME__" \
  -e "REDMINE_SECRET_KEY_BASE=__CHANGE_ME__" \
  --link redmine-mariadb:redmine-mariadb \
  --volumes-from redmine-data \
  --name redmine \
  -d bmichalski/redmine:3.0 \
  bash