// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import {Create2} from "create2/Create2.sol";
import {CallChallenge} from "./CallChallenge.sol";
import {Challenges} from "evmgolf/Challenge.sol";

library EVMPuzzleDeployer {
  function deployEVMPuzzle (address challenges, uint salt, bytes memory code, bytes memory description) internal returns (address challenge) {
    address plainChallenge = Create2.create2Text(salt, code);
    challenge = address(new CallChallenge(plainChallenge));
    Challenges(challenges).requestChallenge(challenge, description);
  }

  function puzzles () internal pure returns (bytes[] memory p) {
    p = new bytes[](9);
    p[1] = hex"3656FDFDFDFDFDFD5B00";
    p[2] = hex"36380356FDFD5B00FDFD";
    p[3] = hex"3656FDFD5B00";
    p[4] = hex"36381856FDFDFDFDFDFD5B00";
    p[5] = hex"36800261010014600C57FDFD5B00FDFD";
    p[6] = hex"60003556FDFDFDFDFDFD5B00";
    p[7] = hex"36600080373660006000F03B600114601357FD5B00";
    p[8] = hex"36600080373660006000F0600080808080945AF1600014601B57FD5B00";
  }
}
