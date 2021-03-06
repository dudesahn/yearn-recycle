# @version 0.2.4
from vyper.interfaces import ERC20

# Banteg's live contract can be found here: https://etherscan.io/address/0x5F07257145fDd889c6E318F99828E68A449A5c7A#code

interface USDT:
    def transferFrom(_from: address, _to: address, _value: uint256): nonpayable
    def approve(_spender: address, _value: uint256): nonpayable

interface crvIBdeposit:
    def add_liquidity(uamounts: uint256[3], min_mint_amount: uint256, true): nonpayable

interface yVault:
    def deposit(amount: uint256): nonpayable

event Recycled:
    user: indexed(address)
    sent_dai: uint256
    sent_usdc: uint256
    sent_usdt: uint256
    received_yvcrvIB: uint256


ibdeposit: constant(address) = 0x2dded6Da1BF5DBdF597C45fcFaa3194e53EcfeAF
crvIB: constant(address) = 0x5282a4eF67D9C33135340fB3289cc1711c13638C
yvcrvIB: constant(address) = add_here_when_deployed

dai: constant(address) = 0x6B175474E89094C44Da98b954EedeAC495271d0F
usdc: constant(address) = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
usdt: constant(address) = 0xdAC17F958D2ee523a2206206994597C13D831ec7


@external
def __init__():
    ERC20(dai).approve(ibdeposit, MAX_UINT256)
    ERC20(usdc).approve(ibdeposit, MAX_UINT256)
    USDT(usdt).approve(ibdeposit, MAX_UINT256)
    ERC20(crvIB).approve(yvcrvIB, MAX_UINT256)


@internal
def recycle_exact_amounts(sender: address, _dai: uint256, _usdc: uint256, _usdt: uint256):
    if _dai > 0:
        ERC20(dai).transferFrom(sender, self, _dai)
    if _usdc > 0:
        ERC20(usdc).transferFrom(sender, self, _usdc)
    if _usdt > 0:
        USDT(usdt).transferFrom(sender, self, _usdt)

    deposit_amounts: uint256[3] = [_dai, _usdc, _usdt]
    if _dai + _usdc + _usdt > 0:
        crvIBdeposit(ibdeposit).add_liquidity(deposit_amounts, 0, true)

    crvIB_balance: uint256 = ERC20(crvIB).balanceOf(self)       
    if crvIB_balance > 0:
        yVault(yvcrvIB).deposit(crvIB_balance)

    _yvcrvIB: uint256 = ERC20(yvcrvIB).balanceOf(self)
    ERC20(yvcrvIB).transfer(sender, _yvcrvIB)

    assert ERC20(yvcrvIB).balanceOf(self) == 0, "leftover yvcrvIB balance"

    log Recycled(sender, _dai, _usdc, _usdt, _yvcrvIB)


@external
def recycle():
    _dai: uint256 = min(ERC20(dai).balanceOf(msg.sender), ERC20(dai).allowance(msg.sender, self))
    _usdc: uint256 = min(ERC20(usdc).balanceOf(msg.sender), ERC20(usdc).allowance(msg.sender, self))
    _usdt: uint256 = min(ERC20(usdt).balanceOf(msg.sender), ERC20(usdt).allowance(msg.sender, self))

    self.recycle_exact_amounts(msg.sender, _dai, _usdc, _usdt)


@external
def recycle_exact(_dai: uint256, _usdc: uint256, _usdt: uint256):
    self.recycle_exact_amounts(msg.sender, _dai, _usdc, _usdt)
