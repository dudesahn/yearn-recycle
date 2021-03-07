# @version 0.2.4
from vyper.interfaces import ERC20

interface USDT:
    def transferFrom(_from: address, _to: address, _value: uint256): nonpayable
    def approve(_spender: address, _value: uint256): nonpayable

interface yCurveDeposit:
    def add_liquidity(uamounts: uint256[4], min_mint_amount: uint256): nonpayable

interface yVault:
    def deposit(amount: uint256): nonpayable

event Recycled:
    user: indexed(address)
    sent_dai: uint256
    sent_usdc: uint256
    sent_usdt: uint256
    sent_busd: uint256
    sent_ybcrv: uint256
    received_ybusd: uint256


ydeposit: constant(address) = 0xb6c057591E073249F2D9D88Ba59a46CFC9B59EdB
ybcrv: constant(address) = 0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B
ybusd: constant(address) = 0x2994529C0652D127b7842094103715ec5299bBed

dai: constant(address) = 0x6B175474E89094C44Da98b954EedeAC495271d0F
usdc: constant(address) = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
usdt: constant(address) = 0xdAC17F958D2ee523a2206206994597C13D831ec7
busd: constant(address) = 0x4Fabb145d64652a948d72533023f6E7A623C7C53


@external
def __init__():
    ERC20(dai).approve(ydeposit, MAX_UINT256)
    ERC20(usdc).approve(ydeposit, MAX_UINT256)
    USDT(usdt).approve(ydeposit, MAX_UINT256)
    ERC20(busd).approve(ydeposit, MAX_UINT256)
    ERC20(ybcrv).approve(ybusd, MAX_UINT256)


@internal
def recycle_exact_amounts(sender: address, _dai: uint256, _usdc: uint256, _usdt: uint256, _busd: uint256, _ybcrv: uint256):
    if _dai > 0:
        ERC20(dai).transferFrom(sender, self, _dai)
    if _usdc > 0:
        ERC20(usdc).transferFrom(sender, self, _usdc)
    if _usdt > 0:
        USDT(usdt).transferFrom(sender, self, _usdt)
    if _busd > 0:
        ERC20(busd).transferFrom(sender, self, _busd)
    if _ybcrv > 0:
        ERC20(ybcrv).transferFrom(sender, self, _ybcrv)

    deposit_amounts: uint256[4] = [_dai, _usdc, _usdt, _busd]
    if _dai + _usdc + _usdt + _busd > 0:
        yCurveDeposit(ydeposit).add_liquidity(deposit_amounts, 0)

    ybcrv_balance: uint256 = ERC20(ybcrv).balanceOf(self)       
    if ybcrv_balance > 0:
        yVault(ybusd).deposit(ybcrv_balance)

    _ybusd: uint256 = ERC20(ybusd).balanceOf(self)
    ERC20(ybusd).transfer(sender, _ybusd)

    assert ERC20(ybusd).balanceOf(self) == 0, "leftover ybUSD balance"

    log Recycled(sender, _dai, _usdc, _usdt, _busd, _ybcrv, _ybusd)


@external
def recycle():
    _dai: uint256 = min(ERC20(dai).balanceOf(msg.sender), ERC20(dai).allowance(msg.sender, self))
    _usdc: uint256 = min(ERC20(usdc).balanceOf(msg.sender), ERC20(usdc).allowance(msg.sender, self))
    _usdt: uint256 = min(ERC20(usdt).balanceOf(msg.sender), ERC20(usdt).allowance(msg.sender, self))
    _busd: uint256 = min(ERC20(busd).balanceOf(msg.sender), ERC20(busd).allowance(msg.sender, self))
    _ybcrv: uint256 = min(ERC20(ybcrv).balanceOf(msg.sender), ERC20(ybcrv).allowance(msg.sender, self))

    self.recycle_exact_amounts(msg.sender, _dai, _usdc, _usdt, _busd, _ybcrv)


@external
def recycle_exact(_dai: uint256, _usdc: uint256, _usdt: uint256, _busd: uint256, _ybcrv: uint256):
    self.recycle_exact_amounts(msg.sender, _dai, _usdc, _usdt, _busd, _ybcrv)
