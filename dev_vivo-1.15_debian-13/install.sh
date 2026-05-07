#!/bin/bash
set -x #echo on
sudo echo "$(basename "$0")"

sudo apt install git -y

./1java.sh
./2tomcat.sh
./3solr.sh
./4vivo.sh

# start Solr
/opt/solr/bin/solr start
sleep 10

# restart Tomcat
sudo systemctl restart tomcat
