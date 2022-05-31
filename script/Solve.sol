// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import {Script} from "forge-std/Script.sol";
import {Create2Deployer} from "foundry-create2-deployer/Create2Deployer.sol";
import {EVMPuzzleDeployer} from "src/EVMPuzzle.sol";
import {Hexadecimal} from "codec/Hexadecimal.sol";
import {Create2} from "create2/Create2.sol";
import {Programs} from "evmgolf/Programs.sol";
import {Id, Challenges} from "evmgolf/Challenge.sol";
import {Trophies} from "evmgolf/Trophies.sol";
import {Bash} from "bash/Bash.sol";
import {GraphQL} from "graphql/GraphQL.sol";

contract Solve is Script {
  using Id for address;
  using Hexadecimal for bytes;

  event log_challenge(address at, string desc);
  event log_program(address);

  address programs;
  address challenges;
  address trophies;
  mapping(uint => address) public indexedChallenges;

  uint currentChallenge = 1;

  function submit(bytes memory text) internal {
    text = Create2.text(text);
    address program = Create2.create2Address(programs, Programs(programs).salt(), text);
    emit log_program(program);
    if (program.code.length == 0) {
      Programs(programs).write(text);
    }
    address challenge = indexedChallenges[currentChallenge++];
    Trophies(trophies).submit(challenge, program);
  }

  function run() external {
    (new Create2Deployer()).run();
    GraphQL graphql = new GraphQL();
    Bash bash = new Bash();

    if (block.chainid == 31337) {
      programs = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    } else if (block.chainid == 80001) {
      programs = 0x1B38eCd445A2bb5596F00D5C2e3eeAa91a0D0A22;
    } else {
      revert("No Programs contract deployed on this chain");
    }

    if (block.chainid == 31337) {
      challenges = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512;
    } else if (block.chainid == 80001) {
      challenges = 0x0d782AB1a116C7c6Eb269A58c4Bd8C4207408198;
    } else {
      revert("No Challenges contract deployed on this chain");
    }

    if (block.chainid == 31337) {
      trophies = 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0;
    } else if (block.chainid == 80001) {
      trophies = 0xb6d4b6156da5B7c770ACaE71e1741fBB4f98Fae3;
    } else {
      revert("No Trophies contract deployed on this chain");
    }

    bytes memory graphqlEndpoint;

    if (block.chainid == 31337) {
      graphqlEndpoint = "http://127.0.0.1:8000/subgraphs/name/evmgolf/evmgolf-subgraph";
    } else if (block.chainid == 80001) {
      graphqlEndpoint = "https://api.thegraph.com/subgraphs/name/evmgolf/evmgolf-mumbai";
    } else {
      revert("No Subgraph deployed for this chain.");
    }

    address[] memory challengeAddresses = graphql.queryManyAddresses(
      graphqlEndpoint,
      "query {challengeEntities {id}}",
      "challengeEntities",
      "id"
    );

    bytes memory search = bytes("EVM Puzzle from @fvictorio - #").hexadecimal();

    for (uint i=0;i<challengeAddresses.length;i++) {
      address challenge = challengeAddresses[i];

      // MUST encode description as hexadecimal to avoid arbitrary shell injection
      bytes memory description = Challenges(challenges).descriptionOf(challenge.id()).hexadecimal();
      
      bytes memory challengeNumberRaw = bash.run(
        bytes.concat(
          "echo '",
          description,
          "'|sed 's/", search, "//g'|cast --to-ascii|cast --to-uint256"
        ),
        ""
      );

      if (challengeNumberRaw.length > 0) {
        uint challengeNumber = abi.decode(challengeNumberRaw, (uint));
        indexedChallenges[challengeNumber] = challenge;
      }
    }

    vm.startBroadcast();

    submit(new bytes(8));
    submit(new bytes(4));
    submit(new bytes(4));
    submit(new bytes(6));
    submit(new bytes(16));
    submit(abi.encode(uint(0xa)));
    submit(Create2.text(hex"00"));
    submit(Create2.text(hex"FD"));
  } 
}
