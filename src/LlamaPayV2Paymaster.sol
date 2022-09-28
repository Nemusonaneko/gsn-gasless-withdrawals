// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "@gsn/packages/contracts/src/BasePaymaster.sol";

interface Factory {
    function whitelists(address, address) external view returns (uint256);

    function ownerOf(uint256) external view returns (address);
}

error NOT_WHITELISTED_OR_OWNER();
error NOT_TARGET();

contract LlamaPayV2Paymaster is BasePaymaster {
    address public immutable target;
    address public immutable factory;

    constructor(address _target, address _factory) {
        target = _target;
        factory = _factory;
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

        address signer = relayRequest.request.from;

        (address payer, uint256 id,) = abi.decode(
            relayRequest.request.data,
            (address, uint256, uint256)
        );

        if (
            Factory(factory).whitelists(payer, signer) != 1 &&
            signer != Factory(factory).ownerOf(id)
        ) revert NOT_WHITELISTED_OR_OWNER();

        return ("", false);
    }

    function _postRelayedCall(
        bytes calldata context,
        bool success,
        uint256 gasUseWithoutPost,
        GsnTypes.RelayData calldata relayData
    ) internal virtual override {
        (context, success, gasUseWithoutPost, relayData);
    }
}
