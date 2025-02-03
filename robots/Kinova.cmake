option(WITH_Kinova "Build Kinova support" OFF)

if(NOT WITH_Kinova)
	return()
endif()

if(NOT WITH_ROS_SUPPORT)
  message(FATAL_ERROR "ROS support is required to use the Kinova robot")
endif()

AptInstall(
  ros-${ROS_DISTRO}-gazebo-ros
  ros-${ROS_DISTRO}-controller-manager
  ros-${ROS_DISTRO}-control-msgs
  ros-${ROS_DISTRO}-control-toolbox
  ros-${ROS_DISTRO}-moveit-ros-planning-interface
)

# Install conan if needed
find_program(CONAN conan)
if(NOT CONAN)
  find_program(PYTHON3 python3)
  if(NOT PYTHON3)
    message(FATAL_ERROR "Must have python3 to install conan to use the Kinova robot")
  endif()
  execute_process(COMMAND sudo python3 -m pip install conan==1.60.1 COMMAND_ERROR_IS_FATAL ANY)
  find_program(CONAN conan)
  if(NOT CONAN)
    message(FATAL_ERROR "Conan installation went wrong")
  endif()
  file(REAL_PATH ${CMAKE_C_COMPILER} CONAN_C_COMPILER)
  file(REAL_PATH ${CMAKE_CXX_COMPILER} CONAN_CXX_COMPILER)
  execute_process(COMMAND ${CMAKE_COMMAND} -E env CC=${CONAN_C_COMPILER} CXX=${CONAN_CXX_COMPILER} ${CONAN} profile new default --detect COMMAND_ERROR_IS_FATAL ANY)
  execute_process(COMMAND ${CONAN} profile update settings.compiler.libcxx=libstdc++11 default COMMAND_ERROR_IS_FATAL ANY)
endif()
execute_process(COMMAND ${CONAN} config set general.revisions_enabled=1 COMMAND_ERROR_IS_FATAL ANY)

AddCatkinProject(ros_kortex
  GITHUB Kinovarobotics/ros_kortex
  GIT_TAG origin/${ROS_DISTRO}-devel
  WORKSPACE data_ws
)

AddProject(mc_kinova
  GITHUB mathieu-celerier/mc_kinova
	GIT_TAG origin/main
	DEPENDS mc_rtc
)
