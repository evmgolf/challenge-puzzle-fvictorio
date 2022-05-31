// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import {Script} from "forge-std/Script.sol";
import {Create2Deployer} from "foundry-create2-deployer/Create2Deployer.sol";
import {EVMPuzzleDeployer} from "src/EVMPuzzle.sol";
import {Decimal} from "codec/Decimal.sol";
import {Create2} from "create2/Create2.sol";
import {CallChallenge} from "src/CallChallenge.sol";
import {Id, Challenges} from "evmgolf/Challenge.sol";

contract Deploy is Script {
  using Decimal for uint;
  using Id for address;

  event log(string);

  function run() external {
    (new Create2Deployer()).run();

    address challenges;
    if (block.chainid == 31337) {
      challenges = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512;
    } else if (block.chainid == 80001) {
      challenges = 0x0d782AB1a116C7c6Eb269A58c4Bd8C4207408198;
    } else {
      revert("No Challenges contract deployed on this chain");
    }

    bytes[] memory puzzles = EVMPuzzleDeployer.puzzles();

    vm.startBroadcast();
    for (uint i=1;i<puzzles.length;i++) {
      bytes memory description = bytes.concat("EVM Puzzle from @fvictorio - #", i.decimal());
      emit log(string(description));
      address plainChallenge = Create2.create2Text(0, puzzles[i]);
      address challenge = address(new CallChallenge(plainChallenge));
      Challenges(challenges).requestChallenge(challenge, description);
      Challenges(challenges).reviewChallenge(challenge.id(), true, "");
    }
  } 
}
