include(CheckFunctionExists)
include(CheckLibraryExists)

####################################################################
##
####################################################################
function( _force_include_headers target_name )
    foreach( include_file ${ARGN} )
        if (CMAKE_C_COMPILER_ID STREQUAL "Clang" OR CMAKE_C_COMPILER_ID STREQUAL "GNU")
            target_compile_options( ${target_name} PUBLIC -include ${include_file} )
        elseif(CMAKE_C_COMPILER_ID STREQUAL "MSVC"
            AND MSVC_VERSION GREATER_EQUAL "1700")
            # For MSVC compiler, supported back as far as Visual Studio 2012 from what I can tell
            # See: https://docs.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-2012/8c5ztk84(v=vs.110)
            # For version mapping: https://en.wikipedia.org/wiki/Microsoft_Visual_C%2B%2B#Internal_version_numbering
            target_compile_options( ${target_name} PUBLIC /FI ${include_file} )
        endif()
    endforeach()
endfunction()

####################################################################
##
####################################################################
function(FIND_FUNCTION_IN_LIBRARY function_name out_variable)
    set(have_var HAVE_${out_variable})
    set(lib_var ${out_variable}_LIB)

    if(EXISTS ${have_var})
        return()
    endif()
    
    CHECK_FUNCTION_EXISTS(${function_name} ${have_var})
    if(NOT ${have_var})
        foreach(lib ${ARGN})
            CHECK_LIBRARY_EXISTS(${lib} ${function_name} "" _have_in_lib)
            if(_have_in_lib)
                set(${have_var} TRUE CACHE INTERNAL "")
                set(${lib_var} ${lib} CACHE INTERNAL "")
                break()
            endif()
        endforeach()
        
        # Will set it to FALSE if the loop above didn't find the function in any library
        set(${have_var} FALSE CACHE INTERNAL "")
    endif()
    
    #if(${have_var})
    #    message
    #else()
    #endif()
endfunction()
