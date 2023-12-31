/*
 * Copyright (c) 1993, David Greenman
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
 *	This product includes software developed by David Greenman
 * 4. The name of the developer may be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
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
 *	$Id: shell_imgact.c,v 1.3 1993/12/11 06:55:33 davidg Exp davidg $
 */

#include "param.h"
#include "systm.h"
#include "resourcevar.h"
#include "imgact.h"

#define SHELLMAGIC	0x2123 /* #! */
#define MAXSHELLCMDLEN	64

/*
 * Shell interpreter image activator. A interpreter name beginning
 *	at iparams->stringbase is the minimal successful exit requirement.
 */
int
exec_shell_imgact(iparams)
	struct image_params *iparams;
{
	const char *image_header = iparams->image_header;
	const char *ihp, *line_endp;
	int length;
	char *interp;
	char **argv;

	/* a shell script? */
	if (((short *) image_header)[0] != SHELLMAGIC)
		return(-1);

	/*
	 * Don't allow a shell script to be the shell for a shell
	 *	script. :-)
	 */
	if (iparams->interpreted)
		return(ENOEXEC);

	iparams->interpreted = 1;

	/*
	 * Copy shell name and arguments from image_header into string
	 *	buffer.
	 */

	/*
	 * Find end of line; return if the line > MAXSHELLCMDLEN long.
	 */
	for (ihp = &image_header[2]; *ihp != '\n'; ++ihp) {
		if (ihp >= &image_header[MAXSHELLCMDLEN])
			return(ENOEXEC);
	}
	line_endp = ihp;

	/* reset for another pass */
	ihp = &image_header[2];

	/* Skip over leading spaces - until the interpreter name */
	while ((*ihp == ' ') || (*ihp == '\t')) ihp++;

	/* copy the interpreter name */
	interp = iparams->interpreter_name;
	while ((ihp < line_endp) && (*ihp != ' ') && (*ihp != '\t'))
		*interp++ = *ihp++;
	*interp = '\0';

	/* Disallow a null interpreter filename */
	if (*iparams->interpreter_name == '\0')
		return(ENOEXEC);

	/* reset for another pass */
	ihp = &image_header[2];

	/* copy the interpreter name and arguments */
	while (ihp < line_endp) {
		/* Skip over leading spaces */
		while ((*ihp == ' ') || (*ihp == '\t')) ihp++;

		if (ihp < line_endp) {
			/*
			 * Copy to end of token. No need to watch stringspace
			 *	because this is at the front of the string buffer
			 *	and the maximum shell command length is tiny.
			 */
			while ((ihp < line_endp) && (*ihp != ' ') && (*ihp != '\t')) {
				*iparams->stringp++ = *ihp++;
				iparams->stringspace--;
			}

			*iparams->stringp++ = 0;
			iparams->stringspace--;

			iparams->argc++;
		}
	}

	/* set argv[0] to point to original file name */
	suword(iparams->uap->argv, (int)iparams->uap->fname);

	return(0);
}
