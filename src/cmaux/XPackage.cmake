include(CMakeParseArguments)

function(amend_search_prefixes)
	foreach(ROOT ${ARGN})
		if (NOT ":${ROOT}:" STREQUAL "")
			# Strip trailing forward/back slashes and whitespace.
			# CMake's regex implementation is wonky. This is a workaround.
			while (TRUE)
				string(LENGTH "${ROOT}" LEN)

				if (LEN LESS 0 OR LEN EQUAL 0)
					break()
				else ()
					math(EXPR NEWLEN "${LEN} - 1")
					string(SUBSTRING "${ROOT}" "${NEWLEN}" 1 CHAR)

					if (":${CHAR}:" MATCHES ":[/\\ \t]:")
						string(SUBSTRING "${ROOT}" 0 "${NEWLEN}" ROOT)
					else ()
						break()
					endif ()
				endif ()
			endwhile ()

			# On OSX, /usr/local is often managed by external tools (ie. brew).
			# Manually installed libraries can now go in /usr/xlocal without fear of messing up /usr/local.
			list(APPEND CMAKE_PREFIX_PATH "${ROOT}/usr/xlocal")

			# CMake doesn't search all default directories.
			if (APPLE)
				get_filename_component(USER_FRAMEWORKS "~/Library/Frameworks" REALPATH)
				list(APPEND CMAKE_PREFIX_PATH "${ROOT}/${USER_FRAMEWORKS}")
				list(APPEND CMAKE_PREFIX_PATH "${ROOT}/Library/Frameworks")
				list(APPEND CMAKE_PREFIX_PATH "${ROOT}/System/Library/Frameworks")
				list(APPEND CMAKE_PREFIX_PATH "${ROOT}/Network/Library/Frameworks")

				# Fink.
				list(APPEND CMAKE_PREFIX_PATH "${ROOT}/sw")

				# MacPorts (formerly DarwinPorts).
				list(APPEND CMAKE_PREFIX_PATH "${ROOT}/opt/local")
			endif ()

			list(APPEND CMAKE_PREFIX_PATH "${ROOT}/usr/local")

			if (NOT ":${ROOT}:" STREQUAL "::")
				list(APPEND CMAKE_PREFIX_PATH "${ROOT}")
			else ()
				list(APPEND CMAKE_PREFIX_PATH "/")
			endif ()
		endif ()
	endforeach()

	set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
endfunction()

function(find_dll)
	get_property(TARGET_BITNESS GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS)
	set(CMAKE_FIND_LIBRARY_SUFFIXES ".dll")

	if (":${TARGET_BITNESS}:" STREQUAL ":64:")
		# TDM-GCC has special _64 suffix for 64-bit libraries.
		foreach (NUM RANGE 50 0 -1)
			list(INSERT CMAKE_FIND_LIBRARY_SUFFIXES 0 _64-${NUM}.dll)
		endforeach ()

		list(INSERT CMAKE_FIND_LIBRARY_SUFFIXES 0 _64.dll)
	endif()


	find_library(
		${ARGN}
	)

	find_program(
		${ARGN}
	)
endfunction()

function(find_child_flags RETVAR PARENT_PREFIX)
	set(CHILD_FLAGS "")

	if (${PARENT_PREFIX}_FIND_REQUIRED)
		list(APPEND CHILD_FLAGS REQUIRED)
	endif ()

	if (${PARENT_PREFIX}_FIND_QUIETLY)
		list(APPEND CHILD_FLAGS QUIET)
	endif ()

	set("${RETVAR}" "${CHILD_FLAGS}" PARENT_SCOPE)
endfunction()

function(find_library_suffixes RETVAR LINK_TYPE)
	set(SUFFIXES "${CMAKE_FIND_LIBRARY_SUFFIXES}")

	if (":${LINK_TYPE}:" STREQUAL ":STATIC:")
		if (WIN32)
			if (MINGW)
				# Apparently MinGW can use DLL as static library.
				list(INSERT SUFFIXES 0 .dll)

				# TDM-GCC has special _64 suffix for 64-bit libraries.
				get_property(TARGET_BITNESS GLOBAL FIND_LIBRARY_USE_LIB64_PATHS)

				if (":${TARGET_BITNESS}:" STREQUAL ":64:")
					foreach (NUM RANGE 50 0 -1)
						list(INSERT SUFFIXES 0 _64-${NUM}.dll)
					endforeach()

					list(INSERT SUFFIXES 0 _64.dll)
				endif ()
			endif ()

			list(INSERT SUFFIXES 0 .lib)
			list(INSERT SUFFIXES 0 .a)
			list(REMOVE_ITEM SUFFIXES "${CMAKE_SHARED_LIBRARY_SUFFIX}")
		else ()
			list(INSERT SUFFIXES 0 .a)
			list(REMOVE_ITEM SUFFIXES "${CMAKE_SHARED_LIBRARY_SUFFIX}")
		endif ()
	elseif (":${LINK_TYPE}:" MATCHES ":DYNAMIC:|:SHARED:")
		if (WIN32)
			list(INSERT SUFFIXES 0 .dll.a)
		endif ()

		list(REMOVE_ITEM SUFFIXES "${CMAKE_STATIC_LIBRARY_SUFFIX}")
	endif ()

	set("${RETVAR}" "${SUFFIXES}" PARENT_SCOPE)
endfunction()

function(set_find_library_bitness BITNESS)
	if (":${BITNESS}:" STREQUAL ":64:")
		set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS TRUE)
	else ()
		set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS FALSE)
	endif ()
endfunction()
