#!/bin/bash

# Set these to the latest version of FantasyGold to update
TARBALLURL="https://github.com/FantasyGold/FantasyGold-Core/releases/download/v1.2.7/FantasyGold-1.2.7-Linux-x64.tar.gz"
TARBALLNAME="FantasyGold-1.2.7-Linux-x64.tar.gz"
FGCVERSION="1.2.7"

CHARS="/-\|"

clear
echo "This script will update your FantasyGold CLI to version $FGCVERSION"
read -p "Press Ctrl-C to abort or any other key to continue. " -n1 -s
clear

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root."
  exit 1
fi

USER=`ps u $(pgrep fantasygoldd) | grep fantasygoldd | cut -d " " -f 1`
USERHOME=`eval echo "~$USER"`

echo "FantasyGold Shutting Down..."
if [ -e /etc/systemd/system/fantasygoldd.service ]; then
  systemctl stop fantasygoldd
else
  su -c "fantasygold-cli stop" $USER
fi

echo "Installing FantasyGold $FGCVERSION"
mkdir ./fantasygold-temp && cd ./fantasygold-temp
wget $TARBALLURL
tar -xzvf $TARBALLNAME && mv bin fantasygold-$FGCVERSION
yes | cp -rf ./fantasygold-$FGCVERSION/fantasygoldd /usr/local/bin
yes | cp -rf ./fantasygold-$FGCVERSION/fantasygold-cli /usr/local/bin
cd ..
rm -rf ./fantasygold-temp

if [ -e /usr/bin/fantasygoldd ];then rm -rf /usr/bin/fantasygoldd; fi
if [ -e /usr/bin/fantasygold-cli ];then rm -rf /usr/bin/fantasygold-cli; fi
if [ -e /usr/bin/fantasygold-tx ];then rm -rf /usr/bin/fantasygold-tx; fi

sed -i '/^addnode/d' $USERHOME/.fantasygold/fantasygold.conf

echo "Restarting fantasygold daemon..."
if [ -e /etc/systemd/system/fantasygoldd.service ]; then
  systemctl start fantasygoldd
else
  cat > /etc/systemd/system/fantasygoldd.service << EOL
[Unit]
Description=fantasygoldd
After=network.target
[Service]
Type=forking
User=${USER}
WorkingDirectory=${USERHOME}
ExecStart=/usr/local/bin/fantasygoldd -conf=${USERHOME}/.fantasygold/fantasygold.conf -datadir=${USERHOME}/.fantasygold
ExecStop=/usr/local/bin/fantasygold-cli -conf=${USERHOME}/.fantasygold/fantasygold.conf -datadir=${USERHOME}/.fantasygold stop
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOL
  sudo systemctl enable fantasygoldd
  sudo systemctl start fantasygoldd
fi
clear

echo "Your node is syncing. Please wait for this process to finish."

until su -c "fantasygold-cli start 2>/dev/null | grep 'successfully started' > /dev/null" $USER; do
  for (( i=0; i<${#CHARS}; i++ )); do
    sleep 2
    echo -en "${CHARS:$i:1}" "\r"
  done
done

su -c "fantasygold-cli getinfo" $USER


