#!/bin/sh
exec haxelib --global update haxelib
exec haxelib --global install hmm
exec haxelib --global run hmm setup
exec hmm install
exec haxelib run lime setup
