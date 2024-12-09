// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// interfaces

// libraries

// contracts

import {Initializable} from "src/facets/initializable/Initializable.sol";
import {IntrospectionBase} from "src/facets/introspection/IntrospectionBase.sol";

abstract contract Facet is Initializable, IntrospectionBase {
  constructor() {
    _disableInitializers();
  }
}
