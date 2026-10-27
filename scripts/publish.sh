#!/bin/bash
# Publishes a release in one go: dev → main, tag, signed zip, GitHub release with the notes from
# CHANGELOG.md, and the updated Homebrew cask.
#
# Usage: scripts/publish.sh <version>     e.g. scripts/publish.sh 0.21.3-stage.2
# Needs: GitHub CLI logged in (`gh auth login`), the "AeroStage Release" signing certificate and
#        the tap checked out next to this repository (../homebrew-tap, or $AEROSTAGE_TAP).
set -euo pipefail
cd "$(dirname "$0")/.."

[[ $# -eq 1 ]] || { echo "Usage: scripts/publish.sh <version>" >&2; exit 2; }
REPO="Tech-Maou/AeroStage-WM"
NAME="AeroStage WM"
VERSION="$1"
ZIP="dist/AeroStage-WM-v$VERSION.zip"
APP="build/AeroStage WM.app"
CASK="aerostage-wm"
release_build() { AEROSTAGE_SIGN_IDENTITY="AeroStage Release" scripts/release.sh "$VERSION"; }

source scripts/publish-common.sh
