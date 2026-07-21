# -------------------------------------------------------------------------------------------------
# File: mystic_options.cmake
# Desc: Contains options for the framework. This contains all options used in the Mystic Framework.
# Auth: thedevmystic (Surya) <thedevmystic@gmail.com>
# Licence: Apache 2.0 License
# -------------------------------------------------------------------------------------------------
# Usage:
# include(path/to/mystic_options)
# -------------------------------------------------------------------------------------------------

# Project Options
option(MYSTIC_ENABLE_COVERAGE "Build code coverage."            OFF)
option(MYSTIC_ENABLE_DOCS     "Build documentation."            ON)
option(MYSTIC_ENABLE_TESTING  "Build test suites."              ON)
option(MYSTIC_USE_SYSTEM      "Use system-installed libraries." OFF)
option(MYSTIC_INTERNAL        "Whether this library is being built as part of a larger project." OFF)

# Third Party Libraries Options
# Catch2
option(MYSTIC_USE_SYSTEM_CATCH2 "Use system-installed Catch2 v3." OFF)
# IWYU
option(MYSTIC_USE_IWYU "Use include-what-you-use (only supports system-installed)." OFF)

# If MYSTIC_USE_SYSTEM is ON, then use system-installed libraries.
if(MYSTIC_USE_SYSTEM)
  set(MYSTIC_USE_SYSTEM_CATCH2 ON)
endif()
