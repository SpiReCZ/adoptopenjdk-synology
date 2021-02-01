#!/bin/sh

INSTALL_UIFILE_TEMPLATE=$(/bin/cat<<EOF
[
  {
      "step_title": "Java Runtime Environment Selection",
      "items": [
        {
          "type": "singleselect",
          "desc": "Java version (default: 11):",
          "subitems": [
          ]
        }
      ]
  },
  {
    "step_title": "Java Runtime Environment Selection",
    "items": [
      {
        "type": "singleselect",
        "desc": "Package type (default: JRE):",
        "subitems": [
          {
            "key": "JAVA_IMAGE_TYPE_JRE",
            "desc": "JRE - Java Runtime Environment",
            "defaultValue": true
          },
          {
            "key": "JAVA_IMAGE_TYPE_JDK",
            "desc": "JDK - Java Development Kit",
            "defaultValue": false
          }
        ]
      },
      {
        "type": "singleselect",
        "desc": "JVM selection (default: OpenJ9):",
        "subitems": [
          {
            "key": "JVM_IMPL_OPENJ9",
            "desc": "OpenJ9 - Smaller memory footprint (x86, aarch64 only)",
            "defaultValue": true
          },
          {
            "key": "JVM_IMPL_HOTSPOT",
            "desc": "HotSpot - Standard OpenJDK (x86, aarch64, arm)",
            "defaultValue": false
          }
        ]
      }
    ]
  }
]
EOF
)

subitem() {
  echo ''"${4}"'{ "key": "'"${1}"'", "desc": "'"${2}"'", "defaultValue": '"${3}"' }'
}

# 1 -> versions 2 -> versions LTS
subitems() {
  echo "["
  VERSION_UI_ITEMS=""
  for version in ${1} ; do
    i=$((i+1))
    case "$2" in *"$version"*) IS_LTS="$version" ;; esac
    if [ "$IS_LTS" = "$version" ]; then
      COMMENT=" (LTS)"
    else
      COMMENT=""
    fi
    if [ "$JAVA_VERSION_LATEST_LTS" = "$version" ]; then
      IS_DEFAULT="true"
    else
      IS_DEFAULT="false"
    fi
    PREFIX=""
    if [ -n "$VERSION_UI_ITEMS" ]; then
      PREFIX=","
    fi
    if [ "$JAVA_VERSION_LATEST_FEATURE" = "$version" ] || [ "$IS_LTS" = "$version" ]; then
      VERSION_UI_ITEMS="$VERSION_UI_ITEMS"$(subitem "JAVA_VERSION_$version" "$version$COMMENT" "$IS_DEFAULT" "${PREFIX}")
    fi
  done
  echo "$VERSION_UI_ITEMS"
  echo "]"
}

(
set -e

JSON_VER_RESPONSE=$(curl -sb -H "Accept: application/json" "https://api.adoptopenjdk.net/v3/info/available_releases")
JAVA_VERSION_LATEST_LTS=$(echo "${JSON_VER_RESPONSE}" | jq '.most_recent_lts')
JAVA_VERSION_LATEST_FEATURE=$(echo "${JSON_VER_RESPONSE}" | jq  '.most_recent_feature_release')
JAVA_VERSIONS_LTS=$(echo "${JSON_VER_RESPONSE}" | jq '.available_lts_releases | .[]' | tr '\n' ' ' | xargs)
JAVA_VERSIONS=$(echo "${JSON_VER_RESPONSE}" | jq -c '.available_releases | .[]' | tr '\n' ' ' | xargs)

INSTALL_UI=$(echo "${INSTALL_UIFILE_TEMPLATE}" | jq -r \
  --arg JAVA_VERSION_LATEST_LTS "$JAVA_VERSION_LATEST_LTS" \
  --argjson JAVA_VERSIONS "$(subitems "$JAVA_VERSIONS" "$JAVA_VERSIONS_LTS")" \
' .[0].items[0].desc = "Java version (default: "+$JAVA_VERSION_LATEST_LTS+"):" |
.[0].items[0].subitems += $JAVA_VERSIONS
')

echo "$INSTALL_UI" > "$SYNOPKG_TEMP_LOGFILE"
)
INSTALL_UI_EXIT_CODE="$?"

# shellcheck disable=SC2181
if [ "$INSTALL_UI_EXIT_CODE" -ne 0 ]; then
    /bin/cat<<EOF > "$SYNOPKG_TEMP_LOGFILE"
[
  {
      "step_title": "Installation has failed.",
      "invalid_next_disabled": true,
      "items": [
        {
          "type": "singleselect",
          "desc": "UI rendering error has occured.<br><br>This UI is dynamically generated, so there can be problem connecting to the server or API has changed. Try installing this package again.<br><br>Feel free to report the issue here: <a href=\"https://github.com/SpiReCZ/adoptopenjdk-synology/issues\" target=\"_blank\">LINK</a>.<br><br>",
          "subitems": [
            {
              "key": "JAVA_UI_INSTALL_ERROR",
              "defaultValue": true,
              "disabled": false,
              "hidden": true,
              "validator": {
                "fn": "{return 'Unable to continue. Please read the information on the this page and cancel the installation.';}"
              }
            }
          ]
        }
      ]
  }
]
EOF
fi
