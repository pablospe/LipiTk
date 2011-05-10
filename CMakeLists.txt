cmake_minimum_required(VERSION 2.6)
include( global.cmake )

add_subdirectory( ${LIPITK_COMMON} )
add_subdirectory( ${LIPITK_SHAPEREC_COMMON} )

add_subdirectory( ${LIPITK_SHAPEREC}/activedtw )


add_subdirectory( ${LIPITK_WORDREC_COMMON} )
