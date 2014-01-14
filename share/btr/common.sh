#!/bin/bash

export DATE=$(date +%Y%m%d%H%M%S)
export CPUS=${CPUS:-$(nproc)}

BTR_QUIET=false
BTR_VERBOSE=false
BTR_FORCEYES=false

function error {
	echo "$@" >&2
	exit 1
}
export -f error

function btr-banner {
	echo "$(basename ${0:btr}) v0.4.0, (c) Michael Wallner <mike@php.net>"
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
	
	if $BTR_VERBOSE
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

# vim: noet
