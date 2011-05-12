cmake_minimum_required(VERSION 2.8)

set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR}/../../.. )
include( ${LIPI_ROOT}/CMake/global.cmake )

add_subdirectory( ${LIPITK_SHAPEREC_ACTIVEDTW} )
add_subdirectory( ${LIPITK_SHAPEREC_COMMON} )
add_subdirectory( ${LIPITK_SHAPEREC_FE} )
add_subdirectory( ${LIPITK_SHAPEREC_NEURALNET} )
add_subdirectory( ${LIPITK_SHAPEREC_NN} )
add_subdirectory( ${LIPITK_SHAPEREC_PREPROC} )
