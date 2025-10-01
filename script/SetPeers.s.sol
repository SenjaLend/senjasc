// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console2 as console} from "forge-std/Script.sol";
import {Helper} from "./L0/Helper.sol";
import {OFTUSDTadapter} from "../src/layerzero/OFTUSDTadapter.sol";
import {OFTNativeAdapter} from "../src/layerzero/OFTNativeAdapter.sol";

/// @notice This script only sets LayerZero peers for existing deployed OApps/OFT adapters.
/// Usage examples:
/// forge script script/SetPeers.s.sol:SetPeers --rpc-url $MOONBEAM_MAINNET --broadcast --private-key $PRIVATE_KEY \
///   --sig "run(address,address,address,address,address,address)" \
///   $OAPP_USDT $OAPP_WGLMR $OAPP_WGLMR_ORI $USDT_PEER_EID0 $USDT_PEER_EID1 $WGLMR_PEER
/// If you prefer env vars, you can wrap these into a small wrapper or pass addresses directly as args.
contract SetPeers is Script, Helper {
    uint32 public eid0; // BASE
    uint32 public eid1; // GLMR

    function run(
        address oappUSDT,
        address oappWGLMR,
        address oappWGLMR_ORI,
        address usdtPeerEid0,
        address usdtPeerEid1,
        address wglmrPeer
    ) external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        // Determine destination EIDs we want to peer with
        eid0 = BASE_EID; // 30184
        eid1 = GLMR_EID; // 30126

        // Default peers to self if not provided
        if (usdtPeerEid0 == address(0)) usdtPeerEid0 = oappUSDT;
        if (usdtPeerEid1 == address(0)) usdtPeerEid1 = oappUSDT;
        if (wglmrPeer == address(0)) wglmrPeer = oappWGLMR;

        // Set peers for USDT OApp
        bytes32 usdtPeer0 = _toBytes32(usdtPeerEid0);
        bytes32 usdtPeer1 = _toBytes32(usdtPeerEid1);
        OFTUSDTadapter(oappUSDT).setPeer(eid0, usdtPeer0);
        OFTUSDTadapter(oappUSDT).setPeer(eid1, usdtPeer1);

        // Set peers for WGLMR OApp
        bytes32 wglmrPeerB = _toBytes32(wglmrPeer);
        OFTNativeAdapter(oappWGLMR).setPeer(eid0, wglmrPeerB);
        OFTNativeAdapter(oappWGLMR).setPeer(eid1, wglmrPeerB);

        // Optionally set for the original WGLMR adapter if provided
        if (oappWGLMR_ORI != address(0)) {
            OFTNativeAdapter(oappWGLMR_ORI).setPeer(eid0, _toBytes32(oappWGLMR_ORI));
            OFTNativeAdapter(oappWGLMR_ORI).setPeer(eid1, _toBytes32(oappWGLMR_ORI));
        }

        console.log("// Peers set");
        console.log("address public OAPP_USDT = %s;", oappUSDT);
        console.log("address public OAPP_WGLMR = %s;", oappWGLMR);
        if (oappWGLMR_ORI != address(0)) {
            console.log("address public OAPP_WGLMR_ORI = %s;", oappWGLMR_ORI);
        }

        vm.stopBroadcast();
    }

    function _toBytes32(address a) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(a)));
    }
}


