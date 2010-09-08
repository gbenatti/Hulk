namespace Hulk.Core

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.PatternMatching

macro dependsOn:
    case [| dependsOn $arg |]:
        match arg:
            case MethodInvocationExpression(Target, Arguments):
                invoke = [| invoke($(Target.ToString())) |]
                invoke.Arguments.Extend(Arguments)
                yield invoke
                
            otherwise:
                yield [| invoke($(arg.ToString())) |]
