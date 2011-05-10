cmake_minimum_required(VERSION 2.6)
set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR}/../../../.. )
include( ${LIPI_ROOT}/global.cmake )


project(wordreccommon)

# Sources
file( GLOB sources  "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp" )

# Include
include_directories( ${LIPITK_COMMON}
                     ${LIPITK_SRC_UTILS_LIB}
                     ${LIPITK_SRC_INCLUDE} )

# Static
add_library( wordreccommon ${sources} )

