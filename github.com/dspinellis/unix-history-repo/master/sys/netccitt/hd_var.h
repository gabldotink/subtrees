/*
 * Copyright (c) University of British Columbia, 1984
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * the Laboratory for Computation Vision and the Computer Science Department
 * of the University of British Columbia.
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
 *	from: @(#)hd_var.h	7.4 (Berkeley) 5/29/91
 *	$Id: hd_var.h,v 1.3 1993/11/07 17:47:22 wollman Exp $
 */

#ifndef _NETCCITT_HD_VAR_H_
#define _NETCCITT_HD_VAR_H_ 1

/*
 *
 * hdlc control block
 *
 */

struct	hdtxq {
	struct	mbuf *head;
	struct	mbuf *tail;
};

struct	hdcb {
	struct	hdcb *hd_next;	/* pointer to next hdlc control block */
	char	hd_state;	/* link state */
	char	hd_vs;		/* send state variable */
	char	hd_vr;		/* receive state variable */
	char	hd_lastrxnr;	/* last received N(R) */
	char	hd_lasttxnr;	/* last transmitted N(R) */
	char	hd_condition;
#define TIMER_RECOVERY_CONDITION        0x01
#define REJ_CONDITION                   0x02
#define REMOTE_RNR_CONDITION            0X04
	char	hd_retxcnt;
	char	hd_xx;
	struct	hdtxq hd_txq;
	struct	mbuf *hd_retxq[MODULUS];
	char	hd_retxqi;
	char	hd_rrtimer;
	char	hd_timer;
#define SET_TIMER(hdp)		hdp->hd_timer = hd_t1
#define KILL_TIMER(hdp)		hdp->hd_timer = 0
	char	hd_dontcopy;	/* if-driver doesn't free I-frames */
	struct	ifnet *hd_ifp;	/* device's network visible interface */
	struct	ifaddr *hd_ifa;	/* device's X.25 network address */
	struct	x25config *hd_xcp;
	caddr_t	hd_pkp;		/* Level III junk */
	int	(*hd_output)();	/* separate entry for HDLC direct output */

	/* link statistics */

	long	hd_iframes_in;
	long	hd_iframes_out;
	long	hd_rrs_in;
	long	hd_rrs_out;
	short	hd_rejs_in;
	short	hd_rejs_out;
	long	hd_window_condition;
	short	hd_invalid_ns;
	short	hd_invalid_nr;
	short	hd_timeouts;
	short	hd_resets;
	short	hd_unknown;
	short	hd_frmrs_in;
	short	hd_frmrs_out;
	short	hd_rnrs_in;
	short	hd_rnrs_out;
};

#ifdef KERNEL
struct	hdcb *hdcbhead;		/* head of linked list of hdcb's */
struct	Frmr_frame hd_frmr;	/* rejected frame diagnostic info */
struct	ifqueue hdintrq;	/* hdlc packet input queue */

int	hd_t1;			/* timer T1 value */
int	hd_t3;			/* RR send timer */
int	hd_n2;			/* frame retransmission limit */

extern void process_sframe(struct hdcb *, struct Hdlc_sframe *, int);
extern void hd_start(struct hdcb *);
extern void hd_send_iframe(struct hdcb *, struct mbuf *, int);
extern void hd_writeinternal(struct hdcb *, int, int);
extern void hd_flush(struct ifnet *);
extern void hd_message(struct hdcb *, const char *);

#endif /* KERNEL */
#endif /* _NETCCITT_HD_VAR_H_ */
