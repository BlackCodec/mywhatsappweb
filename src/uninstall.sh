#!/bin/bash

desktop_path="${HOME}/.local/share/applications"
image_path="${HOME}/.local/share/icons"
bin_path="${HOME}/.local/bin"

echo "Check user icon folder ..."
if [[ -f "${image_path}/mywhatsappweb.png" ]]; then
  echo "Remove file from user icon folder ..."
  rm -f "${image_path}/mywhatsappweb.png"
fi
echo "Check user desktop file ..."
if [[ -f "${desktop_path}/mywhatsappweb.desktop" ]]; then
  echo "Remove file from user desktop folder ..."
  rm -f "${desktop_path}/mywhatsappweb.desktop"
fi
echo "Check user bin file ..."
if [[ -f "${bin_path}/mywhatsappweb" ]]; then
  echo "Remove bin file from user bin folder ..."
  rm -f "${bin_path}/mywhatsappweb"
fi

if [ "$EUID" -ne 0 ]; then
  echo "You are using this script as normal user, this script can only check if the file exists globally but cannot remove them."
  echo "If you want to remove files globally execute this script with sudo."
fi

image_path="/usr/local/share/icons";
bin_path="/usr/local/bin";
desktop_path="/usr/share/applications"

echo "Check icon folder ..."
if [[ -f "${image_path}/mywhatsappweb.png" ]]; then
  if [ "$EUID" -ne 0 ]; then
    echo "Remove file from icon folder ..."
    rm -f "${image_path}/mywhatsappweb.png"
  else
    echo "You need to manually remove file: ${image_path}/mywhatsappweb.png"
  fi
fi
echo "Check desktop file ..."
if [[ -f "${desktop_path}/mywhatsappweb.desktop" ]]; then
  if [ "$EUID" -ne 0 ]; then
    echo "Remove file from desktop folder ..."
    rm -f "${desktop_path}/mywhatsappweb.desktop"
  else
    echo "You need to manually remove file: ${desktop_path}/mywhatsappweb.desktop"
  fi
fi
echo "Check bin file ..."
if [[ -f "${bin_path}/mywhatsappweb" ]]; then
  if [ "$EUID" -ne 0 ]; then
    echo "Remove bin file from bin folder ..."
    rm -f "${bin_path}/mywhatsappweb"
  else
    echo "You need to manually remove file: ${bin_path}/mywhatsappweb"
  fi
fi

echo "Complete"
exit 0