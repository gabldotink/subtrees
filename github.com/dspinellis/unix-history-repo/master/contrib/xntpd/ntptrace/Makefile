#
# $Id: Makefile,v 1.1 1993/12/21 19:50:40 wollman Exp $
#

CFLAGS+= -I${.CURDIR}/../include

.if exists(${.CURDIR}/../lib/obj)
LDADD+= -L${.CURDIR}/../lib/obj
DPADD+= -L${.CURDIR}/../lib/obj/libntp.a
.else
LDADD+= -L${.CURDIR}/../lib
DPADD+= -L${.CURDIR}/../lib/libntp.a
.endif

LDADD+= -lntp

PROG= ntptrace
MAN8= ${.CURDIR}/../doc/ntptrace.8
CLEANFILES+= .version version.c

SRCS= ntptrace.c version.c

beforedepend: version.c

version.c: ${.CURDIR}/../VERSION
	${.CURDIR}/../scripts/mkversion ntptrace

.include <bsd.prog.mk>
