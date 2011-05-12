cmake_minimum_required(VERSION 2.8)

project(featurefilewriter)

set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR}/../../.. )
include( ${LIPI_ROOT}/CMake/global.cmake )

# Sources
file( GLOB sources "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp" )

# Include
include_directories( ${LIPITK_SRC_INCLUDE} ${LIPITK_SRC_UTILS_LIB} ${LIPITK_SHAPEREC_FE_COMMON}
                     ${LIPITK_SHAPEREC_COMMON} )

add_executable( ${PROJECT_NAME} ${sources} )

target_link_libraries( ${PROJECT_NAME} stdc++ dl shaperecommon util common featureextractorcommon )


# Install
INSTALL(TARGETS ${PROJECT_NAME}
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib/static
)
