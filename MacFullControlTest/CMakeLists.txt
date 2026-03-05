cmake_minimum_required(VERSION 2.8.4)
project(MacFullControlTest)

include_directories("../Release/Import")
include_directories("../Mac")
include_directories("../MacShared")

set(OS_LIBRARIES "pthread")
find_library(COREFOUNDATION_LIBRARIES CoreFoundation)
find_library(QUARTZ_LIBRARIES Quartz)
find_library(COREGRAPHICS_LIBRARIES CoreGraphics)
find_library(COCOA_LIBRARIES Cocoa)
find_library(UNIFORMTYPEIDENTIFIERS_LIBRARIES UniformTypeIdentifiers)
set(OS_LIBRARIES ${COREFOUNDATION_LIBRARIES} ${QUARTZ_LIBRARIES} ${COREGRAPHICS_LIBRARIES} ${COCOA_LIBRARIES} ${UNIFORMTYPEIDENTIFIERS_LIBRARIES} ${OS_LIBRARIES})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20 -Wno-missing-declarations")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")

add_compile_definitions(VCZH_DEBUG_NO_REFLECTION)

set(DEPENDENCIES_LIBRARIES ${DEPENDENCIES_LIBRARIES} ${OS_LIBRARIES})

# Reuse libraries built by MacShared
set(GACUI_LIBRARIES "GacUI" "GacOSX" "GacOSXShared")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "bin/")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "bin/")

set(PLIST_TEMPLATE "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist.in")

# Resource file to bundle into the .app
set(SHARED_RESOURCES "UI/FullControlTest/UIRes/BlackSkin.bin")
SET_SOURCE_FILES_PROPERTIES(${SHARED_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

set(APP_NAME "Test_FullControlTest")
set(TESTAPP_SOURCE_FILES
	"Main.mm"
	"UI/FullControlTest/Source/DemoPartialClasses.cpp"
	"UI/FullControlTest/Source/DocumentEditorBase.cpp"
	"UI/FullControlTest/Source/MainWindow.cpp"
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.iGac.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})
set_target_properties(${APP_NAME} PROPERTIES
	MACOSX_BUNDLE_INFO_PLIST ${PLIST_TEMPLATE}
	MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOSX_BUNDLE_GUI_IDENTIFIER}
)
