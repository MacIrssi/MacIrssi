#!/bin/bash
# copies perl libraries

PERLPATH="$SRCROOT/irssi/src/perl"
DST="$BUILT_PRODUCTS_DIR/$FULL_PRODUCT_NAME/Contents/Resources/Scripts"

[ ! -d $DST ] && mkdir -p $DST

# Irssi.pm
cp $PERLPATH/common/Irssi.pm $DST/Irssi.pm

# UI.pm
[ ! -d $DST/Irssi ] && mkdir -p $DST/Irssi
cp $PERLPATH/ui/UI.pm $DST/Irssi/UI.pm

# Irc.pm
[ ! -d $DST/Irssi ] && mkdir -p $DST/Irssi
cp $PERLPATH/irc/Irc.pm $DST/Irssi/Irc.pm

exit 0
