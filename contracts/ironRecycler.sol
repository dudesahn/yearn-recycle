// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

// These are the core Yearn libraries
import {BaseStrategy} from "@yearnvaults/contracts/BaseStrategy.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";

import "./interfaces/curve.sol";
import "./interfaces/yearn.sol";
import {IUniswapV2Router02} from "./interfaces/uniswap.sol";

interface IYVault is IERC20 {
    function deposit(uint256 amount, address recipient) external;
    function withdraw() external;
}

contract ironRecycler {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant gauge =
        address(0xF5194c3325202F456c95c1Cf0cA36f8475C1949F); // Curve Iron Bank Gauge contract, v2 is tokenized, held by Yearn's voter
    ICurveStrategyProxy public curveProxy =
        ICurveStrategyProxy(
            address(0x9a165622a744C20E3B2CB443AeD98110a33a231b)
        ); // Yearn's Updated v3 StrategyProxy

    ICurveFi public pool =
        ICurveFi(address(0x2dded6Da1BF5DBdF597C45fcFaa3194e53EcfeAF)); // Curve Iron Bank Pool
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
        
        uint256 daiBalance = dai.balanceOf(address(msg.sender));
        uint256 usdcBalance = usdc.balanceOf(address(msg.sender));
        uint256 usdtBalance = usdt.balanceOf(address(msg.sender));

        pool.add_liquidity([daiBalance, usdcBalance, usdcBalance], 0, true);

        uint256 curvePoolTokens = want.balanceOf(address(this));

        yVault.deposit(curvePoolTokens, msg.sender);


        uint256 _toInvest = want.balanceOf(address(this));
        want.safeTransfer(address(curveProxy), _toInvest);
        curveProxy.deposit(gauge, address(want));
}
    function zapDai()
        external {
        
        uint256 daiBalance = dai.balanceOf(address(msg.sender));
        require(daiBalance != 0, "0 DAI");

        pool.add_liquidity([daiBalance, 0, 0], 0, true);

        uint256 curvePoolTokens = want.balanceOf(address(this));

        yVault.deposit(curvePoolTokens, msg.sender);


        uint256 _toInvest = want.balanceOf(address(this));
        want.safeTransfer(address(curveProxy), _toInvest);
        curveProxy.deposit(gauge, address(want));
}

    function zapUsdc()
        external {
        
        uint256 usdcBalance = usdc.balanceOf(address(msg.sender));
        require(usdcBalance != 0, "0 USDC");

        pool.add_liquidity([0, usdcBalance, 0], 0, true);

        uint256 curvePoolTokens = want.balanceOf(address(this));

        yVault.deposit(curvePoolTokens, msg.sender);


        uint256 _toInvest = want.balanceOf(address(this));
        want.safeTransfer(address(curveProxy), _toInvest);
        curveProxy.deposit(gauge, address(want));
}

    function zapUsdt()
        external {
        
        uint256 usdtBalance = usdt.balanceOf(address(msg.sender));
        require(usdtBalance != 0, "0 USDT");

        pool.add_liquidity([usdtBalance, 0, 0], 0, true);

        uint256 curvePoolTokens = want.balanceOf(address(this));

        yVault.deposit(curvePoolTokens, msg.sender);


        uint256 _toInvest = want.balanceOf(address(this));
        want.safeTransfer(address(curveProxy), _toInvest);
        curveProxy.deposit(gauge, address(want));
}

}