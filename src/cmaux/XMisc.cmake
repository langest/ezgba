include(CMakeParseArguments)

macro(assert CONDITION)
	set(FAIL_MESSAGE "${ARGV1}")

	if (NOT "${CONDITION}")
		message(FATAL_ERROR "${FAIL_MESSAGE}")
	endif( ${CONDITION} )
endmacro()

function(push_variable VARNAME)
	if (NOT DEFINED _PUSH_VARIABLE_INDEX_${VARNAME})
		set(_PUSH_VARIABLE_INDEX_${VARNAME} 0)
	else ()
		math(EXPR _PUSH_VARIABLE_INDEX_${VARNAME} "${_PUSH_VARIABLE_INDEX_${VARNAME}} + 1")
	endif ()

	set(_PUSH_VARIABLE_VALUE_${_PUSH_VARIABLE_INDEX_${VARNAME}}_${VARNAME} "${${VARNAME}}" PARENT_SCOPE)
	set(_PUSH_VARIABLE_INDEX_${VARNAME} "${_PUSH_VARIABLE_INDEX_${VARNAME}}" PARENT_SCOPE)
endfunction()

function(pop_variable VARNAME)
	if (DEFINED _PUSH_VARIABLE_INDEX_${VARNAME} AND (_PUSH_VARIABLE_INDEX_${VARNAME} GREATER 0 OR _PUSH_VARIABLE_INDEX_${VARNAME} EQUAL 0))
		set("${VARNAME}" "${_PUSH_VARIABLE_VALUE_${_PUSH_VARIABLE_INDEX_${VARNAME}}_${VARNAME}}" PARENT_SCOPE)
		unset(_PUSH_VARIABLE_VALUE_${_PUSH_VARIABLE_INDEX_${VARNAME}}_${VARNAME} PARENT_SCOPE)

		math(EXPR _PUSH_VARIABLE_INDEX_${VARNAME} "${_PUSH_VARIABLE_INDEX_${VARNAME}} - 1")

		if (_PUSH_VARIABLE_INDEX_${VARNAME} LESS 0)
			unset(_PUSH_VARIABLE_INDEX_${VARNAME} PARENT_SCOPE)
		else ()
			set(_PUSH_VARIABLE_INDEX_${VARNAME} "${_PUSH_VARIABLE_INDEX_${VARNAME}}" PARENT_SCOPE)
		endif()
	else ()
		set("${VARNAME}" "" PARENT_SCOPE)
	endif ()
endfunction()

# Parse C/C++ source code for a #define and its assigned value.
function(read_src_define SRC_FILE DEFINE RETVAR)
	file(READ "${SRC_FILE}" SRC_DATA)

	string(REGEX REPLACE "\r\n?|\n" "\n" SRC_DATA "\n${SRC_DATA}\n")
	string(REGEX REPLACE ".*\n[ \t]*#define[ \t]+${DEFINE}[ \t]+([^\n]*).*" "\\1" MATCH "${SRC_DATA}")

	if (NOT ":${MATCH}:" STREQUAL ":${SRC_DATA}:")
		set("${RETVAR}" "${MATCH}" PARENT_SCOPE)
	else ()
		# Since 0 is a common define value, supporting if (RETVAR) .. endif () syntax doesn't make sense.
		#set("${RETVAR}" "${RETVAR}-NOTFOUND" PARENT_SCOPE)
		set("${RETVAR}" "" PARENT_SCOPE)
	endif ()
endfunction()

function(xset)
	# Only set the variable if the restrictions are met.
	set(_XSET_RESTRICTIONS "")

	# Restrictions:
	# IF_DEFINED
	# IF_UNDEFINED
	# IF_TRUE
	# IF_FALSE

	set(_XSET_ARGN "")
	set(_XSET_PARSE_RESTRICTIONS TRUE)
	set(_XSET_VARNAME "")
	math(EXPR _XSET_ARGC "${ARGC} - 1")
	foreach(_XSET_ARG_INDEX RANGE 0 ${_XSET_ARGC})
		set(_XSET_ARG "${ARGV${_XSET_ARG_INDEX}}")

		if (_XSET_PARSE_RESTRICTIONS)
			if (":${_XSET_ARG}:" MATCHES ":IF_DEFINED:|:IF_UNDEFINED:|:IF_TRUE:|:IF_FALSE:")
				list(APPEND _XSET_RESTRICTIONS "${_XSET_ARG}")
			else ()
				set(_XSET_PARSE_RESTRICTIONS FALSE)
				set(_XSET_VARNAME "${_XSET_ARG}")
			endif ()
		else()
			string(REPLACE "\"" "\\\"" _XSET_ARG "${_XSET_ARG}")
			string(REPLACE ";" "\\;" _XSET_ARG "${_XSET_ARG}")
			list(APPEND _XSET_ARGN "${_XSET_ARG}")
		endif()
	endforeach()

	# Set the variable by disqualification.
	set(_XSET_DO_SET TRUE)

	list(FIND _XSET_RESTRICTIONS IF_DEFINED _IF_DEFINED)
	list(FIND _XSET_RESTRICTIONS IF_UNDEFINED _IF_UNDEFINED)
	list(FIND _XSET_RESTRICTIONS IF_TRUE _IF_TRUE)
	list(FIND _XSET_RESTRICTIONS IF_FALSE _IF_FALSE)

	if (_IF_DEFINED GREATER -1 AND NOT DEFINED ${_XSET_VARNAME})
		set(_XSET_DO_SET FALSE)
	endif()

	if (_IF_UNDEFINED GREATER -1 AND DEFINED ${_XSET_VARNAME})
		set(_XSET_DO_SET FALSE)
	endif()

	if (_IF_TRUE GREATER -1 AND NOT ${_XSET_VARNAME})
		set(_XSET_DO_SET FALSE)
	endif()

	if ((_IF_FALSE GREATER -1) AND (${_XSET_VARNAME}))
		set(_XSET_DO_SET FALSE)
	endif()

	if (_XSET_DO_SET)
		set(${_XSET_VARNAME} ${_XSET_ARGN} PARENT_SCOPE)
	endif()
endfunction()


math(EXPR BUILD_MACHINE_BITNESS "${CMAKE_SIZEOF_VOID_P} * 8")
