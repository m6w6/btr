AC_INIT([btr], [0.4.0], [mike@php.net])
AM_INIT_AUTOMAKE([foreign])
AM_SILENT_RULES([yes])
AC_CONFIG_SRCDIR([./share/btr/btr.sh])

AC_MSG_CHECKING([for bin/ scripts]);
	BTR_BIN=$(find $srcdir/bin -type f -perm -a=x | xargs)
AC_MSG_RESULT([$BTR_BIN])
AC_SUBST([BTR_BIN], [$BTR_BIN])

AC_MSG_CHECKING([for share/ scripts])
	BTR_SCRIPTS=$(find $srcdir/share/btr -type f -perm -a=x | xargs)
AC_MSG_RESULT([$BTR_SCRIPTS])
AC_SUBST([BTR_SCRIPTS], [$BTR_SCRIPTS])

AC_MSG_CHECKING([for share/ data])
	BTR_SHARE=$(find $srcdir/share/btr -type f ! -perm -a=x | xargs)
AC_MSG_RESULT([$BTR_SHARE])
AC_SUBST([BTR_SHARE], [$BTR_SHARE])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
