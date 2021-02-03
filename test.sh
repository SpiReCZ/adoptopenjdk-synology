#!/bin/sh

SYNOPKG_DSM_VERSION_MAJOR=6

# 8, 11
#JAVA_VERSION=11

JAVA_VERSION_8="false"
JAVA_VERSION_11="true"
JAVA_VERSION_15="false"

# hotspot, openj9
JVM_IMPL=openj9
# jre, jdk
JAVA_IMAGE_TYPE=jre

SYNOPKG_PKGDEST=./adoptopenjdk

. scripts/installer.sh
preinst
postinst
# better not use on your local environment ;)
#echo "start-stop-status.sh"
#scripts/start-stop-status.sh start
#scripts/start-stop-status.sh stop
#scripts/start-stop-status.sh status
#scripts/start-stop-status.sh log
#scripts/installer.sh && preupgrade
#scripts/installer.sh && postupgrade
#scripts/installer.sh && preuninst
#scripts/installer.sh && postuninst
