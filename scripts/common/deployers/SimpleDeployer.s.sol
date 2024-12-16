// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//interfaces

//libraries

//contracts
import {DeployBase} from "scripts/common/DeployBase.s.sol";

abstract contract SimpleDeployer is DeployBase {
  constructor() DeployBase() {}
}
