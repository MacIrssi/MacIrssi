#!/bin/sh

# copySymbols.sh

# Until MacIrssi moves to Xcode4, we'll continue to copy dSYMs over from MILibs pre-packaging
for x in `find $SRCROOT/Frameworks/MILibs/build/Release -name *.dSYM`; do
  rsync -av $x $BUILT_PRODUCTS_DIR
done
