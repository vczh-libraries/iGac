cmake_minimum_required(VERSION 3.20)
project(MacShared)

include_directories("../Import")
include_directories("../Mac")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20 -Wno-missing-declarations")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")

add_compile_definitions(VCZH_DEBUG_NO_REFLECTION)

set(GACUI_COMMON_FILES
	"../Import/Vlpp.cpp"
	"../Import/Vlpp.Linux.cpp"
	"../Import/VlppOS.cpp"
	"../Import/VlppOS.Linux.cpp"
	"../Import/VlppRegex.cpp"
	"../Import/VlppReflection.cpp"
	"../Import/VlppGlrParser.cpp"
	"../Import/VlppWorkflowLibrary.cpp"
	"../Import/GacUI.cpp"
	"../Import/Skins/DarkSkin/DarkSkin.cpp"
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

find_library(NETWORK_LIBRARIES Network REQUIRED)

# The packed VlppOS file guards <cstdlib> with !VCZH_APPLE even though its
# macOS async-socket section uses std::malloc and std::free.
set_source_files_properties("../Import/VlppOS.Linux.cpp" PROPERTIES COMPILE_OPTIONS "-include;cstdlib")

add_library(GacUI STATIC ${GACUI_COMMON_FILES})
target_link_libraries(GacUI PUBLIC ${NETWORK_LIBRARIES})
add_library(GacOSX STATIC ${GACOSX_FILES})
add_library(GacOSXShared STATIC ${GACOSX_SHARED_FILES})
