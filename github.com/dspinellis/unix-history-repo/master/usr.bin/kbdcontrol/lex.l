/*-
 * Copyright (c) 1994 S�ren Schmidt
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
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software withough specific prior written permission
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *	$Id$
 */

%{

#include "lex.h"

%}

D	[0-9]
X	[0-9a-fA-F]
A	.
L	[OCN]

%%

nop		{ return TNOP; }
lshift 		{ return TLSH; }
rshift 		{ return TRSH; }
clock 		{ return TCLK; }
nlock		{ return TNLK; }
slock 		{ return TSLK; }
lalt|alt 	{ return TLALT; }
btab		{ return TBTAB; }
lctrl|ctrl 	{ return TLCTR; }
nscr 		{ return TNEXT; }
rctrl 		{ return TRCTR; }
ralt 		{ return TRALT; }
alock 		{ return TALK; }
ashift 		{ return TASH; }
meta 		{ return TMETA; }
boot 		{ return TRBT; }
debug 		{ return TDBG; }

NUL|nul		{ number = 0; return TNUM; }
SOH|soh		{ number = 1; return TNUM; }
STX|stx		{ number = 2; return TNUM; }
ETX|etx		{ number = 3; return TNUM; }
EOT|eot		{ number = 4; return TNUM; }
ENQ|enq		{ number = 5; return TNUM; }
ACK|ack		{ number = 6; return TNUM; }
BEL|bel		{ number = 7; return TNUM; }
BS|bs		{ number = 8; return TNUM; }
HT|ht		{ number = 9; return TNUM; }
LF|lf|NL|nl	{ number = 10; return TNUM; }
VT|vt		{ number = 11; return TNUM; }
FF|ff|NP|np	{ number = 12; return TNUM; }
CR|cr		{ number = 13; return TNUM; }
SO|so		{ number = 14; return TNUM; }
SI|si		{ number = 15; return TNUM; }
DLE|dle		{ number = 16; return TNUM; }
DC1|dc1		{ number = 17; return TNUM; }
DC2|dc2		{ number = 18; return TNUM; }
DC3|dc3		{ number = 19; return TNUM; }
DC4|dc4		{ number = 20; return TNUM; }
NAK|nak		{ number = 21; return TNUM; }
SYN|syn		{ number = 22; return TNUM; }
ETB|etb		{ number = 23; return TNUM; }
CAN|can		{ number = 24; return TNUM; }
EM|em		{ number = 25; return TNUM; }
SUB|sub		{ number = 26; return TNUM; }
ESC|esc		{ number = 27; return TNUM; }
FS|fs		{ number = 28; return TNUM; }
GS|gs		{ number = 29; return TNUM; }
RS|rs		{ number = 30; return TNUM; }
NS|ns		{ number = 31; return TNUM; }
SP|sp		{ number = 32; return TNUM; }
DEL|del		{ number = 127; return TNUM; }

fkey{D}({D}*)		{ 
				sscanf(yytext+4, "%d", &number); 
				return TFUNC; 
			}
scr{D}({D}*)		{ 
				sscanf(yytext+3, "%d", &number); 
				return TSCRN; 
			}
'{A}'			{ letter = *(yytext+1); return TLET; }
#({A}*)			{ /* ignore */ }
0x{X}({X}*)  		{ sscanf(yytext, "%x", &number); return TNUM; }
{D}({D}*)  		{ sscanf(yytext, "%d", &number); return TNUM; }
{L}			{ 
				if (*yytext == 'O') number = 0;
				if (*yytext == 'C') number = 1;
				if (*yytext == 'N') number = 2;
				return TFLAG;
			}
[ \t\n]		{ /* ignore */ }
