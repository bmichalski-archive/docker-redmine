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

if [ "$FIRST_RUN" = true ]
then
  echo "First run, configuring."
  attempt=0
  while [ $attempt -le 59 ]; do
    attempt=$(( $attempt + 1 ))
    echo "Waiting for server to be up (attempt: $attempt)..."
      result=$(docker logs redmine-mariadb)
      if grep -q 'ready for connections' <<< $result ; then
        echo "MariaDB is up, configuring."
        docker exec redmine-mariadb mysql -u root -e "CREATE DATABASE redmine CHARACTER SET UTF8;"
        docker exec redmine-mariadb mysql -u root -e "CREATE USER 'redmine'@'%' IDENTIFIED BY 'redmine';"
        docker exec redmine-mariadb mysql -u root -e "GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'%';"
        break
      fi
      sleep 2
    done
fi

REDMINE_EXISTS=`docker inspect --format="{{ .Id }}" redmine 2> /dev/null`
REDMINE_DATA_EXISTS=`docker inspect --format="{{ .Id }}" redmine-data 2> /dev/null`

if [ -z "$REDMINE_DATA_EXISTS" ]
then
  docker run \
    -d \
    -v /opt/redmine/redmine/vendor \
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
  --link redmine-mariadb:redmine-mariadb \
  --volumes-from redmine-data \
  --name redmine \
  -it bmichalski/redmine:3.0 \
  bash