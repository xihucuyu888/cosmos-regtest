#!/bin/bash


export GOPATH=/root/go
export PATH=$PATH:$GOPATH/bin

COSMOS_PATH=/data1/validator
CHAIN_ID=testing
NUM=1
PW=11111111

cd $COSMOS_PATH
rm -rf node*
for((i=0;i<=$NUM;i++));
do
pm2 delete node$i
mkdir -p $COSMOS_PATH/node$i
mkdir -p $COSMOS_PATH/node$i/gentxs
done
pm2 delete cosmos-rest-server

# initialize node0
gaiad init --chain-id=$CHAIN_ID node0 --home=$COSMOS_PATH/node0

for((i=0;i<=$NUM;i++));
do
gaiad init --chain-id=$CHAIN_ID node$i --home=$COSMOS_PATH/node$i
rm -rf node$i/config/genesis.json
done

cp genesis.json node0/config/

for((i=0;i<=$NUM;i++));
do
gaiad add-genesis-account $(gaiacli keys show validator$i -a) 1000000000stake,1000000000validator${i}token --home=$COSMOS_PATH/node0
done


echo $PW | gaiad gentx --name validator0 --home=$COSMOS_PATH/node0 --output-document=$COSMOS_PATH/node0/gentxs/node0.json

gaiad collect-gentxs --home=$COSMOS_PATH/node0 --gentx-dir=$COSMOS_PATH/node0/gentxs

cp node0/config/genesis.json node1/config

pm2 start runnode0.sh --name=node0

sleep 5

rm -rf node1/config/config.toml
cp backup/config1.toml node1/config/config.toml


ID=`gaiacli status | jq -r ".node_info.id"`
SEEDS="$ID@127.0.0.1:26656"
VALACC=`gaiad tendermint show-validator --home=$COSMOS_PATH/node1`

sed -i "/seeds = ""/c seeds = \"$SEEDS\"" node1/config/config.toml

# node1
gaiacli tx staking create-validator \
  --amount=1000000stake \
  --pubkey=$VALACC \
  --moniker=node1 \
  --chain-id=testing \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="100000" \
  --gas=200000 \
  --gas-prices="0.025stake" \
  --from=cosmos1wpw2nrq850mwgrhteh3jwc2g7w9led2huhck90

sleep 5
pm2 start runnode1.sh --name=node1

sleep 5
pm2 start start-rest-server.sh --name=cosmos-rest-server
