// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// utils
import {TestUtils} from "test/TestUtils.sol";

//interfaces

//libraries

//contracts
import {DeployMockERC6909} from "scripts/deployments/mocks/DeployMockERC6909.s.sol";
import {MockERC6909} from "test/mocks/MockERC6909.sol";

contract ERC6909Test is TestUtils {
  DeployMockERC6909 deployMockERC6909Helper = new DeployMockERC6909();
  MockERC6909 facet;

  address deployer;

  function setUp() external {
    deployer = getDeployer();
    facet = MockERC6909(deployMockERC6909Helper.deploy(deployer));
  }

  modifier givenTokensAreMinted(
    address to,
    uint256 tokenId,
    uint256 amount
  ) {
    vm.assume(to != address(0));
    facet.mint(to, tokenId, amount);
    _;
  }

  modifier givenTokensAreBurned(
    address from,
    uint256 tokenId,
    uint256 amount
  ) {
    facet.burn(from, tokenId, amount);
    _;
  }

  modifier givenAccountIsApproved(
    address to,
    address operator,
    uint256 tokenId,
    uint256 amount
  ) {
    vm.assume(to != operator);
    vm.prank(to);
    facet.approve(operator, tokenId, amount);
    _;
  }

  modifier givenOperatorIsSet(
    address to,
    address operator,
    bool approved
  ) {
    vm.prank(to);
    facet.setOperator(operator, approved);
    _;
  }

  function test_totalSupply(
    address to,
    uint256 tokenId,
    uint256 amount
  ) public givenTokensAreMinted(to, tokenId, amount) {
    assertEq(facet.totalSupply(tokenId), amount);
    assertEq(facet.balanceOf(to, tokenId), amount);
  }

  function test_allowance(
    address to,
    address operator,
    uint256 tokenId,
    uint256 amount
  ) public givenAccountIsApproved(to, operator, tokenId, amount) {
    assertEq(facet.allowance(to, operator, tokenId), amount);
  }

  function test_isOperator(
    address to,
    address operator,
    bool approved
  ) public givenOperatorIsSet(to, operator, approved) {
    assertEq(facet.isOperator(to, operator), approved);
  }

  function test_transfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 amount
  ) public givenTokensAreMinted(from, tokenId, amount) {
    vm.assume(from != to);

    vm.prank(from);
    facet.transfer(to, tokenId, amount);
    assertEq(facet.balanceOf(from, tokenId), 0);
    assertEq(facet.balanceOf(to, tokenId), amount);
  }

  function test_burn(
    address from,
    uint256 tokenId,
    uint256 amount
  ) public givenTokensAreMinted(from, tokenId, amount) {
    facet.burn(from, tokenId, amount);
    assertEq(facet.balanceOf(from, tokenId), 0);
  }
}
