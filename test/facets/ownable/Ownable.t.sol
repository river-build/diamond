// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// utils
import {TestUtils} from "test/TestUtils.sol";

//interfaces
import {IERC173, IOwnableBase} from "src/facets/ownable/IERC173.sol";
import {IDiamond} from "src/Diamond.sol";

//libraries

//contracts
import {DeployDiamond} from "scripts/deployments/diamonds/DeployDiamond.s.sol";
import {DeployOwnable} from "scripts/deployments/facets/DeployOwnable.s.sol";
import {OwnableFacet} from "src/facets/ownable/OwnableFacet.sol";

contract OwnableTest is TestUtils, IOwnableBase {
  DeployDiamond diamondHelper = new DeployDiamond();
  DeployOwnable ownableHelper = new DeployOwnable();

  address diamond;
  address deployer;
  address owner;

  IERC173 ownable;

  function setUp() public {
    deployer = getDeployer();

    address ownableFacet = ownableHelper.deploy(deployer);
    diamondHelper.addCut(
      ownableHelper.makeCut(ownableFacet, IDiamond.FacetCutAction.Add)
    );

    diamond = diamondHelper.deploy(deployer);
    ownable = IERC173(diamond);
  }

  function test_revertIfNotOwner() external {
    vm.stopPrank();
    address newOwner = _randomAddress();
    vm.expectRevert(
      abi.encodeWithSelector(Ownable__NotOwner.selector, newOwner)
    );
    vm.prank(newOwner);
    ownable.transferOwnership(newOwner);
  }

  function test_revertIZeroAddress() external {
    vm.prank(deployer);
    vm.expectRevert(Ownable__ZeroAddress.selector);
    ownable.transferOwnership(address(0));
  }

  function test_emitOwnershipTransferred() external {
    address newOwner = _randomAddress();

    vm.prank(deployer);
    vm.expectEmit(true, true, true, true, diamond);
    emit OwnershipTransferred(deployer, newOwner);
    ownable.transferOwnership(newOwner);
  }

  function test_transerOwnership() external {
    address newOwner = _randomAddress();

    vm.prank(deployer);
    ownable.transferOwnership(newOwner);
    assertEq(ownable.owner(), newOwner);
  }

  function test_renounceOwnership() external {
    OwnableV2 ownableV2 = new OwnableV2();
    ownableV2.renounceOwnership();
    assertEq(ownableV2.owner(), address(0));
  }
}

contract OwnableV2 is OwnableFacet {
  function renounceOwnership() external {
    _renounceOwnership();
  }
}
