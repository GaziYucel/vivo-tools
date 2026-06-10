#!/bin/bash
set -x #echo on
sudo echo "$(basename "$0")"

appName="tib-vivo-1.15"
appDir="/opt/${appName}"
tomcatDir="/opt/tomcat"
settingsFile="/opt/${appName}/project-settings.xml"
branch="develop-1.15"
vitroBranch="1.15.1-snapshot-3"
vivoBranch="1.15.1-snapshot-3"

sudo mkdir -p $appDir
sudo chown tomcat:tomcat $appDir
sudo chmod 777 $appDir

cd $appDir || exit

git clone https://git.tib.eu/OSL/VIVO/vivo_1.12_project_template.git -b $branch .

sed -i "s#git@git.tib.eu:#https://git.tib.eu/#g" .gitmodules

sed -i "s#<app-name>vivo</app-name>"\
"#<app-name>${appName}</app-name>#g" $settingsFile

sed -i "s#<vivo-dir>/tib/app/vivo/data/vivo</vivo-dir>"\
"#<vivo-dir>${appDir}/VIVO/home</vivo-dir>#g" $settingsFile

sed -i "s#<tomcat-dir>/Program Files/Apache Software Foundation/Tomcat 9.0</tomcat-dir>"\
"#<tomcat-dir>${tomcatDir}</tomcat-dir>#g" $settingsFile

git submodule init

git submodule update

git -C Vitro checkout $vitroBranch

git -C VIVO checkout $vivoBranch

mkdir VIVO/home/config

cp VIVO/home/src/main/resources/config/example.runtime.properties \
   VIVO/home/config/runtime.properties
cp VIVO/home/src/main/resources/config/example.applicationSetup.n3 \
   VIVO/home/config/applicationSetup.n3

cd VIVO || exit
mvn install -s ../project-settings.xml

# miscellaneous
mkdir -p "${tomcatDir}/webapps/${appName}/WEB-INF/resources/home-files"

# set permissions
sudo chown -R tomcat:tomcat $appDir
sudo chmod 775 -R $appDir
sudo chown -R tomcat:tomcat $tomcatDir
sudo chmod 775 -R $tomcatDir

# instructions
echo "VIVO deployment completed"
echo "sudo systemctl restart tomcat"
echo "Open: http://localhost:8080/${appName}"
echo "vivo_root@mydomain.edu"
echo "rootPassword"
