// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// interfaces

// libraries

// contracts
import {TestUtils} from "test/TestUtils.sol";
import {Initializable} from "src/facets/initializable/Initializable.sol";

contract Mock is Initializable {
  uint256 public value;

  function init() external initializer {
    value = 1;
  }

  function reinit() external reinitializer(2) {}

  function getVersion() external view returns (uint32) {
    return _getInitializedVersion();
  }
}

contract InitializableTest is TestUtils {
  address internal deployer;
  Mock internal initializable;

  function setUp() public {
    deployer = _randomAddress();

    vm.startPrank(deployer);
    initializable = new Mock();
  }

  function test_initializer() external {
    initializable.init();
    assertEq(initializable.value(), 1);
    assertEq(initializable.getVersion(), 1);
  }

  function test_reinitializer() external {
    initializable.reinit();
    assertEq(initializable.getVersion(), 2);
  }
}
