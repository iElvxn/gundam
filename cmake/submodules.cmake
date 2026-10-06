
# SubModules: These are just adding the code directly, as stand-alone projects.

message("")
cmessage( WARNING "Checking submodules..." )

function( checkSubmodule )

  list( GET ARGV 0 SELECTED_SUBMODULE )
  cmessage( STATUS "Checking submodule: ${SELECTED_SUBMODULE}" )

  file( GLOB FILES_IN_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/submodules/${SELECTED_SUBMODULE}/*")

  if( FILES_IN_DIRECTORY )
    cmessage( STATUS "Git submodule ${SELECTED_SUBMODULE} is present" )
  else()
    cmessage( ERROR "Git submodule ${SELECTED_SUBMODULE} is not present, please checkout: \"git submodule update --init --remote --recursive\"" )
    cmessage( FATAL_ERROR "CMake fatal error." )
  endif()

endfunction( checkSubmodule )

checkSubmodule( cpp-generic-toolbox )
checkSubmodule( simple-cpp-logger )
checkSubmodule( simple-cpp-cmd-line-parser )

# The submodules are header-only and their own CMakeLists.txt only build
# examples, so each one is wrapped in an INTERFACE target here. A target that
# links one gets its include path, macro settings and dependencies.
#
# The macro settings are compile options, not compile definitions, on purpose:
# ROOT_GENERATE_DICTIONARY forwards a MODULE target's compile definitions to
# rootcling, which strips the quotes from string values like
# LOGGER_TIME_FORMAT and fails. rootcling never saw these settings before.

## CmdLineParser
add_library( GundamCmdLineParser INTERFACE )
target_include_directories( GundamCmdLineParser INTERFACE
  ${CMAKE_SOURCE_DIR}/submodules/simple-cpp-cmd-line-parser/include )
target_compile_options( GundamCmdLineParser INTERFACE -DCMDLINEPARSER_YAML_CPP_ENABLED=1 )
target_link_libraries( GundamCmdLineParser INTERFACE yaml-cpp::yaml-cpp )

## GenericToolbox
add_library( GundamGenericToolbox INTERFACE )
target_include_directories( GundamGenericToolbox INTERFACE
  ${CMAKE_SOURCE_DIR}/submodules/cpp-generic-toolbox/include )
target_link_libraries( GundamGenericToolbox INTERFACE nlohmann_json::nlohmann_json )

#file( GLOB CPP_GENERIC_TOOLBOX_HEADERS ${CMAKE_SOURCE_DIR}/submodules/cpp-generic-toolbox/include/*.h )
#file( GLOB CPP_GENERIC_TOOLBOX_HEADERS_IMPL ${CMAKE_SOURCE_DIR}/submodules/cpp-generic-toolbox/include/implementation/*.h )
#install(FILES ${CPP_GENERIC_TOOLBOX_HEADERS} DESTINATION include)
#install(FILES ${CPP_GENERIC_TOOLBOX_HEADERS_IMPL} DESTINATION include/implementation)

target_compile_options( GundamGenericToolbox INTERFACE "-DPROGRESS_BAR_FILL_TAG=\"GUNDAM\"" )
if (ENABLE_COLOR_OUTPUT)
  target_compile_options( GundamGenericToolbox INTERFACE -DPROGRESS_BAR_ENABLE_RAINBOW=1 )
else (ENABLE_COLOR_OUTPUT)
  target_compile_options( GundamGenericToolbox INTERFACE -DCPP_GENERIC_TOOLBOX_NOCOLOR )
endif (ENABLE_COLOR_OUTPUT)
if( ENABLE_BATCH_MODE )
  target_compile_options( GundamGenericToolbox INTERFACE -DCPP_GENERIC_TOOLBOX_BATCH )
endif( ENABLE_BATCH_MODE )

## Logger
add_library( GundamLogger INTERFACE )
target_include_directories( GundamLogger INTERFACE
  ${CMAKE_SOURCE_DIR}/submodules/simple-cpp-logger/include )
target_compile_options( GundamLogger INTERFACE
  "-DLOGGER_TIME_FORMAT=\"%Y.%m.%d %H:%M:%S\""
  -DLOGGER_MAX_LOG_LEVEL_PRINTED=6
  -DLOGGER_PREFIX_LEVEL=3 )

if( ${CMAKE_BUILD_TYPE} MATCHES DEBUG OR ${ENABLE_DEV_MODE} )
  cmessage( STATUS "Logger set in DEBUG mode." )
  target_compile_options( GundamLogger INTERFACE "-DLOGGER_PREFIX_FORMAT=\"{TIME} {SEVERITY} {FILELINE}\"" )
else()
  cmessage( STATUS "Logger set in RELEASE mode." )
  target_compile_options( GundamLogger INTERFACE "-DLOGGER_PREFIX_FORMAT=\"{TIME} {SEVERITY} {FILENAME}\"" )
endif()

if(NOT ENABLE_COLOR_OUTPUT)
  cmessage( STATUS "Color output is disabled." )
  target_compile_options( GundamLogger INTERFACE -DLOGGER_ENABLE_COLORS=0 -DLOGGER_ENABLE_COLORS_ON_USER_HEADER=0 )
else()
  target_compile_options( GundamLogger INTERFACE -DLOGGER_ENABLE_COLORS=1 -DLOGGER_ENABLE_COLORS_ON_USER_HEADER=1 )
endif()

