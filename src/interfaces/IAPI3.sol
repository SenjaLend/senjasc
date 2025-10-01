// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAPI3 {
    function read() external view returns (int224 value, uint32 timestamp);
}
