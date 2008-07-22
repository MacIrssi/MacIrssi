#!/bin/bash
if [ ! -e configure ]; then
  echo "Please run inside the irssi directory."
  exit 1
fi

if [[ ( -e config.xcode ) && ( -e Makefile ) && "$CONFIGURATION" != "" ]]; then
  if grep -q "$CONFIGURATION" config.xcode; then
		exit 0
  fi 
fi

./configure $@
CONF_EXIT=$?

if [ "$CONF_EXIT" -eq "0" ]; then
  echo $CONFIGURATION > config.xcode
fi
exit $CONF_EXIT

