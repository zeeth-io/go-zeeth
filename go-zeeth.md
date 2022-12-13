# Go Zeeth
This repo implements Zeeth Blockchain Validator Node. The implementation is derived from Go implementation of Ethereum.

```
git clone https://github.com/zeeth-io/go-zeeth.git
make geth
```

## Features
## Governrnance protocol
A goveranance protocol for blockchain operatin

# Blockchain Operation

## Protocol

## Geneis 

First, you'll need to create the genesis state of your networks, which all nodes need to be aware of and agree upon. This consists of a small JSON file.

The genesis file includes three starting validator nodes started by Zeeth. This forms the initial blockchain.

The blockchain can be further expanded by node operators that can start new nodes and join the network.


Genesis file for Zeeth Devnet (chainId 859):  
-- TODO --

Genesis file for Zeeth Mainnet (chainId 427):  
-- TODO --

## Validator Node Initialization 
Every geth node with it prior to starting it up to ensure all blockchain parameters are correctly set (This is included for docker image):

```
geth init path/to/genesis.json
```

## Boot node for discovery
---- TODO: Move to bootstrap in production ---

you'll need to start a bootstrap node that others can use to find each other in your network and/or over the internet. The clean way is to configure and run a dedicated bootnode:

## Building docker image for Boot node
```
# Generate boot.key
bootnode --genkey=boot.key
# Run bootnode
bootnode --nodekey=boot.key
```

Docker
```
docker build -t gzeeth-bootnode -f ./Dockerfile.bootnode .
docker run -it --env extip=192.168.0.141 --env verbosity=5 -p 30301:30301/udp gzeeth-bootnode
```
## Building Docker image for Validator node

```
docker build --build-arg password=<password> --build-arg privatekey=<miner private key. without 0x prefix>    -t gzeeth .
```

## Running the node
Create a persistant volume storing chin data and run the docker image. If running all dockers on the same machine (for testing), assingn different rpc port in host mapping.

Example commands:
```
docker volume create --name zeeth1-data
docker run -it -d -v zeeth1-data:/root/.ethereum -p 8545:8545 --name zeeth1 gzeeth

```
Managing the validar node.

```
# Stop node
docker stop zeeth1

# Start node
docker start zeeth1

# Volume size
docker system df -v | grep zeeth1

# Backup
docker cp zeeth1:/root/.ethereum ~/tmp/
```

Run Geth console by attaching to a running node
```
docker exec -it gzeeth /bin/sh

# Attach to geth and run any admin command
geth attach

# Check if node is mining
eth.mining

# check current block number
eth.blockNumber
```
### Validator Node Admin commands
```
clique.status()
clique.getSigners()
```
### Fee propsal
```
eth.gasPrice
clique.proposeFee(2000000000)
```

## Adding Node to Zeeth Blockchain


## Removing a Node from Zeeth Blockchain



# Testnet Setup

## Creating a Genesis
Use puppeth to generate genesis file.
As a prerequisite, gather addresses of three validator nodes(from the participants/partners running validator nodes) and faucet/bank address. Test addresses are used below for this purpose.

```
cd go-zeeth
./build/bin/puppeth
# Please specify a network name to administer (no spaces, hyphens or capital letters please)
> zeethdev

What would you like to do? (default = stats)
 1. Show network stats
 2. Configure new genesis
 3. Track new remote server
 4. Deploy network components
> 2
What would you like to do? (default = create)
 1. Create new genesis from scratch
 2. Import already existing genesis
 > 1
 Which consensus engine to use? (default = clique)
 1. Ethash - proof-of-work
 2. Clique - proof-of-authority
 > 2
 How many seconds should blocks take? (default = 15)
 > 5
Which accounts are allowed to seal? (mandatory at least one)
> 0x789eeac8071ce0faae85a97cdd83f4677524d74d
> 0x0e32574b1ea5280168916aae8c8ab330d836e5c8
> 0x1f2192fce51f9bd96a37a4df09af4791ab0d0916
Which accounts should be pre-funded? (advisable at least one)
> 0xA80885886fb53F88FC8Ce3312478F884dEf998CD

Should the precompile-addresses (0x1 .. 0xff) be pre-funded with 1 wei? (advisable yes)
> yes

Specify your chain/network ID if you want an explicit one (default = random)
> 90009

What would you like to do? (default = stats)
 1. Show network stats
 2. Manage existing genesis
 3. Track new remote server
 4. Deploy network components
> 2
 1. Modify existing configurations
 2. Export genesis configurations
 3. Remove genesis configuration
> 2

Which folder to save the genesis spec into? (default = current)
  Will create zeethdev.json
>
#rename zeethdev.json as genesis.json
# Modify the genesis.json to change the funding of 0xA80885886fb53F88FC8Ce3312478F884dEf998CD to 0xdb33eec91221fba9000000 equl to 265M VID



## Run 3 Node Devnet

```
# sample bootnode env
export bootnodeId=ad64602a3bdaa584949760514e44ee08137256b4950026f96b2f2a9cba3ca33b3b2f1e648f023beb5ca1218926c3712e0083b4cd2706a4a5e44e8169f35a3034
export bootnodeIp=192.168.0.141

cp genesis_test/genesis_sealers_3.json ./genesis.json

# build and run bootnode
docker build -t gzeeth-bootnode -f ./Dockerfile.bootnode .
docker run -it --env extip=192.168.0.141 --env verbosity=5 -p 30301:30301/udp gzeeth-bootnode

# build and run node1
docker build --build-arg password=vcn123 --build-arg  privatekey=6208a98d1f31430fa51a37b89a0016b842d8570d7e3da0bac7ca5e11bc96b2f6  -t gzeeth-node1 .

docker volume create --name zeeth1-data

docker run -it -d -v zeeth1-data:/root/.ethereum -p 8545:8545 -p 30304:30304 --env address=0x789eeac8071ce0faae85a97cdd83f4677524d74d  \
--env bootnodeId=$bootnodeId \
--env bootnodeIp=$bootnodeIp --env p2port=30304 --name zeeth1 gzeeth-node1

# build and run node2
docker build --build-arg password=vcn123 --build-arg  privatekey=36d5f32dddc0097f3f895a0c4f42530a010c039bb003ff52c3f4b5984f8050ee  -t gzeeth-node2 .

docker volume create --name zeeth2-data

docker run -it -d -v zeeth2-data:/root/.ethereum -p 8546:8545 -p 30305:30305 --env address=0x0e32574b1ea5280168916aae8c8ab330d836e5c8 \
--env bootnodeId=$bootnodeId \
--env bootnodeIp=$bootnodeIp --env p2port=30305 --name zeeth2 gzeeth-node2

# build and run node3
docker build --build-arg password=vcn123 --build-arg  privatekey=78df575164c9e31dc27c0ff059a3714dec2a99c91b07e2bd814c4f0356dfce51  -t gzeeth-node3 .

docker volume create --name zeeth3-data

docker run -it -d -v zeeth3-data:/root/.ethereum -p 8547:8545 -p 30306:30306 --env address=0x1f2192fce51f9bd96a37a4df09af4791ab0d0916  \
--env bootnodeId=$bootnodeId \
--env bootnodeIp=$bootnodeIp --env p2port=30306 --name zeeth3 gzeeth-node3
```