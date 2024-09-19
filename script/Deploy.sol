// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "src/Kernel.sol";
import "forge-std/console.sol";

import "src/Kernel.sol";
import "src/factory/FactoryStaker.sol";
import "src/factory/KernelFactory.sol";

contract DeployKernel is Script  {
    address public entryPointAddr = vm.envAddress("ENTRYPOINT");
    address constant CREATE2_PROXY = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
    uint256 deployer = vm.envUint("OWNER");
    address public factoryOwner = vm.envAddress("FACTORY_OWNER");

    function run () external {
        console.log("******** Deploying *********");

        vm.startBroadcast(deployer);
        Kernel kernel = new Kernel{salt: 0}(IEntryPoint(entryPointAddr));
        console.log("Kernel : ", address(kernel));
        KernelFactory factory = new KernelFactory{salt: 0}(address(kernel));
        console.log("KernelFactory : ", address(factory));
        /* FactoryStaker staker = FactoryStaker(CREATE2_PROXY);
        if (!staker.approved(factory)) {
            staker.approveFactory(factory, true);
            console.log("Approved");
        } */

        FactoryStaker staker = new FactoryStaker{salt:0}(factoryOwner);
        if(!staker.approved(factory)) {
            staker.approveFactory(factory, true);
            console.log("Approved");
        }

        console.log("FactoryStaker : ", address(staker));

        IEntryPoint entryPoint = IEntryPoint(entryPointAddr);
        IStakeManager.DepositInfo memory info = entryPoint.getDepositInfo(address(staker));
        if (info.stake < 1e17) {
            staker.stake{value: 1e17 - info.stake}(IEntryPoint(entryPointAddr), 86400);
        }

        console.log("******** Deployed *********");
        vm.stopBroadcast();
    }
}


/**
  ******** Deploying *********
  Kernel :  0xB818d789C8299f34F82483FdE88aB8b4B02339D5
  KernelFactory :  0x0f3Cb61bf683cacf692A1B03537c398824d25c92
  Approved
  FactoryStaker :  0xD3c2DA55129399f39C1c78b6F0267BB9Cd35ee65
  ******** Deployed *********
 */