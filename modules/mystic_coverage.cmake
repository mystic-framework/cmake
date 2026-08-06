# -------------------------------------------------------------------------------------------------
# File: mystic_coverage.cmake
# Desc: Adds proper compile options to the target for coverage generation.
# Auth: thedevmystic (Surya) <thedevmystic@gmail.com>
# Licence: Apache 2.0 License
# -------------------------------------------------------------------------------------------------
# Usage:
# include(path/to/mystic_coverage)
# mystic_coverage(
#  ENABLE <YOUR_COVERAGE_OPTION>
#  TARGETS <target1> <target2> ...
# )
# -------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")

# -------------------------------------------------------------------------------------------------
# Desc: Function to enable coverage conditionally.
# Args:
#   ENABLE: Whether enable it or not (provide your control option).
#   TARGETS: The actual targets for coverage.
# -------------------------------------------------------------------------------------------------
function(mystic_coverage)
  set(options "")
  set(singleValueArgs ENABLE)
  set(multiValueArgs TARGETS)

  cmake_parse_arguments(
    ARG
    "${options}"
    "${singleValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  if(ARG_UNPARSED_ARGUMENTS)
    mystic_message(FATAL_ERROR "mystic_coverage received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  if(DEFINED ARG_ENABLE AND ARG_ENABLE)
    # Guard against empty list
    if(NOT ARG_TARGETS)
      mystic_message(FATAL_ERROR "ENABLE was specified but TARGETS list is empty in mystic_coverage.")
    endif()

    foreach(target IN LISTS ARG_TARGETS)
      # Guard against invalid targets
      if(NOT TARGET "${target}")
        mystic_message(FATAL_ERROR "'${target}' provided in 'mystic_coverage' is not a valid CMake target.")
      endif()

      mystic_message(NOTICE "Adding coverage flags to the following targets: ${target}")
      
      if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
          target_compile_options(${target} PRIVATE -fprofile-instr-generate -fcoverage-mapping -O0 -g)
          target_link_options(${target} PRIVATE -fprofile-instr-generate)
      elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
          target_compile_options(${target} PRIVATE --coverage -O0 -g)
          target_link_options(${target} PRIVATE --coverage)
      else()
        mystic_message(FATAL_ERROR "Coverage is only supported in Clang and GCC.")
      endif()
    endforeach()
  endif()
endfunction()
