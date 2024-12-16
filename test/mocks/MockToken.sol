// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// interfaces

// libraries

// contracts
import {MockERC721} from "forge-std/mocks/MockERC721.sol";

contract MockToken is MockERC721 {
  uint256 public tokenId;

  constructor() {
    initialize("MockToken", "MTK");
  }

  function mintTo(address to) external returns (uint256) {
    tokenId++;
    _mint(to, tokenId);
    return tokenId;
  }

  function mint(address to, uint256 amount) external {
    for (uint256 i = 0; i < amount; i++) {
      _mint(to, tokenId);
      tokenId++;
    }
  }

  function burn(uint256 token) external {
    _burn(token);
  }
}
