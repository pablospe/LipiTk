cmake_minimum_required(VERSION 2.8)

set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR}/../.. )
include( ${LIPI_ROOT}/CMake/global.cmake )

add_subdirectory( ${LIPITK_SHAPEREC} )
add_subdirectory( ${LIPITK_WORDREC} )

