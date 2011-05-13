# Headers
file( GLOB headers            "${LIPITK_SRC_INCLUDE}/*.h" )
file( GLOB headers_util       "${LIPITK_SRC_UTILS_LIB}/*.h" )

file( GLOB headers_shaperec   "${LIPITK_SHAPEREC_ACTIVEDTW}/*.h"
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

file( GLOB headers_wordrec    "${LIPITK_WORDREC_BOXFLD}/*.h" )
file( GLOB headers_lipiengine "${LIPITK_LIPIENGINE}/*.h" )
file( GLOB headers_logger     "${LIPITK_LOGGER}/*.h" )


# Install headers (set the location)
INSTALL( FILES ${headers}            DESTINATION include/ )
INSTALL( FILES ${headers_util}       DESTINATION include/util )
INSTALL( FILES ${headers_shaperec}   DESTINATION include/shaperec )
INSTALL( FILES ${headers_shaperec_featureextractor}
                                     DESTINATION include/shaperec/featureextractor )
INSTALL( FILES ${headers_wordrec}    DESTINATION include/wordrec )
INSTALL( FILES ${headers_lipiengine} DESTINATION include/lipiengine )
INSTALL( FILES ${headers_logger}     DESTINATION include/logger )


# make uninstall
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/CMake/uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/CMake/uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/CMake/uninstall.cmake)
