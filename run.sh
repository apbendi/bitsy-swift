#!/bin/sh

BITSY_PATH=build/Debug
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
BITSY_BIN=$SCRIPTPATH/$BITSY_PATH/bitsy-swift

$BITSY_BIN $1 --run-delete
