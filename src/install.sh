#!/bin/bash

desktop_path="${HOME}/.local/share/applications"
image_path="${HOME}/.local/share/icons"
bin_path="${HOME}/.local/bin"

if [ "$EUID" -ne 0 ]; then
  echo "You are using this script as normal user, all changes will be avaiable only for your user."
  read -p "Do you want to proceed? (y/N) " yn
  case $yn in
    [yYsS] ) 
      image_path="${HOME}/.local/share/icons";
      bin_path="${HOME}/.local/bin";
      desktop_path="${HOME}/.local/share/applications";
      echo "Remember that you must add ${HOME}/.local/bin directory to your path to launch mywhatsappweb from command line."
      ;;
    * ) 
      echo "Aborted";
      exit 1;
  esac
else
  echo "You are using this script as normal user, all changes will be avaiable only for your user."
  read -p "Do you want to proceed? (y/N) " yn
  case $yn in
    [yYsS] ) 
      image_path="/usr/local/share/icons";
      bin_path="/usr/local/bin";
      desktop_path="/usr/share/applications"
      ;;
    * ) 
      echo "Aborted";
      exit 1;
  esac
fi
echo "Creating folders ..."
[[ ! -d "${bin_path}" ]] && mkdir -p "${bin_path}"
[[ ! -d "${image_path}" ]] && mkdir -p "${image_path}"
[[ ! -d "${desktop_path}" ]] && mkdir -p "${desktop_path}"

echo "Copy icon ..."
cp ./mywhatsappweb.png "${image_path}/mywhatsappweb.png"
echo "Copy desktop file ..."
cp ./mywhatsappweb.desktop "${desktop_path}/mywhatsappweb.desktop"
sed -i "s|@image_path@|${image_path}|g" "${desktop_path}/mywhatsappweb.desktop"
sed -i "s|@bin_path@|${bin_path}|g" "${desktop_path}/mywhatsappweb.desktop"
echo "Copy bin ..."
cp ./bin/mywhatsappweb "${bin_path}/mywhatsappweb"
chmod +x "${bin_path}/mywhatsappweb"
echo "Installation completed"
exit 0