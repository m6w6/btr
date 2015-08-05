#!/bin/bash

function btrc_parseargs {
	eval set -- "$BTR_EXTRA_ARGS"
	while test $# -gt 0
	do
		case "$1" in
		s|st|stat|status)
			BTR_ACTION=status
			;;
		r|run)
			BTR_ACTION=run
			;;
		c|canc|cancel)
			BTR_ACTION=cancel
			;;
		t|term|terminate)
			BTR_ACTION=term
			;;
		*)
			if test -z "$BTR_BUILD"
			then
				BTR_BUILD="$1"
			else
				error "Unknown action: '$BTR_BUILD' for build id '$1'!"
			fi
			;;
		esac
		shift
	done
}

function btrc_setup {
	btrc_parseargs
	
	if test -z "$BTR_BUILD"
	then
		btr_banner
		btr_help
	fi
	
	if test -z "$BTR_ACTION"
	then
		BTR_ACTION=status
	fi
	
	btr_setup_rundir
	btr_setup_verbosity false
	
	BTR_PIDFILE="$BTR_RUNDIR/$BTR_BUILD.pid"
	BTR_LOGFILE="$BTR_RUNDIR/$BTR_BUILD.log"
	BTR_COMFILE="$BTR_RUNDIR/$BTR_BUILD.socket"
	
	if test -r "$BTR_PIDFILE"
	then
		export BTR_PIDFILE BTR_LOGFILE BTR_COMFILE
	else
		if test -e "$BTR_LOGFILE"
		then
			cat "$BTR_LOGFILE"
			echo
		fi
		error "Could not find btrd pid file of '$BTR_BUILD' in $BTR_RUNDIR."
	fi
}
export -f btrc_setup

function btrc_signal {
	local sig=$1
	local pid=$(cat "$BTR_PIDFILE")
	kill -s $sig $pid
	kill -s CONT $pid
	case "$sig" in
	TERM|SIGTERM|15)
		$SAY -n "Waiting for the daemon to shutdown..."
		while kill -s 0 $pid &>/dev/null
		do
			$SAY -n "."
			sleep .1
		done
		$SAY " Done, bye."
		;;
	esac
}
export -f btrc_signal


# vim: noet
