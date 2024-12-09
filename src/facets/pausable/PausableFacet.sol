// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// interfaces
import {IPausable} from "./IPausable.sol";

// libraries

// contracts
import {Facet} from "src/facets/Facet.sol";
import {PausableBase} from "./PausableBase.sol";
import {OwnableBase} from "src/facets/ownable/OwnableBase.sol";

contract PausableFacet is IPausable, PausableBase, OwnableBase, Facet {
  function __Pausable_init() external onlyInitializing {
    _unpause();
  }

  function paused() external view returns (bool) {
    return _paused();
  }

  function pause() external onlyOwner whenNotPaused {
    _pause();
  }

  function unpause() external onlyOwner whenPaused {
    _unpause();
  }
}
