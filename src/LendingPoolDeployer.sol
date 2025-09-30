// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LendingPool} from "./LendingPool.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract LendingPoolDeployer is Ownable {
    error OnlyFactoryCanCall();

    address public factory;

    constructor() Ownable(msg.sender) {
    }

    modifier onlyFactory() {
        _onlyFactory();
        _;
    }

    function _onlyFactory() internal view {
        if (msg.sender != factory) revert OnlyFactoryCanCall();
    }

    /**
     * @notice Deploys a new LendingPool contract with specified parameters
     * @param _router The address of the router contract
     * @return The address of the newly deployed LendingPool contract
     *
     * @dev This function creates a new LendingPool instance with the provided parameters.
     * Only the factory contract should call this function to ensure proper pool management.
     *
     * Requirements:
     * - _router must be a valid router contract address
     *
     * @custom:security This function should only be called by the factory contract
     */
    function deployLendingPool(address _router) public onlyFactory returns (address) {
        LendingPool lendingPool = new LendingPool(_router);
        return address(lendingPool);
    }

    function setFactory(address _factory) public onlyOwner {
        factory = _factory;
    }
}
