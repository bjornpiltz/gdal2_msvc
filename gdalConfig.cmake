
# Use the following variables to compile and link against gdal:
    # GDAL_LIBRARY
    # GDAL_FOUND, if false, do not try to link to gdal
    # GDAL_INCLUDE_DIR, where to find the headers

set ( GDAL_FOUND 1 )
get_filename_component(GDAL_ROOT_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH CACHE)
set ( GDAL_INCLUDE_DIR  "${GDAL_ROOT_DIR}/include/" )
set ( GDAL_LIBRARY  "optimized;${GDAL_ROOT_DIR}/lib/gdal_i.lib;debug;${GDAL_ROOT_DIR}/lib/gdal_id.lib" )
