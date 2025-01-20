// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// interfaces
import {IERC20PermitBase} from "./IERC20PermitBase.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

// libraries

import {ERC20Lib, MinimalERC20Storage} from "src/primitive/ERC20.sol";

// contracts
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Nonces} from "../../../../utils/Nonces.sol";
import {EIP712} from "../../../../utils/cryptography/EIP712.sol";
import {ERC20} from "../ERC20.sol";

abstract contract ERC20PermitBase is IERC20PermitBase, ERC20, EIP712, Nonces {
  using ERC20Lib for MinimalERC20Storage;

  function __ERC20PermitBase_init(
    string memory name_,
    string memory symbol_,
    uint8 decimals_
  ) external onlyInitializing {
    __ERC20_init_unchained(name_, symbol_, decimals_);
    __ERC20PermitBase_init_unchained(name_);
  }

  function __ERC20PermitBase_init_unchained(string memory name_) internal {
    __EIP712_init_unchained(name_, "1");
  }

  /// @dev `keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")`.
  bytes32 private constant _PERMIT_TYPEHASH =
    0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

  /// @inheritdoc IERC20Permit
  function nonces(address owner) external view returns (uint256 result) {
    return _latestNonce(owner);
  }

  /// @inheritdoc IERC20Permit
  function permit(
    address owner,
    address spender,
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external {
    require(block.timestamp <= deadline, "ERC20Permit: expired deadline");
    bytes32 structHash = keccak256(
      abi.encode(
        _PERMIT_TYPEHASH,
        owner,
        spender,
        amount,
        _useNonce(owner),
        deadline
      )
    );

    bytes32 hash = _hashTypedDataV4(structHash);

    address signer = ECDSA.recover(hash, v, r, s);
    require(signer == owner, "ERC20Permit: invalid signature");
    approve(spender, amount);
  }

  /// @inheritdoc IERC20Permit
  function DOMAIN_SEPARATOR() external view returns (bytes32 result) {
    return _domainSeparatorV4();
  }
}
