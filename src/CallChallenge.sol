// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import {Challenge} from "evmgolf/Challenge.sol";

contract CallChallenge is Challenge {
  address immutable public plainChallenge;
  constructor(address _plainChallenge) {
    plainChallenge = _plainChallenge;
  }

  function challenge(address program) external override returns (bool result) {
    bytes memory returnValue;
    (result, returnValue) = plainChallenge.call(program.code);
  }
}
