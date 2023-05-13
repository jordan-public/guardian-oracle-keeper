#!/bin/zsh

# Run anvil.sh in another shell before running this

# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script script/DeployLineaTestnet.s.sol:Deploy --slow --rpc-url "https://rpc.goerli.linea.build" --sender $SENDER --private-key $PRIVATE_KEY --broadcast -vvvv
