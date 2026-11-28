set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "bin/")

file(GLOB CORE_RESOURCE_SOURCES CONFIGURE_DEPENDS
    "../Apps/FullControlTest/Source/*.cpp"
    "../Apps/RemoteProtocolTest/Source/*.cpp"
    "../Apps/RemoteViewModelTest/Source/*.cpp"
)
list(FILTER CORE_RESOURCE_SOURCES EXCLUDE REGEX "Reflection\\.cpp$")

add_executable(RemotingTest_Core Main.cpp GuiMain.cpp ${CORE_RESOURCE_SOURCES})
target_compile_definitions(RemotingTest_Core PRIVATE VCZH_DEBUG_NO_REFLECTION)
target_include_directories(RemotingTest_Core PRIVATE
    "../Import"
    "../Import-Test"
    "../Apps/FullControlTest/Source"
    "../Apps/RemoteProtocolTest/Source"
    "../Apps/RemoteViewModelTest/Source"
)
find_library(COREFOUNDATION_FRAMEWORK CoreFoundation REQUIRED)
find_library(COREGRAPHICS_FRAMEWORK CoreGraphics REQUIRED)
find_library(COCOA_FRAMEWORK Cocoa REQUIRED)
find_library(QUARTZ_FRAMEWORK Quartz REQUIRED)
find_library(CARBON_FRAMEWORK Carbon REQUIRED)
find_library(UTTYPE_FRAMEWORK UniformTypeIdentifiers REQUIRED)
target_link_libraries(RemotingTest_Core PRIVATE GacOSXShared GacOSX GacUI
    ${COREFOUNDATION_FRAMEWORK} ${COREGRAPHICS_FRAMEWORK} ${COCOA_FRAMEWORK} ${QUARTZ_FRAMEWORK} ${CARBON_FRAMEWORK} ${UTTYPE_FRAMEWORK})
