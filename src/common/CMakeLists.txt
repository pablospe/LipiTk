cmake_minimum_required(VERSION 2.6)
set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR}/../.. )
include( ${LIPI_ROOT}/global.cmake )

project(common)

# Sources
file( GLOB sources  "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp" )

# Include
include_directories( ${LIPITK_SRC_INCLUDE} ${LIPITK_SRC_UTILS_LIB} )

# Static
add_library( common ${sources} )

