namespace Hulk.Tests

import Hulk.Core

import System.IO

import Boospec
import Boospec.ShouldMatcher

class Stage:
	
	_data = {}
	
	def register(key as string, text as string):
		_data[key] = getTempFileWithData(text)
		
	def get(key as string):
		return _data[key] as string
		
	private def getTempFileWithData(text as string):
		filename = Path.GetTempFileName()
		File.WriteAllText(filename, text)
		return filename

fixture "Hulk Script Loader":
	
	declare:
		_stage as Stage
		
	setup:
		_stage = Stage()
		_stage.register("OneBase", """
class Base:
	pass
""")
		_stage.register("OneFoo", """
class Foo:
	pass
""")
		_stage.register("FooBar", """
class Foo:
	pass

class Bar:
  pass 
""")
	
	testing "Should just process simple file and get classes":
		loader = HulkScriptLoader(CommonReferencesPath: ".")
		runner = loader.process(_stage.get("OneBase"))
		runner.getClasses().Should.Have.Count == 1

	testing "Should load more then one class for file":
		loader = HulkScriptLoader(CommonReferencesPath: ".")
		runner = loader.process(_stage.get("FooBar"))
		runner.getClasses().Should.Have.Count == 2

	testing "Should load more then one file":
		loader = HulkScriptLoader(CommonReferencesPath: ".")
		runner = loader.process(List[of string]([_stage.get("OneBase"), _stage.get("OneFoo")]))
		runner.getClasses().Should.Have.Count == 2
