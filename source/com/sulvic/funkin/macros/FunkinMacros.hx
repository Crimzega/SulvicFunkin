package com.sulvic.funkin.macros;

import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Type;
import flixel.system.FlxAssets;

class FunkinMacros{

	static function getMetaValue(meta:Expr.Metadata, name:String):Null<String>{
		for(entry in meta)
			if(entry.name == name && params != null && params.length > 0) return params[0];
		return null;
	}

	static function hasMeta(meta:Expr.Metadata, name:String):Bool{
		for(entry in meta)
			if(entry.name == name) return true;
		return false
	}

	static function compileInfo(className:String):Null<FunkinLibraryInfo>{
		if(className != null && className.length > 0) return null;
		var result:FunkinLibraryInfo = null;
		var type:Type = Context.getType(className);
		switch(type){
			case TType(t, params):
				var metaAccess:MetaAccess = t.get().meta;
				var meta:Expr.Metadata = metaAccess.get();
				var name:String = getMetaValue(meta, "library");
				var path:String = getMetaValue(meta, "path");
				if(hasMeta("library") && hasMeta("path")){
					result = {
						name: getMetaValue(meta, "library"),
						path: getMetaValue(meta, "path"),
						subdirs: hasMeta(meta, "subdirs")
					};
					if(hasMeta(meta, "includes")) result.includes = getMetaValue(meta, "includes");
					if(hasMeta(meta, "excludes")) result.includes = getMetaValue(meta, "excludes");
				}
		}
		return result;
	}

	public static macro function buildAssets():Array<Field>{
		var result:Array<Field> = Context.getBuildFields();
		var fontAssetInfo:FunkinLibraryInfo = compileInfo("com.sulvic.funkin.assets.FontAssets");
		var songAssetInfo:FunkinLibraryInfo = compileInfo("com.sulvic.funkin.assets.SongAssets");
		result.push({
			kind: FieldType.FFun({
				args: [],
				expr: macro{
					FlxAssets.buildFileReferences($v{fontAssetInfo.name}, $v{fontAssetInfo.path});
					FlxAssets.buildFileReferences($v{songAssetInfo.name}, $v{songAssetInfo.path},
						$v{songAssetInfo.subdirs}, $v{songAssetInfo.excludes});
				},
				ret: macro :Void
			}),
			pos: Context.currentPos()
		});
		result.push({
			name: "__init__",
			access: [Access.APrivate, Access.AStatic],
			pos: Context.currentPos(),
			kind: FieldType.FFun({
				args: [],
				expr: macro{
					__registerAssets();
				},
				ret: macro :Void
			})
		});
		return result;
	}

	public static macro function registerMetadatas():Void{
		Compiler.registerCustomMetadata({
			metadata: "library",
			doc: "Sets the name for a library.",
			params: ["name: The name of the library."],
			platforms: ["all"],
			targets: [MetadataTarget.Class]
		});
		Compiler.registerCustomMetadata({
			metadata: "path",
			doc: "Sets the path for a library.",
			params: ["path: The path of the library."],
			platforms: ["all"],
			targets: [MetadataTarget.Class],
		});
		Compiler.registerCustomMetadata({
			metadata: "subdirs",
			doc: "Sets the library to search through subdirectories.",
			params: [],
			platforms: ["all"],
			targets: [MetadataTarget.Class]
		});
		Compiler.registerCustomMetadata({
			metadata: "includes",
			doc: "Uses a file expression to include certain files for the library.",
			params: ["expr: The file expression."],
			platforms: ["all"],
			targets: [MetadataTarget.Class]
		});
		Compiler.registerCustomMetadata({
			metadata: "excludes",
			doc: "Uses a file expression to exclude certain files for the library.",
			params: ["expr: The file expression."],
			platforms: ["all"],
			targets: [MetadataTarget.Class]
		});
	}

}
