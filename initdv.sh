#!/bin/sh 
DEMO="JBoss BPM Suite & Fuse Travel Agency Integration Demo"
AUTHORS="Christina Lin, Andrew Block, Eric D. Schabell, Cojan van Ballegooijen"
PROJECT="git@github.com:jbossdemocentral/bpms-fuse-travel-agency-integration-demo.git"

#DV env
JBOSS_HOME=./target/dv6.2/jboss-eap-6.4
SERVER_DIR=$JBOSS_HOME/standalone/deployments/
SERVER_CONF=$JBOSS_HOME/standalone/configuration/
SERVER_BIN=$JBOSS_HOME/bin
SRC_DIR=./installs
PRJ_DIR=./projects
SUPPORT_DIR=./support
DV=jboss-dv-installer-6.2.0.redhat-2.jar
EAP=jboss-eap-6.4.0-installer.jar
EAP_PATCH=jboss-eap-6.4.3-patch.zip
DV_VERSION=6.2
DV_PATCH=BZ-1268321.zip

# wipe screen.
clear 

# add executeable in installs
chmod +x installs/*.zip
echo "#################################################################"
echo "##                                                             ##"
echo "##  Setting up the ${DEMO}         ##"
echo "##                                                             ##"
echo "##                                                             ##"
echo "##                ####  #   #                                  ##"
echo "##                #   # #   #                                  ##"
echo "##                #   # #   #                                  ##"
echo "##                #   #  # #                                   ##"
echo "##                ####    #                                    ##"
echo "##                                                             ##"
echo "##                                                             ##"
echo "##  ${AUTHORS}               ##"
echo "##                                                             ##"   
echo "##  ${PROJECT}   ##"
echo "##                                                             ##"   
echo "#################################################################"
echo

command -v mvn -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed yet... aborting."; exit 1; }

# Check mvn version must be in 3.1.1 to 3.2.4	
verone=$(mvn -version | awk '/Apache Maven/{print $3}' | awk -F[=.] '{print $1}')
vertwo=$(mvn -version | awk '/Apache Maven/{print $3}' | awk -F[=.] '{print $2}')
verthree=$(mvn -version | awk '/Apache Maven/{print $3}' | awk -F[=.] '{print $3}')     
     
if [[ $verone -eq 3 ]] && [[ $vertwo -eq 1 ]] && [[ $verthree -ge 1 ]]; then
		echo  Correct Maven version $verone.$vertwo.$verthree
		echo
elif [[ $verone -eq 3 ]] && [[ $vertwo -eq 3 ]] && [[ $verthree -le 9 ]]; then
		echo  Correct Maven version $verone.$vertwo.$verthree
		echo
else
		echo Please make sure you have Maven 3.1.1 - 3.3.9 installed in order to use fabric maven plugin.
		echo
		echo We are unable to run with current installed maven version: $verone.$vertwo.$verthree
		echo	
		exit
fi

# make some checks first before proceeding.	
if [ -r $SRC_DIR/$EAP ] || [ -L $SRC_DIR/$EAP ]; then
	echo Product sources are present...
	echo
else
	echo Need to download $EAP package from the Customer Portal 
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi

if [ -r $SRC_DIR/$EAP_PATCH ] || [ -L $SRC_DIR/$EAP_PATCH ]; then
	echo EAP patches are present...
	echo
else
	echo Need to download $EAP_PATCH package from the Customer Portal 
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi

if [ -r $SRC_DIR/$DV ] || [ -L $SRC_DIR/$DV ]; then
	echo Product sources DV are present...
	echo
else
	echo Need to download $DV package from the Customer Portal 
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi

if [ -r $SRC_DIR/$DV_PATCH ] || [ -L $SRC_DIR/$DV_PATCH ]; then
        echo DV patches are present...
        echo
else
        echo Need to download $DV_PATCH package from the Customer Portal
        echo and place it in the $SRC_DIR directory to proceed...
        echo
        exit
fi

# Remove JBoss product installation if exists.
if [ -x target ]; then
	echo "  - existing JBoss product installation detected..."
	echo
	echo "  - removing existing JBoss product installation..."
	echo
	rm -rf target
fi

# Run installers.
echo "JBoss EAP installer running now..."
echo
java -jar $SRC_DIR/$EAP $SUPPORT_DIR/installation-dveap -variablefile $SUPPORT_DIR/installation-dveap.variables

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during JBoss EAP installation!
	exit
fi

echo
echo "Applying JBoss EAP 6.4.3 patch now..."
echo
$JBOSS_HOME/bin/jboss-cli.sh --command="patch apply $SRC_DIR/$EAP_PATCH"

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during JBoss EAP patching!
	exit
fi

echo
echo "JBoss Data Virtualization installer running now..."
echo
java -jar $SRC_DIR/$DV $SUPPORT_DIR/installation-dv -variablefile $SUPPORT_DIR/installation-dv.variables

if [ $? -ne 0 ]; then
	echo Error occurred during DV installation!
	exit
fi

echo "  - enabling demo accounts role setup in application-roles.properties file..."
echo
cp $SUPPORT_DIR/dv-application-roles.properties $SERVER_CONF/application-roles.properties
cp $SUPPORT_DIR/dv-application-users.properties $SERVER_CONF/application-users.properties

echo "  - setting up demo projects..."
echo

echo "  - setting up web services..."
echo

echo "  - setting up standalone.xml configuration adjustments..."
echo
cp $SUPPORT_DIR/standalone-dv.xml $SERVER_CONF/standalone.xml

echo "  - making sure standalone.sh for server is executable..."
echo
chmod u+x $JBOSS_HOME/bin/standalone.sh

echo "==========================================================================================="
echo "=                                                                                         ="
echo "=  You can now start JBoss Data Virtualization with:                                      ="
echo "=                                                                                         ="
echo "=        $SERVER_BIN/standalone.sh                                   ="
echo "=                                                                                         ="
echo "=   $DEMO Setup Complete.                 ="
echo "==========================================================================================="
echo
