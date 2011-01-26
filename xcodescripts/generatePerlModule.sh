#!/bin/sh
# generatePerlModule.sh [dir] [module name]

[ ! -d $DERIVED_SOURCES_DIR ] && mkdir $DERIVED_SOURCES_DIR
for x in $1/*.xs; do
  OTHER_TYPEMAPS=""
  if [ -f $1/../common/typemap ]; then
    OTHER_TYPEMAPS="-typemap ../common/typemap"
  fi
  [ $x -nt "$DERIVED_SOURCES_DIR/`basename $x .xs`.c" ] && (xsubpp -typemap $1/typemap $OTHER_TYPEMAPS $x > $DERIVED_SOURCES_DIR/`basename $x .xs`.c || exit 1)
done

CCOPTS=$DERIVED_SOURCES_DIR/compiler.opts

[ -f $CCOPTS ] && rm $CCOPTS
perl -MExtUtils::Embed -e perl_inc >> $CCOPTS
