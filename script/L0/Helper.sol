// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

contract Helper {
    // ***** MAINNET *****
    address public BASE_LZ_ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c;
    address public GLMR_LZ_ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c;

    address public BASE_SEND_LIB = 0xB5320B0B3a13cC860893E2Bd79FCd7e13484Dda2;
    address public GLMR_SEND_LIB = 0xeac136456d078bB76f59DCcb2d5E008b31AfE1cF;

    address public BASE_RECEIVE_LIB = 0xc70AB6f32772f59fBfc23889Caf4Ba3376C84bAf;
    address public GLMR_RECEIVE_LIB = 0x2F4C6eeA955e95e6d65E08620D980C0e0e92211F;

    uint32 public BASE_EID = 30184;
    uint32 public GLMR_EID = 30126;

    address public BASE_DVN1 = 0x554833698Ae0FB22ECC90B01222903fD62CA4B47; // Canary
    address public BASE_DVN2 = 0xa7b5189bcA84Cd304D8553977c7C614329750d99; // Horizen
    address public BASE_DVN3 = 0x9e059a54699a285714207b43B055483E78FAac25; // LayerZeroLabs

    address public GLMR_DVN1 = 0x33E5fcC13D7439cC62d54c41AA966197145b3Cd7; // Canary
    address public GLMR_DVN2 = 0x34730f2570E6cff8B1C91FaaBF37D0DD917c4367; // Horizen
    address public GLMR_DVN3 = 0x8B9b67b22ab2ed6Ee324C2fd43734dBd2dDDD045; // LayerZeroLabs

    address public BASE_EXECUTOR = 0x2CCA08ae69E0C44b18a57Ab2A87644234dAebaE4;
    address public GLMR_EXECUTOR = 0xEC0906949f88f72bF9206E84764163e24a56a499;

    address public GLMR_WGLMR = 0xAcc15dC74880C9944775448304B263D191c6077F;
    address public GLMR_WETH = 0xFFffFFfF86829AFE1521ad2296719Df3acE8DEd7; // (Celo native bridge)
    address public GLMR_WBTC = 0xfFffFFFf1B4Bb1ac5749F73D866FfC91a3432c47;
    address public GLMR_USDT = 0xFFFFFFfFea09FB06d082fd1275CD48b191cbCD1d;
    address public GLMR_USDC = 0xFFfffffF7D2B0B761Af01Ca8e25242976ac0aD7D;

    address public BASE_USDT = 0xfde4C96c8593536E31F229EA8f37b2ADa2699bb2;
    address public BASE_WETH = 0x4200000000000000000000000000000000000006;
    address public BASE_WBTC = 0x0555E30da8f98308EdB960aa94C0Db47230d2B9c;
    // *******************

    // *******************
    address public usdt_usd = 0x4eadC6ee74b7Ceb09A4ad90a33eA2915fbefcf76;
    address public usdc_usd = 0xD3C586Eec1C6C3eC41D276a23944dea080eDCf7f;
    address public eth_usd = 0x5b0cf2b36a65a6BB085D501B971e4c102B9Cd473;
    address public btc_usd = 0xCAc4d304032a46C8D0947396B7cBb07986826A36;
    address public glmr_usd = 0xB64e610082d3c5C34130b8229E13DaB96180a6DF;
}
