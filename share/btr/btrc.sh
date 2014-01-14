#!/bin/bash

function btrc-help {
	btr-banner
	echo
	echo "Usage: $(basename $0) [-hyvq] [<options>] [action] <build>"
	echo
	echo "    -h, --help                Display this help"
	echo "    -y, --yes                 Always assume yes"
	echo "    -v, --verbose             Be more verbose"
	echo "    -q, --quiet               Be more quiet"
	echo
	echo "  Options:"
	echo "    -D, --directory=<directory>"
	echo "                              Use this directory as work root"
	echo
	echo "  Actions:"
	echo "    s[tatus]                  Show the status of the build"
	echo "    r[un]                     Make a BTR run"
	echo "    c[ancel]                  Cancel any currently running BTR job"
	echo "    t[erminate]               Terminate the BTR daemon"
	echo
	echo "  Arguments:"
	echo "    <build>                   The build id of the \`btrd\` daemon, usually"
	echo "                              something like \$repository@\$branch[-\$suffix]."
	echo
	exit
}
export -f btrc-help

function btrc-parseargs {
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

function btrc-parseopts {
	local shortoptions="hvqyD:"
	local longoptions="help,verbose,quiet,yes,directory:"
	local options=$(getopt \
		--options "$shortoptions" \
		--longoptions "$longoptions" \
		-- "$@" \
	)

	if test $? -ne 0 ; then
		btrc-help
	fi
	
	eval set -- "$options"
	
	while test $# -gt 1
	do
		case "$1" in
		-h|--help)
			btrc-help
			;;
		-y|--yes)
			BTR_FORCEYES=true
			;;
		-v|--verbose)
			BTR_VERBOSE=true
			BTR_QUIET=false
			;;
		-q|--quiet)
			BTR_QUIET=true
			BTR_VERBOSE=false
			;;
		#
		-D|--directory)
			BTR_RUNDIR="$2"
			shift
			;;
		#
		--)
			shift
			btrc-parseargs "$@"
		esac
		shift
	done
}
export -f btrc-parseopts

function btrc-setup {
	if test -z "$BTR_BUILD"
	then
		btrc-help
	fi
	
	if test -z "$BTR_ACTION"
	then
		BTR_ACTION=status
	fi
	
	btr-setup-rundir
	btr-setup-verbosity
	
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
		error "Could not find pid file of btr daemon for '$BTR_BUILD' in $BTR_RUNDIR."
	fi
}
export -f btrc-setup

function btrc-signal {
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
export -f btrc-signal


# vim: noet
