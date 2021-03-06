include(GNUInstallDirs)

# Compute the installation prefix relative to this file.
GET_FILENAME_COMPONENT(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
GET_FILENAME_COMPONENT(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
GET_FILENAME_COMPONENT(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
GET_FILENAME_COMPONENT(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

set(shared_lib_name ${CMAKE_SHARED_LIBRARY_PREFIX}sr25519crust${CMAKE_SHARED_LIBRARY_SUFFIX})
set(static_lib_name ${CMAKE_STATIC_LIBRARY_PREFIX}sr25519crust${CMAKE_STATIC_LIBRARY_SUFFIX})
if(EXISTS ${_IMPORT_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${shared_lib_name})
    set(lib ${shared_lib_name})
elseif(EXISTS ${_IMPORT_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${static_lib_name})
    set(lib ${static_lib_name})
else()
    message(ERROR "sr25519 library not found!")
endif()

set(include_path sr25519)
if(NOT EXISTS ${_IMPORT_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}/${include_path})
    message(ERROR "sr25519 header not found!")
endif()

if(NOT TARGET sr25519::sr25519)
    add_library(sr25519::sr25519 STATIC IMPORTED GLOBAL)

    if(EXISTS ${_IMPORT_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${static_lib_name})
        if (APPLE)
            # on apple we need to link Security
            find_library(Security Security)
            find_package_handle_standard_args(sr25519::sr25519
                REQUIRED_VARS Security
                )
            set_target_properties(sr25519::sr25519 PROPERTIES
                INTERFACE_LINK_LIBRARIES ${Security}
                )
        elseif (UNIX)
            # on Linux we need to link pthread
            target_link_libraries(sr25519::sr25519 INTERFACE
                pthread
                -Wl,--no-as-needed
                dl
                )
        else ()
            message(ERROR "You've built static lib, it may not link on this platform. Come here and fix.")
        endif ()
    endif()


    set_target_properties(sr25519::sr25519 PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES ${_IMPORT_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}/${include_path}
        IMPORTED_LOCATION ${_IMPORT_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${lib}
        )
endif()
