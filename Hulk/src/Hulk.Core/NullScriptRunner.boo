namespace Hulk.Core

class NullScriptRunner(ScriptRunner):
	def runTask(className as string, taskName as string, params as (string)):
		pass

	def getClasses() as (string):
		return array(string, 0)
		
	def getTasks(className as string) as (TaskInfo):
		return array(TaskInfo, 0)
