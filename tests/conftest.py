import pytest
from brownie import *


@pytest.fixture
def recycle(IronRecycle, accounts):
    return IronRecycle.deploy({'from': accounts[0]})


@pytest.fixture
def uniswap(interface):
    return interface.UniswapV2Router02('0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D')


@pytest.fixture
def coins(interface):
    return [
        interface.ERC20('0x6B175474E89094C44Da98b954EedeAC495271d0F'),
        interface.ERC20('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'),
        interface.USDT('0xdAC17F958D2ee523a2206206994597C13D831ec7'),
    ]


@pytest.fixture
def yvcrvIB(interface):
    return interface.ERC20('0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c') # put deployed vault contract here when launched

@pytest.fixture
def buy_coins_on_uniswap(uniswap, coins, user):
    weth = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'
    for coin in coins:
        uniswap.swapExactETHForTokens(0, [weth, coin], user, 10 ** 20, {'from': user, 'value': '1 ether'})
        assert coin.balanceOf(user) > 0, 'coin not bought'
        print('bought', coin.symbol(), coin.balanceOf(user) / 10 ** coin.decimals())

@pytest.fixture
def set_allowances(coins, user, spender, unlimited=True):
    for coin in coins:
        allowance = 2 ** 256 - 1 if unlimited else 10 ** coin.decimals()
        coin.approve(spender, allowance, {'from': user})
        assert coin.allowance(user, spender) == allowance, 'invalid allowance'
        print('allowance', coin.symbol(), 'is set to', allowance)