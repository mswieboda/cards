#!/usr/bin/env bash

dir=`dirname "$0"`
LD_LIBRARY_PATH="$dir/lib_ext" "$dir/bin/cards"
