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
# File: MysticTest.cmake
# Description: This CMake module is used to set up testing for a C++ project. It provides
# functions to add test targets, configure test frameworks, and manage test dependencies.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file:
# include(MysticTest)
# # Enable testing for your project:
# mystic_enable_testing()
# # Now you can add test targets using the provided functions.
# mystic_test(MyTestTarget)
# --------------------------------------------------------------------------------------------------
# Note:
# - `mystic_enable_testing()` must be called before adding any test targets. Also it replaces the
#   need to call `enable_testing()` directly in your CMakeLists.txt.
# - `mystic_test()` will handle the linking of the test target with the necessary testing framework
#   libraries (e.g., Google Test, Catch2), and discover the test executable for CTest.
# - It assumes you fetch the testing framework as a submodule or have it available in your project.
# --------------------------------------------------------------------------------------------------

include(CTest)
include(FetchContent)
include("${CMAKE_CURRENT_LIST_DIR}/MysticMessage.cmake")

# This function sets up _MYSTIC_TEST_FRAMEWORK property for the project.
function(_mystic_setup_test_framework_property)
  # Get project prefix
  get_property(PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  get_property(_MYSTIC_TEST_FRAMEWORK_PROPERTY_DEFINED GLOBAL PROPERTY _MYSTIC_TEST_FRAMEWORK_PROPERTY_DEFINED_${PROJECT_PREFIX})
  if(NOT _MYSTIC_TEST_FRAMEWORK_PROPERTY_DEFINED)
    define_property(DIRECTORY PROPERTY _${PROJECT_PREFIX}_TEST_FRAMEWORK INHERITED
      BRIEF_DOCS "Selected test framework (catch2/gtest) for the ${PROJECT_PREFIX} project."
      FULL_DOCS "Set by mystic_enable_testing(). Declared INHERITED so mystic_test() can find it "
                 "when called from a subdirectory of the project rather than the directory that "
                 "called mystic_enable_testing()."
    )
    set_property(GLOBAL PROPERTY _MYSTIC_TEST_FRAMEWORK_PROPERTY_DEFINED_${PROJECT_PREFIX} TRUE)
  endif()
endfunction()

# --------------------------------------------------------------------------------------------------
# Function: mystic_enable_testing
# Description: This function enables testing for the CMake project. It should be called before
# adding any test targets. It replaces the need to call `enable_testing()` directly in your
# CMakeLists.txt.
# Args:
#   TEST_FRAMEWORK: Optional argument to specify the testing framework to use (e.g., "gtest",
#                   "catch2"). When not specified, it scans project.json's "dependencies.third_party"
#                   for available testing frameworks and uses the first one found.
#   JSON_PATH: Path to project metadata file (Optional, default: "project.json").
# --------------------------------------------------------------------------------------------------
function(mystic_enable_testing)
  # Enable testing for the project
  enable_testing()

  # Get project prefix
  get_property(PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  if(NOT PROJECT_PREFIX)
    mystic_message(FATAL_ERROR "Project prefix not set. Ensure that 'mystic_project' is called before 'mystic_enable_testing'.")
  endif()

  set(options "")
  set(oneValueArgs "TEST_FRAMEWORK" "JSON_PATH")
  set(multiValueArgs "")

  cmake_parse_arguments(
    ARG
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  if(ARG_UNPARSED_ARGUMENTS)
    mystic_message(FATAL_ERROR "mystic_enable_testing received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  # Set up the _MYSTIC_TEST_FRAMEWORK property for the project
  _mystic_setup_test_framework_property()

  # Valid test frameworks to look for in dependencies.third_party array
  # Catch2 (catch2) and Google Test (gtest)
  set(VALID_TEST_FRAMEWORKS "catch2" "gtest")

  # Set test framework if specified and return
  # Valid options: catch2, gtest
  if(ARG_TEST_FRAMEWORK)
    string(TOLOWER "${ARG_TEST_FRAMEWORK}" ARG_TEST_FRAMEWORK)

    # Validate the specified test framework
    if(NOT ARG_TEST_FRAMEWORK IN_LIST VALID_TEST_FRAMEWORKS)
      mystic_message(FATAL_ERROR "Invalid test framework specified: ${ARG_TEST_FRAMEWORK}. Valid options are: catch2, gtest.")
    endif()

    set_property(DIRECTORY PROPERTY _${PROJECT_PREFIX}_TEST_FRAMEWORK "${ARG_TEST_FRAMEWORK}")
    mystic_message(STATUS "Using specified test framework: ${ARG_TEST_FRAMEWORK}.")
    return()
  endif()

  # Read the project.json file to determine the test framework if not specified
  if(ARG_JSON_PATH)
    set(PROJECT_JSON_PATH "${ARG_JSON_PATH}")
  else()
    set(PROJECT_JSON_PATH "${CMAKE_CURRENT_LIST_DIR}/project.json")
  endif()
  file(READ "${PROJECT_JSON_PATH}" PROJECT_JSON_CONTENT)

  # Get length of dependencies.third_party
  string(JSON THIRD_PARTY_LIBS_COUNT LENGTH "${PROJECT_JSON_CONTENT}" "dependencies" "third_party")
  if(THIRD_PARTY_LIBS_COUNT GREATER 0)
    math(EXPR LAST_INDEX "${THIRD_PARTY_LIBS_COUNT} - 1")
    foreach(INDEX RANGE 0 ${LAST_INDEX})
      string(JSON THIRD_PARTY_LIB GET "${PROJECT_JSON_CONTENT}" "dependencies" "third_party" ${INDEX} "name" ERROR_VARIABLE JSON_ERROR)

      if(JSON_ERROR)
        mystic_message(FATAL_ERROR "Error reading project.json: ${JSON_ERROR}")
      endif()

      if(THIRD_PARTY_LIB IN_LIST VALID_TEST_FRAMEWORKS)
        set_property(DIRECTORY PROPERTY _${PROJECT_PREFIX}_TEST_FRAMEWORK "${THIRD_PARTY_LIB}")
        mystic_message(STATUS "Using auto-detected test framework: ${THIRD_PARTY_LIB}.")
        return()
      endif()
    endforeach()
  endif()

  mystic_message(FATAL_ERROR "No valid test framework found in project.json dependencies."
                             "Please specify a test framework using the TEST_FRAMEWORK argument.")
endfunction()

# --------------------------------------------------------------------------------------------------
# Function: mystic_test
# Description: This function adds a test target to the CMake project. It automatically links the
# test target with the necessary testing framework libraries (e.g., Google Test, Catch2) and
# discovers the test executable for CTest.
# Args:
#   TARGET: The name of the test target to be added.
#   SOURCES: The source files for the test target.
#   DEPENDENCIES: Optional argument to specify additional dependencies for the test target.
#   NO_MAIN: Optional flag to not link the test target with the main function of the testing
#            framework, e.g., when it is used it links against Ctach2::Catch2 instead of
#            Catch2::Catch2WithMain.
# --------------------------------------------------------------------------------------------------
function(mystic_test TARGET)
  # Get project prefix
  get_property(PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  if(NOT PROJECT_PREFIX)
    mystic_message(FATAL_ERROR "Project prefix not set. Ensure that 'mystic_project' is called before 'mystic_test'.")
  endif()

  # Get the test framework from the directory property
  get_property(TEST_FRAMEWORK DIRECTORY PROPERTY _${PROJECT_PREFIX}_TEST_FRAMEWORK)

  # If tests are not enabled, skip adding the test targets.
  if (NOT ${PROJECT_PREFIX}_ENABLE_TESTING)
    mystic_message(STATUS "Tests are disabled for the ${PROJECT_PREFIX} project. Skipping test target ${TARGET}.")
    return()
  endif()

  if(NOT TEST_FRAMEWORK)
    mystic_message(FATAL_ERROR "Test framework not set. Please call mystic_enable_testing() before adding test targets.")
  endif()

  set(options "NO_MAIN")
  set(oneValueArgs "")
  set(multiValueArgs "SOURCES" "DEPENDENCIES")

  cmake_parse_arguments(
    ARG
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  if(ARG_UNPARSED_ARGUMENTS)
    mystic_message(FATAL_ERROR "mystic_test received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT ARG_SOURCES)
    mystic_message(FATAL_ERROR "mystic_test requires SOURCES argument to specify the source files for the test target.")
  endif()

  # Create the test target
  add_executable(${TARGET} ${ARG_SOURCES})

  # Link the test target with the specified test framework
  if(TEST_FRAMEWORK STREQUAL "catch2")
    if(ARG_NO_MAIN)
      target_link_libraries(${TARGET} PRIVATE Catch2::Catch2)
    else()
      target_link_libraries(${TARGET} PRIVATE Catch2::Catch2WithMain)
    endif()
  elseif(TEST_FRAMEWORK STREQUAL "gtest")
    if(ARG_NO_MAIN)
      target_link_libraries(${TARGET} PRIVATE GTest::gtest)
    else()
      target_link_libraries(${TARGET} PRIVATE GTest::gtest GTest::gtest_main)
    endif()
  else()
    mystic_message(FATAL_ERROR "Unsupported test framework: ${TEST_FRAMEWORK}. Supported frameworks are: catch2, gtest.")
  endif()

  # Link additional dependencies if specified
  if(ARG_DEPENDENCIES)
    target_link_libraries(${TARGET} PRIVATE ${ARG_DEPENDENCIES})
  endif()

  # Discover the test executable for CTest
  if(TEST_FRAMEWORK STREQUAL "catch2")
    FetchContent_GetProperties(catch2 SOURCE_DIR _MYSTIC_CATCH2_SRC)
    if(_MYSTIC_CATCH2_SRC)
      list(APPEND CMAKE_MODULE_PATH "${_MYSTIC_CATCH2_SRC}/extras")
    elseif(Catch2_DIR)
      list(APPEND CMAKE_MODULE_PATH "${Catch2_DIR}")
    else()
      mystic_message(FATAL_ERROR "Catch2 CMake modules not found (neither fetched nor system-installed).")
    endif()
    include(Catch)
    get_filename_component(_CXX_BIN "${CMAKE_CXX_COMPILER}" DIRECTORY)
    catch_discover_tests(${TARGET} DL_PATHS "${_CXX_BIN}")
  elseif(TEST_FRAMEWORK STREQUAL "gtest")
    include(GoogleTest)
    gtest_discover_tests(${TARGET})
  endif()
endfunction()
