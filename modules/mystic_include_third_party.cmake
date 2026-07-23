# -------------------------------------------------------------------------------------------------
# File: mystic_include_third_party.cmake
# Desc: Facilitates the inclusion of third-party libraries in a CMake project. It scans the
#       specified root directory for subdirectories containing CMakeLists.txt files, adds them,
#       and copies any license files found to a designated output directory.
# Auth: thedevmystic (Surya) <thedevmystic@gmail.com>
# Licence: Apache 2.0 License
# -------------------------------------------------------------------------------------------------
# Usage:
# include(path/to/mystic_include_third_party)
# mystic_include_third_party(${CMAKE_CURRENT_SOURCE_DIR}/third_party)
# -------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")

# -------------------------------------------------------------------------------------------------
# Desc: This function scans a specified root directory for third-party libraries and process them.
# Args:
#   ROOT_DIR: The root directory containing third-party libraries.
#             Defaults to: ${CMAKE_CURRENT_SOURCE_DIR}/third_party.
# -------------------------------------------------------------------------------------------------
function(mystic_include_third_party)
  # Determine the root directory for third-party libraries
  if(ARGC EQUAL 0)
    set(ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third_party")
  else()
    set(ROOT_DIR "${ARGV0}")
  endif()

  # Copies license to licenses directory in the build folder
  set(LICENSE_OUTPUT_DIR "${CMAKE_BINARY_DIR}/licenses")

  mystic_message(STATUS "Scanning for third-party libraries...")

  # Find all CMakeLists.txt files recursively in third_party
  file(GLOB_RECURSE CMAKE_FILES CONFIGURE_DEPENDS RELATIVE "${ROOT_DIR}" "${ROOT_DIR}/**/CMakeLists.txt")

  foreach(CMAKE_FILE IN LISTS CMAKE_FILES)
    # Get the relative directory path (e.g., "libfoo" out of "libfoo/CMakeLists.txt")
    get_filename_component(SUB_DIR "${CMAKE_FILE}" DIRECTORY)

    # Skip the root directory itself if it accidentally matches
    if(SUB_DIR STREQUAL "")
      continue()
    endif()

    set(FULL_SUB_DIR_PATH "${ROOT_DIR}/${SUB_DIR}")
    get_filename_component(DIR_NAME "${SUB_DIR}" NAME)

    mystic_message(STATUS "Processing third-party library: ${DIR_NAME}...")
    # Add the subdirectory to the build layout
    add_subdirectory("${FULL_SUB_DIR_PATH}" "${CMAKE_BINARY_DIR}/third_party/${DIR_NAME}")
    mystic_message(STATUS "Processed third-party library: ${FULL_SUB_DIR_PATH}")

    # Find and copy the License file
    file(GLOB LICENSE_FILES 
      "${FULL_SUB_DIR_PATH}/*LICENSE*" 
      "${FULL_SUB_DIR_PATH}/*LICENCE*" 
      "${FULL_SUB_DIR_PATH}/*COPYING*"
    )

    mystic_message(STATUS "Copying license files for ${DIR_NAME}...")
    foreach(LICENSE_FILE IN LISTS LICENSE_FILES)
        get_filename_component(LICENSE_FILENAME "${LICENSE_FILE}" NAME)

        # Copy the license file to the build directory immediately
        configure_file("${LICENSE_FILE}" "${LICENSE_OUTPUT_DIR}/${SUB_DIR}_${LICENSE_FILENAME}" COPYONLY)
    endforeach()
    mystic_message(STATUS "Copied license files for ${DIR_NAME}.")
  endforeach()
  mystic_message(STATUS "Finished processing all third-party libraries.")
endfunction()
