#	$Id: Makefile,v 1.1 1993/09/16 00:36:39 jtc Exp $

PROG =	rpc.rwalld
SRCS =	rwalld.c
MAN8 =	rpc.rwalld.8

DPADD=	${LIBRPCSVC} ${LIBUTIL}
LDADD=	-lrpcsvc -lutil

.include <bsd.prog.mk>
