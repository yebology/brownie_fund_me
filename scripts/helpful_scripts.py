from brownie import network, config, accounts, MockV3Aggregator
from web3 import Web3

decimal = 8
starting_price = 2e8
# ini itu kek development OR ganache-local
local_blockchain_env = ["development", "ganache-local"]
forked_local_env = ["mainnet-fork", "mainnet-fork-dev"]

def get_account():
    if network.show_active() in local_blockchain_env or network.show_active() in forked_local_env :
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])

def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    print("Deploying Mocks...")
    if len(MockV3Aggregator) <= 0:
        # Web3.toWei() mau jadiin 2000 ether ke wei
        MockV3Aggregator.deploy(decimal, starting_price, {"from": get_account()})
