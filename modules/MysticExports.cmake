# --------------------------------------------------------------------------------------------------
# Copyright 2026-present The Mystic Framework Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# --------------------------------------------------------------------------------------------------
# File: MysticExports.cmake
# Description: This CMake module is used to control exporting of the library symbols.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file:
# include(MysticExports)
# # Then call the function to set up exports:
# mystic_exports(<TARGET_NAME>)
# --------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/MysticMessage.cmake")

# Implementation of the mystic_exports function
function(_mystic_exports_impl TARGET_NAME MACRO_NAME)
  # Check if the target is valid
  if(NOT TARGET ${TARGET_NAME})
    mystic_message(FATAL_ERROR "Target '${TARGET_NAME}' is not a valid CMake target. Ensure that the target is defined before calling mystic_exports.")
  endif()

  # Check if the target is a library
  get_target_property(target_type ${TARGET_NAME} TYPE)
  if(NOT target_type STREQUAL "STATIC_LIBRARY" AND NOT target_type STREQUAL "SHARED_LIBRARY")
    mystic_message(FATAL_ERROR "Target '${TARGET_NAME}' is not a library. mystic_exports can only be used with library targets.")
  endif()

  # Hide symbols by default in GCC and Clang
  if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(${target} PRIVATE "-fvisibility=hidden")
  endif()

  # MSVC already hides symbols by default, so no need to set visibility for MSVC.

  # Set the export macro for the target
  target_compile_definitions(${TARGET_NAME} PRIVATE ${MACRO_NAME})
endfunction()

# --------------------------------------------------------------------------------------------------
# Function: mystic_exports
# Description: This function sets up the export symbols for the specified target.
# It defines the appropriate preprocessor definitions for exporting symbols based on the target type.
# Args:
#   ...: List of target names to set up exports for.
#   MACRO_NAME: The name of the macro defined for exporting symbols (default: MYSTIC_EXPORTS).
# --------------------------------------------------------------------------------------------------
function(mystic_exports)
  # Guard against empty argument list
  if(NOT ARGN)
    mystic_message(FATAL_ERROR "mystic_exports requires at least one target name as an argument.")
  endif()

  # Get project prefix
  get_property(PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  if(NOT PROJECT_PREFIX)
    mystic_message(FATAL_ERROR "Project prefix not set. Ensure that 'mystic_project' is called before 'mystic_exports'.")
  endif()

  # If exports option is not enabled, skip setting up exports
  if(NOT ${PROJECT_PREFIX}_EXPORTS)
    mystic_message(WARNING "MYSTIC_EXPORTS is not enabled. Skipping export setup for targets: ${ARGN}.")
    return()
  endif()

  set(options "")
  set(oneValueArgs "MACRO_NAME")
  set(multiValueArgs "")

  cmake_parse_arguments(
    ARG
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  # Every unparsed argument is considered a target name
  set(TARGETS ${ARG_UNPARSED_ARGUMENTS})

  # Set default macro name if not provided
  if(NOT ARG_MACRO_NAME)
    set(ARG_MACRO_NAME "MYSTIC_EXPORTS")
  else()
    set(ARG_MACRO_NAME "${ARG_MACRO_NAME}")
  endif()

  # Iterate over each target and set up exports
  foreach(target IN LISTS TARGETS)
    _mystic_exports_impl(${target} ${ARG_MACRO_NAME})
  endforeach()
endfunction()
