# EVM Puzzle Challenges based on [fvictorio/evm-puzzles](https://github.com/fvictorio/evm-puzzles)

The following challenges are modified versions of fvictorio's evm-puzzles,
which replaces all references to `CALLVALUE` with `CALLDATASIZE`

Puzzles 1-8 have been included, of which [8](https://mumbai.polygonscan.com/address/0x80ee2b680b0c5e1670f2352ae1486cd0f30cc31c) is still unsolved.

The scripts Deploy and Solve create and solve the challenges respectively.
Solve uses an ffi call to GraphQL in order to find the available challenges,
and filters their descriptions to find the specific challenges according to their number.

Each challenge is implemented via CallChallenge, which uses the entire code of the submitted program
as calldata for the target challenge code. This mimics the behavior of the original, which existing entirely on-chain.

