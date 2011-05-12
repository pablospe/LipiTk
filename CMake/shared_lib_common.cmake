include( ${CMAKE_CURRENT_LIST_DIR}/global.cmake )

# Sources
file( GLOB sources "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp" )

# Include
include_directories( ${LIPITK_SRC_INCLUDE} ${LIPITK_SRC_UTILS_LIB} )

# Shared
add_library( ${PROJECT_NAME} SHARED ${sources} )

# Install
include( ${CMAKE_CURRENT_LIST_DIR}/install_targets.cmake )
