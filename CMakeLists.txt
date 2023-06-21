if(NOT WIN32)

cmake_minimum_required(VERSION 3.25)
project(Photino.Native)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(PROJ_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Photino.Native)

if(APPLE)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
  
  configure_file(${PROJ_DIR}/src/shared/Exports.cpp ${PROJ_DIR}/src/shared/Exports.mm COPYONLY)
  
  file(GLOB SOURCES "${PROJ_DIR}/src/shared/Exports.mm" "${PROJ_DIR}/src/platform/macos/*.mm")
else(UNIX AND NOT APPLE)
  find_package(PkgConfig REQUIRED)
  pkg_check_modules(GTK3 REQUIRED gtk+-3.0)
  pkg_check_modules(WEBKIT2GTK REQUIRED webkit2gtk-4.0)
  pkg_check_modules(LIBNOTIFY REQUIRED libnotify)

  file(GLOB SOURCES "${PROJ_DIR}/src/shared/Exports.cpp" "${PROJ_DIR}/src/platform/linux/*.cpp")
endif()

add_library(Photino.Native SHARED ${SOURCES})

set_target_properties(Photino.Native PROPERTIES OUTPUT_NAME Photino.Native PREFIX "")

target_include_directories(Photino.Native PRIVATE ${PROJ_DIR}/include/shared)

if(APPLE)
  target_include_directories(Photino.Native PRIVATE ${PROJ_DIR}/include/platform/macos)

  find_library(COCOA_LIBRARY Cocoa)
  find_library(FOUNDATION_LIBRARY Foundation)
  find_library(WEBKIT_LIBRARY WebKit)
  find_library(USER_NOTIFICATIONS_FRAMEWORK UserNotifications)
  target_link_libraries(Photino.Native ${COCOA_LIBRARY} ${FOUNDATION_LIBRARY} ${WEBKIT_LIBRARY} ${USER_NOTIFICATIONS_FRAMEWORK})
else(UNIX AND NOT APPLE)
  target_include_directories(Photino.Native PRIVATE ${PROJ_DIR}/include/platform/linux)
  target_include_directories(Photino.Native PRIVATE ${GTK3_INCLUDE_DIRS} ${WEBKIT2GTK_INCLUDE_DIRS} ${LIBNOTIFY_INCLUDE_DIRS})

  target_link_libraries(Photino.Native ${GTK3_LIBRARIES} ${WEBKIT2GTK_LIBRARIES} ${LIBNOTIFY_LIBRARIES})
endif()

endif()
