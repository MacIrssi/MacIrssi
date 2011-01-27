#!/bin/sh
# generatePerlModule.sh [dir] [module name]

mkdir -p "$DERIVED_SOURCES_DIR"
for x in $1/*.xs; do
  [ $x -nt "$DERIVED_SOURCES_DIR/`basename $x .xs`.c" ] && (xsubpp -typemap $1/typemap -typemap ../common/typemap $x > $DERIVED_SOURCES_DIR/`basename $x .xs`.c || exit 1)
done

CCOPTS=$DERIVED_SOURCES_DIR/compiler.opts

[ -f $CCOPTS ] && rm $CCOPTS
perl -MExtUtils::Embed -e perl_inc >> $CCOPTS
