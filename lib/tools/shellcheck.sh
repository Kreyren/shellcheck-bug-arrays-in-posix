#!/usr/bin/env bash
# shellcheck shell=sh # POSIX

set -e # Exit on false

SHELLCHECK_VERSION=${SHELLCHECK_VERSION:-0.9.0} # https://github.com/koalaman/shellcheck/releases

SRC="$(
	cd "$(dirname "$0")/../.." || exit 1
	pwd -P
)"
echo "SRC: ${SRC}"

DIR_SHELLCHECK="$SRC/cache/tools/shellcheck"
mkdir -p "$DIR_SHELLCHECK"

MACHINE="$(uname -s)"

case "$MACHINE" in
	"Darwin") SHELLCHECK_OS="darwin" ;;
	"Linux") SHELLCHECK_OS="linux" ;;
	*)
		echo "unknown os: $MACHINE"
		exit 3
		;;
esac

ARCH="$(uname -m)"

case "$ARCH" in
	"aarch64") SHELLCHECK_ARCH="aarch64" ;;
	"x86_64") SHELLCHECK_ARCH="x86_64" ;;
	*)
		echo "unknown arch: $MACHINE"
		exit 2
		;;
esac

# https://github.com/koalaman/shellcheck/releases/download/v0.8.0/shellcheck-v0.8.0.darwin.x86_64.tar.xz
# https://github.com/koalaman/shellcheck/releases/download/v0.8.0/shellcheck-v0.8.0.linux.aarch64.tar.xz
# https://github.com/koalaman/shellcheck/releases/download/v0.8.0/shellcheck-v0.8.0.linux.x86_64.tar.xz

SHELLCHECK_FN="shellcheck-v$SHELLCHECK_VERSION.$SHELLCHECK_OS.$SHELLCHECK_ARCH"
SHELLCHECK_FN_TARXZ="$SHELLCHECK_FN.tar.xz"
DOWN_URL="https://github.com/koalaman/shellcheck/releases/download/v$SHELLCHECK_VERSION/$SHELLCHECK_FN_TARXZ"
SHELLCHECK_BIN="$DIR_SHELLCHECK/$SHELLCHECK_FN"

[ -f "${SHELLCHECK_BIN}" ] || {
	printf "%s\n" \
		"Cache for shellcheck was missed, downloading..." \
		"MACHINE: ${MACHINE}" \
		"Down URL: ${DOWN_URL}" \
		"SHELLCHECK_BIN: ${SHELLCHECK_BIN}"

	[ -f "$SHELLCHECK_BIN.tar.xz" ] || wget -O "$SHELLCHECK_BIN.tar.xz" "$DOWN_URL"

	[ -f "$DIR_SHELLCHECK/shellcheck-v$SHELLCHECK_VERSION/shellcheck" ] || tar -xf "${SHELLCHECK_BIN}.tar.xz" -C "$DIR_SHELLCHECK" "shellcheck-v$SHELLCHECK_VERSION/shellcheck"

	mv -v "$DIR_SHELLCHECK/shellcheck-v$SHELLCHECK_VERSION/shellcheck" "${SHELLCHECK_BIN}"
}

[ ! -f "$DIR_SHELLCHECK/shellcheck-v$SHELLCHECK_VERSION" ] || rm -rf "$DIR_SHELLCHECK/shellcheck-v$SHELLCHECK_VERSION"
[ ! -f "$SHELLCHECK_BIN.tar.xz" ] || rm -rf "$SHELLCHECK_BIN.tar.xz"

[ -x "$SHELLCHECK_BIN" ] || chmod +x "$SHELLCHECK_BIN"

# NOTE(Krey): This is stupid, i hate this, not worth refactoring -> Brainstorm better implementation

# ACTUAL_VERSION="$("$SHELLCHECK_BIN" --version | grep "^version")"

# calculate_params_for_severity() {
# 	SEVERITY="${SEVERITY:-"critical"}"

# 	params="--check-sourced --color=always --external-sources --format=tty --shell=bash"

# 	case "$SEVERITY" in
# 		important|critical)
# 			params="$params --severity=warning"
# 			;;

# 		*)
# 			params="$params --severity=$SEVERITY"
# 			;;
# 	esac
# }

# unset problems

# formats:
# checkstyle -- some XML format
# gcc - one per line, compact references; does not show the source
# tty - default for checkstyle

# cd "$SRC"

# # config/sources errors
# SEVERITY="error"
# calculate_params_for_severity
# config_source_files="$(find "$SRC/config/sources" -type f -name "*.inc" -o -name "*.conf" | tr "\n" " ")"
# config_board_files="$(find "$SRC/config/boards" -type f -name "*.wip" -o -name "*.tvb" -o -name "*.conf" -o -name "*.csc" -o -name "*.eos")"
# # add all elements of config_source_files and config_board_files to config_files
# config_files="$config_source_files $config_board_files"

# for file in $config_files; do
# 	printf "%s\n" "Running shellcheck $ACTUAL_VERSION against config file '$file' - severity 'SEVERITY=$SEVERITY'"
# done

# if "${SHELLCHECK_BIN}" "${params[@]}" "${config_files[@]}"; then
# 	echo "Congrats, no ${SEVERITY}'s detected in config/sources."
# else
# 	echo "Ooops, ${SEVERITY}'s detected in config/sources."
# 	problems+=("Ooops, ${SEVERITY}'s detected in config/sources.")
# fi

# # Lib/ code checks
# SEVERITY="critical"
# declare -a params=()
# calculate_params_for_severity
# echo "Running shellcheck ${ACTUAL_VERSION} against 'compile.sh' -- lib/ checks, severity 'SEVERITY=${SEVERITY}', please wait..."
# echo "All params: " "${params[@]}"

# if "${SHELLCHECK_BIN}" "${params[@]}" compile.sh; then
# 	echo "Congrats, no ${SEVERITY}'s detected in lib/ code."
# else
# 	problems+=("Ooops, ${SEVERITY}'s detected in lib/ code.")
# fi

# # show the problems, if any
# if [[ ${#problems[@]} -gt 0 ]]; then
# 	echo "Problems detected:"
# 	for problem in "${problems[@]}"; do
# 		echo " - ${problem}"
# 	done
# 	exit 1
# fi
