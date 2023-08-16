#!/bin/bash

if [ -z $PASSENGER_FRIENDLY_ERROR_PAGES ]
then
  PASSENGER_FRIENDLY_ERROR_PAGES=off
fi

VHOST_CONFIGURATION_FILE=/opt/nginx/conf/vhost/default
DATABASE_YML_FILE=/opt/redmine/redmine/config/database.yml
SECRETS_YML_FILE=/opt/redmine/redmine/config/secrets.yml

sudo sed -i "s/__REDMINE_WEB_HOST__/${REDMINE_WEB_HOST}/"                             $VHOST_CONFIGURATION_FILE
sudo sed -i "s/__REDMINE_WEB_PORT__/${REDMINE_WEB_PORT}/"                             $VHOST_CONFIGURATION_FILE
sudo sed -i "s/__PASSENGER_FRIENDLY_ERROR_PAGES__/${PASSENGER_FRIENDLY_ERROR_PAGES}/" $VHOST_CONFIGURATION_FILE

sudo sed -i "s/__REDMINE_DATABASE_HOST__/${REDMINE_DATABASE_HOST}/"         $DATABASE_YML_FILE
sudo sed -i "s/__REDMINE_DATABASE_NAME__/${REDMINE_DATABASE_NAME}/"         $DATABASE_YML_FILE
sudo sed -i "s/__REDMINE_DATABASE_USERNAME__/${REDMINE_DATABASE_USERNAME}/" $DATABASE_YML_FILE
sudo sed -i "s/__REDMINE_DATABASE_PASSWORD__/${REDMINE_DATABASE_PASSWORD}/" $DATABASE_YML_FILE
sudo sed -i "s/__REDMINE_DATABASE_ENCODING__/${REDMINE_DATABASE_ENCODING}/" $DATABASE_YML_FILE

sudo sed -i "s/__REDMINE_SECRET_TOKEN__/${REDMINE_SECRET_TOKEN}/"       $SECRETS_YML_FILE
sudo sed -i "s/__REDMINE_SECRET_KEY_BASE__/${REDMINE_SECRET_KEY_BASE}/" $SECRETS_YML_FILE

cd /opt/redmine/redmine && \
sudo chown -R redmine:redmine files log && \
sudo chmod -R 755 files log

/opt/nginx/sbin/nginx

tail -f \
  /opt/nginx/logs/*.log \
  /var/log/vhost/redmine/*.log \
  /opt/redmine/redmine/log/*.log
