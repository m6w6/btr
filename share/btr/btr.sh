#!/bin/sh

function btr_setup {
	if test -z "$BTR_SOURCE_RULES" -o -z "$BTR_BUILD_RULES" -o -z "$BTR_REPORT_RULES"
	then
		btr_banner
		btr_help
	fi

	btr_setup_verbosity ${1:-true}
	btr_setup_rundir

	export BTR_SOURCE_RULES BTR_BUILD_RULES BTR_REPORT_RULES
	test -z "$BTR_SOURCE_ARGS"  || export BTR_SOURCE_ARGS
	test -z "$BTR_SOURCE_CLEAN" || export BTR_SOURCE_CLEAN
	test -z "$BTR_BUILD_ARGS"   || export BTR_BUILD_ARGS
	test -z "$BTR_BUILD_CLEAN"  || export BTR_BUILD_CLEAN
	test -z "$BTR_TEST_ARGS"    || export BTR_TEST_ARGS
	test -z "$BTR_REPORT_ARGS"  || export BTR_REPORT_ARGS
	BTR_REPO=$(basename $(sed 's~^.*[/:#]~~' <<<"$BTR_SOURCE_ARGS") .git)
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
	export BTR_CONFIG_REPORT="$BTR_LOG_DIR/config@$BTR_DATE.log"
	export BTR_BUILD_REPORT="$BTR_LOG_DIR/build@$BTR_DATE.log"
	export BTR_TEST_REPORT="$BTR_LOG_DIR/test@$BTR_DATE.log"
	export BTR_LAST_REPORT=$(basename $(ls -t "$BTR_RUNDIR/$BTR_LOG_DIR/test@"* 2>/dev/null | head -n1) 2>/dev/null)
	export BTR_REPORT="$BTR_LOG_DIR/report@$BTR_DATE.log"
}
export -f btr_setup

function btr_conf_show {
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
export -f btr_conf_show

function btr_run {
	set -e
	make -e $BTR_SILENT_FLAG -C $BTR_RUNDIR -f $(pwd)/$BTR_LIBDIR/source/$BTR_SOURCE_RULES.mk
	make -e $BTR_SILENT_FLAG -C $BTR_RUNDIR -f $(pwd)/$BTR_LIBDIR/build/$BTR_BUILD_RULES.mk
	make -e $BTR_SILENT_FLAG -C $BTR_RUNDIR -f $(pwd)/$BTR_LIBDIR/report/$BTR_REPORT_RULES.mk
	set +e
}
export -f btr_run

# vim: noet
