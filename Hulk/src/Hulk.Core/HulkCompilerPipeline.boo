namespace Hulk.Core

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Environments

import Boo.Lang.Parser

class HulkCompilerPipeline(Boo.Lang.Compiler.Pipelines.CompileToMemory):
	def constructor():
		InsertAfter(BooParsingStep, HulkInsertImports(["Hulk.Core"]))
		InsertAfter(BooParsingStep, HulkCollectDocumentation())
		InsertAfter(InitializeTypeSystemServices, HulkPatchBaseTypes())

class HulkInsertImports(Boo.Lang.Compiler.Steps.AbstractCompilerStep):
	_knownImports as List
	
	def constructor(knownImports as List):
		_knownImports = knownImports
	
	def Run():
		insertImports()
		
	private def insertImports():
		for module in CompileUnit.Modules: 
			for ns in _knownImports: 
				module.Imports.Add(Import(Namespace: ns))

class HulkPatchBaseTypes(Boo.Lang.Compiler.Steps.AbstractCompilerStep):
	def Run():
		patchBaseType()

	private def patchBaseType():
		for module in CompileUnit.Modules:
			for member in module.Members:
				typeDef = member as TypeDefinition
				if typeDef and len(typeDef.BaseTypes) == 0:
					typeDef.BaseTypes.Add(my(BooCodeBuilder).CreateTypeReference(typeof(Hulk.Core.Hulk)))

class HulkCollectDocumentation(Boo.Lang.Compiler.Steps.AbstractCompilerStep):
	
	def Run():
		collectDocumentation()
		
	private def collectDocumentation():
		collector = DocumentationCollector()
		for module in CompileUnit.Modules:
			module.Accept(collector)
			
		Context["documentation"] = collector.Documentation
							
class DocumentationCollector(DepthFirstVisitor):
	
	[getter(Documentation)]
	_documentation = List[of Tuple4[of string, string, string, string]]()
	
	override def OnMethod(node as Method):
		data = Tuple4[of string, string, string, string](node.DeclaringType.ToString(), node.Name, join(node.Parameters, ", "), node.Documentation)
		_documentation.Add(data)
