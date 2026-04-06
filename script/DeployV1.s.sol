// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {SSTORE2} from "solady/utils/SSTORE2.sol";

import {IkhaaliDictionaryV1} from "../src/dictionary/IkhaaliDictionaryV1.sol";
import {ColorDictionaryV1} from "../src/dictionary/ColorDictionaryV1.sol";
import {AnimalDictionaryV1} from "../src/dictionary/AnimalDictionaryV1.sol";
import {AdjectiveDictionaryV1} from "../src/dictionary/AdjectiveDictionaryV1.sol";
import {khaaliNamesV1} from "../src/khaaliNamesV1.sol";

contract DeployV1 is Script {

    uint256 constant WORD_LENGTH = 16;
    
    uint256 constant COLOR_COUNT = 50;
    uint256 constant ANIMAL_COUNT = 350;
    uint256 constant ADJECTIVE_COUNT = 1200;

    uint256 immutable DEPLOYER_KEY = vm.envUint("DEPLOYER_PRIVATE_KEY");

    function run() external {
        vm.startBroadcast(DEPLOYER_KEY);
        uint256 gasBefore = gasleft();

        // Deploy dictionaries
        (address colorPointer, uint256 colorDictSize) = _writeDictionary("data/colors.txt", COLOR_COUNT);
        IkhaaliDictionaryV1 colorDict = new ColorDictionaryV1(colorPointer);
        console.log("ColorDictionary:", address(colorDict));
        console.log("ColorDictionary size:", colorDictSize);

        (address animalPointer, uint256 animalDictSize) = _writeDictionary("data/animals.txt", ANIMAL_COUNT);
        IkhaaliDictionaryV1 animalDict = new AnimalDictionaryV1(animalPointer);
        console.log("AnimalDictionary:", address(animalDict));
        console.log("AnimalDictionary size:", animalDictSize);

        (address adjPointer, uint256 adjDictSize) = _writeDictionary("data/adjectives.txt", ADJECTIVE_COUNT);
        IkhaaliDictionaryV1 adjDict = new AdjectiveDictionaryV1(adjPointer);
        console.log("AdjectiveDictionary:", address(adjDict));
        console.log("AdjectiveDictionary size:", adjDictSize);

        // Deploy khaaliNamesV1
        khaaliNamesV1 names = new khaaliNamesV1(
            IkhaaliDictionaryV1(address(colorDict)),
            IkhaaliDictionaryV1(address(animalDict)),
            IkhaaliDictionaryV1(address(adjDict))
        );
        console.log("khaaliNamesV1:", address(names));

        uint256 gasUsed = gasBefore - gasleft();
        console.log("Gas used:", gasUsed);
        vm.stopBroadcast();

        // Save deployment info to disk
        _writeDeployment(
            colorPointer, colorDictSize, address(colorDict),
            animalPointer, animalDictSize, address(animalDict),
            adjPointer, adjDictSize, address(adjDict),
            address(names), gasUsed
        );
    }

    /// @dev Write a dictionary to SSTORE2 and return the pointer and size
    function _writeDictionary(string memory filePath, uint256 count) internal returns (address, uint256) {
        address pointer = SSTORE2.write(_packWords(filePath, count));
        uint256 size = pointer.code.length;
        return (pointer, size);
    }

    /// @dev Pack the words into a bytes array, each word padded to `WORD_LENGTH` bytes
    function _packWords(string memory filePath, uint256 count) internal view returns (bytes memory) {
        string memory fileContent = vm.readFile(filePath);
        bytes memory raw = bytes(fileContent);
        bytes memory packed = new bytes(count * WORD_LENGTH);

        uint256 start = 0;
        uint256 wordIndex = 0;

        for (uint256 i = 0; i <= raw.length; i++) {
            if (i == raw.length || raw[i] == 0x0A) {
                uint256 len = i - start;
                if (len > 0 && raw[start] != 0x0D) {
                    // strip \r if present
                    if (raw[start + len - 1] == 0x0D) len--;
                    require(len <= WORD_LENGTH, "Word too long for bytes16");
                    for (uint256 j = 0; j < len; j++) {
                        packed[wordIndex * WORD_LENGTH + j] = raw[start + j];
                    }
                    wordIndex++;
                }
                start = i + 1;
            }
        }

        require(wordIndex == count, "Word count mismatch");
        return packed;
    }

    function _writeDeployment(
        address colorPointer, uint256 colorDictSize, address colorDict,
        address animalPointer, uint256 animalDictSize, address animalDict,
        address adjPointer, uint256 adjDictSize, address adjDict,
        address names, uint256 gasUsed
    ) internal {

        // build objects ---------

        string memory colorObj = "color";
        vm.serializeAddress(colorObj, "address", colorDict);
        vm.serializeUint(colorObj, "count", COLOR_COUNT);
        vm.serializeAddress(colorObj, "data", colorPointer);
        string memory colorJson = vm.serializeUint(colorObj, "size", colorDictSize);


        string memory animalObj = "animal";
        vm.serializeAddress(animalObj, "address", animalDict);
        vm.serializeUint(animalObj, "count", ANIMAL_COUNT);
        vm.serializeAddress(animalObj, "data", animalPointer);
        string memory animalJson = vm.serializeUint(animalObj, "size", animalDictSize);

        string memory adjObj = "adj";
        vm.serializeAddress(adjObj, "address", adjDict);
        vm.serializeUint(adjObj, "count", ADJECTIVE_COUNT);
        vm.serializeAddress(adjObj, "data", adjPointer);
        string memory adjJson = vm.serializeUint(adjObj, "size", adjDictSize);

        // Nest under "dictionaries"
        string memory dictsObj = "dicts";
        vm.serializeString(dictsObj, "adjectives", adjJson);
        vm.serializeString(dictsObj, "animals", animalJson);
        string memory dictsJson = vm.serializeString(dictsObj, "colors", colorJson);

        // Build deployment content
        string memory info = "info";
        vm.serializeString(info, "dictionaries", dictsJson);
        vm.serializeAddress(info, "khaaliNamesV1", names);
        vm.serializeUint(info, "gasUsed", gasUsed);
        string memory infoJson = vm.serializeUint(info, "timestamp", block.timestamp);

        // write to deployments.json ---------
        string memory root = "root";
        string memory json = vm.serializeString(root, vm.toString(block.chainid), infoJson);
        vm.writeJson(json, "deployments.json");
    }
}