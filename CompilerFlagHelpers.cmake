

# Based on the determined configuration properties (SystemHelpers) the compiler flags are set for a specific target.
macro(setTargetCompileOptions targetName)

	set(localCompileFlags "-std=c++11")

	if(CONFIG_OS STREQUAL "win")
		setTargetCompilerFlags_Win(${targetName} localCompileFlags)
	elseif(CONFIG_OS STREQUAL "linux")
		setTargetCompilerFlags_Linux(${targetName} localCompileFlags)
	else() 
		message(WARNING "Could not set compiler settings for target '${targetName}', unknown operating-system '${CONFIG_OS}'")
	endif()
	
	message(STATUS "Compile-flags for target '${targetName}': '${localCompileFlags}'")
	
	target_compile_options("${targetName}"
		PUBLIC 
			${localCompileFlags}
	)
endmacro()


function(setTargetCompilerFlags_Win targetName compileFlags)
	
	set(localCompileFlags ${${compileFlags}})		
	#list(APPEND localCompileFlags "/Wall" "/WX")

	if(CONFIG_MEMORY_ARCHITECTURE STREQUAL "i386")
		setTargetCompilerFlags_Win_i386("${targetName}" "${compileFlags}")
	elseif(CONFIG_MEMORY_ARCHITECTURE STREQUAL "amd64")
		setTargetCompilerFlags_Win_amd64("${targetName}" "${compileFlags}")
	else() 
		message(WARNING "Could not set compiler settings (Win) for target '${targetName}', unknown memory-architecture '${CONFIG_MEMORY_ARCHITECTURE}'.")
	endif()

	set(${compileFlags} ${localCompileFlags} PARENT_SCOPE)

endfunction()

function(setTargetCompilerFlags_Win_i386 targetName compileFlags)

	set(localCompileFlags ${${compileFlags}})	

	if(CONFIG_BUILD_TYPE STREQUAL "debug")
		setTargetCompilerFlags_Win_i386_Debug("${targetName}" localCompileFlags)
	elseif(CONFIG_BUILD_TYPE STREQUAL "release")
		setTargetCompilerFlags_Win_i386_Release("${targetName}" localCompileFlags)
	else() 
		message(WARNING "Could not set compiler settings (Win, i386) for target '${targetName}', unknown build-type '${CONFIG_BUILD_TYPE}'.")
	endif()

	set(${compileFlags} ${localCompileFlags} PARENT_SCOPE)

endfunction()

function(setTargetCompilerFlags_Win_amd64 targetName compileFlags)

	set(localCompileFlags ${${compileFlags}})	

	if(CONFIG_BUILD_TYPE STREQUAL "debug")
		setTargetCompilerFlags_Win_amd64_Debug("${targetName}" localCompileFlags)
	elseif(CONFIG_BUILD_TYPE STREQUAL "release")
		setTargetCompilerFlags_Win_amd64_Release("${targetName}" localCompileFlags)
	else() 
		message(WARNING "Could not set compiler settings (Win, amd64) for target '${targetName}', unknown build-type '${CONFIG_BUILD_TYPE}'.")
	endif()

	set(${compileFlags} ${localCompileFlags} PARENT_SCOPE)

endfunction()

function(setTargetCompilerFlags_Win_i386_Debug targetName compileFlags)
	set(localCompileFlags ${${compileFlags}})	
	list(APPEND localCompileFlags "/Zi" "/Od")
	set(${compileFlags} ${localCompileFlags} PARENT_SCOPE)
endfunction()

function(setTargetCompilerFlags_Win_i386_Release targetName compileFlags)
	set(localCompileFlags ${${compileFlags}})	
	list(APPEND localCompileFlags "/O2")
	set(${compileFlags} ${localCompileFlags} PARENT_SCOPE)	
endfunction()

function(setTargetCompilerFlags_Win_amd64_Debug targetName compileFlags)
	set(localCompileFlags ${${compileFlags}})	
	list(APPEND localCompileFlags "/Zi" "/Od")
	set(${compileFlags} ${localCompileFlags} PARENT_SCOPE)
endfunction()

function(setTargetCompilerFlags_Win_amd64_Release targetName compileFlags)	
	set(localCompileFlags ${${compileFlags}})	
	list(APPEND localCompileFlags "/O2")
	set(${compileFlags} ${localCompileFlags} PARENT_SCOPE)
endfunction()



function(setTargetCompilerFlags_Linux targetName compileFlags)

	set(localCompileFlags ${${compileFlags}})	
	list(APPEND localCompileFlags "-Wall" "-Werror" "-fpermissive")
	
	if(CONFIG_MEMORY_ARCHITECTURE STREQUAL "i386")
		setTargetCompilerFlags_Linux_i386("${targetName}" localCompileFlags)
	elseif(CONFIG_MEMORY_ARCHITECTURE STREQUAL "amd64")
		setTargetCompilerFlags_Linux_amd64("${targetName}" localCompileFlags)
	else() 
		message(WARNING "Could not set compiler settings (Linux) for target '${targetName}', unknown memory-architecture '${CONFIG_MEMORY_ARCHITECTURE}'.")
	endif()

	set(${compileFlags} ${localCompileFlags} PARENT_SCOPE)

endfunction()

function(setTargetCompilerFlags_Linux_i386 targetName compileFlags)

	set(localCompileFlags ${${compileFlags}})	
	list(APPEND localCompileFlags "-m32")

	if(CONFIG_BUILD_TYPE STREQUAL "debug")
		setTargetCompilerFlags_Linux_i386_Debug("${targetName}" localCompileFlags)
	elseif(CONFIG_BUILD_TYPE STREQUAL "release")
		setTargetCompilerFlags_Linux_i386_Release("${targetName}" localCompileFlags)
	else() 
		message(WARNING "Could not set compiler settings (Linux, i386) for target '${targetName}', unknown build-type '${CONFIG_BUILD_TYPE}'.")
	endif()

	set(${compileFlags} ${localCompileFlags} PARENT_SCOPE)

endfunction()

function(setTargetCompilerFlags_Linux_amd64 targetName compileFlags)

	set(localCompileFlags ${${compileFlags}})	
	list(APPEND localCompileFlags "-m64")

	if(CONFIG_BUILD_TYPE STREQUAL "debug")
		setTargetCompilerFlags_Linux_amd64_Debug("${targetName}" localCompileFlags)
	elseif(CONFIG_BUILD_TYPE STREQUAL "release")
		setTargetCompilerFlags_Linux_amd64_Release("${targetName}" localCompileFlags)
	else() 
		message(WARNING "Could not set compiler settings (Linux, amd64) for target '${targetName}', unknown build-type '${CONFIG_BUILD_TYPE}'.")
	endif()

	set(${compileFlags} ${localCompileFlags} PARENT_SCOPE)

endfunction()

function(setTargetCompilerFlags_Linux_i386_Debug targetName compileFlags)
	set(localCompileFlags ${${compileFlags}})	
	list(APPEND localCompileFlags "-O0")
	set(${compileFlags} ${localCompileFlags} PARENT_SCOPE)
endfunction()

function(setTargetCompilerFlags_Linux_i386_Release targetName compileFlags)
	set(localCompileFlags ${${compileFlags}})	
	list(APPEND localCompileFlags "-O3")
	set(${compileFlags} ${localCompileFlags} PARENT_SCOPE)	
endfunction()

function(setTargetCompilerFlags_Linux_amd64_Debug targetName compileFlags)
	set(localCompileFlags ${${compileFlags}})	
	list(APPEND localCompileFlags "-O0")
	set(${compileFlags} ${localCompileFlags} PARENT_SCOPE)
endfunction()

function(setTargetCompilerFlags_Linux_amd64_Release targetName compileFlags)	
	set(localCompileFlags ${${compileFlags}})	
	list(APPEND localCompileFlags "-O0")
	set(${compileFlags} ${localCompileFlags} PARENT_SCOPE)
endfunction()