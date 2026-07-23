# -------------------------------------------------------------------------------------------------
# File: mystic_message.cmake
# Desc: Wrapper around CMake's message but it's turns off when MYSTIC_INTERNAL is set to ON.
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
  if(NOT MYSTIC_INTERNAL)
    message(${LEVEL} "[MYSTIC] - ${MESSAGE}")
  endif()
endfunction()
