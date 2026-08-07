# -------------------------------------------------------------------------------------------------
# File: mystic_third_party_config.cmake
# Desc: Defines a function to include a third party dependency in the project.
#       It checks for system-installed libraries first (if enabled), and if not found, fetches the 
#       library from GitHub using FetchContent.
# Auth: thedevmystic (Surya) <thedevmystic@gmail.com>
# Licence: Apache 2.0 License
# -------------------------------------------------------------------------------------------------
# Usage:
# include(path/to/mystic_third_party_config)
# mystic_third_party_config(
#   LIB_NAME "my_third_party_lib"
#   LIB_VER "v1.2.3"
#   GIT_URL "https://github.com/username/repo.git"
#   GIT_TAG "main"
#   USE_SYSTEM ${MY_COOL_LIB_USE_SYSTEM_MY_THIRD_PARTY_LIB}
# )
# -------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")

# -------------------------------------------------------------------------------------------------
# Desc: Function to include a third party dependency in the project.
# Args:
#   LIB_NAME: Name of the library, e.g., Catch2.
#   LIB_VER: Version of the library, e.g., 2.13.7.
#   GIT_URL: URL of the Git repository.
#   GIT_TAG: Library's Git Tag. (Optional, defaults to the VER provided)
#   USE_SYSTEM: Whether to use system or not.
# -------------------------------------------------------------------------------------------------
function(mystic_third_party_config)
  set(options "")
  set(singleValueArgs "LIB_NAME" "LIB_VER" "GIT_URL" "GIT_TAG" "USE_SYSTEM")
  set(multiValueArgs "")

  cmake_parse_arguments(
    ARG
    "${options}"
    "${singleValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  if(ARG_UNPARSED_ARGUMENTS)
    mystic_message(FATAL_ERROR "mystic_third_party_config received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  # Validate Args
  if(NOT DEFINED ARG_LIB_NAME)
    mystic_message(FATAL_ERROR "LIB_NAME not defined in mystic_third_party_config.")
  endif()
  if(NOT DEFINED ARG_LIB_VER)
    mystic_message(FATAL_ERROR "LIB_VER not defined in mystic_third_party_config.")
  endif()
  if(NOT DEFINED ARG_GIT_URL)
    mystic_message(FATAL_ERROR "GIT_URL not defined in mystic_third_party_config.")
  endif()

  # Check if a Git tag is provided, else use the version as the tag
  if(NOT DEFINED ARG_GIT_TAG)
    set(ARG_GIT_TAG ${ARG_LIB_VER})
  endif()

  # Check for system-installed if option is set
  string(TOUPPER "${ARG_LIB_NAME}" LIB_NAME_UPPER)
  if(DEFINED ARG_USE_SYSTEM AND ARG_USE_SYSTEM)
    mystic_message(STATUS "Searching for system-installed ${ARG_LIB_NAME} ${ARG_LIB_VER}...")
    find_package(${ARG_LIB_NAME} ${ARG_LIB_VER} REQUIRED)
    mystic_message(STATUS "System-installed ${ARG_LIB_NAME} ${ARG_LIB_VER} found.")
  else()
    # Fetch from Internet
    string(TOLOWER "${ARG_LIB_NAME}" LIB_NAME_LOWER)
    mystic_message(STATUS "Fetching ${ARG_LIB_NAME} ${ARG_LIB_VER}...")
    include(FetchContent)
    FetchContent_Declare(
      ${LIB_NAME_LOWER}
        GIT_REPOSITORY ${ARG_GIT_URL}
        GIT_TAG        ${ARG_GIT_TAG}
    )
    FetchContent_MakeAvailable(${LIB_NAME_LOWER})
    mystic_message(STATUS "${ARG_LIB_NAME} ${ARG_LIB_VER} fetched.")
  endif()
endfunction()

# If we have to pass build flags to a library define then before using this.
# Example:
# set(MY_LIB_TEST OFF CACHE INTERNAL "Turn off my_lib's test suites.")
# ...
# include(mystic_third_party_config)
# mystic_third_party_config(
#   LIB_NAME "my_lib"
#   LIB_VER "v1.2.3"
#   GIT_URL "https://github.com/username/repo.git"
#   GIT_TAG "main"
# )
