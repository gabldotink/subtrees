/* lineno.c
   Return the saved line number.

   Copyright (C) 1992 Ian Lance Taylor

   This file is part of the Taylor UUCP uuconf library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License
   as published by the Free Software Foundation; either version 2 of
   the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

   The author of the program may be contacted at ian@airs.com or
   c/o Cygnus Support, Building 200, 1 Kendall Square, Cambridge, MA 02139.
   */

#include "uucnfi.h"

#if USE_RCS_ID
const char _uuconf_lineno_rcsid[] = "$Id: lineno.c,v 1.3 1994/01/30 21:14:29 ian Rel $";
#endif

/* Return the saved line number.  */

int
uuconf_error_lineno (pglobal)
     pointer pglobal;
{
  struct sglobal *qglobal = (struct sglobal *) pglobal;

  if (qglobal == NULL)
    return 0;
  else
    return qglobal->ilineno;
}
