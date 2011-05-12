cmake_minimum_required(VERSION 2.8)

set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR}/../../../.. )
include( ${LIPI_ROOT}/CMake/global.cmake )

add_subdirectory( ${LIPITK_SHAPEREC_FE_COMMON} )
add_subdirectory( ${LIPITK_SHAPEREC_FE_L7} )
add_subdirectory( ${LIPITK_SHAPEREC_FE_NPEN} )
add_subdirectory( ${LIPITK_SHAPEREC_FE_POINTFLOAT} )
add_subdirectory( ${LIPITK_SHAPEREC_FE_SS} )
