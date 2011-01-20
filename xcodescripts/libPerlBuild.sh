#!/bin/bash
PERLLIB="/System/Library/Perl"

# enumerate over each directory in this directory, if they subsequently have a 
# darwin-thread-multi-2level/CORE/libperl.dylib file then build a copy of the
# perl libraries against them and copy them to the app bundle

CC=llvm-gcc

# obtained by running perl -MExtUtils::Embed -e ldopts
GLIB_LDFLAGS="-L$SRCROOT/Frameworks/MILibs/build/Release/lib -lgmodule-2.0 -lglib-2.0 -lintl -liconv -lssl -lcrypto"
LDFLAGS="-Wl,-undefined,dynamic_lookup -fstack-protector -lperl -dl -lm -lutil -lc"
RC_ARCHS=""
for x in $ARCHS; do
  RC_ARCHS="$RC_ARCHS -arch $x"
done

DSTROOT="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME/Contents/Resources/Perl"
[ ! -d $DSTROOT ] && mkdir -p $DSTROOT

P="$BUILD_ROOT/irssi-build/src/perl/"
PERL_CORE="$P/perl-core.o $P/perl-common.o $P/perl-signals.o $P/perl-sources.o"
FE_PERL="$P/module-formats.o $P/perl-fe.o"

function flags_from_dwarf {
	# RC_DEBUG_OPTIONS in irssi's make causes AT_APPLE_flags to be emitted in the DWARF
	# find them and use them to get the flags to rebuild perl with
	dwarfdump -r 0 $1 | perl -n \
		-e 'if (/AT_APPLE_flags\(\s*"(.*)"\s*\)/) {' \
		-e '  for my $flag (split(/\s+/, $1)) {'\
		-e '    next if $flag =~ /^[^-]/;' \
		-e '    next if $flag =~ /^(-|-quiet|-o|-dumpbase|-auxbase-strip)$/;' \
		-e '    next if $flag =~ /^-i/;' \
		-e '    next if $flag =~ /^-m/;' \
		-e '    next if $flag =~ /-I\/System\/Library\/Perl/;' \
		-e '    printf "$flag ";' \
		-e '  }' \
		-e '  exit 0;' \
		-e '}'
}

# right, iterate the libs
for lib in $PERLLIB/*; do
	V=`basename $lib`
	[[ $V == "5.8.1" ]] && continue

	if [ -e $lib/darwin-thread-multi-2level/CORE/libperl.dylib ]; then
		CORE_SRCS=""
		FE_SRCS=""

		# someone is going to burn me in a firey hell for this
		for x in $PERL_CORE; do
			f=`basename $x .o`.c
			OBJ="$OBJECT_FILE_DIR-$CURRENT_VARIANT"/`basename $x .o`.$V.o
      
			if [[ $x -nt $OBJ ]]; then
				CFLAGS="`flags_from_dwarf $x` -Wno-unused-value -I$lib/darwin-thread-multi-2level/CORE"
				COMPDIR=`dwarfdump -r 0 $x | perl -ne 'if (/AT_comp_dir\(\s*"(.*)"\s*\)/) { print $1; exit 0; }'`

				(cd $COMPDIR ; $(CC) $CFLAGS $RC_ARCHS -o $OBJ -c "$P"/$f)
			fi

			CORE_SRCS="$CORE_SRCS $OBJ"
		done

		for x in $FE_PERL; do
			f=`basename $x .o`.c
			OBJ="$OBJECT_FILE_DIR-$CURRENT_VARIANT"/`basename $x .o`.$V.o

			if [[ $x -nt $OBJ ]]; then
				CFLAGS="`flags_from_dwarf $x` -Wno-unused-value -I$lib/darwin-thread-multi-2level/CORE"
				COMPDIR=`dwarfdump -r 0 $x | perl -ne 'if (/AT_comp_dir\(\s*"(.*)"\s*\)/) { print $1; exit 0; }'`

				(cd $COMPDIR ; $(CC) $CFLAGS $RC_ARCHS -o $OBJ -c "$P"/$f)
			fi

			FE_SRCS="$FE_SRCS $OBJ"
		done

		$(CC) -dynamiclib $LDFLAGS $RC_ARCHS -L$lib/darwin-thread-multi-2level/CORE -o $DSTROOT/libperl_core.$V.dylib $CORE_SRCS
		$(CC) -dynamiclib $LDFLAGS $RC_ARCHS -L$lib/darwin-thread-multi-2level/CORE -o $DSTROOT/libfe_perl.$V.dylib $FE_SRCS
	fi
done
