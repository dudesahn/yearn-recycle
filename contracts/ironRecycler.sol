// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

// These are the core Yearn libraries
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/curve.sol";


interface IYVault is IERC20 {
    function deposit(uint256 amount, address recipient) external;
}

contract ironRecycler {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    ICurveFi public pool = ICurveFi(address(0x2dded6Da1BF5DBdF597C45fcFaa3194e53EcfeAF)); // Curve Iron Bank Pool
    IYVault public yVault = IYVault(address()); // add address here when deployed

    IERC20 public want = IERC20(address(0x5282a4eF67D9C33135340fB3289cc1711c13638C)); // Iron Bank curve LP Token
    IERC20 public dai = IERC20(address(0x6B175474E89094C44Da98b954EedeAC495271d0F));
    IERC20 public usdc = IERC20(address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));
    IERC20 public usdt = IERC20(address(0xdAC17F958D2ee523a2206206994597C13D831ec7));

    constructor() public Ownable() {
        want.safeApprove(address(yVault), uint256(-1));
        dai.safeApprove(address(pool), uint256(-1));
        usdc.safeApprove(address(pool), uint256(-1));
        usdt.safeApprove(address(pool), uint256(-1));
    }

    function name() external view override returns (string memory) {
        // Add your own name here, suggestion e.g. "StrategyCreamYFI"
        return "Iron Recycler";
    }

    function ironRecycle()
        external {
        
        uint256 daiBalance = dai.balanceOf(msg.sender);
        uint256 usdcBalance = usdc.balanceOf(msg.sender);
        uint256 usdtBalance = usdt.balanceOf(msg.sender);

        dai.transferFrom(msg.sender, address(this), daiBalance);
        usdc.transferFrom(msg.sender, address(this), usdcBalance);
        usdt.transferFrom(msg.sender, address(this), usdtBalance);

        uint256 daiBalanceBegin = dai.balanceOf(address(this));
        require(daiBalanceBegin >= daiBalance, "NOT ALL DAI RECEIVED");
        
        uint256 usdcBalanceBegin = usdc.balanceOf(address(this));
        require(usdcBalanceBegin >= usdcBalance, "NOT ALL USDC RECEIVED");
        
        uint256 usdtBalanceBegin = usdt.balanceOf(address(this));
        require(usdtBalanceBegin >= usdtBalance, "NOT ALL USDT RECEIVED");

        pool.add_liquidity([daiBalance, usdcBalance, usdcBalance], 0, true);

        uint256 curvePoolTokens = want.balanceOf(address(this));

        yVault.deposit(curvePoolTokens, msg.sender);
}

    function zapDai()
        external {
        
        uint256 daiBalance = dai.balanceOf(msg.sender);
        require(daiBalance != 0, "0 DAI");

        pool.add_liquidity([daiBalance, 0, 0], 0, true);

        uint256 curvePoolTokens = want.balanceOf(address(this));

        yVault.deposit(curvePoolTokens, msg.sender);

}

    function zapUsdc()
        external {
        
        uint256 usdcBalance = usdc.balanceOf(msg.sender);
        require(usdcBalance != 0, "0 USDC");

        pool.add_liquidity([0, usdcBalance, 0], 0, true);

        uint256 curvePoolTokens = want.balanceOf(address(this));

        yVault.deposit(curvePoolTokens, msg.sender);

}

    function zapUsdt()
        external {
        
        uint256 usdtBalance = usdt.balanceOf(msg.sender);
        require(usdtBalance != 0, "0 USDT");

        pool.add_liquidity([usdtBalance, 0, 0], 0, true);

        uint256 curvePoolTokens = want.balanceOf(address(this));

        yVault.deposit(curvePoolTokens, msg.sender);

}

}