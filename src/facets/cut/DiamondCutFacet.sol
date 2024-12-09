// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// interfaces
import {IDiamond} from "src/IDiamond.sol";
import {IDiamondCut} from "./IDiamondCut.sol";

// libraries

// contracts
import {Facet} from "src/facets/Facet.sol";
import {DiamondCutBase} from "./DiamondCutBase.sol";
import {OwnableBase} from "src/facets/ownable/OwnableBase.sol";

contract DiamondCutFacet is IDiamondCut, OwnableBase, Facet {
  function __DiamondCut_init() external onlyInitializing {
    _addInterface(type(IDiamondCut).interfaceId);
  }

  /// @inheritdoc IDiamondCut
  function diamondCut(
    IDiamond.FacetCut[] memory facetCuts,
    address init,
    bytes memory initPayload
  ) external onlyOwner reinitializer(_nextVersion()) {
    DiamondCutBase.diamondCut(facetCuts, init, initPayload);
  }
}
