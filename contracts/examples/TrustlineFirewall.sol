// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

//import {Trustlined} from "@trustline.id/evmsdk/contracts/Trustlined.sol";
import {Trustlined} from "../Trustlined.sol";

/// @title TrustlineFirewall
/// @notice Generic intermediary that forwards every call to a fixed target contract after Trustline validation.
///         Uses regular call (not delegatecall), so the target runs in its own context and sees msg.sender as this firewall.
/// @dev Deploy with the contract to protect as target and Trustline Validation Engine (logic and/or proxy).
///      Configure the target so that privileged actions are allowed only from this firewall (e.g. set this firewall
///      as owner/curator/allocator).
///
///      Access model:
///      - `owner` (single address): admin only — setTarget, setOwner, setOperator, setPublicForward.
///      - `isOperator`: addresses allowed to use the protected forward path (fallback / receive).
///      - `publicForward`: when true, anyone may use the protected forward path (still Trustline-gated).
///
///      Any call (including value) is validated with requireTrustline() then forwarded as:
///      target.call{value: msg.value}(msg.data). Return data and reverts are propagated to the original caller.
contract TrustlineFirewall is Trustlined {
    error Unauthorized();

    /// @notice The contract all calls are forwarded to.
    address public target;

    /// @notice Admin address; sole role that can configure the firewall.
    address public owner;

    /// @notice When true, fallback/receive are callable by any address (after Trustline validation).
    bool public publicForward;

    /// @notice Addresses allowed to use the protected forward path when `publicForward` is false.
    mapping(address account => bool) public isOperator;

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier onlyOperator() {
        if (!publicForward && !isOperator[msg.sender]) revert Unauthorized();
        _;
    }

    /// @param _target Contract to protect; all calls are forwarded here.
    /// @param trustlineValidationEngineLogic Validation Engine logic (used if proxy is zero to deploy a new proxy).
    /// @param trustlineValidationEngineProxy Validation Engine proxy; if non-zero, used directly.
    /// @param initialOwner Admin of the firewall; cannot be zero.
    /// @param initialOperator Optional first operator; zero to skip.
    /// @param initialPublicForward Initial value for `publicForward`.
    constructor(
        address _target,
        address trustlineValidationEngineLogic,
        address trustlineValidationEngineProxy,
        address initialOwner,
        address initialOperator,
        bool initialPublicForward
    ) Trustlined(trustlineValidationEngineLogic, trustlineValidationEngineProxy) {
        require(_target != address(0), "target zero");
        require(initialOwner != address(0), "owner zero");
        target = _target;
        owner = initialOwner;
        publicForward = initialPublicForward;
        if (initialOperator != address(0)) isOperator[initialOperator] = true;
    }

    // ---------- Admin (owner only, Trustline-protected) ----------

    /// @notice Sets the target contract.
    function setTarget(address newTarget) external onlyOwner {
        requireTrustline();
        require(newTarget != address(0), "target zero");
        target = newTarget;
    }

    /// @notice Transfers firewall admin to another address.
    function setOwner(address newOwner) external onlyOwner {
        requireTrustline();
        require(newOwner != address(0), "owner zero");
        owner = newOwner;
    }

    /// @notice Add or remove an operator allowed to use the protected forward path.
    function setOperator(address account, bool isOperator_) external onlyOwner {
        requireTrustline();
        isOperator[account] = isOperator_;
    }

    /// @notice Allow or disallow unrestricted callers on the protected forward path.
    function setPublicForward(bool enabled) external onlyOwner {
        requireTrustline();
        publicForward = enabled;
    }

    // ---------- Protected forward (operators or public, Trustline-protected) ----------

    /// @notice Forwards any call to the target. Value and calldata are passed through; return data and reverts are propagated.
    fallback() external payable onlyOperator {
        requireTrustline();
        _forward(target, msg.value, msg.data);
    }

    /// @notice Forwards plain ETH sends to the target (target.receive() or fallback).
    receive() external payable onlyOperator {
        requireTrustline();
        _forward(target, msg.value, "");
    }

    /// @dev Performs the low-level call and propagates return data or revert reason.
    function _forward(address _target, uint256 value, bytes memory data) internal {
        (bool success, bytes memory result) = _target.call{value: value}(data);
        if (success) {
            assembly {
                return(add(result, 0x20), mload(result))
            }
        }
        if (result.length > 0) {
            assembly {
                revert(add(result, 0x20), mload(result))
            }
        }
        revert();
    }
}
