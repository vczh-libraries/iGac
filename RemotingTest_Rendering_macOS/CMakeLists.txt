cmake_minimum_required(VERSION 3.20)
project(RemotingTest_Rendering_macOS)

include_directories("../Import")
include_directories("../Import-Test")
include_directories("../Mac")

set(OS_LIBRARIES "pthread")
find_library(COREFOUNDATION_LIBRARIES CoreFoundation)
find_library(QUARTZ_LIBRARIES Quartz)
find_library(COREGRAPHICS_LIBRARIES CoreGraphics)
find_library(COCOA_LIBRARIES Cocoa)
find_library(UNIFORMTYPEIDENTIFIERS_LIBRARIES UniformTypeIdentifiers)
find_library(CARBON_LIBRARIES Carbon)
set(OS_LIBRARIES ${COREFOUNDATION_LIBRARIES} ${QUARTZ_LIBRARIES} ${COREGRAPHICS_LIBRARIES} ${COCOA_LIBRARIES} ${UNIFORMTYPEIDENTIFIERS_LIBRARIES} ${CARBON_LIBRARIES} ${OS_LIBRARIES})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20 -Wno-missing-declarations")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")

add_compile_definitions(VCZH_DEBUG_NO_REFLECTION)

set(DEPENDENCIES_LIBRARIES ${DEPENDENCIES_LIBRARIES} ${OS_LIBRARIES})
set(GACUI_LIBRARIES "GacUI" "GacOSX" "GacOSXShared")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "bin/")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "bin/")

set(APP_NAME "RemotingTest_Rendering_macOS")
set(APP_SOURCE_FILES
	"GuiMain.cpp"
	"Main.cpp"
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.iGac.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${APP_SOURCE_FILES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})
set_target_properties(${APP_NAME} PROPERTIES
	MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/../MacFullControlTest/Info.plist.in"
	MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOSX_BUNDLE_GUI_IDENTIFIER}
)
