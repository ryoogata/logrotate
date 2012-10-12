#
#	$Id$
#
#	SYNOPSIS:
#	#!/bin/sh
#	. /some/where/thisfile
#

#
#	rotateold() --- rotate old file named with numeric suffix ---
#
#	SYNOPSIS:
#		rotateold filename n
#			filename: filename without age suffix.
#			n: upper limit of the age.
#			   retain file file.0 file.1 ... file.n
#
#
rotateold()
{
	dir=`dirname $1`
	file=`basename $1`
	if [ "$2" != "" ]; then
		i=$2
	else
		i=7
	fi
	cd ${dir}
	while [ 0 -lt $i ]; do
		j=`expr $i - 1`
		if [ -e ${file}.$j ]; then
			mv ${file}.$j ${file}.$i
		fi
		i=$j
	done
}

#
#	rotate() --- rotate exist files and touch new one.
#
#	SYNOPSIS:
#		rotate filename n [owner [group] ]
#			filename: filename without age suffix.
#			n: upper limit of the age.
#			owner: optional paramater indicate owner of the file.
#			group: optional paramater indicate group of the file.
#
#	some daemon grabs the log file.
#	for such daemon, use grotate instead of this function.
#
rotate()
{
	rotateold $1 $2
	if [ -e $1 ]; then
		mv $1 $1.0
	fi
	touch $1
	case $# in
	3)	chown $3 $1
		;;
	4)	chown $3 $1
		chgrp $4 $1
		;;
	esac
}

#
#	grotate() --- rotate exist files and force make current file empty.
#
#	SYNOPSIS:
#		rotate filename n
#			filename: filename without age suffix.
#			n: upper limit of the age.
#
#	some daemon grabs the log file.
#	for such daemon, use this function instead of rotate().
#
grotate()
{
	rotateold $1 $2
	if [ -e $1 ]; then
		cp $1 $1.0
	fi
	cp /dev/null $1
}

#
#	relocate() --- keep old files forever and touch new one.
#
#	SYNOPSIS:
#		relocate filename n [owner [group] ]
#			filename: filename without age suffix.
#			n: upper limit of the age.
#
#	old file aged beyond n are located sub directory, not removed.
#
relocate()
{
	yyyy=`/bin/date '+%Y'`
	mm=`/bin/date '+%m'`
	dd=`/bin/date '+%d'`
	dir=`dirname $1`
	file=`basename $1`
	cd ${dir}
	if [ ! -d ${yyyy} ]; then
		mkdir ${yyyy}
	fi
	if [ ! -d ${yyyy}/${mm} ]; then
		mkdir ${yyyy}/${mm}
	fi
	if [ ! -d ${yyyy}/${mm}/${dd} ]; then
		mkdir ${yyyy}/${mm}/${dd}
	fi
	rotateold $1 $2
	mv $1 $1.0
	touch ${yyyy}/${mm}/${dd}/${file}
	case $# in
	3)	chown $3 $1
		;;
	4)	chown $3 $1
		chgrp $4 $1
		;;
	esac
	ln ${yyyy}/${mm}/${dd}/${file} ${file}
}
#
#	brelocate() --- keep zipped old files forever and touch new one.
#
#	SYNOPSIS:
#		relocate filename n [owner [group] ]
#			filename: filename without age suffix.
#			n: upper limit of the age.
#
#	old file aged beyond n are located sub directory, not removed.
#
brelocate()
{
	yyyy=`/bin/date '+%Y'`
	mm=`/bin/date '+%m'`
	dd=`/bin/date '+%d'`
	dir=`dirname $1`
	file=`basename $1`
	cd ${dir}
	byyyy=`date -v-1d '+%Y %m %d' | awk '{print $1}'`
	bmm=`date -v-1d '+%Y %m %d' | awk '{print $2}'`
	bdd=`date -v-1d '+%Y %m %d' | awk '{print $3}'`
	/usr/bin/bzip2 -f ${byyyy}/${bmm}/${bdd}/${file}
	if [ ! -d ${yyyy} ]; then
		mkdir ${yyyy}
	fi
	if [ ! -d ${yyyy}/${mm} ]; then
		mkdir ${yyyy}/${mm}
	fi
	if [ ! -d ${yyyy}/${mm}/${dd} ]; then
		mkdir ${yyyy}/${mm}/${dd}
	fi
	rotateold $1 $2
	mv $1 $1.0
	touch ${yyyy}/${mm}/${dd}/${file}
	case $# in
	3)	chown $3 $1
		;;
	4)	chown $3 $1
		chgrp $4 $1
		;;
	esac
	ln ${yyyy}/${mm}/${dd}/${file} ${file}
}
