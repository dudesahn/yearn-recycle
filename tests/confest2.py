import pytest
from brownie import config
from brownie import Contract

# Define relevant tokens and contracts in this section

@pytest.fixture
def token():
    # this should be the address of the ERC-20 used by the strategy/vault. In this case, Curve's Iron Bank Pool token
    token_address = "0x5282a4eF67D9C33135340fB3289cc1711c13638C" 
    yield Contract(token_address)

@pytest.fixture
def dai():
    yield Contract("0x6B175474E89094C44Da98b954EedeAC495271d0F")

@pytest.fixture
def usdc():
    yield Contract("0x6B175474E89094C44Da98b954EedeAC495271d0F")

@pytest.fixture
def usdt():
    yield Contract("0x6B175474E89094C44Da98b954EedeAC495271d0F")
    
@pytest.fixture
def voter():
    # this is yearn's veCRV voter, where all gauge tokens are held (for v2 curve gauges that are tokenized)
    yield Contract("0xF147b8125d2ef93FB6965Db97D6746952a133934")    
    
@pytest.fixture
def gaugeIB():
    # this is the gauge contract for the Iron Bank Curve Pool, in Curve v2 these are tokenized.
    yield Contract("0xF5194c3325202F456c95c1Cf0cA36f8475C1949F")   

# Define any accounts in this section

@pytest.fixture
def reserve(accounts):
    # this is the gauge contract, holds >99% of pool tokens. use this to seed our whale, as well for calling functions above as gauge
    yield accounts.at("0xF5194c3325202F456c95c1Cf0cA36f8475C1949F", force=True)         

@pytest.fixture
def whale(accounts, token,reserve):
    # Totally in it for the tech
    # Has 10% of tokens (was in the ICO)
    a = accounts[0]
    bal = token.totalSupply() // 10
    token.transfer(a, bal, {"from":reserve})
    yield a


# Define the amount of tokens that our whale will be using
    
@pytest.fixture
def amount(token, whale):
    # set the amount that our whale friend is going to throw around; pocket change
    amount = token.balanceOf(whale) * 0.1
    yield amount

# Set definitions for vault and strategy

@pytest.fixture
def strategyProxy(interface):
    # This is Yearn's StrategyProxy contract, overlord of the Curve world
    yield interface.ICurveStrategyProxy("0x9a165622a744C20E3B2CB443AeD98110a33a231b")

@pytest.fixture
def vault(pm, gov, rewards, guardian, management, token):
    Vault = pm(config["dependencies"][0]).Vault
    vault = guardian.deploy(Vault)
    vault.initialize(token, gov, rewards, "", "", guardian)
    vault.setDepositLimit(2 ** 256 - 1, {"from": gov})
    vault.setManagement(management, {"from": gov})
    yield vault

@pytest.fixture
def strategy(strategist, keeper, vault, StrategyCurveIBVoterProxy, gov, strategyProxy):
    strategy = strategist.deploy(StrategyCurveIBVoterProxy, vault)
    strategy.setKeeper(keeper)
    strategyProxy.approveStrategy(strategy.gauge(), strategy, {"from": gov})
    vault.addStrategy(strategy, 10_000, 0,  2 ** 256 -1, 1_000, {"from": gov})
    yield strategy