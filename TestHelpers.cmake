
# Based on the current directory this macro creates unit-tests by filtering *.cpp files.
macro(createUnitTests TARGET_NAME REQUIRED_LIBRARIES_LIST)

    # gTest requires pthread on linux.
    if(CONFIG_OS STREQUAL "linux")
        list(APPEND REQUIRED_LIBRARIES_LIST "pthread")
    endif()

    set(testFilePrefix "Test")

    # Unit-tests themselves have to obey the pattern "Test*.cpp".
    # Gather all *.cpp files and sort them as unit-tests or additional files.
    file(GLOB cppFiles "*.cpp")
    foreach(cppFile ${cppFiles})
        get_filename_component(baseFileName ${cppFile} NAME_WE)
        string(FIND "${baseFileName}" "${testFilePrefix}" position)
        if("${position}" EQUAL 0)
            list(APPEND testSourceFiles "${cppFile}")
        else()
            list(APPEND additionalSourceFiles "${cppFile}")
        endif()
    endforeach()
    
    # All header files are considered additional supportive files.
    file(GLOB additionalHeaderFiles "*.hpp")

    # Create all tests.
    foreach(testFile ${testSourceFiles})

        get_filename_component(testName ${testFile} NAME_WE)

        message(STATUS "Creating executable for test '${testName}' (inside target '${TARGET_NAME}')")
        set(targetTestName "${TARGET_NAME}_${testName}")

        # Set up the test
        add_executable("${targetTestName}" "${testFile}" "${additionalSourceFiles}" "${additionalHeaderFiles}")
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