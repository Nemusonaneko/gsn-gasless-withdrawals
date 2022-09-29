// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "@gsn/packages/contracts/src/ERC2771Recipient.sol";
import "@gsn/packages/contracts/src/forwarder/Forwarder.sol";

interface Payer {
    function withdraw(uint256, uint256) external;
}

error NOT_WHITELISTED_OR_OWNER();

contract LlamaPayV2GaslessWithdrawals is ERC2771Recipient {
    event GaslessWithdraw(
        address caller,
        address payer,
        uint256 id,
        uint256 amount
    );

    constructor(address _forwarder) {
        ERC2771Recipient(_forwarder);
    }

    function executeWithdrawal(
        address _payer,
        uint256 _id,
        uint256 _amount
    ) external {
        Payer(_payer).withdraw(_id, _amount);

        emit GaslessWithdraw(_msgSender(), _payer, _id, _amount);
    }
}
