#! /bin/sh -
#	from: @(#)makesyscalls.sh	7.6 (Berkeley) 4/20/91
#	$Id: makesyscalls.sh,v 1.3 1993/11/07 21:22:30 wollman Exp $

set -e

# name of compat option:
compat=COMPAT_43

# output files:
sysnames="syscalls.c"
syshdr="../sys/syscall.h"
syssw="init_sysent.c"

# tmp files:
sysdcl="sysent.dcl"
syscompat="sysent.compat"
sysent="sysent.switch"

trap "rm $sysdcl $syscompat $sysent" 0

case $# in
    0)	echo "Usage: $0 input-file" 1>&2
	exit 1
	;;
esac

awk < $1 "
	BEGIN {
		sysdcl = \"$sysdcl\"
		syscompat = \"$syscompat\"
		sysent = \"$sysent\"
		sysnames = \"$sysnames\"
		syshdr = \"$syshdr\"
		compat = \"$compat\"
		infile = \"$1\"
		"'

		printf "#ifndef _SYS_SYSCALL_H_\n" > syshdr
		printf "#define _SYS_SYSCALL_H_ 1\n" > syshdr
		printf "/*\n * System call switch table.\n *\n" > sysdcl
		printf " * DO NOT EDIT-- this file is automatically generated.\n" > sysdcl

		printf "\n#ifdef %s\n", compat > syscompat
		printf "#define compat(n, name) n, __CONCAT(o,name)\n\n" > syscompat

		printf "/*\n * System call names.\n *\n" > sysnames
		printf " * DO NOT EDIT-- this file is automatically generated.\n" > sysnames

		printf "/*\n * System call numbers.\n *\n" > syshdr
		printf " * DO NOT EDIT-- this file is automatically generated.\n" > syshdr
	}
	NR == 1 {
		printf " * created from%s\n */\n\n", $0 > sysdcl
		printf "#include \"param.h\"\n" > sysdcl
		printf "#include \"systm.h\"\n\n" > sysdcl
		printf "int\tnosys();\n\n" > sysdcl

		printf "struct sysent sysent[] = {\n" > sysent

		printf " * created from%s\n */\n\n", $0 > sysnames
		printf "char *syscallnames[] = {\n" > sysnames

		printf " * created from%s\n */\n\n", $0 > syshdr
		next
	}
	NF == 0 || $1 ~ /^;/ {
		next
	}
	$1 ~ /^#[ 	]*if/ {
		print > sysent
		print > sysdcl
		print > syscompat
		print > sysnames
		savesyscall = syscall
		next
	}
	$1 ~ /^#[ 	]*else/ {
		print > sysent
		print > sysdcl
		print > syscompat
		print > sysnames
		syscall = savesyscall
		next
	}
	$1 ~ /^#/ {
		print > sysent
		print > sysdcl
		print > syscompat
		print > sysnames
		next
	}
	syscall != $1 {
		printf "%s: line %d: syscall number out of sync at %d\n", \
		   infile, NR, syscall
		printf "line is:\n"
		print
		exit 1
	}
	{	comment = $4
		for (i = 5; i <= NF; i++)
			comment = comment " " $i
		if (NF < 5)
			$5 = $4
	}
	$2 == "STD" {
		printf("int\t%s();\n", $4) > sysdcl
		printf("\t%d, %s,\t\t\t/* %d = %s */\n", \
		    $3, $4, syscall, $5) > sysent
		printf("\t\"%s\",\t\t\t/* %d = %s */\n", \
		    $5, syscall, $5) > sysnames
		printf("#define\tSYS_%s\t%d\n", \
		    $5, syscall) > syshdr
		syscall++
		next
	}
	$2 == "COMPAT" {
		printf("int\to%s();\n", $4) > syscompat
		printf("\tcompat(%d,%s),\t\t/* %d = old %s */\n", \
		    $3, $4, syscall, $5) > sysent
		printf("\t\"old.%s\",\t\t/* %d = old %s */\n", \
		    $5, syscall, $5) > sysnames
		printf("\t\t\t\t/* %d is old %s */\n", \
		    syscall, comment) > syshdr
		syscall++
		next
	}
	$2 == "LIBCOMPAT" {
		printf("int\to%s();\n", $4) > syscompat
		printf("\tcompat(%d,%s),\t\t/* %d = old %s */\n", \
		    $3, $4, syscall, $5) > sysent
		printf("\t\"old.%s\",\t\t/* %d = old %s */\n", \
		    $5, syscall, $5) > sysnames
		printf("#define\tSYS_%s\t%d\t/* compatibility; still used by libc */\n", \
		    $5, syscall) > syshdr
		syscall++
		next
	}
	$2 == "OBSOL" {
		printf("\t0, nosys,\t\t\t/* %d = obsolete %s */\n", \
		    syscall, comment) > sysent
		printf("\t\"obs_%s\",\t\t\t/* %d = obsolete %s */\n", \
		    $4, syscall, comment) > sysnames
		printf("\t\t\t\t/* %d is obsolete %s */\n", \
		    syscall, comment) > syshdr
		syscall++
		next
	}
	$2 == "UNIMPL" {
		printf("\t0, nosys,\t\t\t/* %d = %s */\n", \
		    syscall, comment) > sysent
		printf("\t\"#%d\",\t\t\t/* %d = %s */\n", \
		    syscall, syscall, comment) > sysnames
		syscall++
		next
	}
	{
		printf "%s: line %d: unrecognized keyword %s\n", infile, NR, $2
		exit 1
	}
	END {
		printf("\n#else /* %s */\n", compat) > syscompat
		printf("#define compat(n, name) 0, nosys\n") > syscompat
		printf("#endif /* %s */\n\n", compat) > syscompat
		printf("#endif /* _SYS_SYSCALL_H_ */\n") > syshdr

		printf("};\n\n") > sysent
		printf("int\tnsysent = sizeof(sysent) / sizeof(sysent[0]);\n") > sysent

		printf("};\n") > sysnames
	} '

cat $sysdcl $syscompat $sysent >$syssw

if [ -d CVS ]; then
	true
else
	chmod 444 $sysnames $syshdr $syssw
fi
