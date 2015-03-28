#!/bin/bash

su - redmine -c "cd /opt/redmine/redmine && rake generate_secret_token" && \
su - redmine -c "cd /opt/redmine/redmine && RAILS_ENV=production rake db:migrate" && \
su - redmine -c "cd /opt/redmine/redmine && RAILS_ENV=production rake redmine:load_default_data"