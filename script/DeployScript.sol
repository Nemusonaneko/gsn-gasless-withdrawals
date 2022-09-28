// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/LlamaPayV2GaslessWithdrawals.sol";
import "../src/LlamaPayV2Paymaster.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        LlamaPayV2GaslessWithdrawals gaslessWithdrawals = new LlamaPayV2GaslessWithdrawals{
                salt: bytes32("llamao")
            }(0x7A95fA73250dc53556d264522150A940d4C50238);
        LlamaPayV2Paymaster paymaster = new LlamaPayV2Paymaster{
            salt: bytes32("llamao")
        }(
            address(gaslessWithdrawals),
            0x620371D31CC53aa09A91e47A9091BAf5A56DA8d9
        );

        vm.stopBroadcast();
    }
}
