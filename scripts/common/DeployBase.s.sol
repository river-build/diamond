// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// interfaces

// libraries

// contracts
import {Script} from "forge-std/Script.sol";
import {DeployHelpers} from "./DeployHelpers.s.sol";

abstract contract DeployBase is Script, DeployHelpers {
  string internal DEPLOYMENT_CACHE_PATH;

  constructor() {
    setChain(
      "river",
      ChainData({
        name: "river",
        chainId: 550,
        rpcUrl: "https://mainnet.rpc.river.build/http"
      })
    );
    setChain(
      "river_anvil",
      ChainData({
        name: "river_anvil",
        chainId: 31338,
        rpcUrl: "http://localhost:8546"
      })
    );
    setChain(
      "river_devnet",
      ChainData({
        name: "river_devnet",
        chainId: 6524490,
        rpcUrl: "https://devnet.rpc.river.build"
      })
    );
    setChain(
      "base_sepolia",
      ChainData({
        name: "base_sepolia",
        chainId: 84532,
        rpcUrl: "https://sepolia.base.org"
      })
    );
  }

  // override this with the name of the deployment version that this script deploys
  function versionName() public view virtual returns (string memory);

  // override this with the actual deployment logic, no need to worry about:
  // - existing deployments
  // - loading private keys
  // - saving deployments
  // - logging
  function __deploy(address deployer) public virtual returns (address);

  // will first try to load existing deployments from `deployments/<network>/<contract>.json`
  // if OVERRIDE_DEPLOYMENTS is set to true or if no cached deployment is found:
  // - read PRIVATE_KEY from env
  // - invoke __deploy() with the private key
  // - save the deployment to `deployments/<network>/<contract>.json`
  function deploy() public virtual returns (address deployedAddr) {
    return deploy(_msgSender());
  }

  function deploy(
    address deployer
  ) public virtual returns (address deployedAddr) {
    bool overrideDeployment = vm.envOr("OVERRIDE_DEPLOYMENTS", uint256(0)) > 0;

    address existingAddr = isTesting()
      ? address(0)
      : getDeployment(versionName());

    if (!overrideDeployment && existingAddr != address(0)) {
      info(
        string.concat(
          unicode"📝 using an existing address for ",
          versionName(),
          " at"
        ),
        vm.toString(existingAddr)
      );
      return existingAddr;
    }

    if (!isTesting()) {
      info(
        string.concat(
          unicode"deploying \n\t📜 ",
          versionName(),
          unicode"\n\t⚡️ on ",
          chainIdAlias(),
          unicode"\n\t📬 from deployer address"
        ),
        vm.toString(deployer)
      );
    }

    // call __deploy hook
    deployedAddr = __deploy(deployer);

    if (!isTesting()) {
      info(
        string.concat(unicode"✅ ", versionName(), " deployed at"),
        vm.toString(deployedAddr)
      );

      if (deployedAddr != address(0)) {
        saveDeployment(versionName(), deployedAddr);
      }
    }

    if (!isTesting()) postDeploy(deployer, deployedAddr);
  }

  function postDeploy(address deployer, address deployment) public virtual {}

  function run() public virtual {
    bytes memory data = abi.encodeWithSignature("deploy()");

    // we use a dynamic call to call deploy as we do not want to prescribe a return type
    (bool success, bytes memory returnData) = address(this).delegatecall(data);
    if (!success) {
      if (returnData.length > 0) {
        /// @solidity memory-safe-assembly
        assembly {
          let returnDataSize := mload(returnData)
          revert(add(32, returnData), returnDataSize)
        }
      } else {
        revert("FAILED_TO_CALL: deploy()");
      }
    }
  }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  // =============================================================
  //                      DEPLOYMENT HELPERS
  // =============================================================

  /// @notice returns the chain alias for the current chain
  function chainIdAlias() internal virtual returns (string memory) {
    string memory chainAlias = getChain(block.chainid).chainAlias;
    return getInitialStringFromUnderscore(chainAlias);
  }

  function networkDirPath() internal returns (string memory path) {
    string memory context = vm.envOr("DEPLOYMENT_CONTEXT", string(""));
    string memory cache_path = vm.envOr("DEPLOYMENT_CACHE_PATH", string(""));

    require(bytes(cache_path).length > 0, "DEPLOYMENT_CACHE_PATH is not set");

    // if no context is provided, use the default path
    if (bytes(context).length == 0) {
      context = string.concat(DEPLOYMENT_CACHE_PATH, "/", chainIdAlias());
    } else {
      context = string.concat(
        DEPLOYMENT_CACHE_PATH,
        "/",
        context,
        "/",
        chainIdAlias()
      );
    }

    path = string.concat(vm.projectRoot(), "/", context);
  }

  function addressesPath(
    string memory contractName
  ) internal returns (string memory path) {
    path = string.concat(
      networkDirPath(),
      "/",
      "addresses",
      "/",
      contractName,
      ".json"
    );
  }

  function getDeployment(
    string memory deploymentName
  ) internal returns (address) {
    string memory path = addressesPath(deploymentName);

    if (!exists(path)) {
      debug(
        string.concat(
          "no deployment found for ",
          deploymentName,
          " on ",
          chainIdAlias()
        )
      );
      return address(0);
    }

    string memory data = vm.readFile(path);
    return vm.parseJsonAddress(data, ".address");
  }

  function saveDeployment(
    string memory deploymentName,
    address contractAddr
  ) internal {
    if (vm.envOr("SAVE_DEPLOYMENTS", uint256(0)) == 0) {
      debug("(set SAVE_DEPLOYMENTS=1 to save deployments to file)");
      return;
    }

    // create addresses directory
    createDir(string.concat(networkDirPath(), "/", "addresses"));
    createChainIdFile(networkDirPath());

    // get deployment path
    string memory path = addressesPath(deploymentName);

    // save deployment
    string memory contractJson = vm.serializeAddress(
      "addresses",
      "address",
      contractAddr
    );
    debug("saving deployment to: ", path);
    vm.writeJson(contractJson, path);
  }

  function isAnvil() internal view returns (bool) {
    return block.chainid == 31337 || block.chainid == 31338;
  }

  function isRiver() internal view returns (bool) {
    return block.chainid == 6524490;
  }

  // Utils
  function createChainIdFile(string memory networkDir) internal {
    string memory chainIdFilePath = string.concat(
      networkDir,
      "/",
      "chainId.json"
    );

    if (!exists(chainIdFilePath)) {
      debug("creating chain id file: ", chainIdFilePath);
      string memory jsonStr = vm.serializeUint("chainIds", "id", block.chainid);
      vm.writeJson(jsonStr, chainIdFilePath);
    }
  }

  function getInitialStringFromUnderscore(
    string memory fullString
  ) internal pure returns (string memory) {
    bytes memory fullStringBytes = bytes(fullString);
    uint256 underscoreIndex = 0;

    for (uint256 i = 0; i < fullStringBytes.length; i++) {
      if (fullStringBytes[i] == "_") {
        underscoreIndex = i;
        break;
      }
    }

    if (underscoreIndex == 0) {
      return fullString;
    }

    bytes memory result = new bytes(underscoreIndex);
    for (uint256 i = 0; i < underscoreIndex; i++) {
      result[i] = fullStringBytes[i];
    }

    return string(result);
  }
}
