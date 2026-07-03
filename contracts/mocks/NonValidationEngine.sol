// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @dev Contract account that does not advertise IValidationEngine via EIP-165.
contract NonValidationEngine is IERC165 {
    uint256 public value;

    function setValue(uint256 newValue) external {
        value = newValue;
    }

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
