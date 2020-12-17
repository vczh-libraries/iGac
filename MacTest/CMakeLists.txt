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

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -Wno-missing-declarations")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")

set(GACUI_COMMON_FILES 
	"../Release/Import/Vlpp.cpp" 
	"../Release/Import/VlppWorkflowLibrary.cpp"
	"../Release/Import/VlppWorkflowRuntime.cpp"
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

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "bin/")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "bin/")

set(PLIST_TEMPLATE "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist.in")

add_custom_target(
    CopyResources
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/CopyResources.py
)

#
set(SHARED_RESOURCES "")
set(APP_NAME "Test_HellWorld_Cpp")
set(TESTAPP_SOURCE_FILES 
	"HelloWorlds/Cpp/Main.cpp"
	"../Release/Import/Skins/DarkSkin/DarkSkin.cpp"
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.iGac.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})
set_target_properties( ${APP_NAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${PLIST_TEMPLATE} 
MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOSX_BUNDLE_GUI_IDENTIFIER} )
add_dependencies(${APP_NAME} CopyResources)

#
set(SHARED_RESOURCES "Controls/Animation/Animation.bin")
SET_SOURCE_FILES_PROPERTIES(${SHARED_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

set(APP_NAME "Test_Animation")
set(TESTAPP_SOURCE_FILES
		"Controls/Animation/Main.cpp"
		"Controls/Animation/DemoPartialClasses.cpp"
		"Controls/Animation/DemoReflection.cpp"
		"../Release/Import/Skins/DarkSkin/DarkSkin.cpp"
		)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.iGac.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})
set_target_properties( ${APP_NAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${PLIST_TEMPLATE} MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOSX_BUNDLE_GUI_IDENTIFIER} )
add_dependencies(${APP_NAME} CopyResources)

#
set(SHARED_RESOURCES "Controls/CalculatorAndStateMachine/CalculatorAndStateMachine.bin")
SET_SOURCE_FILES_PROPERTIES(${SHARED_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

set(APP_NAME "Test_CalculatorAndStateMachine")
set(TESTAPP_SOURCE_FILES
		"Controls/CalculatorAndStateMachine/Main.cpp"
		"Controls/CalculatorAndStateMachine/DemoPartialClasses.cpp"
		"Controls/CalculatorAndStateMachine/DemoReflection.cpp"
		"../Release/Import/Skins/DarkSkin/DarkSkin.cpp"
		)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.iGac.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})
set_target_properties( ${APP_NAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${PLIST_TEMPLATE} MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOSX_BUNDLE_GUI_IDENTIFIER} )
add_dependencies(${APP_NAME} CopyResources)

#
set(SHARED_RESOURCES "Controls/ContainersAndButtons/ContainersAndButtons.bin")
SET_SOURCE_FILES_PROPERTIES(${SHARED_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

set(APP_NAME "Test_ContainersAndButtons")
set(TESTAPP_SOURCE_FILES 
	"Controls/ContainersAndButtons/Main.cpp" 
	"Controls/ContainersAndButtons/DemoPartialClasses.cpp"
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.iGac.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})
set_target_properties( ${APP_NAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${PLIST_TEMPLATE} MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOSX_BUNDLE_GUI_IDENTIFIER} )
add_dependencies(${APP_NAME} CopyResources)

#
set(SHARED_RESOURCES "Layouts/Alignment/Alignment.bin")
SET_SOURCE_FILES_PROPERTIES(${SHARED_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

set(APP_NAME "Test_Layouts_Alignment")
set(TESTAPP_SOURCE_FILES 
	"Layouts/Alignment/Main.cpp" 
	"Layouts/Alignment/DemoPartialClasses.cpp"
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.iGac.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})
set_target_properties( ${APP_NAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${PLIST_TEMPLATE} 
MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOSX_BUNDLE_GUI_IDENTIFIER} )
add_dependencies(${APP_NAME} CopyResources)

#
set(SHARED_RESOURCES "Layouts/Table/Table.bin")
SET_SOURCE_FILES_PROPERTIES(${SHARED_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

set(APP_NAME "Test_Layouts_Table")
set(TESTAPP_SOURCE_FILES 
	"Layouts/Table/Main.cpp"
	"Layouts/Table/DemoPartialClasses.cpp"
	"../Release/Import/Skins/DarkSkin/DarkSkin.cpp"
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.iGac.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})
set_target_properties( ${APP_NAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${PLIST_TEMPLATE} 
MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOSX_BUNDLE_GUI_IDENTIFIER} )
add_dependencies(${APP_NAME} CopyResources)


#
set(SHARED_RESOURCES "Layouts/Stack/Stack.bin")
SET_SOURCE_FILES_PROPERTIES(${SHARED_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

set(APP_NAME "Test_Layouts_Stack")
set(TESTAPP_SOURCE_FILES 
	"Layouts/Stack/Main.cpp" 
	"Layouts/Stack/DemoPartialClasses.cpp"
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.iGac.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})
set_target_properties( ${APP_NAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${PLIST_TEMPLATE} 
MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOSX_BUNDLE_GUI_IDENTIFIER} )
add_dependencies(${APP_NAME} CopyResources)


#
set(SHARED_RESOURCES "Layouts/Flow/Flow.bin")
SET_SOURCE_FILES_PROPERTIES(${SHARED_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

set(APP_NAME "Test_Layouts_Flow")
set(TESTAPP_SOURCE_FILES 
	"Layouts/Flow/Main.cpp" 
	"Layouts/Flow/DemoPartialClasses.cpp"
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.iGac.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})
set_target_properties( ${APP_NAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${PLIST_TEMPLATE} 
MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOSX_BUNDLE_GUI_IDENTIFIER} )
add_dependencies(${APP_NAME} CopyResources)


#
set(SHARED_RESOURCES "Layouts/RichTextEmbedding/RichTextEmbedding.bin")
SET_SOURCE_FILES_PROPERTIES(${SHARED_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

set(APP_NAME "Test_Layouts_RichTextEmbedding")
set(TESTAPP_SOURCE_FILES 
	"Layouts/RichTextEmbedding/Main.cpp" 
	"Layouts/RichTextEmbedding/DemoPartialClasses.cpp"
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.iGac.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})
set_target_properties( ${APP_NAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${PLIST_TEMPLATE} 
MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOSX_BUNDLE_GUI_IDENTIFIER} )
add_dependencies(${APP_NAME} CopyResources)