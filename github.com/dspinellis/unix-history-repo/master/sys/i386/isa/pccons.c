/*-
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * William Jolitz and Don Ahn.
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
 *	from: @(#)pccons.c	5.11 (Berkeley) 5/21/91
 *	$Id: pccons.c,v 1.16 1994/05/03 19:38:49 davidg Exp $
 */

/*
 * code to work keyboard & display for PC-style console
 */
#include "param.h"
#include "conf.h"
#include "ioctl.h"
#include "proc.h"
#include "user.h"
#include "tty.h"
#include "uio.h"
#include "i386/isa/isa_device.h"
#include "callout.h"
#include "systm.h"
#include "kernel.h"
#include "syslog.h"
#include "i386/isa/icu.h"
#include "i386/i386/cons.h"
#include "i386/isa/isa.h"
#include "i386/isa/ic/i8042.h"
#include "i386/isa/kbd.h"
#include "machine/pc/display.h"

#ifdef XSERVER						/* 15 Aug 92*/
int pc_xmode;
#endif /* XSERVER */

struct	tty *pccons;

struct	pcconsoftc {
	char	cs_flags;
#define	CSF_ACTIVE	0x1	/* timeout active */
#define	CSF_POLLING	0x2	/* polling for input */
	char	cs_lastc;	/* last char sent */
	int	cs_timo;	/* timeouts since interrupt */
	u_long	cs_wedgecnt;	/* times restarted */
} pcconsoftc;

struct	kbdsoftc {
	char	kbd_flags;
#define	KBDF_ACTIVE	0x1	/* timeout active */
#define	KBDF_POLLING	0x2	/* polling for input */
#define	KBDF_RAW	0x4	/* pass thru scan codes for input */
	char	kbd_lastc;	/* last char sent */
} kbdsoftc;

static struct video_state {
	char	esc;	/* seen escape */
	char	ebrac;	/* seen escape bracket */
	char	eparm;	/* seen escape and parameters */
	char	so;	/* in standout mode? */
	int 	cx;	/* "x" parameter */
	int 	cy;	/* "y" parameter */
	int 	row, col;	/* current cursor position */
	int 	nrow, ncol;	/* current screen geometry */
	char	fg_at, bg_at;	/* normal attributes */
	char	so_at;	/* standout attribute */
	char	kern_fg_at, kern_bg_at;
	char	color;	/* color or mono display */
} vs;

static int pcprobe(struct isa_device *);
static int pcattach(struct isa_device *);

struct	isa_driver pcdriver = {
	pcprobe, pcattach, "pc",
};


#define	COL		80
#define	ROW		25
#define	CHR		2
#define MONO_BASE	0x3B4
#define MONO_BUF	(KERNBASE + 0xB0000)
#define CGA_BASE	0x3D4
#define CGA_BUF		(KERNBASE + 0xB8000)
#define IOPHYSMEM	0xA0000

static unsigned int addr_6845 = MONO_BASE;
u_short *Crtat = (u_short *)MONO_BUF;
static int openf;

char *sgetc(int);
static	char	*more_chars;
static	int	char_count;

/*
 * We check the console periodically to make sure
 * that it hasn't wedged.  Unfortunately, if an XOFF
 * is typed on the console, that can't be distinguished
 * from more catastrophic failure.
 */
#define	CN_TIMERVAL	(hz)		/* frequency at which to check cons */
#define	CN_TIMO		(2*60)		/* intervals to allow for output char */

void	pcstart(struct tty *);
int	pcparam(struct tty *, struct termios *);
extern char partab[];
static void cursor(caddr_t, int);
static void sput(int /*u_char*/, int /*u_char*/);
static void pc_xmode_on(void);
static void pc_xmode_off(void);

int pcopen(int /*dev_t*/, int, int, struct proc *);
/*
 * Wait for CP to accept last CP command sent
 * before setting up next command.
 */
#define	waitforlast(timo) { \
	if (pclast) { \
		(timo) = 10000; \
		do \
			uncache((char *)&pclast->cp_unit); \
		while ((pclast->cp_unit&CPTAKE) == 0 && --(timo)); \
	} \
}

/*
 * Pass command to keyboard controller (8042)
 */
static int kbc_8042cmd(val)
int val;
{
	unsigned timeo;

	timeo = 100000; 	/* > 100 msec */
	while (inb(KBSTATP) & KBS_IBF)
		if (--timeo == 0)
			return (-1);
	outb(KBCMDP, val);
	return (0);
}

/*
 * Pass command to keyboard itself
 */
int kbd_cmd(val)
int val;
{
	unsigned timeo;

	timeo = 100000; 	/* > 100 msec */
	while (inb(KBSTATP) & KBS_IBF)
		if (--timeo == 0)
			return (-1);
	outb(KBOUTP, val);
	return (0);
}

/*
 * Read response from keyboard
 */
int kbd_response()
{
	unsigned timeo;

	timeo = 500000; 	/* > 500 msec (KBR_RSTDONE requires 87) */
	while (!(inb(KBSTATP) & KBS_DIB))
		if (--timeo == 0)
			return (-1);
	return ((u_char) inb(KBDATAP));
}

/*
 * these are both bad jokes
 */
int
pcprobe(dev)
	struct isa_device *dev;
{
	int again = 0;
	int response;

	/* Enable interrupts and keyboard, etc. */
	if (kbc_8042cmd(K_LDCMDBYTE) != 0)
		printf("Timeout specifying load of keyboard command byte\n");
	if (kbd_cmd(CMDBYTE) != 0)
		printf("Timeout writing keyboard command byte\n");
	/*
	 * Discard any stale keyboard activity.  The 0.1 boot code isn't
	 * very careful and sometimes leaves a KBR_RESEND.
	 */
	while (inb(KBSTATP) & KBS_DIB)
		kbd_response();

	/* Start keyboard reset */
	if (kbd_cmd(KBC_RESET) != 0)
		printf("Timeout for keyboard reset command\n");

	/* Wait for the first response to reset and handle retries */
	while ((response = kbd_response()) != KBR_ACK) {
		if (response < 0) {
			printf("Timeout for keyboard reset ack byte #1\n");
			response = KBR_RESEND;
		}
		if (response == KBR_RESEND) {
			if (!again) {
				printf("KEYBOARD disconnected: RECONNECT\n");
				again = 1;
			}
			if (kbd_cmd(KBC_RESET) != 0)
				printf("Timeout for keyboard reset command\n");
		}
		/*
		 * Other responses are harmless.  They may occur for new
		 * keystrokes.
		 */
	}

	/* Wait for the second response to reset */
	while ((response = kbd_response()) != KBR_RSTDONE) {
		if (response < 0) {
			printf("Timeout for keyboard reset ack byte #2\n");
			/*
			 * If KBR_RSTDONE never arrives, the loop will
			 * finish here unless the keyboard babbles or
			 * KBS_DIB gets stuck.
			 */
			break;
		}
	}
	return (IO_KBDSIZE);
}

int
pcattach(dev)
	struct isa_device *dev;
{
	u_short *cp = Crtat + (CGA_BUF-MONO_BUF)/CHR;
	u_short was;

	if (vs.color == 0)
		printf("pc%d: type monochrome\n",dev->id_unit);
	else	printf("pc%d: type color\n",dev->id_unit);
	cursor(0, 0);
	return 0;
}

/* ARGSUSED */
int
#ifdef __STDC__
pcopen(int /*dev_t*/ dev, int flag, int mode, struct proc *p)
#else
pcopen(dev, flag, mode, p)
	dev_t dev;
	int flag, mode;
	struct proc *p;
#endif
{
	register struct tty *tp;

	if (minor(dev) != 0)
		return (ENXIO);
	tp = pccons = ttymalloc(pccons);
	tp->t_oproc = pcstart;
	tp->t_param = pcparam;
	tp->t_dev = dev;
	openf++;
	if ((tp->t_state & TS_ISOPEN) == 0) {
		ttychars(tp);
		tp->t_iflag = TTYDEF_IFLAG;
		tp->t_oflag = TTYDEF_OFLAG;
		tp->t_cflag = TTYDEF_CFLAG;
		tp->t_lflag = TTYDEF_LFLAG;
		tp->t_ispeed = tp->t_ospeed = TTYDEF_SPEED;
		pcparam(tp, &tp->t_termios);
		ttsetwater(tp);
	} else if (tp->t_state&TS_XCLUDE && p->p_ucred->cr_uid != 0)
		return (EBUSY);
	tp->t_state |= TS_CARR_ON;
	return ((*linesw[tp->t_line].l_open)(dev, tp, 0));
}

int
pcclose(dev, flag, mode, p)
	dev_t dev;
	int flag, mode;
	struct proc *p;
{
	(*linesw[pccons->t_line].l_close)(pccons, flag);
	ttyclose(pccons);
#ifdef broken /* session holds a ref to the tty; can't deallocate */
	ttyfree(pccons);
	pccons = (struct tty *)NULL;
#endif
	return(0);
}

/*ARGSUSED*/
int
pcread(dev, uio, flag)
	dev_t dev;
	struct uio *uio;
	int flag;
{
	return ((*linesw[pccons->t_line].l_read)(pccons, uio, flag));
}

/*ARGSUSED*/
int
pcwrite(dev, uio, flag)
	dev_t dev;
	struct uio *uio;
	int flag;
{
	return ((*linesw[pccons->t_line].l_write)(pccons, uio, flag));
}

/*
 * Got a console receive interrupt -
 * the console processor wants to give us a character.
 * Catch the character, and see who it goes to.
 */
void
pcrint(unit)
	int unit;
{
	int c;
	char *cp;

	cp = sgetc(1);
	if (cp == 0)
		return;
	if (pcconsoftc.cs_flags & CSF_POLLING)
		return;
#ifdef KDB
	if (kdbrintr(c, pccons))
		return;
#endif
	if (!openf)
		return;

#ifdef XSERVER						/* 15 Aug 92*/
	/* send at least one character, because cntl-space is a null */
	(*linesw[pccons->t_line].l_rint)(*cp++ & 0xff, pccons);
#endif /* XSERVER */

	while (*cp)
		(*linesw[pccons->t_line].l_rint)(*cp++ & 0xff, pccons);
}

#ifdef XSERVER						/* 15 Aug 92*/
#define CONSOLE_X_MODE_ON _IO('t',121)
#define CONSOLE_X_MODE_OFF _IO('t',122)
#define CONSOLE_X_BELL _IOW('t',123,int[2])
#endif /* XSERVER */

int
pcioctl(dev, cmd, data, flag)
	dev_t dev;
	int cmd;
	caddr_t data;
	int flag;
{
	register struct tty *tp = pccons;
	register error;

#ifdef XSERVER						/* 15 Aug 92*/
	if (cmd == CONSOLE_X_MODE_ON) {
		pc_xmode_on ();
		return (0);
	} else if (cmd == CONSOLE_X_MODE_OFF) {
		pc_xmode_off ();
		return (0);
	} else if (cmd == CONSOLE_X_BELL) {
		/* if set, data is a pointer to a length 2 array of
		   integers. data[0] is the pitch in Hz and data[1]
		   is the duration in msec.  */
		if (data) {
			sysbeep(1187500/ ((int*)data)[0],
				((int*)data)[1] * hz/ 3000);
		} else {
			sysbeep(0x31b, hz/4);
		}
		return (0);
	}
#endif /* XSERVER */
 
	error = (*linesw[tp->t_line].l_ioctl)(tp, cmd, data, flag);
	if (error >= 0)
		return (error);
	error = ttioctl(tp, cmd, data, flag);
	if (error >= 0)
		return (error);
	return (ENOTTY);
}

int	pcconsintr = 1;
/*
 * Got a console transmission interrupt -
 * the console processor wants another character.
 */
void
pcxint(dev)
	dev_t dev;
{
	register struct tty *tp;
	register int unit;

	if (!pcconsintr)
		return;
	pccons->t_state &= ~TS_BUSY;
	pcconsoftc.cs_timo = 0;
	if (pccons->t_line)
		(*linesw[pccons->t_line].l_start)(pccons);
	else
		pcstart(pccons);
}

void
pcstart(tp)
	register struct tty *tp;
{
	int c, s;

	s = spltty();
	if (tp->t_state & (TS_TIMEOUT|TS_BUSY|TS_TTSTOP))
		goto out;
	do {
	if (tp->t_state & (TS_SO_OCOMPLETE | TS_SO_OLOWAT) || tp->t_wsel)
		ttwwakeup(tp);
	if (RB_LEN(tp->t_out) == 0)
		goto out;
	c = getc(tp->t_out);
	tp->t_state |= TS_BUSY;				/* 21 Aug 92*/
	splx(s);
	sput(c, 0);
	(void)spltty();
	tp->t_state &= ~TS_BUSY;			/* 21 Aug 92*/
	} while(1);
out:
	splx(s);
}

void
pccnprobe(cp)
	struct consdev *cp;
{
	int maj;

	/* locate the major number */
	for (maj = 0; maj < nchrdev; maj++)
		if (cdevsw[maj].d_open == pcopen)
			break;

	/* initialize required fields */
	cp->cn_dev = makedev(maj, 0);
	cp->cn_tp = pccons;
	cp->cn_pri = CN_INTERNAL;
}

/* ARGSUSED */
void
pccninit(cp)
	struct consdev *cp;
{
	/*
	 * For now, don't screw with it.
	 */
	/* crtat = 0; */
}

static __color;

/* ARGSUSED */
void
pccnputc(dev, c)
	dev_t dev;
	char c;
{
	if (c == '\n')
		sput('\r', 1);
	sput(c, 1);
}

/*
 * Print a character on console.
 */
void
pcputchar(c, tp)
	char c;
	register struct tty *tp;
{
	sput(c, 1);
	/*if (c=='\n') getchar();*/
}


/* ARGSUSED */
int
pccngetc(dev)
	dev_t dev;
{
	register int s;
	register char *cp;

#ifdef XSERVER						/* 15 Aug 92*/
	if (pc_xmode)
		return (0);
#endif /* XSERVER */

	s = spltty();		/* block pcrint while we poll */
	cp = sgetc(0);
	splx(s);
	if (*cp == '\r') return('\n');
	return (*cp);
}

int
pcgetchar(tp)
	register struct tty *tp;
{
	char *cp;

#ifdef XSERVER						/* 15 Aug 92*/
	if (pc_xmode)
		return (0);
#endif /* XSERVER */

	cp = sgetc(0);
	return (*cp&0xff);
}

/*
 * Set line parameters
 */
int
pcparam(tp, t)
	register struct tty *tp;
	register struct termios *t;
{
	register int cflag = t->c_cflag;
        /* and copy to tty */
        tp->t_ispeed = t->c_ispeed;
        tp->t_ospeed = t->c_ospeed;
        tp->t_cflag = cflag;

	return(0);
}

#ifdef KDB
/*
 * Turn input polling on/off (used by debugger).
 */
pcpoll(onoff)
	int onoff;
{
}
#endif

/*
 * cursor():
 *   reassigns cursor position, updated by the rescheduling clock
 *   which is a index (0-1999) into the text area. Note that the
 *   cursor is a "foreground" character, it's color determined by
 *   the fg_at attribute. Thus if fg_at is left as 0, (FG_BLACK),
 *   as when a portion of screen memory is 0, the cursor may dissappear.
 */

static u_short *crtat = 0;

static void
cursor(caddr_t rock, int arg2)
{
 	int pos = crtat - Crtat;

#ifdef XSERVER						/* 15 Aug 92*/
	if (!pc_xmode) {
#endif /* XSERVER */
	outb(addr_6845, 14);
	outb(addr_6845+1, pos>> 8);
	outb(addr_6845, 15);
	outb(addr_6845+1, pos);
#ifdef	FAT_CURSOR
	outb(addr_6845, 10);
	outb(addr_6845+1, 0);
	outb(addr_6845, 11);
	outb(addr_6845+1, 18);
#endif	/* FAT_CURSOR */
	if (rock == 0)
		timeout(cursor, 0, hz/10);
#ifdef XSERVER						/* 15 Aug 92*/
	}
#endif /* XSERVER */
}

static u_char shift_down, ctrl_down, alt_down, caps, num, scroll;

#define	wrtchar(c, at) \
	{ char *cp = (char *)crtat; *cp++ = (c); *cp = (at); crtat++; vs.col++; }


/* translate ANSI color codes to standard pc ones */
static char fgansitopc[] =
{	FG_BLACK, FG_RED, FG_GREEN, FG_BROWN, FG_BLUE,
	FG_MAGENTA, FG_CYAN, FG_LIGHTGREY
};

static char bgansitopc[] =
{	BG_BLACK, BG_RED, BG_GREEN, BG_BROWN, BG_BLUE,
	BG_MAGENTA, BG_CYAN, BG_LIGHTGREY
};

/*
 *   sput has support for emulation of the 'pc3' termcap entry.
 *   if ka, use kernel attributes.
 */
static void
sput(c,  ka)
	u_char c;
	u_char ka;
{

	int sc = 1;	/* do scroll check */
	char fg_at, bg_at, at;

#ifdef XSERVER						/* 15 Aug 92*/
	if (pc_xmode)
		return;
#endif /* XSERVER */

	if (crtat == 0)
	{
		u_short volatile *cp = Crtat + (CGA_BUF-MONO_BUF)/CHR;
		u_short was;
		unsigned cursorat;

		/*
		 *   Crtat  initialized  to  point  to  MONO  buffer  if not present
		 *   change   to  CGA_BUF  offset  ONLY  ADD  the  difference  since
		 *   locore.s adds in the remapped offset at the right time
		 */

		was = *cp;
		*cp = (u_short) 0xA55A;
		if (*cp != 0xA55A) {
			addr_6845 = MONO_BASE;
			vs.color=0;
		} else {
			*cp = was;
			addr_6845 = CGA_BASE;
			Crtat = Crtat + (CGA_BUF-MONO_BUF)/CHR;
			vs.color=1;
		}
		/* Extract cursor location */
		outb(addr_6845,14);
		cursorat = inb(addr_6845+1)<<8 ;
		outb(addr_6845,15);
		cursorat |= inb(addr_6845+1);

		crtat = Crtat + cursorat;
		vs.ncol = COL;
		vs.nrow = ROW;
		vs.fg_at = FG_LIGHTGREY;
		vs.bg_at = BG_BLACK;

		if (vs.color == 0) {
			vs.kern_fg_at = FG_UNDERLINE;
			vs.so_at = FG_BLACK | BG_LIGHTGREY;
		} else {
			vs.kern_fg_at = FG_LIGHTGREY;
			vs.so_at = FG_YELLOW | BG_BLACK;
		}
		vs.kern_bg_at = BG_BLACK;

		fillw(((vs.bg_at|vs.fg_at)<<8)|' ', crtat,
		      COL*ROW-cursorat);
	}

	/* which attributes do we use? */
	if (ka) {
		fg_at = vs.kern_fg_at;
		bg_at = vs.kern_bg_at;
	} else {
		fg_at = vs.fg_at;
		bg_at = vs.bg_at;
	}
	at = fg_at|bg_at;

	switch(c) {
		int inccol;

	case 0x1B:
		if(vs.esc)
			wrtchar(c, vs.so_at); 
		vs.esc = 1; vs.ebrac = 0; vs.eparm = 0;
		break;

	case '\t':
		inccol = (8 - vs.col % 8);	/* non-destructive tab */
		crtat += inccol;
		vs.col += inccol;
		break;

	case '\010':
		crtat--; vs.col--;
		if (vs.col < 0) vs.col += vs.ncol;  /* non-destructive backspace */
		break;

	case '\r':
		crtat -=  (crtat - Crtat) % vs.ncol; vs.col = 0;
		break;

	case '\n':
		crtat += vs.ncol ;
		break;

	default:
	bypass:
		if (vs.esc) {
			if (vs.ebrac) {
				switch(c) {
					int pos, posy, count;
					u_short *src, *dst;

				case 'm':
					if (!vs.cx) vs.so = 0;
					else vs.so = 1;
					vs.esc = 0; vs.ebrac = 0; vs.eparm = 0;
					break;
				case 'A': /* back cx rows */
					if (vs.cx <= 0) vs.cx = 1;
					pos = crtat - Crtat;
					pos -= vs.ncol * vs.cx;
					if (pos < 0)
						pos += vs.nrow * vs.ncol;
					crtat = Crtat + pos;
					sc = vs.esc = vs.ebrac = vs.eparm = 0;
					break;
				case 'B': /* down cx rows */
					if (vs.cx <= 0) vs.cx = 1;
					pos = crtat - Crtat;
					pos += vs.ncol * vs.cx;
					if (pos >= vs.nrow * vs.ncol) 
						pos -= vs.nrow * vs.ncol;
					crtat = Crtat + pos;
					sc = vs.esc = vs.ebrac = vs.eparm = 0;
					break;
				case 'C': /* right cursor */
					if (vs.cx <= 0)
						vs.cx = 1;
					pos = crtat - Crtat;
					pos += vs.cx; vs.col += vs.cx;
					if (vs.col >= vs.ncol) {
						vs.col -= vs.ncol;
						pos -= vs.ncol;     /* cursor stays on same line */
					}
					crtat = Crtat + pos;
					sc = vs.esc = vs.ebrac = vs.eparm = 0;
					break;
				case 'D': /* left cursor */
					if (vs.cx <= 0)
						vs.cx = 1;
					pos = crtat - Crtat;
					pos -= vs.cx; vs.col -= vs.cx;
					if (vs.col < 0) {
						vs.col += vs.ncol;
						pos += vs.ncol;     /* cursor stays on same line */
					}
					crtat = Crtat + pos;
					sc = vs.esc = vs.ebrac = vs.eparm = 0;
					break;
				case 'J': /* Clear ... */
					if (vs.cx == 0)
						/* ... to end of display */
						fillw((at << 8) + ' ',
							crtat,
							Crtat + vs.ncol * vs.nrow - crtat);
					else if (vs.cx == 1)
						/* ... to next location */
						fillw((at << 8) + ' ',
							Crtat,
							crtat - Crtat + 1);
					else if (vs.cx == 2)
						/* ... whole display */
						fillw((at << 8) + ' ',
							Crtat,
							vs.ncol * vs.nrow);
						
					vs.esc = 0; vs.ebrac = 0; vs.eparm = 0;
					break;
				case 'K': /* Clear line ... */
					if (vs.cx == 0)
						/* ... current to EOL */
						fillw((at << 8) + ' ',
							crtat,
							vs.ncol - (crtat - Crtat) % vs.ncol);
					else if (vs.cx == 1)
						/* ... beginning to next */
						fillw((at << 8) + ' ',
							crtat - (crtat - Crtat) % vs.ncol,
							((crtat - Crtat) % vs.ncol) + 1);
					else if (vs.cx == 2)
						/* ... entire line */
						fillw((at << 8) + ' ',
							crtat - (crtat - Crtat) % vs.ncol,
							vs.ncol);
					vs.esc = 0; vs.ebrac = 0; vs.eparm = 0;
					break;
				case 'f': /* in system V consoles */
				case 'H': /* Cursor move */
					if ((!vs.cx)||(!vs.cy)) {
						crtat = Crtat;
						vs.col = 0;
					} else {
						crtat = Crtat + (vs.cx - 1) * vs.ncol + vs.cy - 1;
						vs.col = vs.cy - 1;
					}
					vs.esc = 0; vs.ebrac = 0; vs.eparm = 0;
					break;
				case 'S':  /* scroll up cx lines */
					if (vs.cx <= 0) vs.cx = 1;
					posy = (crtat - Crtat) / vs.ncol;
					if (vs.cx > posy)
						vs.cx = posy;
					bcopyw(Crtat+vs.ncol*vs.cx, Crtat, vs.ncol*(vs.nrow-vs.cx)*CHR);
					fillw((at <<8)+' ',
						(Crtat + vs.ncol * (vs.nrow - vs.cx)),
						vs.ncol * vs.cx);
					/* crtat -= vs.ncol*vs.cx;*/ /* XXX */
					vs.esc = 0; vs.ebrac = 0; vs.eparm = 0;
					break;
				case 'T':  /* scroll down cx lines */
					if (vs.cx <= 0) vs.cx = 1;
					posy = (crtat - Crtat) / vs.ncol;
					if (vs.cx > vs.nrow - posy)
						vs.cx = vs.nrow - posy;
					bcopyw(Crtat, Crtat+vs.ncol*vs.cx, vs.ncol*(vs.nrow-vs.cx)*CHR);
					fillw((at <<8)+' ', Crtat, vs.ncol*vs.cx);
					/* crtat += vs.ncol*vs.cx;*/ /* XXX */
					vs.esc = 0; vs.ebrac = 0; vs.eparm = 0;
					break;
				case 'L':       /* Insert cx lines */
					if (vs.cx <= 0) vs.cx = 1;
					posy = (crtat - Crtat) / vs.ncol;
					if (vs.cx > vs.nrow - posy)
						vs.cx = vs.nrow - posy;
					src = Crtat + posy * vs.ncol;
					dst = src + vs.cx * vs.ncol;
					count = vs.nrow - (posy + vs.cx);
					bcopyw(src, dst, count * vs.ncol * CHR);
					fillw((at <<8)+' ', src, vs.cx * vs.ncol);
					vs.esc = 0; vs.ebrac = 0; vs.eparm = 0;
					break;
				case 'M':       /* Delete cx lines */
					if (vs.cx <= 0) vs.cx = 1;
					posy = (crtat - Crtat) / vs.ncol;
					if (vs.cx > vs.nrow - posy)
						vs.cx = vs.nrow - posy;
					dst = Crtat + posy * vs.ncol;
					src = dst + vs.cx * vs.ncol;
					count = vs.nrow - (posy + vs.cx);
					bcopyw(src, dst, count * vs.ncol * CHR);
					src = dst + count * vs.ncol;
					fillw((at <<8)+' ', src, vs.cx * vs.ncol);
					vs.esc = 0; vs.ebrac = 0; vs.eparm = 0;
  					break;
				case ';': /* Switch params in cursor def */
					vs.eparm = 1;
					break;
				case 'r':
					vs.so_at = (vs.cx & 0x0f) | ((vs.cy & 0x0f) << 4);
					vs.esc = 0; vs.ebrac = 0; vs.eparm = 0;
					break;
				case 'x': /* set attributes */
					switch (vs.cx) {
					case 0:
						/* reset to normal attributes */
						bg_at = BG_BLACK;
						if (ka)
							fg_at = vs.color? FG_LIGHTGREY: FG_UNDERLINE;
						else
							fg_at = FG_LIGHTGREY;
						break;
					case 1:
						/* ansi background */
						if (vs.color)
							bg_at = bgansitopc[vs.cy & 7];
						break;
					case 2:
						/* ansi foreground */
						if (vs.color)
							fg_at = fgansitopc[vs.cy & 7];
						break;
					case 3:
						/* pc text attribute */
						if (vs.eparm) {
							fg_at = vs.cy & 0x8f;
							bg_at = vs.cy & 0x70;
						}
						break;
					}
					if (ka) {
						vs.kern_fg_at = fg_at;
						vs.kern_bg_at = bg_at;
					} else {
						vs.fg_at = fg_at;
						vs.bg_at = bg_at;
					}
					vs.esc = 0; vs.ebrac = 0; vs.eparm = 0;
					break;
					
				default: /* Only numbers valid here */
					if ((c >= '0')&&(c <= '9')) {
						if (vs.eparm) {
							vs.cy *= 10;
							vs.cy += c - '0';
						} else {
							vs.cx *= 10;
							vs.cx += c - '0';
						}
					} else {
						vs.esc = 0; vs.ebrac = 0; vs.eparm = 0;
					}
					break;
				}
				break;
			} else if (c == 'c') { /* Clear screen & home */
				fillw((at << 8) + ' ', Crtat, vs.ncol*vs.nrow);
				crtat = Crtat; vs.col = 0;
				vs.esc = 0; vs.ebrac = 0; vs.eparm = 0;
			} else if (c == '[') { /* Start ESC [ sequence */
				vs.ebrac = 1; vs.cx = 0; vs.cy = 0; vs.eparm = 0;
			} else { /* Invalid, clear state */
				 vs.esc = 0; vs.ebrac = 0; vs.eparm = 0;
					wrtchar(c, vs.so_at); 
			}
		} else {
			if (c == 7)
				sysbeep(0x31b, hz/4);
			else {
				if (vs.so) {
					wrtchar(c, vs.so_at);
				} else
					wrtchar(c, at); 
				if (vs.col >= vs.ncol) vs.col = 0;
				break ;
			}
		}
	}
	if (sc && crtat >= Crtat+vs.ncol*vs.nrow) { /* scroll check */
		if (openf) do (void)sgetc(1); while (scroll);
		bcopyw(Crtat+vs.ncol, Crtat, vs.ncol*(vs.nrow-1)*CHR);
		fillw ((at << 8) + ' ', Crtat + vs.ncol*(vs.nrow-1),
			vs.ncol);
		crtat -= vs.ncol;
	}
	if (ka)
		cursor((caddr_t)1, 0);
}


unsigned	__debug = 0; /*0xffe */
static char scantokey[] = {
0,
120,	/* F9 */
0,
116,	/* F5 */
114,	/* F3 */
112,	/* F1 */
113,	/* F2 */
123,	/* F12 */
0,
121,	/* F10 */
119,	/* F8 */
117,	/* F6 */
115,	/* F4 */
16,	/* TAB */
1,	/* ` */
0,
0,
60,	/* ALT (left) */
44,	/* SHIFT (left) */
0,
58,	/* CTRL (left) */
17,	/* Q */
2,	/* 1 */
0,
0,
0,
46,	/* Z */
32,	/* S */
31,	/* A */
18,	/* W */
3,	/* 2 */
0,
0,
48,	/* C */
47,	/* X */
33,	/* D */
19,	/* E */
5,	/* 4 */
4,	/* 3 */
0,
0,
61,	/* SPACE */
49,	/* V */
34,	/* F */
21,	/* T */
20,	/* R */
6,	/* 5 */
0,
0,
51,	/* N */
50,	/* B */
36,	/* H */
35,	/* G */
22,	/* Y */
7,	/* 6 */
0,
0,
0,
52,	/* M */
37,	/* J */
23,	/* U */
8,	/* 7 */
9,	/* 8 */
0,
0,
53,	/* , */
38,	/* K */
24,	/* I */
25,	/* O */
11,	/* 0 */
10,	/* 9 */
0,
0,
54,	/* . */
55,	/* / */
39,	/* L */
40,	/* ; */
26,	/* P */
12,	/* - */
0,
0,
0,
41,	/* " */
0,
27,	/* [ */
13,	/* + */
0,
0,
0,
57,	/* SHIFT (right) */
43,	/* ENTER */
28,	/* ] */
0,
29,	/* \ */
0,
0,
0,
45,	/* na*/
0,
0,
0,
0,
15,	/* backspace */
0,
0,				/* keypad */
93,	/* 1 */
0,
92,	/* 4 */
91,	/* 7 */
0,
0,
0,
99,	/* 0 */
104,	/* . */
98,	/* 2 */
97,	/* 5 */
102,	/* 6 */
96,	/* 8 */
110,	/* ESC */
90,	/* Num Lock */
122,	/* F11 */
106,	/* + */
103,	/* 3 */
105,	/* - */
100,	/* * */
101,	/* 9 */
0,
0,
0,
0,
0,
118,	/* F7 */
};
static char extscantokey[] = {
0,
120,	/* F9 */
0,
116,	/* F5 */
114,	/* F3 */
112,	/* F1 */
113,	/* F2 */
123,	/* F12 */
0,
121,	/* F10 */
119,	/* F8 */
117,	/* F6 */
115,	/* F4 */
16,	/* TAB */
1,	/* ` */
0,
0,
 62,	/* ALT (right) */
 124,	/* Print Screen */
0,
 64,	/* CTRL (right) */
17,	/* Q */
2,	/* 1 */
0,
0,
0,
46,	/* Z */
32,	/* S */
31,	/* A */
18,	/* W */
3,	/* 2 */
0,
0,
48,	/* C */
47,	/* X */
33,	/* D */
19,	/* E */
5,	/* 4 */
4,	/* 3 */
0,
0,
61,	/* SPACE */
49,	/* V */
34,	/* F */
21,	/* T */
20,	/* R */
6,	/* 5 */
0,
0,
51,	/* N */
50,	/* B */
36,	/* H */
35,	/* G */
22,	/* Y */
7,	/* 6 */
0,
0,
0,
52,	/* M */
37,	/* J */
23,	/* U */
8,	/* 7 */
9,	/* 8 */
0,
0,
53,	/* , */
38,	/* K */
24,	/* I */
25,	/* O */
11,	/* 0 */
10,	/* 9 */
0,
0,
54,	/* . */
 95,	/* / */
39,	/* L */
40,	/* ; */
26,	/* P */
12,	/* - */
0,
0,
0,
41,	/* " */
0,
27,	/* [ */
13,	/* + */
0,
0,
0,
57,	/* SHIFT (right) */
 108,	/* ENTER */
28,	/* ] */
0,
29,	/* \ */
0,
0,
0,
45,	/* na*/
0,
0,
0,
0,
15,	/* backspace */
0,
0,				/* keypad */
 81,	/* end */
0,
 79,	/* left arrow */
 80,	/* home */
0,
0,
0,
 75,	/* ins */
 76,	/* del */
 84,	/* down arrow */
97,	/* 5 */
 89,	/* right arrow */
 83,	/* up arrow */
110,	/* ESC */
90,	/* Num Lock */
122,	/* F11 */
106,	/* + */
 86,	/* page down */
105,	/* - */
 124,	/* print screen */
 85,	/* page up */
0,
0,
0,
0,
0,
118,	/* F7 */
};
#define	CODE_SIZE	4		/* Use a max of 4 for now... */
typedef struct
{
	u_short	type;
	char	unshift[CODE_SIZE];
	char	shift[CODE_SIZE];
	char	ctrl[CODE_SIZE];
} Scan_def;

#define	SHIFT		0x0002	/* keyboard shift */
#define	ALT		0x0004	/* alternate shift -- alternate chars */
#define	NUM		0x0008	/* numeric shift  cursors vs. numeric */
#define	CTL		0x0010	/* control shift  -- allows ctl function */
#define	CAPS		0x0020	/* caps shift -- swaps case of letter */
#define	ASCII		0x0040	/* ascii code for this key */
#define	SCROLL		0x0080	/* stop output */
#define	FUNC		0x0100	/* function key */
#define	KP		0x0200	/* Keypad keys */
#define	NONE		0x0400	/* no function */

static Scan_def	scan_codes[] =
{
	NONE,	"",		"",		"",		/* 0 unused */
	ASCII,	"\033",		"\033",		"\033",		/* 1 ESCape */
	ASCII,	"1",		"!",		"!",		/* 2 1 */
	ASCII,	"2",		"@",		"\000",		/* 3 2 */
	ASCII,	"3",		"#",		"#",		/* 4 3 */
	ASCII,	"4",		"$",		"$",		/* 5 4 */
	ASCII,	"5",		"%",		"%",		/* 6 5 */
	ASCII,	"6",		"^",		"\036",		/* 7 6 */
	ASCII,	"7",		"&",		"&",		/* 8 7 */
	ASCII,	"8",		"*",		"\010",		/* 9 8 */
	ASCII,	"9",		"(",		"(",		/* 10 9 */
	ASCII,	"0",		")",		")",		/* 11 0 */
	ASCII,	"-",		"_",		"\037",		/* 12 - */
	ASCII,	"=",		"+",		"+",		/* 13 = */
	ASCII,	"\177",		"\177",		"\010",		/* 14 backspace */
	ASCII,	"\t",		"\177\t",	"\t",		/* 15 tab */
	ASCII,	"q",		"Q",		"\021",		/* 16 q */
	ASCII,	"w",		"W",		"\027",		/* 17 w */
	ASCII,	"e",		"E",		"\005",		/* 18 e */
	ASCII,	"r",		"R",		"\022",		/* 19 r */
	ASCII,	"t",		"T",		"\024",		/* 20 t */
	ASCII,	"y",		"Y",		"\031",		/* 21 y */
	ASCII,	"u",		"U",		"\025",		/* 22 u */
	ASCII,	"i",		"I",		"\011",		/* 23 i */
	ASCII,	"o",		"O",		"\017",		/* 24 o */
	ASCII,	"p",		"P",		"\020",		/* 25 p */
	ASCII,	"[",		"{",		"\033",		/* 26 [ */
	ASCII,	"]",		"}",		"\035",		/* 27 ] */
	ASCII,	"\r",		"\r",		"\n",		/* 28 return */
	CTL,	"",		"",		"",		/* 29 control */
	ASCII,	"a",		"A",		"\001",		/* 30 a */
	ASCII,	"s",		"S",		"\023",		/* 31 s */
	ASCII,	"d",		"D",		"\004",		/* 32 d */
	ASCII,	"f",		"F",		"\006",		/* 33 f */
	ASCII,	"g",		"G",		"\007",		/* 34 g */
	ASCII,	"h",		"H",		"\010",		/* 35 h */
	ASCII,	"j",		"J",		"\n",		/* 36 j */
	ASCII,	"k",		"K",		"\013",		/* 37 k */
	ASCII,	"l",		"L",		"\014",		/* 38 l */
	ASCII,	";",		":",		";",		/* 39 ; */
	ASCII,	"'",		"\"",		"'",		/* 40 ' */
	ASCII,	"`",		"~",		"`",		/* 41 ` */
	SHIFT,	"",		"",		"",		/* 42 shift */
	ASCII,	"\\",		"|",		"\034",		/* 43 \ */
	ASCII,	"z",		"Z",		"\032",		/* 44 z */
	ASCII,	"x",		"X",		"\030",		/* 45 x */
	ASCII,	"c",		"C",		"\003",		/* 46 c */
	ASCII,	"v",		"V",		"\026",		/* 47 v */
	ASCII,	"b",		"B",		"\002",		/* 48 b */
	ASCII,	"n",		"N",		"\016",		/* 49 n */
	ASCII,	"m",		"M",		"\r",		/* 50 m */
	ASCII,	",",		"<",		"<",		/* 51 , */
	ASCII,	".",		">",		">",		/* 52 . */
	ASCII,	"/",		"?",		"\177",		/* 53 / */
	SHIFT,	"",		"",		"",		/* 54 shift */
	KP,	"*",		"*",		"*",		/* 55 kp * */
	ALT,	"",		"",		"",		/* 56 alt */
	ASCII,	" ",		" ",		" ",		/* 57 space */
	CAPS,	"",		"",		"",		/* 58 caps */
	FUNC,	"\033[M",	"\033[Y",	"\033[k",	/* 59 f1 */
	FUNC,	"\033[N",	"\033[Z",	"\033[l",	/* 60 f2 */
	FUNC,	"\033[O",	"\033[a",	"\033[m",	/* 61 f3 */
	FUNC,	"\033[P",	"\033[b",	"\033[n",	/* 62 f4 */
	FUNC,	"\033[Q",	"\033[c",	"\033[o",	/* 63 f5 */
	FUNC,	"\033[R",	"\033[d",	"\033[p",	/* 64 f6 */
	FUNC,	"\033[S",	"\033[e",	"\033[q",	/* 65 f7 */
	FUNC,	"\033[T",	"\033[f",	"\033[r",	/* 66 f8 */
	FUNC,	"\033[U",	"\033[g",	"\033[s",	/* 67 f9 */
	FUNC,	"\033[V",	"\033[h",	"\033[t",	/* 68 f10 */
	NUM,	"",		"",		"",		/* 69 num lock */
	SCROLL,	"",		"",		"",		/* 70 scroll lock */
	KP,	"7",		"\033[H",	"7",		/* 71 kp 7 */
	KP,	"8",		"\033[A",	"8",		/* 72 kp 8 */
	KP,	"9",		"\033[I",	"9",		/* 73 kp 9 */
	KP,	"-",		"-",		"-",		/* 74 kp - */
	KP,	"4",		"\033[D",	"4",		/* 75 kp 4 */
	KP,	"5",		"\033[E",	"5",		/* 76 kp 5 */
	KP,	"6",		"\033[C",	"6",		/* 77 kp 6 */
	KP,	"+",		"+",		"+",		/* 78 kp + */
	KP,	"1",		"\033[F",	"1",		/* 79 kp 1 */
	KP,	"2",		"\033[B",	"2",		/* 80 kp 2 */
	KP,	"3",		"\033[G",	"3",		/* 81 kp 3 */
	KP,	"0",		"\033[L",	"0",		/* 82 kp 0 */
	KP,	".",		"\177",		".",		/* 83 kp . */
	NONE,	"",		"",		"",		/* 84 0 */
	NONE,	"100",		"",		"",		/* 85 0 */
	NONE,	"101",		"",		"",		/* 86 0 */
	FUNC,	"\033[W",	"\033[i",	"\033[u",	/* 87 f11 */
	FUNC,	"\033[X",	"\033[j",	"\033[v",	/* 88 f12 */
	NONE,	"102",		"",		"",		/* 89 0 */
	NONE,	"103",		"",		"",		/* 90 0 */
	NONE,	"",		"",		"",		/* 91 0 */
	NONE,	"",		"",		"",		/* 92 0 */
	NONE,	"",		"",		"",		/* 93 0 */
	NONE,	"",		"",		"",		/* 94 0 */
	NONE,	"",		"",		"",		/* 95 0 */
	NONE,	"",		"",		"",		/* 96 0 */
	NONE,	"",		"",		"",		/* 97 0 */
	NONE,	"",		"",		"",		/* 98 0 */
	NONE,	"",		"",		"",		/* 99 0 */
	NONE,	"",		"",		"",		/* 100 */
	NONE,	"",		"",		"",		/* 101 */
	NONE,	"",		"",		"",		/* 102 */
	NONE,	"",		"",		"",		/* 103 */
	NONE,	"",		"",		"",		/* 104 */
	NONE,	"",		"",		"",		/* 105 */
	NONE,	"",		"",		"",		/* 106 */
	NONE,	"",		"",		"",		/* 107 */
	NONE,	"",		"",		"",		/* 108 */
	NONE,	"",		"",		"",		/* 109 */
	NONE,	"",		"",		"",		/* 110 */
	NONE,	"",		"",		"",		/* 111 */
	NONE,	"",		"",		"",		/* 112 */
	NONE,	"",		"",		"",		/* 113 */
	NONE,	"",		"",		"",		/* 114 */
	NONE,	"",		"",		"",		/* 115 */
	NONE,	"",		"",		"",		/* 116 */
	NONE,	"",		"",		"",		/* 117 */
	NONE,	"",		"",		"",		/* 118 */
	NONE,	"",		"",		"",		/* 119 */
	NONE,	"",		"",		"",		/* 120 */
	NONE,	"",		"",		"",		/* 121 */
	NONE,	"",		"",		"",		/* 122 */
	NONE,	"",		"",		"",		/* 123 */
	NONE,	"",		"",		"",		/* 124 */
	NONE,	"",		"",		"",		/* 125 */
	NONE,	"",		"",		"",		/* 126 */
	NONE,	"",		"",		"",		/* 127 */
};


void
update_led()
{
	int response;

	if (kbd_cmd(KBC_STSIND) != 0) {
		printf("Timeout for keyboard LED command\n");
	} else {
		/*
		 * XXX This is quite questionable, but seems to fix
		 * the problem reported.
		 * some keyboard controllers need some time after they
		 * get a command.  Without this the keyboard 'hangs'.
		 * This seems to be the only place where two commands
		 * are just one behind another. 
		 */
		DELAY (10000);

		if (kbd_cmd(scroll | (num << 1) | (caps << 2)) != 0)
			printf("Timeout for keyboard LED data\n");
	}
#if 0
	else if ((response = kbd_response()) < 0)
		printf("Timeout for keyboard LED ack\n");
	else if (response != KBR_ACK)
		printf("Unexpected keyboard LED ack %d\n", response);
#else
	/*
	 * Skip waiting for and checking the response.  The waiting
	 * would be too long (about 3 msec) and the checking might eat
	 * fresh keystrokes.  The waiting should be done using timeout()
	 * and the checking should be done in the interrupt handler.
	 */
#endif
}

/*
 *   sgetc(noblock):  get  characters  from  the  keyboard.  If
 *   noblock  ==  0  wait  until a key is gotten. Otherwise return a
 *    if no characters are present 0.
 */
char *
sgetc(noblock)
	int noblock;
{
	u_char		dt;
	unsigned	key;
	static u_char	extended = 0;
	static char	capchar[2];

	/*
	 *   First see if there is something in the keyboard port
	 */
loop:
#ifdef XSERVER						/* 15 Aug 92*/
	if (inb(KBSTATP) & KBS_DIB) {
		dt = inb(KBDATAP);
#ifdef REVERSE_CAPS_CTRL
		/* switch the caps lock and control keys */
		if ((dt & 0x7f) == 29)
			dt = (dt & 0x80) | 58;
		else
			if ((dt & 0x7f) == 58)
				dt = (dt & 0x80) | 29;
#endif
		if (pc_xmode) {
			capchar[0] = dt;
			/*
			 *   Check for locking keys
			 */
			if (!(dt & 0x80))
			{
				dt = dt & 0x7f;
				switch (scan_codes[dt].type)
				{
					case NUM:
						num ^= 1;
						update_led();
						break;
					case CAPS:
						caps ^= 1;
						update_led();
						break;
					case SCROLL:
						scroll ^= 1;
						update_led();
						break;
				}
			}
			return (&capchar[0]);
		}
	}
#else	/* !XSERVER*/
	if (inb(KBSTATP) & KBS_DIB) {
		dt = inb(KBDATAP);
#ifdef REVERSE_CAPS_CTRL
		/* switch the caps lock and control keys */
		if ((dt & 0x7f) == 29)
			dt = (dt & 0x80) | 58;
		else
			if ((dt & 0x7f) == 58)
				dt = (dt & 0x80) | 29;
#endif
	}
#endif /* !XSERVER*/
	else
	{
		if (noblock)
			return 0;
		else
			goto loop;
	}

	if (dt == 0xe0)
	{
		extended = 1;
#ifdef XSERVER						/* 15 Aug 92*/
		goto loop;
#else	/* !XSERVER*/
		if (noblock)
			return 0;
		else
			goto loop;
#endif /* !XSERVER*/
	}

	/*
	 *   Check for cntl-alt-del
	 */
	if ((dt == 83) && ctrl_down && alt_down)
		cpu_reset();

#include "ddb.h"
#if NDDB > 0
	/*
	 *   Check for cntl-alt-esc
	 */
	if ((dt == 1) && ctrl_down && alt_down) {
		Debugger("manual escape to debugger");
		goto loop;
	}
#endif

	/*
	 *   Check for make/break
	 */
	if (dt & 0x80)
	{
		/*
		 *   break
		 */
		dt = dt & 0x7f;
		switch (scan_codes[dt].type)
		{
			case SHIFT:
				shift_down = 0;
				break;
			case ALT:
				alt_down = 0;
				break;
			case CTL:
				ctrl_down = 0;
				break;
		}
	}
	else
	{
		/*
		 *   Make
		 */
		dt = dt & 0x7f;
		switch (scan_codes[dt].type)
		{
			/*
			 *   Locking keys
			 */
			case NUM:
				num ^= 1;
				update_led();
				break;
			case CAPS:
				caps ^= 1;
				update_led();
				break;
			case SCROLL:
				scroll ^= 1;
				update_led();
				break;

			/*
			 *   Non-locking keys
			 */
			case SHIFT:
				shift_down = 1;
				break;
			case ALT:
				alt_down = 0x80;
				break;
			case CTL:
				ctrl_down = 1;
				break;
			case ASCII:
#ifdef XSERVER						/* 15 Aug 92*/
/*
 * 18 Sep 92	Terry Lambert	I find that this behaviour is questionable --
 *				I believe that this should be conditional on
 *				the value of pc_xmode rather than always
 *				done.  In particular, "case NONE" seems to
 *				not cause a scancode return.  This may
 *				invalidate alt-"=" and alt-"-" as well as the
 *				F11 and F12 keys, and some keys on lap-tops,
 *				Especially Toshibal T1100 and Epson Equity 1
 *				and Equity 1+ when not in pc_xmode.
 */
				/* control has highest priority */
				if (ctrl_down)
					capchar[0] = scan_codes[dt].ctrl[0];
				else if (shift_down)
					capchar[0] = scan_codes[dt].shift[0];
				else
					capchar[0] = scan_codes[dt].unshift[0];

				if (caps && (capchar[0] >= 'a'
					 && capchar[0] <= 'z')) {
					capchar[0] = capchar[0] - ('a' - 'A');
				}
				capchar[0] |= alt_down;
				extended = 0;
				return(&capchar[0]);
#else	/* !XSERVER*/
			case NONE:
#endif	/* !XSERVER*/
			case FUNC:
				if (shift_down)
					more_chars = scan_codes[dt].shift;
				else if (ctrl_down)
					more_chars = scan_codes[dt].ctrl;
				else
					more_chars = scan_codes[dt].unshift;
#ifndef XSERVER						/* 15 Aug 92*/
				/* XXX */
				if (caps && more_chars[1] == 0
					&& (more_chars[0] >= 'a'
						&& more_chars[0] <= 'z')) {
					capchar[0] = *more_chars - ('a' - 'A');
					more_chars = capchar;
				}
#endif	/* !XSERVER*/
				extended = 0;
				return(more_chars);
			case KP:
				if (shift_down || ctrl_down || !num || extended)
					more_chars = scan_codes[dt].shift;
				else
					more_chars = scan_codes[dt].unshift;
				extended = 0;
				return(more_chars);
#ifdef XSERVER						/* 15 Aug 92*/
			case NONE:
				break;
#endif	/* XSERVER*/
		}
	}
	extended = 0;
#ifdef XSERVER						/* 15 Aug 92*/
	goto loop;
#else	/* !XSERVER*/
	if (noblock)
		return 0;
	else
		goto loop;
#endif	/* !XSERVER*/
}

/* special characters */
#define bs	8
#define lf	10	
#define cr	13	
#define cntlc	3	
#define del	0177	
#define cntld	4

int
getchar()
{
	char	thechar;
	register	delay;
	int		x;

	pcconsoftc.cs_flags |= CSF_POLLING;
	x = splhigh();
	sput('>', 1);
	/*while (1) {*/
		thechar = *(sgetc(0));
		pcconsoftc.cs_flags &= ~CSF_POLLING;
		splx(x);
		switch (thechar) {
		    default: if (thechar >= ' ')
			     	sput(thechar, 1);
			     return(thechar);
		    case cr:
		    case lf: sput('\r', 1);
		    		sput('\n', 1);
			     return(lf);
		    case bs:
		    case del:
			     sput('\b', 1);
			     sput(' ', 1);
			     sput('\b', 1);
			     return(thechar);
		    case cntlc:
			     sput('^', 1) ; sput('C', 1) ; sput('\r', 1) ; sput('\n', 1) ;
			     cpu_reset();
		    case cntld:
			     sput('^', 1) ; sput('D', 1) ; sput('\r', 1) ; sput('\n', 1) ;
			     return(0);
		}
	/*}*/
}

#include "machine/stdarg.h"
static nrow;

#define	DPAUSE 1
void
#ifdef __STDC__
dprintf(unsigned flgs, const char *fmt, ...)
#else
dprintf(flgs, fmt /*, va_alist */)
        char *fmt;
	unsigned flgs;
#endif
{	extern unsigned __debug;
	va_list ap;

	if((flgs&__debug) > DPAUSE) {
		__color = ffs(flgs&__debug)+1;
		va_start(ap,fmt);
		kprintf(fmt, 1, (struct tty *)0, ap);
		va_end(ap);
	if (flgs&DPAUSE || nrow%24 == 23) { 
		int x;
		x = splhigh();
		if (nrow%24 == 23) nrow = 0;
		(void)sgetc(0);
		splx(x);
	}
	}
	__color = 0;
}

void
consinit() {}

/* -hv- 22-Apr-93: to make init_main more portable */
void cons_highlight() 
{
	/* pc text attribute */
	vs.kern_fg_at = 0x0f;
	vs.kern_bg_at = 0x00;
}

void cons_normal() 
{
	/* reset to normal attributes */
	vs.bg_at = BG_BLACK;
	/* we are in kernel mode */
	vs.fg_at = vs.color? FG_LIGHTGREY: FG_UNDERLINE;
}

int pcmmap(dev_t dev, int offset, int nprot)
{
	if (offset > 0x20000 - PAGE_SIZE)
		return -1;
	return i386_btop((0xa0000 + offset));
}

#ifdef XSERVER						/* 15 Aug 92*/
#include "machine/psl.h"
#include "machine/frame.h"

static void
pc_xmode_on (void)
{
	struct trapframe *fp;

	if (pc_xmode)
		return;
	pc_xmode = 1;

	fp = (struct trapframe *)curproc->p_regs;
	fp->tf_eflags |= PSL_IOPL;
}

static void
pc_xmode_off ()
{
	struct trapframe *fp;

	if (pc_xmode == 0)
		return;
	pc_xmode = 0;

	cursor(0, 0);

	fp = (struct trapframe *)curproc->p_regs;
	fp->tf_eflags &= ~PSL_IOPL;
}
#endif	/* XSERVER*/

/*
 * EOF -- File has not been truncated
 */
