#	$Id: Makefile,v 1.1 1994/03/06 22:59:14 nate Exp $

CFLAGS+= -I${.CURDIR} -DHAVE_MMAP -DSTDHEADERS -fno-builtin
PFLAGS+= -DTRACE -DPROFILESIZES

LIB=	malloc

SRCS+=	_emalloc.c _malloc.c _memalign.c _strdup.c _strsave.c botch.c \
	dumpheap.c emalloc.c getmem.c leak.c malloc.c memalign.c setopts.c \
	sptree.c stats.c strdup.c strsave.c verify.c
NOMAN=	noman

beforeinstall:
	install -c -o ${BINOWN} -g ${BINGRP} -m 444 ${.CURDIR}/malloc.h \
		${DESTDIR}/usr/include

.include <bsd.lib.mk>
