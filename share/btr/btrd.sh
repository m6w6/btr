#!/bin/bash

function btrd_start {
	btrd_cancel
	BTR_DATE=$(date +%Y%m%d%H%M%S)
	btr_setup
	btr_run &
	BTR_WORKER=$!
}
export -f btrd_start

function btrd_cancel {
	if btrd_worker_started
	then
		btrd_worker_kill
		btrd_worker_reap
	fi
}
export -f btrd_cancel

function btrd_stop {
	BTR_DAEMON=false
}
export -f btrd_stop

function btrd_ctime {
	stat -c %y "$1"
}
export -f btrd_ctime

function btrd_fsize {
	local bytes=$(stat -c %s "$1")
}
export -f btrd_fsize

function btrd_status {
	echo "BTR_BUILD='$BTR_BUILD'"
	echo "BTR_SERVER='$BTR_SERVER'"
	echo "BTR_PIDFILE='$BTR_PIDFILE'"
	echo "BTR_LOGFILE='$BTR_LOGFILE'"
	echo "BTR_COMFILE='$BTR_COMFILE'"
}
export -f btrd_status

function btrd_logrotate {
	local i=1
	local f="$BTR_LOGFILE"
	
	if test -e "$f"
	then
		while test -e "$f.$i"
		do 
			i=$((i+1))
		done
		mv "$f" "$f.$i"
	fi
	
}
export -f btrd_logrotate

function btrd_worker_started {
	test "$BTR_WORKER" -gt 1
}
export -f btrd_worker_started

function btrd_worker_running {
	kill -s 0 $BTR_WORKER
}
export -f btrd_worker_running

function btrd_worker_reap {
	wait $BTR_WORKER
	BTR_WORKER=0
}
export -f btrd_worker_reap

function btrd_worker_kill {
	kill $BTR_WORKER
}
export -f btrd_worker_kill
 
BTR_DAEMON=true
BTR_WORKER=0
BTR_SERVER=0
BTR_PIDFILE="$BTR_RUNDIR/$BTR_BUILD.pid"
BTR_LOGFILE="$BTR_RUNDIR/$BTR_BUILD.log"
BTR_COMFILE="$BTR_RUNDIR/$BTR_BUILD.socket"

export BTR_DAEMON BTR_WORKER BTR_SERVER BTR_PIDFILE BTR_LOGFILE BTR_COMFILE

btrd_logrotate

exec >"$BTR_LOGFILE" 2>&1
echo $$ >"$BTR_PIDFILE"

# see https://github.com/nmap/nmap/issues/193
if test $(uname -s) = Darwin; then
	echo $(($(cksum <<<"$BTR_BUILD" | cut -d" " -f 1) % 64511 + 1024)) > "$BTR_COMFILE"
	ncat -nlkc btrd_status 127.0.0.1 $(cat "$BTR_COMFILE") &
else
	ncat -nlkc btrd_status -U "$BTR_COMFILE" &
fi
BTR_SERVER=$!

trap btrd_start HUP
trap btrd_cancel INT
trap btrd_stop TERM

while $BTR_DAEMON
do
	if btrd_worker_started && btrd_worker_running
	then
		btrd_worker_reap
	else
		kill -s STOP $$
	fi
done

btrd_cancel

if test "$BTR_SERVER" -gt 1
then
	kill $BTR_SERVER
	wait $BTR_SERVER
fi

test -e "$BTR_PIDFILE" && rm "$BTR_PIDFILE"
test -e "$BTR_LOGFILE" && rm "$BTR_LOGFILE"
test -S "$BTR_COMFILE" && rm "$BTR_COMFILE"

# vim: noet
