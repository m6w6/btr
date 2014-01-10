#!/bin/sh

function help {
	echo "btr v0.3.0, (c) Michael Wallner <mike@php.net>"
	echo
	echo "Usage: $(basename $0) [-hyvqcC] [<options>]"
	echo
	echo "    -h, --help      Display this help"
	echo "    -y, --yes       Always assume yes"
	echo "    -v, --verbose   Be more verbose"
	echo "    -q, --quiet     Be more quiet"
	echo "    -c, --clean     Clean build"
	echo "    -C, --vcsclean  Clean repo/branch"
	echo
	echo "  Options:"
	echo "    -f, --config=<file>           Read configuration from a file"
	echo "    -s, --source=<rules>          Use the specified source ruleset"
	echo "    -b, --build=<rules>           Use the specified build ruleset"
	echo "    -r, --report=<rules>          Use the specifued report ruleset"
	echo "    -T, --test=<args>             Provide test runner arguments"
	echo "    -B, --branch=<branch>         Checkout this branch"
	echo "    -D, --directory=<directory>   Use this directory as work root"
	echo "    -S, --suffix=<suffix>         Append suffix to the build name"
	echo
	echo "  Rules format:"
	echo "    type=argument    e.g: git=git@github.com:m6w6/btr.git"
	echo "                          irc=irc://btr@chat.freenode.org/#btr"
	echo "                          mail=\"-c copy@to rcpt@to\""
	echo "                          notify-send=\"-u low\""
	echo
	echo "    Note though, that some rules do not use any argument."
	echo
	echo "  Rulesets:"
	for ruleset in source build report
	do
		printf "    %10s: %s\n" $ruleset \
			"$(find "$LIBDIR/$ruleset" -name '*.mk' -exec basename {} .mk \; | sort | xargs)"
	done
	echo
	echo "  Examples:"
	echo 
	echo "  Clone PHP's git, use PHP-5.5 branch, build with php ruleset and"
	echo "  run the test suite with valgrind (-m) on a debug build and report"
	echo "  the results with a simple OSD notification:"
	echo "    $ btr -s git=git@php.net:php/php-src.git -B PHP-5.5 \\"
	echo "          -b \"php=--enable-debug\" -T-m -r notify-send"
	echo "  See also php.example.conf"
	echo
	echo "  Clone CURL's git (use master), build with GNU autotools"
	echo "  ruleset which runs 'make check' and mail the report to the"
	echo "  current user. Verbosely show all actions taken:"
	echo "    $ btr -v -s git=https://github.com/bagder/curl.git -b gnu -r mail"
	echo "  See also curl.example.conf"
	echo
	exit
}

function parseopts {
	local shortoptions="hvqycCf:T:B:D:S:s:b:r:"
	local longoptions="help,verbose,quiet,yes,clean,vcsclean,config:,test:,branch:,directory:,suffix:,source:,build:,report:"
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
				QUIET=false
				VERBOSE=true
				;;
			-q|--quiet)
				QUIET=true
				VERBOSE=false
				;;
			-y|--yes)
				FORCEYES=true
				;;
			-c|--clean)
				BUILD_CLEAN=true
				;;
			-C|--vcsclean)
				SOURCE_CLEAN=true
				;;
			####
			-f|--config)
				source "$2"
				shift
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
			-T|--test)
				TEST_ARGS="$2"
				shift
				;;
			####
			-s|--source)
				case "$2" in
				git*)
					test -z "$BRANCH" && BRANCH=master
					;;
				svn*)
					test -z "$BRANCH" && BRANCH=trunk
					;;
				cvs*)
					test -z "$BRANCH" && BRANCH=HEAD
					;;
				esac
				SOURCE_RULES="$(cut -d= -f1 <<<$2)"
				SOURCE_ARGS="$(cut -s -d= -f2- <<<$2)"
				shift
				;;
			-b|--build)
				BUILD_RULES="$(cut -d= -f1 <<<$2)"
				BUILD_ARGS="$(cut -s -d= -f2- <<<$2)"
				shift
				;;
			-r|--report)
				REPORT_RULES="$(cut -d= -f1 <<<$2)"
				REPORT_ARGS="$(cut -s -d= -f2- <<<$2)"
				shift
				;;
			####
			--)
				# legacy
				if test "$2"
				then
					SOURCE_ARGS="$2"
				fi
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
	if test -z "$SOURCE_RULES" -o -z "$BUILD_RULES" -o -z "$REPORT_RULES"
	then
		help
	fi

	if $VERBOSE
	then
		QUIET_FLAG=
		SILENT_FLAG=
		VERBOSE_FLAG="-v"
		SAY="echo; echo"
	elif $QUIET
	then
		QUIET_FLAG="-q"
		SILENT_FLAG="-s"
		VERBOSE_FLAG=
		SAY="@true"
	else
		QUIET_FLAG=
		SILENT_FLAG="-s"
		VERBOSE_FLAG=
		SAY="@echo"
	fi
	
	export QUIET VERBOSE FORCEYES QUIET_FLAG SILENT_FLAG VERBOSE_FLAG SAY
	
	if test -z "$BTRDIR"
	then
		export BTRDIR="/tmp/btr"
	else
		export BTRDIR=$(realpath "$BTRDIR")
	fi
	
	mkdir -p "$BTRDIR" || error "Could not create $BTRDIR"

	
	export SOURCE_RULES BUILD_RULES REPORT_RULES
	test -z "$SOURCE_ARGS"  || export SOURCE_ARGS
	test -z "$SOURCE_CLEAN" || export SOURCE_CLEAN
	test -z "$BUILD_ARGS"   || export BUILD_ARGS
	test -z "$BUILD_CLEAN"  || export BUILD_CLEAN
	test -z "$TEST_ARGS"    || export TEST_ARGS
	test -z "$REPORT_ARGS"  || export REPORT_ARGS
	REPO=$(basename $(sed -re 's~^.*[/:#]~~' <<<"$SOURCE_ARGS") .git)
	SAFE_BRANCH=$(tr ":" "_" <<<$(basename "$BRANCH"))
	export REPO BRANCH SAFE_BRANCH

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
	export LAST_REPORT=$(basename $(ls -t "$BTRDIR/btr+tests-$BUILD"* 2>/dev/null | head -n1) 2>/dev/null)
	export REPORT="btr+report-$BUILD-$DATE"
}

function show_conf {
	echo
	echo "Configuration:"
	echo "=============="
	echo
	echo "BTRDIR         = $BTRDIR"
	echo "BINDIR         = $BINDIR"
	echo "LIBDIR         = $LIBDIR"
	echo
	echo "SOURCE_RULES   = $SOURCE_RULES"
	echo "SOURCE_ARGS    = $SOURCE_ARGS"
	echo "SOURCE_CLEAN   = $SOURCE_CLEAN"
	echo "BUILD_RULES    = $BUILD_RULES"
	echo "BUILD_ARGS     = $BUILD_ARGS"
	echo "BUILD_CLEAN    = $BUILD_CLEAN"
	echo "TEST_ARGS      = $TEST_ARGS"
	echo "REPORT_RULES   = $REPORT_RULES"
	echo "REPORT_ARGS    = $REPORT_ARGS"
	echo
	echo "REPO           = $REPO"
	echo "BRANCH         = $BRANCH"
	echo "SAFE_BRANCH    = $SAFE_BRANCH"
	echo
	echo "CLEAN_DIR      = $CLEAN_DIR"
	echo "BRANCH_DIR     = $BRANCH_DIR"
	echo "BUILD_DIR      = $BUILD_DIR"
	echo "CONFIG_REPORT  = $CONFIG_REPORT"
	echo "BUILD_REPORT   = $BUILD_REPORT"
	echo "TEST_REPORT    = $TEST_REPORT"
	echo "LAST_REPORT    = $LAST_REPORT"
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
