#!/bin/sh

# Original part of this script by: pcloadletter.co.uk
JDK_PATH="/var/packages/${SYNOPKG_PKGNAME}/target/"
JRE_PATH=${JDK_PATH}
[ -d "${JDK_PATH}/jre/" ] && JRE_PATH=${JDK_PATH}/jre/
COMMENT="# AdoptOpenJDK Java Package"

EnvCheck ()
#updates to DSM will reset these changes so check them each startup 
{
  #/etc/profile should contain 5 lines added by this package tagged with trailing comments
  COUNT=$(grep -c "$COMMENT$" /etc/profile)
  if [ "${COUNT}" != 5 ]; then

    #remove any existing mods
    sed -i "/${COMMENT}/d" /etc/profile

    #add required environment variables
    echo "PATH=\$PATH:${JRE_PATH}/bin ${COMMENT}" >> /etc/profile
    echo "JAVA_HOME=${JRE_PATH} ${COMMENT}" >> /etc/profile
    echo "CLASSPATH=.:${JRE_PATH}/lib ${COMMENT}" >> /etc/profile
    echo "LANG=en_US.utf8 ${COMMENT}" >> /etc/profile
    echo "export CLASSPATH JAVA_HOME LANG PATH ${COMMENT}" >> /etc/profile
  fi

  #/root/.profile should contain 2 lines added by this package tagged with trailing comments
  COUNT=$(grep -c "$COMMENT$" /root/.profile)
  if [ "${COUNT}" != 2 ]; then

    #remove any existing mods
    sed -i "/${COMMENT}/d" /root/.profile

    #add required environment variables
    echo "PATH=\$PATH:${JRE_PATH}/bin ${COMMENT}" >> /root/.profile
    echo "JAVA_HOME=${JRE_PATH} ${COMMENT}" >> /root/.profile
  fi

}

case $1 in
  start)
    EnvCheck
    . /etc/profile
    . /root/.profile

    #evidence of whether Java can start successfully is written to the package log
    java -version > "${SYNOPKG_PKGDEST}"/output.log 2>&1
    echo >> "${SYNOPKG_PKGDEST}"/output.log
    echo JAVA_HOME="${JAVA_HOME}" >> "${SYNOPKG_PKGDEST}"/output.log

    exit 0
  ;;

  stop)
    exit 0
  ;;

  status)
    . /etc/profile
    . /root/.profile
    if [ -e "${JAVA_HOME}/bin/java" ] && [ -x "${JAVA_HOME}/bin/java" ]; then
      exit 0
    else
      exit 1
    fi
  ;;

  log)
    echo "${SYNOPKG_PKGDEST}/output.log"
    exit 0
  ;;

esac

