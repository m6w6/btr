AC_INIT([btr], [0.5.0], [mike@php.net])
AM_INIT_AUTOMAKE([foreign])
AM_SILENT_RULES
AC_CONFIG_SRCDIR([./share/btr/btr.sh])

AC_PATH_PROG([GETOPT], [getopt], [getopt])
AC_ARG_VAR([GETOPT], [location of gnu-getopt, see --with-gnu-getopt; e.g. /usr/local/opt/gnu-getopt/bin/getopt])
AC_ARG_WITH([gnu-getopt], [AS_HELP_STRING([--with-gnu-getopt=path], [
	Location of the enhanced GNU getopt program])], [
], [
	with_gnu_getopt=$GETOPT
])

AC_MSG_CHECKING([for GNU getopt])
$with_gnu_getopt --test >/dev/null
AS_IF([test $? -ne 4], [
	AC_MSG_RESULT([no])
	AC_MSG_ERROR([$with_gnu_getopt looks like the BSD version, please provide the path to the GNU version --with-gnu-getopt])
], [
	AC_MSG_RESULT([yes, $with_gnu_getopt])
	AC_SUBST([GETOPT], [$with_gnu_getopt])
])

AC_PROG_AWK
AC_PATH_PROG([AWK_PATH], [$AWK], [/bin/$AWK])

AC_CHECK_PROGS([SETSID], [setsid], [nothing])
AC_ARG_VAR([SETSID], [location of a setsid program; a simple replacement will be built if none found or provided])
AS_IF([test "$SETSID" = nothing], [
	SETSID="\$BTR_BINDIR/btr-setsid"
	AC_PROG_CC
	AC_CONFIG_FILES([bin/Makefile])
], [:]);

AC_CHECK_PROGS([NPROC], [nproc sysctl], [nothing])
AC_MSG_CHECKING([for number of cores])
AS_CASE([$NPROC],
	[nproc], [
		BTR_CPUS=$(nproc)
	],
	[sysctl], [
		BTR_CPUS=$(sysctl -n hw.ncpu 2>/dev/null || echo 1)
	],
	[
		BTR_CPUS=1
	]
)
AC_MSG_RESULT([$BTR_CPUS])
AC_SUBST([BTR_CPUS], [$BTR_CPUS])

AC_MSG_CHECKING([for bin/ scripts]);
	BTR_BIN=$(find $srcdir/bin -type f -perm -a=x | sed 's/\.in$//' | xargs)
AC_MSG_RESULT([$BTR_BIN])
AC_SUBST([BTR_BIN], [$BTR_BIN])

AC_MSG_CHECKING([for share/ scripts])
	BTR_SCRIPTS=$(find $srcdir/share/btr -type f -perm -a=x | sed 's/\.in$//' | xargs)
AC_MSG_RESULT([$BTR_SCRIPTS])
AC_SUBST([BTR_SCRIPTS], [$BTR_SCRIPTS])

AC_MSG_CHECKING([for share/ data])
	BTR_SHARE=$(find $srcdir/share/btr -type f ! -perm -a=x | sed 's/\.in$//' | xargs)
AC_MSG_RESULT([$BTR_SHARE])
AC_SUBST([BTR_SHARE], [$BTR_SHARE])

AC_CONFIG_FILES([bin/btrd], [chmod +x bin/btrd])
AC_CONFIG_FILES([share/btr/opt.awk], [chmod +x share/btr/opt.awk])
AC_CONFIG_FILES([share/btr/common.sh], [chmod +x share/btr/common.sh])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT

dnl vim: noet
