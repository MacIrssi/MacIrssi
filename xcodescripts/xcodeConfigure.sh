#!/bin/bash

if [ ! -e autogen.sh ]; then
  echo "Please run inside the irssi directory."
  exit 1
fi

if [ "x$ACTION" == "xclean" ]; then
  echo "warning: skipping configure, clean requested."
  exit 0
fi

if [ ! -e "$BUILD_ROOT"/irssi-build ]; then
  mkdir -p "$BUILD_ROOT"/irssi-build
  # link .git for irssi-version
  ln -s "`pwd`/.git" "$BUILD_ROOT/irssi-build/.git"
  for i in `find * -print`; do
    if [ -d $i ]; then
      mkdir -p "$BUILD_ROOT/irssi-build/$i"
    else
      ln -s "`pwd`/$i" "$BUILD_ROOT/irssi-build/$i"
    fi
  done
fi

# move to the real build directory
cd "$BUILD_ROOT"/irssi-build

VERSION=`pl < $PROJECT_DIR/Info.plist | perl -ne 'while (<STDIN>) { print $1 if ($_ =~ /CFBundleVersion\s+=\s+"(.*?)"/); }'`

if [[ ( -e config.xcode ) && ( -e Makefile ) && "$CONFIGURATION" != "" ]]; then
  if grep -q "$CONFIGURATION-$TARGET_NAME" config.xcode; then
		exit 0
  fi 
fi

[ -e config.xcode ] && echo "warning: build configuration changed, running ./configure"
[ ! -e config.xcode ] && echo "warning: config.xcode not found, running ./configure"

[ -e config.xcode ] && rm config.xcode

A=
for x in $ARCHS; do
  A="$A -arch $x"
done

# find the *lowest* versioned perl on the system (there's usually two, more if you have PerlSDKs installed)
PERL_VERSION=`perl -e 'opendir(DIR, "/System/Library/Perl"); my @ds=(); while (my $d = readdir(DIR)) { next unless $d =~ /\d+\.\d+/ ; push(@ds, $d); }; @ds = sort { my @as=split(/\./, $a) ; my @bs=split(/\./, $b); $as[0] <=> $bs[0] || $as[1] <=> $bs[1] || $as[2] <=> $bs[2]; } @ds; printf "$ds[0]\n";'`

export SHELL="/bin/bash"
export CFLAGS="$CFLAGS $A -I$SRCROOT/Frameworks/MILibs/build/Release/include -DMACIRSSI_VERSION=\\\"$VERSION\\\""
export LDFLAGS="$LDFLAGS $A -L$SRCROOT/Frameworks/MILibs/build/Release/lib"
export PKG_CONFIG_PATH="$SRCROOT/Frameworks/MILibs/build/Release/lib/pkgconfig"
export PATH="$SRCROOT/Frameworks/MILibs/build/pkg-config-build:$PATH"
export VERSIONER_PERL_VERSION=$PERL_VERSION

if [ ! -f ./configure ]; then
  # set up autoconf so it has pkg.m4 around
  cat "$SRCROOT/Frameworks/MILibs/build/pkg-config-build/pkg.m4" >> acinclude.m4 || exit 1
  ./autogen.sh
fi

# yes I know I'm running configure twice (once in autogen). The first one is responsible for
# generating us a libtool but fails to recognise that we can build perl as a module.
./configure $@
CONF_EXIT=$?

if [ "$CONF_EXIT" -eq "0" ]; then
  echo "$CONFIGURATION-$TARGET_NAME" > config.xcode
fi
exit $CONF_EXIT

