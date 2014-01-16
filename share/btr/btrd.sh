#!/bin/bash

function btrd-start {
	btrd-cancel
	BTR_DATE=$(date +%Y%m%d%H%M%S)
	btr-setup
	btr-run &
	BTR_WORKER=$!
}
export -f btrd-start

function btrd-cancel {
	if btrd-worker-started
	then
		kill $BTR_WORKER
		wait $BTR_WORKER
	fi
	BTR_WORKER=0
}
export -f btrd-cancel

function btrd-stop {
	BTR_DAEMON=false
}
export -f btrd-stop

function btrd-ctime {
	stat -c %y "$1"
}
export -f btrd-ctime

function btrd-fsize {
	local bytes=$(stat -c %s "$1")
}
export -f btrd-fsize

function btrd-status {
	echo "BTR_BUILD='$BTR_BUILD'"
	echo "BTR_SERVER='$BTR_SERVER'"
	echo "BTR_PIDFILE='$BTR_PIDFILE'"
	echo "BTR_LOGFILE='$BTR_LOGFILE'"
	echo "BTR_COMFILE='$BTR_COMFILE'"
}
export -f btrd-status

function btrd-logrotate {
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
export -f btrd-logrotate

function btrd-worker-started {
	test "$BTR_WORKER" -gt 1
}
export -f btrd-worker-started

function btrd-worker-running {
	kill -s 0 $BTR_WORKER
}
export -f btrd-worker-running

function btrd-worker-reap {
	wait $BTR_WORKER
	BTR_WORKER=0
}
export -f btrd-worker-reap

function btrd-worker-kill {
	kill $BTR_WORKER
}
export -f btrd-worker-kill
 
BTR_DAEMON=true
BTR_WORKER=0
BTR_SERVER=0
BTR_PIDFILE="$BTR_RUNDIR/$BTR_BUILD.pid"
BTR_LOGFILE="$BTR_RUNDIR/$BTR_BUILD.log"
BTR_COMFILE="$BTR_RUNDIR/$BTR_BUILD.socket"

export BTR_DAEMON BTR_WORKER BTR_SERVER BTR_PIDFILE BTR_LOGFILE BTR_COMFILE

btrd-logrotate

exec >"$BTR_LOGFILE" 2>&1
echo $$ >"$BTR_PIDFILE"

ncat -lkU -c btrd-status "$BTR_COMFILE" &
BTR_SERVER=$!

trap btrd-start HUP
trap btrd-cancel INT
trap btrd-stop TERM

while $BTR_DAEMON
do
	if btrd-worker-started && btrd-worker-running
	then
		btrd-worker-reap
	else
		kill -s STOP $$
	fi
done

btrd-cancel

if test "$BTR_SERVER" -gt 1
then
	kill $BTR_SERVER
	wait $BTR_SERVER
fi

test -e "$BTR_PIDFILE" && rm "$BTR_PIDFILE"
test -e "$BTR_LOGFILE" && rm "$BTR_LOGFILE"
test -S "$BTR_COMFILE" && rm "$BTR_COMFILE"

# vim: noet
