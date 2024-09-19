// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "src/Kernel.sol";
import "forge-std/console.sol";

contract DeployProxy is Script {


uint256 deployer = vm.envUint("OWNER");


    function run() external {
        console.log("******** Deploying *********");

        vm.startBroadcast(deployer);
        bytes memory bytecode = hex"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03601600081602082378035828234f58015156039578182fd5b8082525050506014600cf3";

        address addr;
        
        assembly {
            // Allocate memory for the bytecode and deploy the contract
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(addr != address(0), "Deployment failed");

        console.log("CREATE2_PROXY : ", addr);

        vm.stopBroadcast();
    }
}