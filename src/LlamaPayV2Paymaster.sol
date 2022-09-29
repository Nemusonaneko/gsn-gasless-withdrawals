// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "@gsn/packages/contracts/src/BasePaymaster.sol";

error NOT_TARGET();
error NOT_ENOUGH_BALANCE();

contract LlamaPayV2Paymaster is BasePaymaster {
    address public immutable target;
    address public currentPayer;

    mapping(address => uint256) balances;

    constructor(address _target) {
        target = _target;
    }

    function versionPaymaster()
        external
        view
        virtual
        override
        returns (string memory)
    {
        return "3.0.0-beta.2+opengsn";
    }

    function _preRelayedCall(
        GsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    )
        internal
        virtual
        override
        returns (bytes memory context, bool revertOnRecipientRevert)
    {
        if (relayRequest.request.to != target) revert NOT_TARGET();

        (address payer, , ) = abi.decode(
            relayRequest.request.data,
            (address, uint256, uint256)
        );

        if (maxPossibleGas > balances[payer]) revert NOT_ENOUGH_BALANCE();
        currentPayer = payer;
        (signature, approvalData);
        return ("", false);
    }

    function _postRelayedCall(
        bytes calldata context,
        bool success,
        uint256 gasUseWithoutPost,
        GsnTypes.RelayData calldata relayData
    ) internal virtual override {
        balances[currentPayer] -= gasUseWithoutPost;
        (context, success, relayData);
    }

    function deposit() public payable {
        relayHub.depositFor{value: msg.value}(address(this));
        balances[msg.sender] += msg.value;
    }

    function refund() public {
        uint256 toRefund = balances[msg.sender];
        balances[msg.sender] = 0;
        withdrawRelayHubDepositTo(toRefund, payable(msg.sender));
    }
}
