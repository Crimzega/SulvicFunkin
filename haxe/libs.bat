@echo off
haxelib --global update haxelib
haxelib --global install hmm
haxelib --global run hmm setup
hmm install
haxelib run lime setup
