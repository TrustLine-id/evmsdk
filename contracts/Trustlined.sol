// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {TrustlinedBase} from "./TrustlinedBase.sol";

/// @title Trustline's Base Contract
/// @author Trustline
/// @notice Non-upgradeable integration base for Trustline validation
abstract contract Trustlined is TrustlinedBase {
    /// @dev Constructor-only initialization for non-upgradeable deployment scenarios.
    /// @param trustlineValidationEngineLogic The Validation Engine logic contract address for deploying a proxy (used only if trustlineValidationEngineProxy is zero)
    /// @param trustlineValidationEngineProxy Optional Validation Engine proxy address. If provided (non-zero), it must have been deployed atomically by `Trustlined` (not manually). If `address(0)`, a new proxy is deployed and initialized in the same transaction.
    constructor(address trustlineValidationEngineLogic, address trustlineValidationEngineProxy) {
        _initializeValidationEngine(trustlineValidationEngineLogic, trustlineValidationEngineProxy);
    }
}
