namespace Hulk.Core

import System.ComponentModel
import System.Reflection

import Boobel.Dynamic

class Hulk:
	_executedTasks = []
	
	def invoke(task as string, *params as (object)):
		return if task in _executedTasks
		
		_executedTasks.AddUnique(task)
		
		paramsInfo = getParametersInfo(task)
		adapted = array(adaptParameter(param, info.ParameterType) for param, info as ParameterInfo in zip(params, paramsInfo))
		
		self.send(task, adapted)
		
	private def getParametersInfo(method as string):
		target = self.GetType().GetMethod(method)
		return target.GetParameters()
		
	private def adaptParameter(param as object, targetType as System.Type):
		return param if param.GetType() == targetType
		asText = TypeDescriptor.GetConverter(param.GetType()).ConvertToString(param)
		return TypeDescriptor.GetConverter(targetType).ConvertFromString(asText)
