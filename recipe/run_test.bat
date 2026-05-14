@echo on

set "FOUND_DISPENSO_CONFIG="

for /d %%D in ("%PREFIX%\Library\lib\cmake\Dispenso-*") do (
  if exist "%%~D\DispensoConfig.cmake" set "FOUND_DISPENSO_CONFIG=1"
)

if not defined FOUND_DISPENSO_CONFIG exit /b 1

cmake tests ^
  %CMAKE_ARGS% ^
  -G Ninja ^
  -B tests\build ^
  -DCMAKE_BUILD_TYPE=Release

if errorlevel 1 exit /b 1

cmake --build tests\build --parallel

if errorlevel 1 exit /b 1

tests\build\dispenso_consumer_test.exe
