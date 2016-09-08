OnChain Gem
===========

The onchain gem gives you access to the very basic blockchain data you need to run web wallets and other Bitcoin applications.

The onchain gem actually uses 2 API's in the background (blockchain.info and blockr.io) if one goes down the Gem will makes calls to the other. The data from the API's is changed so that they look identical to the caller.

Usage
=====

We currently support :bitcoin and :testnet3 for the Bitcoin and Testnet networks respectively. 

### Get Address Balance

```
2.3.0 :001 > OnChain::BlockChain.get_balance('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :testnet3)
 => 0.216 
```

### Get Unspent Outs

```
2.3.0 :002 > OnChain::BlockChain.get_unspent_outs('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :testnet3)
 => [["c3d2189220a68c89a41a5c01e19a81c607c8cb62c5292fcf8dfe26bb89c5c972", 1, "76a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88ac", 5700000], ["f6b192e6cd0cda81822c4a59506a3ac4113d43530d7d0d16d7ee663a8d3d23da", 1, "76a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88ac", 5800000], ["525d2f71e299fc0aa903ebd196b8c2c94d9be64880aa228d057fc6f2697901ac", 0, "76a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88ac", 10000000], ["93c8e1d06de7a95cacfaa8b9ba2e541d344523761f6818587ccf391493808712", 0, "76a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88ac", 100000]] 
```

### Get the history of an address.

```
2.3.0 :003 > OnChain::BlockChain.address_history('2MwpZJ67K9s8Q3bdaTziW6u1qWffjXHM7ca', :testnet3)
 
=> [{:time=>1473081774, :addr=>{"2MwpZJ67K9s8Q3bdaTziW6u1qWffjXHM7ca"=>"2MwpZJ67K9s8Q3bdaTziW6u1qWffjXHM7ca"}, :outs=>{"2N1dPLcuQVVyPfLHqkAm7gLBSv8ruiQ3SDN"=>"2N1dPLcuQVVyPfLHqkAm7gLBSv8ruiQ3SDN"}, :hash=>"bbcf34ada24a9b0276ea04733c3551b09aff6606d256cb415abf80bf32c9fb85", :total=>0.001, :recv=>"N"}, {:time=>1473080572, :addr=>{"2MwpZJ67K9s8Q3bdaTziW6u1qWffjXHM7ca"=>"2MwpZJ67K9s8Q3bdaTziW6u1qWffjXHM7ca"}, :outs=>{"2N1dPLcuQVVyPfLHqkAm7gLBSv8ruiQ3SDN"=>"2N1dPLcuQVVyPfLHqkAm7gLBSv8ruiQ3SDN"}, :hash=>"f26de6b67398e53142944e0a74579478a36ba0c8dbea1b611df54358c9eb194e", :total=>0.01, :recv=>"N"}, {:time=>1472812912, :addr=>{"2N4Jv96riyC7AYuyWDNLijnLhm7goHy41Wr"=>"2N4Jv96riyC7AYuyWDNLijnLhm7goHy41Wr"}, :outs=>{"2MwpZJ67K9s8Q3bdaTziW6u1qWffjXHM7ca"=>"2MwpZJ67K9s8Q3bdaTziW6u1qWffjXHM7ca", "2N25HtxzRBwB6EcNorWP9agFxLYvndeUiBn"=>"2N25HtxzRBwB6EcNorWP9agFxLYvndeUiBn"}, :hash=>"50f84562bf9abcec14cd4c93728822b65698f52f3584f5408bb023be23d44f30", :total=>0.09, :recv=>"Y"}] 
```

### Send a transaction to the network.

The transaction should be signed.

```
OnChain::BlockChain.send_tx('0100000002d8c8df6a6fdd2addaf589a83d860f18b44872d13ee6ec35....', :testnet3)
```

### Get a transaction in hex format

```
2.3.0 :005 >   OnChain::BlockChain.get_transaction('23dc613b5548d3f3607274e2c0722fa4b562fe106c45fba8d28c1d697c63bc83', :bitcoin)
 => "0100000001362edbaa75ae597acbc568d10979b6add286d87fe68cea73d0e9cdf2b1c075db000000008b483045022100ca475aa528381232d2c0105a2223de87affc5df2504d32d622e1838161bafabc02205e21516406102674bc11b4e07b654d08bfd55692d3bde69b4116599ffc1fb5df0141048b5146a9175229b77fc92a48ca74b59c7aae30d413172815bce54311d1cba61abdcf2bdd7e32433e02f32aa3371ecf139e8892fadc3d507f18681d0395966282ffffffff02ebbcc200000000001976a914cd253e4b30b42704dd6c41364b1645674e176d4788ac801a0600000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac00000000" 
```