AptInstall(libgl1-mesa-dev libglfw3-dev freeglut3-dev libglew-dev)

AddProject(monodzukuri_demo
  GITHUB bastien-muraccioli/monodzukuri2024_kinova_demo
  GIT_TAG origin/main
  DEPENDS mc_rtc
)
