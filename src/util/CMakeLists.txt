cmake_minimum_required(VERSION 2.8)

set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR}/../.. )
include( ${LIPI_ROOT}/CMake/global.cmake )

add_subdirectory( ${LIPITK_LOGGER} )
add_subdirectory( ${LIPITK_SRC_UTILS_LIB} )
add_subdirectory( ${LIPITK_SRC_UTILS_FFW} )
add_subdirectory( ${LIPITK_SRC_UTILS_IMGWRITER} )
add_subdirectory( ${LIPITK_SRC_UTILS_MDV} )

add_subdirectory( ${LIPITK_SRC_UTILS_RUN} )
