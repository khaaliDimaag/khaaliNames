// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IDictionary} from "./IDictionary.sol";

/// @title AdjectiveDictionary
/// @notice On-chain dictionary of adjectives for khaaliNames.
contract AdjectiveDictionary is IDictionary {
    string[] private _words;

    constructor() {
        _words.push("bold");
        _words.push("calm");
        _words.push("cool");
        _words.push("dark");
        _words.push("deep");
        _words.push("dry");
        _words.push("fair");
        _words.push("fast");
        _words.push("firm");
        _words.push("free");
        _words.push("glad");
        _words.push("hale");
        _words.push("keen");
        _words.push("kind");
        _words.push("loud");
        _words.push("meek");
        _words.push("mild");
        _words.push("neat");
        _words.push("new");
        _words.push("odd");
        _words.push("open");
        _words.push("pale");
        _words.push("pure");
        _words.push("rare");
        _words.push("raw");
        _words.push("rich");
        _words.push("ripe");
        _words.push("safe");
        _words.push("shy");
        _words.push("slim");
        _words.push("soft");
        _words.push("sly");
        _words.push("tall");
        _words.push("thin");
        _words.push("true");
        _words.push("vast");
        _words.push("warm");
        _words.push("wide");
        _words.push("wild");
        _words.push("wise");
    }

    function wordCount() external view override returns (uint256) {
        return _words.length;
    }

    function wordAt(uint256 index) external view override returns (string memory) {
        require(index < _words.length, "AdjectiveDictionary: index out of bounds");
        return _words[index];
    }
}
