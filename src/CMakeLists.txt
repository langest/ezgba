cmake_minimum_required(VERSION 3.1)
project(ezgba VERSION 0.2.0 LANGUAGES C CXX)
list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_SOURCE_DIR}/cmaux")
include(XPackage)
include(XMisc)


# BUILD_MACHINE_BITNESS is set by XMisc.
set(ezgba_TARGET_BITNESS "${BUILD_MACHINE_BITNESS}" CACHE STRING "Bitness (eg. 32-bits, 64-bits) of target architecture (ie. system that will run the compiled code). Default is CMAKE_SIZEOF_VOID_P * 8.")
set(ezgba_GUI_SUPPORT OFF CACHE BOOL "If building with GUI support or not.")

set_find_library_bitness("${ezgba_TARGET_BITNESS}")
amend_search_prefixes("/")


# Statically link libgcc and libstdc++.
# set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libgcc -static-libstdc++")

# if (WIN32)
# 	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-Bstatic -lpthread -Wl,-Bdynamic")
# endif()


# If on Windows, compile the executable icon.
if (WIN32)
	enable_language(RC)

	if (":${CMAKE_RC_COMPILER}:" MATCHES ":.*[/\\\\]?windres\\.[A-z0-9]*")
		# CMake tries to give windres.exe -W as a flag, which it doesn't support.
		set(CMAKE_RC_COMPILE_OBJECT "<CMAKE_RC_COMPILER> -O coff <DEFINES> -i <SOURCE> -o <OBJECT>")
	endif()
endif ()


# Configure build.
set(ezgba_COMPILE_FEATURES cxx_nonstatic_member_init cxx_constexpr cxx_strong_enums)
set(ezgba_DEFINITIONS "")
set(ezgba_INCLUDE_DIRS "")
set(ezgba_LIBRARIES "")
set(ezgba_SOURCE_FILES windows-icon.rc src/main.cpp src/gba.hpp src/data.cpp src/data.hpp src/patch.cpp src/patch.hpp src/error.cpp src/error.hpp src/misc.cpp src/misc.hpp)

# TODO Don't pollute source directory when using CMake configure_file().
configure_file("${ezgba_SOURCE_DIR}/src/main.cpp.in" "${ezgba_SOURCE_DIR}/src/main.cpp")
configure_file("${ezgba_SOURCE_DIR}/src/gui.cpp.in" "${ezgba_SOURCE_DIR}/src/gui.cpp")

if (":${CMAKE_BUILD_TYPE}:" MATCHES ":[Dd][Ee][Bb][Uu][Gg]:")
	set(ezgba_DEFINITIONS ${ezgba_DEFINITIONS} DEBUG=1)
else()
	set(ezgba_DEFINITIONS ${ezgba_DEFINITIONS} DEBUG=0)
endif ()



if (ezgba_GUI_SUPPORT)
	if (":${CMAKE_BUILD_TYPE}:" MATCHES ":[Dd][Ee][Bb][Uu][Gg]:")
		set(wxWidgets_USE_DEBUG TRUE)
	else()
		set(wxWidgets_USE_DEBUG FALSE)
	endif ()

	# For MinGW the order of wxWidgets components is important.
#	set(wxWidgets_USE_STATIC ON)
	find_package(wxWidgets REQUIRED COMPONENTS core base)
	include("${wxWidgets_USE_FILE}")

	if (":${CMAKE_BUILD_TYPE}:" MATCHES ":[Dd][Ee][Bb][Uu][Gg]:")
		set(wxWidgets_DEFINITIONS_ ${wxWidgets_DEFINITIONS_DEBUG})
	else()
        set(wxWidgets_DEFINITIONS_ ${wxWidgets_DEFINITIONS})
	endif ()

	add_definitions(-D_CRT_SECURE_NO_WARNINGS=0)

	# Disable false deprecation warnings for GCC building wxWidgets.
	if (CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
		execute_process(COMMAND "${CMAKE_C_COMPILER}" -dumpversion OUTPUT_VARIABLE GNUC_VERSION TIMEOUT 2 ERROR_QUIET)
		execute_process(COMMAND "${CMAKE_CXX_COMPILER}" -dumpversion OUTPUT_VARIABLE GNUCXX_VERSION TIMEOUT 2 ERROR_QUIET)

		if (((GNUC_VERSION VERSION_EQUAL "5.1.0" OR GNUC_VERSION VERSION_GREATER "5.1.0") AND (GNUC_VERSION VERSION_EQUAL "5.2.0" OR GNUC_VERSION VERSION_LESS "5.2.0"))
				OR ((GNUCXX_VERSION VERSION_EQUAL "5.1.0" OR GNUCXX_VERSION VERSION_GREATER "5.1.0") AND (GNUCXX_VERSION VERSION_EQUAL "5.2.0" OR GNUCXX_VERSION VERSION_LESS "5.2.0")))
			# HACK GCC has a bug that floods you with false deprecation warnings when compiling wxWidgets headers.
			message(AUTHOR_WARNING "Using -Wno-deprecated-declarations to work around gcc false deprecation warning bug when building wxWidgets headers.")
			add_definitions(-Wno-deprecated-declarations)
		endif ()
	endif ()
else()
    set(ezgba_DEFINITIONS ${ezgba_DEFINITIONS} GUI_SUPPORT=0)
endif ()


# set(Boost_USE_STATIC_LIBS ON)
# set(Boost_USE_STATIC_RUNTIME ON)

find_package(Boost COMPONENTS system filesystem REQUIRED)
find_package(TCLAP REQUIRED)

# With MSVC, FindBoost.cmake gives only filename, not full path (Jan. 09, 2015).
link_directories("${BOOST_LIBRARYDIR}")


add_executable(ezgba-cli ${ezgba_SOURCE_FILES})
target_compile_features(ezgba-cli PRIVATE ${ezgba_COMPILE_FEATURES} ${Boost_COMPILE_FEATURES} ${TCLAP_COMPILE_FEATURES})
target_link_libraries(ezgba-cli PRIVATE ${ezgba_LIBRARIES} ${Boost_LIBRARIES} ${TCLAP_LIBRARIES})
target_include_directories(ezgba-cli PRIVATE ${ezgba_INCLUDE_DIRS} ${Boost_INCLUDE_DIRS} ${TCLAP_INCLUDE_DIRS})
target_compile_definitions(ezgba-cli PRIVATE ${ezgba_DEFINITIONS} ${Boost_DEFINITIONS} ${TCLAP_DEFINITIONS})
set_property(TARGET ezgba-cli PROPERTY CXX_STANDARD 11)


if (ezgba_GUI_SUPPORT)
	add_executable(ezgba-gui ${ezgba_SOURCE_FILES} src/gui_base.cpp src/gui_base.h src/gui.cpp src/gui.hpp)
	target_compile_features(ezgba-gui PRIVATE ${ezgba_COMPILE_FEATURES} ${Boost_COMPILE_FEATURES} ${TCLAP_COMPILE_FEATURES} ${wxWidgets_COMPILE_FEATURES})
	target_link_libraries(ezgba-gui PRIVATE ${ezgba_LIBRARIES} ${Boost_LIBRARIES} ${TCLAP_LIBRARIES} ${wxWidgets_LIBRARIES})
	target_include_directories(ezgba-gui PRIVATE ${ezgba_INCLUDE_DIRS} ${Boost_INCLUDE_DIRS} ${TCLAP_INCLUDE_DIRS} ${wxWidgets_INCLUDE_DIRS})
	target_compile_definitions(ezgba-gui PRIVATE ${ezgba_DEFINITIONS} GUI_SUPPORT=1 ${Boost_DEFINITIONS} ${TCLAP_DEFINITIONS} ${wxWidgets_DEFINITIONS_})
	set_property(TARGET ezgba-gui PROPERTY CXX_STANDARD 11)

	if (MINGW)
		# On MinGW, copy libpthread-1.dll. This can't be avoided (for now 09/09/2015).

		# find_dll(WINPTHREAD1_DLL "winpthread-1")
		find_dll(WXBASE30_DLL "wxbase30u_gcc_custom")
		find_dll(WXMSW30_DLL "wxmsw30u_core_gcc_custom")
		# find_dll(PNG16_DLL "png16-16")
		# find_dll(ZLIB1_DLL "zlib1")
		find_dll(LIBSTDC_DLL "libstdc++-6")
		find_dll(BOOST_FILESYSTEM_MT_DLL "libboost_filesystem-mt")
		find_dll(BOOST_SYSTEM_MT_DLL "libboost_system-mt")

		# add_custom_command(TARGET ezgba-gui POST_BUILD COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${WINPTHREAD1_DLL}" "$<TARGET_FILE_DIR:ezgba-gui>")
		add_custom_command(TARGET ezgba-gui POST_BUILD COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${WXBASE30_DLL}" "$<TARGET_FILE_DIR:ezgba-gui>")
		add_custom_command(TARGET ezgba-gui POST_BUILD COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${WXMSW30_DLL}" "$<TARGET_FILE_DIR:ezgba-gui>")
		# add_custom_command(TARGET ezgba-gui POST_BUILD COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${PNG16_DLL}" "$<TARGET_FILE_DIR:ezgba-gui>")
		# add_custom_command(TARGET ezgba-gui POST_BUILD COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${ZLIB1_DLL}" "$<TARGET_FILE_DIR:ezgba-gui>")
		add_custom_command(TARGET ezgba-gui POST_BUILD COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${LIBSTDC_DLL}" "$<TARGET_FILE_DIR:ezgba-gui>")
		add_custom_command(TARGET ezgba-gui POST_BUILD COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${BOOST_FILESYSTEM_MT_DLL}" "$<TARGET_FILE_DIR:ezgba-gui>")
		add_custom_command(TARGET ezgba-gui POST_BUILD COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${BOOST_SYSTEM_MT_DLL}" "$<TARGET_FILE_DIR:ezgba-gui>")
	endif()

	if (APPLE)
		add_custom_command(TARGET ezgba-gui COMMENT "Change permissions for OS X app bundle creation script." POST_BUILD COMMAND "chmod" "755" "${ezgba_SOURCE_DIR}/build-osx-bundle.sh")
		add_custom_command(TARGET ezgba-gui COMMENT "Create Mac OS X application bundle." POST_BUILD COMMAND "${ezgba_SOURCE_DIR}/build-osx-bundle.sh" "${ezgba_BINARY_DIR}/ezgba-gui" "${ezgba_SOURCE_DIR}/assets/gba-icon-cyan.icns" "${ezgba_BINARY_DIR}/ezgba.app")
	endif()
endif()
