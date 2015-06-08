rem only tested MSVC 2013 x64 so far
rem call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x64
call "%VS120COMNTOOLS%\..\..\VC\vcvarsall.bat" x64
time /T

set SOURCE_DIR=%~dp0

if exist CMakeLists.txt (
	echo We seem to be in the source tree
	if exist build (
		rem RMDIR  /q /s build
		echo Using existing build dir.
	) else (
		echo Creating new build dir.
		mkdir build
	)
	cd build
) else (
	echo The file does not exist.
)
echo SOURCE_DIR is %SOURCE_DIR%
echo BUILD_DIR is %CD%

echo Invoking CMake.
cmake %SOURCE_DIR% -G"Visual Studio 12 2013 Win64"  1>cmake.log 2>cmake-errors.log

IF ERRORLEVEL 1 GOTO CMAKE-ERROR

time /T

echo Starting debug build
msbuild /p:Configuration=Debug /p:Platform=x64 ALL_BUILD.vcxproj 1>build-debug.log 2>build-errors-debug.log

time /T

echo Starting release build
msbuild /p:Configuration=Release /p:Platform=x64 ALL_BUILD.vcxproj 1>build-release.log 2>build-errors-release.log

GOTO END

:CMAKE-ERROR
ECHO CMake exited with an error. See build/cmake.log and build/cmake-errors.log.
GOTO END

:END

time /T
pause