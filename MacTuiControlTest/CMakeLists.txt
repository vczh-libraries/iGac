set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "bin/")

find_library(COCOA_LIBRARIES Cocoa REQUIRED)
find_library(QUARTZ_LIBRARIES Quartz REQUIRED)
find_library(CARBON_LIBRARIES Carbon REQUIRED)
find_library(UNIFORMTYPEIDENTIFIERS_LIBRARIES UniformTypeIdentifiers REQUIRED)

add_library(GacOSXTui STATIC "../Mac/TUI/TuiCocoaController.mm")
target_include_directories(GacOSXTui PUBLIC "../Import" "../Mac")
target_compile_definitions(GacOSXTui PUBLIC VCZH_DEBUG_NO_REFLECTION)
target_link_libraries(GacOSXTui PUBLIC GacUI GacOSX
    ${COCOA_LIBRARIES} ${QUARTZ_LIBRARIES} ${CARBON_LIBRARIES}
    ${UNIFORMTYPEIDENTIFIERS_LIBRARIES})

add_executable(Test_TuiControlTest
    "Main.cpp"
    "GuiMain.cpp"
    "../Apps/TuiControlTest/Source/TuiControlTestPartialClasses.cpp"
    "../Apps/TuiControlTest/Source/TuiControlTestResource.cpp"
    "../Import/Skins/TuiSkin/TuiSkin.cpp"
)
target_include_directories(Test_TuiControlTest PRIVATE "../Apps/TuiControlTest/Source")
target_link_libraries(Test_TuiControlTest PRIVATE GacOSXTui)
