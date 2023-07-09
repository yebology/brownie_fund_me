from scripts.helpful_scripts import get_account, local_blockchain_env
from scripts.deploy import deploy_fund_me
from brownie import network, accounts, exceptions
import pytest

def test_fund_withdraw() : 
    my_account = get_account()
    fund_me = deploy_fund_me()
    entrance_fee = fund_me.getEntranceFee()
    transaction1 = fund_me.fund({
        "from" : my_account,
        "value" : entrance_fee
    })
    transaction1.wait(1)
    assert fund_me.addressToValueFunded(my_account.address) == entrance_fee
    transaction2 = fund_me.withdraw({
        "from" : my_account
    })
    transaction2.wait(1)
    

def test_only_owner_can_withdraw() : 
    if network.show_active() not in local_blockchain_env : 
        # kalo networknya selain development atau ganache local, maka ke skip
        pytest.skip("only for local testing")
    fund_me = deploy_fund_me()
    unknown_user = accounts.add()
    with pytest.raises(exceptions.VirtualMachineError) :
        fund_me.withdraw({
        "from": unknown_user
    })
    