cmake_minimum_required(VERSION 2.8.3)

project(runshaperec)

set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR}/../../../.. )
include( ${LIPI_ROOT}/CMake/global.cmake )
include( ${LIPI_ROOT}/CMake/binary_common.cmake )


target_link_libraries( ${PROJECT_NAME} stdc++ dl shaperecommon featureextractorcommon ${LIPITK_STATIC_LIB} )
