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

# right, iterate the libs
for lib in $PERLLIB/*; do
	V=`basename $lib`
	[[ $V == "5.8.1" ]] && continue

	if [ -e $lib/darwin-thread-multi-2level/CORE/libperl.dylib ]; then
		CORE_SRCS=""
		FE_SRCS=""

		# someone is going to burn me in a firey hell for this
		for x in $PERL_CORE; do
			OBJ="$OBJECT_FILE_DIR-$CURRENT_VARIANT"/`basename $x .c`.$V.o
      
			if [[ $x -nt $OBJ ]]; then
				_CFLAGS="$CFLAGS -I$lib/darwin-thread-multi-2level/CORE"
        $CC -isysroot $SDKROOT $_CFLAGS $RC_ARCHS -o $OBJ -c $x || exit 1
			fi

			CORE_SRCS="$CORE_SRCS $OBJ"
		done

		for x in $FE_PERL; do
			OBJ="$OBJECT_FILE_DIR-$CURRENT_VARIANT"/`basename $x .c`.$V.o

			if [[ $x -nt $OBJ ]]; then
				_CFLAGS="$CFLAGS -I$lib/darwin-thread-multi-2level/CORE"
        $CC -isysroot $SDKROOT $_CFLAGS $RC_ARCHS -o $OBJ -c $x || exit 1
			fi

			FE_SRCS="$FE_SRCS $OBJ"
		done

		$CC -dynamiclib $LDFLAGS $RC_ARCHS -L$lib/darwin-thread-multi-2level/CORE -o $DSTROOT/libperl_core.$V.dylib $CORE_SRCS || exit 1
		$CC -dynamiclib $LDFLAGS $RC_ARCHS -L$lib/darwin-thread-multi-2level/CORE -o $DSTROOT/libfe_perl.$V.dylib $FE_SRCS || exit 1
	fi
done
