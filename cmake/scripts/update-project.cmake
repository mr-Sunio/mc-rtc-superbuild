cmake_minimum_required(VERSION 3.20)

# Skip update for non git repository
if(NOT EXISTS "${SOURCE_DIR}/.git")
  message("[SKIP] Update ${NAME}: not a git repository")
  return()
endif()

# Skip update for fixed tags It is technically possible to reposition a tag but we
# accept the risk
if(DEFINED GIT_TAG AND NOT GIT_TAG MATCHES "^origin/(.*)")
  message("[SKIP] Update ${NAME}: fixed to ${GIT_TAG}")
  return()
else()
  set(GIT_BRANCH_NAME "${GIT_TAG}")
  string(REGEX REPLACE "^origin/" "" GIT_BRANCH_NAME "${GIT_BRANCH_NAME}")
endif()

# We check that our work tree is clean and matches the desired branch

# First update the index
execute_process(
  COMMAND git update-index -q --ignore-submodules --refresh
  WORKING_DIRECTORY "${SOURCE_DIR}"
)

# Disallow unstaged changes in the working tree
execute_process(
  COMMAND git diff-files --quiet --ignore-submodules --
  RESULT_VARIABLE git_diff_err
  WORKING_DIRECTORY "${SOURCE_DIR}"
)
if(git_diff_err)
  message("[SKIP] Update ${NAME}: unstaged changes")
  return()
endif()

# Disallow uncommitted changes in the index
execute_process(
  COMMAND git diff-index --cached --quiet HEAD --ignore-submodules --
  RESULT_VARIABLE git_diff_err
  WORKING_DIRECTORY "${SOURCE_DIR}"
)
if(git_diff_err)
  message("[SKIP] Update ${NAME}: uncommited changes")
  return()
endif()

# Find the current remote branch
execute_process(
  COMMAND git rev-parse --abbrev-ref --symbolic-full-name @{u}
  RESULT_VARIABLE git_rev_parse_err
  OUTPUT_VARIABLE CURRENT_REMOTE_BRANCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
  WORKING_DIRECTORY "${SOURCE_DIR}"
)

if(git_rev_parse_err)
  message("[SKIP] Update ${NAME}: cannot figure tracking branch")
  return()
endif()

if(DEFINED GIT_TAG AND NOT "${CURRENT_REMOTE_BRANCH}" STREQUAL "${GIT_TAG}")
  message("[SKIP] Update ${NAME}: not tracking ${GIT_TAG}")
  return()
endif()

# Check if branches have diverged
# - `REMOTE_AHEAD_COUNT`: commits on remote not on local.
# - `LOCAL_AHEAD_COUNT`: commits on local not on remote.
# - If both are non-zero, branches have diverged.

# Get commit counts
execute_process(
  COMMAND git rev-list --count ${GIT_BRANCH_NAME}..origin/${GIT_BRANCH_NAME}
  WORKING_DIRECTORY "${SOURCE_DIR}"
  OUTPUT_VARIABLE REMOTE_AHEAD_COUNT
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
  COMMAND git rev-list --count origin/${GIT_BRANCH_NAME}..${GIT_BRANCH_NAME}
  WORKING_DIRECTORY "${SOURCE_DIR}"
  OUTPUT_VARIABLE LOCAL_AHEAD_COUNT
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Detect divergence
if(NOT REMOTE_AHEAD_COUNT STREQUAL "0" AND NOT LOCAL_AHEAD_COUNT STREQUAL "0")
  message(
    "[SKIP] Update ${NAME}: local and remote branches have diverged, manual merge/rebase required"
  )
  return()
endif()

message("Update ${NAME}")
execute_process(
  COMMAND git pull --rebase
  RESULT_VARIABLE git_pull_err
  WORKING_DIRECTORY "${SOURCE_DIR}"
)
if(git_pull_err)
  message("[ERROR] Failed to update ${NAME}")
endif()

execute_process(
  COMMAND git submodule sync
  COMMAND git submodule update --init --recursive
  WORKING_DIRECTORY "${SOURCE_DIR}"
)

if(NOT DEFINED SOURCE_DESTINATION)
  return()
endif()

execute_process(
  COMMAND git add .
  WORKING_DIRECTORY "${SOURCE_DESTINATION}"
  OUTPUT_QUIET ERROR_QUIET
)
execute_process(
  COMMAND git commit -m "[${TARGET_FOLDER}] Updated submodule"
  WORKING_DIRECTORY "${SOURCE_DESTINATION}"
  OUTPUT_QUIET ERROR_QUIET
)

if(DEFINED PRE_COMMIT
   AND EXISTS "${PRE_COMMIT}"
   AND EXISTS "${SOURCE_DIR}/.pre-commit-config.yaml"
   AND EXISTS "${SOURCE_DIR}/.git"
)
  execute_process(
    COMMAND ${PRE_COMMIT} install WORKING_DIRECTORY ${SOURCE_DIR}
                                                    COMMAND_ERROR_IS_FATAL ANY
  )
endif()

if(NOT "${LINK_TO}" STREQUAL "")
  if(NOT WIN32)
    file(CREATE_LINK "${SOURCE_DESTINATION}/${TARGET_FOLDER}" "${LINK_TO}" SYMBOLIC)
  else()
    file(COPY "${SOURCE_DESTINATION}/${TARGET_FOLDER}" "${LINK_TO}")
    if("${OPERATION}" STREQUAL "init")
      file(APPEND "${SOURCE_DESTINATION}/.gitignore" "${LINK_TO}/*")
    endif()
  endif()
endif()
