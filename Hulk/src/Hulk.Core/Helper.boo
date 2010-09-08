namespace Hulk.Core

class Collection:
	[extension]
	static def Flatten([required] collection as System.Collections.ICollection):
		if len(collection) == 0: return []		
		return internalFlatten(collection)

	static def internalFlatten(data as object) as List:
		result = []
		for item in data:
			result += (internalFlatten(item) if item isa System.Collections.ICollection else [item])
				
		return result