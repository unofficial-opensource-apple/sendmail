#!/bin/sh

# Copyright (c) 1998-2000 Sendmail, Inc. and its suppliers.
#	All rights reserved.
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the sendmail distribution.
#
#
#	$Id: configure.sh,v 1.1.1.1 2000/06/10 00:40:46 wsanchez Exp $

#
#  Special script to autoconfigure for M4 generation of Makefile
#

os=""
resolver=""
sflag=""
bin_dir=`echo $0 | sed -e 's/\/[^/]*$//'`
if [ ! -d $bin_dir ]
then
	bin_dir="."
fi
find_prog=$bin_dir/find_in_path.sh

while [ ! -z "$1" ]
do
	case $1
	in
	  -s)	# skip auto-configure
		sflag=1
		shift
		;;

	  *)	# OS definition
		os=$1
		shift
		;;
	esac
done

usewhoami=0
usehostname=0
for p in `echo $PATH | sed 's/:/ /g'`
do
	if [ "x$p" = "x" ]
	then
		p="."
	fi
	if [ -f $p/whoami ]
	then
		usewhoami=1
		if [ $usehostname -ne 0 ]
		then
			break;
		fi
	fi
	if [ -f $p/hostname ]
	then
		usehostname=1
		if [ $usewhoami -ne 0 ]
		then
			break;
		fi
	fi
done
if [ $usewhoami -ne 0 ]
then
	user=`whoami`
else
	user=$LOGNAME
fi

if [ $usehostname -ne 0 ]
then
	host=`hostname`
else
	host=`uname -n`
fi
echo "PUSHDIVERT(0)"
echo "####################################################################"
echo "##### This file is automatically generated -- edit at your own risk"
echo '#####' Built by $user@$host
echo '#####' on `date` using template OS/$os
if [ ! -z "$SITECONFIG" ]
then
	echo '#####' including $SITECONFIG
fi
echo '#####' in `pwd` | sed 's/\/tmp_mnt//'
echo "####################################################################"
echo ""
echo "POPDIVERT"
echo "define(\`__HOST__', \`$host')dnl"
echo "ifdef(\`confMAPDEF',, \`define(\`confMAPDEF', \`')')dnl"
echo "ifdef(\`confLIBS',, \`define(\`confLIBS', \`')')dnl"

LIBDIRS="$LIBDIRS $LIBPATH"
libs=""
mapdef=""
for l in $LIBSRCH
do
	for p in `echo $LIBDIRS | sed -e 's/:/ /g' -e 's/^-L//g' -e 's/ -L/ /g'`
	do
		if [ "x$p" = "x" ]
		then
			p = "."
		fi
		if [ -f $p/lib$l.a -o -f $p/lib$l.so ]
		then
			case $l
			in
			  db)
				mapdef="$mapdef -DNEWDB"
				;;
			  bind|resolv)
				if [ -n "$resolver" ]
				then
					continue
				else
					resolver=$l
				fi
				;;
			  44bsd)
				if [ "x$resolver" != "xresolv" ]
				then
					continue
				fi
				;;
			esac
			libs="$libs -l$l"
			break
		fi
	done
done

for p in `echo $PATH | sed 's/:/ /g'`
do
	pbase=`echo $p | sed -e 's,/bin,,'`
	if [ "x$p" = "x" ]
	then
		p="."
	fi
	if [ -f $p/mkdep ]
	then
		echo "ifdef(\`confDEPEND_TYPE',, \`define(\`confDEPEND_TYPE', \`BSD')')dnl"
	fi
done

if [ -z "$sflag" ]
then
	echo "define(\`confMAPDEF', \`$mapdef' confMAPDEF)dnl"
	echo "define(\`confLIBS', \`$libs' confLIBS)dnl"
fi

if [ ! -z "`sh $find_prog ranlib`" ]
then
	echo "define(\`confRANLIB', \`ranlib')dnl"
fi

roff_progs="groff nroff"
for roff_prog in $roff_progs
do
	if [ ! -z "`sh $find_prog $roff_prog`" ]
	then
		found_roff=$roff_prog
		break;
	fi
done

case $found_roff
in
	groff)
		echo "ifdef(\`confNROFF',,\`define(\`confNROFF', \`$found_roff -Tascii')')dnl"
		;;
	nroff)
		echo "ifdef(\`confNROFF',,\`define(\`confNROFF', \`$found_roff')')dnl"
		;;
	*)
		echo "ifdef(\`confNROFF',,\`define(\`confNO_MAN_BUILD')')dnl"
		;;
esac
