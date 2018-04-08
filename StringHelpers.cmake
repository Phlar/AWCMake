
macro(getReadableVariableContent INPUT OUTPUT)
	
	if(${INPUT})
		set(${OUTPUT} ${${INPUT}})
	else()
		set(${OUTPUT} "n.a.")	
	endif()
endmacro()

macro(leftOfString IN_STRING IN_REGEX OUT_RESULT)

	set(${OUT_RESULT} ${IN_STRING} PARENT_SCOPE)
	string(REGEX MATCH "[-.\" \"]" token ${IN_STRING})
	if(token)
		string(FIND ${IN_STRING} ${token} position)
		string(SUBSTRING ${IN_STRING} 0 ${position} left)
		set(${OUT_RESULT} ${left})		
		#message("Regex matches on ${IN_STRING}; token found: '${token}'; position: '${position}'; leftVar: '${left}'")
	endif()		
endmacro()