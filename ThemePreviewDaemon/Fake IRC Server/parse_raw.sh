#!/bin/sh

grep ">>" -- | grep -v PONG | cut -d' ' -f2-
