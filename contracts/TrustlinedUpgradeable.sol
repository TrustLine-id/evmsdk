// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {EIP7702Utils} from "@openzeppelin/contracts/account/utils/EIP7702Utils.sol";
import {IAccessControlDefaultAdminRules} from "@openzeppelin/contracts/access/extensions/IAccessControlDefaultAdminRules.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IValidationEngine} from "./interfaces/IValidationEngine.sol";
import {IValidationEngineInitializer} from "./interfaces/IValidationEngineInitializer.sol";

/// @title Trustline's Upgradeable Base Contract
/// @author Trustline
/// @notice Upgradeable variant of Trustlined for proxy-based deployments
/// @dev Validation Engine proxies must not be deployed manually. Use the auto-deploy path (logic + zero proxy)
///      so the ERC1967 proxy is created and `initialize` runs atomically, or reuse a proxy previously deployed that way.
/// @dev Integration requires direct inheritance into a contract that owns its storage layout. Not supported
///      in Diamond facets, delegatecall routers, or other hosts with foreign storage. When combining with
///      other bases (e.g. ERC20), keep inheritance order stable across upgrades.
abstract contract TrustlinedUpgradeable is Initializable {
    /// @notice Emitted when a new Validation Engine proxy is deployed for this client contract.
    /// @dev `client` is the address of the integrating contract (i.e., the contract inheriting from TrustlinedUpgradeable).
    /// @dev `engineProxy` is the freshly deployed ERC1967 proxy address for the Validation Engine instance.
    /// @dev Index this event to obtain the per-chain proxy address — it is not deterministic across chains (CREATE, not CREATE2).
    /// @dev `logic` is the Validation Engine implementation (logic) contract the proxy points to at deployment time.
    /// @dev `initialOwner` is the address passed to the engine's `initialize(address)` call (typically the deployer/initializer).
    event ValidationEngineDeployed(
        address indexed client,
        address indexed engineProxy,
        address indexed logic,
        address initialOwner
    );

    /// @notice Emitted when an existing Validation Engine proxy is adopted by this client contract.
    /// @dev `client` is the address of the integrating contract (i.e., the contract inheriting from TrustlinedUpgradeable).
    /// @dev `engineProxy` is the Validation Engine proxy address being reused.
    event ValidationEngineAdopted(
        address indexed client,
        address indexed engineProxy
    );

    /// @notice The Trustline ValidationEngine contract address. It must be set before any of the provided functions can be used
    /// @dev Multiple dapps can share the same ValidationEngine contract
    /// @dev This contract is set by the owner and must implement the IValidationEngine interface
    /// @dev Slot is assigned by Solidity inheritance layout; see contract-level integration constraints.
    IValidationEngine public validationEngine;

    /// @dev Initializer for proxy-based deployments.
    /// @param logic The Validation Engine logic contract address for deploying a proxy (used only if proxy is zero)
    /// @param proxy Optional Validation Engine proxy address. If provided (non-zero), it must have been deployed atomically by `Trustlined` (not manually). If `address(0)`, a new proxy is deployed and initialized in the same transaction.
    function __Trustlined_init(address logic, address proxy) internal onlyInitializing {
        __Trustlined_init_unchained(logic, proxy);
    }

    function __Trustlined_init_unchained(address logic, address proxy) internal onlyInitializing {
        require(address(validationEngine) == address(0), "Already initialized");

        if (proxy != address(0)) {
            // Use the provided Validation Engine proxy
            _assertContractAccount(proxy);
            _assertValidationEngine(proxy);
            require(
                IAccessControlDefaultAdminRules(proxy).defaultAdmin() == msg.sender,
                "Invalid validation engine admin"
            );
            validationEngine = IValidationEngine(proxy);

            emit ValidationEngineAdopted(address(this), proxy);
        } else {
            // Deploy a new Validation Engine proxy and initialize it atomically (never deploy manually).
            // Proxy address uses CREATE and is chain-/nonce-dependent — not reproducible cross-chain.
            _assertContractAccount(logic);

            address initialOwner = msg.sender;

            bytes memory data = abi.encodeCall(IValidationEngineInitializer.initialize, (initialOwner));
            address proxy_ = address(new ERC1967Proxy(logic, data));

            _assertValidationEngine(proxy_);
            validationEngine = IValidationEngine(proxy_);

            emit ValidationEngineDeployed(address(this), proxy_, logic, initialOwner);
        }
    }

    /// @notice Checks whether a transaction is trusted and verifies msg.sender + addresses[] against sanctions lists
    /// @dev Does not enforce compliance. Use `requireTrustline(...)` to enforce.
    /// @param addresses An array of addresses that will be verified by the policy
    function checkTrustlineStatus(address[] memory addresses) internal view returns (bool) {
        return validationEngine.checkTrustlineStatus(msg.sender, msg.value, msg.data, addresses);
    }

    /// @notice Checks whether a transaction is trusted and verifies msg.sender against sanctions lists
    /// @dev Does not enforce compliance. Use `requireTrustline(...)` to enforce.
    function checkTrustlineStatus() internal view returns (bool) {
        return validationEngine.checkTrustlineStatus(msg.sender, msg.value, msg.data);
    }

    /// @notice Requires a trusted transaction and non-sanctioned msg.sender + addresses[]
    /// @param addresses An array of addresses that will be verified by the policy
    function requireTrustline(address[] memory addresses) internal {
        validationEngine.requireTrustline(msg.sender, msg.value, msg.data, addresses);
    }

    /// @notice Requires a trusted transaction and a non-sanctioned msg.sender
    function requireTrustline() internal {
        validationEngine.requireTrustline(msg.sender, msg.value, msg.data);
    }

    /// @dev Ensures `target` is a genuine contract account, not an empty EOA or an EIP-7702 delegated EOA.
    /// @dev EIP-7702 accounts expose a 23-byte designator (`0xef0100 || delegate`) in `extcode`; reject those.
    function _assertContractAccount(address target) private view {
        require(target.code.length > 0, "Not a contract");
        require(EIP7702Utils.fetchDelegate(target) == address(0), "Delegated EOA not allowed");
    }

    /// @dev Runtime conformance check via EIP-165 to ensure the candidate advertises IValidationEngine.
    /// @dev This does not cryptographically attest Trustline provenance, but prevents accidental misconfiguration.
    function _assertValidationEngine(address candidate) private view {
        require(
            IERC165(candidate).supportsInterface(type(IValidationEngine).interfaceId),
            "Invalid validation engine"
        );
    }

    uint256[49] private __gap;
}
