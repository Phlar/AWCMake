
# 'This' directory contains modules, propagate them.
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")

include(StringHelpers)
include(SystemConfigHelpers)
include(FileHelpers)
include(TargetImportHelpers)
include(TestHelpers)

# Pull in custom finders.
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CustomModuleFinders)

# Detect system-config settings.
determineSystemConfiguration()
