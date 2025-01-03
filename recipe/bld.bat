@echo on

cmake %SRC_DIR% ^
  %CMAKE_ARGS% ^
  -B build ^
  -DDISPENSO_BUILD_TESTS=ON

cmake --build build --parallel --config Release

ctest --test-dir build --output-on-failure --build-config Release -LE flaky

cmake --install build --config Release
