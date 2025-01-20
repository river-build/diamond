// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

using OwnersMapLib for OwnersMap;

struct OwnersMap {
  mapping(uint256 => address) data;
}

library OwnersMapLib {
  function slot(
    OwnersMap storage self,
    uint256 tokenId
  ) internal pure returns (uint256 _slot) {
    assembly ("memory-safe") {
      mstore(0x00, tokenId)
      mstore(0x20, self.slot)
      _slot := keccak256(0x00, 0x40)
    }
  }

  function get(
    OwnersMap storage self,
    uint256 tokenId
  ) internal view returns (address owner) {
    uint256 _slot = self.slot(tokenId);
    assembly ("memory-safe") {
      owner := sload(_slot)
    }
  }

  function set(
    OwnersMap storage self,
    uint256 tokenId,
    address owner
  ) internal {
    uint256 _slot = self.slot(tokenId);
    assembly ("memory-safe") {
      sstore(_slot, owner)
    }
  }
}
