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
top_srcdir = ../..

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

top_builddir = ../..

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

LIBTOOL = $(PERL_LIBTOOL)

moduledir = $(libdir)/irssi/modules

perl_dirs = common irc ui textui

module_LTLIBRARIES = $(perl_module_lib) $(perl_module_fe_lib)
noinst_LTLIBRARIES = $(perl_static_lib) $(perl_static_fe_lib)
EXTRA_LTLIBRARIES =  	libperl_core.la libfe_perl.la 	libperl_core_static.la libfe_perl_static.la


libperl_core_la_LDFLAGS = -avoid-version -rpath $(moduledir)
libfe_perl_la_LDFLAGS = -avoid-version -rpath $(moduledir)

INCLUDES =  	-I$(top_srcdir)/src 	-I$(top_srcdir)/src/core 	-I$(top_srcdir)/src/fe-common/core 	$(GLIB_CFLAGS) 	-DSCRIPTDIR=\""$(datadir)/irssi/scripts"\" 	-DPERL_USE_LIB=\""$(PERL_USE_LIB)"\" 	-DPERL_STATIC_LIBS=$(PERL_STATIC_LIBS) 	$(PERL_CFLAGS)


perl_sources =  	perl-core.c 	perl-common.c 	perl-signals.c 	perl-sources.c


perl_fe_sources =  	module-formats.c 	perl-fe.c


noinst_HEADERS =  	module.h 	module-fe.h 	module-formats.h 	perl-core.h 	perl-common.h 	perl-signals.h 	perl-sources.h


libperl_core_la_DEPENDENCIES = .libs/libperl_orig.a .libs/DynaLoader.a

libperl_core_la_SOURCES =  	$(perl_sources)


libperl_core_static_la_SOURCES =  	$(perl_sources)


libfe_perl_la_SOURCES =  	$(perl_fe_sources)


libfe_perl_static_la_SOURCES =  	$(perl_fe_sources)


common_sources =  	common/Irssi.xs 	common/Irssi.pm 	common/Channel.xs 	common/Core.xs 	common/Expando.xs 	common/Ignore.xs 	common/Log.xs 	common/Masks.xs 	common/Query.xs 	common/Rawlog.xs 	common/Server.xs 	common/Settings.xs 	common/Makefile.PL.in 	common/typemap 	common/module.h


irc_sources =  	irc/Irc.xs 	irc/Irc.pm 	irc/Dcc.xs 	irc/Channel.xs 	irc/Ctcp.xs 	irc/Query.xs 	irc/Server.xs 	irc/Modes.xs 	irc/Netsplit.xs 	irc/Notifylist.xs 	irc/Makefile.PL.in 	irc/typemap 	irc/module.h


ui_sources =  	ui/UI.xs 	ui/UI.pm 	ui/Formats.xs 	ui/Themes.xs 	ui/Window.xs 	ui/Makefile.PL.in 	ui/typemap 	ui/module.h


textui_sources =  	textui/TextUI.xs 	textui/TextUI.pm 	textui/TextBuffer.xs 	textui/TextBufferView.xs 	textui/Statusbar.xs 	textui/Makefile.PL.in 	textui/typemap 	textui/module.h


EXTRA_DIST =  	libperl_dynaloader.la 	libperl_orig.la 	get-signals.pl 	irssi-core.pl 	$(common_sources) 	$(irc_sources) 	$(ui_sources) 	$(textui_sources)


libperl_core_la_LIBADD = $(PERL_LDFLAGS)
mkinstalldirs = $(SHELL) $(top_srcdir)/mkinstalldirs
CONFIG_HEADER = ../../config.h
CONFIG_CLEAN_FILES = 
LTLIBRARIES =  $(module_LTLIBRARIES) $(noinst_LTLIBRARIES)


DEFS = -DHAVE_CONFIG_H -I. -I$(srcdir) -I../..
CPPFLAGS = 
LDFLAGS = 
LIBS = 
libperl_core_la_OBJECTS =  perl-core.lo perl-common.lo perl-signals.lo \
perl-sources.lo
libfe_perl_la_LIBADD = 
libfe_perl_la_OBJECTS =  module-formats.lo perl-fe.lo
libperl_core_static_la_LDFLAGS = 
libperl_core_static_la_LIBADD = 
libperl_core_static_la_OBJECTS =  perl-core.lo perl-common.lo \
perl-signals.lo perl-sources.lo
libfe_perl_static_la_LDFLAGS = 
libfe_perl_static_la_LIBADD = 
libfe_perl_static_la_OBJECTS =  module-formats.lo perl-fe.lo
CFLAGS = -g -O2 -Wall
COMPILE = $(CC) $(DEFS) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
LTCOMPILE = $(LIBTOOL) --mode=compile $(CC) $(DEFS) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
CCLD = $(CC)
LINK = $(LIBTOOL) --mode=link $(CCLD) $(AM_CFLAGS) $(CFLAGS) $(LDFLAGS) -o $@
HEADERS =  $(noinst_HEADERS)

DIST_COMMON =  Makefile.am Makefile.in


DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS) $(TEXINFOS) $(EXTRA_DIST)

TAR = tar
GZIP_ENV = --best
SOURCES = $(libperl_core_la_SOURCES) $(libfe_perl_la_SOURCES) $(libperl_core_static_la_SOURCES) $(libfe_perl_static_la_SOURCES)
OBJECTS = $(libperl_core_la_OBJECTS) $(libfe_perl_la_OBJECTS) $(libperl_core_static_la_OBJECTS) $(libfe_perl_static_la_OBJECTS)

all: all-redirect
.SUFFIXES:
.SUFFIXES: .S .c .lo .o .obj .s
$(srcdir)/Makefile.in: # Makefile.am $(top_srcdir)/configure.in $(ACLOCAL_M4) 
	cd $(top_srcdir) && $(AUTOMAKE) --gnu --include-deps src/perl/Makefile

Makefile: $(srcdir)/Makefile.in  $(top_builddir)/config.status
	cd $(top_builddir) \
	  && CONFIG_FILES=$(subdir)/$@ CONFIG_HEADERS= $(SHELL) ./config.status


mostlyclean-moduleLTLIBRARIES:

clean-moduleLTLIBRARIES:
	-test -z "$(module_LTLIBRARIES)" || rm -f $(module_LTLIBRARIES)

distclean-moduleLTLIBRARIES:

maintainer-clean-moduleLTLIBRARIES:

install-moduleLTLIBRARIES: $(module_LTLIBRARIES)
	@$(NORMAL_INSTALL)
	$(mkinstalldirs) $(DESTDIR)$(moduledir)
	@list='$(module_LTLIBRARIES)'; for p in $$list; do \
	  if test -f $$p; then \
	    echo "$(LIBTOOL)  --mode=install $(INSTALL) $$p $(DESTDIR)$(moduledir)/$$p"; \
	    $(LIBTOOL)  --mode=install $(INSTALL) $$p $(DESTDIR)$(moduledir)/$$p; \
	  else :; fi; \
	done

uninstall-moduleLTLIBRARIES:
	@$(NORMAL_UNINSTALL)
	list='$(module_LTLIBRARIES)'; for p in $$list; do \
	  $(LIBTOOL)  --mode=uninstall rm -f $(DESTDIR)$(moduledir)/$$p; \
	done

mostlyclean-noinstLTLIBRARIES:

clean-noinstLTLIBRARIES:
	-test -z "$(noinst_LTLIBRARIES)" || rm -f $(noinst_LTLIBRARIES)

distclean-noinstLTLIBRARIES:

maintainer-clean-noinstLTLIBRARIES:

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

libperl_core.la: $(libperl_core_la_OBJECTS) $(libperl_core_la_DEPENDENCIES)
	$(LINK)  $(libperl_core_la_LDFLAGS) $(libperl_core_la_OBJECTS) $(libperl_core_la_LIBADD) $(LIBS)

libfe_perl.la: $(libfe_perl_la_OBJECTS) $(libfe_perl_la_DEPENDENCIES)
	$(LINK)  $(libfe_perl_la_LDFLAGS) $(libfe_perl_la_OBJECTS) $(libfe_perl_la_LIBADD) $(LIBS)

libperl_core_static.la: $(libperl_core_static_la_OBJECTS) $(libperl_core_static_la_DEPENDENCIES)
	$(LINK)  $(libperl_core_static_la_LDFLAGS) $(libperl_core_static_la_OBJECTS) $(libperl_core_static_la_LIBADD) $(LIBS)

libfe_perl_static.la: $(libfe_perl_static_la_OBJECTS) $(libfe_perl_static_la_DEPENDENCIES)
	$(LINK)  $(libfe_perl_static_la_LDFLAGS) $(libfe_perl_static_la_OBJECTS) $(libfe_perl_static_la_LIBADD) $(LIBS)

tags: TAGS

ID: $(HEADERS) $(SOURCES) $(LISP)
	list='$(SOURCES) $(HEADERS)'; \
	unique=`for i in $$list; do echo $$i; done | \
	  awk '    { files[$$0] = 1; } \
	       END { for (i in files) print i; }'`; \
	here=`pwd` && cd $(srcdir) \
	  && mkid -f$$here/ID $$unique $(LISP)

TAGS:  $(HEADERS) $(SOURCES)  $(TAGS_DEPENDENCIES) $(LISP)
	tags=; \
	here=`pwd`; \
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

subdir = src/perl

distdir: $(DISTFILES)
	$(mkinstalldirs) $(distdir)/common $(distdir)/irc $(distdir)/textui \
	   $(distdir)/ui
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

info-am:
info: info-am
dvi-am:
dvi: dvi-am
check-am: all-am
check: check-am
installcheck-am:
installcheck: installcheck-am
install-exec-am: install-exec-local
install-exec: install-exec-am

install-data-am: install-moduleLTLIBRARIES
install-data: install-data-am

install-am: all-am
	@$(MAKE) $(AM_MAKEFLAGS) install-exec-am install-data-am
install: install-am
uninstall-am: uninstall-moduleLTLIBRARIES
uninstall: uninstall-am
all-am: Makefile $(LTLIBRARIES) $(HEADERS) all-local
all-redirect: all-am
install-strip:
	$(MAKE) $(AM_MAKEFLAGS) AM_INSTALL_PROGRAM_FLAGS=-s install
installdirs:
	$(mkinstalldirs)  $(DESTDIR)$(moduledir)


mostlyclean-generic:

maintainer-clean-generic:
mostlyclean-am:  mostlyclean-moduleLTLIBRARIES \
		mostlyclean-noinstLTLIBRARIES mostlyclean-compile \
		mostlyclean-libtool mostlyclean-tags \
		mostlyclean-generic

mostlyclean: mostlyclean-am

clean-am:  clean-moduleLTLIBRARIES clean-noinstLTLIBRARIES clean-compile \
		clean-libtool clean-tags clean-generic mostlyclean-am

clean: clean-am

distclean-am:  distclean-moduleLTLIBRARIES distclean-noinstLTLIBRARIES \
		distclean-compile distclean-libtool distclean-tags \
		distclean-generic clean-am
	-rm -f libtool

distclean: distclean-am

maintainer-clean-am:  maintainer-clean-moduleLTLIBRARIES \
		maintainer-clean-noinstLTLIBRARIES \
		maintainer-clean-compile maintainer-clean-libtool \
		maintainer-clean-tags maintainer-clean-generic \
		distclean-am
	@echo "This command is intended for maintainers to use;"
	@echo "it deletes files that may require special tools to rebuild."

maintainer-clean: maintainer-clean-am

.PHONY: mostlyclean-moduleLTLIBRARIES distclean-moduleLTLIBRARIES \
clean-moduleLTLIBRARIES maintainer-clean-moduleLTLIBRARIES \
uninstall-moduleLTLIBRARIES install-moduleLTLIBRARIES \
mostlyclean-noinstLTLIBRARIES distclean-noinstLTLIBRARIES \
clean-noinstLTLIBRARIES maintainer-clean-noinstLTLIBRARIES \
mostlyclean-compile distclean-compile clean-compile \
maintainer-clean-compile mostlyclean-libtool distclean-libtool \
clean-libtool maintainer-clean-libtool tags mostlyclean-tags \
distclean-tags clean-tags maintainer-clean-tags distdir info-am info \
dvi-am dvi check check-am installcheck-am installcheck \
install-exec-local install-exec-am install-exec install-data-am \
install-data install-am install uninstall-am uninstall all-local \
all-redirect all-am all installdirs mostlyclean-generic \
distclean-generic clean-generic maintainer-clean-generic clean \
mostlyclean distclean maintainer-clean


perl-core.c: perl-signals-list.h irssi-core.pl.h

.libs/libperl_orig.a:
	if [ ! -d .libs ]; then mkdir .libs; fi
	rm -f .libs/libperl_orig.a
	if [ x$(LIBPERL_A) = x ]; then touch .libs/libperl_orig.a; else $(LN_S) $(LIBPERL_A) .libs/libperl_orig.a; fi
.libs/DynaLoader.a:
	if [ ! -d .libs ]; then mkdir .libs; fi
	rm -f .libs/DynaLoader.a
	$(LN_S) $(DYNALOADER_A) .libs/DynaLoader.a

perl-signals-list.h: $(top_srcdir)/docs/signals.txt $(srcdir)/get-signals.pl
	cat $(top_srcdir)/docs/signals.txt | $(perlpath) $(srcdir)/get-signals.pl > perl-signals-list.h

irssi-core.pl.h: irssi-core.pl
	$(top_srcdir)/file2header.sh $(srcdir)/irssi-core.pl irssi_core_code > irssi-core.pl.h

all-local:
	for dir in $(perl_dirs); do \
	  cd $$dir && \
	  if [ ! -f Makefile ]; then \
	    $(perlpath) Makefile.PL $(PERL_MM_PARAMS); \
	  fi && \
	  ($(MAKE) CC="$(CC)" CCFLAGS="$(PERL_CFLAGS) $(CFLAGS)" $(PERL_EXTRA_OPTS) || \
	   $(MAKE) CC="$(CC)" CCFLAGS="$(PERL_CFLAGS) $(CFLAGS)" $(PERL_EXTRA_OPTS)) && \
	  cd ..; \
	done

install-exec-local:
	for dir in $(perl_dirs); do \
	  cd $$dir && $(MAKE) install && cd ..; \
	done

clean-generic:
	for dir in $(perl_dirs); do \
	  cd $$dir; \
	  $(MAKE) clean; \
	  cd ..; \
	done

distclean-generic:
	for dir in $(perl_dirs); do \
	  cd $$dir; \
	  $(MAKE) realclean; rm -f Makefile.PL Makefile; \
	  cd ..; \
	done

# Tell versions [3.59,3.63) of GNU make to not export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:
