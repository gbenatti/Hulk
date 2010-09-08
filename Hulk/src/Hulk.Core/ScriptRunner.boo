namespace Hulk.Core

interface ScriptRunner:
	def runTask(className as string, taskName as string, params as (string))
	def getClasses() as (string)
	def getTasks(className as string) as (TaskInfo)
