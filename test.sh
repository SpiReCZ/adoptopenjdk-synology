#!/bin/sh

SYNOPKG_DSM_VERSION_MAJOR=6

# 8, 11
#JAVA_VERSION=11

JAVA_VERSION_11="false"
JAVA_VERSION_11="false"
JAVA_VERSION_LATEST_LTS="false"
JAVA_VERSION_LATEST_FEATURE="true"

# hotspot, openj9
JVM_IMPL=openj9
# jre, jdk
JAVA_IMAGE_TYPE=jre

SYNOPKG_PKGDEST=./adoptopenjdk

. scripts/installer.sh && preinst
. scripts/installer.sh && postinst
# better not use on your local environment ;)
#. scripts/star-stop-status.sh start
