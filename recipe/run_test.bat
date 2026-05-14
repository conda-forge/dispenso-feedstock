@echo on

dir "%LIBRARY_PREFIX%\lib\cmake\Dispenso-*\DispensoConfig.cmake"

if errorlevel 1 exit 1

cmake tests ^
  %CMAKE_ARGS% ^
  -G Ninja ^
  -B tests\build ^
  -DCMAKE_BUILD_TYPE=Release

if errorlevel 1 exit 1

cmake --build tests\build --parallel

if errorlevel 1 exit 1

tests\build\dispenso_consumer_test.exe
