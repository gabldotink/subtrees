/*
 * Copyright (c) 1989 Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *	from: @(#)cltp_var.h	7.3 (Berkeley) 6/28/90
 *	$Id: cltp_var.h,v 1.2 1993/10/16 21:05:00 rgrimes Exp $
 */

#ifndef _NETISO_CLTP_VAR_H_
#define _NETISO_CLTP_VAR_H_ 1

#define UD_TPDU_type	0x40	/* packet type */

#define CLTPOVAL_SRC	0xc1	/* Source TSAP -- required */
#define CLTPOVAL_DST	0xc2	/* Destination TSAP -- required */
#define CLTPOVAL_CSM	0xc3	/* Checksum parameter -- optional */

struct	cltpstat {
	int	cltps_hdrops;
	int	cltps_badsum;
	int	cltps_badlen;
	int	cltps_noport;
	int	cltps_ipackets;
	int	cltps_opackets;
};

#ifdef KERNEL
extern struct	isopcb cltb;
extern struct	cltpstat cltpstat;
#endif
#endif /* _NETISO_CLTP_VAR_H_ */
