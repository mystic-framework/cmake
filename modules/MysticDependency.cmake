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
# File: MysticDependency.cmake
# Description: This CMake module is used to manage dependencies for the Mystic Framework.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Dependencies can be classified into two categories:
# 1. First-party dependencies: These are modules that are part of the Mystic Framework itself. We
#    call it "Modules" in the MFW.
# 2. Third-party dependencies: These are external libraries or modules that the Mystic Framework
#    relies on or your own project may rely on.
#
# This file provides a unified way to manage both types of dependencies, allowing for easy
# integration and version control.
#
# The dependency information is provided in project.json (or equivalent) file. This file also
# contains project metadata, such as the project name, version, and other relevant information.
# To see those, check `MysticProject.cmake`.
#
# So, the project.json file may look like this:
# {
#   ...Other project metadata...
#   "dependencies": {
#     "modules": [
#       {
#         "name": "module1",
#         "version": "x.y.z",
#         "force_find_package": false
#       },
#       {
#         "name": "module2",
#         "version": "a.b.c"
#       }
#     ],
#     "third_party": [
#       {
#         "name": "library1",
#         "version": "p.q.r",
#         "git_url": "https://github.com/user/library1.git",
#         "git_tag": "v1.2.3",
#         "force_find_package": false
#       },
#       {
#         "name": "library2",
#         "version": "s.t.u",
#         "git_url": "https://github.com/user/library2.git",
#         "cmake_options": ["SOME_OPTION=ON", "ANOTHER_OPTION=OFF"]
#       }
#     ]
#   }
# }
#
# The "dependencies" section contains two subsections:
# 1. "modules": This subsection lists the first-party modules that the project depends on
#    as objects containing "name", "version", and an optional "force_find_package" boolean.
# 2. "third_party": This subsection lists the external libraries that are not part of the Mystic
#    Framework. Each entry is an object specifying "name", "version", "git_url", and optional
#    "git_tag" (defaults to "main") and "force_find_package" (defaults to false).
#
# A note on behavior: We first try to import the dependency using find_package. If it is not found,
# we will fetch it from its Git URL using FetchContent. The fallback happens without any issues,
# but if we want to force find_package only (for certain system packages), set
# `"force_find_package": true` on the dependency entry in your project.json file:
# {
#   "dependencies": {
#     "third_party": [
#       {
#         "name": "library1",
#         "version": "p.q.r",
#         "git_url": "https://github.com/user/library1.git",
#         "force_find_package": true
#       }
#     ]
#   }
# }
#
# Usage:
# # To use this file, include it in your CMakeLists.txt file and call it:
# include(MysticDependency)
# mystic_generate_dependencies()
#
# This file requires Python to be installed on the system, as it uses Python script to generate the
# dependency information from the project.json file.
# --------------------------------------------------------------------------------------------------

include(FetchContent)
include("${CMAKE_CURRENT_LIST_DIR}/MysticMessage.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/PrivateHelpers.cmake")

# --------------------------------------------------------------------------------------------------
# Function: mystic_import_dependency
# Description: Imports a dependency into the project. This function handles both first-party
# modules and third-party libraries.
# Args:
#  - NAME: Name of the dependency, e.g., Catch2 (on find_package).
#  - VERSION: Version of the dependency, e.g., 2.13.7
#  - GIT_URL: URL of the Git repository (Optional if only using system-installed libraries).
#  - GIT_TAG: Library's Git Tag. (Optional, defaults to the "main" branch)
#  - FORCE_FIND_PACKAGE: Flag to force find_package even if the dependency is not found in the
#    system (Optional).
# --------------------------------------------------------------------------------------------------
function(mystic_import_dependency NAME)
  set(options "FORCE_FIND_PACKAGE")
  set(singleValueArgs "VERSION" "GIT_URL" "GIT_TAG")
  set(multiValueArgs "")

  cmake_parse_arguments(
    ARG
    "${options}"
    "${singleValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  # Check if unprocessed arguments exist
  if(ARG_UNPARSED_ARGUMENTS)
    mystic_message(FATAL_ERROR "mystic_import_dependency received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  # Get the project prefix
  get_property(PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  # Check for system-installed library first if enabled
  _mystic_to_constant_case("${NAME}" NAME_CONSTANT)
  if(${PROJECT_PREFIX}_USE_SYSTEM_${NAME_CONSTANT})
    mystic_message(STATUS "Searching for system-installed ${NAME}...")

    # When VERSION is provided use it
    if(ARG_VERSION)
      find_package(${NAME} ${ARG_VERSION} QUIET GLOBAL)
    else()
      find_package(${NAME} QUIET GLOBAL)
    endif()

    if(${NAME}_FOUND OR TARGET ${NAME}::${NAME})
      mystic_message(STATUS "Found system-installed ${NAME}.")
      return()
    else()
      if(ARG_FORCE_FIND_PACKAGE)
        mystic_message(FATAL_ERROR "System-installed ${NAME} not found, and FORCE_FIND_PACKAGE is set. Aborting.")
      else()
        mystic_message(WARNING "System-installed ${NAME} not found. Falling back to FetchContent.")
      endif()
    endif()
  endif()

  # If not found, fetch the library from the URL using FetchContent
  if(ARG_GIT_URL)
    # Determine the Git tag to use. If not provided, default to "main".
    if(NOT ARG_GIT_TAG)
      set(ARG_GIT_TAG "main")
    endif()

    string(TOLOWER "${NAME}" NAME_LOWER)

    mystic_message(STATUS "Fetching ${NAME} from ${ARG_GIT_URL}...")
    FetchContent_Declare(
      ${NAME_LOWER}
      GIT_REPOSITORY ${ARG_GIT_URL}
      GIT_TAG ${ARG_GIT_TAG}
    )
    FetchContent_MakeAvailable(${NAME_LOWER})
    mystic_message(STATUS "Fetched ${NAME} from ${ARG_GIT_URL}.")
  else()
    mystic_message(FATAL_ERROR "GIT_URL not provided for ${NAME}. Cannot fetch the dependency.")
  endif()
endfunction()

# --------------------------------------------------------------------------------------------------
# Function: mystic_generate_dependencies
# Description: Generates the dependency information from the project.json file and creates a
# MysticDependencyInfo.cmake file that contains `mystic_import_dependency()` calls for all the
# dependencies in the project.json file.
# Args:
#   JSON_PATH: The path to the project.json file (optional, default is
#   "${CMAKE_CURRENT_SOURCE_DIR}/project.json")
# --------------------------------------------------------------------------------------------------
function(mystic_generate_dependencies)
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
    mystic_message(FATAL_ERROR "mystic_generate_dependencies received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  # Determine the path to the project.json file. If JSON_PATH is provided, use it; otherwise, use
  # the default path.
  if(ARG_JSON_PATH)
    set(PROJECT_JSON_PATH "${ARG_JSON_PATH}")
  else()
    set(PROJECT_JSON_PATH "${CMAKE_CURRENT_SOURCE_DIR}/project.json")
  endif()

  # Check if the project.json file exists
  if(NOT EXISTS "${PROJECT_JSON_PATH}")
    mystic_message(FATAL_ERROR "project.json file not found at ${PROJECT_JSON_PATH}. Please ensure the file exists.")
  endif()

  # Find Python interpreter
  find_package(Python3 REQUIRED COMPONENTS Interpreter)

  # Generate the MysticDependencyInfo.cmake file using the Python script
  execute_process(
    COMMAND "${Python3_EXECUTABLE}" "${_MYSTIC_CURRENT_DIR}/scripts/gen_dependency_info.py" "${PROJECT_JSON_PATH}" "${CMAKE_CURRENT_BINARY_DIR}/MysticDependencyInfo.cmake"
    RESULT_VARIABLE _MYSTIC_DEPENDENCY_PYTHON_RESULT
  )
  if (NOT _MYSTIC_DEPENDENCY_PYTHON_RESULT EQUAL 0)
    mystic_message(FATAL_ERROR "Failed to generate MysticDependencyInfo.cmake from project.json at ${PROJECT_JSON_PATH}. Ensure the file exists and is valid JSON.")
  endif()

  mystic_message(STATUS "Starting to import dependencies...")
  # Include the generated MysticDependencyInfo.cmake file to import the dependencies.
  include("${CMAKE_CURRENT_BINARY_DIR}/MysticDependencyInfo.cmake")
  mystic_message(STATUS "Finished importing dependencies. Done!")
endfunction()
