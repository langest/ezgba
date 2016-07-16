# Internal function. Do not call directly.
function(_xparse_arguments_splitarg ARG TYPE RETNAME)
	# CMake's regex implementation is wonky. This is a workaround.
	set(DELIM "<NOBODYJONESKNOWSWHATMANYNEVERKNEWTHATADREAMISONLYREALWHENITSTARTSINSIDEYOUNOBODYJONESKNOWSITSNOTINANAMESHEKNOWSSHESSOMEBODYIFTHEYDONTFEELTHESAMENOBODYJONESISAWINNERBYFARSHESEESPASTWHERESHESFROMSHEKEEPSHOPEINHERHEART>")
	string(REGEX MATCH "^[^\\\\=:]*(\\\\.[^\\\\=:]*)*" ARG_NAME "${ARG}")
	
	string(REPLACE "${DELIM}${ARG_NAME}" "" ARG_DEFAULT_VALUE "${DELIM}${ARG}")
	string(REGEX MATCH "^=(\\\\.|[^\\\\:])*" ARG_DEFAULT_VALUE "${ARG_DEFAULT_VALUE}")
	string(REPLACE "${DELIM}=" "" ARG_DEFAULT_VALUE "${DELIM}${ARG_DEFAULT_VALUE}")
	string(REPLACE "${DELIM}" "" ARG_DEFAULT_VALUE "${ARG_DEFAULT_VALUE}")
	
	string(REGEX MATCH "^[^\\\\:]*(\\\\.[^\\\\:]*)*" ARG_VALID_REGEX "${ARG}")
	string(REPLACE "${DELIM}${ARG_VALID_REGEX}" "" ARG_VALID_REGEX "${DELIM}${ARG}")
	string(REPLACE "${DELIM}:" "" ARG_VALID_REGEX "${DELIM}${ARG_VALID_REGEX}")
	string(REPLACE "${DELIM}" "" ARG_VALID_REGEX "${ARG_VALID_REGEX}")
	
	# message(STATUS "ARG: \"${ARG}\"")
	# message(STATUS "ARG_NAME: \"${ARG_NAME}\"")
	# message(STATUS "ARG_DEFAULT_VALUE: \"${ARG_DEFAULT_VALUE}\"")
	# message(STATUS "ARG_VALID_REGEX: \"${ARG_VALID_REGEX}\"")
	
	set("ARG_${ARG_NAME}_DEFAULT_VALUE" "${ARG_DEFAULT_VALUE}" PARENT_SCOPE)
	set("ARG_${ARG_NAME}_VALID_REGEX" "${ARG_VALID_REGEX}" PARENT_SCOPE)
	
	if (ARG_DEFAULT_VALUE)
		set("ARG_${ARG_NAME}_VALUE" "${ARG_DEFAULT_VALUE}" PARENT_SCOPE)
	elseif (":${TYPE}:" STREQUAL ":TOGGLE:")
		set("ARG_${ARG_NAME}_VALUE" FALSE PARENT_SCOPE)
	else ()
		set("ARG_${ARG_NAME}_VALUE" "" PARENT_SCOPE)
	endif ()
	
	set("${RETNAME}" "${ARG_NAME}" PARENT_SCOPE)
endfunction()


function(xparse_arguments PREFIX TOGGLE_ARGS SINGLE_ARGS MULTI_ARGS)
	set(REMAINING_ARGN "")
	set(TOGGLE_ARG_NAMES "")
	set(SINGLE_ARG_NAMES "")
	set(MULTI_ARG_NAMES "")

	set(QUIET FALSE)

	set("REMAINING_ARGN" "")

	foreach(ARG ${TOGGLE_ARGS})
		_xparse_arguments_splitarg("${ARG}" TOGGLE ARG_NAME)
		list(APPEND TOGGLE_ARG_NAMES "${ARG_NAME}")
	endforeach()

	foreach(ARG ${SINGLE_ARGS})
		_xparse_arguments_splitarg("${ARG}" SINGLE ARG_NAME)
		list(APPEND SINGLE_ARG_NAMES "${ARG_NAME}")
	endforeach()

	foreach(ARG ${MULTI_ARGS})
		_xparse_arguments_splitarg("${ARG}" MULTI ARG_NAME)
		list(APPEND MULTI_ARG_NAMES "${ARG_NAME}")
	endforeach()



	# Range begins at 4 b/c this function has 4 expected arguments.
	set(ARGNC_RANGE_BEGIN 4)
	math(EXPR ARGNC_RANGE_END "${ARGC} - 1")

	set(READING_TYPE "")
	set(READING_ARG_NAME "")

	foreach(ARG_INDEX RANGE ${ARGNC_RANGE_BEGIN} ${ARGNC_RANGE_END})
		# Used to determine if argument is keyword or not.
		list(FIND TOGGLE_ARG_NAMES "${ARGV${ARG_INDEX}}" TOGGLE_ARG_INDEX)
		list(FIND SINGLE_ARG_NAMES "${ARGV${ARG_INDEX}}" SINGLE_ARG_INDEX)
		list(FIND MULTI_ARG_NAMES "${ARGV${ARG_INDEX}}" MULTI_ARG_INDEX)

		if (NOT TOGGLE_ARG_INDEX LESS 0)
			# Toggle-type keyword found.
			set("ARG_${ARGV${ARG_INDEX}}_VALUE" TRUE)
			set(READING_TYPE "")
			set(READING_ARG_NAME "")
		elseif (NOT SINGLE_ARG_INDEX LESS 0)
			# Single-argument keyword found.
			set(READING_TYPE SINGLE)
			set(READING_ARG_NAME "${ARGV${ARG_INDEX}}")
		elseif (NOT MULTI_ARG_INDEX LESS 0)
			# Multi-argument keyword found.
			set(READING_TYPE MULTI)
			set(READING_ARG_NAME "${ARGV${ARG_INDEX}}")
		else ()
			# Argument is a value.
			string(REPLACE ";" "\;" ESCAPED_ARG "${ARGV${ARG_INDEX}}")
			set(IS_ARG_VALID TRUE)

			if (NOT ":${ARG_${READING_ARG_NAME}_VALID_REGEX}:" STREQUAL "::" AND NOT ":${ARGV${ARG_INDEX}}:" STREQUAL "::")
				# Validate argument w/ regex.
				string(REGEX MATCH "${ARG_${READING_ARG_NAME}_VALID_REGEX}" RET "${ARGV${ARG_INDEX}}")

				if (":${RET}:" STREQUAL "::" AND NOT QUIET)
					message(AUTHOR_WARNING "Invalid argument \"${ARGV${ARG_INDEX}}\" for parameter \"${READING_ARG_NAME}\".")
					set(IS_ARG_VALID FALSE)
				endif ()
			endif ()

			if (":${READING_TYPE}:" STREQUAL ":SINGLE:")
				if (IS_ARG_VALID)
					set("ARG_${READING_ARG_NAME}_VALUE" "${ESCAPED_ARG}")
				endif ()

				set(READING_TYPE "")
				set(READING_ARG_NAME "")
			elseif (":${READING_TYPE}:" STREQUAL ":MULTI:")
				if (IS_ARG_VALID)
					list(APPEND "ARG_${READING_ARG_NAME}_VALUE" "${ESCAPED_ARG}")
				endif ()
			endif ()

			if (":${READING_TYPE}:" STREQUAL "::")
				# No value is being read.
				list(APPEND "REMAINING_ARGN" "${ESCAPED_ARG}")
				set("REMAINING_ARGN" "${REMAINING_ARGN}")
			endif ()
		endif ()
	endforeach()


	# Proliferate all return values to parent scope.
	if (NOT ":${PREFIX}:" STREQUAL "::" AND NOT PREFIX MATCHES "_\$")
		set(PREFIX "${PREFIX}_")
	endif ()

	foreach(ARG_NAME ${TOGGLE_ARG_NAMES} ${SINGLE_ARG_NAMES} ${MULTI_ARG_NAMES})
		set("${PREFIX}${ARG_NAME}" "${ARG_${ARG_NAME}_VALUE}" PARENT_SCOPE)
#		message(WARNING "SET: ${PREFIX}${ARG_NAME} : ${ARG_${ARG_NAME}_VALUE}")
	endforeach()

	list(LENGTH "${REMAINING_ARGN}" REMAINING_ARGC)
	set("${PREFIX}REMAINING_ARGN" "${REMAINING_ARGN}" PARENT_SCOPE)
	set("${PREFIX}REMAINING_ARGC" "${REMAINING_ARGC}" PARENT_SCOPE)
endfunction()
