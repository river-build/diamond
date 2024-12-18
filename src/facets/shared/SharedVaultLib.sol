// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// interfaces

// libraries

// contracts

library SharedVaultLib {
  // keccak256(abi.encode(uint256(keccak256("diamond.facets.shared.vault.storage")) - 1)) & ~bytes32(uint256(0xff))
  bytes32 internal constant STORAGE_SLOT =
    0x11f71b69597bb52e20468f55ded0d7c6e47e777febec9722e739c1f6aad87500;

  enum ProposalState {
    Pending,
    Active,
    Executed,
    Canceled
  }

  struct Proposal {
    uint256 id;
    uint256 deadline;
    address target;
    uint256 value;
    bytes data;
    uint256 confirmations;
    ProposalState state;
  }

  struct Layout {
    uint256 proposalCount;
    uint256 confirmationsRequired;
    mapping(uint256 id => Proposal) proposals;
    mapping(uint256 id => mapping(address => bool)) confirmations;
  }

  function layout() internal pure returns (Layout storage ds) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      ds.slot := slot
    }
  }

  function createProposal(
    uint256 deadline,
    address target,
    uint256 value,
    bytes memory data
  ) internal {
    uint256 id = layout().proposalCount++;
    layout().proposals[id] = Proposal(
      id,
      deadline,
      target,
      value,
      data,
      0,
      ProposalState.Pending
    );
  }

  function confirmProposal(uint256 id, address account) internal {
    Layout storage l = layout();
    Proposal storage proposal = l.proposals[id];
    require(!l.confirmations[id][account], "SharedVault: already confirmed");
    l.confirmations[id][account] = true;
    proposal.confirmations++;

    if (proposal.confirmations >= l.confirmationsRequired) {
      proposal.state = ProposalState.Active;
    }
  }

  function revokeConfirmation(uint256 id, address account) internal {
    Layout storage l = layout();
    Proposal storage proposal = l.proposals[id];
    require(l.confirmations[id][account], "SharedVault: not confirmed");
    l.confirmations[id][account] = false;
    proposal.confirmations--;
  }

  function cancelProposal(uint256 id) internal {
    Proposal storage proposal = layout().proposals[id];
    proposal.state = ProposalState.Canceled;
  }

  function executeProposal(uint256 id) internal {
    Proposal storage proposal = layout().proposals[id];

    require(
      proposal.deadline > block.timestamp,
      "SharedVault: proposal expired"
    );
    require(
      proposal.state == ProposalState.Active,
      "SharedVault: proposal not active"
    );
    (bool success, ) = proposal.target.call{value: proposal.value}(
      proposal.data
    );
    require(success, "SharedVault: proposal execution failed");
    proposal.state = ProposalState.Executed;
  }
}
