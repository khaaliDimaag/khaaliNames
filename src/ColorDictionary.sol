// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IDictionary} from "./IDictionary.sol";

/// @title ColorDictionary
/// @notice On-chain dictionary of color names for khaaliNames.
contract ColorDictionary is IDictionary {
    string[] private _words;

    constructor() {
        _words.push("red");
        _words.push("blue");
        _words.push("green");
        _words.push("gold");
        _words.push("gray");
        _words.push("jade");
        _words.push("lime");
        _words.push("mint");
        _words.push("navy");
        _words.push("onyx");
        _words.push("peach");
        _words.push("pink");
        _words.push("plum");
        _words.push("rose");
        _words.push("ruby");
        _words.push("rust");
        _words.push("sage");
        _words.push("sand");
        _words.push("snow");
        _words.push("teal");
        _words.push("wine");
        _words.push("amber");
        _words.push("azure");
        _words.push("beige");
        _words.push("black");
        _words.push("blush");
        _words.push("brass");
        _words.push("brown");
        _words.push("coral");
        _words.push("cream");
        _words.push("ivory");
        _words.push("khaki");
        _words.push("lilac");
        _words.push("mauve");
        _words.push("ochre");
        _words.push("olive");
        _words.push("pearl");
        _words.push("slate");
        _words.push("steel");
        _words.push("white");
    }

    function wordCount() external view override returns (uint256) {
        return _words.length;
    }

    function wordAt(uint256 index) external view override returns (string memory) {
        require(index < _words.length, "ColorDictionary: index out of bounds");
        return _words[index];
    }
}
