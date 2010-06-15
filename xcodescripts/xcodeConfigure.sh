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

export SHELL="/bin/bash"
export CFLAGS="$CFLAGS -I$SRCROOT/Frameworks/MILibs/build/Release/include -DMACIRSSI_VERSION=\\\"$VERSION\\\""
export LDFLAGS="$LDFLAGS -L$SRCROOT/Frameworks/MILibs/build/Release/lib"
export PKG_CONFIG_PATH="$SRCROOT/Frameworks/MILibs/build/Release/lib/pkgconfig"
export PATH="$SRCROOT/Frameworks/MILibs/build/pkg-config-build:$PATH"

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

