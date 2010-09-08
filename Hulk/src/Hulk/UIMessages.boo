namespace Hulk

import System.IO
import Boobel.Math

import Hulk.Core

static class UIMessages:
	def showScriptNotFound():
		print "Could not find a Hulkfile in '${Directory.GetCurrentDirectory()}'"
		print "Try 'hulk -help' for more information\n"
		
	def showHelp(cmdLine as CommandLine):
		print "Usage: hulk [options] <classname.taskname> <parameters>"
		print "Options:\n"
		cmdLine.PrintOptions()
		print ""
		
	def showStartBanner():
		print "Hulk ${HulkMain.Version}"
		print "Copyright (C) 2010 Georges Benatti Jr.\n"
		
	def showEndBanner():
		print "\nHulk smash little tasks\n"
		
	def showAllTasks(application as HulkApplication):
		for className in application.getClasses():
			showTasks(className, application.getTasks(className))			
		
	def showTasks(className as string, tasks as (TaskInfo)):
		title(className)
		columnSize = calculateColumnSize(tasks)
		for task in tasks:
			taskCommand(className, task.Name, task.Description, columnSize + len(className) + 2)
			
		print ""
		
	private def title(message as string):
		System.Console.ForegroundColor = System.ConsoleColor.Green
		print message
		System.Console.ResetColor()
		print "-"*len(message)
		
	private def calculateColumnSize(tasks as (TaskInfo)):
		greater = 0
		for task in tasks:
			greater = greater.max(len(task.Name))
			
		return greater
		
	def showTaskDescription(className as string, task as string, params as string, description as string):
		title(className)
		print "hulk ${className}.${task}(${params})  # ${description}\n"
		
	def showWrongNumberOfArguments(className as string, task as string, params as string, description as string):
		print "Wrong number of arguments\n\nTask usage:\n  hulk ${className}.${task}(${params})  # ${description}\n"

	private def taskCommand(className as string, task as string, description as string, size as int):
		delta = size - len(className) - len(task)
		print "hulk ${className}.${task}${delta* ' '}# ${description}"
				
	def showClassNotFound(className as string):
		print "Could not find class '${className}'\n"
		
	def showTaskNotFound(className as string, taskName as string):
		print "Could not find task '${taskName}' in class '${className}'\n"
