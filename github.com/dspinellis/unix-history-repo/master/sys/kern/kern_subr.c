/*
 * Copyright (c) UNIX System Laboratories, Inc.  All or some portions
 * of this file are derived from material licensed to the
 * University of California by American Telephone and Telegraph Co.
 * or UNIX System Laboratories, Inc. and are reproduced herein with
 * the permission of UNIX System Laboratories, Inc.
 */
/*
 * Copyright (c) 1982, 1986, 1991 Regents of the University of California.
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
 *	from: @(#)kern_subr.c	7.7 (Berkeley) 4/15/91
 *	$Id: kern_subr.c,v 1.5 1993/12/19 00:51:31 wollman Exp $
 */

#include "param.h"
#include "systm.h"
#include "proc.h"

int
uiomove(xcp, n, uio)
	register void *xcp;
	register int n;
	register struct uio *uio;
{
	caddr_t cp = (caddr_t)xcp;
	register struct iovec *iov;
	u_int cnt;
	int error = 0;


#ifdef DIAGNOSTIC
	if (uio->uio_rw != UIO_READ && uio->uio_rw != UIO_WRITE)
		panic("uiomove: mode");
	if (uio->uio_segflg == UIO_USERSPACE && uio->uio_procp != curproc)
		panic("uiomove proc");
#endif
	while (n > 0 && uio->uio_resid) {
		iov = uio->uio_iov;
		cnt = iov->iov_len;
		if (cnt == 0) {
			uio->uio_iov++;
			uio->uio_iovcnt--;
			continue;
		}
		if (cnt > n)
			cnt = n;
		switch (uio->uio_segflg) {

		case UIO_USERSPACE:
		case UIO_USERISPACE:
			if (uio->uio_rw == UIO_READ)
				error = copyout(cp, iov->iov_base, cnt);
			else
				error = copyin(iov->iov_base, cp, cnt);
			if (error)
				return (error);
			break;

		case UIO_SYSSPACE:
			if (uio->uio_rw == UIO_READ)
				bcopy((caddr_t)cp, iov->iov_base, cnt);
			else
				bcopy(iov->iov_base, (caddr_t)cp, cnt);
			break;
		}
		iov->iov_base += cnt;
		iov->iov_len -= cnt;
		uio->uio_resid -= cnt;
		uio->uio_offset += cnt;
		cp += cnt;
		n -= cnt;
	}
	return (error);
}

int
uioapply(func, arg1, arg2, uio)
	int (*func)() ;
	caddr_t arg1;
	caddr_t arg2;
	register struct uio *uio;
{
	register struct iovec *iov;
	u_int cnt, cnt1;
	int error = 0;


/*#ifdef DIAGNOSTIC*/
	if (uio->uio_rw != UIO_READ && uio->uio_rw != UIO_WRITE)
		panic("uioapply: mode");
	if (uio->uio_segflg == UIO_USERSPACE && uio->uio_procp != curproc)
		panic("uioapply proc");
/*#endif*/
	while (uio->uio_resid) {
		iov = uio->uio_iov;
		cnt = iov->iov_len;
		if (cnt == 0) {
			uio->uio_iov++;
			uio->uio_iovcnt--;
			continue;
		}
		cnt1 = cnt;
		error = (*func)(arg1, arg2, NULL, uio->uio_offset, uio->uio_rw,
			iov->iov_base, &cnt1, uio->uio_procp);
		cnt -= cnt1;
		iov->iov_base += cnt;
		iov->iov_len -= cnt;
		uio->uio_resid -= cnt;
		uio->uio_offset += cnt;
		if (error || cnt1)
			return (error);
	}
	return (0);
}

/*
 * Give next character to user as result of read.
 */
int
ureadc(c, uio)
	register int c;
	register struct uio *uio;
{
	register struct iovec *iov;

again:
	if (uio->uio_iovcnt == 0)
		panic("ureadc");
	iov = uio->uio_iov;
	if (iov->iov_len <= 0 || uio->uio_resid <= 0) {
		uio->uio_iovcnt--;
		uio->uio_iov++;
		goto again;
	}
	switch (uio->uio_segflg) {

	case UIO_USERSPACE:
		if (subyte(iov->iov_base, c) < 0)
			return (EFAULT);
		break;

	case UIO_SYSSPACE:
		*iov->iov_base = c;
		break;

	case UIO_USERISPACE:
		if (suibyte(iov->iov_base, c) < 0)
			return (EFAULT);
		break;
	}
	iov->iov_base++;
	iov->iov_len--;
	uio->uio_resid--;
	uio->uio_offset++;
	return (0);
}

char *
strcat(src, append)
	register char *src;
	const char *append;
{
	char *old = src;

	for (; *src; ++src)
		;
	while (*src++ = *append++)
		;
	return old;
}

char *
strcpy(to, from)
	char *to;
	const char *from;
{
	char *old = to;
	for (; *to = *from; ++from, ++to)
		;
	return old;
}

char *
strncpy(to, from, cnt)
	char *to;
	const char *from;
	int cnt;
{
	char *old = to;

	for (; cnt && (*to = *from); --cnt, ++from, ++to)
		;
	*to = '\0';
	return old;
}


int
strcmp(s1, s2)
	register const char *s1, *s2;
{
	while (*s1 == *s2++)
		if (*s1++ == 0)
			return (0);
	return (*(unsigned char *)s1 - *(unsigned char *)--s2);
}

		

	


#ifdef notdef	/* unused except by ct.c, other oddities XXX */
/*
 * Get next character written in by user from uio.
 */
int
uwritec(uio)
	struct uio *uio;
{
	register struct iovec *iov;
	register int c;

	if (uio->uio_resid <= 0)
		return (-1);
again:
	if (uio->uio_iovcnt <= 0)
		panic("uwritec");
	iov = uio->uio_iov;
	if (iov->iov_len == 0) {
		uio->uio_iov++;
		if (--uio->uio_iovcnt == 0)
			return (-1);
		goto again;
	}
	switch (uio->uio_segflg) {

	case UIO_USERSPACE:
		c = fubyte(iov->iov_base);
		break;

	case UIO_SYSSPACE:
		c = *(u_char *) iov->iov_base;
		break;

	case UIO_USERISPACE:
		c = fuibyte(iov->iov_base);
		break;
	}
	if (c < 0)
		return (-1);
	iov->iov_base++;
	iov->iov_len--;
	uio->uio_resid--;
	uio->uio_offset++;
	return (c);
}
#endif /* notdef */
