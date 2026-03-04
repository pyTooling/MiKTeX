#! /bin/bash
# =============================================================================
# Authors:          Patrick Lehmann
#
# Entity:           STDOUT Post-Processor for latexmk
#
# License:
# =============================================================================
# Copyright 2026-2026 Patrick Lehmann - Boetzingen, Germany
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#		http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# =============================================================================

ANSI_BLACK=$'\x1b[30m'
ANSI_RED=$'\x1b[31m'
ANSI_GREEN=$'\x1b[32m'
ANSI_YELLOW=$'\x1b[33m'
ANSI_BLUE=$'\x1b[34m'
ANSI_MAGENTA=$'\x1b[35m'
ANSI_CYAN=$'\x1b[36m'
ANSI_DARK_GRAY=$'\x1b[90m'
ANSI_LIGHT_GRAY=$'\x1b[37m'
ANSI_LIGHT_RED=$'\x1b[91m'
ANSI_LIGHT_GREEN=$'\x1b[92m'
ANSI_LIGHT_YELLOW=$'\x1b[93m'
ANSI_LIGHT_BLUE=$'\x1b[94m'
ANSI_LIGHT_MAGENTA=$'\x1b[95m'
ANSI_LIGHT_CYAN=$'\x1b[96m'
ANSI_WHITE=$'\x1b[97m'
ANSI_NOCOLOR=$'\x1b[0m'

# red texts
COLORED_ERROR="${ANSI_RED}[ERROR]"
COLORED_FAILED="${ANSI_RED}[FAILED]${ANSI_NOCOLOR}"

# yellow texts
COLORED_WARNING="${ANSI_YELLOW}[WARNING]"

# green texts
COLORED_PASSED="${ANSI_GREEN}[PASSED]${ANSI_NOCOLOR}"
COLORED_DONE="${ANSI_GREEN}[DONE]${ANSI_NOCOLOR}"
COLORED_SUCCESSFUL="${ANSI_GREEN}[SUCCESSFUL]${ANSI_NOCOLOR}"

# command line argument processing
COMMAND=2
INDENT=""
TIME=0
#VERBOSE=0
#DEBUG=0
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-i|--indent)
			INDENT="$2"; shift
			;;
		-t|--time)
			TIME=1
			;;
#		-v|--verbose)
#			VERBOSE=1
#			;;
#		-d|--debug)
#			VERBOSE=1
#			DEBUG=1
#			;;
		-h|--help)
			COMMAND=0
			;;
		*)		# unknown option
			printf -- "${COLORED_ERROR} Unknown command line option '$key'.${ANSI_NOCOLOR}\n" 1>&2
			COMMAND=1
		;;
	esac
	shift # past argument or value
done

if [ $COMMAND -le 1 ]; then
	test $COMMAND -eq 1 && printf -- "\n${COLORED_ERROR} No command selected.${ANSI_NOCOLOR}\n" 1>&2
	printf -- "\n"
	printf -- "Synopsis:\n"
	printf -- "  Script to filter latexmk outputs.\n"
	printf -- "\n"
	printf -- "Usage:\n"
	printf -- "  filter.latex.sh [-v][-d] [--help] [--indent <pattern>]\n"
	printf -- "\n"
	printf -- "Common commands:\n"
	printf -- "  -h --help             Print this help page.\n"
	printf -- "\n"
	printf -- "Common options:\n"
	printf -- "  -t --time             Print current time in front of each line.\n"
	printf -- "  -i --indent <pattern> Indent all lines with this pattern.\n"
#	printf -- "  -v --verbose          Print verbose messages.\n"
#	printf -- "  -d --debug            Print debug messages.\n"
	printf -- "\n"
	exit $COMMAND
fi

# RegExp patterns
ALL_TARGETS="^Latexmk: All targets"
PACKAGE_WARNING="^Package (\w+) Warning:"
NO_FILE="^\s*No file (.*)\.tex"

# Placeholder for the current timecode, if used
TIMECODE=""
EXIT_CODE=0

while read -r line; do
	test $TIME -eq 1 && printf -v TIMECODE "%(%H:%M:%S)T "

	if [[ "${line:0:10}" == "Run number" ]]; then
		printf -- "$INDENT${ANSI_LIGHT_CYAN}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
	elif [[ "${line:0:14}" == "LaTeX Warning:" ]]; then
		printf -- "$INDENT${ANSI_YELLOW}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
	elif [[ "${line}" =~ ${PACKAGE_WARNING} ]]; then
		printf -- "$INDENT${ANSI_YELLOW}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
	elif [[ "${line}" =~ ${NO_FILE} ]]; then
		printf -- "$INDENT${ANSI_RED}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
		EXIT_CODE=1
	elif [[ "${line:0:7}" == "No file" ]]; then
		printf -- "$INDENT${ANSI_YELLOW}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
	elif [[ "${line:0:27}" == "Latexmk: Missing input file" ]]; then
		printf -- "$INDENT${ANSI_YELLOW}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
	elif [[ "${line:0:23}" == "Latex failed to resolve" ]]; then
		printf -- "$INDENT${ANSI_LIGHT_RED}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
	elif [[ "${line:0:29}" == "! Undefined control sequence." ]]; then
		printf -- "$INDENT${ANSI_RED}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
		EXIT_CODE=2
	elif [[ "${line:0:9}" == "! Missing" ]]; then
		printf -- "$INDENT${ANSI_RED}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
		EXIT_CODE=2
	elif [[ "${line:0:17}" == "! Emergency stop." ]]; then
		printf -- "$INDENT${ANSI_MAGENTA}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
		EXIT_CODE=2
	elif [[ "${line:0:27}" == "!  ==> Fatal error occurred" ]]; then
		printf -- "$INDENT${ANSI_MAGENTA}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
		EXIT_CODE=2
	elif [[ "${line:0:15}" == "Latexmk: Errors" ]]; then
		printf -- "$INDENT${ANSI_MAGENTA}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
		EXIT_CODE=2
	elif [[ "${line:0:18}" == "Writing index file" ]]; then
		printf -- "$INDENT${ANSI_GREEN}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
	elif [[ "${line:0:17}" == "Output written on" ]]; then
		printf -- "$INDENT${ANSI_GREEN}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
	elif [[ "${line}" =~ ${ALL_TARGETS} ]]; then
		printf -- "$INDENT${ANSI_LIGHT_GREEN}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
	elif [[ "${line}" =~ "MiKTeX administrator" ]]; then
		printf -- "$INDENT${ANSI_DARK_GRAY}${TIMECODE}${line}${ANSI_NOCOLOR}\n"
	else
		printf -- "${INDENT}${TIMECODE}${line}\n"
	fi
done < "/dev/stdin"

exit ${EXIT_CODE}
