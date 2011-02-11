#!/bin/bash
PERLLIB="/System/Library/Perl"

# enumerate over each directory in this directory, if they subsequently have a 
# darwin-thread-multi-2level/CORE/libperl.dylib file then build a copy of the
# perl libraries against them and copy them to the app bundle

CC="llvm-gcc"

# obtained by running perl -MExtUtils::Embed -e ldopts
IRSSI_INCLUDES="-I$SRCROOT/irssi/src -I$SRCROOT/irssi/src/core -I$SRCROOT/irssi/src/fe-common/core"
DEFINES="-DPERL_DARWIN -DPERL_STATIC_LIBS=0 -D_REENTRANT -DSCRIPTDIR=\"\" -DHAVE_CONFIG_H -DPERL_USE_LIB=\"\""
CFLAGS="$IRSSI_INCLUDES -I$SRCROOT/Frameworks/MILibs/build/Release/GLib.framework/Headers -I$SRCROOT/Headers -g -Os $DEFINES"
LDFLAGS="-isysroot $SDKROOT -Wl,-undefined,dynamic_lookup -fstack-protector -lperl -dl -lm -lutil -lc"

RC_ARCHS=""
for x in $ARCHS; do
	RC_ARCHS="$RC_ARCHS -arch $x"
done

DSTROOT="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME/Contents/Resources/Perl"
[ ! -d $DSTROOT ] && mkdir -p $DSTROOT

P="$SRCROOT/irssi/src/perl/"
PERL_CORE="$P/perl-core.c $P/perl-common.c $P/perl-signals.c $P/perl-sources.c"
FE_PERL="$P/module-formats.c $P/perl-fe.c"

BINARY_MODULES="common Irc UI"

# right, iterate the libs
for lib in $PERLLIB/*; do
	V=`basename $lib`
	[[ $V == "5.8.1" ]] && continue

	_CFLAGS="$CFLAGS -I$lib/darwin-thread-multi-2level/CORE"

	if [ -e $lib/darwin-thread-multi-2level/CORE/libperl.dylib ]; then
		CORE_SRCS=""
		FE_SRCS=""

		# someone is going to burn me in a firey hell for this
		for x in $PERL_CORE; do
			OBJ="$OBJECT_FILE_DIR-$CURRENT_VARIANT"/`basename $x .c`.$V.o

			if [[ $x -nt $OBJ ]]; then
				$CC -isysroot $SDKROOT $_CFLAGS $RC_ARCHS -o $OBJ -c $x || exit 1
			fi

			CORE_SRCS="$CORE_SRCS $OBJ"
		done

		for x in $FE_PERL; do
			OBJ="$OBJECT_FILE_DIR-$CURRENT_VARIANT"/`basename $x .c`.$V.o

			if [[ $x -nt $OBJ ]]; then
				$CC -isysroot $SDKROOT $_CFLAGS $RC_ARCHS -o $OBJ -c $x || exit 1
			fi

			FE_SRCS="$FE_SRCS $OBJ"
		done

		$CC -dynamiclib $LDFLAGS $RC_ARCHS -L$lib/darwin-thread-multi-2level/CORE -o $DSTROOT/libperl_core.$V.dylib $CORE_SRCS || exit 1
		$CC -dynamiclib $LDFLAGS $RC_ARCHS -L$lib/darwin-thread-multi-2level/CORE -o $DSTROOT/libfe_perl.$V.dylib $FE_SRCS || exit 1

		# now build the perl modules
		for module in $BINARY_MODULES; do
			mkdir -p "$DERIVED_SOURCES_DIR/perl/$V/$module"

			XS_INCLUDES="-isystem $lib/darwin-thread-multi-2level/CORE -I$SRCROOT/irssi/src/perl/$module -I$SRCROOT/irssi/src/fe-common/core -I$SRCROOT/irssi/src/core -I$SRCROOT/irssi/src/irc -I$SRCROOT/irssi/src/irc/core -I$SRCROOT/irssi/src/core -I$SRCROOT/Headers"
			XS_CFLAGS="-UHAVE_CONFIG_H -DVERSION=\"0.9\" -DXS_VERSION=\"0.9\""

			for xs in $P/$module/*.xs; do
				CFILE="$DERIVED_SOURCES_DIR/perl/$V/$module/`basename $xs .xs`.c"
				[ $xs -nt $CFILE ] && (cd $P/$module ; echo xsubpp $V/$module/`basename $xs` ; xsubpp -typemap typemap -typemap ../common/typemap $xs > $CFILE || exit 2)
				[ $? -eq 2 ] && exit 1
			done

			OBJECTS=""
			for xc in $DERIVED_SOURCES_DIR/perl/$V/$module/*.c; do
				OBJ="$DERIVED_SOURCES_DIR/perl/$V/$module/`basename $xc .c`.o"
				[ $xc -nt $OBJ ] && (echo cc $V/$module/`basename $xc` ; $CC -isysroot $SDKROOT $XS_INCLUDES $_CFLAGS $XS_CFLAGS $RC_ARCHS -o $OBJ -c $xc || exit 2)
				[ $? -eq 2 ] && exit 1
				OBJECTS="$OBJECTS $OBJ"
			done

			if [ "x$module" == "xcommon" ]; then
				mkdir -p "$DSTROOT/$V/auto/Irssi"
				$CC -dynamiclib $RC_ARCHS -undefined dynamic_lookup -o "$DSTROOT/$V/auto/Irssi/Irssi.bundle" $OBJECTS || exit 1
			else
				mkdir -p "$DSTROOT/$V/auto/Irssi/$module"
				$CC -dynamiclib $RC_ARCHS -undefined dynamic_lookup -o "$DSTROOT/$V/auto/Irssi/$module/$module.bundle" $OBJECTS || exit 1
			fi
		done
	fi
done
