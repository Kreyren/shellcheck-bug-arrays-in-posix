#!/usr/bin/env bash
# shellcheck shell=sh

set -e # Exit on False

# FIXME(Krey): Import Helpers

# Metadata
FRAMEWORK_NAME="AerithForge"
FRAMEWORK_REPO="https://github.com/AerithForge/AerithForge"

SRC="$(realpath "$0")"
cd "$SRC"

# Source the libraries
# shellcheck source=./lib/library-functions.sh
. "$SRC/lib/library-functions.sh"

# initialize logging variables. (this does not consider parameters at this point, only environment variables)
logging_init

# initialize the traps
traps_init

# Execute the main CLI entrypoint.
cli_entrypoint "$@"

# Log the last statement of this script for debugging purposes.
display_alert "Framework build script exiting" "very last thing" "cleanup"
