
## Follow this guide to install the FantasyGold CLI wallet and use FGC as a payment method or in game currency on websites and applications. 

It is recomended the FantasyGold CLI be installed on the same server as your app. 

Part 2 of this guide is to configure the RPC Clinet on your website or app.



## STEP 1 : Download a desktop FantasyGold wallet.

Later you will want to use this in a hot/warm or hot/cold wallet configuration.
  

## STEP 2 : VPS MasterNode Configuration
## System requirements

The VPS you plan to install your masternode on needs to have at least 1GB of RAM and 10GB of free disk space. We do not recommend using servers who do not meet those criteria, and your masternode will not be stable.

Most people are using Vultr Servers
Location: Any
Type: 64bit Ubuntu 17.10
Size: $5 per month
(give your server a name, ie FGC-MN-1)
Start the server.

## Installation & Setting up your Server

SSH (Putty on Windows, Terminal.app on macOS) to your VPS.
  (meaning connect to your server throught an old DOS like command window)

Windows users can download Putty here: 
```
  https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
```
Put your VPS server IP into Putty and connect.

login as root 
get your password from your vps config details.
(if using Putty you can paste by clicking right mouse button)
(**Please note:** It's normal that you don't see your password after typing or pasting it) 

Once logged in:
Run the following command:

```bash
bash <( curl https://raw.githubusercontent.com/FantasyGold/FGC-Install/master/install.sh )
```

When the script asks, confirm your VPS IP Address and paste the ip address of your application. (You can copy your key and paste into the VPS if connected with Putty by right clicking)

The installer will then present you with a few options.

**PLEASE NOTE**: Do not choose the advanced installation option unless you have experience with Linux and know what you are doing - if you do and something goes wrong, the FantasyGold team CANNOT help you, and you will have to restart the installation.

Options:
Install using Advanced = n
Confirm the IP Address of your VPS (it should already display and be correct, just hit enter to continue)
Paste the ip address where your remote app is located, hit enter.
Install Fail2ban? = y
Install UFW and configure ports? = y

Sit back, relax, some dependancies will now install and the Node will configure.
This can take 10 or 15 minutes depending.

After the basic installation is done, the wallet will sync. You will see the following message:

```
Syncing with the FantasyGold blockchain. Please wait for this process to finish.

```

Last copy the rpcuser and rpcpassword information for use in your application or website.

Now download and configure the RPC Clinet on your application.

## Refreshing Node

If your node is stuck on a block or behaving badly, you can refresh it.
Please note that this script must be run as root.

```
bash <( curl https://raw.githubusercontent.com/FantasyGold/FGC-Install/master/refresh_node.sh )
```

No other attention is required.

## Updating Node

To update your node please run this command and follow the instructions.
Please note that this script must be run as root.

```
bash <( curl https://raw.githubusercontent.com/FantasyGoldCoin/FGC-Install/master/update_node.sh )
```
