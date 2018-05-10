
# Based on the current directory this macro creates unit-tests by filtering *.cpp files.
macro(createUnitTests TARGET_NAME REQUIRED_LIBRARIES_LIST)

	# Gather all files matching the filter from the current directory.
	file(GLOB testFiles Test*.cpp)
	
	# Create all tests.
	foreach(testFile ${testFiles})
		
		get_filename_component(testName ${testFile} NAME_WE)
	
		message(STATUS "Creating executable for test '${testName}' (inside target '${TARGET_NAME}'")
		set(targetTestName "${TARGET_NAME}_${testName}")
	
		# Set up the test
		add_executable("${targetTestName}" "${testFile}")
		
		target_link_libraries(${targetTestName} ${REQUIRED_LIBRARIES_LIST})		
		
		setTargetCompileOptions(${targetTestName})
	
		add_test(NAME "${targetTestName}" COMMAND "${targetTestName}")	
	
	endforeach()
	
endmacro()