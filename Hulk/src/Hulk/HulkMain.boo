namespace Hulk

import System.IO

static class HulkMain:
	
	public Version = "0.2"
	
	def main(args as (string)):
		scriptFound = HulkScriptLocator.existsScriptFile(Directory.GetCurrentDirectory())
		cmdLine = CommandLine(args[1:])
		application = HulkApplication()

		execute(application, cmdLine, scriptFound)

	def execute(application as HulkApplication, cmdLine as CommandLine, scriptFound as bool):
		if not cmdLine.Version: UIMessages.showStartBanner()

		if not scriptFound and not cmdLine.DoHelp and not cmdLine.List and not cmdLine.Version:
			UIMessages.showScriptNotFound()
			return
			
		if cmdLine.DoHelp:
			UIMessages.showHelp(cmdLine)
			return
		
		if cmdLine.List:
			processList(application, cmdLine)
			return
		
		if cmdLine.Version:
			processVersion()
			return
		
		if not cmdLine.TaskName or not cmdLine.ClassName:
			processList(application, cmdLine)
			return

		if cmdLine.ClassName and not application.contains(cmdLine.ClassName):
			UIMessages.showClassNotFound(cmdLine.ClassName)
			return
		
		if cmdLine.TaskName and not application.contains(cmdLine.ClassName, cmdLine.TaskName):
			UIMessages.showTaskNotFound(cmdLine.ClassName, cmdLine.TaskName)
			return

		if application.run(cmdLine.ClassName, cmdLine.TaskName, cmdLine.Parameters):
			UIMessages.showEndBanner()

	def processList(application as HulkApplication, cmdLine as CommandLine):
		print "Tasks:\n"
		if not cmdLine.ClassName:
			UIMessages.showAllTasks(application)
			return
			
		if cmdLine.ClassName and not cmdLine.TaskName:
			UIMessages.showTasks(cmdLine.ClassName, application.getTasks(cmdLine.ClassName))
			return
			
		UIMessages.showTaskDescription(cmdLine.ClassName, cmdLine.TaskName, 
					application.getParameters(cmdLine.ClassName, cmdLine.TaskName), 
					application.getDescription(cmdLine.ClassName, cmdLine.TaskName))
		
	def processVersion():
		print "Hulk ${HulkMain.Version}\n"

HulkMain.main(/\s+/.Split(System.Environment.CommandLine))
