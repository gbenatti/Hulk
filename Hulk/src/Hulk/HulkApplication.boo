namespace Hulk

import System.IO

import Boo.Lang.Useful.Attributes

import Hulk.Core

class HulkApplication:

	def run(className as string, taskName as string, params as (string)):
		try:
			getRunner().runTask(className, taskName, params)
			return true
		except e as System.Reflection.TargetParameterCountException:
			UIMessages.showWrongNumberOfArguments(className, taskName,
						getParameters(className, taskName), 
						getDescription(className, taskName))
				
		return false
			
	[once]		
	def getRunner() as ScriptRunner:
		try:
			locator = HulkScriptLocator(Directory.GetCurrentDirectory())
			runner = HulkScriptLoader().process(locator.getFiles())
			return runner
		except e as ScriptCompilationException:
			print e
	
	[once]
	def getClasses():
		return getRunner().getClasses()
		
	def getTasks(className as string):
		return getRunner().getTasks(className)
		
	def getDescription(className as string, taskName as string):
		for task in getTasks(className):
			if task.Name == taskName: return task.Description
			
		return ""
						
	def getParameters(className as string, taskName as string):
		for task in getTasks(className):
			if task.Name == taskName: return task.Parameters
			
		return ""

	def contains(className as string):
		return className in getClasses()
		
	def contains(className as string, taskName as string):
		for task in getTasks(className):
			if task.Name == taskName: return true
		
		return false
