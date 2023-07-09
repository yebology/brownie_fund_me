from brownie import FundMe
from scripts.helpful_scripts import get_account


def main():
    fund()
    withdraw()


def fund():
    fund_me = FundMe[-1]
    my_account = get_account()
    entrance_fee = fund_me.getEntranceFee()
    print(f"the current entry fee is {entrance_fee}")
    print("funding..")
    fund_me.fund({
        "from" : my_account,
        "value" : entrance_fee
    })


def withdraw() : 
    fund_me = FundMe[-1]
    my_account = get_account()
    fund_me.withdraw({
        "from" : my_account
    })