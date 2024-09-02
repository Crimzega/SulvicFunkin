package com.sulvic.funkin.assets;

@:library("songs")
@:path("assets/songs")
@:subdirs
@:exclude("*.fla|" + #if web "*.ogg" #else "*.mp3" #end + "|*.wav")
class SongAssets{}
