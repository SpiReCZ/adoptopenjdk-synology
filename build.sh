#!/bin/sh

# This is custom tailored script inspired by: https://github.com/palsbo/synology-spk-maker

set -e

SCRIPTS_DIR="$(cd "$(dirname '$0')" >/dev/null 2>&1 && pwd)"
PKG_NAME=$(grep "package=" ./INFO | cut -d'"' -f 2)
ver=$(grep "version=" ./INFO | cut -d'"' -f 2)
file="$PKG_NAME-$ver.spk"
filepath="${SCRIPTS_DIR}/$file"

echo "Creating $file"

if [ -f "$filepath" ]; then rm -f "$filepath"; fi
#tar czvf "${SCRIPTS_DIR}"/package.tgz --files-from=/dev/null

cd package
shopt -s dotglob
tar -czf ../package.tgz ./*
shopt -u dotglob
cd ../

cp ./WIZARD_UIFILES/install_uifile.sh ./WIZARD_UIFILES/upgrade_uifile.sh

tar -cf "$filepath" INFO package.tgz scripts WIZARD_UIFILES
if [ -f "${SCRIPTS_DIR}"/PACKAGE_ICON.PNG ]; then tar -rf "$filepath" PACKAGE_ICON.PNG; fi
if [ -f "${SCRIPTS_DIR}"/PACKAGE_ICON_120.PNG ]; then tar -rf "$filepath" PACKAGE_ICON_120.PNG; fi

echo "File $file created."
