# Industry Ready PHRI: A Control Framework for Physical Human-Robot Interaction Toward Industrial Applications

This repository contains the complete code base used in the paper:

> **"Demonstrating a Control Framework for Physical Human-Robot Interaction Toward Industrial Applications"**

![Static Badge](https://img.shields.io/badge/Paper_status-Submitted-orange?style=flat)

This work presents a novel control framework for physical human-robot interaction (PHRI) aimed at industrial applications. The repository is built on a modified version of the [mc-rtc-superbuild](https://github.com/mc-rtc/mc-rtc-superbuild) infrastructure. It has been adapted to automatically install all required dependencies and build the code necessary for reproducing the experiments and results described in the paper.

For more details, please visit the project website:  
[https://industry-ready-phri.github.io/](https://industry-ready-phri.github.io/)

---

## Overview

This superbuild repository will:
1. **Install all required system dependencies.**
2. **Clone and configure all necessary project repositories.**
3. **Build and install the projects** in a consistent and reproducible manner.

By using this repository, you can reproduce the experiments from the paper, test modifications, or extend the framework for your own research.

---

## Requirements

- **CMake ≥ 3.20**  
  [Download CMake](https://cmake.org/download/)
- **Git**  
  [Download Git](https://git-scm.com/)
- **Build Tools** (e.g., `build-essential` on Debian/Ubuntu)  
- **Operating System:** Tested on Linux (Debian/Ubuntu) and macOS  
  *(For Windows users, Visual Studio 2019 or later is required.)*

---

## Installation

### 1. Clone the Repository

```sh
git clone https://github.com/yourusername/industry-ready-phri.git
```

### 2. Bootstrap the Environment
Navigate to the cloned repository’s superbuild folder:
```sh
cd industry-ready-phri/mc-rtc-superbuild
```

Then run the bootstrap script to install system dependencies:
- On Debian-like systems:
```sh
./utils/bootstrap-linux.sh
```

- On macOS:
```sh
./utils/bootstrap-macos.sh
```

### 3. Configure and Build

Configure the superbuild by specifying where the source code should be cloned and where the build files will be generated. For example:

```sh
cmake -S . -B build \
  -DSOURCE_DESTINATION=${HOME}/devel/src \
  -DBUILD_DESTINATION=${HOME}/devel/build \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo
```

Then, build the complete project:
```sh
cmake --build build --config RelWithDebInfo
```

---

## Usage

After a successful build, the projects built by the superbuild are ready for use. You can:

- Run experiments: Launch simulation or control applications as described in the paper.
- Rebuild projects: If you modify the source, simply rebuild using:
```sh
cmake --build build --config RelWithDebInfo
```
- Clone repositories separately: To clone all repositories without building immediately, use:
```sh
cmake --build build --config RelWithDebInfo --target clone
```

## Updating the Code Base

To update all the cloned repositories with the latest changes, run:

```sh
cmake --build build --config RelWithDebInfo --target update
```

Or update a specific project (e.g., mc_rtc):

```sh
cmake --build build --config RelWithDebInfo --target update-mc_rtc
```

For updating the superbuild itself along with any extensions:

```sh
cmake --build build --config RelWithDebInfo --target self-update
```

## Uninstallation

If you need to remove the installed projects, you can uninstall everything at once:

```sh
cmake --build build --target uninstall
```

(Note: You might need sudo if the installation prefix requires elevated privileges.)

---

## Extensions and Customization

This code base is designed to be flexible. You can extend the framework by:

- Adding new projects via the main CMakeLists.txt (look for PERSONAL_PROJECTS).
- Creating new extensions under the extensions folder.
- Modifying or adding CMake options to suit specific experimental setups.

For further details on how to extend the superbuild, please refer to the original [mc-rtc-superbuild documentation](https://github.com/mc-rtc/mc-rtc-superbuild).

---

## Citation

If you use this code in your research, please cite the paper as follows:

---

## Contact

For any questions or issues, please open an issue in this repository or contact [bastien.muraccioli@aist.go.jp] or [mathieu.celerier@aist.go.jp].


---

This modified README now serves as a self-contained guide for reproducing the work associated with the paper, while maintaining the original superbuild functionality. Adjust paths, URLs, and other details as appropriate for your repository and project requirements.
