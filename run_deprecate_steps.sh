#!/usr/bin/env bash

#
# Purpose: 
#   1. Deprecate golang repository for gitspaces and move to gitspaces.golang repo/pkg.golang
#   2. https://pkg.go.dev/github.com/davfive/gitspaces/v2 deprecate will retract all packages
#      and leave a Decprecated message pointing to the archive location at gitspaces.golang/v2
#   3. Rename gitspaces repo to gitspaces.golang
#   4. Separate action will move gitspaces.golang/main pypi commits to clean gitspaces repo
#

# Because: We want strict error handling and tracing: fail on error (-e), unset vars (-u), pipe fails (-o pipefail), and print commands before execution (-x).
# Afterward: The script executes safely, and its flow is printed step-by-step for debugging.
set -euxo pipefail

# --- CONFIGURATION ---

# IMPORTANT: Ensure this path points to the local directory containing your final V2 Go code.
SOURCE_DIR="." 
# The new home for the Go archive
ARCHIVE_REPO_URL="https://github.com/davfive/gitspaces.golang"
# The reclaimed name, which will host the Python V3 code and the deprecation message
RECLAIMED_REPO_URL="https://github.com/davfive/gitspaces"

# Final functional Go version tag
FINAL_GO_VERSION="v2.0.37"
# Metadata vehicle version tag (to carry the retract/deprecated message)
DEPRECATION_VERSION="v2.0.38"
# The module path used in the go.mod files
MODULE_PATH="github.com/davfive/gitspaces/v2"

# --- SAFETY CHECK: SOURCE DIRECTORY EXISTENCE ---
if [ ! -d "$SOURCE_DIR" ]; then echo "Error: Source directory '$SOURCE_DIR' not found."; exit 1; fi

# --- PHASE 1: INITIAL REPO SETUP (MANUAL ACTIONS) ---

echo ""
echo "=========================================================="
echo "MANUAL ACTION 1: RENAME REPOSITORY ON GITHUB"
echo "1. Go to https://github.com/davfive/gitspaces/settings"
echo "2. Rename the repository to davfive/gitspaces.golang"
echo "=========================================================="
read -p "Hit ENTER after renaming the repository to continue..."

echo ""
echo "=========================================================="
echo "MANUAL ACTION 2: CREATE NEW EMPTY REPOSITORY ON GITHUB"
echo "1. Create a NEW empty repository named davfive/gitspaces."
echo "   (DO NOT initialize with a README, license, or gitignore)"
echo "=========================================================="
read -p "Hit ENTER after creating the new repository to continue..."


# --- PHASE 2: PREP ARCHIVE REPO (FINAL GO V2 CODE - v2.0.37) ---

# Because: We move into the local repository which contains the last functional Go code.
# Afterward: All subsequent actions happen in the source directory.
cd "$SOURCE_DIR"

echo ""
echo "=========================================================="
echo "MANUAL ACTION 3: PREP FINAL ARCHIVE RELEASE FILE CHANGES"
echo "**THIS MUST BE DONE BEFORE RUNNING NEWTAG.**"
echo "1. Update go.mod module path: Change to 'module github.com/davfive/gitspaces.golang/v2'."
echo "2. ADD the 'deprecated' directive and its comment (pointing to the Python V3 move)."
echo "3. Ensure all functional require() lines are present."
echo "4. Ensure all modified files are saved."
echo "=========================================================="
read -p "Hit ENTER after completing all file edits and saving to continue..."

# Because: We update the local remote URL to point to the new archive location for the 'newtag' push.
# Afterward: The 'origin' remote is now the archive repository.
git remote set-url origin "$ARCHIVE_REPO_URL"

echo ""
echo "=========================================================="
echo "MANUAL ACTION 4: CREATE AND PUSH FINAL ARCHIVE TAG (v2.0.37)"
echo "1. Run the following command. It will run 'make newtag', which updates the version manifest, commits, tags, and pushes the final v2.0.37 release to the archive."
echo "   NOTE: Your current working directory must be clean before running."
echo "=========================================================="
read -p "Hit ENTER to run the make command: make newtag tag=${FINAL_GO_VERSION}..."
# Command to be run manually by the user: make newtag tag=v2.0.37
make newtag tag=${FINAL_GO_VERSION}

echo ""
echo "=========================================================="
echo "MANUAL ACTION 5: PUBLISH ARCHIVE VERSION (v2.0.37)"
echo "1. Run 'make publish' to notify the proxy and complete checks."
echo "=========================================================="
read -p "Hit ENTER after running the 'make publish' command..."
# Command to be run manually by the user: make publish
make publish


# --- PHASE 3: PREP DEPRECATION MESSAGE (v2.0.38) ---

echo ""
echo "=========================================================="
echo "MANUAL ACTION 6: CREATE DUMMY go.mod FOR DEPRECATION MESSAGE (v2.0.38)"
echo "1. Replace the entire contents of go.mod with the MINIMAL metadata for the message:"
echo "   - module github.com/davfive/gitspaces/v2"
echo "   - The full deprecation/archival message comment"
echo "   - The 'deprecated' keyword"
echo "   - The full 'retract' block covering v2.0.0 through ${FINAL_GO_VERSION}"
echo "   - Remove ALL 'require' lines, internal version constant files, and 'manifest.json'."
echo "2. Save the file and ensure the working directory is clean."
echo "=========================================================="
read -p "Hit ENTER after editing and saving the dummy go.mod to commit the changes..."

# Because: We commit the file containing the final message and retraction list.
# Afterward: The final message state is recorded locally.
git commit -a -m "chore: Final message and retraction commit (${DEPRECATION_VERSION})"

# Because: We mark this commit with the version dedicated to carrying the message.
# Afterward: This tag carries the authoritative retraction message.
git tag -a "${DEPRECATION_VERSION}" -m "Final Deprecation Message and Retraction Vehicle"

# Because: We update the local remote URL to point to the reclaimed repository.
# Afterward: The 'origin' remote is now the reclaimed repository.
git remote set-url origin "$RECLAIMED_REPO_URL"

# Because: We push the final message commit and tag to the reclaimed repository.
# Afterward: The reclaimed repository is ready to be queried for the message.
git push origin main
git push origin "${DEPRECATION_VERSION}"

echo ""
echo "=========================================================="
echo "MANUAL ACTION 7: PUBLISH DEPRECATION MESSAGE (v2.0.38)"
echo "1. Run the direct Go command to force the proxy to pull the metadata:"
echo "   GOPROXY=proxy.golang.org go list -m ${MODULE_PATH}@${DEPRECATION_VERSION}"
echo "=========================================================="
read -p "Hit ENTER after running the Go list command to continue..."
# Command to be run manually by the user: GOPROXY=proxy.golang.org go list -m github.com/davfive/gitspaces/v2@v2.0.38


# --- PHASE 4: CLEAN V3 HISTORY PUSH ---

# Because: We exit the V2 source directory.
# Afterward: We are back to the parent directory.
cd ..

echo ""
echo "=========================================================="
echo "MANUAL ACTION 8: PUSH CLEAN V3 PYTHON HISTORY"
echo "1. Enter the directory where the clean V3 Python history was created."
echo "2. Run the following commands to push the V3 history to the reclaimed repo ($RECLAIMED_REPO_URL):"
echo "   git remote add origin $RECLAIMED_REPO_URL"
echo "   git push -u origin main --force"
echo "   git push origin --tags"
echo "3. You must use --force to overwrite the temporary V2.0.38 commit."
echo "=========================================================="
read -p "Hit ENTER after pushing the clean V3 Python history to its new home..."

# Because: We need to inform users the process is complete and the next manual step is archival.
# Afterward: Script terminates successfully.
echo ""
echo "--------------------------------------------------------------------------"
echo "SUCCESS! Go module deprecation and archival process is complete."
echo "1. The archived Go module is at: ${ARCHIVE_REPO_URL}"
echo "2. The new Python home is at: ${RECLAIMED_REPO_URL}"
echo "3. FINAL STEP: Please manually set the ${ARCHIVE_REPO_URL} GitHub repo to ARCHIVED status to prevent future contribution."
echo "--------------------------------------------------------------------------"