/*
 * Copyright (c) 1984, 1985, 1986, 1987 Regents of the University of California.
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
 *	from: @(#)ns_pcb.h	7.4 (Berkeley) 6/28/90
 *	$Id: ns_pcb.h,v 1.4 1993/11/25 01:36:34 wollman Exp $
 */

#ifndef _NETNS_NS_PCB_H_
#define _NETNS_NS_PCB_H_ 1

/*
 * Ns protocol interface control block.
 */
struct nspcb {
	struct	nspcb *nsp_next;	/* doubly linked list */
	struct	nspcb *nsp_prev;
	struct	nspcb *nsp_head;
	struct	socket *nsp_socket;	/* back pointer to socket */
	struct	ns_addr nsp_faddr;	/* destination address */
	struct	ns_addr nsp_laddr;	/* socket's address */
	caddr_t	nsp_pcb;		/* protocol specific stuff */
	struct	route nsp_route;	/* routing information */
	struct	ns_addr nsp_lastdst;	/* validate cached route for dg socks*/
	long	nsp_notify_param;	/* extra info passed via ns_pcbnotify*/
	short	nsp_flags;
	u_char	nsp_dpt;		/* default packet type for idp_output*/
	u_char	nsp_rpt;		/* last received packet type by
								idp_input() */
};

/* possible flags */

#define NSP_IN_ABORT	0x1		/* calling abort through socket */
#define NSP_RAWIN	0x2		/* show headers on input */
#define NSP_RAWOUT	0x4		/* show header on output */
#define NSP_ALL_PACKETS	0x8		/* Turn off higher proto processing */

#define	NS_WILDCARD	1

#define nsp_lport nsp_laddr.x_port
#define nsp_fport nsp_faddr.x_port

#define	sotonspcb(so)		((struct nspcb *)((so)->so_pcb))

/*
 * Nominal space allocated to a ns socket.
 */
#define	NSSNDQ		2048
#define	NSRCVQ		2048


#ifdef KERNEL
extern struct	nspcb nspcb;			/* head of list */

extern int ns_pcballoc(struct socket *, struct nspcb *);
extern int ns_pcbbind(struct nspcb *, struct mbuf *);
extern int ns_pcbconnect(struct nspcb *, struct mbuf *);
extern void ns_pcbdisconnect(struct nspcb *);
extern void ns_pcbdetach(struct nspcb *);
extern void ns_setsockaddr(struct nspcb *, struct mbuf *);
extern void ns_setpeeraddr(struct nspcb *, struct mbuf *);
typedef void (*ns_notify_func_t)(struct nspcb *, int);
extern void ns_pcbnotify(struct ns_addr *, int, ns_notify_func_t, long);
extern struct nspcb *ns_pcblookup(struct ns_addr *, int /*u_short*/, int);

#endif /* KERNEL */
#endif /* _NETNS_NS_PCB_H_ */
