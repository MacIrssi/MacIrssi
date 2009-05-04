/*
 printd.h
 Copyright (c) 2008, 2009 Matt Wright, 2008 Nils Hjelte.
 
 MacIrssi is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef PRINTD_H
#define PRINTD_H

/* general debug facility */
#ifndef DEBUG
#define printd(x...)
#else
void printd(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);

    fprintf(stderr, "DEBUG: ");
    vfprintf(stderr, fmt, ap);

    va_end(ap);
}
#endif /* DEBUG */

#endif /* PRINTD_H */