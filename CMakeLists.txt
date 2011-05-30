#############################################
##   PREAMBLE
#############################################

cmake_minimum_required(VERSION 2.8.3)

project(LipiTk)

set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR} )
include( ${LIPI_ROOT}/CMake/global.cmake )



#############################################
##   SUBDIRECTORY
#############################################

# Create "LTKConfig.h" header (for internal use)
set( LIPI_CMAKE_DIR "${CMAKE_INSTALL_PREFIX}")
configure_file( CMake/LTKConfig.h.in
                "${PROJECT_BINARY_DIR}/include/LTKConfig.h" )

add_subdirectory( ${LIPITK_SRC} )



#############################################
##   INSTALLATION
#############################################

# make (un)install
include( ${LIPI_ROOT}/CMake/install_headers.cmake )


# Install the export set for use with the install-tree
install( EXPORT LipiTkLibraryDepends
         DESTINATION "${CMAKE_INSTALL_PREFIX}" )


# Create "LipiTkConfig.cmake"
include( ${LIPI_ROOT}/CMake/export.cmake )
# set( LIPI_CMAKE_DIR "${CMAKE_INSTALL_PREFIX}")
configure_file( CMake/LipiTkConfig.cmake.in
                "${PROJECT_BINARY_DIR}/InstallFiles/LipiTkConfig.cmake" @ONLY)

# Install "LipiTkConfig.cmake"
install( FILES "${PROJECT_BINARY_DIR}/InstallFiles/LipiTkConfig.cmake"
         DESTINATION "${LIPI_CMAKE_DIR}" COMPONENT dev)


# Create "LTKConfig.h" header (used once installed)
configure_file( CMake/LTKConfig.h.in
                "${PROJECT_BINARY_DIR}/InstallFiles/LTKConfig.h" )

# Install "LTKConfig.h" header
install( FILES "${PROJECT_BINARY_DIR}/InstallFiles/LTKConfig.h"
         DESTINATION "${LIPI_CMAKE_DIR}/include" COMPONENT dev)



#############################################
##   CPACK
#############################################

# make package
set(CPACK_GENERATOR "TGZ" )            # "ZIP" "TBZ2" "RPM" "DEB" "NSIS"
set(CPACK_PACKAGE_VERSION_MAJOR "3")
set(CPACK_PACKAGE_VERSION_MINOR "0")
set(CPACK_PACKAGE_VERSION_PATCH "0")
include(CPack)



#############################################
##   MESSAGE
#############################################

# MESSAGE( STATUS "PROJECT_BINARY_DIR: " ${PROJECT_BINARY_DIR} )
# MESSAGE( STATUS "CMAKE_CURRENT_LIST_DIR: " ${CMAKE_CURRENT_LIST_DIR} )
# MESSAGE( STATUS "CMAKE_CURRENT_SOURCE_DIR: " ${CMAKE_CURRENT_SOURCE_DIR} )
# 
# MESSAGE( STATUS "CMAKE_CURRENT_LIST_DIR: " ${CMAKE_CURRENT_LIST_DIR} )
# MESSAGE( STATUS "CMAKE_CURRENT_BINARY_DIR: " ${CMAKE_CURRENT_BINARY_DIR} )
# 
# MESSAGE( STATUS "CMAKE_BINARY_DIR: " ${CMAKE_BINARY_DIR} )
