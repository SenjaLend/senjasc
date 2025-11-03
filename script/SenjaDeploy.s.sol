// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console2 as console} from "forge-std/Script.sol";
import {Helper} from "./L0/Helper.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {SetConfigParam} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import {ExecutorConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";
import {EnforcedOptionParam} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

import {OFTUSDTadapter} from "../src/layerzero/OFTUSDTadapter.sol";
import {OFTNativeAdapter} from "../src/layerzero/OFTNativeAdapter.sol";
import {ElevatedMinterBurner} from "../src/layerzero/ElevatedMinterBurner.sol";
import {MyOApp} from "../src/layerzero/MyOApp.sol";

import {Oracle} from "../src/Oracle.sol";

import {LendingPoolFactory} from "../src/LendingPoolFactory.sol";
import {IFactory} from "../src/interfaces/IFactory.sol";
import {LendingPoolDeployer} from "../src/LendingPoolDeployer.sol";
import {LendingPoolRouterDeployer} from "../src/LendingPoolRouterDeployer.sol";
import {Protocol} from "../src/Protocol.sol";
import {IsHealthy} from "../src/IsHealthy.sol";
import {Liquidator} from "../src/Liquidator.sol";
import {PositionDeployer} from "../src/PositionDeployer.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {USDT2049} from "../src/dstToken/USDT2049.sol";
import {USDC2049} from "../src/dstToken/USDC2049.sol";
import {MOCKUSDT} from "../src/mocks/mockusdt.sol";
import {MOCKWGLMR} from "../src/mocks/mockwglmr.sol";

contract SenjaDeploy is Script, Helper {
    using OptionsBuilder for bytes;

    address public owner;
    address public endpoint;
    address public sendLib;
    address public receiveLib;
    uint32 public srcEid;
    uint32 public gracePeriod;
    address public dvn1;
    address public dvn2;
    address public executor;
    uint32 public eid0;
    uint32 public eid1;
    uint32 constant EXECUTOR_CONFIG_TYPE = 1;
    uint32 constant ULN_CONFIG_TYPE = 2;

    // Adapters / OApps
    address public oapp;
    address public oapp2;
    address public oapp3;
    address public glmr_oftusdt_adapter;
    address public glmr_oftusdc_adapter;
    address public glmr_oftglmr_adapter;
    address public gmlr_oftglmr_ori_adapter;

    // Oracles (API3/Chainlink adapters)
    address public usdt_usd_adapter;
    address public glmr_usd_adapter;
    address public usdc_usd_adapter;
    address public eth_usd_adapter;
    address public btc_usd_adapter;

    // Factory / infra
    IsHealthy public isHealthy;
    Liquidator public liquidator;
    LendingPoolDeployer public lendingPoolDeployer;
    LendingPoolRouterDeployer public lendingPoolRouterDeployer;
    Protocol public protocol;
    PositionDeployer public positionDeployer;
    LendingPoolFactory public lendingPoolFactory;
    ERC1967Proxy public proxy;

    function run() external {
        vm.createSelectFork(vm.rpcUrl("moonbeam_mainnet"));
        // vm.createSelectFork(vm.rpcUrl("base_mainnet"));
        uint256 pk = vm.envUint("PRIVATE_KEY");
        owner = vm.addr(pk);
        vm.startBroadcast(pk);

        _configureChain();
        // _deployOFT();
        // _setLibraries();
        // _setSendConfig();
        // _setReceiveConfig();
        // _setPeers();
        // _setEnforcedOptions();

        _deployOracleAdapter();
        // _deployFactory();
        _setOFTAddress();

        // _logAddresses();

        vm.stopBroadcast();
    }

    function _configureChain() internal {
        if (block.chainid == 8453) {
            eid0 = BASE_EID;
            eid1 = GLMR_EID;
            endpoint = BASE_LZ_ENDPOINT;
            sendLib = BASE_SEND_LIB;
            receiveLib = BASE_RECEIVE_LIB;
            srcEid = BASE_EID;
            gracePeriod = uint32(0);
            dvn1 = BASE_DVN1;
            dvn2 = BASE_DVN2;
            executor = BASE_EXECUTOR;
        } else {
            eid1 = BASE_EID;
            eid0 = GLMR_EID;
            endpoint = GLMR_LZ_ENDPOINT;
            sendLib = GLMR_SEND_LIB;
            receiveLib = GLMR_RECEIVE_LIB;
            srcEid = GLMR_EID;
            gracePeriod = uint32(0);
            dvn1 = GLMR_DVN1;
            dvn2 = GLMR_DVN2;
            executor = GLMR_EXECUTOR;
        }
    }

    function _deployOFT() internal {
        if (block.chainid == 8453) {
            USDT2049 usdt = new USDT2049();
            USDC2049 usdc = new USDC2049();
            console.log("address public BASE_USDT2049 = %s;", address(usdt));
            console.log("address public BASE_USDC2049 = %s;", address(usdc));

            ElevatedMinterBurner elevated = new ElevatedMinterBurner(address(usdt), owner);
            OFTUSDTadapter oftusdt = new OFTUSDTadapter(address(usdt), address(elevated), endpoint, owner);
            glmr_oftusdt_adapter = address(oftusdt);
            oapp = address(oftusdt);
            console.log("address public BASE_OFT_USDT_ADAPTER = %s;", address(oftusdt));

            elevated = new ElevatedMinterBurner(address(usdc), owner);
            OFTUSDTadapter oftusdc = new OFTUSDTadapter(address(usdc), address(elevated), endpoint, owner);
            glmr_oftusdc_adapter = address(oftusdc);
            oapp2 = address(oftusdc);
            console.log("address public BASE_OFT_USDC_ADAPTER = %s;", address(oftusdc));
        } else {
            MOCKUSDT usdt = new MOCKUSDT();
            console.log("address public GLMR_MOCKUSDT = %s;", address(usdt));

            ElevatedMinterBurner elevated = new ElevatedMinterBurner(address(usdt), owner);
            OFTUSDTadapter oftusdt = new OFTUSDTadapter(address(usdt), address(elevated), endpoint, owner);
            glmr_oftusdt_adapter = address(oftusdt);
            oapp = address(oftusdt);
            console.log("address public GLMR_OFT_USDT_ADAPTER = %s;", address(oftusdt));

            MOCKWGLMR wglmr = new MOCKWGLMR();
            console.log("address public GLMR_MOCKWGLMR = %s;", address(wglmr));

            // elevated = new ElevatedMinterBurner(GLMR_WGLMR, owner);
            // OFTNativeAdapter oftnative = new OFTNativeAdapter(GLMR_WGLMR, address(elevated), endpoint, owner);
            // glmr_oftglmr_adapter = address(oftnative);
            // oapp2 = address(oftnative);

            // elevated = new ElevatedMinterBurner(GLMR_WGLMR, owner);
            // oftnative = new OFTNativeAdapter(GLMR_WGLMR, address(elevated), endpoint, owner);
            // gmlr_oftglmr_ori_adapter = address(oftnative);
            // oapp3 = address(oftnative);

            // ElevatedMinterBurner elevated = new ElevatedMinterBurner(GLMR_USDT, owner);
            // OFTUSDTadapter oftusdt = new OFTUSDTadapter(GLMR_USDT, address(elevated), endpoint, owner);
            // glmr_oftusdt_adapter = address(oftusdt);
            // oapp = address(oftusdt);

            // elevated = new ElevatedMinterBurner(GLMR_WGLMR, owner);
            // OFTNativeAdapter oftnative = new OFTNativeAdapter(GLMR_WGLMR, address(elevated), endpoint, owner);
            // glmr_oftglmr_adapter = address(oftnative);
            // oapp2 = address(oftnative);

            // elevated = new ElevatedMinterBurner(GLMR_WGLMR, owner);
            // oftnative = new OFTNativeAdapter(GLMR_WGLMR, address(elevated), endpoint, owner);
            // gmlr_oftglmr_ori_adapter = address(oftnative);
            // oapp3 = address(oftnative);
        }
    }

    function _setLibraries() internal {
        ILayerZeroEndpointV2(endpoint).setSendLibrary(BASE_OFT_USDT_ADAPTER, eid0, sendLib);
        ILayerZeroEndpointV2(endpoint).setReceiveLibrary(BASE_OFT_USDT_ADAPTER, srcEid, receiveLib, gracePeriod);

        // ILayerZeroEndpointV2(endpoint).setSendLibrary(GLMR_OFT_USDT_ADAPTER, eid0, sendLib);
        // ILayerZeroEndpointV2(endpoint).setReceiveLibrary(GLMR_OFT_USDT_ADAPTER, srcEid, receiveLib, gracePeriod);

        // ILayerZeroEndpointV2(endpoint).setSendLibrary(oapp, eid0, sendLib);
        // ILayerZeroEndpointV2(endpoint).setSendLibrary(oapp, eid1, sendLib);
        // ILayerZeroEndpointV2(endpoint).setReceiveLibrary(oapp, srcEid, receiveLib, gracePeriod);

        // ILayerZeroEndpointV2(endpoint).setSendLibrary(oapp2, eid0, sendLib);
        // ILayerZeroEndpointV2(endpoint).setSendLibrary(oapp2, eid1, sendLib);
        // ILayerZeroEndpointV2(endpoint).setReceiveLibrary(oapp2, srcEid, receiveLib, gracePeriod);
        // if (block.chainid != 8453) {
        //     ILayerZeroEndpointV2(endpoint).setSendLibrary(oapp3, eid0, sendLib);
        //     ILayerZeroEndpointV2(endpoint).setSendLibrary(oapp3, eid1, sendLib);
        //     ILayerZeroEndpointV2(endpoint).setReceiveLibrary(oapp3, srcEid, receiveLib, gracePeriod);
        // }
    }

    function _setSendConfig() internal {
        UlnConfig memory uln = UlnConfig({
            confirmations: 15,
            requiredDVNCount: 2,
            optionalDVNCount: type(uint8).max,
            optionalDVNThreshold: 0,
            requiredDVNs: _toDynamicArray([dvn1, dvn2]),
            optionalDVNs: new address[](0)
        });
        ExecutorConfig memory exec = ExecutorConfig({maxMessageSize: 10000, executor: executor});
        bytes memory encodedUln = abi.encode(uln);
        bytes memory encodedExec = abi.encode(exec);
        SetConfigParam[] memory params = new SetConfigParam[](4);
        params[0] = SetConfigParam(eid0, EXECUTOR_CONFIG_TYPE, encodedExec);
        params[1] = SetConfigParam(eid0, ULN_CONFIG_TYPE, encodedUln);
        params[2] = SetConfigParam(eid1, EXECUTOR_CONFIG_TYPE, encodedExec);
        params[3] = SetConfigParam(eid1, ULN_CONFIG_TYPE, encodedUln);
        ILayerZeroEndpointV2(endpoint).setConfig(BASE_OFT_USDT_ADAPTER, sendLib, params);
        // ILayerZeroEndpointV2(endpoint).setConfig(GLMR_OFT_USDT_ADAPTER, sendLib, params);
        // ILayerZeroEndpointV2(endpoint).setConfig(oapp, sendLib, params);
        // ILayerZeroEndpointV2(endpoint).setConfig(oapp2, sendLib, params);
        // if (block.chainid != 8453) {
        //     ILayerZeroEndpointV2(endpoint).setConfig(oapp3, sendLib, params);
        // }
    }

    function _setReceiveConfig() internal {
        uint32 RECEIVE_CONFIG_TYPE = 2;
        UlnConfig memory uln = UlnConfig({
            confirmations: 15,
            requiredDVNCount: 2,
            optionalDVNCount: type(uint8).max,
            optionalDVNThreshold: 0,
            requiredDVNs: _toDynamicArray([dvn1, dvn2]),
            optionalDVNs: new address[](0)
        });
        bytes memory encodedUln = abi.encode(uln);
        SetConfigParam[] memory params = new SetConfigParam[](2);
        params[0] = SetConfigParam(eid0, RECEIVE_CONFIG_TYPE, encodedUln);
        params[1] = SetConfigParam(eid1, RECEIVE_CONFIG_TYPE, encodedUln);

        ILayerZeroEndpointV2(endpoint).setConfig(BASE_OFT_USDT_ADAPTER, receiveLib, params);
        // ILayerZeroEndpointV2(endpoint).setConfig(GLMR_OFT_USDT_ADAPTER, receiveLib, params);
        // ILayerZeroEndpointV2(endpoint).setConfig(oapp, receiveLib, params);
        // ILayerZeroEndpointV2(endpoint).setConfig(oapp2, receiveLib, params);
        // if (block.chainid != 8453) {
        //     ILayerZeroEndpointV2(endpoint).setConfig(oapp3, receiveLib, params);
        // }
    }

    function _setPeers() internal {
        bytes32 oftPeer = bytes32(uint256(uint160(BASE_OFT_USDT_ADAPTER)));
        bytes32 oftPeerX = bytes32(uint256(uint160(GLMR_OFT_USDT_ADAPTER)));
        OFTUSDTadapter(BASE_OFT_USDT_ADAPTER).setPeer(eid1, oftPeerX);
        OFTUSDTadapter(BASE_OFT_USDT_ADAPTER).setPeer(eid0, oftPeer);
        // OFTUSDTadapter(GLMR_OFT_USDT_ADAPTER).setPeer(eid1, oftPeer);
        // OFTUSDTadapter(GLMR_OFT_USDT_ADAPTER).setPeer(eid0, oftPeerX);

        // bytes32 oftPeer = bytes32(uint256(uint160(0xf89eAB4a9A4C87d4a40E1E4E325c3CdA985b0b26)));
        // bytes32 oftPeerX = bytes32(uint256(uint160(0xAE1b8d3B428d6A8F62df2f623081EAC8734168fe)));
        // OFTUSDTadapter(0xAE1b8d3B428d6A8F62df2f623081EAC8734168fe).setPeer(eid1, oftPeer);
        // OFTUSDTadapter(0xAE1b8d3B428d6A8F62df2f623081EAC8734168fe).setPeer(eid0, oftPeerX);

        // bytes32 oftPeer2 = bytes32(uint256(uint160(address(oapp2))));
        // OFTNativeAdapter(oapp2).setPeer(eid0, oftPeer2);
        // OFTNativeAdapter(oapp2).setPeer(eid1, oftPeer2);
        // if (block.chainid != 8453) {
        //     bytes32 oftPeer3 = bytes32(uint256(uint160(address(oapp3))));
        //     OFTNativeAdapter(oapp3).setPeer(eid0, oftPeer3);
        //     OFTNativeAdapter(oapp3).setPeer(eid1, oftPeer3);
        // }
    }

    function _setEnforcedOptions() internal {
        uint16 SEND = 1;
        bytes memory options1 = OptionsBuilder.newOptions().addExecutorLzReceiveOption(80000, 0);
        bytes memory options2 = OptionsBuilder.newOptions().addExecutorLzReceiveOption(100000, 0);

        EnforcedOptionParam[] memory enforcedOptions = new EnforcedOptionParam[](2);
        enforcedOptions[0] = EnforcedOptionParam({eid: eid0, msgType: SEND, options: options1});
        enforcedOptions[1] = EnforcedOptionParam({eid: eid1, msgType: SEND, options: options2});

        MyOApp(GLMR_OFT_USDT_ADAPTER).setEnforcedOptions(enforcedOptions);
        // MyOApp(oapp).setEnforcedOptions(enforcedOptions);
        // MyOApp(oapp2).setEnforcedOptions(enforcedOptions);
        // if (block.chainid != 8453) {
        //     MyOApp(oapp3).setEnforcedOptions(enforcedOptions);
        // }
    }

    function _deployOracleAdapter() internal {
        Oracle oracle = new Oracle(usdt_usd);
        usdt_usd_adapter = address(oracle);
        oracle = new Oracle(glmr_usd);
        glmr_usd_adapter = address(oracle);
        oracle = new Oracle(usdc_usd);
        usdc_usd_adapter = address(oracle);
        oracle = new Oracle(eth_usd);
        eth_usd_adapter = address(oracle);
        oracle = new Oracle(btc_usd);
        btc_usd_adapter = address(oracle);
    }

    function _deployFactory() internal {
        liquidator = new Liquidator();
        isHealthy = new IsHealthy(address(liquidator));
        lendingPoolDeployer = new LendingPoolDeployer();
        lendingPoolRouterDeployer = new LendingPoolRouterDeployer();
        protocol = new Protocol();
        positionDeployer = new PositionDeployer();

        lendingPoolFactory = new LendingPoolFactory();
        bytes memory data = abi.encodeWithSelector(
            lendingPoolFactory.initialize.selector,
            address(isHealthy),
            address(lendingPoolRouterDeployer),
            address(lendingPoolDeployer),
            address(protocol),
            address(positionDeployer)
        );
        proxy = new ERC1967Proxy(address(lendingPoolFactory), data);

        lendingPoolDeployer.setFactory(address(proxy));
        lendingPoolRouterDeployer.setFactory(address(proxy));

        IFactory(address(proxy)).setWNative(GLMR_WGLMR);
        // IFactory(address(proxy)).addTokenDataStream(GLMR_USDT, usdt_usd_adapter);
        // IFactory(address(proxy)).addTokenDataStream(GLMR_WGLMR, glmr_usd_adapter);
        // IFactory(address(proxy)).addTokenDataStream(GLMR_WGLMR, glmr_usd_adapter);
        // IFactory(address(proxy)).addTokenDataStream(address(1), glmr_usd_adapter); // GLMR native alias
        IFactory(address(proxy)).addTokenDataStream(GLMR_MOCKUSDT, usdt_usd_adapter);
        IFactory(address(proxy)).addTokenDataStream(GLMR_MOCKWGLMR, glmr_usd_adapter);
    }

    function _setOFTAddress() internal {
        IFactory(0x46638aD472507482B7D5ba45124E93D16bc97eCE).setOftAddress(GLMR_MOCKUSDT, GLMR_OFT_USDT_ADAPTER);
        IFactory(0x46638aD472507482B7D5ba45124E93D16bc97eCE).addTokenDataStream(GLMR_MOCKUSDT, usdt_usd_adapter);
        IFactory(0x46638aD472507482B7D5ba45124E93D16bc97eCE).addTokenDataStream(GLMR_MOCKWGLMR, glmr_usd_adapter);

        IFactory(0x46638aD472507482B7D5ba45124E93D16bc97eCE).oftAddress(GLMR_MOCKUSDT);

        // IFactory(address(proxy)).setOftAddress(GLMR_WGLMR, glmr_oftglmr_adapter);
        // IFactory(address(proxy)).setOftAddress(GLMR_USDT, glmr_oftusdt_adapter);
        // IFactory(address(proxy)).setOftAddress(address(1), glmr_oftglmr_adapter); // GLMR native alias
    }

    function _toDynamicArray(address[2] memory fixedArray) internal pure returns (address[] memory) {
        address[] memory dynamicArray = new address[](2);
        dynamicArray[0] = fixedArray[0];
        dynamicArray[1] = fixedArray[1];
        return dynamicArray;
    }

    function _logAddresses() internal view {
        console.log("address public FACTORY_PROXY = %s;", address(proxy));

        // LayerZero core
        console.log("address public LZ_ENDPOINT = %s;", endpoint);
        console.log("address public LZ_SEND_LIB = %s;", sendLib);
        console.log("address public LZ_RECEIVE_LIB = %s;", receiveLib);
        console.log("address public LZ_DVN1 = %s;", dvn1);
        console.log("address public LZ_DVN2 = %s;", dvn2);
        console.log("address public LZ_EXECUTOR = %s;", executor);

        // OFT adapters / OApps
        console.log("address public OFT_USDT_ADAPTER = %s;", glmr_oftusdt_adapter);
        console.log("address public OFT_WGLMR_ADAPTER = %s;", glmr_oftglmr_adapter);
        console.log("address public OFT_WGLMR_ORI_ADAPTER = %s;", gmlr_oftglmr_ori_adapter);
        console.log("address public OAPP_USDT = %s;", oapp);
        console.log("address public OAPP_WGLMR = %s;", oapp2);
        console.log("address public OAPP_WGLMR_ORI = %s;", oapp3);

        // Oracles
        console.log("address public ORACLE_USDT_USD = %s;", usdt_usd_adapter);
        console.log("address public ORACLE_GLMR_USD = %s;", glmr_usd_adapter);
        console.log("address public ORACLE_USDC_USD = %s;", usdc_usd_adapter);
        console.log("address public ORACLE_ETH_USD = %s;", eth_usd_adapter);
        console.log("address public ORACLE_BTC_USD = %s;", btc_usd_adapter);
    }
}

// RUN
// forge script SenjaDeploy --broadcast -vvv
// forge script SenjaDeploy -vvv
