
# Helper that retrieves the 'include', 'lib' and 'bin' directories beneath the provided path
# taking pre-configured CONFIG_* settings into account.
function(determineImportedTargetPaths ROOT_DIRECTORY OUT_INCLUDE_DIRECTORY OUT_LIB_DIRECTORY OUT_BIN_DIRECTORY)

	# Check the include directory.
	set(OUT_INCLUDE_DIRECTORY "${ROOT_DIRECTORY}/include")
	if(NOT EXISTS ${OUT_INCLUDE_DIRECTORY})
		message(STATUS "Could not determine an include directory for target '${TARGET_NAME}', expected at '${OUT_INCLUDE_DIRECTORY}'.")
	else()
		unset(OUT_INCLUDE_DIRECTORY)
	endif()
	
	# Check the static lib directory.
	set(OUT_LIB_DIRECTORY "${ROOT_DIRECTORY}/lib/${CONFIG_OS}_${CONFIG_MEMORY_ARCHITECTURE}/${CONFIG_COMPILER}-${CONFIG_COMPILER_VERSION}/${CONFIG_BUILD_TYPE}")
	if(NOT EXISTS ${OUT_LIB_DIRECTORY})
		message(STATUS "Could not determine 'lib' directory for target '${TARGET_NAME}', expected at '${OUT_LIB_DIRECTORY}'.")
	else()
		unset(OUT_LIB_DIRECTORY)
	endif()
	
	# Check the shared-lib directory.
	set(OUT_BIN_DIRECTORY "${ROOT_DIRECTORY}/bin/${CONFIG_OS}_${CONFIG_MEMORY_ARCHITECTURE}/${CONFIG_COMPILER}-${CONFIG_COMPILER_VERSION}/${CONFIG_BUILD_TYPE}")
	if(NOT EXISTS ${OUT_BIN_DIRECTORY})
		message(STATUS "Could not determine 'bin' directory for target '${TARGET_NAME}', expected at '${OUT_BIN_DIRECTORY}'.")
	else()
		unset(OUT_BIN_DIRECTORY)
	endif()
	
endfunction()

# From the provided directory this function filters out all static-libraries.
function(getStaticLibraries DIRECTORY OUT_FILES)

	if(DEFINED WIN32)
		file(GLOB OUT_FILES "${DIRECTORY}/*.lib")
	else()
		file(GLOB OUT_FILES "${DIRECTORY}/*.a")
	endif()	
endfunction()

# From the provided directory this function filters out all shared-libraries.
function(getStaticLibraries DIRECTORY OUT_FILES)

	if(DEFINED WIN32)
		file(GLOB OUT_FILES "${DIRECTORY}/*.dll")
	else()
		file(GLOB OUT_FILES "${DIRECTORY}/*.so")
	endif()	
endfunction()



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
	message(STATUS ${customCMakeListsFilePath})
	if(EXISTS ${customCMakeListsFilePath})
		message(STATUS "Custom CMakeLists.txt found in '${TARGET_ROOT_DIRECTORY}' for importing target '${TARGET_NAME}'.")
		include(${customCMakeListsFilePath})
	else()
	
		message(STATUS "No custom CMakeLists.txt found in '${TARGET_ROOT_DIRECTORY}', trying to import shared / static targets.")
		determineImportedTargetPaths(${TARGET_ROOT_DIRECTORY} targetIncludeDirectory targetLibDirectory targetBinDirectory)
		
		# TODO - Go for the files and set up the targets.
		
	endif()

endfunction()