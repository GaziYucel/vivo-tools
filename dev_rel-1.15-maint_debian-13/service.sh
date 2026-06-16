#!/bin/bash

if [ "$1" = "start" ]; then
  sudo -u tomcat /opt/solr/bin/solr start
  sudo systemctl start tomcat
  exit 0
elif [ "$1" = "stop" ]; then
  /opt/solr/bin/solr stop
  sudo systemctl stop tomcat
  exit 0
else
  echo "Usage: $0 {start|stop}"
  exit 2
fi
