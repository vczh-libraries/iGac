cmake_minimum_required(VERSION 2.8.4)
project(MacShared)

include_directories("../Release/Import")
include_directories("../Mac")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20 -Wno-missing-declarations")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")

add_compile_definitions(VCZH_DEBUG_NO_REFLECTION)

set(GACUI_COMMON_FILES
	"../Release/Import/Vlpp.cpp"
	"../Release/Import/Vlpp.Linux.cpp"
	"../Release/Import/VlppOS.cpp"
	"../Release/Import/VlppOS.Linux.cpp"
	"../Release/Import/VlppRegex.cpp"
	"../Release/Import/VlppReflection.cpp"
	"../Release/Import/VlppGlrParser.cpp"
	"../Release/Import/VlppWorkflowLibrary.cpp"
	"../Release/Import/GacUI.cpp"
	"../Release/Import/Skins/DarkSkin/DarkSkin.cpp"
)

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
	"../Mac/NativeWindow/OSX/ServicesImpl/CocoaClipboardService.mm"
	"../Mac/NativeWindow/OSX/ServicesImpl/CocoaDialogService.mm"
	"../Mac/NativeWindow/OSX/ServicesImpl/CocoaImageService.mm"
	"../Mac/NativeWindow/OSX/ServicesImpl/CocoaInputService.mm"
	"../Mac/NativeWindow/OSX/ServicesImpl/CocoaResourceService.mm"
	"../Mac/NativeWindow/OSX/ServicesImpl/CocoaScreenService.mm"
)

set(GACOSX_SHARED_FILES
	"osx_shared.mm"
	"UnixFileSystemInfo.cpp"
)

add_library(GacUI STATIC ${GACUI_COMMON_FILES})
add_library(GacOSX STATIC ${GACOSX_FILES})
add_library(GacOSXShared STATIC ${GACOSX_SHARED_FILES})
