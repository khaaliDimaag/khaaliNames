// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Dictionary} from "./Dictionary.sol";

/// @title ColorDictionary
/// @notice On-chain dictionary of color names for khaaliNamesV1
contract ColorDictionary is Dictionary {
    bytes32 public constant NAME = keccak256("khaaliNamesV1_ColorDictionaryV1");
    constructor(address data) Dictionary(data, 50) {}
}
