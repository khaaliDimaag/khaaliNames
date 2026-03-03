// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Dictionary} from "./Dictionary.sol";

/// @title AdjectiveDictionary
/// @notice On-chain dictionary of adjective names for khaaliNamesV1
contract AdjectiveDictionary is Dictionary {
    bytes32 public constant NAME = keccak256("khaaliNamesV1_AdjectiveDictionaryV1");
    constructor(address data) Dictionary(data, 1200) {}
}
