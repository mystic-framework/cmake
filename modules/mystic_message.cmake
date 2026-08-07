# -------------------------------------------------------------------------------------------------
# File: mystic_message.cmake
# Desc: Wrapper around CMake's message but adds control options.
# Auth: thedevmystic (Surya) <thedevmystic@gmail.com>
# Licence: Apache 2.0 License
# -------------------------------------------------------------------------------------------------
# Usage:
# include(path/to/mystic_message)
# mystic_message(LEVEL "This is a message!")
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Desc: This function wraps around CMake's message command.
# Args:
#   LEVEL: The message level (e.g., STATUS, WARNING, FATAL_ERROR). Same as CMake's message command.
#   MESSAGE: The message to display.
# -------------------------------------------------------------------------------------------------
function(mystic_message LEVEL MESSAGE)
  # MODE 1: Disabled
  if(MYSTIC_MESSAGE_DISABLE)
    return()
  endif()

  # MODE 2: Only Errors
  if(MYSTIC_MESSAGE_ONLY_ERRORS)
    if(LEVEL STREQUAL "FATAL_ERROR" OR LEVEL STREQUAL "SEND_ERROR")
      message(${LEVEL} "[MYSTIC] - ${MESSAGE}" "${ARGN}")
    endif()
    return()
  endif()

  # MODE 3: Normal
  message(${LEVEL} "[MYSTIC] - ${MESSAGE}" "${ARGN}")
endfunction()
