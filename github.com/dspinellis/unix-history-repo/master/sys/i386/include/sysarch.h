/*
 * Architecture specific syscalls (i386)
 *
 *	$Id: sysarch.h,v 1.2 1993/10/16 14:39:35 rgrimes Exp $
 */
#ifndef _MACHINE_SYSARCH_H_
#define _MACHINE_SYSARCH_H_ 1

#include <sys/cdefs.h>

#define I386_GET_LDT	0
#define I386_SET_LDT	1

#ifdef KERNEL
/* nothing here yet... */
#else /* not KERNEL */
__BEGIN_DECLS

int i386_get_ldt __P((int, union descriptor *, int));
int i386_set_ldt __P((int, union descriptor *, int));

__END_DECLS
#endif /* not KERNEL */
#endif /* _MACHINE_SYSARCH_H_ */
