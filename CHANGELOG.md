# Changelog

All notable changes to `@trustline.id/evmsdk` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-11-10

### Added

- `TrustlineFirewall` example — generic intermediary that runs `requireTrustline()` then
  forwards any call to a fixed target with a regular `call`, so existing role-based
  contracts can be gated without code changes.
- `TrustlinedBase` — shared Trustline validation / Validation Engine wiring used by both
  the non-upgradeable and upgradeable entry contracts.

### Changed

- Renamed the payment example from `PaymentFirewall` to `PaymentForwarder` to avoid
  confusion with the general-purpose Trustline Firewall.
- Raised OpenZeppelin dependencies to `^5.4.0`.
- Slimmed `Trustlined` and `TrustlinedUpgradeable` to thin wrappers over `TrustlinedBase`.
- Merged the `1.0.7-audited.0` remediations into the mainline release line.

### Security

- Stronger, type-checked ABI encoding for Validation Engine calls (H1).
- EIP-165 checks so configured logic/proxy addresses must implement the Validation Engine
  interface (H2).
- User-provided Validation Engine proxy must be administered by `msg.sender`; documented
  required proxy deployment shape (H4).
- Reject EIP-7702-delegated EOAs as Validation Engine proxy or logic (M13).
- `ValidationEngineAdopted` event when a Validation Engine is bound (I12).
- Documented inheritance / storage-slot constraints (M14), cross-chain address
  non-determinism (L4), and that `checkTrustlineStatus` is query-only (M5).

## [1.0.7-audited.0] - 2026-06-29

### Security

- Audited remediations later folded into `1.1.0` (H1, H2, H4, M5, M13, M14, L4, I12).
  Published as a semver prerelease on the audited line (`> 1.0.6` and `< 1.0.7` range).

## [1.0.7] - 2026-03-31

### Added

- Separate non-upgradeable (`Trustlined`) and upgradeable (`TrustlinedUpgradeable`)
  integration patterns, with tests and mocks.

### Changed

- Stronger, type-checked ABI encoding for Validation Engine interactions.
- Additional checks that configured addresses are actual Validation Engines.

### Fixed

- Hardened the payment example: `SafeERC20`, reentrancy guard, and basic argument checks.

## [1.0.6] - 2026-02-13

### Changed

- Renamed the package to EVM SDK to avoid confusion with the Web SDK.
- Clarified the on-chain validation flow in the documentation.

## [1.0.5] - 2026-02-11

### Documentation

- Expanded the README with clearer integration guidance.

## [1.0.4] - 2026-01-27

### Added

- Automatic Validation Engine proxy deployment when none is supplied.
- Option to pass an existing Validation Engine proxy address at construction.

## [1.0.3] - 2025-08-28

### Added

- Morpho and ERC-3643 validation modes on the Validation Engine interface.

### Fixed

- Address checks in the payment example contract.

### Changed

- Clearer naming for the Validation Engine address surface.

## [1.0.2] - 2025-07-21

### Added

- Advanced Validation Engine interface calls for richer protocol integrations.

### Documentation

- Expanded explanations around Validation Engine usage.

## [1.0.1] - 2025-06-27

### Changed

- Updated OpenZeppelin dependencies.
- Simplified the public Validation Engine interface surface and documented the npm import.

## [1.0.0] - 2025-06-25

### Added

- Initial public release of `@trustline.id/evmsdk`.
- `Trustlined` base for gating contract entrypoints through a Trustline Validation Engine.
- Validation Engine interfaces and the payment example contract.
- Hardhat build, tests, and npm packaging for Solidity consumers.

[Unreleased]: https://github.com/TrustLine-id/evmsdk/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/TrustLine-id/evmsdk/compare/v1.0.7...v1.1.0
[1.0.7-audited.0]: https://github.com/TrustLine-id/evmsdk/releases/tag/v1.0.7-audited.0
[1.0.7]: https://github.com/TrustLine-id/evmsdk/compare/v1.0.6...v1.0.7
[1.0.6]: https://github.com/TrustLine-id/evmsdk/compare/v1.0.5...v1.0.6
[1.0.5]: https://github.com/TrustLine-id/evmsdk/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/TrustLine-id/evmsdk/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/TrustLine-id/evmsdk/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/TrustLine-id/evmsdk/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/TrustLine-id/evmsdk/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/TrustLine-id/evmsdk/releases/tag/v1.0.0
