// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IWNative} from "./interfaces/IWNative.sol";
import {ISwapRouter} from "./interfaces/ISwapRouter.sol";

/**
 * @title Protocol
 * @dev Protocol contract for managing protocol fees and withdrawals
 * @notice This contract handles protocol-level operations including fee collection and withdrawals
 * @author Senja Team
 * @custom:version 1.0.0
 */
contract Protocol is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;


    address public constant SWAP_ROUTER = 0xA324880f884036E3d21a09B90269E1aC57c7EC8a;
    address public wNative = 0x19Aac5f612f524B754CA7e7c41cbFa2E981A4432;

    // Buyback configuration
    uint256 public constant PROTOCOL_SHARE = 95; // 95% for protocol (locked)
    uint256 public constant OWNER_SHARE = 5; // 5% for owner
    uint256 public constant PERCENTAGE_DIVISOR = 100;

    // State variables for buyback tracking
    mapping(address => uint256) public protocolLockedBalance; // Token => locked amount for protocol
    mapping(address => uint256) public ownerAvailableBalance; // Token => available amount for owner

    // ============ Errors ============

    /**
     * @dev Error thrown when there are insufficient tokens for withdrawal
     * @param token Address of the token with insufficient balance
     * @param amount Amount that was attempted to withdraw
     */
    error InsufficientBalance(address token, uint256 amount);

    /**
     * @dev Error thrown when swap fails
     * @param tokenIn Address of the input token
     * @param tokenOut Address of the output token
     * @param amountIn Amount of input tokens
     */
    error SwapFailed(address tokenIn, address tokenOut, uint256 amountIn);

    /**
     * @dev Error thrown when insufficient output amount is received
     * @param expectedMinimum Expected minimum output amount
     * @param actualOutput Actual output amount received
     */
    error InsufficientOutputAmount(uint256 expectedMinimum, uint256 actualOutput);

    /**
     * @dev Error thrown when invalid token address is provided
     */
    error InvalidTokenAddress();

    /**
     * @dev Error thrown when amount is zero or invalid
     */
    error InvalidAmount();

    /**
     * @dev Error thrown when deadline has passed
     */
    error DeadlinePassed();

    error CannotSwapWNativeForWNative();

    event BuybackExecuted(
        address indexed tokenIn,
        uint256 totalAmountIn,
        uint256 protocolAmount,
        uint256 ownerAmount,
        uint256 received
    );

    /**
     * @dev Constructor for the Protocol contract
     * @notice Initializes the protocol contract with the deployer as owner
     */
    constructor() Ownable(msg.sender) {}

    receive() external payable {
        if (msg.value > 0) {
            IWNative(wNative).deposit{value: msg.value}();
        }
    }
    fallback() external {
        revert("Fallback not allowed");
    }

    function executeBuyback(address tokenIn, uint256 amountIn, uint256 amountOutMinimum, uint24 fee, uint256 deadline)
        external
        nonReentrant
        returns (uint256 totalReceived)
    {
        return _executeBuyback(tokenIn, amountIn, amountOutMinimum, fee, deadline);
    }

    function _executeBuyback(address tokenIn, uint256 amountIn, uint256 amountOutMinimum, uint24 fee, uint256 deadline)
        internal
        returns (uint256 totalReceived)
    {
        // Validate inputs
        if (tokenIn == address(0)) revert InvalidTokenAddress();
        if (amountIn == 0) revert InvalidAmount();
        if (deadline <= block.timestamp) revert DeadlinePassed();
        if (tokenIn == wNative) revert CannotSwapWNativeForWNative();

        // Check if protocol has sufficient balance
        uint256 protocolBalance = IERC20(tokenIn).balanceOf(address(this));
        if (protocolBalance < amountIn) {
            revert InsufficientBalance(tokenIn, amountIn);
        }

        // Calculate shares
        uint256 protocolAmount = (amountIn * PROTOCOL_SHARE) / PERCENTAGE_DIVISOR;
        uint256 ownerAmount = amountIn - protocolAmount; // Remaining amount for owner

        IERC20(tokenIn).approve(SWAP_ROUTER, amountIn);

        // Prepare swap parameters for protocol share
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: wNative,
            fee: fee,
            recipient: address(this), // Send to protocol
            amountIn: protocolAmount,
            amountOutMinimum: (amountOutMinimum * PROTOCOL_SHARE) / PERCENTAGE_DIVISOR,
            sqrtPriceLimitX96: 0 // No price limit
        });

        // Execute swap for protocol share
        uint256 protocolReceived;
        try ISwapRouter(SWAP_ROUTER).exactInputSingle(params) returns (uint256 _amountOut) {
            protocolReceived = _amountOut;
        } catch {
            revert SwapFailed(tokenIn, wNative, protocolAmount);
        }

        // Update protocol locked balance
        protocolLockedBalance[wNative] += protocolReceived;

        // If there's an owner amount, execute swap for owner
        uint256 ownerReceived = 0;
        if (ownerAmount > 0) {
            // Prepare swap parameters for owner share
            params.amountIn = ownerAmount;
            params.recipient = owner();
            params.amountOutMinimum = (amountOutMinimum * OWNER_SHARE) / PERCENTAGE_DIVISOR;

            try ISwapRouter(SWAP_ROUTER).exactInputSingle(params) returns (uint256 _amountOut) {
                ownerReceived = _amountOut;
                ownerAvailableBalance[wNative] += ownerReceived;
            } catch {
                revert SwapFailed(tokenIn, wNative, ownerAmount);
            }
        }

        totalReceived = protocolReceived + ownerReceived;

        // Emit buyback event
        emit BuybackExecuted(tokenIn, amountIn, protocolAmount, ownerAmount, totalReceived);
    }

    function executeBuybackSimple(address tokenIn, uint256 amountIn, uint256 amountOutMinimum, uint24 fee)
        external
        onlyOwner
        returns (uint256 totalReceived)
    {
        return _executeBuyback(tokenIn, amountIn, amountOutMinimum, fee, block.timestamp + 3600);
    }

    function withdraw(address token, uint256 amount, bool unwrapToNative) public nonReentrant onlyOwner {
        if (token == wNative) {
            if (IERC20(wNative).balanceOf(address(this)) < amount) {
                revert InsufficientBalance(token, amount);
            }

            if (unwrapToNative) {
                IWNative(wNative).withdraw(amount);
                (bool sent,) = msg.sender.call{value: amount}("");
                require(sent, "Failed to send native token");
            } else {
                IERC20(wNative).safeTransfer(msg.sender, amount);
            }
        } else {
            if (IERC20(token).balanceOf(address(this)) < amount) {
                revert InsufficientBalance(token, amount);
            }
            IERC20(token).safeTransfer(msg.sender, amount);
        }
    }

    function withdraw(address token, uint256 amount) public nonReentrant onlyOwner {
        withdraw(token, amount, false);
    }

    function withdrawOwnerBalance(address token, uint256 amount, bool unwrapToNative) public nonReentrant onlyOwner {
        if (amount > ownerAvailableBalance[token]) {
            revert InsufficientBalance(token, amount);
        }

        ownerAvailableBalance[token] -= amount;

        if (token == wNative) {
            if (unwrapToNative) {
                IWNative(wNative).withdraw(amount);
                (bool sent,) = msg.sender.call{value: amount}("");
                require(sent, "Failed to send native token");
            } else {
                IERC20(wNative).safeTransfer(msg.sender, amount);
            }
        } else {
            // Handle ERC20 token withdrawal
            IERC20(token).safeTransfer(msg.sender, amount);
        }
    }

    function withdrawOwnerBalance(address token, uint256 amount) public onlyOwner {
        withdrawOwnerBalance(token, amount, false);
    }

    /**
     * @dev Gets the total protocol locked balance for a token
     * @param token Address of the token
     * @return The locked balance for the protocol
     */
    function getProtocolLockedBalance(address token) public view returns (uint256) {
        return protocolLockedBalance[token];
    }

    /**
     * @dev Gets the owner's available balance for a token
     * @param token Address of the token
     * @return The available balance for the owner
     */
    function getOwnerAvailableBalance(address token) public view returns (uint256) {
        return ownerAvailableBalance[token];
    }

    /**
     * @dev Gets the total protocol balance (locked + available) for a token
     * @param token Address of the token
     * @return The total balance held by the protocol
     */
    function getTotalProtocolBalance(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }
}
