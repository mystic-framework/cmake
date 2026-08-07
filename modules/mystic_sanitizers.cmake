# -------------------------------------------------------------------------------------------------
# File: mystic_sanitizers.cmake
# Desc: Enables and prepares target with sanitizers.
# Auth: thedevmystic (Surya) <thedevmystic@gmail.com>
# Licence: Apache 2.0 License
# -------------------------------------------------------------------------------------------------
# Usage:
# include(path/to/mystic_sanitizers)
# mystic_sanitizers(
#   ENABLE <YOUR_SANITIZERS_CONTROL_OPTION>
#   SANITIZER <SANITIZER_VARIANT>
#   TARGETS <LIST_OF_TARGETS>
# )
# -------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")

set(_MYSTIC_VALID_SANITIZERS "address" "undefined" "thread" "memory")

# Internal helpers to add correct flags
# ASan
macro(_mystic_internal_add_address_san ARG_TARGET)
  if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    target_compile_options(${ARG_TARGET} PRIVATE /fsanitize=address /Zi)
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(${ARG_TARGET} PRIVATE -fsanitize=address -g -fno-omit-frame-pointer)
    target_link_options(${ARG_TARGET} PRIVATE -fsanitize=address)
  else()
    mystic_message(WARNING "Unknown compiler. Skip adding sanitizer flags...")
  endif()
endmacro
# UBSan
macro(_mystic_internal_add_undefined_san ARG_TARGET)
  if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    mystic_message(FATAL_ERROR "UndefinedBehaviorSanitizer is not available in MSVC.")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(${ARG_TARGET} PRIVATE -fsanitize=undefined -g -fno-omit-frame-pointer)
    target_link_options(${ARG_TARGET} PRIVATE -fsanitize=undefined)
  else()
    mystic_message(WARNING "Unknown compiler. Skip adding sanitizer flags...")
  endif()
endmacro
# TSan
macro(_mystic_internal_add_thread_san ARG_TARGET)
  if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    mystic_message(FATAL_ERROR "ThreadSanitizer is not available in MSVC.")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(${ARG_TARGET} PRIVATE -fsanitize=thread -g -fno-omit-frame-pointer)
    target_link_options(${ARG_TARGET} PRIVATE -fsanitize=thread)
  else()
    mystic_message(WARNING "Unknown compiler. Skip adding sanitizer flags...")
  endif()
endmacro
# MSan
macro(_mystic_internal_add_memory_san ARG_TARGET)
  if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    mystic_message(FATAL_ERROR "MemorySanitizer is not available in MSVC.")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    mystic_message(FATAL_ERROR "MemorySanitizer is not available in GCC.")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    target_compile_options(${ARG_TARGET} PRIVATE -fsanitize=memory -g -fno-omit-frame-pointer)
    target_link_options(${ARG_TARGET} PRIVATE -fsanitize=memory)
  else()
    mystic_message(WARNING "Unknown compiler. Skip adding sanitizer flags...")
  endif()
endmacro

# -------------------------------------------------------------------------------------------------
# Desc: Enables and preapres targets with specified sanitizer.
# Args:
#   ENABLE: Whether to enable sanitizers or not.
#   SANITIZER: The variant of sanitizer to enable (must be valid sanitizer variant).
#   TARGETS: List of targets.
# -------------------------------------------------------------------------------------------------
function(mystic_sanitizers)
  set(options "")
  set(singleValueArgs "ENABLE" "SANITIZER")
  set(multiValueArgs "TARGETS")

  cmake_parse_arguments(
    ARG
    "${options}"
    "${singleValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  if(ARG_UNPARSED_ARGUMENTS)
    mystic_message(FATAL_ERROR "mystic_sanitizers received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  # if not enable exit
  if(NOT ARG_ENABLE)
    return()
  endif()

  # Check for sanitizer validity
  string(TOLOWER "${ARG_SANITIZER}" ARG_SANITIZER)
  list(FIND _MYSTIC_VALID_SANITIZERS ${ARG_SANITIZER} _INDEX)
  if(_INDEX EQUAL -1)
    mystic_message(FATAL_ERROR "Invalid sanitizer variant passed: ${ARG_SANITIZER}. Please check the list of valid sanitizers.")
  endif()

  # Check if TARGETS is empty
  if(NOT ARG_TARGETS)
    mystic_message(FATAL_ERROR "Empty TARGETS list was provided in mystic_sanitizers.")
  endif()

  # Enable the given sanitizer for given targets
  foreach(target IN LISTS ARG_TARGETS)
    # Check if given target is a valid target
    if(NOT TARGET "${target}")
        mystic_message(FATAL_ERROR "'${target}' provided in 'mystic_sanitizers' is not a valid CMake target.")
    endif()
    
    if(ARG_SANITIZER STREQUAL "address")
      _mystic_internal_add_address_san("${target}")
    elseif(ARG_SANITIZER STREQUAL "undefined")
      _mystic_internal_add_undefined_san("${target}")
    elseif(ARG_SANITIZER STREQUAL "thread")
      _mystic_internal_add_thread_san("${target}")
    elseif(ARG_SANITIZER STREQUAL "memory")
      _mystic_internal_add_memory_san("${target}")
    endif()
  endforeach()
endfunction()
