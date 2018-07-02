## FGC Integration Document (PHP)

  
Following these step to integrate FGC integration on website and your web application.

Step 1 :
	You need to include php-rpc-client  file on the top:

```
  <?php
	require_once 'jsonRPCClient.php';
	$ fgccoind = new jsonRPCClient('http://user:password@127.0.0.1:8332/');
echo "<pre>\n";
print_r($fgccoind ->getinfo());
echo "</pre>";
?>

```

Once you include library on top and make a connection via above code then you are able to fetch wallet info via getinfo() function.
Output should be like this : 

```
Array
(
    [version] => 1020400
    [protocolversion] => 70820
    [walletversion] => 61000
    [balance] => 50952.78294015
    [obfuscation_balance] => 0
    [blocks] => 52192
    [timeoffset] => 0
    [connections] => 125
    [proxy] => 
    [difficulty] => 16475.8888744
    [testnet] => 
    [keypoololdest] => 1528746568
    [keypoolsize] => 1001
    [paytxfee] => 0
    [relayfee] => 0.0001
    [staking status] => Staking Active
    [errors] => 
)
```

After successfully connection , you need to create deposit address per user basis:
Code like this : 
```
<?php
	require_once 'jsonRPCClient.php';
	$ fgccoind = new jsonRPCClient('http://user:password@127.0.0.1:57814/');
	$username = $user['user_name'];  // it is use for label, username become label of this address
	if(!isset($FGCAccount[$username])){
	$fgccoind->getnewaddress($username);
	}
?>
```


Output should be like this : 
```
FTBa8ojtFXKzm4VJ8XXXXKkGtpxKQEuQJ   =? this is deposit address for that user or label.
```

Great you have successfully created deposit address now move the withdrawal process. Let see the code for the withdrawal:

Suppose there is a user called “maxxjems” and its deposit address is : FTBa8ojtFXKzm4VJ8XXXXKkGtpxKQEuQJ and his desktop wallet is : FTBa8ojtFXKzm4VJ8rgthvkGtpxKQEuQJ


```
<?php
require_once 'jsonRPCClient.php';
$ fgccoind = new jsonRPCClient('http://user:password@127.0.0.1:8332/');
$depostAdd = ‘FTBa8ojtFXKzm4VJ8XXXXKkGtpxKQEuQJ’;
$desktopWalletAdd = ‘FTBa8ojtFXKzm4VJ8rgthvkGtpxKQEuQJ’;
$amt = 200;
$status = $fgccoind->sendfrom($depostAdd , $desktopWalletAdd , (float)$amt);
echo "<pre>\n";
print_r($status);
echo "</pre>";
?>
```

Output should be like this:

```

073b22738c7ee991f305c70968cbbd9130b3607e1e81843b07e5d12574f81f23
```

Our FGC RPC support following commands:

```

 	== Blockchain ==
getbestblockhash
getblock "hash" ( verbose )
getblockchaininfo
getblockcount
getblockhash index
getblockheader "hash" ( verbose )
getchaintips
getdifficulty
getmempoolinfo
getrawmempool ( verbose )
gettxout "txid" n ( includemempool )
gettxoutsetinfo
verifychain ( checklevel numblocks )

== Control ==
getinfo
help ( "command" )
stop

== Fantasygold ==
checkbudgets
createmasternodekey
getbudgetinfo ( "proposal" )
getbudgetprojection
getbudgetvotes "proposal-name"
getmasternodecount
getmasternodeoutputs
getmasternodescores ( blocks )
getmasternodestatus
getmasternodewinners ( blocks "filter" )
getnextsuperblock
getpoolinfo
listmasternodeconf ( "filter" )
listmasternodes ( "filter" )
masternode "command"...
masternodeconnect "address"
masternodecurrent
masternodedebug
mnbudget "command"... ( "passphrase" )
mnbudgetrawvote "masternode-tx-hash" masternode-tx-index "proposal-hash" yes|no time "vote-sig"
mnbudgetvote "local|many|alias" "votehash" "yes|no" ( "alias" )
mnfinalbudget "command"... ( "passphrase" )
mnsync "status|reset"
obfuscation <fantasygoldaddress> <amount>
preparebudget "proposal-name" "url" payment-count block-start "fantasygold-address" monthy-payment
spork <name> [<value>]
startmasternode "local|all|many|missing|disabled|alias" lockwallet ( "alias" )
submitbudget "proposal-name" "url" payment-count block-start "fantasygold-address" monthy-payment "fee-tx"

== Generating ==
getgenerate
gethashespersec
setgenerate generate ( genproclimit )

== Mining ==
getblocktemplate ( "jsonrequestobject" )
getmininginfo
getnetworkhashps ( blocks height )
prioritisetransaction <txid> <priority delta> <fee delta>
reservebalance ( reserve amount )
submitblock "hexdata" ( "jsonparametersobject" )

== Network ==
addnode "node" "add|remove|onetry"
getaddednodeinfo dns ( "node" )
getconnectioncount
getnettotals
getnetworkinfo
getpeerinfo
ping

== Rawtransactions ==
createrawtransaction [{"txid":"id","vout":n},...] {"address":amount,...}
decoderawtransaction "hexstring"
decodescript "hex"
getrawtransaction "txid" ( verbose )
sendrawtransaction "hexstring" ( allowhighfees )
signrawtransaction "hexstring" ( [{"txid":"id","vout":n,"scriptPubKey":"hex","redeemScript":"hex"},...] ["privatekey1",...] sighashtype )

== Util ==
createmultisig nrequired ["key",...]
estimatefee nblocks
estimatepriority nblocks
validateaddress "fantasygoldaddress"
verifymessage "fantasygoldaddress" "signature" "message"

== Wallet ==
addmultisigaddress nrequired ["key",...] ( "account" )
autocombinerewards true|false ( threshold )
backupwallet "destination"
bip38decrypt "fantasygoldaddress"
bip38encrypt "fantasygoldaddress"
dumpprivkey "fantasygoldaddress"
dumpwallet "filename"
encryptwallet "passphrase"
getaccount "fantasygoldaddress"
getaccountaddress "account"
getaddressesbyaccount "account"
getbalance ( "account" minconf includeWatchonly )
getnewaddress ( "account" )
getrawchangeaddress
getreceivedbyaccount "account" ( minconf )
getreceivedbyaddress "fantasygoldaddress" ( minconf )
getstakesplitthreshold
getstakingstatus
gettransaction "txid" ( includeWatchonly )
getunconfirmedbalance
getwalletinfo
importaddress "address" ( "label" rescan )
importprivkey "fantasygoldprivkey" ( "label" rescan )
importwallet "filename"
keypoolrefill ( newsize )
listaccounts ( minconf includeWatchonly)
listaddressgroupings
listlockunspent
listreceivedbyaccount ( minconf includeempty includeWatchonly)
listreceivedbyaddress ( minconf includeempty includeWatchonly)
listsinceblock ( "blockhash" target-confirmations includeWatchonly)
listtransactions ( "account" count from includeWatchonly)
listunspent ( minconf maxconf  ["address",...] )
lockunspent unlock [{"txid":"txid","vout":n},...]
move "fromaccount" "toaccount" amount ( minconf "comment" )
multisend <command>
sendfrom "fromaccount" "tofantasygoldaddress" amount ( minconf "comment" "comment-to" )
sendmany "fromaccount" {"address":amount,...} ( minconf "comment" )
sendtoaddress "fantasygoldaddress" amount ( "comment" "comment-to" )
sendtoaddressix "fantasygoldaddress" amount ( "comment" "comment-to" )
setaccount "fantasygoldaddress" "account"
setstakesplitthreshold value
settxfee amount
signmessage "fantasygoldaddress" "message"
```
