// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

//interfaces

//libraries

//contracts
import {Deployer} from "../common/Deployer.s.sol";
import {DiamondCutFacet} from "src/facets/cut/DiamondCutFacet.sol";
import {FacetHelper} from "../common/FacetHelper.s.sol";

contract DeployDiamondCut is FacetHelper, Deployer {
  constructor() {
    addSelector(DiamondCutFacet.diamondCut.selector);
  }

  function initializer() public pure override returns (bytes4) {
    return DiamondCutFacet.__DiamondCut_init.selector;
  }

  function versionName() public pure override returns (string memory) {
    return "diamondCutFacet";
  }

  function __deploy(address deployer) public override returns (address) {
    vm.startBroadcast(deployer);
    DiamondCutFacet diamondCut = new DiamondCutFacet();
    vm.stopBroadcast();
    return address(diamondCut);
  }
}
