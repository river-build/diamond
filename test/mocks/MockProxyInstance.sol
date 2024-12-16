// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// interfaces

// libraries

// contracts

import {ManagedProxyBase} from "src/proxy/managed/ManagedProxyBase.sol";
import {OwnableBase} from "src/facets/ownable/OwnableBase.sol";
import {IntrospectionBase} from "src/facets/introspection/IntrospectionBase.sol";

/// @title MockProxyInstance
/// @notice Simple instance of a managed proxy for testing purposes
contract MockProxyInstance is ManagedProxyBase, OwnableBase, IntrospectionBase {
  constructor(bytes4 managerSelector, address manager) {
    __ManagedProxyBase_init(
      ManagedProxy({managerSelector: managerSelector, manager: manager})
    );
    _transferOwnership(msg.sender);
  }

  function local_addInterface(bytes4 interfaceId) external onlyOwner {
    _addInterface(interfaceId);
  }

  receive() external payable {
    revert("MockProxyInstance: cannot receive ether");
  }
}
