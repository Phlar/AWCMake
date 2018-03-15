
# Import all *.cmake files from this directory.
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}") 	# In order to make include() below work, add this directory to CMAKE_MODULE_PATH.
file(GLOB foundFiles ${CMAKE_CURRENT_SOURCE_DIR}/. "*.cmake")	# Get all potential files.

list(LENGTH foundFiles numFiles)
message(STATUS "Found ${numFiles} potential module-finders:")
foreach(foundFile ${foundFiles})
	get_filename_component(baseFileName ${foundFile} NAME_WE)
	message(STATUS "Importing ${baseFileName}")
endforeach(foundFile)