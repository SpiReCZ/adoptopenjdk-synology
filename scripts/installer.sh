#!/bin/sh

# Exit immediately when error occurs
set -e

COMMENT="# AdoptOpenJDK Java Package"

# Original part of this script section by: pcloadletter.co.uk
SYNO_CPU_ARCH="$(uname -m)"
[ "$(echo "${SYNO_CPU_ARCH}" | cut -c1-7)" = "armv5te" ] && SYNO_CPU_ARCH="armv5tel"
#--------Synology switched Armada 370 systems from SoftFP to HardFP EABI for DSM 6.0
[ "${SYNOPKG_DSM_ARCH}" = "armada370" ] && [ "${SYNOPKG_DSM_VERSION_MAJOR}" -gt 5 ] && SYNO_CPU_ARCH="armv7l-hflt"
[ "${SYNOPKG_DSM_ARCH}" = "armada375" ] && SYNO_CPU_ARCH="armv7l-hflt"
[ "${SYNOPKG_DSM_ARCH}" = "armada38x" ] && SYNO_CPU_ARCH="armv7l-hflt"
[ "${SYNOPKG_DSM_ARCH}" = "comcerto2k" ] && SYNO_CPU_ARCH="armv7l-hflt"
[ "${SYNOPKG_DSM_ARCH}" = "alpine" ] && SYNO_CPU_ARCH="armv7l-hflt"
[ "${SYNOPKG_DSM_ARCH}" = "alpine4k" ] && SYNO_CPU_ARCH="armv7l-hflt"
[ "${SYNOPKG_DSM_ARCH}" = "monaco" ] && SYNO_CPU_ARCH="armv7l-hflt"
[ "${SYNO_CPU_ARCH}" = "x86_64" ] && [ "${SYNOPKG_DSM_VERSION_MAJOR}" -lt 6 ] && SYNO_CPU_ARCH="i686"
# not tested DSM arm
[ "${SYNOPKG_DSM_ARCH}" = "88f628x" ] && SYNO_CPU_ARCH="arm"
[ "${SYNOPKG_DSM_ARCH}" = "armadaxp" ] && SYNO_CPU_ARCH="arm"
[ "${SYNOPKG_DSM_ARCH}" = "armv7" ] && SYNO_CPU_ARCH="arm"
[ "${SYNOPKG_DSM_ARCH}" = "hi3535" ] && SYNO_CPU_ARCH="arm"
# not tested SRM arm
[ "${SYNOPKG_DSM_ARCH}" = "ipq806x" ] && SYNO_CPU_ARCH="arm"
[ "${SYNOPKG_DSM_ARCH}" = "dakota" ] && SYNO_CPU_ARCH="arm"
[ "${SYNOPKG_DSM_ARCH}" = "northstarplus" ] && SYNO_CPU_ARCH="arm"


# General install variables
JAVA_PKG_FILENAME="adoptopenjdk.tar.gz"
#SCRIPTS_DIR="$(cd "$(dirname '$0')" >/dev/null 2>&1 && pwd)"
TEMP_FOLDER="$(find / -maxdepth 2 -path '/volume?/@tmp' 2>/dev/null | head -n 1 | grep . || echo "/tmp")"

# Java package selection variables
RELEASE="latest"
# linux, windows, mac, ...
JAVA_OS="linux"
# normal, large - required with openj9
JAVA_HEAP_SIZE="normal"

# jdk, jre
[ "${JAVA_IMAGE_TYPE_JDK}" = "true" ] && JAVA_IMAGE_TYPE="jdk"
[ "${JAVA_IMAGE_TYPE_JRE}" = "true" ] && JAVA_IMAGE_TYPE="jre"

# aarch64, x64, arm
[ "${SYNO_CPU_ARCH}" = "x86_64" ] && JAVA_ARCHITECTURE="x64"
[ "${SYNO_CPU_ARCH}" = "aarch64" ] && JAVA_ARCHITECTURE="aarch64"
case "${SYNO_CPU_ARCH}" in
  "arm"*) JAVA_ARCHITECTURE="arm" ;;
esac

#echo "${JAVA_ARCHITECTURE}"

# hotspot, openj9
if [ "${JAVA_ARCHITECTURE}" = "x64" ] || [ "${JAVA_ARCHITECTURE}" = "aarch64" ]; then
  [ "${JVM_IMPL_OPENJ9}" = "true" ] && JVM_IMPL="openj9"
  [ "${JVM_IMPL_HOTSPOT}" = "true" ] && JVM_IMPL="hotspot"
else
  JVM_IMPL="hotspot"
fi


preinst() {
  # choose JAVA_VERSION
  # shellcheck disable=SC2039
  for i in $(compgen -A variable | grep JAVA_VERSION_); do
    if [ "$(eval echo \$"${i}")" = "true" ]; then
      JAVA_VERSION=$(echo "$i" | sed -e 's/JAVA_VERSION_//g')
    fi
  done

  if [ -z "${JAVA_VERSION}" ]; then
    echo 'JAVA_VERSION not set!'
    exit 1
  fi

  # i686 not supported
  if [ -z "${JAVA_ARCHITECTURE}" ]; then
    echo "This platform is not supported: $(uname -m), ${SYNOPKG_DSM_ARCH}."
    echo "Details: $(uname -a)"
    exit 1
  fi

  # https://api.adoptopenjdk.net/v3/assets/latest/11/hotspot?release=latest&vendor=adoptopenjdk
  API_URL="https://api.adoptopenjdk.net/v3/assets/latest/${JAVA_VERSION:?}/${JVM_IMPL:?}?release=${RELEASE:?}&vendor=adoptopenjdk"

  JSON_RESPONSE=$(curl -sb -H "Accept: application/json" "${API_URL}")

  JSON_RESPONSE=$(echo "${JSON_RESPONSE}" | jq -r \
  --arg OS "${JAVA_OS}" \
  --arg IMAGE_TYPE "${JAVA_IMAGE_TYPE}" \
  --arg ARCHITECTURE "${JAVA_ARCHITECTURE}" \
  --arg HEAP_SIZE "${JAVA_HEAP_SIZE}" \
  '.[]
  | select(.binary.os==$OS)
  | select(.binary.image_type==$IMAGE_TYPE)
  | select(.binary.architecture==$ARCHITECTURE)
  | select(.binary.heap_size==$HEAP_SIZE)')

  DOWNLOAD_URL=$(echo "$JSON_RESPONSE" | jq -r '.binary.package.link')
  DOWNLOAD_CHECKSUM_SHA256_API=$(echo "$JSON_RESPONSE" | jq -r '.binary.package.checksum')

  #echo "${DOWNLOAD_URL}"

  if [ -z "${DOWNLOAD_URL}" ] || [ "$(echo "${DOWNLOAD_URL}" | wc -l)" -gt 1 ]; then
    if [ -z "${DOWNLOAD_URL}" ] ]; then
      echo "Error has occurred. DOWNLOAD_URL is empty."
    else
      echo "Error has occurred. Got multiple results for DOWNLOAD_URL:"
      echo "${DOWNLOAD_URL}"
    fi
    echo "This is probably due to AdopOpenJDK API changes or a script error."
    exit 1
  fi

  #echo "${DOWNLOAD_URL}"

  #echo "Download starting"
  curl -L -o "${TEMP_FOLDER}/${JAVA_PKG_FILENAME}" "${DOWNLOAD_URL}"
  #echo "Download finished"

  echo "$DOWNLOAD_CHECKSUM_SHA256_API ${TEMP_FOLDER}/${JAVA_PKG_FILENAME}" | sha256sum -c --quiet
}


postinst() {
  #echo "Create directory $SYNOPKG_PKGDEST"
  mkdir -p "${SYNOPKG_PKGDEST:?}"

  #echo "Unzip downloaded package"
  tar -xzf "${TEMP_FOLDER:?}/${JAVA_PKG_FILENAME:?}" -C "${SYNOPKG_PKGDEST:?}" --strip-components=1

  #echo "Delete downloaded package"
  rm -f "${TEMP_FOLDER:?}/${JAVA_PKG_FILENAME:?}"

  #echo "Fix permissions"
  chown -R root:root "${SYNOPKG_PKGDEST:?}"

  #echo "Test java -version"
  "${SYNOPKG_PKGDEST:?}"/bin/java -version
}


preuninst () {
  exit 0
}


postuninst () {
  #clean up profile mods
  sed -i "/${COMMENT}/d" /etc/profile
  sed -i "/${COMMENT}/d" /root/.profile

  exit 0
}

preupgrade() {
  exit 0
}

postupgrade() {
  exit 0
}
