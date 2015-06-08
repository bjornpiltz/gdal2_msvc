CMAKE_MINIMUM_REQUIRED(VERSION 3.0)
PROJECT(3dParty_MSVC)

INCLUDE(ExternalProject)

SET(INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/install)

FILE(MAKE_DIRECTORY ${INSTALL_DIR}/lib)
FILE(MAKE_DIRECTORY ${INSTALL_DIR}/bin)

STRING(REPLACE "/" "\\" INSTALL_DIR ${INSTALL_DIR})

FIND_PACKAGE(Git)
if(GIT_FOUND)
	MESSAGE("git found: ${GIT_EXECUTABLE}")
ELSE()
	MESSAGE(FATAL_ERROR "git not found.")
ENDIF()

FIND_PROGRAM(PATCH_EXECUTABLE patch	HINTS "C:/Program Files (x86)/Git/bin")
# Workaround: I have appended " || dir" to each patch command
# because it seems that a second time patch runs it reports failure
# even though the flags "-t -N" are supposed to prevent that.
if(PATCH_EXECUTABLE)
	MESSAGE("patch.exe found: ${PATCH_EXECUTABLE}")
ELSE()
	MESSAGE(FATAL_ERROR "patch.exe not found.")
ENDIF()

IF(NOT MSVC_VERSION STREQUAL "1800" OR NOT CMAKE_CL_64)
	MESSAGE(WARNING "You might need to adapt this script for your version of MSVC.")
ENDIF()


# PROJ.4
ExternalProject_Add( proj4
	URL http://download.osgeo.org/proj/proj-4.8.0.zip
	PATCH_COMMAND ${PATCH_EXECUTABLE} -t -N -p1 < ${CMAKE_CURRENT_SOURCE_DIR}/proj4.patch || dir
	CONFIGURE_COMMAND ""
	BUILD_IN_SOURCE 1
	BUILD_COMMAND nmake /NOLOGO /f makefile.vc INSTDIR=${INSTALL_DIR} CONFIGURATION=$(Configuration)
	INSTALL_COMMAND nmake /NOLOGO /f makefile.vc INSTDIR=${INSTALL_DIR} CONFIGURATION=$(Configuration) install-all
	UPDATE_COMMAND ""
)
ExternalProject_Add_Step(proj4 copy_pdbs
	WORKING_DIRECTORY <SOURCE_DIR>
	COMMAND copy /y src\\*.pdb ${INSTALL_DIR}\\bin
	DEPENDEES install
)

# geos
ExternalProject_Add( geos
	URL http://download.osgeo.org/geos/geos-3.4.2.tar.bz2
	PATCH_COMMAND ${PATCH_EXECUTABLE} -t -N -p1 < ${CMAKE_CURRENT_SOURCE_DIR}/geos.patch || dir
	CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_DIR} -DCMAKE_DEBUG_POSTFIX=d -DBUILD_TESTING=OFF -DGEOS_ENABLE_TESTS=OFF
	UPDATE_COMMAND ""
)
ExternalProject_Add_Step(geos copy_pdbs
	WORKING_DIRECTORY <BINARY_DIR>
	COMMAND copy /y bin\\Debug\\*.pdb ${INSTALL_DIR}\\bin
	DEPENDEES install
)

# gdal
ExternalProject_Add( gdal
	URL http://download.osgeo.org/gdal/2.0.0beta2/gdal200beta2.zip
#	URL_HASH MD5=bc490ae81b7eb69e15d041c0e308edeb
	CONFIGURE_COMMAND ""
	PATCH_COMMAND ${PATCH_EXECUTABLE} -t -N -p1 < ${CMAKE_CURRENT_SOURCE_DIR}/gdal.patch || dir
	BUILD_IN_SOURCE 1
	BUILD_COMMAND nmake /NOLOGO /f makefile.vc GDAL_HOME="${INSTALL_DIR}" CONFIGURATION=$(Configuration)
	INSTALL_COMMAND nmake /NOLOGO /f makefile.vc GDAL_HOME="${INSTALL_DIR}" CONFIGURATION=$(Configuration) devinstall
	UPDATE_COMMAND ""
)

ADD_DEPENDENCIES(gdal geos proj4)
ExternalProject_Add_Step(gdal cleanup
	WORKING_DIRECTORY <BINARY_DIR>
	COMMAND if exist makefile.vc nmake /NOLOGO /f makefile.vc GDAL_HOME="${INSTALL_DIR}" CONFIGURATION=$(Configuration) clean
	DEPENDERS build
)
ExternalProject_Add_Step(gdal copy_pdbs
	WORKING_DIRECTORY <SOURCE_DIR>
	COMMAND copy /y *.pdb ${INSTALL_DIR}\\bin
	DEPENDEES install
)
ExternalProject_Add_Step(gdal deploy_cmake_config
	WORKING_DIRECTORY <SOURCE_DIR>
	COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}\\gdalConfig.cmake ${INSTALL_DIR}
	DEPENDEES install
)
