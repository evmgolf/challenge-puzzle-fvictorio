// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import {Programs} from "evmgolf/Programs.sol";
import {Id, Challenge, Challenges} from "evmgolf/Challenge.sol";
import {Trophies} from "evmgolf/Trophies.sol";
import {Create2} from "create2/Create2.sol";
import {EVMPuzzleDeployer} from "../EVMPuzzle.sol";
import {ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";
import {Decimal} from "codec/Decimal.sol";

contract EVMPuzzleTest is Test, ERC721TokenReceiver {
  Programs programs;
  Challenges challenges;
  Trophies trophies;
  mapping(uint8=>address) challenge;
  using Id for address;
  using Decimal for uint;

  function setUp() public {
    programs = new Programs("Programs", "P");
    challenges = new Challenges("Challenges", "C");
    trophies = new Trophies("Trophies", "T", address(challenges), address(programs));

    bytes[] memory puzzles = EVMPuzzleDeployer.puzzles();

    for (uint i=1;i<puzzles.length;i++) {
      challenge[uint8(i)] = EVMPuzzleDeployer.deployEVMPuzzle(address(challenges), 0, puzzles[i], bytes.concat("EVM Puzzle from @fvictorio - #", i.decimal()));
      challenges.reviewChallenge(challenge[uint8(i)].id(), true, "");
    }
  }

  function solveSize(bytes memory solution, uint expected, uint8 c) public {
    if (Create2.hasBadText(solution)) {
      return;
    }

    address program = programs.write(Create2.text(solution));

    if (solution.length == expected) {
      trophies.submit(challenge[c], program);
    } else {
      vm.expectRevert("CHALLENGE_FAILED");
      trophies.submit(challenge[c], program);
    }
  }

  function testPuzzle01(bytes calldata solution) public {
    solveSize(solution, 8, 1);
  }

  function testGasPuzzle01() public {
    bytes memory text = new bytes(8);
    address program = programs.write(Create2.text(text));
    trophies.submit(challenge[1], program);
  }

  function testPuzzle02(bytes calldata solution) public {
    solveSize(solution, 4, 2);
  }

  function testGasPuzzle02() public {
    bytes memory text = new bytes(4);
    address program = programs.write(Create2.text(text));
    trophies.submit(challenge[2], program);
  }

  function testPuzzle03(bytes calldata solution) public {
    solveSize(solution, 4, 3);
  }

  function testGasPuzzle03() public {
    bytes memory text = new bytes(4);
    address program = programs.write(Create2.text(text));
    trophies.submit(challenge[3], program);
  }

  function testPuzzle04(bytes calldata solution) public {
    solveSize(solution, 6, 4);
  }

  function testGasPuzzle04() public {
    bytes memory text = new bytes(6);
    address program = programs.write(Create2.text(text));
    trophies.submit(challenge[4], program);
  }

  function testPuzzle05(uint16 size) public {
    bytes memory text = new bytes(size);
    address program = programs.write(Create2.text(text));

    if (size == 16) {
      trophies.submit(challenge[5], program);
    } else {
      vm.expectRevert("CHALLENGE_FAILED");
      trophies.submit(challenge[5], program);
    }
  }

  function testGasPuzzle05() public {
    bytes memory text = new bytes(16);
    address program = programs.write(Create2.text(text));
    trophies.submit(challenge[5], program);
  }

  function testPuzzle06(bytes calldata text) public {
    if (Create2.hasBadText(text)) {
      return;
    }

    address program = programs.write(Create2.text(text));

    vm.expectRevert("CHALLENGE_FAILED");
    trophies.submit(challenge[6], program);
  }

  function testGasPuzzle06() public {
    bytes memory text = abi.encode(uint(0xa));
    address program = programs.write(Create2.text(text));
    trophies.submit(challenge[6], program);
  }

  function testPuzzle07(uint16 size) public {
    bytes memory text = new bytes(size);
    address program = programs.write(Create2.text(text));

    vm.expectRevert("CHALLENGE_FAILED");
    trophies.submit(challenge[7], program);
  }

  function testGasPuzzle07() public {
    bytes memory text = Create2.text(hex"00");
    address program = programs.write(Create2.text(text));
    trophies.submit(challenge[7], program);
  }

  function testPuzzle08(uint16 size) public {
    bytes memory text = new bytes(size);
    address program = programs.write(Create2.text(text));

    vm.expectRevert("CHALLENGE_FAILED");
    trophies.submit(challenge[8], program);
  }

  function testGasPuzzle08() public {
    bytes memory text = Create2.text(hex"FD");
    address program = programs.write(Create2.text(text));
    trophies.submit(challenge[8], program);
  }

}
