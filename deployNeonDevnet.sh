#!/bin/zsh

# Run anvil.sh in another shell before running this

# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script script/DeployNeonDevnet.s.sol:Deploy --slow --legacy --rpc-url "https://devnet.neonevm.org" --gas-limit 80000000 --block-gas-limit 80000000 --sender $SENDER --private-key $PRIVATE_KEY --broadcast -vvvv
