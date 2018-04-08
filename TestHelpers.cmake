
# Based on the current directory this macro creates unit-tests by filtering *.cpp files.
macro(createUnitTests REQUIRED_LIBRARIES_LIST)

	# Gather all files matching the filter from the current directory.
	file(GLOB testFiles Test*.cpp)
	
	# Create all tests.
	foreach(testFile ${testFiles})
		
		get_filename_component(testName ${testFile} NAME_WE)
	
		message(STATUS "Creating executable for test - '${testName}'")
	
		# Set up the test
		add_executable(${testName} ${testFile})
	
		#Link to the provided libraries.
		target_link_libraries(${testName} ${REQUIRED_LIBRARIES_LIST})

		add_test(NAME ${testName} COMMAND ${testName})	
	
	endforeach()
	
endmacro()