// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Dictionary} from "./Dictionary.sol";

/// @title AnimalDictionary
/// @notice On-chain dictionary of animal names for khaaliNamesV1
contract AnimalDictionary is Dictionary {
    bytes32 public constant NAME = keccak256("khaaliNamesV1_AnimalDictionaryV1");
    constructor(address data) Dictionary(data, 350) {}
}
