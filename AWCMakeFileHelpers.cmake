
# Builds a (library)-filename based on global settings.
function(buildLibrary	FileName FILE_NAME)
	set(fileOutName "${FILE_NAME}_${CMAKE_SYSTEM_NAME}")
	if(BUILD_SHARED_LIBS)
		set(fileOutName "${fileOutName}_Dynamic")
	else()
		set(fileOutName "${fileOutName}_Static")
	endif()
	set(fileOutName "${fileOutName}_${CMAKE_BUILD_TYPE}")
	set(${FILE_NAME} "${fileOutName}" PARENT_SCOPE)
endfunction()

# Downloads s file and stores it locally.
# If EXPECTED_MD5 is set the associated hash will be compared after download is complete.
function(downloadArchive ORIGIN TARGET)

	set(oneValueArgs EXPECTED_MD5)
    cmake_parse_arguments(localFunctionValues "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
	
	if(NOT 3RD_PARTY_DIRECTORY)
		message(FATAL_ERROR "Error downloading artifact, '3RD_PARTY_DIRECTORY' not set.")
	endif(NOT 3RD_PARTY_DIRECTORY)
	
	if(localFunctionValues_EXPECTED_MD5)
		message(STATUS "Starting download from '${ORIGIN}' to '${TARGET}' (Expected md5 hash '${localFunctionValues_EXPECTED_MD5}').")
		file(DOWNLOAD ${ORIGIN} ${TARGET} EXPECTED_MD5 ${localFunctionValues_EXPECTED_MD5} STATUS downloadStatus)
	else()
		message(STATUS "Starting download from '${ORIGIN}' to '${TARGET}' (Warning, no md5 check will be performed!)")
		file(DOWNLOAD ${ORIGIN} ${TARGET} STATUS downloadStatus)
	endif()
	
	list(GET downloadStatus 0 errorCode)
	if(NOT errorCode EQUAL 0)
		list(GET downloadStatus 1 errorMessage)
		message(FATAL_ERROR "Error downloading artifact from '${ORIGIN}':  errorMessage")
	endif()
endfunction()

# Unzips provided file into a target-directory.
# If TARGET_DIRECTORY is set the file gets expanded into it. Otherwise
# the archive's base-name will be the name of the directory.
function(expandArchive ARCHIVE)

	set(oneValueArgs TARGET_DIRECTORY)
    cmake_parse_arguments(localFunctionValues "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
		
	if(localFunctionValues_TARGET_DIRECTORY)
		set(targetDirectory ${localFunctionValues_TARGET_DIRECTORY})
	else()
		get_filename_component(targetDirectory ${ARCHIVE} DIRECTORY)
	endif()

	message(STATUS "Expanding '${ARCHIVE}' into '${targetDirectory}'.")
	execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${ARCHIVE} WORKING_DIRECTORY ${targetDirectory} RESULT_VARIABLE executionResult)
	
	if(NOT executionResult EQUAL 0)
		message(FATAL_ERROR "Error unpacking artifact ('${ARCHIVE}') to '${targetDirectory}' - result: ${executionResult}")
	endif()
endfunction()
