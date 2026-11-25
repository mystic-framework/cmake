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
# File: MysticProject.cmake
# Description: This CMake module is used to simplify the process of a project.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file:
# include(MysticProject)
# # Then call the mystic_project function:
# mystic_project()
# # It reads from the project.json file and sets the parameters for the project() command.
# project(${<YOUR_PROJECT_NAME>_PROJECT_ARGUMENTS})
# # If your project name is "MyProject",then the arguments for the project() command are as follows:
# project(${MYPROJECT_PROJECT_ARGUMENTS})
#
# Note: This requires Python to be installed on the system, as it uses Python to parse the JSON
# file.
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# Valid example of project.json file:
# --------------------------------------------------------------------------------------------------
# {
#   "name": "MyProject",
#   "version": "3.4.5",
#   "description": "This is a sample project.",
#   "homepage": "https://example.com",
#   "languages": ["CXX"],
#   "cxx_standard": "23",
#   "license": "<SPDX_LICENSE_IDENTIFIER>",
# }
# --------------------------------------------------------------------------------------------------
# Here:
# - "name" is the name of the project. (Required)
# - "version" is the version of the project. (Optional)
# - "description" is a brief description of the project. (Optional)
# - "homepage" is the URL of the project's homepage. (Optional)
# - "languages" is a list of programming languages used in the project. (Optional)
# - "cxx_standard" is the C++ standard version used in the project. (Optional, only applicable
#   if CXX is specified in "languages")
# - "license" is the SPDX license identifier for the project. (Optional)
# Note:
# - The "name" field is required and must be a non-empty string. It is used as the prefix for the
#   project() command arguments.
# - If you specify "name" as "MyProject", then the project() command arguments will be called as:
#   MYPROJECT_PROJECT_ARGUMENTS.
# - The "languages" field should be a list of strings, where each string is a valid CMake
#   language identifier.
# - The "cxx_standard" field should be a string representing the C++ standard version, such as
#   "11", "14", "17", "20", or "23".
# --------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/MysticMessage.cmake")

# Current Directory
set(_MYSTIC_CURRENT_DIR "${CMAKE_CURRENT_LIST_DIR}")

# --------------------------------------------------------------------------------------------------
# Declare _MYSTIC_PROJECT_PREFIX as an INHERITED directory property.
# --------------------------------------------------------------------------------------------------
get_property(_MYSTIC_PROJECT_PREFIX_PROPERTY_DEFINED GLOBAL PROPERTY _MYSTIC_PROJECT_PREFIX_PROPERTY_DEFINED)
if(NOT _MYSTIC_PROJECT_PREFIX_PROPERTY_DEFINED)
  define_property(DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX INHERITED
    BRIEF_DOCS "Constant-case name prefix for the current Mystic project."
    FULL_DOCS "Set by mystic_project() to the CONSTANT_CASE form of the project's name."
              "It is used as a prefix for all project-related variables and is stored as a directory property."
              "Inherited so subdirectories can retrieve it without redeclaring it."
  )
  set_property(GLOBAL PROPERTY _MYSTIC_PROJECT_PREFIX_PROPERTY_DEFINED TRUE)
endif()

# --------------------------------------------------------------------------------------------------
# Function: mystic_project
# Description: This function reads the project.json file and sets the parameters for the project()
# command. It also sets the C++ standard version if specified in the project.json file.
# Args:
#   JSON_PATH: The path to the project.json file (optional, default is
#   "${CMAKE_CURRENT_SOURCE_DIR}/project.json")
# --------------------------------------------------------------------------------------------------
function(mystic_project)
  set(options "")
  set(singleValueArgs "JSON_PATH")
  set(multiValueArgs "")

  cmake_parse_arguments(
    ARG
    "${options}"
    "${singleValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  if(ARG_UNPARSED_ARGUMENTS)
    mystic_message(FATAL_ERROR "mystic_project received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  # Determine the path to the project.json file. If JSON_PATH is provided, use it; otherwise, use
  # the default path.
  if(ARG_JSON_PATH)
    set(PROJECT_JSON_PATH "${ARG_JSON_PATH}")
  else()
    set(PROJECT_JSON_PATH "${CMAKE_CURRENT_SOURCE_DIR}/project.json")
  endif()

  # Find Python interpreter
  find_package(Python3 COMPONENTS Interpreter REQUIRED)

  # Run the Python script to read the project.json file and extract the project metadata.
  execute_process(
    COMMAND "${Python3_EXECUTABLE}" "${_MYSTIC_CURRENT_DIR}/scripts/gen_project_info.py" "${PROJECT_JSON_PATH}" "${CMAKE_CURRENT_BINARY_DIR}/MysticProjectInfo.cmake"
    RESULT_VARIABLE _MYSTIC_PROJECT_PYTHON_RESULT
  )
  if (NOT _MYSTIC_PROJECT_PYTHON_RESULT EQUAL 0)
    mystic_message(FATAL_ERROR "Failed to read project.json file at ${PROJECT_JSON_PATH}. Ensure the file exists and is valid JSON.")
  endif()

  # Add project.json as a dependency
  set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${PROJECT_JSON_PATH}")

  # Include the generated MysticProjectInfo.cmake file to set the project variables.
  include("${CMAKE_CURRENT_BINARY_DIR}/MysticProjectInfo.cmake")

  # Set the _MYSTIC_PROJECT_PREFIX directory property to the constant-case form of the project name.
  set_property(DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX "${_MYSTIC_CURRENT_PROJECT_PREFIX}")
endfunction()
