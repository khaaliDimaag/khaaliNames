// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {khaaliNamesV1, NameType, Milestone} from "../src/khaaliNamesV1.sol";
import {AnimalDictionary} from "../src/AnimalDictionary.sol";
import {ColorDictionary} from "../src/ColorDictionary.sol";
import {AdjectiveDictionary} from "../src/AdjectiveDictionary.sol";
import {IDictionary} from "../src/IDictionary.sol";

// Minimal test harness (no forge-std dependency)
contract khaaliNamesV1Test {
    AnimalDictionary animalDict;
    ColorDictionary colorDict;
    AdjectiveDictionary adjectiveDict;
    khaaliNamesV1 names;

    address constant ALICE = address(0xA11CE);
    address constant BOB = address(0xB0B);

    event LogName(string name);
    event TestPassed(string testName);

    function setUp() public {
        animalDict = new AnimalDictionary();
        colorDict = new ColorDictionary();
        adjectiveDict = new AdjectiveDictionary();
        names = new khaaliNamesV1(
            IDictionary(address(animalDict)),
            IDictionary(address(colorDict)),
            IDictionary(address(adjectiveDict))
        );
    }

    // ─────────────── Dictionary tests ───────────────

    function test_AnimalDictionary_wordCount() public {
        setUp();
        uint256 count = animalDict.wordCount();
        require(count == 64, "Expected 64 animals");
        emit TestPassed("test_AnimalDictionary_wordCount");
    }

    function test_ColorDictionary_wordCount() public {
        setUp();
        uint256 count = colorDict.wordCount();
        require(count == 40, "Expected 40 colors");
        emit TestPassed("test_ColorDictionary_wordCount");
    }

    function test_AdjectiveDictionary_wordCount() public {
        setUp();
        uint256 count = adjectiveDict.wordCount();
        require(count == 40, "Expected 40 adjectives");
        emit TestPassed("test_AdjectiveDictionary_wordCount");
    }

    function test_AnimalDictionary_wordAt() public {
        setUp();
        string memory first = animalDict.wordAt(0);
        require(keccak256(bytes(first)) == keccak256(bytes("ant")), "First animal should be ant");
        emit TestPassed("test_AnimalDictionary_wordAt");
    }

    // ─────────────── Default name generation ───────────────

    function test_getRandomName_default_returnsNonEmpty() public {
        setUp();
        string memory name = names.getRandomName(ALICE);
        require(bytes(name).length > 0, "Name should not be empty");
        emit LogName(name);
        emit TestPassed("test_getRandomName_default_returnsNonEmpty");
    }

    function test_getRandomName_default_containsHyphen() public {
        setUp();
        string memory name = names.getRandomName(ALICE);
        require(_containsHyphen(name), "Default name should contain a hyphen");
        emit TestPassed("test_getRandomName_default_containsHyphen");
    }

    function test_getRandomName_differentRecipients_differentNames() public {
        setUp();
        string memory nameA = names.getRandomName(ALICE);
        string memory nameB = names.getRandomName(BOB);
        require(
            keccak256(bytes(nameA)) != keccak256(bytes(nameB)),
            "Different recipients should get different names"
        );
        emit TestPassed("test_getRandomName_differentRecipients_differentNames");
    }

    // ─────────────── Milestone-based generation ───────────────

    function test_getRandomName_milestone_ANIMAL_30() public {
        setUp();
        string memory name = names.getRandomName(ALICE, Milestone.ANIMAL_30);
        require(bytes(name).length > 0, "ANIMAL_30 name should not be empty");
        emit LogName(name);
        emit TestPassed("test_getRandomName_milestone_ANIMAL_30");
    }

    function test_getRandomName_milestone_COLOR_ANIMAL_5() public {
        setUp();
        string memory name = names.getRandomName(ALICE, Milestone.COLOR_ANIMAL_5);
        require(_countHyphens(name) >= 2, "COLOR_ANIMAL_5 should have at least 2 hyphens");
        emit LogName(name);
        emit TestPassed("test_getRandomName_milestone_COLOR_ANIMAL_5");
    }

    function test_getRandomName_milestone_ADJ_ANIMAL_2() public {
        setUp();
        string memory name = names.getRandomName(ALICE, Milestone.ADJ_ANIMAL_2);
        require(_countHyphens(name) >= 2, "ADJ_ANIMAL_2 should have at least 2 hyphens");
        emit LogName(name);
        emit TestPassed("test_getRandomName_milestone_ADJ_ANIMAL_2");
    }

    function test_getRandomName_milestone_COLOR_ADJ_ANIMAL_3() public {
        setUp();
        string memory name = names.getRandomName(ALICE, Milestone.COLOR_ADJ_ANIMAL_3);
        require(_countHyphens(name) >= 3, "COLOR_ADJ_ANIMAL_3 should have at least 3 hyphens");
        emit LogName(name);
        emit TestPassed("test_getRandomName_milestone_COLOR_ADJ_ANIMAL_3");
    }

    // ─────────────── Escape hatch (custom NameType + n) ───────────────

    function test_getRandomName_custom_ANIMAL() public {
        setUp();
        string memory name = names.getRandomName(ALICE, NameType.ANIMAL, 10);
        require(_countHyphens(name) == 1, "ANIMAL should have exactly 1 hyphen (word-n)");
        emit LogName(name);
        emit TestPassed("test_getRandomName_custom_ANIMAL");
    }

    function test_getRandomName_custom_COLOR() public {
        setUp();
        string memory name = names.getRandomName(ALICE, NameType.COLOR, 5);
        require(_countHyphens(name) == 1, "COLOR should have exactly 1 hyphen (word-n)");
        emit LogName(name);
        emit TestPassed("test_getRandomName_custom_COLOR");
    }

    function test_getRandomName_custom_ADJECTIVE_COLOR_ANIMAL() public {
        setUp();
        string memory name = names.getRandomName(ALICE, NameType.ADJECTIVE_COLOR_ANIMAL, 1);
        require(_countHyphens(name) == 3, "ADJECTIVE_COLOR_ANIMAL should have 3 hyphens");
        emit LogName(name);
        emit TestPassed("test_getRandomName_custom_ADJECTIVE_COLOR_ANIMAL");
    }

    // ─────────────── Revert cases ───────────────

    function test_getRandomName_reverts_on_NONE() public {
        setUp();
        bool reverted = false;
        try names.getRandomName(ALICE, NameType.NONE, 5) {
            // Should not reach here
        } catch {
            reverted = true;
        }
        require(reverted, "Should revert on NameType.NONE");
        emit TestPassed("test_getRandomName_reverts_on_NONE");
    }

    function test_getRandomName_reverts_on_zero_n() public {
        setUp();
        bool reverted = false;
        try names.getRandomName(ALICE, NameType.ANIMAL, 0) {
            // Should not reach here
        } catch {
            reverted = true;
        }
        require(reverted, "Should revert on n=0");
        emit TestPassed("test_getRandomName_reverts_on_zero_n");
    }

    // ─────────────── Immutables ───────────────

    function test_immutables_set_correctly() public {
        setUp();
        require(address(names.animalDict()) == address(animalDict), "animalDict mismatch");
        require(address(names.colorDict()) == address(colorDict), "colorDict mismatch");
        require(address(names.adjectiveDict()) == address(adjectiveDict), "adjectiveDict mismatch");
        emit TestPassed("test_immutables_set_correctly");
    }

    // ─────────────── Helpers ───────────────

    function _containsHyphen(string memory s) internal pure returns (bool) {
        bytes memory b = bytes(s);
        for (uint256 i = 0; i < b.length; i++) {
            if (b[i] == "-") return true;
        }
        return false;
    }

    function _countHyphens(string memory s) internal pure returns (uint256 count) {
        bytes memory b = bytes(s);
        for (uint256 i = 0; i < b.length; i++) {
            if (b[i] == "-") count++;
        }
    }
}
