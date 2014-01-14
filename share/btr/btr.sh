#!/bin/sh

function btr-help {
	btr-banner
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
			"$(find "$BTR_LIBDIR/$ruleset" -name '*.mk' -exec basename {} .mk \; | sort | xargs)"
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
export -f btr-help

function btr-parseopts {
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
				btr-help
				;;
			-v|--verbose)
				BTR_QUIET=false
				BTR_VERBOSE=true
				;;
			-q|--quiet)
				BTR_QUIET=true
				BTR_VERBOSE=false
				;;
			-y|--yes)
				BTR_FORCEYES=true
				;;
			-c|--clean)
				BTR_BUILD_CLEAN=true
				;;
			-C|--vcsclean)
				BTR_SOURCE_CLEAN=true
				;;
			####
			-f|--config)
				source "$2"
				shift
				;;
			####
			-B|--branch)
				BTR_BRANCH="$2"
				shift
				;;
			-D|--directory)
				BTR_RUNDIR="$2"
				shift
				;;
			-S|--suffix)
				BTR_SUFFIX="$2"
				shift
				;;
			-T|--test)
				BTR_TEST_ARGS="$2"
				shift
				;;
			####
			-s|--source)
				case "$2" in
				git*)
					test -z "$BTR_BRANCH" && BTR_BRANCH=master
					;;
				svn*)
					test -z "$BTR_BRANCH" && BTR_BRANCH=trunk
					;;
				cvs*)
					test -z "$BTR_BRANCH" && BTR_BRANCH=HEAD
					;;
				esac
				BTR_SOURCE_RULES="$(cut -d= -f1 <<<$2)"
				BTR_SOURCE_ARGS="$(cut -s -d= -f2- <<<$2)"
				shift
				;;
			-b|--build)
				BTR_BUILD_RULES="$(cut -d= -f1 <<<$2)"
				BTR_BUILD_ARGS="$(cut -s -d= -f2- <<<$2)"
				shift
				;;
			-r|--report)
				BTR_REPORT_RULES="$(cut -d= -f1 <<<$2)"
				BTR_REPORT_ARGS="$(cut -s -d= -f2- <<<$2)"
				shift
				;;
			####
			--)
				# legacy
				if test "$2"
				then
					BTR_SOURCE_ARGS="$2"
				fi
				shift
				;;
		esac
		shift
	done
}
export -f btr-parseopts

function btr-setup {
	if test -z "$BTR_SOURCE_RULES" -o -z "$BTR_BUILD_RULES" -o -z "$BTR_REPORT_RULES"
	then
		btr-help
	fi

	btr-setup-verbosity true
	btr-setup-rundir

	export BTR_SOURCE_RULES BTR_BUILD_RULES BTR_REPORT_RULES
	test -z "$BTR_SOURCE_ARGS"  || export BTR_SOURCE_ARGS
	test -z "$BTR_SOURCE_CLEAN" || export BTR_SOURCE_CLEAN
	test -z "$BTR_BUILD_ARGS"   || export BTR_BUILD_ARGS
	test -z "$BTR_BUILD_CLEAN"  || export BTR_BUILD_CLEAN
	test -z "$BTR_TEST_ARGS"    || export BTR_TEST_ARGS
	test -z "$BTR_REPORT_ARGS"  || export BTR_REPORT_ARGS
	BTR_REPO=$(basename $(sed -re 's~^.*[/:#]~~' <<<"$BTR_SOURCE_ARGS") .git)
	BTR_SAFE_BRANCH=$(tr ":/" "_" <<<$(basename "$BTR_BRANCH"))
	export BTR_REPO BTR_BRANCH BTR_SAFE_BRANCH

	if test -z "$BTR_SUFFIX"
	then
		export BTR_BUILD="$BTR_REPO@$BTR_SAFE_BRANCH"
	else
		export BTR_BUILD="$BTR_REPO@$BTR_SAFE_BRANCH-$BTR_SUFFIX"
	fi

	export BTR_REPO_DIR="$BTR_REPO"
	export BTR_BRANCH_DIR="$BTR_BUILD/checkout"
	export BTR_BUILD_DIR="$BTR_BUILD/build"
	export BTR_LOG_DIR="$BTR_BUILD/log"
	export BTR_CONFIG_REPORT="$BTR_LOG_DIR/config@$DATE.log"
	export BTR_BUILD_REPORT="$BTR_LOG_DIR/build@$DATE.log"
	export BTR_TEST_REPORT="$BTR_LOG_DIR/test@$DATE.log"
	export BTR_LAST_REPORT=$(basename $(ls -t "$BTR_RUNDIR/$BTR_LOG_DIR/test@"* 2>/dev/null | head -n1) 2>/dev/null)
	export BTR_REPORT="$BTR_LOG_DIR/report@$DATE.log"
}
export -f btr-setup

function btr-conf-dump {
	echo "BTR_QUIET='$BTR_QUIET'"
	echo "BTR_VERBOSE='$BTR_VEROSE'"
	echo "BTR_FORCEYES='$BTR_FORCEYES'"
	echo "BTR_BRANCH='$BTR_BRANCH'"
	echo "BTR_SUFFIX='$BTR_SUFFIX'"
	echo "BTR_RUNDIR='$BTR_RUNDIR'"
	echo "BTR_SOURCE_RULES='$BTR_SOURCE_RULES'"
	test ${BTR_SOURCE_ARGS+defined} && echo "BTR_SOURCE_ARGS='$BTR_SOURCE_ARGS'"
	test ${BTR_SOURC_CLEAN+defined} && echo "BTR_SOURCE_CLEAN='$BTR_SOURCE_CLEAN'"
	echo "BTR_BUILD_RULES='$BTR_BUILD_RULES'"
	test ${BTR_BUILD_ARGS+defined}  && echo "BTR_BUILD_ARGS='$BTR_BUILD_ARGS'"
	test ${BTR_BUILD_CLEAN+defined} && echo "BTR_BUILD_CLEAN='$BTR_BUILD_CLEAN'"
	test ${BTR_TEST_ARGS+defined}   && echo "BTR_TEST_ARGS='$BTR_TEST_ARGS'"
	echo "BTR_REPORT_RULES='$BTR_REPORT_RULES'"
	test ${BTR_REPORT_ARGS+defined} && echo "BTR_REPORT_ARGS='$BTR_REPORT_ARGS'"
}
export -f btr-conf-dump

function btr-conf-show {
	echo
	echo "# Configuration:"
	echo
	echo "BTR_RUNDIR         = $BTR_RUNDIR"
	echo "BTR_BINDIR         = $BTR_BINDIR"
	echo "BTR_LIBDIR         = $BTR_LIBDIR"
	echo
	echo "BTR_SOURCE_RULES   = $BTR_SOURCE_RULES"
	echo "BTR_SOURCE_ARGS    = $BTR_SOURCE_ARGS"
	echo "BTR_SOURCE_CLEAN   = $BTR_SOURCE_CLEAN"
	echo "BTR_BUILD_RULES    = $BTR_BUILD_RULES"
	echo "BTR_BUILD_ARGS     = $BTR_BUILD_ARGS"
	echo "BTR_BUILD_CLEAN    = $BTR_BUILD_CLEAN"
	echo "BTR_TEST_ARGS      = $BTR_TEST_ARGS"
	echo "BTR_REPORT_RULES   = $BTR_REPORT_RULES"
	echo "BTR_REPORT_ARGS    = $BTR_REPORT_ARGS"
	echo "BTR_REPO           = $BTR_REPO"
	echo "BTR_BRANCH         = $BTR_BRANCH"
	echo "BTR_SAFE_BRANCH    = $BTR_SAFE_BRANCH"
	echo "BTR_BUILD          = $BTR_BUILD"
	echo
	echo "BTR_REPO_DIR       = $BTR_REPO_DIR"
	echo "BTR_BRANCH_DIR     = $BTR_BRANCH_DIR"
	echo "BTR_BUILD_DIR      = $BTR_BUILD_DIR"
	echo "BTR_LOG_DIR        = $BTR_LOG_DIR"
	echo "BTR_CONFIG_REPORT  = $BTR_CONFIG_REPORT"
	echo "BTR_BUILD_REPORT   = $BTR_BUILD_REPORT"
	echo "BTR_TEST_REPORT    = $BTR_TEST_REPORT"
	echo "BTR_LAST_REPORT    = $BTR_LAST_REPORT"
	echo
}
export -f btr-conf-show

function btr-run {
	set -e
	make -e $BTR_SILENT_FLAG -C $BTR_RUNDIR -f $BTR_LIBDIR/source/$BTR_SOURCE_RULES.mk
	make -e $BTR_SILENT_FLAG -C $BTR_RUNDIR -f $BTR_LIBDIR/build/$BTR_BUILD_RULES.mk
	make -e $BTR_SILENT_FLAG -C $BTR_RUNDIR -f $BTR_LIBDIR/report/$BTR_REPORT_RULES.mk
	set +e
}
export -f btr-run

# vim: noet
