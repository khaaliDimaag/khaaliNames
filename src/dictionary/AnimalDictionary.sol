// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IDictionary} from "./IDictionary.sol";

/// @title AnimalDictionary
/// @notice On-chain dictionary of animal names for khaaliNames.
contract AnimalDictionary is IDictionary {
    string[] private _words;

    constructor() {
        _words.push("ant");
        _words.push("ape");
        _words.push("bat");
        _words.push("bear");
        _words.push("bee");
        _words.push("bird");
        _words.push("bull");
        _words.push("cat");
        _words.push("cod");
        _words.push("cow");
        _words.push("crab");
        _words.push("crow");
        _words.push("deer");
        _words.push("dog");
        _words.push("dove");
        _words.push("duck");
        _words.push("eagle");
        _words.push("eel");
        _words.push("elk");
        _words.push("emu");
        _words.push("fish");
        _words.push("fly");
        _words.push("fox");
        _words.push("frog");
        _words.push("goat");
        _words.push("hawk");
        _words.push("hen");
        _words.push("hog");
        _words.push("horse");
        _words.push("jay");
        _words.push("koi");
        _words.push("lamb");
        _words.push("lark");
        _words.push("lion");
        _words.push("lynx");
        _words.push("mink");
        _words.push("mole");
        _words.push("moth");
        _words.push("mouse");
        _words.push("mule");
        _words.push("newt");
        _words.push("owl");
        _words.push("ox");
        _words.push("panda");
        _words.push("pig");
        _words.push("puma");
        _words.push("ram");
        _words.push("rat");
        _words.push("ray");
        _words.push("seal");
        _words.push("shark");
        _words.push("slug");
        _words.push("snail");
        _words.push("snake");
        _words.push("swan");
        _words.push("toad");
        _words.push("trout");
        _words.push("tuna");
        _words.push("viper");
        _words.push("wasp");
        _words.push("whale");
        _words.push("wolf");
        _words.push("worm");
        _words.push("yak");
    }

    function wordCount() external view override returns (uint256) {
        return _words.length;
    }

    function wordAt(uint256 index) external view override returns (string memory) {
        require(index < _words.length, "AnimalDictionary: index out of bounds");
        return _words[index];
    }
}
