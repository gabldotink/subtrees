#
# $Id: Makefile,v 1.4 1993/12/22 11:32:23 rgrimes Exp $
#

CFLAGS+= -I${.CURDIR}/../include

SRCS=	atoint.c atolfp.c atouint.c auth12crypt.c authdecrypt.c authdes.c \
	authencrypt.c authkeys.c authparity.c authreadkeys.c authusekey.c \
	buftvtots.c caljulian.c calleapwhen.c caltontp.c calyearstart.c \
	clocktime.c dofptoa.c dolfptoa.c emalloc.c fptoa.c fptoms.c \
	gettstamp.c hextoint.c hextolfp.c humandate.c inttoa.c \
	lib_strbuf.c mfptoa.c mfptoms.c modetoa.c mstolfp.c \
	msutotsf.c netof.c numtoa.c refnumtoa.c numtohost.c octtoint.c \
	prettydate.c ranny.c tsftomsu.c tstotv.c tvtoa.c tvtots.c \
	uglydate.c uinttoa.c utvtoa.c clocktypes.c \
	md5.c a_md5encrypt.c a_md5decrypt.c \
	a_md512crypt.c decodenetnum.c systime.c msyslog.c syssignal.c \
	findconfig.c getopt.c

NOMAN=
NOPROFILE=
LIB= ntp
CLEANFILES+=authdes.c

install:

authdes.c: authdes.c.export
	cp ${.CURDIR}/authdes.c.export authdes.c

.include <bsd.lib.mk>
