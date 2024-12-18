// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// interfaces

// libraries

// contracts
import {SimpleDeployer} from "scripts/common/deployers/SimpleDeployer.s.sol";
import {FacetHelper} from "scripts/common/helpers/FacetHelper.s.sol";
import {MockERC20Permit} from "test/mocks/MockERC20Permit.sol";
import {ERC20} from "src/facets/token/ERC20/ERC20.sol";

contract DeployMockERC20Permit is SimpleDeployer, FacetHelper {
  constructor() {
    // ERC20
    addSelector(ERC20.totalSupply.selector);
    addSelector(ERC20.balanceOf.selector);
    addSelector(ERC20.allowance.selector);
    addSelector(ERC20.approve.selector);
    addSelector(ERC20.transfer.selector);
    addSelector(ERC20.transferFrom.selector);
    addSelector(MockERC20Permit.mint.selector);
    // Metadata
    addSelector(ERC20.name.selector);
    addSelector(ERC20.symbol.selector);
    addSelector(ERC20.decimals.selector);

    // Permit
    addSelector(ERC20.nonces.selector);
    addSelector(ERC20.permit.selector);
    addSelector(ERC20.DOMAIN_SEPARATOR.selector);
  }

  function versionName() public pure override returns (string memory) {
    return "mockERC20Permit";
  }

  function initializer() public pure override returns (bytes4) {
    return ERC20.__ERC20_init.selector;
  }

  function makeInitData(
    string memory name,
    string memory symbol,
    uint8 decimals
  ) public pure returns (bytes memory) {
    return abi.encodeWithSelector(initializer(), name, symbol, decimals);
  }

  function __deploy(address deployer) public override returns (address) {
    vm.startBroadcast(deployer);
    MockERC20Permit facet = new MockERC20Permit();
    vm.stopBroadcast();
    return address(facet);
  }
}
