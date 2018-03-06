
# Builds a (library)-filename based on global settings.
function(buildLibraryFileName FILE_NAME)
	set(fileOutName "${FILE_NAME}_${CMAKE_SYSTEM_NAME}")
	if(BUILD_SHARED_LIBS)
		set(fileOutName "${fileOutName}_Dynamic")
	else(BUILD_SHARED_LIBS)
		set(fileOutName "${fileOutName}_Static")
	endif(BUILD_SHARED_LIBS)
	set(fileOutName "${fileOutName}_${CMAKE_BUILD_TYPE}")
	set(${FILE_NAME} "${fileOutName}" PARENT_SCOPE)
endfunction()