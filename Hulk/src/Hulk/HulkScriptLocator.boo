namespace Hulk

import System.IO

import Boobel.Attributes

class HulkScriptLocator:

	static def existsScriptFile(directory as string):
		return getScriptFile(directory) != null
			
	static private def getScriptFile(directory as string):
		scriptFile = Path.Combine(directory, "Hulkfile")
		return (scriptFile if File.Exists(scriptFile) else null)

	def constructor([let] directory as string):
		pass
		
	def getFiles() as List[of string]:
		files = List[of string]([getScriptFile(_directory)])
		tasksDir = Path.Combine(_directory, "tasks")
		files += Directory.GetFiles(tasksDir, "*.hulk") if Directory.Exists(tasksDir)

		return files
