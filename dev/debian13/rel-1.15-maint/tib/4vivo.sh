#!/bin/bash
set -x #echo on
sudo echo "$(basename "$0")"

# Configuration variables
appName="rel-1.15-maint"                                             # Application release name to deploy
branch=$appName                                                      # Application branch name to deploy
appDir="/opt/${appName}"                                             # Target installation directory for this app
tomcatDir="/opt/tomcat"                                              # Tomcat installation directory to deploy webapp to
settingsFile="/opt/${appName}/project-settings.xml"                  # Path to the Maven/project settings file that will be edited

# Create the application directory if it doesn't exist
sudo mkdir -p "$appDir"

# Ensure the directory is owned by the tomcat user/group so Tomcat can access it
sudo chown tomcat:tomcat "$appDir"

# Give wide open access during build/deploy (adjust to stricter perms for production)
sudo chmod 777 "$appDir"

# Move into the application directory, exit script if cd fails
cd "$appDir" || exit 1

# Clone the project template repository into the current directory and check out the specified branch
git clone https://git.tib.eu/OSL/VIVO/VIVO_PROJECT_TEMPLATE.git -b $branch .

# Update settings file
sed -i "s#<app-name>vivo</app-name>#<app-name>${appName}</app-name>#g" $settingsFile
sed -i "s#<vivo-dir>/tib/app/vivo/data/vivo</vivo-dir>#<vivo-dir>${appDir}/VIVO/home</vivo-dir>#g" $settingsFile
sed -i "s#<tomcat-dir>/Program Files/Apache Software Foundation/Tomcat 9.0</tomcat-dir>#<tomcat-dir>${tomcatDir}</tomcat-dir>#g" $settingsFile

# Initialize and update git submodules required by the project
git submodule init
git submodule update

# Ensure submodules Vitro and VIVO are checked out to the desired branch
git -C Vitro checkout $branch
git -C VIVO checkout $branch

# Create configuration directory used by the VIVO application
mkdir -p VIVO/home/config

# Copy example runtime and application setup files into the config directory
cp VIVO/home/src/main/resources/config/example.runtime.properties \
   VIVO/home/config/runtime.properties
cp VIVO/home/src/main/resources/config/example.applicationSetup.n3 \
   VIVO/home/config/applicationSetup.n3

# Build the VIVO module with Maven using the project-settings.xml
cd VIVO || exit 1
mvn install -s settingsFile

# Set permissions recursively so Tomcat can read/write where appropriate
sudo chown -R tomcat:tomcat $appDir
sudo chmod 775 -R $appDir

# Ensure Tomcat directory is owned by tomcat user/group and has appropriate permissions
sudo chown -R tomcat:tomcat $tomcatDir
sudo chmod 775 -R $tomcatDir

# Final instructions printed for the operator
echo "VIVO deployment completed"
echo "sudo systemctl restart tomcat"
echo "Open: http://localhost:8080/${appName}"
echo "vivo_root@mydomain.edu"
echo "rootPassword"
