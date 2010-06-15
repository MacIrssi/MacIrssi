#!/bin/bash
# copies perl libraries

PERLPATH="build/irssi-build/src/perl"
SUBDIRS="common textui ui irc"

for s in $SUBDIRS; do
	if [ -d $PERLPATH/$s ]; then
		SRCPATH="$PROJECT_DIR/$PERLPATH/$s/blib/lib/"
		DSTPATH="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME/Contents/Resources/Scripts/"
		mkdir -p "$DSTPATH"
		tar -zcpC "$SRCPATH" . | tar -zxC "$DSTPATH"
	fi
done

for s in $SUBDIRS; do
	if [ -d $PERLPATH/$s ]; then
		SRCPATH="$PROJECT_DIR/$PERLPATH/$s/blib/arch/"
		DSTPATH="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME/Contents/Resources/Scripts/"
		mkdir -p "$DSTPATH"
		tar -zcpC "$SRCPATH" . | tar -zxC "$DSTPATH"
	fi
done

exit 0