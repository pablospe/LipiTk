#############################################
##   Variables to be exported. Once installed
#############################################

set( LIPITK_DYNAMIC_LIBDIR ${CMAKE_INSTALL_PREFIX}/lib  )
set( LIPITK_STATIC_LIBDIR  ${CMAKE_INSTALL_PREFIX}/lib/static  )

#  LIPITK_INCLUDE_DIRS   - include directories for LIPITK
set( LIPITK_INCLUDE_DIRS   ${CMAKE_INSTALL_PREFIX}/include/
                           ${CMAKE_INSTALL_PREFIX}/include/util
                           ${CMAKE_INSTALL_PREFIX}/include/shaperec
                           ${CMAKE_INSTALL_PREFIX}/include/shaperec/featureextractor
                           ${CMAKE_INSTALL_PREFIX}/include/wordrec
                           ${CMAKE_INSTALL_PREFIX}/include/lipiengine
                           ${CMAKE_INSTALL_PREFIX}/include/logger )

#  LIPITK_LIBRARIES      - libraries to link against
set( LIPITK_LIBRARIES      ${LIPITK_DYNAMIC_LIB} ${LIPITK_STATIC_LIB} )

#  LIPITK_LIBRARIES_DIRS - library directories for LIPITK
set( LIPITK_LIBRARIES_DIRS ${LIPITK_DYNAMIC_LIBDIR} ${LIPITK_STATIC_LIBDIR} )
