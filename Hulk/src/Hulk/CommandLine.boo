namespace Hulk

import Boo.Lang.PatternMatching
import Boo.Lang.Useful.CommandLine

class CommandLine(AbstractCommandLine):
	
	_args = List[of string]()
	
	def constructor(argv):
		Parse(argv)
		
	IsValid:
		get: return len(_args) > 0 or Version or List
	
	ClassName:
		get:
			return unless len(_args) > 0
			return parseTask(_args[0])[0]

	TaskName:
		get:
			return unless len(_args) > 0
			return parseTask(_args[0])[1]
			
	Parameters:
		get:
			if len(_args) > 1: 
				return array(_args.GetRange(1))
			else:
				return array(string, 0)
		
	[Option("List avaiable tasks", LongForm: "list", ShortForm: "L")]
	public List = false

	[Option("Show Hulk version", LongForm: "version")]
	public Version = false

	[Option("Enables verbose mode", LongForm: "verbose")]
	public Verbose = false

	[Option("Display this help and exit", LongForm: "help")]
	public DoHelp = false
		
	[Argument]
	def AddArg([required] arg as string):
		_args.Add(arg)
		
	private def parseTask(arg as string):
		match arg:
			case /^(?<ns>.+)\.(?<task>.+)$/:
				return (ns[0].Value, task[0].Value)
			case /^(?<ns>.+)$/:
				return (ns[0].Value, null)
		
		return (null, null)
