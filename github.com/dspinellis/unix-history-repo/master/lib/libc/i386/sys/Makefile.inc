#	from: Makefile.inc,v 1.1 1993/09/03 19:04:23 jtc Exp
#	$Id$

.PATH:	${.CURDIR}/${MACHINE}/sys

SRCS+=	i386_get_ldt.c i386_set_ldt.c

MAN2+=	i386/sys/i386_get_ldt.2

MLINKS+=i386_get_ldt.2 i386_set_ldt.2
