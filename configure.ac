AC_INIT([btr], [0.4.0], [mike@php.net])
AC_CONFIG_SRCDIR([./share/btr/btr.sh])
AM_INIT_AUTOMAKE([foreign])
AM_SILENT_RULES([yes])
BTR_BIN='$(echo $$abs_srcdir/bin/*)'
BTR_SHARE='$(echo $$abs_srcdir/share/{*,*/*}/*.*)'
AC_SUBST([BTR_BIN], [$BTR_BIN])
AC_SUBST([BTR_SHARE], [$BTR_SHARE])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
