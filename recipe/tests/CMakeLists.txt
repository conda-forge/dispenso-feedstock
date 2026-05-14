cmake_minimum_required(VERSION 3.16)

project(dispenso_consumer LANGUAGES CXX)

find_package(Dispenso CONFIG REQUIRED)

add_executable(dispenso_consumer_test main.cpp)
target_compile_features(dispenso_consumer_test PRIVATE cxx_std_14)
target_link_libraries(dispenso_consumer_test PRIVATE Dispenso::dispenso)
