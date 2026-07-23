# -------------------------------------------------------------------------------------------------
# File: mystic_include_modules.cmake
# Desc: Facilitates the inclusion of modules (first-party libraries) in a CMake project.
# Auth: thedevmystic (Surya) <thedevmystic@gmail.com>
# Licence: Apache 2.0 License
# -------------------------------------------------------------------------------------------------
# Usage:
# include(path/to/mystic_include_modules)
# mystic_include_modules(${CMAKE_CURRENT_SOURCE_DIR}/modules)
# -------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")

# -------------------------------------------------------------------------------------------------
# Desc: This function scans a specified root directory for modules and process them.
# Args:
#   ROOT_DIR: The root directory containing modules.
#             Defaults to: ${CMAKE_CURRENT_SOURCE_DIR}/modules.
# -------------------------------------------------------------------------------------------------
function(mystic_include_modules)
  # Determine the root directory for modules
  if(ARGC EQUAL 0)
    set(ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/modules")
  else()
    set(ROOT_DIR "${ARGV0}")
  endif()

  mystic_message(STATUS "Scanning for modules...")

  # Find all CMakeLists.txt files recursively in modules
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

    # Add the subdirectory to the build layout
    add_subdirectory("${FULL_SUB_DIR_PATH}" "${CMAKE_BINARY_DIR}/modules/${DIR_NAME}")
  endforeach()
  mystic_message(STATUS "Finished importing all modules.")
endfunction()
