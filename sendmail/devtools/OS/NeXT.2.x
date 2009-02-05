#	$Id: NeXT.2.x,v 1.1.1.3 2002/10/15 02:37:37 zarzycki Exp $

dnl	DO NOT EDIT THIS FILE.
dnl	Place personal settings in devtools/Site/site.config.m4

define(`confSM_OS_HEADER', `sm_os_next')
define(`confBEFORE', `unistd.h dirent.h')
define(`confMAPDEF', `-DNDBM -DNIS -DNETINFO')
define(`confENVDEF', `-DNeXT')
define(`confLIBS', `-ldbm')
define(`confMBINDIR', `/usr/lib')
define(`confSBINDIR', `/usr/etc')
define(`confUBINDIR', `/usr/ucb')
define(`confEBINDIR', `/usr/lib')
define(`confINSTALL', `${BUILDBIN}/install.sh')
define(`confRANLIBOPTS', `-c')
PUSHDIVERT(3)
unistd.h:
	cp /dev/null unistd.h

dirent.h:
	echo "#include <sys/dir.h>" > dirent.h
	echo "#define dirent	direct" >> dirent.h
POPDIVERT
