cmake_minimum_required(VERSION 2.8.4)
project(GacOSXTests)
include_directories("../Release/Import")
include_directories("../Mac")

include_directories(${DEPENDENCIES_INCLUDE_DIRS})
link_directories(${DEPENDENCIES_LIBRARY_DIRS})

set(OS_LIBRARIES "pthread")
find_library(COREFOUNDATION_LIBRARIES CoreFoundation)
find_library(QUARTZ_LIBRARIES Quartz)
find_library(COREGRAPHICS_LIBRARIES CoreGraphics)
find_library(COCOA_LIBRARIES Cocoa)
set(OS_LIBRARIES ${COREFOUNDATION_LIBRARIES} ${QUARTZ_LIBRARIES} ${COREGRAPHICS_LIBRARIES} ${COCOA_LIBRARIES} ${OS_LIBRARIES})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wno-missing-declarations")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")

set(GACUI_COMMON_FILES 
	"../Release/Import/Vlpp.cpp" 
	"../Release/Import/VlppWorkflow.cpp" 
	"../Release/Import/GacUI.cpp" 
	"../Release/Import/GacUIReflection.cpp")

set(GACOSX_FILES
	"../Mac/GraphicsElement/CoreGraphics/GuiGraphicsCoreGraphics.mm"
	"../Mac/GraphicsElement/CoreGraphics/GuiGraphicsCoreGraphicsRenderers.mm"
	"../Mac/GraphicsElement/CoreGraphics/GuiGraphicsLayoutProviderCoreText.mm"
	"../Mac/NativeWindow/OSX/CocoaBaseView.mm"
	"../Mac/NativeWindow/OSX/CocoaHelper.mm"
	"../Mac/NativeWindow/OSX/CocoaIntrospection.mm"
	"../Mac/NativeWindow/OSX/CocoaNativeController.mm"
	"../Mac/NativeWindow/OSX/CocoaWindow.mm"
	"../Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.mm"
	"../Mac/NativeWindow/OSX/ServicesImpl/CocoaAsyncService.mm"
	"../Mac/NativeWindow/OSX/ServicesImpl/CocoaCallbackService.mm"
	"../Mac/NativeWindow/OSX/ServicesImpl/CocoaClipboardService.mm"
	"../Mac/NativeWindow/OSX/ServicesImpl/CocoaDialogService.mm"
	"../Mac/NativeWindow/OSX/ServicesImpl/CocoaImageService.mm"
	"../Mac/NativeWindow/OSX/ServicesImpl/CocoaInputService.mm"
	"../Mac/NativeWindow/OSX/ServicesImpl/CocoaResourceService.mm"
	"../Mac/NativeWindow/OSX/ServicesImpl/CocoaScreenService.mm"
)

add_library(GacUI STATIC ${GACUI_COMMON_FILES})
add_library(GacOSX STATIC ${GACOSX_FILES})

set(DEPENDENCIES_LIBRARIES ${DEPENDENCIES_LIBRARIES} ${OS_LIBRARIES})
set(GACUI_LIBRARIES "GacUI" "GacOSX")


set(GACOSX_TESTS_COMMON_FILES
	"shared/osx_shared.mm"
	"shared/UnixFileSystemInfo.cpp"
)

file(GLOB_RECURSE SHARED_RESOURCES "Resources/*")
SET_SOURCE_FILES_PROPERTIES(
	${SHARED_RESOURCES}
	PROPERTIES
	MACOSX_PACKAGE_LOCATION 
	Resources
)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "bin/")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "bin/")

set(PLIST_TEMPLATE "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist.in")

#
set(APP_NAME "HellWorld_Cpp")
set(TESTAPP_SOURCE_FILES 
	"HelloWorlds/Cpp/Main.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})
set_target_properties( ${APP_NAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${PLIST_TEMPLATE} )

