#!/bin/bash
clear

# Set these to change the version of FantasyGold to install
TARBALLURL="https://github.com/FantasyGold/FantasyGold-Core/releases/download/v1.2.7/FantasyGold-1.2.7-Linux-x64.tar.gz"
TARBALLNAME="FantasyGold-1.2.7-Linux-x64.tar.gz"
FGCVERSION="1.2.7"

# Check if we are root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi

# Check if we have enough memory
if [[ `free -m | awk '/^Mem:/{print $2}'` -lt 900 ]]; then
  echo "This installation requires at least 1GB of RAM.";
  exit 1
fi

# Check if we have enough disk space
if [[ `df -k --output=avail / | tail -n1` -lt 10485760 ]]; then
  echo "This installation requires at least 10GB of free disk space.";
  exit 1
fi

# Install tools for dig and systemctl
echo "Preparing installation..."
apt-get install git dnsutils systemd -y > /dev/null 2>&1

# Check for systemd
systemctl --version >/dev/null 2>&1 || { echo "systemd is required. Are you using Ubuntu 16.04?"  >&2; exit 1; }

# CHARS is used for the loading animation further down.
CHARS="/-\|"
EXTERNALIP=`dig +short myip.opendns.com @resolver1.opendns.com`
clear

echo "
    ___T_
   | o o |
   |__-__|
   /| []|\\
 ()/|___|\()
    |_|_|
    /_|_\  ---- FANTASYGOLD CORE INSTALLER v1.0 ----+
 |                                                |
 |You can choose between two installation options:|::
 |             default and advanced.              |::
 |                                                |::
 | The advanced installation will install and run |::
 |  the daemon under a non-root user. If you  |::
 |  don't know what that means, use the default   |::
 |              installation method.              |::
 |                                                |::
 | Otherwise, your daemon will not work, and  |::
 |the FGC Team CANNOT assist you in repairing |::
 |        it. You will have to start over.        |::
 |                                                |::
 |Don't use the advanced option unless you are an |::
 |            experienced Linux user.             |::
 |                                                |::
 +------------------------------------------------+::
   ::::::::::::::::::::::::::::::::::::::::::::::::::
"

sleep 5

read -e -p "Use the Advanced Installation? [N/y] : " ADVANCED

if [[ ("$ADVANCED" == "y" || "$ADVANCED" == "Y") ]]; then

USER=fantasygold

adduser $USER --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password > /dev/null

echo "" && echo 'Added user "fantasygold"' && echo ""
sleep 1

else

USER=root

fi

USERHOME=`eval echo "~$USER"`

read -e -p "Server IP Address: " -i $EXTERNALIP -e IP
#read -e -p "Remote Application IP (e.g. 127.0.0.1 # THE IP ADDRESS OF YOUR WEBSITE OR APP) : " APPIP
read -e -p "Install Fail2ban? [Y/n] : " FAIL2BAN
read -e -p "Install UFW and configure ports? [Y/n] : " UFW

clear

# Generate random passwords
RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
RPCPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# update packages and upgrade Ubuntu
echo "Installing dependencies..."
apt-get -qq update
apt-get -qq upgrade
apt-get -qq autoremove
apt-get -qq install wget htop unzip
apt-get -qq install build-essential && apt-get -qq install libtool autotools-dev autoconf automake && apt-get -qq install libssl-dev && apt-get -qq install libboost-all-dev && apt-get -qq install software-properties-common && add-apt-repository -y ppa:bitcoin/bitcoin && apt update && apt-get -qq install libdb4.8-dev && apt-get -qq install libdb4.8++-dev && apt-get -qq install libminiupnpc-dev && apt-get -qq install libqt4-dev libprotobuf-dev protobuf-compiler && apt-get -qq install libqrencode-dev && apt-get -qq install git && apt-get -qq install pkg-config && apt-get -qq install libzmq3-dev
apt-get -qq install aptitude

# Install Fail2Ban
if [[ ("$FAIL2BAN" == "y" || "$FAIL2BAN" == "Y" || "$FAIL2BAN" == "") ]]; then
  aptitude -y -q install fail2ban
  service fail2ban restart
fi

# Install UFW
if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then
  apt-get -qq install ufw
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow ssh
  ufw allow 57814/tcp
  ufw allow 57810/tcp
  yes | ufw enable
fi

# Install FantasyGold daemon
wget $TARBALLURL
tar -xzvf $TARBALLNAME #&& mv bin fantasygold-$FGCVERSION
rm $TARBALLNAME
cp ./fantasygoldd /usr/local/bin
cp ./fantasygold-cli /usr/local/bin
cp ./fantasygold-tx /usr/local/bin
cp ./fantasygold-qt /usr/local/bin
rm -rf fantasygold-$FGCVERSION

# Create .fantasygold directory
mkdir $USERHOME/.fantasygold

# Install bootstrap file
#if [[ ("$BOOTSTRAP" == "y" || "$BOOTSTRAP" == "Y" || "$BOOTSTRAP" == "") ]]; then
#  echo "Installing bootstrap file..."
#  wget $BOOTSTRAPURL && unzip $BOOTSTRAPARCHIVE -d $USERHOME/.fantasygold/ && rm $BOOTSTRAPARCHIVE
#fi

# Create fantasygold.conf
touch $USERHOME/.fantasygold/fantasygold.conf
cat > $USERHOME/.fantasygold/fantasygold.conf << EOL
rpcuser=${RPCUSER}
rpcpassword=${RPCPASSWORD}
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=256
externalip=${IP}
bind=${IP}:57814
addnode=45.33.49.18:57810
addnode=45.33.115.240:57810
addnode=45.79.203.106:57810
addnode=45.79.151.214:57810
addnode=176.58.126.105:57810
addnode=139.162.190.155:57810
EOL
chmod 0600 $USERHOME/.fantasygold/fantasygold.conf
chown -R $USER:$USER $USERHOME/.fantasygold

sleep 1

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
sudo systemctl start fantasygoldd.service

#clear

#clear
#echo "Syncing with the FantasyGold blockchain. Please wait for this process to finish."

until su -c "fantasygold-cli 2>/dev/null | grep 'successfully started' > /dev/null" $USER; do
  for (( i=0; i<${#CHARS}; i++ )); do
    sleep 5
    #echo -en "${CHARS:$i:1}" "\r"
    clear
    echo "Service Started. The FantasyGold blockchain is syncing. 
    When Current = Script should auto finish here."
    echo "
    Current Block: "
    su -c "curl https://fantasygold.network/api/getblockcount" $USER
    echo "
    Synced Blocks: "
    su -c "fantasygold-cli getblockcount" $USER
  done
done



sleep 1
su -c "/usr/local/bin/fantasygold-cli start" $USER
sleep 1
clear
su -c "/usr/local/bin/fantasygold-cli getblockcount" $USER
sleep 5

echo "" && echo "$(<$USERHOME/.fantasygold/fantasygold.conf)"

echo "" && echo "FantasyGold Core setup completed." && echo ""

