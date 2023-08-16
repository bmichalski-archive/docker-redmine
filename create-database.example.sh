#!/bin/bash

docker exec redmine-mariadb mysql -u root -e "CREATE DATABASE redmine CHARACTER SET UTF8;" && \
docker exec redmine-mariadb mysql -u root -e "CREATE USER 'redmine'@'%' IDENTIFIED BY 'redmine';" && \
docker exec redmine-mariadb mysql -u root -e "GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'%';" && \
docker exec redmine-mariadb su - redmine -c "cd /opt/redmine/redmine && RAILS_ENV=production rake db:migrate" && \
docker exec redmine-mariadb su - redmine -c "cd /opt/redmine/redmine && RAILS_ENV=production REDMINE_LANG=en rake redmine:load_default_data"
