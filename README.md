# Senja — Cross-Chain Lending & Borrowing on Moonbeam

**Senja** is a permissionless **cross-chain lending and borrowing protocol** built on **Moonbeam**, a Polkadot parachain, and powered by **LayerZero interoperability**. Users deposit collateral on Moonbeam and can borrow **synthetic tokens** on other LayerZero-enabled chains seamlessly, unlocking flexible cross-chain DeFi opportunities without manual bridging.

---

## Links

Web: https://senja-land.vercel.app/

Farcaster: https://farcaster.xyz/miniapps/loZN-y-IJM1t/senja

GitHub Repo: https://github.com/SenjaLend

X (Twitter): https://x.com/SenjaLabs

Docs: https://senja-token2049.gitbook.io/senja-token2049-docs

Presentation Deck: https://docsend.com/view/8wkcibrikbv23ggz

Demo Video: https://youtu.be/WQkibVbjAsk

---

## Features

- **Cross-Chain Borrowing:** Deposit collateral on Moonbeam and borrow synthetic tokens on other chains instantly.
- **Isolated Pools:** Each asset and market risk is contained to ensure safer lending and allow onboarding of new assets.
- **Dynamic Risk Management:** Decentralized oracles (API3) provide real-time pricing for efficient liquidation and optimized borrowing limits.
- **Multi-Asset Support:** Supports ETH, Stablecoins, and other collateral types, with plans for additional assets across LayerZero-supported chains.
- **Seamless UX:** No need to manually bridge assets, LayerZero handles cross-chain messaging.

---

## How It Works

1. **Deposit Collateral:** Lock assets such as ETH or Stablecoins on Moonbeam vaults (ERC-4626).
2. **Borrow Synthetic Tokens:** Mint synthetic tokens based on your collateral and send them to other chains via LayerZero.
3. **Use Across Chains:** Borrowed tokens are instantly available on the target chain for DeFi usage.
4. **Repay & Unlock Collateral:** Repay borrowed tokens and reclaim collateral on Moonbeam.

---

## Demo Video

Check out the [Senja Demo Video](https://youtu.be/WQkibVbjAsk) for a walkthrough of cross-chain borrowing using synthetic tokens.

**Script Example:**
> “This is the demo video of Senja, a permissionless cross-chain lending protocol built on Moonbeam, a Polkadot parachain. With Senja, when you deposit collateral on Moonbeam, you can borrow synthetic tokens on other chains through LayerZero interoperability. This unlocks seamless cross-chain borrowing without the need for manual bridging. Thanks for watching.”

---

## Contract Addresses (Moonbeam Mainnet)

**Core Contracts**  

FACTORY_PROXY = 0x46638aD472507482B7D5ba45124E93D16bc97eCE
GLMR_LZ_ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c
GLMR_SEND_LIB = 0xeac136456d078bB76f59DCcb2d5E008b31AfE1cF
GLMR_RECEIVE_LIB = 0x2F4C6eeA955e95e6d65E08620D980C0e0e92211F
GLMR_DVN1 = 0x33E5fcC13D7439cC62d54c41AA966197145b3Cd7 (Canary)
GLMR_DVN2 = 0x34730f2570E6cff8B1C91FaaBF37D0DD917c4367 (Horizen)
GLMR_DVN3 = 0x8B9b67b22ab2ed6Ee324C2fd43734dBd2dDDD045 (LayerZeroLabs)
GLMR_EXECUTOR = 0xEC0906949f88f72bF9206E84764163e24a56a499

**Token Contracts**  

GLMR_WGLMR = 0xAcc15dC74880C9944775448304B263D191c6077F
GLMR_WETH = 0xFFffFFfF86829AFE1521ad2296719Df3acE8DEd7
GLMR_WBTC = 0xfFffFFFf1B4Bb1ac5749F73D866FfC91a3432c47
GLMR_USDT = 0xFFFFFFfFea09FB06d082fd1275CD48b191cbCD1d
GLMR_USDC = 0xFFfffffF7D2B0B761Af01Ca8e25242976ac0aD7D

**Oracles (API3)**  

usdt_usd = 0x4eadC6ee74b7Ceb09A4ad90a33eA2915fbefcf76
usdc_usd = 0xD3C586Eec1C6C3eC41D276a23944dea080eDCf7f
eth_usd = 0x5b0cf2b36a65a6BB085D501B971e4c102B9Cd473
btc_usd = 0xCAc4d304032a46C8D0947396B7cBb07986826A36
glmr_usd = 0xB64e610082d3c5C34130b8229E13DaB96180a6DF

---

## Tech Stack

- **Smart Contracts:** Solidity (ERC-4626 vaults, synthetic token minting)
- **Cross-Chain Messaging:** LayerZero endpoints
- **Origin Chain:** Moonbeam (Polkadot parachain)
- **Oracles:** API3 (price feeds)
- **Frontend:** Next.js + WalletConnect

---

## Roadmap

- **Hackathon MVP:** Borrow on Moonbeam → cross-chain via LayerZero
- **Q4 2025:** Expand to more LayerZero-enabled chains (Arbitrum, Optimism, etc.)
- **Q1 2026:** Launch Collateral Swap (Trade-as-Collateral)
- **Q2 2026:** Multi-asset support (ETH, BTC, other parachain-native assets)

---
