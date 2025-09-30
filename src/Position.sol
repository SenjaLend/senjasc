// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Position is ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public owner;
    address public lpAddress;

    constructor(address _lpAddress, address _user) {
        lpAddress = _lpAddress;
        owner = _user;
    }

    receive() external payable {}

    fallback() external payable {}
}
