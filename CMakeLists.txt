cmake_minimum_required(VERSION 2.8)

set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR} )
include( ${LIPI_ROOT}/CMake/global.cmake )

add_subdirectory( ${LIPITK_SRC} )

# Headers
file( GLOB headers          "${LIPITK_SRC_INCLUDE}/*.h" )
file( GLOB headers_util     "${LIPITK_SRC_UTILS_LIB}/*.h" )

file( GLOB headers_shaperec "${LIPITK_SHAPEREC_ACTIVEDTW}/*.h"
                            "${LIPITK_SHAPEREC_COMMON}/*.h"
                            "${LIPITK_SHAPEREC_NEURALNET}/*.h"
                            "${LIPITK_SHAPEREC_NN}/*.h"
                            "${LIPITK_SHAPEREC_PREPROC}/*.h" )

file( GLOB headers_shaperec_featureextractor
                            "${LIPITK_SHAPEREC_FE_COMMON}/*.h"
                            "${LIPITK_SHAPEREC_FE_L7}/*.h"
                            "${LIPITK_SHAPEREC_FE_NPEN}/*.h"
                            "${LIPITK_SHAPEREC_FE_POINTFLOAT}/*.h"
                            "${LIPITK_SHAPEREC_FE_SS}/*.h" )


# Install headers (set the location)
INSTALL( FILES ${headers}          DESTINATION include/ )
INSTALL( FILES ${headers_util}     DESTINATION include/util )
INSTALL( FILES ${headers_shaperec} DESTINATION include/shaperec )
INSTALL( FILES ${headers_shaperec_featureextractor} DESTINATION include/shaperec/featureextractor )


# make uninstall
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/CMake/uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/CMake/uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/CMake/uninstall.cmake)





# 
# MESSAGE( STATUS "PROJECT_BINARY_DIR: " ${PROJECT_BINARY_DIR} )
# MESSAGE( STATUS "CMAKE_CURRENT_LIST_DIR: " ${CMAKE_CURRENT_LIST_DIR} )
# MESSAGE( STATUS "CMAKE_CURRENT_SOURCE_DIR: " ${CMAKE_CURRENT_SOURCE_DIR} )
# 
# # MESSAGE( STATUS "CMAKE_CURRENT_LIST_DIR: " ${CMAKE_CURRENT_LIST_DIR} )
# MESSAGE( STATUS "CMAKE_CURRENT_BINARY_DIR: " ${CMAKE_CURRENT_BINARY_DIR} )
# 
# MESSAGE( STATUS "CMAKE_BINARY_DIR: " ${CMAKE_BINARY_DIR} )
#
