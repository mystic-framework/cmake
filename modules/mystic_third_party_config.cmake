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
# mystic_third_party_config("my_lib" "v1.2.3" "https://github.com/username/repo.git")
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Desc: Function to include a third party dependency in the project.
# Args:
#   LIB_NAME: Name of the library, e.g., Catch2.
#   LIB_VER: Version of the library, e.g., 2.13.7.
#   GIT_URL: URL of the Git repository.
#   GIT_TAG: Library's Git Tag. (Optional, defaults to the VER provided)
# -------------------------------------------------------------------------------------------------
function(mystic_third_party_config LIB_NAME LIB_VER GIT_URL)
  # Check if a Git tag is provided, else use the version as the tag
  if(ARGC GREATER 3 AND DEFINED ARGV3)
    set(GIT_TAG ${ARGV3})
  else()
    set(GIT_TAG ${LIB_VER})
  endif()

  # Check for system-installed if option is set
  string(TOUPPER "${LIB_NAME}" LIB_NAME_UPPER)
  if(MYSTIC_USE_SYSTEM_${LIB_NAME_UPPER})
    message(STATUS "[MYSTIC] - Searching for system-installed ${LIB_NAME} ${LIB_VER}...")
    find_package(${LIB_NAME} ${LIB_VER} REQUIRED)
    message(STATUS "[MYSTIC] - System-installed ${LIB_NAME} ${LIB_VER} found.")
  else()
    # Fetch from Internet
    string(TOLOWER "${LIB_NAME}" LIB_NAME_LOWER)
    message(STATUS "[MYSTIC] - Fetching ${LIB_NAME} ${LIB_VER}...")
    include(FetchContent)
    FetchContent_Declare(
      ${LIB_NAME_LOWER}
        GIT_REPOSITORY ${GIT_URL}
        GIT_TAG        ${GIT_TAG}
    )
    FetchContent_MakeAvailable(${LIB_NAME_LOWER})
    message(STATUS "[MYSTIC] - ${LIB_NAME} ${LIB_VER} fetched.")
  endif()
endfunction()

# If we have to pass build flags to a library define then before using this.
# Example:
# set(MY_LIB_TEST OFF CACHE INTERNAL "Turn off my_lib's test suites.")
# ...
# include(mystic_third_party_config)
# mystic_third_party_config("my_lib" "v1.2.3" "https://github.com/username/repo.git")
