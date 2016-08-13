#!/bin/sh

BUILDCMD=xcodebuild
BUILDPATH=build/Release
BINNAME=bitsy-swift
BINDIR=bin

$BUILDCMD

if [ ! -d "$BINDIR" ]; then
  mkdir "$BINDIR"
fi

cp "$BUILDPATH/$BINNAME" "$BINDIR/"
