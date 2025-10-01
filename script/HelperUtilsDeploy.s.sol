// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {HelperUtils} from "../src/HelperUtils.sol";

contract HelperUtilsDeploy is Script {
    address public FACTORY_PROXY = 0x46638aD472507482B7D5ba45124E93D16bc97eCE;
    HelperUtils public helperUtils;

    function run() public {
        vm.createSelectFork(vm.rpcUrl("moonbeam_mainnet"));
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);
        helperUtils = new HelperUtils(FACTORY_PROXY);
        console.log("HelperUtils deployed at", address(helperUtils));
        vm.stopBroadcast();
    }
}

// forge script HelperUtilsDeploy -vvv --broadcast
