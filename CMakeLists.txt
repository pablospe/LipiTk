cmake_minimum_required(VERSION 2.8.3)

project(LipiTk)

set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR} )
include( ${LIPI_ROOT}/CMake/global.cmake )


add_subdirectory( ${LIPITK_SRC} )


# make (un)install
include( ${LIPI_ROOT}/CMake/install_headers.cmake )


# make package - CPack
SET(CPACK_GENERATOR "TGZ" )            # "ZIP" "TBZ2" "RPM" "DEB" "NSIS"
SET(CPACK_PACKAGE_VERSION_MAJOR "3")
SET(CPACK_PACKAGE_VERSION_MINOR "0")
SET(CPACK_PACKAGE_VERSION_PATCH "0")
INCLUDE(CPack)



# Install the export set for use with the install-tree
install(EXPORT LipiTkLibraryDepends DESTINATION "${CMAKE_INSTALL_PREFIX}" )

# Create a LipiTkConfig.cmake file for the use from the install tree and install it
# set( LIPITK_INCLUDE_DIRS  "${LIPITK_INCLUDE_DIRS}")
# set( LIPI_LIB_DIR         "${LIPITK_LIBRARIES}")
set( LIPI_CMAKE_DIR       "${CMAKE_INSTALL_PREFIX}")
configure_file( CMake/LipiTkConfig.cmake.in
                "${PROJECT_BINARY_DIR}/InstallFiles/LipiTkConfig.cmake" @ONLY)
install( FILES
         "${PROJECT_BINARY_DIR}/InstallFiles/${PROJECT_NAME}Config.cmake"
         DESTINATION "${LIPI_CMAKE_DIR}" COMPONENT dev)



# Create the "LTKConfig.h" header
configure_file( CMake/LTKConfig.h.in
                "${LIPI_CMAKE_DIR}/include/LTKConfig.h" )


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
