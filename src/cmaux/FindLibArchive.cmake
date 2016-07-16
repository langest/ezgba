# Options:
# LibArchive_USE_STATIC_LIBS (bool)
# LibArchive_ROOT (str)

include(FindPackageHandleStandardArgs)
include(XMisc)

find_path(
	LibArchive_INCLUDE_DIR
	NAMES "archive.h"
	HINTS "${LibArchive_ROOT}" "[HKEY_LOCAL_MACHINE\\SOFTWARE\\GnuWin32\\LibArchive;InstallPath]"
)

push_variable(CMAKE_FIND_LIBRARY_SUFFIXES)

if (LibArchive_USE_STATIC_LIBS)
	find_library_suffixes(CMAKE_FIND_LIBRARY_SUFFIXES STATIC)
else ()
	find_library_suffixes(CMAKE_FIND_LIBRARY_SUFFIXES DYNAMIC)
endif ()

find_library(
	LibArchive_LIBRARY
	NAMES "archive" "libarchive"
	HINTS "${LibArchive_ROOT}" "[HKEY_LOCAL_MACHINE\\SOFTWARE\\GnuWin32\\LibArchive;InstallPath]"
)

pop_variable(CMAKE_FIND_LIBRARY_SUFFIXES)




if (NOT ":${LibArchive_INCLUDE_DIR}:" STREQUAL "::" AND EXISTS "${LibArchive_INCLUDE_DIR}/archive.h")
	read_src_define("${LibArchive_INCLUDE_DIR}/archive.h" ARCHIVE_VERSION_NUMBER _LibArchive_VERSION_NUMBER)

	string(SUBSTRING "${_LibArchive_VERSION_NUMBER}" 0 1 LibArchive_MAJOR_VERSION)
	string(SUBSTRING "${_LibArchive_VERSION_NUMBER}" 1 3 LibArchive_MINOR_VERSION)
	string(SUBSTRING "${_LibArchive_VERSION_NUMBER}" 4 3 LibArchive_PATCH_VERSION)

	string(REGEX REPLACE "0*([1-9][0-9]*|0)" "\\1" LibArchive_MAJOR_VERSION "${LibArchive_MAJOR_VERSION}")
	string(REGEX REPLACE "0*([1-9][0-9]*|0)" "\\1" LibArchive_MINOR_VERSION "${LibArchive_MINOR_VERSION}")
	string(REGEX REPLACE "0*([1-9][0-9]*|0)" "\\1" LibArchive_PATCH_VERSION "${LibArchive_PATCH_VERSION}")
	unset(_LibArchive_VERSION_NUMBER)

	set(LibArchive_VERSION_STRING "${LibArchive_MAJOR_VERSION}.${LibArchive_MINOR_VERSION}.${LibArchive_PATCH_VERSION}.")
endif ()


set(LibArchive_LIBRARIES "${LibArchive_LIBRARY}")
set(LibArchive_INCLUDE_DIRS "${LibArchive_INCLUDE_DIR}")

find_package_handle_standard_args(
	LibArchive
	REQUIRED_VARS LibArchive_LIBRARIES LibArchive_INCLUDE_DIRS
	VERSION_VAR LibArchive_VERSION_STRING
)
