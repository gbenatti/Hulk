namespace Hulk.Core

import System.IO

import Boobel.Attributes

import Hulk.Core.Collection

enum OsTypes:
	Win32 = 1
	OsX = 2
	Unix = 4

class HulkFacilitiesLocator:

	_facilitiesPath as string

	static def getRelevantOSType():
		return OsTypes.OsX

	def constructor([let] directory as string):
		_facilitiesPath = Path.Combine(directory, "facilities")

	def getFiles():
		return List[of string](getFilesForPath("."))
		
	def getFiles(oses as OsTypes):
		paths = getPathsForOses(oses)
		return List[of string](getFilesForPaths(paths))

	private def getPathsForOses(oses as OsTypes):
		return ["."] + [entry.Value for entry in {OsTypes.Win32: "win32", OsTypes.OsX: "osx", OsTypes.Unix: "unix"} if cast(OsTypes, entry.Key) & oses]

	private def getFilesForPaths(paths as List) as List:
		result = [getFilesForPath(path) for path in paths].Flatten()
		return result

	private def getFilesForPath(path as string) as List:
		targetPath = Path.Combine(_facilitiesPath, path)
		if not Directory.Exists(targetPath): return []
		return [item for item in Directory.GetFiles(targetPath, "*.dll")]
