package com.sulvic.funkin;

import com.sulvic.funkin.input.Cursor;
import com.sulvic.funkin.io.SaveData;
import com.sulvic.funkin.ui.FunkinSoundTray;
import haxe.ui.Toolkit;
import haxe.ui.focus.FocusManager;
import haxe.ui.tooltips.ToolTipManager;
import openfl.events.Event;
import openfl.display.Sprite;

class FunkinMain extends Sprite{

	static var zoom:Float = -1.0;
	static var framerate:Int = #if web 60 #else 120 #end;
	public static var initialState:Class<FlxState> = InitialState;
	public static var skipSplash:Bool = false;
	public static var startFullscreen:Bool = false;
	public static var gameWidth:Int = 1280;
	public static var gameHeight:Int = 720;

	public function new(){
		super();
		Log.trace = AnsiTrace.trace;
		AnsiTrace.traceBF();
		PolymodHandler.loadAllMods();
		if (stage != null) init();
		else
			addEventHandler(Event.ADDED_TO_STAGE, init);
	}

	public static function main():Void{
		// CrashHandler.initialize();
		// CrashHandler.queryStatus();
		Lib.current.addChild(new FunkinMain());
	}

	function init(?evt:Event):Void{
		if (hasEventListener(Event.ADDED_TO_STAGE)) removeEventHandler(Event.ADDED_TO_STAGE, init);
		setupGame();
	}

	function setupGame():Void{
		Toolkit.init();
		Toolkit.theme = #if REQUEST_DARK_MODE "dark" #else "light" #end;
		Toolkit.autoScale = false;
		FocusManager.instance.autoFocus = false;
		Cursor.registerHaxeUICursors();
		ToolTipManager.defaultDelay = 200;
		SaveData.load();
		var game:FlxGame = new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen);
		@:privateAccess
		game._customSoundTray = new SulvicSoundTray();
		addChild(game);
	}

}
