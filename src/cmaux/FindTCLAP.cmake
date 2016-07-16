include(FindPackageHandleStandardArgs)
include(XMisc)

push_variable(CMAKE_PREFIX_PATH)

if (NOT ":${TCLAP_ROOT}:" STREQUAL "::")
	list(APPEND CMAKE_PREFIX_PATH "${TCLAP_ROOT}")
endif ()

find_path(
	TCLAP_INCLUDE_DIR
	NAMES "tclap/CmdLine.h"
	DOC "A command line option-parsing library."
	HINTS "${TCLAP_ROOT}"
	PATH_SUFFIXES "include"
)

pop_variable(CMAKE_PREFIX_PATH)

set(TCLAP_INCLUDE_DIRS "${TCLAP_INCLUDE_DIR}")

find_package_handle_standard_args(
	TCLAP
	REQUIRED_VARS TCLAP_INCLUDE_DIRS
	HANDLE_COMPONENTS
)
