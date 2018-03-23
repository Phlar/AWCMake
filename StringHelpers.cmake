
macro(getReadableVariableContent INPUT OUTPUT)
	
	if(${INPUT})
		set(${OUTPUT} ${${INPUT}})
	else()
		set(${OUTPUT} "n.a.")	
	endif()
endmacro()