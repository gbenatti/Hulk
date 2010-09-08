namespace Hulk.Core

import Boo.Lang.Compiler
import Boo.Lang.PatternMatching

import Boobel.Attributes
import Boobel.Dynamic

import Hulk.Core

class HulkScriptRunner(ScriptRunner):
			
	[getter(NullRunner)]
	static _nullRunner = NullScriptRunner()
	
	def constructor([let] context as CompilerContext, [let] extraInfo as List[of Tuple4[of string, string, string, string]]):
		pass
	
	def runTask(className as string, taskName as string, params as (string)):
		match locateScriptInstance(className):
			case instance=Hulk.Core.Hulk():
				if instance.respondTo(taskName):
					instance.invoke(taskName, *params)
				else:
					raise "Task ${taskName} not found in namespace ${className}"
			otherwise:
				raise "Unknown Namespace ${className}"
		
	private def locateScriptInstance(className as string):
		return _context.GeneratedAssembly.CreateInstance(className) as Hulk.Core.Hulk
		
	def getClasses():
		return array(t.ToString() for t in _context.GeneratedAssembly.GetTypes() if typeof(Hulk.Core.Hulk).IsAssignableFrom(t))

	def getTasks(className as string) as (TaskInfo):
		type = _context.GeneratedAssembly.GetType(className)
		excludedNames = ["Equals", "GetType", "ToString", "GetHashCode", "invoke"]
		if type and typeof(Hulk.Core.Hulk).IsAssignableFrom(type):
			return array(TaskInfo(Name: methodInfo.Name, Description: getDescription(className, methodInfo.Name), Parameters: getParameters(className, methodInfo.Name)) for methodInfo in type.GetMethods() if methodInfo.Name not in excludedNames)
		
		return array(TaskInfo, 0)

	private def getDescription(className as string, taskName as string) as string:
		for data in _extraInfo:
			if data._1 == className and data._2 == taskName: return data._4
			
		return ""
	
	private def getParameters(className as string, taskName as string) as string:
		for data in _extraInfo:
			if data._1 == className and data._2 == taskName: return data._3
			
		return ""
		