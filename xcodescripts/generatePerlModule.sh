#!/bin/sh
# generatePerlModule.sh [dir] [module name]

[ ! -d $DERIVED_SOURCES_DIR ] && mkdir $DERIVED_SOURCES_DIR
for x in $1/*.xs; do
  [ $x -nt "$DERIVED_SOURCES_DIR/`basename $x .xs`.xc" ] && xsubpp -typemap $1/typemap $x > $DERIVED_SOURCES_DIR/`basename $x .xs`.c
done

CCOPTS=$DERIVED_SOURCES_DIR/compiler.opts

[ -f $CCOPTS ] && rm $CCOPTS
perl -MExtUtils::Embed -e perl_inc >> $CCOPTS
