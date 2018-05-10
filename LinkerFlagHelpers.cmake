
# Based on the determined configuration properties (SystemHelpers) the global 
# linker flags are set for all targets.
macro(setGlobalLinkerFlags)

	if(CONFIG_OS STREQUAL "win")
		setGlobalLinkerFlags_Win()
	elseif(CONFIG_OS STREQUAL "linux")
		setGlobalLinkerFlags_Linux()
	else() 
		message(WARNING "Could not set (global) linker settings, unknown operating-system '${CONFIG_OS}'.")
	endif()

endmacro()

macro(setGlobalLinkerFlags_Win)
	
	if(CONFIG_MEMORY_ARCHITECTURE STREQUAL "i386")
		setGlobalLinkerFlags_Win_i386()
	elseif(CONFIG_MEMORY_ARCHITECTURE STREQUAL "amd64")
		setGlobalLinkerFlags_Win_amd64()
	else() 
		message(WARNING "Could not set (global) linker settings (Win), unknown memory-architecture '${CONFIG_MEMORY_ARCHITECTURE}'.")
	endif()

endmacro()

macro(setGlobalLinkerFlags_Win_i386)
	
	if(CONFIG_BUILD_TYPE STREQUAL "debug")
		setGlobalLinkerFlags_Win_i386_Debug()
	elseif(CONFIG_BUILD_TYPE STREQUAL "release")
		setGlobalLinkerFlags_Win_i386_Release()
	else() 
		message(WARNING "Could not set (global) linker settings (Win, i386), unknown build-type '${CONFIG_BUILD_TYPE}'.")
	endif()

endmacro()

macro(setGlobalLinkerFlags_Win_amd64)
	
	if(CONFIG_BUILD_TYPE STREQUAL "debug")
		setGlobalLinkerFlags_Win_amd64_Debug()
	elseif(CONFIG_BUILD_TYPE STREQUAL "release")
		setGlobalLinkerFlags_Win_amd64_Release()
	else() 
		message(WARNING "Could not set (global) linker settings (Win, amd64), unknown build-type '${CONFIG_BUILD_TYPE}'.")
	endif()

endmacro()

macro(setGlobalLinkerFlags_Win_i386_Debug)
endmacro()

macro(setGlobalLinkerFlags_Win_i386_Release)
endmacro()

macro(setGlobalLinkerFlags_Win_amd64_Debug)
endmacro()

macro(setGlobalLinkerFlags_Win_amd64_Release)
endmacro()



macro(setGlobalLinkerFlags_Linux)
	
	if(CONFIG_MEMORY_ARCHITECTURE STREQUAL "i386")
		setGlobalLinkerFlags_Linux_i386()
	elseif(CONFIG_MEMORY_ARCHITECTURE STREQUAL "amd64")
		setGlobalLinkerFlags_Linux_amd64()
	else() 
		message(WARNING "Could not set (global) linker settings (Linux), unknown memory-architecture '${CONFIG_MEMORY_ARCHITECTURE}'.")
	endif()

endmacro()

macro(setGlobalLinkerFlags_Linux_i386)

	# Explicitly tell the linker what architecture the target should be linked to
	# e.g. on a 64 bit OS one still might want to link a 32 executable.
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -m32")
	set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -m32")
	
	if(CONFIG_BUILD_TYPE STREQUAL "debug")
		setGlobalLinkerFlags_Linux_i386_Debug()
	elseif(CONFIG_BUILD_TYPE STREQUAL "release")
		setGlobalLinkerFlags_Linux_i386_Release()
	else() 
		message(WARNING "Could not set (global) linker settings (Linux, i386), unknown build-type '${CONFIG_BUILD_TYPE}'.")
	endif()

endmacro()

macro(setGlobalLinkerFlags_Linux_amd64)

	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -m64")
	set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -m64")
	
	if(CONFIG_BUILD_TYPE STREQUAL "debug")
		setGlobalLinkerFlags_Linux_amd64_Debug()
	elseif(CONFIG_BUILD_TYPE STREQUAL "release")
		setGlobalLinkerFlags_Linux_amd64_Release()
	else() 
		message(WARNING "Could not set (global) linker settings (Linux, amd64), unknown build-type '${CONFIG_BUILD_TYPE}'.")
	endif()

endmacro()

macro(setGlobalLinkerFlags_Linux_i386_Debug)
endmacro()

macro(setGlobalLinkerFlags_Linux_i386_Release)
endmacro()

macro(setGlobalLinkerFlags_Linux_amd64_Debug)
endmacro()

macro(setGlobalLinkerFlags_Linux_amd64_Release)
endmacro()
