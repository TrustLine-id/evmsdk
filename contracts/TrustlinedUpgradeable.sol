// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {TrustlinedBase} from "./TrustlinedBase.sol";

/// @title Trustline's Upgradeable Base Contract
/// @author Trustline
/// @notice Upgradeable variant of Trustlined for proxy-based deployments
abstract contract TrustlinedUpgradeable is Initializable, TrustlinedBase {
    /// @dev Initializer for proxy-based deployments.
    /// @param logic The Validation Engine logic contract address for deploying a proxy (used only if proxy is zero)
    /// @param proxy Optional Validation Engine proxy address. If provided (non-zero), it must have been deployed atomically by `Trustlined` (not manually). If `address(0)`, a new proxy is deployed and initialized in the same transaction.
    function __Trustlined_init(address logic, address proxy) internal onlyInitializing {
        __Trustlined_init_unchained(logic, proxy);
    }

    function __Trustlined_init_unchained(address logic, address proxy) internal onlyInitializing {
        _initializeValidationEngine(logic, proxy);
    }

    uint256[49] private __gap;
}
