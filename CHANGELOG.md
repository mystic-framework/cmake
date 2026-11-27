# CHANGELOG.md

All the notable changes in the project `mystic-framework/cmake` will be documented here.

## [1.2.1] - 2026-11-27

### Added

- Automatic third-party dependency options setup in `MysticSetupOptions`.
- Automatic test framework detection in `MysticTest`.

### Fixed

- Logging inconsistencies in `MysticDependency`.
- Major errors in `MysticLint.`

### Removed

- Duplicate addition of `project.json` to `CMAKE_CONFIGURE_DEPEND` in
  `MysticDependeny` (`MysticProject` already adds it to that).

## [1.2.0] - 2026-11-26

### Added

- `MysticDependency`: Centralizes dependency management into project.json file.

### Changed

- `MysticProject`: Offloaded JSON parsing to Python script.

### Removed

- `MysticImportModule`, `MysticIncludeModules`, `MysticThirdPartyConfig`, `MysticIncludeThirdParty`

## [1.1.0] - 2026-11-25

### Added

- `MysticVersion`: Exposes version information as an header file for Version library to read.
- `MysticExports`: Export control helper for libraries.
- `cxx_std_X` flag in `MysticCompileOptions`.

### Fixed

- Fixed undefined `VALID_TEST_FRAMEWORK` error in `MysticTest`.
- Fixed CXX standard variable in `MysticCompileOptions`.
- Fixed setup options variable expansion error in `MysticSetupOptions`.
- Fixed Catch2 CMake helper modules path in `MysticTest`.
- Fixed multiple errors in `MysticLint`.
- Fixed scoping issues in `MysticProject`.
- Fixed scoping issue in `MysticThirdPartyConfig`.
- Fixed incorrect job name in pre-commit action.
- Fixed DLL errors on windows in `MysticTest`.
- Fixed `MysticTest` not respecting control options.

## [1.0.0] - 2026-09-26

### Added

- `MysticProject`: Configures the project.
- `MysticCompileOptions`: Configures compiler options.
- `MysticInstall`: Configures installation options.
- `MysticSetupOptions`: Sets up project options.
- `MysticTest`: Configures testing options.
- `MysticCoverage`: Configures code coverage options.
- `MysticLint`: Configures linting options (`clang-format` and `clang-tidy`).
- `MysticSanitizers`: Configures sanitizers options (`AddressSanitizer`, `ThreadSanitizer`, etc).
- `MysticImportModule`: Imports a first party (from MFW) module.
- `MysticIncludeModules`: Includes every module from `modules/` directory.
- `MysticThirdPartyConfig`: Configures third party dependencies.
- `MysticIncludeThirdParty`: Includes third party dependencies from `third_party/` directory.
- `MysticAsciiBanner`: Displays an ASCII banner (makes boring CI interesting!).
- `MysticMessage`: Wraps `message()` function to control the output verbosity and prefixing.
