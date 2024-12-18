// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// interfaces

// libraries
import {ERC20Storage} from "src/facets/token/ERC20/ERC20Storage.sol";

// contracts
import {ERC20} from "src/facets/token/ERC20/ERC20.sol";

contract MockERC20Permit is ERC20 {
  function mint(address to, uint256 amount) external {
    ERC20Storage.layout().inner.mint(to, amount);
  }
}
