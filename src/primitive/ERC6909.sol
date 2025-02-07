// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// interfaces
import {IERC6909} from "../facets/token/ERC6909/IERC6909.sol";

using ERC6909Lib for MinimalERC6909Storage global;

/// @notice Minimal storage layout for an ERC6909 token
/// @dev Do not modify the layout of this struct especially if it's nested in another struct
/// or used in a linear storage layout
struct MinimalERC6909Storage {
  // Mapping from (owner, id) to balance
  mapping(address => mapping(uint256 => uint256)) balances;
  // Mapping from (owner, spender, id) to allowance
  mapping(address => mapping(address => mapping(uint256 => uint256))) allowances;
  // Mapping from owner to operator approvals
  mapping(address => mapping(address => bool)) operatorApprovals;
  // Mapping from token id to total supply
  mapping(uint256 => uint256) supply;
}

/// @notice Library implementing ERC6909 logic with flexible storage slot
library ERC6909Lib {
  // Custom errors
  error InsufficientBalance();
  error InsufficientPermission();
  error BalanceOverflow();

  function totalSupply(
    MinimalERC6909Storage storage self,
    uint256 id
  ) internal view returns (uint256) {
    return self.supply[id];
  }

  function balanceOf(
    MinimalERC6909Storage storage self,
    address owner,
    uint256 id
  ) internal view returns (uint256) {
    return self.balances[owner][id];
  }

  function allowance(
    MinimalERC6909Storage storage self,
    address owner,
    address spender,
    uint256 id
  ) internal view returns (uint256) {
    return self.allowances[owner][spender][id];
  }

  function isOperator(
    MinimalERC6909Storage storage self,
    address owner,
    address spender
  ) internal view returns (bool) {
    return self.operatorApprovals[owner][spender];
  }

  function transfer(
    MinimalERC6909Storage storage self,
    address to,
    uint256 id,
    uint256 amount
  ) internal returns (bool) {
    _transfer(self, msg.sender, to, id, amount);
    return true;
  }

  function transferFrom(
    MinimalERC6909Storage storage self,
    address from,
    address to,
    uint256 id,
    uint256 amount
  ) internal returns (bool) {
    if (!isOperator(self, from, msg.sender)) {
      uint256 currentAllowance = allowance(self, from, msg.sender, id);
      if (currentAllowance != type(uint256).max) {
        if (currentAllowance < amount) {
          revert InsufficientPermission();
        }
        _approve(self, from, msg.sender, id, currentAllowance - amount);
      }
    }
    _transfer(self, from, to, id, amount);
    return true;
  }

  function approve(
    MinimalERC6909Storage storage self,
    address spender,
    uint256 id,
    uint256 amount
  ) internal returns (bool) {
    _approve(self, msg.sender, spender, id, amount);
    return true;
  }

  function setOperator(
    MinimalERC6909Storage storage self,
    address operator,
    bool approved
  ) internal returns (bool) {
    self.operatorApprovals[msg.sender][operator] = approved;
    emit IERC6909.OperatorSet(msg.sender, operator, approved);
    return true;
  }

  // Internal functions
  function mint(
    MinimalERC6909Storage storage self,
    address to,
    uint256 id,
    uint256 amount
  ) internal {
    if (amount > 0) {
      uint256 toBalanceBefore = self.balances[to][id];
      uint256 toBalanceAfter = toBalanceBefore + amount;
      if (toBalanceAfter < toBalanceBefore) revert BalanceOverflow();

      self.supply[id] += amount;
      self.balances[to][id] = toBalanceAfter;
      emit IERC6909.Transfer(msg.sender, address(0), to, id, amount);
    }
  }

  function burn(
    MinimalERC6909Storage storage self,
    address from,
    uint256 id,
    uint256 amount
  ) internal {
    if (amount > 0) {
      uint256 fromBalance = self.balances[from][id];
      if (fromBalance < amount) revert InsufficientBalance();

      unchecked {
        self.balances[from][id] = fromBalance - amount;
        self.supply[id] -= amount;
      }
      emit IERC6909.Transfer(msg.sender, from, address(0), id, amount);
    }
  }

  function _transfer(
    MinimalERC6909Storage storage self,
    address from,
    address to,
    uint256 id,
    uint256 amount
  ) private {
    if (amount > 0) {
      uint256 fromBalance = self.balances[from][id];
      if (fromBalance < amount) revert InsufficientBalance();

      unchecked {
        self.balances[from][id] = fromBalance - amount;
      }

      uint256 toBalanceBefore = self.balances[to][id];
      uint256 toBalanceAfter = toBalanceBefore + amount;
      if (toBalanceAfter < toBalanceBefore) revert BalanceOverflow();

      self.balances[to][id] = toBalanceAfter;
      emit IERC6909.Transfer(msg.sender, from, to, id, amount);
    }
  }

  function _approve(
    MinimalERC6909Storage storage self,
    address owner,
    address spender,
    uint256 id,
    uint256 amount
  ) private {
    self.allowances[owner][spender][id] = amount;
    emit IERC6909.Approval(owner, spender, id, amount);
  }
}
