// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";


interface ICurveFi {

    function add_liquidity(
        // Link pool
        uint256[3] calldata amounts,
        uint256 min_mint_amount
    ) external payable;

}
