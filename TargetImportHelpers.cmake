
# Helper that retrieves the 'include', 'lib' and 'bin' directories beneath the provided path
# taking pre-configured CONFIG_* settings into account.
function(determineImportedTargetPaths ROOT_DIRECTORY IN_DETAIL_TARGET_NAME OUT_LIB_DIRECTORY OUT_BIN_DIRECTORY)

	# Check the include directory.
	#set(includeDirectory "${ROOT_DIRECTORY}/include")
	#if(NOT EXISTS ${includeDirectory})
	#	message(STATUS "Could not determine a target's 'include' directory expected at '${includeDirectory}'.")
	#else()
	#	get_filename_component(includeDirectory ${includeDirectory} ABSOLUTE)
	#	set(${OUT_INCLUDE_DIRECTORY} ${includeDirectory} PARENT_SCOPE)
	#endif()
	
	# Check the static lib directory.
	set(libDirectory "${ROOT_DIRECTORY}/lib/${CONFIG_OS}_${CONFIG_MEMORY_ARCHITECTURE}/${CONFIG_COMPILER}-${CONFIG_COMPILER_VERSION}/${CONFIG_BUILD_TYPE}/${IN_DETAIL_TARGET_NAME}")
	if(NOT EXISTS ${libDirectory})
		message(STATUS "Could not determine a target's 'lib' directory expected at '${libDirectory}'.")
	else()
		get_filename_component(libDirectory ${libDirectory} ABSOLUTE)
		set(${OUT_LIB_DIRECTORY} ${libDirectory} PARENT_SCOPE)
	endif()
	
	# Check the shared-lib directory.
	set(binDirectory "${ROOT_DIRECTORY}/bin/${CONFIG_OS}_${CONFIG_MEMORY_ARCHITECTURE}/${CONFIG_COMPILER}-${CONFIG_COMPILER_VERSION}/${CONFIG_BUILD_TYPE}/${IN_DETAIL_TARGET_NAME}")
	if(NOT EXISTS ${binDirectory})
		message(STATUS "Could not determine a target's 'bin' directory for target '${TARGET_NAME}', expected at '${binDirectory}'.")
	else()
		get_filename_component(binDirectory ${binDirectory} ABSOLUTE)
		set(${OUT_BIN_DIRECTORY} ${binDirectory} PARENT_SCOPE)
	endif()
endfunction()

# From the provided directory this function filters out all static-libraries.
function(getStaticLibrariesInternal DIRECTORY OUT_FILES)

	if(NOT DEFINED ${DIRECTORY})
		message(FATAL_ERROR "Error retrieving static-/importer- libraries, invalid directory provided.")
	endif()

	get_filename_component(absolutePath ${${DIRECTORY}} ABSOLUTE)
	if(DEFINED WIN32)
		file(GLOB files "${absolutePath}/*.lib")
	else()
		file(GLOB files "${absolutePath}/*.a")
	endif()	
	set(${OUT_FILES} ${files} PARENT_SCOPE)	
endfunction()

# From the provided directory this function filters out all shared-libraries.
function(getSharedLibrariesInternal DIRECTORY OUT_FILES)

	if(NOT DEFINED ${DIRECTORY})
		message(FATAL_ERROR "Error retrieving shared-libraries, invalid directory provided.")
	endif()

	get_filename_component(absolutePath ${${DIRECTORY}} ABSOLUTE)
	if(DEFINED WIN32)
		file(GLOB files "${absolutePath}/*.dll")
	else()
		file(GLOB files "${absolutePath}/*.so")
	endif()
	set(${OUT_FILES} ${files} PARENT_SCOPE)	
endfunction()

function(getSharedLibrary DIRECTORY OUT_FILE)
	
	getSharedLibrariesInternal(${DIRECTORY} foundFiles)
	if(DEFINED foundFiles)
		list(LENGTH foundFiles numFiles)
		if(${numFiles} GREATER 1)
			message(FATAL_ERROR "Error retrieving shared-library from directory '${${DIRECTORY}}' more (${numFiles}) than 1 file found.")
		else()
			list(GET foundFiles 0 foundFile)
			set(${OUT_FILE} ${foundFile} PARENT_SCOPE)
		endif()
	endif()
endfunction()

function(getStaticLibrary DIRECTORY OUT_FILE)
	
	getStaticLibrariesInternal(${DIRECTORY} foundFiles)
	if(foundFiles)		
		list(LENGTH foundFiles numFiles)
		if(${numFiles} GREATER 1)
			message(FATAL_ERROR "Error retrieving static-library from directory '${${DIRECTORY}}' more (${numFiles}) than 1 file found.")
		else()
			list(GET foundFiles 0 foundFile)
			set(${OUT_FILE} ${foundFile} PARENT_SCOPE)
		endif()
	endif()
endfunction()

function(getImporterLibrary DIRECTORY OUT_FILE)
	
	getStaticLibrariesInternal(${DIRECTORY} foundFiles)
	if(DEFINED foundFiles)
		list(LENGTH foundFiles numFiles)
		if(${numFiles} GREATER 1)
			message(FATAL_ERROR "Error retrieving importer-library from directory '${${DIRECTORY}}' more (${numFiles}) than 1 file found.")
		else()
			list(GET foundFiles 0 foundFile)
			set(${OUT_FILE} ${foundFile} PARENT_SCOPE)
		endif()
	endif()
endfunction()


macro(postImportTarget TARGET_NAME)

	get_target_property(interfaceIncludeDirectories ${TARGET_NAME}  INTERFACE_INCLUDE_DIRECTORIES)
	get_target_property(importedLocation ${TARGET_NAME} IMPORTED_LOCATION)
	get_target_property(importedImplib ${TARGET_NAME}  IMPORTED_IMPLIB)

	# In case of this target refers to shared-libraries, place them in the global 'bin'-dir here already.
	# Todo: Consider a more robust / fine-granular approach as this one copies all files despite the fact
	# that they are actually used in the final project or not.
	if(importedLocation) 
		file(COPY ${importedLocation} DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
	endif()
	
	# Now print some stats on the previous import.	
	getReadableVariableContent(interfaceIncludeDirectories interfaceIncludeDirectories)
	getReadableVariableContent(importedLocation importedLocation)
	getReadableVariableContent(importedImplib importedImplib)
	
	message(STATUS "Properties of imported target '${TARGET_NAME}':"
	"\n    INTERFACE_INCLUDE_DIRECTORIES: '${interfaceIncludeDirectories}'"
	"\n    IMPORTED_LOCATION: '${importedLocation}'"
	"\n    IMPORTED_IMPLIB: '${importedImplib}'")
	
	# Cache it to have something in the GUI...
	set(${TARGET_NAME}_FOUND "" CACHE STRING "Location of the artifact's root directory.")

endmacro()

# importTarget tries downloading the corresponding artifact and expands it.
# Then the root-directory is checked whether it contains a CMakeLists.txt.
# If existing, this file is supposed to handler importing the target. 
# Otherwise it tries to resolve the static / shared libraries and include
# paths on its own - resulting in a _SHARED and _STATIC imported target. 
# In the latter case the artifact has to meet the following requirements in
# order to be resolved:
# /someArtifact/include for the include path.
# /someArtifact/bin/${CONFIG_OS}_${CONFIG_MEMORY_ARCHITECTURE}/
#	${CONFIG_COMPILER}_${CONFIG_COMPILER_VERSION}/
#	ToLower(${CONFIG_BUILD_TYPE})/ containing *.so, *.dll, *.lib (Import lib for msvc)
# /someArtifact/lib/${CONFIG_OS}_${CONFIG_MEMORY_ARCHITECTURE}/
#	${CONFIG_COMPILER}_${CONFIG_COMPILER_VERSION}/
#	ToLower(${CONFIG_BUILD_TYPE})/ containing *.a *.lib
function(downloadAndimportTarget IN_URL IN_FILE_PATH)

	set(oneValueArgs EXPECTED_MD5)
    cmake_parse_arguments(localFunctionValues "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	#Determine the directory and the file-name.
	get_filename_component(DOWNLOAD_DIRECTORY ${IN_FILE_PATH} DIRECTORY)
	get_filename_component(DOWNLOAD_FILE_NAME ${IN_FILE_PATH} NAME)
	
	# Determine the target-directory the expanded artifact's content will reside in.
	string(REGEX REPLACE "\\.[^.]*$" "" TARGET_ROOT_DIRECTORY ${IN_FILE_PATH}) # Strip the last ".*" from the archive.
		
	# For now quite a unsafe check whether to skip download / extraction - erase the artifact in order to trigger download / expansion again.
	if(EXISTS ${IN_FILE_PATH})
		message(STATUS "Skipping download / extraction of artifact '${IN_FILE_PATH}' as it seems being there already.")
	else()
		# Download the artifact.
		downloadArchive(${IN_URL} ${IN_FILE_PATH} EXPECTED_MD5 ${localFunctionValues_EXPECTED_MD5})

		# Expand the archive next to the archive's location.
		expandArchive(${IN_FILE_PATH} TARGET_DIRECTORY ${DOWNLOAD_DIRECTORY})

		# On the next 'configure' we already are aware of the archive / target.
		# set(${TARGET_NAME}_FOUND ${TARGET_ROOT_DIRECTORY} CACHE STRING "Location of the artifact's root directory.")
	endif()
	
	# Now check whether there's a CMakeLists.txt in the root of the archive's directory - if so this file will handle target resolution.
	set(customCMakeListsFilePath "${TARGET_ROOT_DIRECTORY}/CMakeLists.txt")
	if(EXISTS ${customCMakeListsFilePath})

		message(STATUS "Custom CMakeLists.txt found in '${TARGET_ROOT_DIRECTORY}' for importing target.")
		include(${customCMakeListsFilePath})
	else()
	
		# Deduce the target's name based on the file-name.
		leftOfString(${DOWNLOAD_FILE_NAME} "[.\" \"]" TARGET_NAME)
		message(STATUS "No custom CMakeLists.txt found in '${TARGET_ROOT_DIRECTORY}', trying to import shared / static targets - deduced target-name '${TARGET_NAME}'.")		
		
		importTarget(${TARGET_ROOT_DIRECTORY} ${TARGET_NAME} "" "${TARGET_ROOT_DIRECTORY}/include")
	endif()	
endfunction()


macro(importTarget IN_DIRECTORY IN_TARGET_BASE_NAME IN_TARGET_DETAIL_NAME IN_TARGET_INCLUDE_DIRECTORIES)

	# Define the target-name (basename_detailname).
	#set(targetDetailName "")
	#if(NOT ${IN_TARGET_DETAIL_NAME} STREQUAL "")
	#	set(targetDetailName "_${IN_TARGET_DETAIL_NAME}")
	#endif()
	
	set(targetName "")
	if(NOT ${IN_TARGET_BASE_NAME} STREQUAL "")
		set(targetName "${IN_TARGET_BASE_NAME}_")
	endif()
	
	if(NOT ${IN_TARGET_DETAIL_NAME} STREQUAL "")
		set(targetName "${targetName}${IN_TARGET_DETAIL_NAME}_")
	endif()
	
	
	determineImportedTargetPaths(${IN_DIRECTORY} "${IN_TARGET_DETAIL_NAME}" targetLibDirectory targetBinDirectory)
	
	# Get all the files requited for setting up the targets below.
	getStaticLibrary(targetLibDirectory STATIC_LIBRARY)
	getSharedLibrary(targetBinDirectory SHARED_LIBRARY)
	getImporterLibrary(targetBinDirectory IMPORTER_LIBRARY)
	
	# Set up the static-target.
	set(STATIC_TARGET "${targetName}static")
	add_library(${STATIC_TARGET} STATIC IMPORTED)

	set_property(TARGET ${STATIC_TARGET} PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${IN_TARGET_INCLUDE_DIRECTORIES})
	if(EXISTS ${STATIC_LIBRARY})
		set_property(TARGET ${STATIC_TARGET} PROPERTY IMPORTED_LOCATION ${STATIC_LIBRARY})
	endif()
	postImportTarget(${STATIC_TARGET})
			
	# Set up the shared-target.
	set(SHARED_TARGET "${targetName}shared")
	add_library(${SHARED_TARGET} SHARED IMPORTED)
	
	set_property(TARGET ${SHARED_TARGET} PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${IN_TARGET_INCLUDE_DIRECTORIES})
	if(EXISTS ${SHARED_LIBRARY})
		set_property(TARGET ${SHARED_TARGET} PROPERTY IMPORTED_LOCATION ${SHARED_LIBRARY})
	endif()
	if(EXISTS ${IMPORTER_LIBRARY})
		set_property(TARGET ${SHARED_TARGET} PROPERTY IMPORTED_IMPLIB ${IMPORTER_LIBRARY})
	endif()		
	postImportTarget(${SHARED_TARGET})

endmacro()