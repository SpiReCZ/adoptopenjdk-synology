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

. scripts/installer.sh && preinst
. scripts/installer.sh && postinst
# better not use on your local environment ;)
#. scripts/star-stop-status.sh start
