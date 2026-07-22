<div align="center">
  <h1 style="font-size: 1.75rem; margin: 0.625rem 0;">
    Mystic CMake
  </h1>
  <p>
    General purpose CMake modules for usage in Mystic Framework.
  </p>
</div>

<p align="center">
  <img
    src="https://img.shields.io/badge/CMake-ebdbb2?style=flat-square&logo=cmake&logoColor=458588"
    alt="CMake"
  />
  <img
  <img
    src="https://img.shields.io/badge/Apache%202.0-444444?style=flat-square&logo=apache&logoColor=white"
    alt="License: Apache 2.0"
  />
  <img
    src="https://img.shields.io/badge/Ver-0.1.0-blue?style=flat-square"
    alt="v0.1.0"
  />
</p>

<details>
<summary>Table of Contents (click to show)</summary>

- [About the Project](#about-the-project)
- [How to Use](#how-to-use)
  - [Via FetchContent](#via-fetchcontent)
  - [Via Git Submodules](#via-git-submodules)
  - [Just Copy-Paste](#just-copy-paste)
- [Contributing](#contributing)
- [License](#license)

</details>

# About the Project

**Mystic CMake** is a collection of general-purpose QoL CMake helper modules for Mystic Framework.

---

# How to Use

### Via FetchContent

Add this to your root `CMakeLists.txt`:

```cmake
include(FetchContent)

FetchContent_Declare(
    mystic_cmake
    GIT_REPOSITORY https://github.com/thedevmystic/mystic-cmake.git
    GIT_TAG        main # or other tags
)
FetchContent_MakeAvailable(mystic_cmake)

list(APPEND CMAKE_MODULE_PATH "${mystic_cmake_SOURCE_DIR}/modules")

# Include desired modules
include(mystic_ascii_banner)
include(mystic_options)
```

### Via Git Submodules

Add Mystic CMake as a submodule inside your project:

```bash
git submodule add https://github.com/thedevmystic/mystic-cmake.git third_party/mystic-cmake
```

Then append the path to `CMAKE_MODULE_PATH` in your `CMakeLists.txt`:

```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/third_party/mystic-cmake/modules")

include(mystic_ascii_banner)
include(mystic_coverage)
```

### Just Copy-Paste

1. Copy the `.cmake` files from the `modules/` directory directly into your project's `cmake/` folder.
2. In your `CMakeLists.txt`:

```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(mystic_options)
```

---

# Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page or submit a pull request.

# License

Distributed under the Apache 2.0 License. See [LICENSE](./LICENSE) for more details.
