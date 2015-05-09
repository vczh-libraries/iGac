cmake_minimum_required(VERSION 2.8.4)
project(GacOSXTests)
include_directories("../gac/Public/Source")
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

set(GACUI_COMMON_FILES "../gac/Public/Source/Vlpp.cpp" "../gac/Public/Source/VlppWorkflow.cpp" "../gac/Public/Source/GacUI.cpp" "../gac/Public/Source/GacUIReflection.cpp")

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

set(MACOSX_BUNDLE_INFO_PLIST "MacOSXBundleInfo.plist.in")

#
set(APP_NAME "Controls.Label.Basic")
set(TESTAPP_SOURCE_FILES 
	"controls/label_basic.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.Label.Hyperlink")
set(TESTAPP_SOURCE_FILES 
	"controls/label_hyperlink.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.ListBox.NameEditor")
set(TESTAPP_SOURCE_FILES 
	"controls/listbox_name_editor.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.ListBox.NameSelector")
set(TESTAPP_SOURCE_FILES 
	"controls/listbox_name_selector.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.ListBox.VirtualMode")
set(TESTAPP_SOURCE_FILES 
	"controls/listbox_virtual_mode.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.ListView.SortingAndFiltering")
set(TESTAPP_SOURCE_FILES 
	"controls/listview_sorting_and_filtering.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.ListView.ViewSwitching")
set(TESTAPP_SOURCE_FILES 
	"controls/listview_viewswitching.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.ListView.VirtualMode")
set(TESTAPP_SOURCE_FILES 
	"controls/listview_virtual_mode.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.DataGrid.ChemicalElements")
set(TESTAPP_SOURCE_FILES 
	"controls/datagrid_chemical_elements.cpp" 
	"controls/datagrid_chemical_elements_cg_renderer.mm" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.DataGrid.DatePicker")
set(TESTAPP_SOURCE_FILES 
	"controls/datagrid_date_picker.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.DataGrid.FileBrowser")
set(TESTAPP_SOURCE_FILES 
	"controls/datagrid_file_browser.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.DataGrid.TableEditor")
set(TESTAPP_SOURCE_FILES 
	"controls/datagrid_table_editor.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.Button.CheckAndRadio")
set(TESTAPP_SOURCE_FILES 
	"controls/button_check_and_radio.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.Button.EnableDisable")
set(TESTAPP_SOURCE_FILES 
	"controls/button_enable_disable.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.Scroll.ColorPicker")
set(TESTAPP_SOURCE_FILES 
	"controls/scroll_colorpicker.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.Tab.TextBoxPage")
set(TESTAPP_SOURCE_FILES 
	"controls/tab_textbox_page.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.Template.CustomizedBorder")
set(TESTAPP_SOURCE_FILES 
	"controls/template_customized_border.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.Textbox.Colorizer")
set(TESTAPP_SOURCE_FILES 
	"controls/textbox_colorizer.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.Textbox.Editor")
set(TESTAPP_SOURCE_FILES 
	"controls/textbox_editor.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})


#
set(APP_NAME "Controls.Tooltip.Richtext")
set(TESTAPP_SOURCE_FILES 
	"controls/tooltip_richtext.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Controls.TreeView.FileExplorer")
set(TESTAPP_SOURCE_FILES 
	"controls/treeview_file_explorer.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})


#
set(APP_NAME "Rendering.RawAPI")
set(TESTAPP_SOURCE_FILES 
	"rendering/rendering_rawapi.mm" 
	"rendering/rendering_rawapi_window.cpp"
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Persistant.DirectCode.Scripting")
set(TESTAPP_SOURCE_FILES 
	"persistant/directcode_scripting.cpp" 
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
#set(APP_NAME "Persistant.Xml.ControlTemplate")
#set(TESTAPP_SOURCE_FILES 
#	"persistant/xml_control_template.cpp" 
#)
#file(GLOB CONTROL_TEMPLATE_GENERATED_FILES "persistant/control_template/*.cpp")

#set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
#add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${CONTROL_TEMPLATE_GENERATED_FILES} #${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
#target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Persistant.Xml.DataBinding")
set(TESTAPP_SOURCE_FILES 
	"persistant/xml_data_binding.cpp"
)
file(GLOB DATA_BINDING_GENERATED_FILES "persistant/data_binding/*.cpp")

set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${DATA_BINDING_GENERATED_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})

#
set(APP_NAME "Editor.Toolstrip.DocumentEditor")
set(TESTAPP_SOURCE_FILES 
	"editor/document_editor.cpp" 
	"editor/document_editor_initialization.cpp"
)
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.darkfall.gacosx.${APP_NAME}")
add_executable(${APP_NAME} MACOSX_BUNDLE ${TESTAPP_SOURCE_FILES} ${GACOSX_TESTS_COMMON_FILES} ${SHARED_RESOURCES})
target_link_libraries(${APP_NAME} ${GACUI_LIBRARIES} ${DEPENDENCIES_LIBRARIES})


