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
 *	from: @(#)pk_timer.c	7.5 (Berkeley) 5/29/91
 *	$Id: pk_timer.c,v 1.3 1993/11/25 01:34:32 wollman Exp $
 */

#include "param.h"
#include "systm.h"
#include "mbuf.h"
#include "socket.h"
#include "protosw.h"
#include "socketvar.h"
#include "errno.h"

#include "../net/if.h"

#include "x25.h"
#include "pk.h"
#include "pk_var.h"

/*
 * Various timer values.  They can be adjusted
 * by patching the binary with adb if necessary.
 */
int	pk_t20 = 18 * PR_SLOWHZ;	/* restart timer */
int	pk_t21 = 20 * PR_SLOWHZ;	/* call timer */
/* XXX pk_t22 is never used */
/*int	pk_t22 = 18 * PR_SLOWHZ;*/	/* reset timer */
int	pk_t23 = 18 * PR_SLOWHZ;	/* clear timer */

void
pk_timer ()
{
	register struct pkcb *pkp;
	register struct pklcd *lcp, **pp;
	register int lcns_jammed, cant_restart;

	for (pkp = pkcbhead; pkp; pkp = pkp->pk_next) {
		switch (pkp -> pk_state) {
		case DTE_SENT_RESTART:
			lcp = pkp -> pk_chan[0];
			/*
			 * If restart failures are common, a link level
			 * reset should be initiated here.
			 */
			if (lcp -> lcd_timer && --lcp -> lcd_timer == 0)
				pk_message (0, pkp -> pk_xcp,
					"packet level restart failed");
			break;

		case DTE_READY:
			lcns_jammed = cant_restart = 0;
			for (pp = &pkp -> pk_chan[1]; pp <= &pkp -> pk_chan[pkp -> pk_maxlcn]; pp++) {
				if ((lcp = *pp) == 0)
					continue;
				switch (lcp -> lcd_state) {
				case SENT_CALL: 
					if (--lcp -> lcd_timer == 0) {
					    if (lcp -> lcd_so)
						lcp -> lcd_so -> so_error = ETIMEDOUT;
					    pk_clear (lcp, 49, 1);
					}
					break;

				case SENT_CLEAR: 
					if (lcp -> lcd_retry >= 3)
						lcns_jammed++;
					else
						if (--lcp -> lcd_timer == 0)
							pk_clear (lcp, 50, 1);
					break;

				case DATA_TRANSFER:	/* lcn active */
					cant_restart++;
					break;
				}
			}
			if (lcns_jammed > pkp -> pk_maxlcn / 2 && cant_restart == 0) {
				pk_message (0, pkp -> pk_xcp, "%d lcns jammed: attempting restart", lcns_jammed);
				pk_restart (pkp, 0);
			}
		}
	}
}
