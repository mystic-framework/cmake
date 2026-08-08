# -------------------------------------------------------------------------------------------------
# File: mystic_import_module.cmake
# Desc: Used to import modules of the framework.
# Auth: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache 2.0 License
# -------------------------------------------------------------------------------------------------
# Usage:
# include(path/to/mystic_import_module)
# # must be a valid module name in the framework.
# mystic_prepare_for_import(MODULE_NAME module-name)
# mystic_import_module(MODULE_NAME module-name)
# -------------------------------------------------------------------------------------------------

include(FetchContent)
include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")

# -------------------------------------------------------------------------------------------------
# Checks if a module is valid
# -------------------------------------------------------------------------------------------------
function(_mystic_internal_is_valid_module ARG_MODULE_NAME)
  set(_MYSTIC_VALID_MODULES
    "mystic-common"
    "mystic-traits"
    # Add new modules here
  )

  string(TOLOWER "${ARG_MODULE_NAME}" _module_name)
  list(FIND _MYSTIC_VALID_MODULES "${_module_name}" MODULE_INDEX)
  if(MODULE_INDEX EQUAL -1)
    mystic_message(FATAL_ERROR "Invalid module name: ${ARG_MODULE_NAME}. Please check the list of valid modules.")
  endif()
endfunction()

# -------------------------------------------------------------------------------------------------
# Desc: Function used to import a module, it first checks if it is valid and then imports it.
# Args:
#  MODULE_NAME: The name of the module to import.
#  MODULE_VER: The version/tag of the module to import (defaults to: main).
# -------------------------------------------------------------------------------------------------
function(mystic_import_module)
  set(options "")
  set(singleValueArgs "MODULE_NAME" "MODULE_VER")
  set(multiValueArgs "")

  cmake_parse_arguments(
    ARG
    "${options}"
    "${singleValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  # if unknown args
  if(ARG_UNPARSED_ARGUMENTS)
    mystic_message(FATAL_ERROR "mystic_import_module received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  # Validate args
  if(NOT DEFINED ARG_MODULE_NAME)
    mystic_message(FATAL_ERROR "MODULE_NAME not defined in mystic_import_module.")
  endif()

  set(MYSTIC_MESSAGE_ONLY_ERRORS ON)
  set(MYSTIC_ASCII_BANNER_DISABLE ON)
  
  # Check if the module name is valid
  _mystic_internal_is_valid_module("${ARG_MODULE_NAME}")

  string(TOLOWER "${ARG_MODULE_NAME}" _module_name_lower)

  set(_repo "https://github.com/mystic-framework/${_module_name_lower}.git")
  if(NOT DEFINED ARG_MODULE_VER)
    set(_version "main")
  else()
    set(_version "${ARG_MODULE_VER}")
  endif()

  message(NOTICE "[MYSTIC] - Importing module: ${ARG_MODULE_NAME}...")

  string(REPLACE "-" "_" _effective_module_name "${_module_name_lower}")

  FetchContent_Declare(
    ${_effective_module_name}
      GIT_REPOSITORY ${_repo}
      GIT_TAG        ${_version}
      QUIET
  )
  FetchContent_MakeAvailable(${_effective_module_name})

  message(NOTICE "[MYSTIC] - Imported module: ${ARG_MODULE_NAME}.")
endfunction()

# -------------------------------------------------------------------------------------------------
# Desc: Prepares the module for internal importing (sets up default options)
# Args:
#   MODULE_NAME: The name of the module.
#   USE_LTO: Whether to use LTO or not.
#   USE_NARCH: Whether to use host CPU optimization or not.
#   USE_SYSTEM: Whether to use system libraries or not.
# -------------------------------------------------------------------------------------------------
function(mystic_prepare_for_import)
  set(options "")
  set(singleValueArgs "MODULE_NAME" "USE_LTO" "USE_NARCH" "USE_SYSTEM")
  set(multiValueArgs "")

  cmake_parse_arguments(
    ARG
    "${options}"
    "${singleValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  # Check for unknown args
  if(ARG_UNPARSED_ARGUMENTS)
    mystic_message(FATAL_ERROR "mystic_prepare_for_import received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  # Validate args
  if(NOT DEFINED ARG_MODULE_NAME)
    mystic_message(FATAL_ERROR "MODULE_NAME not defined in mystic_prepare_for_import.")
  endif()

  # Check if the module name is valid
  _mystic_internal_is_valid_module("${ARG_MODULE_NAME}")

  # Convert module name to upper case with underscores (e.g., mystic-lib -> MYSTIC_LIB)
  string(REPLACE "-" "_" _module_name "${ARG_MODULE_NAME}")
  string(TOUPPER "${_prefix}" _module_name)

  # Set default build configuration
  set(${_prefix}_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING "Build type.")
  set(${_prefix}_BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libraries (static, if OFF).")

  # Disable standard options by default
  set(${_prefix}_ENABLE_BENCHMARKS OFF CACHE BOOL "Build benchmarks.")
  set(${_prefix}_ENABLE_COVERAGE   OFF CACHE BOOL "Build code coverage.")
  set(${_prefix}_ENABLE_DOCS       OFF CACHE BOOL "Build documentation.")
  set(${_prefix}_ENABLE_EXAMPLES   OFF CACHE BOOL "Build example programs.")
  set(${_prefix}_ENABLE_LINT       OFF CACHE BOOL "Enable static code analysis.")
  set(${_prefix}_ENABLE_PROFILER   OFF CACHE BOOL "Enable profiling.")
  set(${_prefix}_ENABLE_SANITIZERS OFF CACHE BOOL "Enable sanitizers.")
  set(${_prefix}_ENABLE_TESTING    OFF CACHE BOOL "Build test suites.")
  set(${_prefix}_ENABLE_WARNINGS   OFF CACHE BOOL "Enable strict compiler warnings.")
  set(${_prefix}_INSTALL           OFF CACHE BOOL "Enable installation of the library.")

  # Enable LTO if ARG_USE_LTO
  if(DEFINED ARG_USE_LTO AND ARG_USE_LTO)
    set(${_prefix}_ENABLE_LTO ON CACHE BOOL "Enable Link Time Optimization.")
  else()
    set(${_prefix}_ENABLE_LTO OFF CACHE BOOL "Enable Link Time Optimization.")
  endif()

  # Enable NARCH if ARG_USE_NARCH
  if(DEFINED ARG_USE_NARCH AND ARG_USE_NARCH)
    set(${_prefix}_ENABLE_NARCH ON CACHE BOOL "Enable host CPU optimization.")
  else()
    set(${_prefix}_ENABLE_NARCH OFF CACHE BOOL "Enable host CPU optimization.")
  endif()

  # Enable system libraries option if ARG_USE_SYSTEM
  if(DEFINED ARG_USE_SYSTEM AND ARG_USE_SYSTEM)
    set(${_prefix}_USE_SYSTEM ON CACHE BOOL "Use system-installed libraries.")
  else()
    set(${_prefix}_USE_SYSTEM OFF CACHE BOOL "Use system-installed libraries.")
  endif()

  # Enable internal build flag
  set(${_prefix}_INTERNAL ON CACHE BOOL "Whether this library is being built as part of a larger project.")
endfunction()
