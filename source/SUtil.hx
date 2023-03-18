package;

#if android
import android.widget.Toast;
import android.Permissions;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Environment;
#end
import flash.system.System;
import flixel.FlxG;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/**
 * ...
 * @author: Saw (M.A. Jigsaw)
 */
class SUtil
{
	static final videoFiles:Array<String> = [
		"credits",
		"gose",
		"intro",
		"bendy/1.5",
		"bendy/1",
		"bendy/2",
		"bendy/3",
		"bendy/4",
		"bendy/4ez",
		"bendy/5",
		"bendy/5",
		"bendy/bgscene",
		"bendy/bgscenephotosensitive",
		"cuphead/1",
		"cuphead/2",
		"cuphead/3",
		"cuphead/4",
		"cuphead/cup",
		"cuphead/the devil",
		"sans/1",
		"sans/2",
		"sans/3",
		"sans/3b",
		"sans/4",
		"sans/4b"
	];

	/**
	 * A simple function that checks for storage permissions and game files/folders
	 */
	public static function checkFiles():Void
	{
		#if mobile
		if (!FileSystem.exists(SUtil.getStorageDirectory() + 'assets') && !FileSystem.exists(SUtil.getPath() + 'mods'))
		{
			Lib.application.window.alert("Whoops, seems like you didn't extract the files from the .APK!\nPlease copy the files from the .APK to\n" + SUtil.getStorageDirectory(),
				'Error!');
			LimeSystem.exit(1);
		}
		else if ((FileSystem.exists(SUtil.getStorageDirectory() + 'assets') && !FileSystem.isDirectory(SUtil.getStorageDirectory() + 'assets'))
			&& (FileSystem.exists(SUtil.getStorageDirectory() + 'mods') && !FileSystem.isDirectory(SUtil.getStorageDirectory() + 'mods')))
		{
			Lib.application.window.alert("Why did you create two files called assets and mods instead of copying the folders from the .APK?, expect a crash.",
				'Error!');
			LimeSystem.exit(1);
		}
		else
		{
			if (!FileSystem.exists(SUtil.getStorageDirectory() + 'assets'))
			{
				Lib.application.window.alert("Whoops, seems like you didn't extract the assets/assets folder from the .APK!\nPlease copy the assets/assets folder from the .APK to\n" + SUtil.getStorageDirectory(),
					'Error!');
				LimeSystem.exit(1);
			}
			else if (FileSystem.exists(SUtil.getStorageDirectory() + 'assets') && !FileSystem.isDirectory(SUtil.getStorageDirectory() + 'assets'))
			{
				Lib.application.window.alert("Why did you create a file called assets instead of copying the assets directory from the .APK?, expect a crash.",
					'Error!');
				LimeSystem.exit(1);
			}

			if (!FileSystem.exists(SUtil.getStorageDirectory() + 'mods'))
			{
				Lib.application.window.alert("Whoops, seems like you didn't extract the assets/mods folder from the .APK!\nPlease copy the assets/mods folder from the .APK to\n" + SUtil.getStorageDirectory(),
					'Error!');
				LimeSystem.exit(1);
			}
			else if (FileSystem.exists(SUtil.getStorageDirectory() + 'mods') && !FileSystem.isDirectory(SUtil.getStorageDirectory() + 'mods'))
			{
				Lib.application.window.alert("Why did you create a file called mods instead of copying the mods directory from the .APK?, expect a crash.",
					'Error!');
				LimeSystem.exit(1);
			}
		}
		#end
	}
	
	/**
	 * This returns the external storage path that the game will use
	 */
	public static function getPath():String
	{
		#if android
		return Environment.getExternalStorageDirectory() + '/' + '.' + Application.current.meta.get('file') + '/';
		#else
		return '';
		#end
	}

	/**
	 * Uncaught error handler, original made by: sqirra-rng
	 */
	public static function gameCrashcCheck()
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(u:UncaughtErrorEvent)
		{
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var errMsg:String = '';

			for (stackItem in callStack)
			{
				switch (stackItem)
				{
					case CFunction:
						errMsg += 'a C function\n';
					case Module(m):
						errMsg += 'module ' + m + '\n';
					case FilePos(s, file, line, column):
						errMsg += file + ' (line ' + line + ')\n';
					case Method(cname, meth):
						errMsg += cname == null ? "<unknown>" : cname + '.' + meth + '\n';
					case LocalFunction(n):
						errMsg += 'local function ' + n + '\n';
				}
			}

			errMsg += u.error;

			try
			{
				if (!FileSystem.exists(SUtil.getPath() + 'logs'))
					FileSystem.createDirectory(SUtil.getPath() + 'logs');

				File.saveContent(SUtil.getPath()
					+ 'logs/'
					+ Application.current.meta.get('file')
					+ '-'
					+ Date.now().toString().replace(' ', '-').replace(':', "'")
					+ '.log',
					errMsg
					+ '\n');
			}
			#if android
			catch (e:Dynamic)
			Toast.makeText("Error!\nClouldn't save the crash dump because:\n" + e, Toast.LENGTH_LONG);
			#end

			Sys.println(errMsg);
			Application.current.window.alert(errMsg, 'Error!');

			System.exit(1);
		});
	}

	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json',
			fileData:String = 'you forgot to add something in your code lol')
	{
		try
		{
			if (!FileSystem.exists(SUtil.getPath() + 'saves'))
				FileSystem.createDirectory(SUtil.getPath() + 'saves');

			File.saveContent(SUtil.getPath() + 'saves/' + fileName + fileExtension, fileData);
			Toast.makeText("File Saved Successfully!", Toast.LENGTH_LONG);
		}
		#if android
		catch (e:Dynamic)
		Toast.makeText("Error!\nClouldn't save the file because:\n" + e, Toast.LENGTH_LONG);
		#end
	}

	public static function copyContent(copyPath:String, savePath:String)
	{
		try
		{
			if (!FileSystem.exists(savePath) && Assets.exists(copyPath))
				File.saveBytes(savePath, Assets.getBytes(copyPath));
		}
		#if android
		catch (e:Dynamic)
		Toast.makeText("Error!\nClouldn't copy the file because:\n" + e, Toast.LENGTH_LONG);
		#end
	}
}
