namespace Hulk

// experimental

class Blinq:
	static def first[of TSource]([required] collection as System.Collections.Generic.ICollection[of TSource]):
		if len(collection) == 0: raise System.InvalidOperationException("The collection is empty")
		e = collection.GetEnumerator()
		return e.Current
			
	static def last[of TSource]([required] collection as System.Collections.Generic.ICollection[of TSource]):
		if len(collection) == 0: raise System.InvalidOperationException("The collection is empty")
		data = [item for item in collection]
		return data[-1]
	
	static def singleOrDefault[of TSource]([required] collection as System.Collections.Generic.ICollection[of TSource], predicate as callable(TSource) as bool) as TSource:
		data = [item for item in collection if predicate(item)]
		if len(data) == 1: return data[0]
		if len(data) > 1: raise System.InvalidOperationException("The collection has more then one valid item")
		return
	
	static def max[of TSource]([required] collection as System.Collections.Generic.ICollection[of TSource], [required] comparer as callable(TSource, TSource) as int) as TSource:
		if len(collection) == 0: raise System.InvalidOperationException("The collection is empty")
		if len(collection) == 1: return first(collection)
		e = collection.GetEnumerator()
	
		lastItem = null
		biggerItem = null
		while (e.MoveNext()):
			if lastItem == null:
				lastItem = e.Current
				biggerItem = e.Current
			else:
				if comparer(e.Current, lastItem) > 0:
					biggerItem = e.Current
				lastItem = e.Current
		
		return biggerItem

		
[meta]
def select(thisReference as Boo.Lang.Compiler.Ast.Expression, method as Boo.Lang.Compiler.Ast.ReferenceExpression):
	return [| x.$(method)() for x in $(thisReference) |]
	