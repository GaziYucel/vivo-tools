# VIVO deployment on Windows
# Run the script as Administrator and ensure the Tomcat service user has access is sufficient.

# Stop script on errors
$ErrorActionPreference = "Stop"

# Configuration variables
$AppName = "rel-1.15-maint"                              # Application release name to deploy
$Branch = $AppName                                       # Application branch name to deploy
$AppDir = "C:\opt\${AppName}"                            # Target installation directory for this app
$TomcatDir = "C:\opt\tomcat"                             # Tomcat installation directory to deploy webapp to
$SettingsFile = "${AppDir}\project-settings.xml"         # Path to the Maven/project settings file that will be edited

Write-Host "Starting VIVO deployment for ${AppName}"

# Create the application directory if it doesn't exist
if (-not (Test-Path $AppDir)) {
    New-Item -Path $AppDir -ItemType Directory -Force
}

# Move into the application directory
Set-Location $AppDir

# Clone the project template repository into the current directory and check out the specified branch
git clone https://git.tib.eu/OSL/VIVO/VIVO_PROJECT_TEMPLATE.git -b $Branch .

# Update settings file
(Get-Content $SettingsFile) `
-replace '<app-name>vivo</app-name>', "<app-name>${AppName}</app-name>" `
-replace '<vivo-dir>/tib/app/vivo/data/vivo</vivo-dir>', "<vivo-dir>$($AppDir.Replace('\', '/'))/VIVO/home</vivo-dir>" `
-replace '<tomcat-dir>/Program Files/Apache Software Foundation/Tomcat 9.0</tomcat-dir>', "<tomcat-dir>$($TomcatDir.Replace('\', '/'))</tomcat-dir>" |
Set-Content $SettingsFile

# Initialize and update git submodules required by the project
git submodule init
git submodule update

# Ensure submodules Vitro and VIVO are checked out to the desired branch
git -C Vitro checkout $Branch
git -C VIVO checkout $Branch

# Create configuration directory used by the VIVO application
New-Item -Path "VIVO\home\config" -ItemType Directory -Force

# Copy example runtime and application setup files into the config directory
Copy-Item "VIVO\home\src\main\resources\config\example.runtime.properties" "VIVO\home\config\runtime.properties" -Force
Copy-Item "VIVO\home\src\main\resources\config\example.applicationSetup.n3" "VIVO\home\config\applicationSetup.n3" -Force

# Build the VIVO module with Maven using the project-settings.xml
Set-Location VIVO
mvn install -s ..\project-settings.xml

# miscellaneous
$MiscDir = "${TomcatDir}\webapps\${AppName}\WEB-INF\resources\home-files"
if (-not (Test-Path $MiscDir)) {
    New-Item -Path $MiscDir -ItemType Directory -Force
}

# Final instructions printed for the operator
Write-Host "VIVO deployment completed"
Write-Host "Open: http://localhost:8080/${AppName}"
Write-Host "Username: vivo_root@mydomain.edu"
Write-Host "Password: rootPassword"
