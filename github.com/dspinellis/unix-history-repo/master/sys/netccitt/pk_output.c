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
 *	from: @(#)pk_output.c	7.10 (Berkeley) 5/29/91
 *	$Id: pk_output.c,v 1.3 1993/11/25 01:34:30 wollman Exp $
 */

#include "param.h"
#include "systm.h"
#include "mbuf.h"
#include "socket.h"
#include "socketvar.h"
#include "protosw.h"
#include "errno.h"

#include "../net/if.h"

#include "x25.h"
#include "pk.h"
#include "pk_var.h"

struct mbuf_cache pk_output_cache = {0 };
static struct mbuf *nextpk (struct pklcd *);

/*
 * The `n' argument is just there to make if_x25subr.c happy.  We
 * don't actually do anything with it, although meybe we should.
 * All the other code passes in a null pointer.
 */
int
pk_output (lcp, n)
	register struct pklcd *lcp;
	struct mbuf *n;
{
	register struct x25_packet *xp;
	register struct mbuf *m;
	register struct pkcb *pkp = lcp -> lcd_pkp;

	if (lcp == 0 || pkp == 0) {
		printf ("pk_output: zero arg\n");
		return -1;
	}

	while ((m = nextpk (lcp)) != NULL) {
		xp = mtod (m, struct x25_packet *);

		switch (pk_decode (xp) + lcp -> lcd_state) {
		/* 
		 *  All the work is already done - just set the state and
		 *  pass to peer.
		 */
		case CALL + READY: 
			lcp -> lcd_state = SENT_CALL;
			lcp -> lcd_timer = pk_t21;
			break;

		/*
		 *  Just set the state to allow packet to flow and send the
		 *  confirmation.
		 */
		case CALL_ACCEPTED + RECEIVED_CALL: 
			lcp -> lcd_state = DATA_TRANSFER;
			break;

		/* 
		 *  Just set the state. Keep the LCD around till the clear
		 *  confirmation is returned.
		 */
		case CLEAR + RECEIVED_CALL: 
		case CLEAR + SENT_CALL: 
		case CLEAR + DATA_TRANSFER: 
			lcp -> lcd_state = SENT_CLEAR;
			lcp -> lcd_retry = 0;
			/* fall through */

		case CLEAR + SENT_CLEAR:
			lcp -> lcd_timer = pk_t23;
			lcp -> lcd_retry++;
			break;

		case CLEAR_CONF + RECEIVED_CLEAR: 
		case CLEAR_CONF + SENT_CLEAR: 
		case CLEAR_CONF + READY: 
			lcp -> lcd_state = READY;
			break;

		case DATA + DATA_TRANSFER: 
			PS(xp) = lcp -> lcd_ssn;
			lcp -> lcd_input_window =
				(lcp -> lcd_rsn + 1) % MODULUS;
			PR(xp) = lcp -> lcd_input_window;
			lcp -> lcd_last_transmitted_pr = lcp -> lcd_input_window;
			lcp -> lcd_ssn = (lcp -> lcd_ssn + 1) % MODULUS;
			if (lcp -> lcd_ssn == ((lcp -> lcd_output_window + lcp -> lcd_windowsize) % MODULUS))
				lcp -> lcd_window_condition = TRUE;
			break;

		case INTERRUPT + DATA_TRANSFER: 
#ifdef ancient_history
			xp -> packet_data = 0;
#endif
			lcp -> lcd_intrconf_pending = TRUE;
			break;

		case INTERRUPT_CONF + DATA_TRANSFER: 
			break;

		case RR + DATA_TRANSFER: 
		case RNR + DATA_TRANSFER: 
			lcp -> lcd_input_window =
				(lcp -> lcd_rsn + 1) % MODULUS;
			PR(xp) = lcp -> lcd_input_window;
			lcp -> lcd_last_transmitted_pr = lcp -> lcd_input_window;
			break;

		case RESET + DATA_TRANSFER: 
			lcp -> lcd_reset_condition = TRUE;
			break;

		case RESET_CONF + DATA_TRANSFER: 
			lcp -> lcd_reset_condition = FALSE;
			break;

		/* 
		 *  A restart should be only generated internally. Therefore
		 *  all logic for restart is in the pk_restart routine.
		 */
		case RESTART + READY: 
			lcp -> lcd_timer = pk_t20;
			break;

		/* 
		 *  Restarts are all  handled internally.  Therefore all the
		 *  logic for the incoming restart packet is handled in  the
		 *  pk_input routine.
		 */
		case RESTART_CONF + READY: 
			break;

		default: 
			m_freem (m);
			return 0;
		}

		/* Trace the packet. */
		pk_trace (pkp -> pk_xcp, m, "P-Out");

		/* Pass the packet on down to the link layer */
		if (pk_output_cache.mbc_size || pk_output_cache.mbc_oldsize)
			mbuf_cache(&pk_output_cache, m);
		(*pkp -> pk_lloutput) (pkp -> pk_llnext, m);
	}
	return 0;
}

/* 
 *  This procedure returns the next packet to send or null. A
 *  packet is composed of one or more mbufs.
 */

static struct mbuf *
nextpk (lcp)
	struct pklcd *lcp;
{
	register struct mbuf *m, *n;
	struct socket *so = lcp -> lcd_so;
	register struct sockbuf *sb = & (so ? so -> so_snd : lcp -> lcd_sb);

	if (lcp -> lcd_template) {
		m = lcp -> lcd_template;
		lcp -> lcd_template = NULL;
	} else {
		if (lcp -> lcd_rnr_condition || lcp -> lcd_window_condition ||
				lcp -> lcd_reset_condition)
			return (NULL);

		if ((m = sb -> sb_mb) == 0)
			return (NULL);

 		sb -> sb_mb = m -> m_nextpkt;
 		m->m_act = 0;
		for (n = m; n; n = n -> m_next)
			sbfree (sb, n);
	}
	return (m);
}
