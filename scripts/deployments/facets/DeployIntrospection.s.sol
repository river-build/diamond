// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

//interfaces

//libraries

//contracts
import {SimpleDeployer} from "scripts/common/deployers/SimpleDeployer.s.sol";
import {IntrospectionFacet} from "src/facets/introspection/IntrospectionFacet.sol";
import {FacetHelper} from "scripts/common/helpers/FacetHelper.s.sol";

contract DeployIntrospection is FacetHelper, SimpleDeployer {
  constructor() {
    addSelector(IntrospectionFacet.supportsInterface.selector);
  }

  function initializer() public pure override returns (bytes4) {
    return IntrospectionFacet.__Introspection_init.selector;
  }

  function versionName() public pure override returns (string memory) {
    return "introspectionFacet";
  }

  function __deploy(address deployer) public override returns (address) {
    vm.startBroadcast(deployer);
    IntrospectionFacet facet = new IntrospectionFacet();
    vm.stopBroadcast();
    return address(facet);
  }
}
