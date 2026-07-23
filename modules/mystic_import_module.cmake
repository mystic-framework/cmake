# -------------------------------------------------------------------------------------------------
# File: mystic_import_module.cmake
# Desc: Used to import modules of the framework.
# Auth: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache 2.0 License
# -------------------------------------------------------------------------------------------------
# Usage:
# include(path/to/mystic_import_module)
# mystic_import_module(module-name) # must be a valid module name in the framework.
# -------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")

# -------------------------------------------------------------------------------------------------
# List of valid modules in the framework.
# -------------------------------------------------------------------------------------------------
set(MYSTIC_VALID_MODULES
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
function(mystic_import_module MODULE_NAME)
  # Check if the module name is valid
  list(FIND MYSTIC_VALID_MODULES ${MODULE_NAME} MODULE_INDEX)
  if(MODULE_INDEX EQUAL -1)
    message(FATAL_ERROR "[MYSTIC] Invalid module name: ${MODULE_NAME}. Please check the list of valid modules.")
  endif()

  set(MYSTIC_INTERNAL TRUE CACHE BOOL "" FORCE)

  set(_repo "https://github.com/thedevmystic/${MODULE_NAME}.git")
  if(ARGC EQUAL 1)
    set(_version "main")
  else()
    set(_version "${ARGV1}")
  endif()
  set(_src_dir "${CMAKE_BINARY_DIR}/_deps/${MODULE_NAME}-src")

  message(NOTICE "[MYSTIC] - Importing module: ${MODULE_NAME}...")

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
    mystic_message(FATAL_ERROR "Failed to import ${MODULE_NAME}:\n${_err}")
  endif()

  string(REPLACE "-" "_" MODULE_NAME_UNDERSCORE "${MODULE_NAME}")
  string(TOUPPER MODULE_NAME_UPPER "${MODULE_NAME_UNDERSCORE}")

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

  message(NOTICE "[MYSTIC] - Imported module: ${MODULE_NAME}.")
endfunction()
