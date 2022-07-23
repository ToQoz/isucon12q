#!/bin/sh

set -e

cd /home/isucon/webapp
git pull

# Copy conf files
sudo cp conf/mysqld.conf /etc/mysql/mysql.conf.d/mysqld.cnf
sudo cp conf/nginx.conf /etc/nginx/nginx.conf
sudo nginx -t
sudo cp conf/nginx-isuports.conf /etc/nginx/sites-available/isuports.conf

# Rotate Logs
sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.`date +%Y%m%d-%H%M%S` || true
sudo mv /var/log/mysql/slow.log /var/log/mysql/slow.log.`date +%Y%m%d-%H%M%S` || true

# Restart middlewares
sudo systemctl restart nginx
sudo systemctl restart mysql

# Restart app
(cd go && go build -o isuports ./cmd/isuports)
sudo systemctl restart isuports

echo "(deploy.sh) Done" | slackcat --tee
