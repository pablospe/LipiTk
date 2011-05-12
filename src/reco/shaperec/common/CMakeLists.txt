cmake_minimum_required(VERSION 2.8)

project(shaperecommon)

set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR}/../../../.. )
include( ${LIPI_ROOT}/CMake/static_lib_common.cmake )

# Include
include_directories( ${LIPITK_SHAPEREC_FE_COMMON} )
