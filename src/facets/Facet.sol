// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// interfaces

// libraries

// contracts

import {Initializable} from "solady/utils/Initializable.sol";
import {IntrospectionBase} from "./introspection/IntrospectionBase.sol";

abstract contract Facet is Initializable, IntrospectionBase {
  constructor() {
    _disableInitializers();
  }
}
