cmake_minimum_required(VERSION 3.20)
project(GacOSX)

set(CMAKE_CXX_STANDARD 23)

add_subdirectory(MacShared)
add_subdirectory(MacTest)
add_subdirectory(MacFullControlTest)
add_subdirectory(RemotingTest_Renderer_macOS)
