#!/bin/bash

export BTR_DATE=$(date +%Y%m%d%H%M%S)
export BTR_CPUS=${CPUS:-$(nproc)}
export BTR_PROG=$(basename "$0")
export BTR_QUIET=false
export BTR_VERBOSE=false
export BTR_FORCEYES=false

function error {
	echo "$@" >&2
	exit 1
}
export -f error

function btr-banner {
	echo "$BTR_PROG v0.4.0, (c) Michael Wallner <mike@php.net>"
	if test "$BTR_BANNER"
	then
		echo "$BTR_BANNER"
	fi
}
export -f btr-banner

function btr-confirm {
	local CONTINUE
	if ! $BTR_FORCEYES
	then
		echo
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
	fi
}
export -f btr-confirm

function btr-setup-rundir {
	local default_rundir="${1:-/tmp/btr}"
	
	if test -z "$BTR_RUNDIR"
	then
		export BTR_RUNDIR="$default_rundir"
	else
		export BTR_RUNDIR=$(realpath "$BTR_RUNDIR")
	fi
	
	mkdir -p "$BTR_RUNDIR" || error "Could not create directory '$BTR_RUNDIR'"
}
export -f btr-setup-rundir

function btr-setup-verbosity {
	local for_make=${1:-false}
	
	if ${BTR_VERBOSE:-false}
	then
		BTR_QUIET_FLAG=
		BTR_SILENT_FLAG=
		BTR_VERBOSE_FLAG="-v"
		SAY="echo; echo"
	elif $BTR_QUIET
	then
		BTR_QUIET_FLAG="-q"
		BTR_SILENT_FLAG="-s"
		BTR_VERBOSE_FLAG=
		SAY="true"
	else
		BTR_QUIET_FLAG=
		BTR_SILENT_FLAG="-s"
		BTR_VERBOSE_FLAG=
		SAY="echo"
	fi
	
	if $for_make
	then
		SAY="@$SAY"
	fi
	
	export BTR_QUIET BTR_VERBOSE BTR_FORCEYES BTR_QUIET_FLAG BTR_SILENT_FLAG BTR_VERBOSE_FLAG SAY
}
export -f btr-setup-verbosity

function btr-shortoptions {
	(
		local f
		local e
		
		for f in common $BTR_PROG
		do
			for e in flags opts
			do
				test -e "$BTR_LIBDIR/$f.$e" && cut -sf1 <"$BTR_LIBDIR/$f.$e"
			done
		done
	) | xargs | tr -d " "
}
export -f btr-shortoptions

function btr-longoptions {
	(
		local f
		local e
		
		for f in common $BTR_PROG
		do
			for e in flags opts
			do
				test -e "$BTR_LIBDIR/$f.$e" && cut -sf2 <"$BTR_LIBDIR/$f.$e"
			done
		done
	)  | sed -r -e 's/(:+).*/\1/' | xargs | tr " " ","
}
export -f btr-longoptions

function btr-flags {
	(
		local f
		local e
		
		for f in common $BTR_PROG
		do
			test -e "$BTR_LIBDIR/$f.flags" && cut -sf1 <"$BTR_LIBDIR/$f.flags"
		done
	) | xargs | tr -d " "
}
export -f btr-flags

function btr-help-options {
	local f o=$(
		for f in common $BTR_PROG
		do
			test -e "$BTR_LIBDIR/$f.$1" && "$BTR_LIBDIR/opt.awk" <"$BTR_LIBDIR/$f.$1"
		done
	)
	if test "$o"
	then
		echo
		case "$1" in
		flags)
			echo "  Flags:"
			;;
		opts)
			echo "  Options:"
			;;
		esac
		echo "$o"
	fi
}
export -f btr-help-options

function btr-help-args {
	local a d l
	
	if test -e "$BTR_LIBDIR/$BTR_PROG.args"
	then
		echo
		echo "  Arguments:"
		while read a d
		do
			printf "%b\n" "$d" | fold -sw46 | while read l
			do
				printf "    %-16s %s\n" "$a" "$l"
				a=
			done
			echo
		done <"$BTR_LIBDIR/$BTR_PROG.args"
	fi
}
export -f btr-help-args

function btr-args {
	if test -e "$BTR_LIBDIR/$BTR_PROG.args"
	then
		cut -sf1 <"$BTR_LIBDIR/$BTR_PROG.args" | xargs
	fi
}
export -f btr-args

function btr-help {
	echo
	echo "Usage: $BTR_PROG [-$(btr-flags)] [<options>]" $(btr-args)
	btr-help-options flags
	btr-help-options opts
	btr-help-args
	if test $BTR_PROG != "btrc"
	then
	echo
	echo "  Rules format:"
	echo "    type=arg  e.g: notify-send=\"-u low\""
	echo "                   mail=\"-c copy@to rcpt@to\""
	echo "                   irc=\"tcp://btr@chat.freenode.org/#btr\""
	echo "                   git=\$HOME/src/btr.git"
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
	fi
	exit
}
export -f btr-help

function btr-parseopts {
	local shortoptions="$(btr-shortoptions common btr-flags btr-options)"
	local longoptions="$(btr-longoptions common btr-flags btr-options)"
	local options
	
	options=$(getopt \
		--name $BTR_PROG \
		--options "$shortoptions" \
		--longoptions "$longoptions" \
		-- "$@" \
	)
	if test $? -ne 0
	then
		btr-help
	fi
	
	eval set -- "$options"
	
	while test $# -gt 0
	do
		case "$1" in
			-h|--help)
				btr-banner
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
				shift
				BTR_EXTRA_ARGS="$@"
				break
				;;
		esac
		shift
	done
}
export -f btr-parseopts

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

# vim: noet
