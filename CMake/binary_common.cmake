include( ${CMAKE_CURRENT_LIST_DIR}/global.cmake )

# Sources
file( GLOB sources "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp" )

# Include
include_directories( ${LIPITK_INCLUDE} )

# Binary
add_executable( ${PROJECT_NAME} ${sources} )

# Install
include( ${CMAKE_CURRENT_LIST_DIR}/install_targets.cmake )
