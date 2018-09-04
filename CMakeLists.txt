cmake_minimum_required(VERSION 3.12)

set(CMAKE_CXX_STANDARD 17)

project(ccache LANGUAGES C CXX)

include(cmake/utilities.cmake)

option(CCACHE_USE_BUNDLED_ZLIB "Use the bundled zlib source code or find it on the system" ON)
option(CCACHE_DEVELOPER_MODE "Enables certain developer features" OFF)

if(MSVC)
    # Enable parallel builds in Visual Studio
    add_compile_options(/MP)
endif()

find_package(Boost REQUIRED)

add_executable(ccache
    src/args.cpp
    src/ccache.cpp
    src/ccache.hpp
    src/cleanup.cpp
    src/compopt.cpp
    src/compopt.hpp
    src/conf.cpp
    src/conf.hpp
    src/confitems_lookup.cpp
    src/counters.cpp
    src/counters.hpp
    src/envtoconfitems_lookup.cpp
    src/execute.cpp
    src/exitfn.cpp
    src/getopt_long.cpp
    src/getopt_long.hpp
    src/hash.cpp
    src/hashtable.cpp
    src/hashtable.hpp
    src/hashtable_itr.cpp
    src/hashtable_itr.hpp
    src/hashtable_private.hpp
    src/hashutil.cpp
    src/hashutil.hpp
    src/language.cpp
    src/language.hpp
    src/lockfile.cpp
    src/macroskip.hpp
    src/main.cpp
    src/manifest.cpp
    src/manifest.hpp
    src/mdfour.cpp
    src/mdfour.hpp
    src/murmurhashneutral2.cpp
    src/murmurhashneutral2.hpp
    src/snprintf.cpp
    src/stats.cpp
    src/system.hpp
    src/unify.cpp
    src/util.cpp
)

target_link_libraries(ccache PUBLIC Boost::Boost)

####################################################################
## System Introspection (config.h)
####################################################################
include(CheckIncludeFiles)
include(CheckTypeSize)
include(CheckSymbolExists)
include(CheckFunctionExists)
include(CheckLibraryExists)

# TODO: AC_APPLE_UNIVERSAL_BUILD

CHECK_TYPE_SIZE("long long" LONG_LONG)
CHECK_TYPE_SIZE("long long int" LONG_LONG_INT)
CHECK_TYPE_SIZE("uintmax_t" UINTMAX_T)
CHECK_TYPE_SIZE("uintptr_t" UINTPTR_T)
CHECK_TYPE_SIZE("unsigned long long int" UNSIGNED_LONG_LONG_INT)
CHECK_TYPE_SIZE("intmax_t" INTMAX_T)

CHECK_INCLUDE_FILE(ctype.h HAVE_CTYPE_H)
CHECK_INCLUDE_FILE(pwd.h HAVE_PWD_H)
CHECK_INCLUDE_FILE(stdlib.h HAVE_STDLIB_H)
CHECK_INCLUDE_FILE(string.h HAVE_STRING_H)
CHECK_INCLUDE_FILE(strings.h HAVE_STRINGS_H)
CHECK_INCLUDE_FILE(termios.h HAVE_TERMIOS_H)
CHECK_INCLUDE_FILE(unistd.h HAVE_UNISTD_H)
CHECK_INCLUDE_FILE(varargs.h HAVE_VARARGS_H)
CHECK_INCLUDE_FILE(dirent.h HAVE_DIRENT_H)
CHECK_INCLUDE_FILE(inttypes.h HAVE_INTTYPES_H)
CHECK_INCLUDE_FILE(locale.h HAVE_LOCALE_H)
CHECK_INCLUDE_FILE(memory.h HAVE_MEMORY_H)
CHECK_INCLUDE_FILE(Windows.h HAVE_WINDOWS_H)
CHECK_INCLUDE_FILE(sys/time.h HAVE_SYS_TIME_H)
CHECK_INCLUDE_FILE(sys/mman.h HAVE_SYS_MMAN_H)
CHECK_INCLUDE_FILE(sys/file.h HAVE_SYS_FILE_H)
CHECK_INCLUDE_FILE(sys/dir.h HAVE_SYS_DIR_H)
CHECK_INCLUDE_FILE(sys/ndir.h HAVE_SYS_NDIR_H)
CHECK_INCLUDE_FILE(sys/stat.h HAVE_SYS_STAT_H)
CHECK_INCLUDE_FILE(sys/types.h HAVE_SYS_TYPES_H)
CHECK_INCLUDE_FILE(sys/wait.h HAVE_SYS_WAIT_H)
CHECK_INCLUDE_FILE(sys/file.h HAVE_SYS_FILE_H)

CHECK_FUNCTION_EXISTS(gethostname HAVE_GETHOSTNAME)
CHECK_FUNCTION_EXISTS(getopt_long HAVE_GETOPT_LONG)
CHECK_FUNCTION_EXISTS(getpwuid HAVE_GETPWUID)
CHECK_FUNCTION_EXISTS(gettimeofday HAVE_GETTIMEOFDAY)
CHECK_FUNCTION_EXISTS(mkstemp HAVE_MKSTEMP)
CHECK_FUNCTION_EXISTS(realpath HAVE_REALPATH)
CHECK_FUNCTION_EXISTS(strndup HAVE_STRNDUP)
CHECK_FUNCTION_EXISTS(strtok_r HAVE_STRTOK_R)
CHECK_FUNCTION_EXISTS(unsetenv HAVE_UNSETENV)
CHECK_FUNCTION_EXISTS(utimes HAVE_UTIMES)
CHECK_FUNCTION_EXISTS(localeconv HAVE_LOCALECONV)

# TODO:
# m4_include(m4/snprintf.m4)
# HW_FUNC_VSNPRINTF
# HW_FUNC_SNPRINTF
# HW_FUNC_VASPRINTF
# HW_FUNC_ASPRINTF

FIND_FUNCTION_IN_LIBRARY(cos COS m)

set(CCACHE_CONFIG_H ${CMAKE_CURRENT_BINARY_DIR}/config.h)
configure_file(config.h.in ${CCACHE_CONFIG_H})
target_include_directories(ccache PUBLIC ${CMAKE_CURRENT_BINARY_DIR})
target_sources(ccache PUBLIC ${CCACHE_CONFIG_H})

# Link additional libraries as needed, depending on functions found on the system
target_link_libraries(ccache PUBLIC ${COS_LIB})

####################################################################
## Include zlib (bundled or system)
####################################################################
if(CCACHE_USE_BUNDLED_ZLIB)
    add_subdirectory(src/zlib)
else()
    find_package(ZLIB 1.2.3 REQUIRED)
endif()

target_link_libraries(ccache PUBLIC ZLIB::ZLIB)

####################################################################
## Format version.c with version number
####################################################################
find_package(Git)
if(CCACHE_DEVELOPER_MODE AND GIT_FOUND)
    execute_process(
        COMMAND git describe --dirty
        OUTPUT_VARIABLE CCACHE_VERSION
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )

    # Format git describe version. Should go from `v3.4.3-45-g181298b` to `3.4.3+45_g181298b`
    # Replace 'v' with nothing
    string(REGEX REPLACE "^v([\d.]+)-(\d+)-g([\db]+)" "$1+$2_$3" CCACHE_VERSION "${CCACHE_VERSION}" )

    message(STATUS "Developer Mode Version: ${CCACHE_VERSION}")
endif()

if(NOT CCACHE_VERSION)
    set(CCACHE_VERSION unknown)
endif()

set(version_file ${CMAKE_CURRENT_BINARY_DIR}/src/version.c)
configure_file(src/version.c.in ${version_file})
target_sources(ccache PUBLIC ${version_file})
