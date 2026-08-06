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
  set(MYSTIC_INTERNAL FALSE CACHE BOOL "" FORCE)

  message(NOTICE "[MYSTIC] - Imported module: ${ARG_MODULE_NAME}.")
endfunction()

# -------------------------------------------------------------------------------------------------
# Desc: Prepares the module for internal importing (sets up options)
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

  # Convert module name to upper case with underscores (e.g., mystic-lib -> MYSTIC_LIB)
  string(REPLACE "-" "_" ARG_MODULE_NAME "${ARG_MODULE_NAME}")
  string(TOUPPER "${ARG_MODULE_NAME}" ARG_MODULE_NAME)

  macro(_mystic_internal_prepare_for_import_helper _OPTION _VALUE _TYPE _DESC)
    set(${ARG_MODULE_NAME}_${_OPTION} "${_VALUE}" CACHE ${_TYPE} "${_DESC}" FORCE)
  endmacro()

  # Set default build configuration
  _mystic_internal_prepare_for_import_helper("BUILD_TYPE" "${CMAKE_BUILD_TYPE}" "STRING" "Build type.")
  _mystic_internal_prepare_for_import_helper("BUILD_SHARED_LIBS" "OFF" "BOOL" "Build shared libraries (static, if OFF).")

  # Disable standard options
  _mystic_internal_prepare_for_import_helper("ENABLE_BENCHMARKS" "OFF" "BOOL" "Build benchmarks.")
  _mystic_internal_prepare_for_import_helper("ENABLE_COVERAGE"   "OFF" "BOOL" "Build code coverage.")
  _mystic_internal_prepare_for_import_helper("ENABLE_DOCS"       "OFF" "BOOL" "Build documentation.")
  _mystic_internal_prepare_for_import_helper("ENABLE_EXAMPLES"   "OFF" "BOOL" "Build example programs.")
  _mystic_internal_prepare_for_import_helper("ENABLE_LINT"       "OFF" "BOOL" "Enable static code analysis.")
  _mystic_internal_prepare_for_import_helper("ENABLE_PROFILER"   "OFF" "BOOL" "Enable profiling.")
  _mystic_internal_prepare_for_import_helper("ENABLE_SANITIZERS" "OFF" "BOOL" "Enable sanitizers.")
  _mystic_internal_prepare_for_import_helper("ENABLE_TESTING"    "OFF" "BOOL" "Build test suites.")
  _mystic_internal_prepare_for_import_helper("ENABLE_WARNINGS"   "OFF" "BOOL" "Enable strict compiler warnings.")
  _mystic_internal_prepare_for_import_helper("INSTALL"           "OFF" "BOOL" "Enable installation of the library.")

  # Enable LTO if ARG_USE_LTO
  if(ARG_USE_LTO)
    _mystic_internal_prepare_for_import_helper("ENABLE_LTO" "ON" "BOOL" "Enable Link Time Optimization.")
  else()
    _mystic_internal_prepare_for_import_helper("ENABLE_LTO" "OFF" "BOOL" "Enable Link Time Optimization.")
  endif()

  # Enable NARCH if ARG_USE_NARCH
  if(ARG_USE_NARCH)
    _mystic_internal_prepare_for_import_helper("ENABLE_NARCH" "ON" "BOOL" "Enable host CPU optimization.")
  else()
    _mystic_internal_prepare_for_import_helper("ENABLE_NARCH" "OFF" "BOOL" "Enable host CPU optimization.")
  endif()

  # Enable system libraries option if ARG_USE_SYSTEM
  if(ARG_USE_SYSTEM)
    _mystic_internal_prepare_for_import_helper("USE_SYSTEM" "ON" "BOOL" "Use system-installed libraries.")
  else()
    _mystic_internal_prepare_for_import_helper("USE_SYSTEM" "OFF" "BOOL" "Use system-installed libraries.")
  endif()

  # Enable internal build flag
  _mystic_internal_prepare_for_import_helper("INTERNAL" "ON" "BOOL" "Whether this library is being built as part of a larger project.")
endfunction()
