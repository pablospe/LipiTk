cmake_minimum_required(VERSION 2.8.3)

set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR}/.. )
include( ${LIPI_ROOT}/CMake/global.cmake )

add_subdirectory( ${LIPITK_COMMON} )
add_subdirectory( ${LIPITK_LIPIENGINE} )
add_subdirectory( ${LIPITK_RECO} )
add_subdirectory( ${LIPITK_SRC_UTILS} )