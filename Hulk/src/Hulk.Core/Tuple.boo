namespace Hulk.Core
/*
macro definetuple(count as int):
	className = "Tuple${len(types)}"
	yield [|
		class $className:
			pass
	|]
*/

class Tuple[of T]:
	public _1 as T
	
	def constructor(t1 as T):
		_1 = t1
		
	override def ToString():
		return "(${_1})"

class Tuple2[of T1, T2]:
	public _1 as T1
	public _2 as T2
	
	def constructor(t1 as T1, t2 as T2):
		_1 = t1
		_2 = t2

	override def ToString():
		return "(${_1}, ${_2})"

class Tuple3[of T1, T2, T3]:
	public _1 as T1
	public _2 as T2
	public _3 as T3
	
	def constructor(t1 as T1, t2 as T2, t3 as T3):
		_1 = t1
		_2 = t2
		_3 = t3

	override def ToString():
		return "(${_1}, ${_2}, ${_3})"

class Tuple4[of T1, T2, T3, T4]:
	public _1 as T1
	public _2 as T2
	public _3 as T3
	public _4 as T4
	
	def constructor(t1 as T1, t2 as T2, t3 as T3, t4 as T4):
		_1 = t1
		_2 = t2
		_3 = t3
		_4 = t4

	override def ToString():
		return "(${_1}, ${_2}, ${_3}, ${_4})"
