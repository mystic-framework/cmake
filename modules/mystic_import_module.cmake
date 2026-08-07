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

include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")

# -------------------------------------------------------------------------------------------------
# List of valid modules in the framework.
# -------------------------------------------------------------------------------------------------
set(_MYSTIC_VALID_MODULES
  "mystic-common"
  "mystic-traits"
  # Add new modules here
)

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
  
  # Check if the module name is valid
  string(TOLOWER "${ARG_MODULE_NAME}" ARG_MODULE_NAME)
  list(FIND _MYSTIC_VALID_MODULES ${ARG_MODULE_NAME} MODULE_INDEX)
  if(MODULE_INDEX EQUAL -1)
    mystic_message(FATAL_ERROR "Invalid module name: ${ARG_MODULE_NAME}. Please check the list of valid modules.")
  endif()

  set(_repo "https://github.com/thedevmystic/${ARG_MODULE_NAME}.git")
  if(NOT DEFINED ARG_MODULE_VER)
    set(_version "main")
  else()
    set(_version "${ARG_MODULE_VER}")
  endif()
  set(_src_dir "${CMAKE_BINARY_DIR}/_deps/${ARG_MODULE_NAME}-src")

  message(NOTICE "[MYSTIC] - Importing module: ${ARG_MODULE_NAME}...")

  # Find Git
  find_package(Git QUIET)
  if(NOT Git_FOUND)
    mystic_message(FATAL_ERROR "Error: Git was not found. Please install git.")
  endif()

  # Clone via Git
  if(NOT EXISTS "${_src_dir}/.git")
    execute_process(
      COMMAND ${GIT_EXECUTABLE} clone --quiet --branch ${_version} ${_repo} "${_src_dir}"
      RESULT_VARIABLE _rc
      OUTPUT_QUIET ERROR_VARIABLE _err
    )
  else()
    execute_process(
      COMMAND ${GIT_EXECUTABLE} -C "${_src_dir}" fetch --quiet origin ${_version}
      RESULT_VARIABLE _rc
      OUTPUT_QUIET ERROR_VARIABLE _err
    )
    if(_rc EQUAL 0)
      execute_process(
        COMMAND ${GIT_EXECUTABLE} -C "${_src_dir}" reset --hard --quiet origin/${_version}
        RESULT_VARIABLE _rc
        OUTPUT_QUIET ERROR_VARIABLE _err
      )
    endif()
  endif()

  # Check for failure
  if(NOT _rc EQUAL 0)
    mystic_message(FATAL_ERROR "Failed to import ${ARG_MODULE_NAME}:\n${_err}")
  endif()

  string(REPLACE "-" "_" MODULE_NAME_UNDERSCORE "${ARG_MODULE_NAME}")
  string(TOUPPER "${MODULE_NAME_UNDERSCORE}" MODULE_NAME_UPPER)

  set(FETCHCONTENT_SOURCE_DIR_${MODULE_NAME_UPPER} "${_src_dir}")

  include(FetchContent)
  FetchContent_Declare(
    ${MODULE_NAME_UNDERSCORE}
    GIT_REPOSITORY ${_repo}
    GIT_TAG        ${_version}
    QUIET
  )
  FetchContent_MakeAvailable(${MODULE_NAME_UNDERSCORE})

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

  # Convert module name to upper case with underscores (e.g., mystic-lib -> MYSTIC_LIB)
  string(REPLACE "-" "_" ARG_MODULE_NAME "${ARG_MODULE_NAME}")
  string(TOUPPER "${ARG_MODULE_NAME}" ARG_MODULE_NAME)

  # Set default build configuration
  set(${ARG_MODULE_NAME}_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING "Build type.")
  set(${ARG_MODULE_NAME}_BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libraries (static, if OFF).")

  # Disable standard options by default
  set(${ARG_MODULE_NAME}_ENABLE_BENCHMARKS OFF CACHE BOOL "Build benchmarks.")
  set(${ARG_MODULE_NAME}_ENABLE_COVERAGE   OFF CACHE BOOL "Build code coverage.")
  set(${ARG_MODULE_NAME}_ENABLE_DOCS       OFF CACHE BOOL "Build documentation.")
  set(${ARG_MODULE_NAME}_ENABLE_EXAMPLES   OFF CACHE BOOL "Build example programs.")
  set(${ARG_MODULE_NAME}_ENABLE_LINT       OFF CACHE BOOL "Enable static code analysis.")
  set(${ARG_MODULE_NAME}_ENABLE_PROFILER   OFF CACHE BOOL "Enable profiling.")
  set(${ARG_MODULE_NAME}_ENABLE_SANITIZERS OFF CACHE BOOL "Enable sanitizers.")
  set(${ARG_MODULE_NAME}_ENABLE_TESTING    OFF CACHE BOOL "Build test suites.")
  set(${ARG_MODULE_NAME}_ENABLE_WARNINGS   OFF CACHE BOOL "Enable strict compiler warnings.")
  set(${ARG_MODULE_NAME}_INSTALL           OFF CACHE BOOL "Enable installation of the library.")

  # Enable LTO if ARG_USE_LTO
  if(DEFINED ARG_USE_LTO AND ARG_USE_LTO)
    set(${ARG_MODULE_NAME}_ENABLE_LTO ON CACHE BOOL "Enable Link Time Optimization.")
  else()
    set(${ARG_MODULE_NAME}_ENABLE_LTO OFF CACHE BOOL "Enable Link Time Optimization.")
  endif()

  # Enable NARCH if ARG_USE_NARCH
  if(DEFINED ARG_USE_NARCH AND ARG_USE_NARCH)
    set(${ARG_MODULE_NAME}_ENABLE_NARCH ON CACHE BOOL "Enable host CPU optimization.")
  else()
    set(${ARG_MODULE_NAME}_ENABLE_NARCH OFF CACHE BOOL "Enable host CPU optimization.")
  endif()

  # Enable system libraries option if ARG_USE_SYSTEM
  if(DEFINED ARG_USE_SYSTEM AND ARG_USE_SYSTEM)
    set(${ARG_MODULE_NAME}_USE_SYSTEM ON CACHE BOOL "Use system-installed libraries.")
  else()
    set(${ARG_MODULE_NAME}_USE_SYSTEM OFF CACHE BOOL "Use system-installed libraries.")
  endif()

  # Enable internal build flag
  set(${ARG_MODULE_NAME}_INTERNAL ON CACHE BOOL "Whether this library is being built as part of a larger project.")
endfunction()
