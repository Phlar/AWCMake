
# Memory architecture. (SYSTEM_MEMORY_ARCHITECTURE)
macro(determineMemoryArchitecture)

	list(APPEND SELECTABLE_MEMORY_ARCHITECTURES "32" "64") # Selectable from the UI.
	if(DEFINED CONFIG_MEMORY_ARCHITECTURE) # If the memory-architecture is passed from the outside, verify whether it's valid.
		if(NOT ${CONFIG_MEMORY_ARCHITECTURE} IN_LIST SELECTABLE_MEMORY_ARCHITECTURES)

			message(FATAL_ERROR "Invalid selected memory architecture '${CONFIG_MEMORY_ARCHITECTURE}', must be out of the following (${SELECTABLE_MEMORY_ARCHITECTURES}).")
		endif()
	else()
		list(GET SELECTABLE_MEMORY_ARCHITECTURES 0 CONFIG_MEMORY_ARCHITECTURE)
	endif()
	
	set(CONFIG_MEMORY_ARCHITECTURE ${CONFIG_MEMORY_ARCHITECTURE} CACHE STRING "Memory architecture.")
	set_property(CACHE CONFIG_MEMORY_ARCHITECTURE PROPERTY STRINGS ${SELECTABLE_MEMORY_ARCHITECTURES})
	message(STATUS "Memory architecture (CONFIG_MEMORY_ARCHITECTURE): '${CONFIG_MEMORY_ARCHITECTURE}'")
endmacro()

# Operating system. (CONFIG_OS)
macro(determineOS)
	
	if(WIN32)
		set(CONFIG_OS "win")
	elseif(UNIX)
		set(CONFIG_OS "linux")
	endif()

	if(NOT DEFINED CONFIG_OS)
		message(FATAL_ERROR "Error detecting operating-system.")
	endif()
	message(STATUS "Operating system (CONFIG_OS): '${CONFIG_OS}'")
endmacro()

# Compiler properties. (CONFIG_COMPILER, CONFIG_COMPILER_VERSION)
macro(determineCompilerProperties)

	# Compiler
	if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
		set(CONFIG_COMPILER "gcc")
	elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
		set(CONFIG_COMPILER "msvc")
	endif()

	if(NOT DEFINED CONFIG_COMPILER)
		message(FATAL_ERROR "Error detecting compiler from '${CMAKE_CXX_COMPILER_ID}'.")
	endif()
	
	# Version
	set(CONFIG_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})
	if(NOT DEFINED CONFIG_COMPILER_VERSION)
		message(FATAL_ERROR "Error detecting compiler-version for compiler '${CONFIG_COMPILER}'.")
	endif()
	
	message(STATUS "Compiler (CONFIG_COMPILER): '${CONFIG_COMPILER}'")
	message(STATUS "Compiler version (CONFIG_COMPILER_VERSION): '${CONFIG_COMPILER_VERSION}'")
endmacro()

macro(determineSystemConfiguration)

	determineMemoryArchitecture()
	determineOS()
	determineCompilerProperties()
endmacro()