#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

REDMINE_MARIADB_EXISTS=`docker inspect --format="{{ .Id }}" redmine-mariadb 2> /dev/null`
REDMINE_MARIADB_DATA_EXISTS=`docker inspect --format="{{ .Id }}" redmine-mariadb-data 2> /dev/null`

if [ -z "$REDMINE_MARIADB_DATA_EXISTS" ]
then
  docker run -d -v /var/lib/mysql --name redmine-mariadb-data ubuntu:14.04
fi

if ! [ -z "$REDMINE_MARIADB_EXISTS" ]
then
  docker kill redmine-mariadb
  docker rm redmine-mariadb
fi

docker run \
  -p 3306:3306 \
  --volumes-from mariadb-data \
  --name redmine-mariadb \
  -d bmichalski/mariadb

REDMINE_EXISTS=`docker inspect --format="{{ .Id }}" redmine 2> /dev/null`
REDMINE_DATA_EXISTS=`docker inspect --format="{{ .Id }}" redmine-data 2> /dev/null`

if [ -z "$REDMINE_DATA_EXISTS" ]
then
  docker run \
    -d \
    --name redmine-data \
    ubuntu:14.04
fi

if ! [ -z "$REDMINE_EXISTS" ]
then
  docker kill redmine && \
  docker rm redmine
fi

docker run -p 80:80 --volumes-from redmine-data --name redmine -it bmichalski/redmine:3.0 bash
