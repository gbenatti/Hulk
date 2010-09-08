namespace Hulk.Tests

import Hulk.Core

import Boo.Lang.Compiler
import Boo.Lang.Compiler.IO

import Boospec
import Boospec.ShouldMatcher

fixture "Hulk Compiler Pipeline":
	
	testing "Should have one module when compiling one file":
		compiler = BooCompiler()
		compiler.Parameters.Pipeline = HulkCompilerPipeline()
		compiler.Parameters.Input.Add(StringInput("code", """
class Base:
	pass
"""))
		
		context = compiler.Run()
		context.CompileUnit.Modules.Should.Have.Length == 1
		context.Errors.Should.Have.Count == 0

	testing "Should have two modules when compiling two files":
		compiler = BooCompiler()
		compiler.Parameters.Pipeline = HulkCompilerPipeline()
		compiler.Parameters.Input.Add(StringInput("first", """
class First:
	pass
"""))
		compiler.Parameters.Input.Add(StringInput("second", """
class Second:
	pass
"""))
		
		context = compiler.Run()
		context.CompileUnit.Modules.Should.Have.Length == 2
		
		context.Errors.Should.Have.Count == 0
