#!/bin/sh

function help {
	echo "btr v0.2.0, (c) Michael Wallner <mike@php.net>"
	echo
	echo "Usage: $(basename $0) [-hv] [<options>] <repository>"
	echo
	echo "    -h, --help      Display this help"
	echo "    -v, --verbose   Be more verbose"
	echo
	echo "  Options:"
	echo "    -s, --source=<rules>          Use the specified source ruleset"
	echo "    -b, --build=<rules>           Use the specified build ruleset"
	echo "    -r, --report=<rules>          Use the specifued report ruleset"
	echo "    -B, --branch=<branch>         Checkout this branch"
	echo "    -D, --directory=<directory>   Use this directory as work root"
	echo "    -S, --suffix=<suffix>         Append suffix to the build name"
	echo "    -C, --configure=<options>     Define \$CONFIGURE options"
	echo
	echo "  Rulesets:"
	for ruleset in source build report
	do
		printf "    %10s: %s\n" $ruleset \
			"$(find "$LIBDIR/$ruleset" -name '*.mk' -exec basename {} .mk \; | sort | xargs)"
	done
	echo
	exit
}

function parseopts {
	local shortoptions="hvB:D:S:C:s:b:r:"
	local longoptions="help,verbose,branch:,directory:,suffix:,configure:,source:,build:,report:"
	local options=$(getopt \
		--options "$shortoptions" \
		--longoptions "$longoptions" \
		-- "$@" \
	)

	if test $? -ne 0 ; then
		help
	fi
	
	eval set -- "$options"
	
	while test $# -gt 0
	do
		case "$1" in
			-h|--help)
				help
				;;
			-v|--verbose)
				VERBOSE=true
				;;
			####
			-B|--branch)
				BRANCH="$2"
				shift
				;;
			-D|--directory)
				BTRDIR="$2"
				shift
				;;
			-S|--suffix)
				SUFFIX="$2"
				shift
				;;
			-C|--configure)
				CONFIGURE="$2"
				shift
				;;
			####
			-s|--source)
				case "$2" in
					git)
						SOURCE_RULES="git"
						test -z "$BRANCH" && BRANCH="master"
						;;
					svn)
						SOURCE_RULES="svn"
						test -z "$BRANCH" && BRANCH="trunk"
						;;
				esac
				shift
				;;
			-b|--build)
				case "$2" in
					*)
						BUILD_RULES="$2"
						;;
				esac
				shift
				;;
			-r|--report)
				case "$2" in
					*)
						REPORT_RULES="$2"
						;;
				esac
				shift
				;;
			####
			--)
				SOURCE_URL="$2"
				shift
				;;
		esac
		shift
	done
}

function error {
	echo "$@" >&2
	exit
}

function setup {
	if test -z "$SOURCE_URL" -o -z "$SOURCE_RULES" -o -z "$BUILD_RULES" -o -z "$REPORT_RULES"
	then
		help
	fi

	export SOURCE_URL BRANCH SOURCE_RULES BUILD_RULES REPORT_RULES

	if test -z "$BTRDIR"
	then
		export BTRDIR="/tmp/btr"
	else
		export BTRDIR=$(realpath "$BTRDIR")
	fi

	export REPO=$(basename $(sed -re 's~^.*[/:]~~' <<<"$SOURCE_URL") .git)
	export SAFE_BRANCH=$(tr ":" "_" <<<$(basename "$BRANCH"))

	if test -z "$SUFFIX"
	then
		export BUILD="$REPO@$SAFE_BRANCH"
	else
		export BUILD="$REPO@$SAFE_BRANCH-$SUFFIX"
	fi

	export CLEAN_DIR="btr+clean-$REPO"
	export BRANCH_DIR="btr+branch-$REPO@$SAFE_BRANCH"
	export BUILD_DIR="btr+build-$BUILD"
	export CONFIG_REPORT="btr+config-$BUILD-$DATE"
	export BUILD_REPORT="btr+build-$BUILD-$DATE"
	export TEST_REPORT="btr+tests-$BUILD-$DATE"
	export LAST_REPORT=$(basename $(ls -t "$BTRDIR/btr+tests-$BUILD"* 2>/dev/null | tail -n1) 2>/dev/null)
	export REPORT=""
}

function show_conf {
	echo
	echo "BTRDIR		 = $BTRDIR"
	echo "BINDIR		 = $BINDIR"
	echo "LIBDIR		 = $LIBDIR"
	echo "SOURCE_URL	 = $SOURCE_URL"
	echo "SOURCE_RULES   = $SOURCE_RULES"
	echo "BUILD_RULES	= $BUILD_RULES"
	echo "REPORT_RULES   = $REPORT_RULES"
	echo "BRANCH		 = $BRANCH"
	echo "SAFE_BRANCH	= $SAFE_BRANCH"
	echo "CLEAN_DIR	  = $CLEAN_DIR"
	echo "BRANCH_DIR	 = $BRANCH_DIR"
	echo "BUILD_DIR	  = $BUILD_DIR"
	echo "CONFIG_REPORT  = $CONFIG_REPORT"
	echo "BUILD_REPORT   = $BUILD_REPORT"
	echo "TEST_REPORT	= $TEST_REPORT"
	echo "LAST_REPORT	= $LAST_REPORT"
	echo
}

function confirm {
	local CONTINUE
	echo -n "$1 (y/N) "
	read -r CONTINUE
	case $CONTINUE in
		y*|Y*)
			echo
			;;
		*)
			exit -1
			;;
	esac
}

# vim: noet
