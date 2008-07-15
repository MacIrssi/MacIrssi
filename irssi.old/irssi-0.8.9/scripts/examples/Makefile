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

scriptdir = $(datadir)/irssi/scripts

script_DATA =  	command.pl 	msg-event.pl 	redirect.pl


EXTRA_DIST = $(script_DATA)
mkinstalldirs = $(SHELL) $(top_srcdir)/mkinstalldirs
CONFIG_HEADER = ../../config.h
CONFIG_CLEAN_FILES = 
DATA =  $(script_DATA)

DIST_COMMON =  Makefile.am Makefile.in


DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS) $(TEXINFOS) $(EXTRA_DIST)

TAR = tar
GZIP_ENV = --best
all: all-redirect
.SUFFIXES:
$(srcdir)/Makefile.in: # Makefile.am $(top_srcdir)/configure.in $(ACLOCAL_M4) 
	cd $(top_srcdir) && $(AUTOMAKE) --gnu --include-deps scripts/examples/Makefile

Makefile: $(srcdir)/Makefile.in  $(top_builddir)/config.status
	cd $(top_builddir) \
	  && CONFIG_FILES=$(subdir)/$@ CONFIG_HEADERS= $(SHELL) ./config.status


install-scriptDATA: $(script_DATA)
	@$(NORMAL_INSTALL)
	$(mkinstalldirs) $(DESTDIR)$(scriptdir)
	@list='$(script_DATA)'; for p in $$list; do \
	  if test -f $(srcdir)/$$p; then \
	    echo " $(INSTALL_DATA) $(srcdir)/$$p $(DESTDIR)$(scriptdir)/$$p"; \
	    $(INSTALL_DATA) $(srcdir)/$$p $(DESTDIR)$(scriptdir)/$$p; \
	  else if test -f $$p; then \
	    echo " $(INSTALL_DATA) $$p $(DESTDIR)$(scriptdir)/$$p"; \
	    $(INSTALL_DATA) $$p $(DESTDIR)$(scriptdir)/$$p; \
	  fi; fi; \
	done

uninstall-scriptDATA:
	@$(NORMAL_UNINSTALL)
	list='$(script_DATA)'; for p in $$list; do \
	  rm -f $(DESTDIR)$(scriptdir)/$$p; \
	done
tags: TAGS
TAGS:


distdir = $(top_builddir)/$(PACKAGE)-$(VERSION)/$(subdir)

subdir = scripts/examples

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
info-am:
info: info-am
dvi-am:
dvi: dvi-am
check-am: all-am
check: check-am
installcheck-am:
installcheck: installcheck-am
install-exec-am:
install-exec: install-exec-am

install-data-am: install-scriptDATA
install-data: install-data-am

install-am: all-am
	@$(MAKE) $(AM_MAKEFLAGS) install-exec-am install-data-am
install: install-am
uninstall-am: uninstall-scriptDATA
uninstall: uninstall-am
all-am: Makefile $(DATA)
all-redirect: all-am
install-strip:
	$(MAKE) $(AM_MAKEFLAGS) AM_INSTALL_PROGRAM_FLAGS=-s install
installdirs:
	$(mkinstalldirs)  $(DESTDIR)$(scriptdir)


mostlyclean-generic:

clean-generic:

distclean-generic:
	-rm -f Makefile $(CONFIG_CLEAN_FILES)
	-rm -f config.cache config.log stamp-h stamp-h[0-9]*

maintainer-clean-generic:
mostlyclean-am:  mostlyclean-generic

mostlyclean: mostlyclean-am

clean-am:  clean-generic mostlyclean-am

clean: clean-am

distclean-am:  distclean-generic clean-am
	-rm -f libtool

distclean: distclean-am

maintainer-clean-am:  maintainer-clean-generic distclean-am
	@echo "This command is intended for maintainers to use;"
	@echo "it deletes files that may require special tools to rebuild."

maintainer-clean: maintainer-clean-am

.PHONY: uninstall-scriptDATA install-scriptDATA tags distdir info-am \
info dvi-am dvi check check-am installcheck-am installcheck \
install-exec-am install-exec install-data-am install-data install-am \
install uninstall-am uninstall all-redirect all-am all installdirs \
mostlyclean-generic distclean-generic clean-generic \
maintainer-clean-generic clean mostlyclean distclean maintainer-clean


# Tell versions [3.59,3.63) of GNU make to not export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:
