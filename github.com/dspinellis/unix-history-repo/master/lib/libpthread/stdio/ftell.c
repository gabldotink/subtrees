/*-
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * Chris Torek.
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
 */

#if defined(LIBC_SCCS) && !defined(lint)
/*static char *sccsid = "from: @(#)ftell.c	5.4 (Berkeley) 2/5/91";*/
static char *rcsid = "$Id: ftell.c,v 1.1 1994/01/30 04:25:01 proven Exp $";
#endif /* LIBC_SCCS and not lint */

#include <pthread.h>
#include <stdio.h>
#include <errno.h>
#include "local.h"

/*
 * ftell: return current offset.
 */
long
ftell(fp)
	register const FILE *fp;
{
	register fpos_t pos;

	flockfile(fp);

	/*
	 * Find offset of underlying I/O object, then
	 * adjust for buffered bytes.
	 */
	if (fp->_flags & __SOFF)
		pos = fp->_offset;
	else {
		pos = lseek(fp->_file, (fpos_t)0, SEEK_CUR);
	}

	if (pos != -1L) {
		if (fp->_flags & __SRD) {
			/*
			 * Reading.  Any unread characters (including
			 * those from ungetc) cause the position to be
			 * smaller than that in the underlying object.
			 */
			pos -= fp->_r;
			if (HASUB(fp))
				pos -= fp->_ur;
		} else if (fp->_flags & __SWR && fp->_p != NULL) {
			/*
			 * Writing.  Any buffered characters cause the
			 * position to be greater than that in the
			 * underlying object.
			 */
			pos += fp->_p - fp->_bf._base;
		}
	}
	funlockfile(fp);
	return (pos);
}
