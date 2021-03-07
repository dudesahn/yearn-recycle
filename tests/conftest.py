import pytest
from brownie import *


@pytest.fixture(scope='function')
def recycle(Recycle, accounts):
    return Recycle.deploy({'from': accounts[0]})


@pytest.fixture(scope='module')
def uniswap(interface):
    return interface.UniswapV2Router02('0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D')


@pytest.fixture(scope='module')
def coins(interface):
    return [
        interface.ERC20('0x6B175474E89094C44Da98b954EedeAC495271d0F'),
        interface.ERC20('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'),
        interface.USDT('0xdAC17F958D2ee523a2206206994597C13D831ec7'),
        interface.ERC20('0x4Fabb145d64652a948d72533023f6E7A623C7C53'),
        interface.ERC20('0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B'),
    ]


@pytest.fixture(scope='module')
def ybusd(interface):
    return interface.ERC20('0x2994529C0652D127b7842094103715ec5299bBed')
