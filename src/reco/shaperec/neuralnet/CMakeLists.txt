cmake_minimum_required(VERSION 2.8)

project(neuralnet)

set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR}/../../../.. )
include( ${LIPI_ROOT}/CMake/shared_lib_common.cmake )

# Include
include_directories( ${LIPITK_SHAPEREC_FE_COMMON}
                     ${LIPITK_SHAPEREC_COMMON} )

