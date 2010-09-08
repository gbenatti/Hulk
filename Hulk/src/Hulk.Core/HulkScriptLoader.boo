namespace Hulk.Core

import System.IO
import System.Reflection

import Boo.Lang.Compiler
import Boo.Lang.Compiler.IO

import Hulk.Core

class HulkScriptLoader:

	_commonReferencesPath as string
	_facilitiesPath as string

	CommonReferencesPath as string:
		get:
			if _commonReferencesPath is null:
				_commonReferencesPath = System.IO.Path.GetDirectoryName(Assembly.GetEntryAssembly().Location)
				
			return _commonReferencesPath
		set:
			_commonReferencesPath = value

	def process([required] scriptFiles as List[of string]) as ScriptRunner:
		compiler = getHulkScriptCompiler()
		for scriptFile in scriptFiles:
			compiler.Parameters.Input.Add(StringInput(scriptFile, File.ReadAllText(scriptFile)))
		
		context = compiler.Run()
		raise ScriptCompilationException(context.Errors.Join('\n')) if context.Errors.Count > 0
		
		return HulkScriptRunner(context, context["documentation"])

	def process([required] scriptFile as string) as ScriptRunner:
		return process(List[of string]([scriptFile]))
		
	private def getHulkScriptCompiler():
		compiler = BooCompiler()
		compiler.Parameters.Pipeline = HulkCompilerPipeline()
		
		loadCommonReferences(compiler)
		loadFacilities(compiler)
		return compiler
		
	private def loadCommonReferences(compiler as BooCompiler):
		commonAsms = ["Hulk.Core.dll"]
		for file in commonAsms:
			compiler.Parameters.References.Add(Assembly.LoadFile(Path.Combine(CommonReferencesPath, file)))

	private def loadFacilities(compiler as BooCompiler):
		facilities = HulkFacilitiesLocator(CommonReferencesPath)
		for file in facilities.getFiles(getOsType()):
			compiler.Parameters.References.Add(Assembly.LoadFile(file))
			
	private def getOsType():
		if System.Environment.OSVersion.Platform == System.Environment.OSVersion.Platform.MacOSX:
			return OsTypes.OsX
		if System.Environment.OSVersion.Platform == System.Environment.OSVersion.Platform.Unix:
			return OsTypes.Unix | OsTypes.OsX
			
		return OsTypes.Win32