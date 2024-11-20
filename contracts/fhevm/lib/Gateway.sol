// SPDX-License-Identifier: BSD-3-Clause-Clear

pragma solidity ^0.8.24;

import "./GatewayContract.sol";
import "./ACL.sol";
import "./KMSVerifier.sol";

GatewayContract constant gatewayContract = GatewayContract(0xAF25431c071461311aD227b1f2c6eBBD380768A6); // Replace by GatewayContract address
ACL constant acl = ACL(0x4B0B495995C31857096e8B41837bE23A8895A37C); // Replace by ACL address
KMSVerifier constant kmsVerifier = KMSVerifier(address(0xF4EAb004dD14CbF30115629C43C5Be92B0b90831));

library Gateway {
    function GatewayContractAddress() internal pure returns (address) {
        return address(gatewayContract);
    }

    function toUint256(ebool newCT) internal pure returns (uint256 ct) {
        ct = ebool.unwrap(newCT);
    }

    function toUint256(euint4 newCT) internal pure returns (uint256 ct) {
        ct = euint4.unwrap(newCT);
    }

    function toUint256(euint8 newCT) internal pure returns (uint256 ct) {
        ct = euint8.unwrap(newCT);
    }

    function toUint256(euint16 newCT) internal pure returns (uint256 ct) {
        ct = euint16.unwrap(newCT);
    }

    function toUint256(euint32 newCT) internal pure returns (uint256 ct) {
        ct = euint32.unwrap(newCT);
    }

    function toUint256(euint64 newCT) internal pure returns (uint256 ct) {
        ct = euint64.unwrap(newCT);
    }

    function toUint256(eaddress newCT) internal pure returns (uint256 ct) {
        ct = eaddress.unwrap(newCT);
    }

    function toUint256(ebytes256 newCT) internal pure returns (uint256 ct) {
        ct = ebytes256.unwrap(newCT);
    }

    function requestDecryption(
        uint256[] memory ctsHandles,
        bytes4 callbackSelector,
        uint256 msgValue,
        uint256 maxTimestamp,
        bool passSignaturesToCaller
    ) internal returns (uint256 requestID) {
        acl.allowForDecryption(ctsHandles);
        requestID = gatewayContract.requestDecryption(
            ctsHandles,
            callbackSelector,
            msgValue,
            maxTimestamp,
            passSignaturesToCaller
        );
    }

    /// @dev this function is supposed to be called inside the callback function if the dev wants the dApp contract to verify the signatures
    /// @dev this is useful to give dev the choice not to rely on trusting the GatewayContract.
    /// @notice this could be used only when signatures are made available to the callback, i.e when `passSignaturesToCaller` is set to true during request
    function verifySignatures(uint256[] memory handlesList, bytes[] memory signatures) internal returns (bool) {
        uint256 start = 4 + 32; // start position after skipping the selector (4 bytes) and the first argument (index, 32 bytes)
        uint256 numArgs = handlesList.length; // Number of arguments before signatures
        uint256 length = numArgs * 32; // TODO: fix the way we compute length in case the type of the handle is an ebytes256 (loop over all handles and add correct length corresponding to each type)
        bytes memory decryptedResult = new bytes(length);
        assembly {
            calldatacopy(add(decryptedResult, 0x20), start, length) // Copy the relevant part of calldata to decryptedResult memory
        }
        return kmsVerifier.verifySignatures(handlesList, decryptedResult, signatures);
    }
}