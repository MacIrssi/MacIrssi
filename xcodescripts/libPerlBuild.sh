#!/bin/bash
PERLLIB="/System/Library/Perl"

# enumerate over each directory in this directory, if they subsequently have a 
# darwin-thread-multi-2level/CORE/libperl.dylib file then build a copy of the
# perl libraries against them and copy them to the app bundle

# obtained by running perl -MExtUtils::Embed -e ldopts
GLIB_LDFLAGS="-L$SRCROOT/Frameworks/MILibs/build/Release/lib -lgmodule-2.0 -lglib-2.0 -lintl -liconv -lssl -lcrypto"
LDFLAGS="-Wl,-undefined,dynamic_lookup -fstack-protector -lperl -dl -lm -lutil -lc"
for x in $ARCHS; do
  LDFLAGS="$LDFLAGS -arch $x"
done

DSTROOT="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME/Contents/Resources/Perl"
[ ! -d $DSTROOT ] && mkdir -p $DSTROOT

P="$BUILD_ROOT/irssi-build/src/perl/.libs/"
PERL_CORE="$P/perl-core.o $P/perl-common.o $P/perl-signals.o $P/perl-sources.o"
FE_PERL="$P/module-formats.o $P/perl-fe.o"

# right, iterate the libs
for lib in $PERLLIB/*; do
	V=`basename $lib`
	[[ $V == "5.8.1" ]] && continue

	if [ -e $lib/darwin-thread-multi-2level/CORE/libperl.dylib ]; then
		gcc-4.2 -dynamiclib $LDFLAGS -L$lib/darwin-thread-multi-2level/CORE -o $DSTROOT/libperl_core.$V.dylib $PERL_CORE
		gcc-4.2 -dynamiclib $LDFLAGS -L$lib/darwin-thread-multi-2level/CORE -o $DSTROOT/libfe_perl.$V.dylib $FE_PERL
	fi
done
