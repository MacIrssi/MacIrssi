#!/bin/bash
# copies perl libraries

PERLPATH="$SRCROOT/irssi/src/perl"
DST="$BUILT_PRODUCTS_DIR/$FULL_PRODUCT_NAME/Contents/Resources/Scripts"

[ ! -d $DST ] && mkdir -p $DST

# Irssi.pm
cp $PERLPATH/common/Irssi.pm $DST/Irssi.pm

# Irssi.bundle
[ -f "$BUILT_PRODUCTS_DIR/Irssi.bundle" ] || exit 1
mkdir -p "$DST/auto/Irssi" || exit 1
cp "$BUILT_PRODUCTS_DIR/Irssi.bundle" "$DST/auto/Irssi/Irssi.bundle"
touch "$DST/auto/Irssi/Irssi.bs"

# UI.pm
[ ! -d $DST/Irssi ] && mkdir -p $DST/Irssi
cp $PERLPATH/ui/UI.pm $DST/Irssi/UI.pm

# UI.bundle
[ -f "$BUILT_PRODUCTS_DIR/UI.bundle" ] || exit 1
mkdir -p "$DST/auto/Irssi/UI" || exit 1
cp "$BUILT_PRODUCTS_DIR/UI.bundle" "$DST/auto/Irssi/UI/UI.bundle"
touch "$DST/auto/Irssi/UI/UI.bs"

# Irc.pm
[ ! -d $DST/Irssi ] && mkdir -p $DST/Irssi
cp $PERLPATH/irc/Irc.pm $DST/Irssi/Irc.pm

# Irc.bundle
[ -f "$BUILT_PRODUCTS_DIR/Irc.bundle" ] || exit 1
mkdir -p "$DST/auto/Irssi/Irc" || exit 1
cp "$BUILT_PRODUCTS_DIR/Irc.bundle" "$DST/auto/Irssi/Irc/Irc.bundle"
touch "$DST/auto/Irssi/Irc/Irc.bs"

exit 0
