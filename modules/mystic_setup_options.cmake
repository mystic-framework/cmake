# -------------------------------------------------------------------------------------------------
# File: mystic_setup_options.cmake
# Desc: Contains options for the framework. This contains modular options generation.
# Auth: thedevmystic (Surya) <thedevmystic@gmail.com>
# Licence: Apache 2.0 License
# -------------------------------------------------------------------------------------------------
# Usage:
# include(path/to/mystic_setup_options)
# mystic_setup_options_for("My-Cool-Lib")
# mystic_setup_third_party_options_for("My-Cool-Lib" "Catch2" "Tracy" "Some-Super-Cool-Lib")
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Desc: Macro to define options.
# Args:
#  LIB_NAME: The name of the library.
# -------------------------------------------------------------------------------------------------
function(mystic_setup_options_for LIB_NAME)
  # my-lib -> MY_LIB
  string(REPLACE "-" "_" _LIB_NAME "${LIB_NAME}")
  string(TOUPPER "${_LIB_NAME}" _LIB_NAME)

  # Build Type
  # Valid options: Debug, Release, MinSizeRel, RelWithDebInfo.
  set(${_LIB_NAME}_BUILD_TYPE "Release" CACHE STRING "Build type.")
  set_property(CACHE ${_LIB_NAME}_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")

  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "${${_LIB_NAME}_BUILD_TYPE}" CACHE STRING "Build type." FORCE)
  endif()

  # Static/Shared Library
  option(${_LIB_NAME}_BUILD_SHARED_LIBS "Build shared libraries (static, if OFF)." ON)

  # Map correct lib type
  if(${_LIB_NAME}_BUILD_SHARED_LIBS)
    set(${_LIB_NAME}_LIB_TYPE SHARED PARENT_SCOPE)
  else()
    set(${_LIB_NAME}_LIB_TYPE STATIC PARENT_SCOPE)
  endif()
  
  # Toggles
  option(${_LIB_NAME}_ENABLE_BENCHMARKS "Build benchmarks."                OFF)
  option(${_LIB_NAME}_ENABLE_COVERAGE   "Build code coverage."             OFF)
  option(${_LIB_NAME}_ENABLE_DOCS       "Build documentation."             ON)
  option(${_LIB_NAME}_ENABLE_EXAMPLES   "Build example programs."          ON)
  option(${_LIB_NAME}_ENABLE_LTO        "Enable Link Time Optimization."   OFF)
  option(${_LIB_NAME}_ENABLE_LINT       "Enable static code analysis."     OFF) # clang-tidy, clang-format, cppcheck.
  option(${_LIB_NAME}_ENABLE_NARCH      "Enable host CPU optimization."    OFF)
  option(${_LIB_NAME}_ENABLE_PROFILER   "Enable profiling."                OFF)
  option(${_LIB_NAME}_ENABLE_SANITIZERS "Enable sanitizers."               OFF) # ASan, UBSan, TSan, MSan.
  option(${_LIB_NAME}_ENABLE_TESTING    "Build test suites."               ON)
  option(${_LIB_NAME}_ENABLE_WARNINGS   "Enable strict compiler warnings." OFF)

  # Sanitizer Type
  # Valid Options: Address, Undefined, Thread, Memory
  set(${_LIB_NAME}_SANITIZER_TYPE "Address" CACHE STRING "Sanitizer type.")
  set_property(CACHE ${_LIB_NAME}_SANITIZER_TYPE PROPERTY STRINGS "Address" "Undefined" "Thread" "Memory")

  # Installation Options
  option(${_LIB_NAME}_INSTALL "Enable installation of the library." OFF)

  # Whether it is being built as a part of larger project.
  option(${_LIB_NAME}_INTERNAL "Whether this library is being built as part of a larger project." OFF)
endfunction()

# -------------------------------------------------------------------------------------------------
# Desc: Macro to define third party libs options.
# Args:
#  LIB_NAME: The name of the library (main library).
#  ...: List of all third party libraries.
# -------------------------------------------------------------------------------------------------
function(mystic_setup_third_party_options_for LIB_NAME)
  string(REPLACE "-" "_" _LIB_NAME "${LIB_NAME}")
  string(TOUPPER "${_LIB_NAME}" _LIB_NAME)

  # Toggles all third-party library to use system-installed version
  option(${_LIB_NAME}_USE_SYSTEM "Use system-installed libraries." OFF)

  # Check if the master toggle changed since the last CMake configure run
  set(_PREV_STATE_VAR "_${_LIB_NAME}_USE_SYSTEM_PREV")
  
  set(_MASTER_CHANGED FALSE)
  if(NOT DEFINED ${_PREV_STATE_VAR} OR NOT "${${_PREV_STATE_VAR}}" STREQUAL "${${_LIB_NAME}_USE_SYSTEM}")
    set(_MASTER_CHANGED TRUE)
    set(${_PREV_STATE_VAR} "${${_LIB_NAME}_USE_SYSTEM}" CACHE INTERNAL "Previous state of ${_LIB_NAME}_USE_SYSTEM")
  endif()

  foreach(_LIB IN LISTS ARGN)
    string(REPLACE "-" "_" _LIB_FORMATTED "${_LIB}")
    string(TOUPPER "${_LIB_FORMATTED}" _LIB_FORMATTED)
    set(_OPT_VAR "${_LIB_NAME}_USE_SYSTEM_${_LIB_FORMATTED}")

    # If the user flipped the master USE_SYSTEM switch, propagate it to all children
    if(_MASTER_CHANGED)
      set(${_OPT_VAR} ${${_LIB_NAME}_USE_SYSTEM} CACHE BOOL "Use system-installed ${_LIB}." FORCE)
    else()
      option(${_OPT_VAR} "Use system-installed ${_LIB}." OFF)
    endif()
  endforeach()
endfunction()
