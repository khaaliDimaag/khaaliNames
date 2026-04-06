// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {SSTORE2} from "solady/utils/SSTORE2.sol";

import {IkhaaliDictionaryV1} from "../src/dictionary/IkhaaliDictionaryV1.sol";
import {ColorDictionaryV1} from "../src/dictionary/ColorDictionaryV1.sol";
import {AnimalDictionaryV1} from "../src/dictionary/AnimalDictionaryV1.sol";
import {AdjectiveDictionaryV1} from "../src/dictionary/AdjectiveDictionaryV1.sol";
import {khaaliNamesV1} from "../src/khaaliNamesV1.sol";
import {IkhaaliNamesV1, NameType, Milestone} from "../src/IkhaaliNamesV1.sol";

contract khaaliNamesV1Test is Test {

    uint256 constant WORD_LENGTH = 16;

    khaaliNamesV1 names;
    IkhaaliDictionaryV1 colorDict;
    IkhaaliDictionaryV1 animalDict;
    IkhaaliDictionaryV1 adjDict;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        address colorPointer = SSTORE2.write(_packWords("data/colors.txt", 50));
        colorDict = new ColorDictionaryV1(colorPointer);

        address animalPointer = SSTORE2.write(_packWords("data/animals.txt", 350));
        animalDict = new AnimalDictionaryV1(animalPointer);

        address adjPointer = SSTORE2.write(_packWords("data/adjectives.txt", 1200));
        adjDict = new AdjectiveDictionaryV1(adjPointer);

        names = new khaaliNamesV1(animalDict, colorDict, adjDict);
    }

    // ───────────────── Dictionary tests ─────────────────

    function test_colorDict_wordCount() public view {
        assertEq(colorDict.wordCount(), 50);
    }

    function test_animalDict_wordCount() public view {
        assertEq(animalDict.wordCount(), 350);
    }

    function test_adjDict_wordCount() public view {
        assertEq(adjDict.wordCount(), 1200);
    }

    function test_colorDict_firstWord() public view {
        string memory word = colorDict.wordAt(0);
        assertTrue(bytes(word).length > 0);
        console.log("First color:", word);
    }

    function test_colorDict_lastWord() public view {
        string memory word = colorDict.wordAt(49);
        assertTrue(bytes(word).length > 0);
        console.log("Last color:", word);
    }

    function test_animalDict_firstWord() public view {
        string memory word = animalDict.wordAt(0);
        assertTrue(bytes(word).length > 0);
        console.log("First animal:", word);
    }

    function test_animalDict_lastWord() public view {
        string memory word = animalDict.wordAt(349);
        assertTrue(bytes(word).length > 0);
        console.log("Last animal:", word);
    }

    function test_adjDict_firstWord() public view {
        string memory word = adjDict.wordAt(0);
        assertTrue(bytes(word).length > 0);
        console.log("First adjective:", word);
    }

    function test_adjDict_lastWord() public view {
        string memory word = adjDict.wordAt(1199);
        assertTrue(bytes(word).length > 0);
        console.log("Last adjective:", word);
    }

    function test_revert_colorDict_outOfBounds() public {
        vm.expectRevert();
        colorDict.wordAt(50);
    }

    function test_revert_animalDict_outOfBounds() public {
        vm.expectRevert();
        animalDict.wordAt(350);
    }

    function test_revert_adjDict_outOfBounds() public {
        vm.expectRevert();
        adjDict.wordAt(1200);
    }

    // ───────────────── Immutables ─────────────────

    function test_immutables() public view {
        assertEq(address(names.animalDict()), address(animalDict));
        assertEq(address(names.colorDict()), address(colorDict));
        assertEq(address(names.adjectiveDict()), address(adjDict));
    }

    // ──────────── Milestone-based names ──────────────────

    function test_milestone_ANIMAL_30() public view {
        string memory name = names.getRandomName(alice, Milestone.ANIMAL_30);
        assertTrue(bytes(name).length > 0);
        assertEq(_countHyphens(name), 1); // word-n
        console.log("ANIMAL_30:", name);
    }

    function test_milestone_COLOR_ANIMAL_5() public view {
        string memory name = names.getRandomName(alice, Milestone.COLOR_ANIMAL_5);
        assertTrue(bytes(name).length > 0);
        assertEq(_countHyphens(name), 2); // color-animal-n
        console.log("COLOR_ANIMAL_5:", name);
    }

    function test_milestone_ADJ_ANIMAL_2() public view {
        string memory name = names.getRandomName(alice, Milestone.ADJ_ANIMAL_2);
        assertTrue(bytes(name).length > 0);
        assertEq(_countHyphens(name), 2); // adj-animal-n
        console.log("ADJ_ANIMAL_2:", name);
    }

    function test_milestone_COLOR_ADJ_ANIMAL_3() public view {
        string memory name = names.getRandomName(alice, Milestone.COLOR_ADJ_ANIMAL_3);
        assertTrue(bytes(name).length > 0);
        assertEq(_countHyphens(name), 3); // color-adj-animal-n
        console.log("COLOR_ADJ_ANIMAL_3:", name);
    }

    function test_revert_milestone_NONE() public {
        vm.expectRevert(IkhaaliNamesV1.UnsupportedMilestone.selector);
        names.getRandomName(alice, Milestone.NONE);
    }

    // ──────────── Escape hatch (NameType + n) ──────────────

    function test_nameType_ANIMAL() public view {
        string memory name = names.getRandomName(alice, NameType.ANIMAL, 10);
        assertEq(_countHyphens(name), 1);
        console.log("ANIMAL:", name);
    }

    function test_nameType_COLOR() public view {
        string memory name = names.getRandomName(alice, NameType.COLOR, 5);
        assertEq(_countHyphens(name), 1);
        console.log("COLOR:", name);
    }

    function test_nameType_ADJECTIVE() public view {
        string memory name = names.getRandomName(alice, NameType.ADJECTIVE, 3);
        assertEq(_countHyphens(name), 1);
        console.log("ADJECTIVE:", name);
    }

    function test_nameType_COLOR_ANIMAL() public view {
        string memory name = names.getRandomName(alice, NameType.COLOR_ANIMAL, 5);
        assertEq(_countHyphens(name), 2);
        console.log("COLOR_ANIMAL:", name);
    }

    function test_nameType_ADJECTIVE_ANIMAL() public view {
        string memory name = names.getRandomName(alice, NameType.ADJECTIVE_ANIMAL, 2);
        assertEq(_countHyphens(name), 2);
        console.log("ADJECTIVE_ANIMAL:", name);
    }

    function test_nameType_COLOR_ADJECTIVE_ANIMAL() public view {
        string memory name = names.getRandomName(alice, NameType.COLOR_ADJECTIVE_ANIMAL, 3);
        assertEq(_countHyphens(name), 3);
        console.log("COLOR_ADJECTIVE_ANIMAL:", name);
    }

    function test_nameType_ADJECTIVE_COLOR_ANIMAL() public view {
        string memory name = names.getRandomName(alice, NameType.ADJECTIVE_COLOR_ANIMAL, 4);
        assertEq(_countHyphens(name), 3);
        console.log("ADJECTIVE_COLOR_ANIMAL:", name);
    }

    // ──────────── n=0 (no suffix) ──────────────

    function test_nameType_noSuffix() public view {
        string memory name = names.getRandomName(alice, NameType.COLOR_ANIMAL, 0);
        assertEq(_countHyphens(name), 1); // color-animal, no -n
        console.log("No suffix:", name);
    }

    // ──────────── Different recipients ──────────────

    function test_differentRecipients() public view {
        string memory nameAlice = names.getRandomName(alice, Milestone.ANIMAL_30);
        string memory nameBob = names.getRandomName(bob, Milestone.ANIMAL_30);
        console.log("Alice:", nameAlice);
        console.log("Bob:", nameBob);
    }

    // ────────────────── Revert cases ─────────────────────

    function test_revert_nameType_NONE() public {
        vm.expectRevert(IkhaaliNamesV1.InvalidNameType.selector);
        names.getRandomName(alice, NameType.NONE, 1);
    }

    // ──────────────── Helper ────────────────

    function _countHyphens(string memory s) internal pure returns (uint256 count) {
        bytes memory b = bytes(s);
        for (uint256 i = 0; i < b.length; i++) {
            if (b[i] == 0x2D) count++;
        }
    }

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
}