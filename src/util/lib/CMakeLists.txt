cmake_minimum_required(VERSION 2.8.3)

project(util)

set( LIPI_ROOT ${CMAKE_CURRENT_LIST_DIR}/../../.. )
include( ${LIPI_ROOT}/CMake/global.cmake )

# Sources
set( sources LTKCheckSumGenerate.cpp
             LTKConfigFileReader.cpp
             LTKInkFileReader.cpp
             LTKInkFileWriter.cpp
             LTKLoggerUtil.cpp
             LTKInkUtils.cpp
             LTKStrEncoding.cpp
             LTKErrors.cpp
             LTKStringUtil.cpp
             LTKVersionCompatibilityCheck.cpp
             LTKLinuxUtil.cpp
             LTKOSUtilFactory.cpp
             LTKImageWriter.cpp )

# Include
include_directories( ${LIPITK_SRC_INCLUDE} ${LIPITK_SRC_UTILS_LIB} ${LIPITK_CONFIG} )

# Static
add_library( ${PROJECT_NAME} SHARED ${sources} )

# Install
INSTALL(TARGETS ${PROJECT_NAME}
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib/static
)


