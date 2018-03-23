
# Helper that retrieves the 'include', 'lib' and 'bin' directories beneath the provided path
# taking pre-configured CONFIG_* settings into account.
function(determineImportedTargetPaths ROOT_DIRECTORY OUT_INCLUDE_DIRECTORY OUT_LIB_DIRECTORY OUT_BIN_DIRECTORY)

	# Check the include directory.
	set(includeDirectory "${ROOT_DIRECTORY}/include")
	if(NOT EXISTS ${includeDirectory})
		message(STATUS "Could not determine an include directory for target '${TARGET_NAME}', expected at '${includeDirectory}'.")
	else()
		get_filename_component(includeDirectory ${includeDirectory} ABSOLUTE)
		set(${OUT_INCLUDE_DIRECTORY} ${includeDirectory} PARENT_SCOPE)
	endif()
	
	# Check the static lib directory.
	set(libDirectory "${ROOT_DIRECTORY}/lib/${CONFIG_OS}_${CONFIG_MEMORY_ARCHITECTURE}/${CONFIG_COMPILER}-${CONFIG_COMPILER_VERSION}/${CONFIG_BUILD_TYPE}")
	if(NOT EXISTS ${libDirectory})
		message(STATUS "Could not determine 'lib' directory for target '${TARGET_NAME}', expected at '${libDirectory}'.")
	else()
		get_filename_component(libDirectory ${libDirectory} ABSOLUTE)
		set(${OUT_LIB_DIRECTORY} ${libDirectory} PARENT_SCOPE)
	endif()
	
	# Check the shared-lib directory.
	set(binDirectory "${ROOT_DIRECTORY}/bin/${CONFIG_OS}_${CONFIG_MEMORY_ARCHITECTURE}/${CONFIG_COMPILER}-${CONFIG_COMPILER_VERSION}/${CONFIG_BUILD_TYPE}")
	if(NOT EXISTS ${binDirectory})
		message(STATUS "Could not determine 'bin' directory for target '${TARGET_NAME}', expected at '${binDirectory}'.")
	else()
		get_filename_component(binDirectory ${binDirectory} ABSOLUTE)
		set(${OUT_BIN_DIRECTORY} ${binDirectory} PARENT_SCOPE)
	endif()
endfunction()

# From the provided directory this function filters out all static-libraries.
function(getStaticLibraries DIRECTORY OUT_FILES)

	if(NOT DEFINED ${DIRECTORY})
		return()
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
function(getSharedLibraries DIRECTORY OUT_FILES)

	if(NOT DEFINED ${DIRECTORY})
		return()
	endif()

	get_filename_component(absolutePath ${${DIRECTORY}} ABSOLUTE)
	if(DEFINED WIN32)
		file(GLOB files "${absolutePath}/*.dll")
	else()
		file(GLOB files "${absolutePath}/*.so")
	endif()
	set(${OUT_FILES} ${files} PARENT_SCOPE)	
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
	
	message(STATUS "Information on imported target '${TARGET_NAME}':"
	"\n\tINTERFACE_INCLUDE_DIRECTORIES: '${interfaceIncludeDirectories}'"
	"\n\tIMPORTED_LOCATION: '${importedLocation}'"
	"\n\tIMPORTED_IMPLIB: '${importedImplib}'")

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
function(importTarget URL FILE_PATH TARGET_NAME)

	set(oneValueArgs EXPECTED_MD5)
    cmake_parse_arguments(localFunctionValues "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	#Determine the directory the packed artifact will reside in.
	get_filename_component(DOWNLOAD_DIRECTORY ${FILE_PATH} DIRECTORY)
	
	# Determine the target-directory the expanded artifact's content will reside in.
	string(REGEX REPLACE "\\.[^.]*$" "" TARGET_ROOT_DIRECTORY ${FILE_PATH}) # Strip the last ".*" from the archive.

	# For now quite a unsafe check whether to skip download / extraction - erase cmake-cache in order to trigger download again.
	if(DEFINED ${TARGET_NAME}_FOUND)
		message(STATUS "Skipping download / extraction of artifact containing target '${TARGET_NAME}' as it seems being there already.")
	else()
		# Download the artifact.
		downloadArchive(${URL} ${FILE_PATH} EXPECTED_MD5 ${localFunctionValues_EXPECTED_MD5})

		# Expand the archive next to the archive's location.
		expandArchive(${FILE_PATH} TARGET_DIRECTORY ${DOWNLOAD_DIRECTORY})

		# On the next 'configure' we already are aware of the archive / target.
		set(${TARGET_NAME}_FOUND ${TARGET_ROOT_DIRECTORY} CACHE STRING "Location of the artifact's root directory.")
	endif()
	
	# Now check whether there's a CMakeLists.txt in the root of the archive's directory - if so this file will handle target resolution.
	set(customCMakeListsFilePath "${TARGET_ROOT_DIRECTORY}/CMakeLists.txt")
	if(EXISTS ${customCMakeListsFilePath})

		message(STATUS "Custom CMakeLists.txt found in '${TARGET_ROOT_DIRECTORY}' for importing target '${TARGET_NAME}'.")
		include(${customCMakeListsFilePath})
	else()
	
		message(STATUS "No custom CMakeLists.txt found in '${TARGET_ROOT_DIRECTORY}', trying to import shared / static targets.")
		determineImportedTargetPaths(${TARGET_ROOT_DIRECTORY} targetIncludeDirectory targetLibDirectory targetBinDirectory)
		
		# Get all the files requited for setting up the targets below.
		getStaticLibraries(targetLibDirectory STATICALLY_LINKED_FILES)
		getSharedLibraries(targetBinDirectory SHARED_LINKED_FILES)
		getStaticLibraries(targetBinDirectory IMPORTER_LIBRARY_FILES)
		
		message(STATUS "Statically linked files for target '${TARGET_NAME}': '${STATICALLY_LINKED_FILES}'")
		message(STATUS "Shared / dynamically linked files for target '${TARGET_NAME}': '${SHARED_LINKED_FILES}'")
		message(STATUS "Importer library for target '${TARGET_NAME}': '${IMPORTER_LIBRARY_FILES}'")
		
		# Set up the static-target.
		set(STATIC_TARGET "${TARGET_NAME}_static")
		add_library(${STATIC_TARGET} STATIC IMPORTED)
		set_property(TARGET ${STATIC_TARGET} PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${targetIncludeDirectory})
		set_property(TARGET ${STATIC_TARGET} PROPERTY IMPORTED_LOCATION ${STATICALLY_LINKED_FILES})
		postImportTarget(${STATIC_TARGET})
		
		# Set up the shared-target.
		set(SHARED_TARGET "${TARGET_NAME}_shared")
		add_library(${SHARED_TARGET} SHARED IMPORTED)
		set_property(TARGET ${SHARED_TARGET} PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${targetIncludeDirectory})
		set_property(TARGET ${SHARED_TARGET} PROPERTY IMPORTED_LOCATION ${SHARED_LINKED_FILES})
		set_property(TARGET ${SHARED_TARGET} PROPERTY IMPORTED_IMPLIB ${IMPORTER_LIBRARY_FILES})
		postImportTarget(${SHARED_TARGET}) 
	endif()
	
endfunction()
