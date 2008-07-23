#!/bin/bash

test -r /sw/bin/init.sh && . /sw/bin/init.sh

if [ ! -e configure ]; then
  echo "Please run inside the irssi directory."
  exit 1
fi

echo $PATH

if [[ ( -e config.xcode ) && ( -e Makefile ) && "$CONFIGURATION" != "" ]]; then
  if grep -q "$CONFIGURATION" config.xcode; then
		exit 0
  fi 
fi

rm config.xcode

./configure $@
CONF_EXIT=$?

if [ "$CONF_EXIT" -eq "0" ]; then
  make clean
  echo $CONFIGURATION > config.xcode
fi
exit $CONF_EXIT

