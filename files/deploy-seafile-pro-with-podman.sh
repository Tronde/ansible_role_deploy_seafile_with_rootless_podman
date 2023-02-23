#!/bin/sh

# This script is used to deploy and update Seafile on ursini
# Start with the following env if this is a new server

podman login -u seafile -p 'PutYourPasswordHERE' docker.seadrive.org

podman pull docker.io/library/mariadb
podman pull docker.io/library/memcached
podman pull docker.io/seafileltd/elasticsearch-with-ik:5.6.16
podman pull docker.seadrive.org/seafileltd/seafile-pro-mc

podman pod rm -f seafile

podman pod create -p 8003:80 --name seafile

podman volume create seafile-mysql-data
podman volume create seafile-elastic
podman volume create seafile-data

# Create MariaDB container in seafile pod
podman create \
				  --pod seafile \
				  --name seafile-db \
				  -e MYSQL_ROOT_PASSWORD='mysqlrootpw' \
				  -e MYSQL_LOG_CONSOLE=true \
				  -v seafile-mysql-data:/var/lib/mysql \
				  mariadb

# Create memcached container in seafile pod
podman create \
				  --pod seafile \
				  --name seafile-memcached \
				  memcached
#--entrypoint '/usr/local/bin/memcached -m 256' \

# Create elasticsearch container in seafile pod
podman create \
				  --pod seafile \
				  --name seafile-elasticsearch \
				  -e discovery.type=single-node \
				  -e bootstrap.memory_lock=true \
				  -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" \
				  -v seafile-elastic:/usr/share/elasticsearch/data \
				  docker.io/seafileltd/elasticsearch-with-ik:5.6.16

# Create seafile container in seafile pod
podman create \
				  --pod seafile \
				  --name seafile-seafile \
				  -v seafile-data:/shared \
				  -e DB_HOST=127.0.0.1 \
				  -e DB_ROOT_PASSWD='mysqlrootpw' \
 				  -e TIME_ZONE='Europe/Zurich' \
				  -e SEAFILE_ADMIN_EMAIL='alice@example.com' \
				  -e SEAFILE_ADMIN_PASSWORD='sadfHH&Ad9sadf' \
				  -e SEAFILE_SERVER_LETSENCRYPT=false \
				  -e SEAFILE_SERVER_HOSTNAME='seafile.example.com \
				  docker.seadrive.org/seafileltd/seafile-pro-mc


podman start seafile-memcached seafile-db seafile-elasticsearch
sleep 30
podman start seafile-seafile
