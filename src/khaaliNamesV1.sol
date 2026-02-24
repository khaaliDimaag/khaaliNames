// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IDictionary} from "./IDictionary.sol";

/// @title khaaliNamesV1
/// @notice On-chain random name generator. Generates human-readable names from
///         combinationsof animals, colors, and adjectives with a numeric suffix.
/// @dev Deployed once with immutable dictionary references. Anyone can call it.

/// @notice The type of name to generate. Determines which dictionaries are used
///         and in what order the words appear.
enum NameType {
    NONE,                    // 0 - no-op, reverts
    ANIMAL,                  // 1 - "fox"
    COLOR,                   // 2 - "blue"
    ADJECTIVE,               // 3 - "bold"
    COLOR_ANIMAL,            // 4 - "blue-fox"
    ADJECTIVE_ANIMAL,        // 5 - "bold-fox"
    COLOR_ADJECTIVE_ANIMAL,  // 6 - "blue-bold-fox"
    ADJECTIVE_COLOR_ANIMAL   // 7 - "bold-blue-fox"
}

/// @notice Opinionated milestone presets that map to (NameType, n) pairs.
///         As a project grows, it can move to higher milestones for more unique names.
enum Milestone {
    ANIMAL_30,           // animal-n,                  n in [1,30]
    COLOR_ANIMAL_5,      // color-animal-n,            n in [1,5]
    ADJ_ANIMAL_2,        // adjective-animal-n,        n in [1,2]
    COLOR_ADJ_ANIMAL_3   // color-adjective-animal-n,  n in [1,3]
}

contract khaaliNamesV1 {

    // ───────────────────────── Errors ─────────────────────────

    error InvalidNameType();
    error InvalidN();

    // ───────────────────── Immutable state ─────────────────────

    IDictionary public immutable animalDict;
    IDictionary public immutable colorDict;
    IDictionary public immutable adjectiveDict;

    // ─────────────────────── Constructor ───────────────────────

    constructor(
        IDictionary _animalDict,
        IDictionary _colorDict,
        IDictionary _adjectiveDict
    ) {
        animalDict = _animalDict;
        colorDict = _colorDict;
        adjectiveDict = _adjectiveDict;
    }

    // ──────────────────── Public interface ─────────────────────

    /// @notice Generate a name using the default milestone (ANIMAL_30).
    /// @param recipient The address used as a seed for randomness.
    /// @return The generated name string.
    function getRandomName(address recipient) external view returns (string memory) {
        return _nameFromMilestone(recipient, Milestone.ANIMAL_30);
    }

    /// @notice Generate a name using an opinionated milestone preset.
    /// @param recipient The address used as a seed for randomness.
    /// @param milestone The milestone preset to use.
    /// @return The generated name string.
    function getRandomName(address recipient, Milestone milestone) external view returns (string memory) {
        return _nameFromMilestone(recipient, milestone);
    }

    /// @notice Escape hatch — caller picks the name type and numeric suffix range.
    /// @param recipient The address used as a seed for randomness.
    /// @param nameType  The name composition to use.
    /// @param n         The upper bound of the numeric suffix (1-based, inclusive).
    /// @return The generated name string.
    function getRandomName(address recipient, NameType nameType, uint8 n) external view returns (string memory) {
        if (nameType == NameType.NONE) revert InvalidNameType();
        if (n == 0) revert InvalidN();
        return _generate(recipient, nameType, n);
    }

    // ───────────────────── Internal logic ─────────────────────

    /// @dev Maps a Milestone to its (NameType, n) pair and generates.
    function _nameFromMilestone(address recipient, Milestone milestone) internal view returns (string memory) {
        if (milestone == Milestone.ANIMAL_30) {
            return _generate(recipient, NameType.ANIMAL, 30);
        } else if (milestone == Milestone.COLOR_ANIMAL_5) {
            return _generate(recipient, NameType.COLOR_ANIMAL, 5);
        } else if (milestone == Milestone.ADJ_ANIMAL_2) {
            return _generate(recipient, NameType.ADJECTIVE_ANIMAL, 2);
        } else {
            return _generate(recipient, NameType.COLOR_ADJECTIVE_ANIMAL, 3);
        }
    }

    /// @dev Core generation logic. Picks words from dictionaries based on NameType,
    ///      concatenates them with hyphens, and appends a numeric suffix in [1, n].
    function _generate(
        address recipient,
        NameType nameType,
        uint8 n
    ) internal view returns (string memory) {
        // Seed from recipient + some on-chain entropy
        uint256 seed = uint256(keccak256(abi.encodePacked(recipient, block.prevrandao, block.timestamp)));

        // Build the name parts
        bytes memory name;

        if (nameType == NameType.ANIMAL) {
            name = abi.encodePacked(_pickWord(animalDict, seed, 0));
        } else if (nameType == NameType.COLOR) {
            name = abi.encodePacked(_pickWord(colorDict, seed, 0));
        } else if (nameType == NameType.ADJECTIVE) {
            name = abi.encodePacked(_pickWord(adjectiveDict, seed, 0));
        } else if (nameType == NameType.COLOR_ANIMAL) {
            name = abi.encodePacked(
                _pickWord(colorDict, seed, 0),
                "-",
                _pickWord(animalDict, seed, 1)
            );
        } else if (nameType == NameType.ADJECTIVE_ANIMAL) {
            name = abi.encodePacked(
                _pickWord(adjectiveDict, seed, 0),
                "-",
                _pickWord(animalDict, seed, 1)
            );
        } else if (nameType == NameType.COLOR_ADJECTIVE_ANIMAL) {
            name = abi.encodePacked(
                _pickWord(colorDict, seed, 0),
                "-",
                _pickWord(adjectiveDict, seed, 1),
                "-",
                _pickWord(animalDict, seed, 2)
            );
        } else {
            // ADJECTIVE_COLOR_ANIMAL
            name = abi.encodePacked(
                _pickWord(adjectiveDict, seed, 0),
                "-",
                _pickWord(colorDict, seed, 1),
                "-",
                _pickWord(animalDict, seed, 2)
            );
        }

        // Append numeric suffix: -n where n is in [1, n]
        uint256 suffix = (uint256(keccak256(abi.encodePacked(seed, "suffix"))) % n) + 1;

        return string(abi.encodePacked(name, "-", _uint2str(suffix)));
    }

    /// @dev Pick a word from a dictionary using a seed and a salt to vary selection
    ///      across multiple word slots in the same name.
    function _pickWord(
        IDictionary dict,
        uint256 seed,
        uint8 salt
    ) internal view returns (string memory) {
        uint256 count = dict.wordCount();
        uint256 index = uint256(keccak256(abi.encodePacked(seed, salt))) % count;
        return dict.wordAt(index);
    }

    /// @dev Convert a uint256 to its decimal string representation.
    function _uint2str(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";

        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }

        return string(buffer);
    }
}
