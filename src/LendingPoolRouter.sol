// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract LendingPoolRouter {
    address public lendingPool;
    address public factory;
    address public collateralToken;
    address public borrowToken;
    uint256 public ltv;
    uint256 public lastAccrued;
    constructor(address _lendingPool, address _factory, address _collateralToken, address _borrowToken, uint256 _ltv) {
        lendingPool = _lendingPool;
        factory = _factory;
        collateralToken = _collateralToken;
        borrowToken = _borrowToken;
        ltv = _ltv;
        lastAccrued = block.timestamp;
    }
}
