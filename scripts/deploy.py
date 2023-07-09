from brownie import FundMe, network, config, MockV3Aggregator
from scripts.helpful_scripts import get_account, deploy_mocks, local_blockchain_env


def main():
    return deploy_fund_me()


def deploy_fund_me():
    my_account = get_account()
    # ini kalo mau deploy live network, seperti metamask
    if network.show_active() not in local_blockchain_env:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_priceFeed"
        ]
    # ini kalo misale fake network alias ganache cli
    else:
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address
        print(f"Mocks deployed!")
    # ini manggil class FundMe
    # ini pake goerli
    fund_me = FundMe.deploy(
        price_feed_address,
        {
            "from": my_account,
        },
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    print(f"Contract deployed to {fund_me.address}")
    return fund_me
