#	from: @(#)Makefile	5.3 (Berkeley) 6/22/90
#	$Id: Makefile,v 1.3 1994/01/31 06:10:27 rgrimes Exp $

FILES=	bsd.README bsd.dep.mk bsd.doc.mk bsd.lib.mk bsd.man.mk bsd.own.mk \
	bsd.prog.mk bsd.subdir.mk sys.mk bsd.subdir_ports.mk
NOOBJ=	noobj

all clean cleandir depend lint tags:

install:
	install -c -o ${BINOWN} -g ${BINOWN} -m 444 ${FILES} \
	    ${DESTDIR}${BINDIR}/mk

.include <bsd.prog.mk>
