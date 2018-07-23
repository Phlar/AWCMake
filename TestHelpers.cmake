
# Based on the current directory this macro creates unit-tests by filtering *.cpp files.
macro(createUnitTests TARGET_NAME REQUIRED_LIBRARIES_LIST)

    # gTest requires pthread on linux.
    if(CONFIG_OS STREQUAL "linux")
        list(APPEND REQUIRED_LIBRARIES_LIST "pthread")
    endif()

    # Gather all files matching the filter from the current directory.
    file(GLOB testFiles Test*.cpp)

    # Create all tests.
    foreach(testFile ${testFiles})

        get_filename_component(testName ${testFile} NAME_WE)

        message(STATUS "Creating executable for test '${testName}' (inside target '${TARGET_NAME}')")
        set(targetTestName "${TARGET_NAME}_${testName}")

        # Set up the test
        add_executable("${targetTestName}" "${testFile}")
        target_link_libraries(${targetTestName} ${REQUIRED_LIBRARIES_LIST})

        # Here we'd have to add all the private include headers of the library under test.
        # Right now we're a bit more aggressive by simply adding all "include directories" of
        # the passed targets from ${REQUIRED_LIBRARIES_LIST}.
        # Get the include-directories already "assigned"...
        set(originalIncludeDirectories "")
        get_target_property(originalIncludeDirectories ${targetTestName} "INCLUDE_DIRECTORIES")
        set(adjustedIncludeDirectories ${${originalIncludeDirectories}})

        # ...and extend them by the list of all the dependencies' include directories...
        foreach(requiredLib ${REQUIRED_LIBRARIES_LIST})

            # For some reason one may not query the include-directories from an interface-library target.
            # "INTERFACE_LIBRARY targets may only have whitelisted properties.  The
            # property "INCLUDE_DIRECTORIES" is not allowed."
            # Skipping them seems to work...
            get_target_property(requiredLibType ${requiredLib} TYPE)
            if(${requiredLibType} STREQUAL "INTERFACE_LIBRARY")
                continue()
            endif()

            get_target_property(directories ${requiredLib} "INCLUDE_DIRECTORIES")
            foreach(directory ${directories})
                if(directory)
                    list(APPEND adjustedIncludeDirectories "${directory}")
                endif()
            endforeach()
        endforeach()

#       message(STATUS "Include directories for project '${targetTestName}'..")
#       foreach(entry ${adjustedIncludeDirectories})
#           message(STATUS "\t${entry}")
#       endforeach()

        # ...and assign them back no the target.
        target_include_directories(${targetTestName} PUBLIC ${adjustedIncludeDirectories})

        
        setTargetCompileOptions(${targetTestName})

        add_test(NAME "${targetTestName}" COMMAND "${targetTestName}")    
    
    endforeach()

endmacro()