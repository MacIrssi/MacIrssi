# Makefile.in generated automatically by automake 1.4-p6 from Makefile.am

# Copyright (C) 1994, 1995-8, 1999, 2001 Free Software Foundation, Inc.
# This Makefile.in is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.


SHELL = /bin/sh

srcdir = .
top_srcdir = ../../..

prefix = /usr/local
exec_prefix = ${prefix}

bindir = ${exec_prefix}/bin
sbindir = ${exec_prefix}/sbin
libexecdir = ${exec_prefix}/libexec
datadir = ${prefix}/share
sysconfdir = ${prefix}/etc
sharedstatedir = ${prefix}/com
localstatedir = ${prefix}/var
libdir = ${exec_prefix}/lib
infodir = ${prefix}/info
mandir = ${prefix}/man
includedir = ${prefix}/include
oldincludedir = /usr/include

DESTDIR =

pkgdatadir = $(datadir)/irssi
pkglibdir = $(libdir)/irssi
pkgincludedir = $(includedir)/irssi

top_builddir = ../../..

ACLOCAL = /Users/kolis/Projects/MacIrssi/irssi-0.8.9/missing aclocal-1.4
AUTOCONF = autoconf
AUTOMAKE = /Users/kolis/Projects/MacIrssi/irssi-0.8.9/missing automake-1.4
AUTOHEADER = autoheader

INSTALL = /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL} $(AM_INSTALL_PROGRAM_FLAGS)
INSTALL_DATA = ${INSTALL} -m 644
INSTALL_SCRIPT = ${INSTALL}
transform = s,x,x,

NORMAL_INSTALL = :
PRE_INSTALL = :
POST_INSTALL = :
NORMAL_UNINSTALL = :
PRE_UNINSTALL = :
POST_UNINSTALL = :
host_alias = 
host_triplet = powerpc-apple-darwin8.2.0
AR = ar
AS = @AS@
CC = gcc
CHAT_MODULES = irc
COMMON_LIBS = ../fe-common/irc/libfe_common_irc.a ../fe-common/irc/dcc/libfe_irc_dcc.a ../fe-common/irc/notifylist/libfe_irc_notifylist.a ../fe-common/core/libfe_common_core.a  ../irc/libirc.a ../irc/core/libirc_core.a ../irc/dcc/libirc_dcc.a ../irc/flood/libirc_flood.a ../irc/notifylist/libirc_notifylist.a ../core/libcore.a ../lib-config/libirssi_config.a ../lib-popt/libpopt.a
COMMON_NOUI_LIBS =  ../irc/libirc.a ../irc/core/libirc_core.a ../irc/dcc/libirc_dcc.a ../irc/flood/libirc_flood.a ../irc/notifylist/libirc_notifylist.a ../core/libcore.a ../lib-config/libirssi_config.a ../lib-popt/libpopt.a
CPP = gcc -E
CURSES_INCLUDEDIR = 
CURSES_LIBS = 
CXX = g++
CXXCPP = g++ -E
DLLTOOL = @DLLTOOL@
DYNALOADER_A = 
ECHO = echo
EGREP = grep -E
EXEEXT = 
F77 = 
GCJ = @GCJ@
GCJFLAGS = @GCJFLAGS@
GLIB_CFLAGS = -I/sw/include/glib-2.0 -I/sw/lib/glib-2.0/include  
GLIB_CONFIG = 
GLIB_GENMARSHAL = glib-genmarshal
GLIB_LIBS = -L/sw/lib -lgmodule-2.0 -lglib-2.0 -lintl -liconv  
GLIB_MKENUMS = glib-mkenums
GOBJECT_QUERY = gobject-query
LIBPERL_A = 
LIBTOOL = $(SHELL) $(top_builddir)/libtool
LN_S = ln -s
MAINT = #
MAKEINFO = makeinfo
OBJDUMP = @OBJDUMP@
OBJEXT = o
PACKAGE = irssi
PERL_CFLAGS = -g -pipe -fno-common -DPERL_DARWIN -no-cpp-precomp -fno-strict-aliasing -I/usr/local/include -I/System/Library/Perl/5.8.6/darwin-thread-multi-2level/CORE
PERL_EXTRA_OPTS = CCCDLFLAGS="-fPIC"
PERL_FE_LINK_LIBS = ../perl/libfe_perl_static.la
PERL_LDFLAGS = 
PERL_LIBTOOL = $(SHELL) $(top_builddir)/libtool
PERL_LINK_FLAGS = -L/usr/local/lib /System/Library/Perl/5.8.6/darwin-thread-multi-2level/auto/DynaLoader/DynaLoader.a -L/System/Library/Perl/5.8.6/darwin-thread-multi-2level/CORE -lperl -ldl -lm
PERL_LINK_LIBS = ../perl/libperl_core_static.la
PERL_MM_PARAMS = 
PERL_STATIC_LIBS = 0
PERL_USE_LIB = 
PKG_CONFIG = /sw/bin/pkg-config
PROG_LIBS =  -L/sw/lib -lgmodule-2.0 -lglib-2.0 -lintl -liconv   -lssl -lcrypto
RANLIB = ranlib
RC = @RC@
SSL_LIBS = -lssl -lcrypto
STRIP = strip
TEXTUI_LIBS = 
VERSION = 0.8.9
VERSION_DATE = 20031210
VERSION_TIME = 2316
irc_MODULES = dcc flood notifylist
perl_module_fe_lib = 
perl_module_lib = 
perl_static_fe_lib = libfe_perl_static.la
perl_static_lib = libperl_core_static.la
perlpath = /usr/bin/perl
sedpath = /usr/bin/sed

SUBDIRS = dcc notifylist

noinst_LIBRARIES = libfe_common_irc.a

INCLUDES =  	-I$(top_srcdir)/src 	-I$(top_srcdir)/src/core/ 	-I$(top_srcdir)/src/irc/core/ 	-I$(top_srcdir)/src/fe-common/core/ 	$(GLIB_CFLAGS) 	-DHELPDIR=\""$(datadir)/irssi/help"\" 	-DSYSCONFDIR=\""$(sysconfdir)"\"


real_sources =  	fe-irc-channels.c 	fe-irc-commands.c 	fe-irc-messages.c 	fe-irc-queries.c 	fe-irc-server.c 	fe-ircnet.c 	fe-ctcp.c 	fe-events.c 	fe-events-numeric.c 	fe-modes.c 	fe-netjoin.c 	fe-netsplit.c 	fe-common-irc.c 	irc-completion.c 	module-formats.c 


libfe_common_irc_a_SOURCES =  	$(real_sources)         irc-modules.c


noinst_HEADERS =  	fe-irc-server.h 	module.h 	module-formats.h


DISTFILES = $(DIST_COMMON) $(real_sources) $(HEADERS) $(TEXINFOS) $(EXTRA_DIST)
mkinstalldirs = $(SHELL) $(top_srcdir)/mkinstalldirs
CONFIG_HEADER = ../../../config.h
CONFIG_CLEAN_FILES = 
LIBRARIES =  $(noinst_LIBRARIES)


DEFS = -DHAVE_CONFIG_H -I. -I$(srcdir) -I../../..
CPPFLAGS = 
LDFLAGS = 
LIBS = 
libfe_common_irc_a_LIBADD = 
libfe_common_irc_a_OBJECTS =  fe-irc-channels.$(OBJEXT) \
fe-irc-commands.$(OBJEXT) fe-irc-messages.$(OBJEXT) \
fe-irc-queries.$(OBJEXT) fe-irc-server.$(OBJEXT) fe-ircnet.$(OBJEXT) \
fe-ctcp.$(OBJEXT) fe-events.$(OBJEXT) fe-events-numeric.$(OBJEXT) \
fe-modes.$(OBJEXT) fe-netjoin.$(OBJEXT) fe-netsplit.$(OBJEXT) \
fe-common-irc.$(OBJEXT) irc-completion.$(OBJEXT) \
module-formats.$(OBJEXT) irc-modules.$(OBJEXT)
CFLAGS = -g -O2 -Wall
COMPILE = $(CC) $(DEFS) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
LTCOMPILE = $(LIBTOOL) --mode=compile $(CC) $(DEFS) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
CCLD = $(CC)
LINK = $(LIBTOOL) --mode=link $(CCLD) $(AM_CFLAGS) $(CFLAGS) $(LDFLAGS) -o $@
HEADERS =  $(noinst_HEADERS)

DIST_COMMON =  Makefile.am Makefile.in


TAR = tar
GZIP_ENV = --best
SOURCES = $(libfe_common_irc_a_SOURCES)
OBJECTS = $(libfe_common_irc_a_OBJECTS)

all: all-redirect
.SUFFIXES:
.SUFFIXES: .S .c .lo .o .obj .s
$(srcdir)/Makefile.in: # Makefile.am $(top_srcdir)/configure.in $(ACLOCAL_M4) 
	cd $(top_srcdir) && $(AUTOMAKE) --gnu --include-deps src/fe-common/irc/Makefile

Makefile: $(srcdir)/Makefile.in  $(top_builddir)/config.status
	cd $(top_builddir) \
	  && CONFIG_FILES=$(subdir)/$@ CONFIG_HEADERS= $(SHELL) ./config.status


mostlyclean-noinstLIBRARIES:

clean-noinstLIBRARIES:
	-test -z "$(noinst_LIBRARIES)" || rm -f $(noinst_LIBRARIES)

distclean-noinstLIBRARIES:

maintainer-clean-noinstLIBRARIES:

.c.o:
	$(COMPILE) -c $<

# FIXME: We should only use cygpath when building on Windows,
# and only if it is available.
.c.obj:
	$(COMPILE) -c `cygpath -w $<`

.s.o:
	$(COMPILE) -c $<

.S.o:
	$(COMPILE) -c $<

mostlyclean-compile:
	-rm -f *.o core *.core
	-rm -f *.$(OBJEXT)

clean-compile:

distclean-compile:
	-rm -f *.tab.c

maintainer-clean-compile:

.c.lo:
	$(LIBTOOL) --mode=compile $(COMPILE) -c $<

.s.lo:
	$(LIBTOOL) --mode=compile $(COMPILE) -c $<

.S.lo:
	$(LIBTOOL) --mode=compile $(COMPILE) -c $<

mostlyclean-libtool:
	-rm -f *.lo

clean-libtool:
	-rm -rf .libs _libs

distclean-libtool:

maintainer-clean-libtool:

libfe_common_irc.a: $(libfe_common_irc_a_OBJECTS) $(libfe_common_irc_a_DEPENDENCIES)
	-rm -f libfe_common_irc.a
	$(AR) cru libfe_common_irc.a $(libfe_common_irc_a_OBJECTS) $(libfe_common_irc_a_LIBADD)
	$(RANLIB) libfe_common_irc.a

# This directory's subdirectories are mostly independent; you can cd
# into them and run `make' without going through this Makefile.
# To change the values of `make' variables: instead of editing Makefiles,
# (1) if the variable is set in `config.status', edit `config.status'
#     (which will cause the Makefiles to be regenerated when you run `make');
# (2) otherwise, pass the desired values on the `make' command line.



all-recursive install-data-recursive install-exec-recursive \
installdirs-recursive install-recursive uninstall-recursive  \
check-recursive installcheck-recursive info-recursive dvi-recursive:
	@set fnord $(MAKEFLAGS); amf=$$2; \
	dot_seen=no; \
	target=`echo $@ | sed s/-recursive//`; \
	list='$(SUBDIRS)'; for subdir in $$list; do \
	  echo "Making $$target in $$subdir"; \
	  if test "$$subdir" = "."; then \
	    dot_seen=yes; \
	    local_target="$$target-am"; \
	  else \
	    local_target="$$target"; \
	  fi; \
	  (cd $$subdir && $(MAKE) $(AM_MAKEFLAGS) $$local_target) \
	   || case "$$amf" in *=*) exit 1;; *k*) fail=yes;; *) exit 1;; esac; \
	done; \
	if test "$$dot_seen" = "no"; then \
	  $(MAKE) $(AM_MAKEFLAGS) "$$target-am" || exit 1; \
	fi; test -z "$$fail"

mostlyclean-recursive clean-recursive distclean-recursive \
maintainer-clean-recursive:
	@set fnord $(MAKEFLAGS); amf=$$2; \
	dot_seen=no; \
	rev=''; list='$(SUBDIRS)'; for subdir in $$list; do \
	  rev="$$subdir $$rev"; \
	  test "$$subdir" != "." || dot_seen=yes; \
	done; \
	test "$$dot_seen" = "no" && rev=". $$rev"; \
	target=`echo $@ | sed s/-recursive//`; \
	for subdir in $$rev; do \
	  echo "Making $$target in $$subdir"; \
	  if test "$$subdir" = "."; then \
	    local_target="$$target-am"; \
	  else \
	    local_target="$$target"; \
	  fi; \
	  (cd $$subdir && $(MAKE) $(AM_MAKEFLAGS) $$local_target) \
	   || case "$$amf" in *=*) exit 1;; *k*) fail=yes;; *) exit 1;; esac; \
	done && test -z "$$fail"
tags-recursive:
	list='$(SUBDIRS)'; for subdir in $$list; do \
	  test "$$subdir" = . || (cd $$subdir && $(MAKE) $(AM_MAKEFLAGS) tags); \
	done

tags: TAGS

ID: $(HEADERS) $(SOURCES) $(LISP)
	list='$(SOURCES) $(HEADERS)'; \
	unique=`for i in $$list; do echo $$i; done | \
	  awk '    { files[$$0] = 1; } \
	       END { for (i in files) print i; }'`; \
	here=`pwd` && cd $(srcdir) \
	  && mkid -f$$here/ID $$unique $(LISP)

TAGS: tags-recursive $(HEADERS) $(SOURCES)  $(TAGS_DEPENDENCIES) $(LISP)
	tags=; \
	here=`pwd`; \
	list='$(SUBDIRS)'; for subdir in $$list; do \
   if test "$$subdir" = .; then :; else \
	    test -f $$subdir/TAGS && tags="$$tags -i $$here/$$subdir/TAGS"; \
   fi; \
	done; \
	list='$(SOURCES) $(HEADERS)'; \
	unique=`for i in $$list; do echo $$i; done | \
	  awk '    { files[$$0] = 1; } \
	       END { for (i in files) print i; }'`; \
	test -z "$(ETAGS_ARGS)$$unique$(LISP)$$tags" \
	  || (cd $(srcdir) && etags -o $$here/TAGS $(ETAGS_ARGS) $$tags  $$unique $(LISP))

mostlyclean-tags:

clean-tags:

distclean-tags:
	-rm -f TAGS ID

maintainer-clean-tags:

distdir = $(top_builddir)/$(PACKAGE)-$(VERSION)/$(subdir)

subdir = src/fe-common/irc

distdir: $(DISTFILES)
	@for file in $(DISTFILES); do \
	  d=$(srcdir); \
	  if test -d $$d/$$file; then \
	    cp -pr $$d/$$file $(distdir)/$$file; \
	  else \
	    test -f $(distdir)/$$file \
	    || ln $$d/$$file $(distdir)/$$file 2> /dev/null \
	    || cp -p $$d/$$file $(distdir)/$$file || :; \
	  fi; \
	done
	for subdir in $(SUBDIRS); do \
	  if test "$$subdir" = .; then :; else \
	    test -d $(distdir)/$$subdir \
	    || mkdir $(distdir)/$$subdir \
	    || exit 1; \
	    chmod 777 $(distdir)/$$subdir; \
	    (cd $$subdir && $(MAKE) $(AM_MAKEFLAGS) top_distdir=../$(top_distdir) distdir=../$(distdir)/$$subdir distdir) \
	      || exit 1; \
	  fi; \
	done

info-am:
info: info-recursive
dvi-am:
dvi: dvi-recursive
check-am: all-am
check: check-recursive
installcheck-am:
installcheck: installcheck-recursive
install-exec-am:
install-exec: install-exec-recursive

install-data-am:
install-data: install-data-recursive

install-am: all-am
	@$(MAKE) $(AM_MAKEFLAGS) install-exec-am install-data-am
install: install-recursive
uninstall-am:
uninstall: uninstall-recursive
all-am: Makefile $(LIBRARIES) $(HEADERS)
all-redirect: all-recursive
install-strip:
	$(MAKE) $(AM_MAKEFLAGS) AM_INSTALL_PROGRAM_FLAGS=-s install
installdirs: installdirs-recursive
installdirs-am:


mostlyclean-generic:

clean-generic:

maintainer-clean-generic:
mostlyclean-am:  mostlyclean-noinstLIBRARIES mostlyclean-compile \
		mostlyclean-libtool mostlyclean-tags \
		mostlyclean-generic

mostlyclean: mostlyclean-recursive

clean-am:  clean-noinstLIBRARIES clean-compile clean-libtool clean-tags \
		clean-generic mostlyclean-am

clean: clean-recursive

distclean-am:  distclean-noinstLIBRARIES distclean-compile \
		distclean-libtool distclean-tags distclean-generic \
		clean-am
	-rm -f libtool

distclean: distclean-recursive

maintainer-clean-am:  maintainer-clean-noinstLIBRARIES \
		maintainer-clean-compile maintainer-clean-libtool \
		maintainer-clean-tags maintainer-clean-generic \
		distclean-am
	@echo "This command is intended for maintainers to use;"
	@echo "it deletes files that may require special tools to rebuild."

maintainer-clean: maintainer-clean-recursive

.PHONY: mostlyclean-noinstLIBRARIES distclean-noinstLIBRARIES \
clean-noinstLIBRARIES maintainer-clean-noinstLIBRARIES \
mostlyclean-compile distclean-compile clean-compile \
maintainer-clean-compile mostlyclean-libtool distclean-libtool \
clean-libtool maintainer-clean-libtool install-data-recursive \
uninstall-data-recursive install-exec-recursive \
uninstall-exec-recursive installdirs-recursive uninstalldirs-recursive \
all-recursive check-recursive installcheck-recursive info-recursive \
dvi-recursive mostlyclean-recursive distclean-recursive clean-recursive \
maintainer-clean-recursive tags tags-recursive mostlyclean-tags \
distclean-tags clean-tags maintainer-clean-tags distdir info-am info \
dvi-am dvi check check-am installcheck-am installcheck install-exec-am \
install-exec install-data-am install-data install-am install \
uninstall-am uninstall all-redirect all-am all installdirs-am \
installdirs mostlyclean-generic distclean-generic clean-generic \
maintainer-clean-generic clean mostlyclean distclean maintainer-clean


distclean-generic:
	rm -f irc-modules.c

# Tell versions [3.59,3.63) of GNU make to not export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:
