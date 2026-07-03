// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IValidationEngine} from "../interfaces/IValidationEngine.sol";

contract MockValidationEngine is IValidationEngine {
    address public owner;
    bool public shouldPass;

    function initialize(address owner_) external {
        require(owner == address(0), "Already initialized");
        owner = owner_;
        shouldPass = true;
    }

    function defaultAdmin() external view returns (address) {
        return owner;
    }

    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return interfaceId == type(IValidationEngine).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function setShouldPass(bool value) external {
        require(msg.sender == owner, "Not owner");
        shouldPass = value;
    }

    function checkTrustlineStatus(
        ValidationMode,
        address,
        uint256,
        bytes calldata,
        address[] memory
    ) external view returns (bool) {
        return shouldPass;
    }

    function checkTrustlineStatus(
        address,
        uint256,
        bytes calldata,
        address[] memory
    ) external view returns (bool) {
        return shouldPass;
    }

    function checkTrustlineStatus(address, uint256, bytes calldata) external view returns (bool) {
        return shouldPass;
    }

    function requireTrustline(
        ValidationMode,
        address,
        uint256,
        bytes calldata,
        address[] memory
    ) external view {
        require(shouldPass, "Not compliant");
    }

    function requireTrustline(
        address,
        uint256,
        bytes calldata,
        address[] memory
    ) external view {
        require(shouldPass, "Not compliant");
    }

    function requireTrustline(address, uint256, bytes calldata) external view {
        require(shouldPass, "Not compliant");
    }
}
