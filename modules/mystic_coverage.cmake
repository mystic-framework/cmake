# -------------------------------------------------------------------------------------------------
# File: mystic_coverage.cmake
# Desc: Adds proper compile options to the target for coverage generation.
# Auth: thedevmystic (Surya) <thedevmystic@gmail.com>
# Licence: Apache 2.0 License
# -------------------------------------------------------------------------------------------------
# Usage:
# include(path/to/mystic_coverage)
# mystic_coverage(<main_target> <other_targets...>)
# -------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")

function(mystic_coverage MAIN_TARGET)
  if(MYSTIC_ENABLE_COVERAGE)
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")

      message(NOTICE "[MYSTIC] - Adding coverage flags to the following targets: ${MAIN_TARGET} ${ARGN}")

      target_compile_options(${MAIN_TARGET} PUBLIC --coverage -O0 -g)
      target_link_options(${MAIN_TARGET} PUBLIC --coverage)

      foreach(target IN LISTS ARGN)
        target_compile_options(${target} PRIVATE --coverage -O0 -g)
        target_link_options(${target} PRIVATE --coverage)
      endforeach()

    else()
      mystic_message(WARNING "Coverage is only supported in Clang and GCC. Disabling 'MYSTIC_ENABLE_COVERAGE'...")
      set(MYSTIC_ENABLE_COVERAGE OFF CACHE BOOL "" FORCE)
    endif()
  endif()
endfunction()
