namespace Hulk.Facilities

import System
import System.IO
import System.Collections.Generic

class IO:
	[extension]
	static def exist(hulk as Hulk.Core.Hulk, name as string):
		return File.Exists(name) or Directory.Exists(name)

# Copy methods

	[extension]
	static def copy(hulk as Hulk.Core.Hulk, source as string, target as string):
		File.Copy(source, target)
	
	[extension]
	static def copy(hulk as Hulk.Core.Hulk, source as string, target as string, overwrite as bool):
		File.Copy(source, target, overwrite)

	[extension]
	static def copy(hulk as Hulk.Core.Hulk, sources as FileSet, targetDir as string):
		for source in sources.Files:
			target = Path.Combine(targetDir, Path.GetFileName(source))
			File.Copy(source, target)

	[extension]
	static def copy(hulk as Hulk.Core.Hulk, sources as FileSet, targetDir as string, overwrite as bool):
		for source in sources.Files:
			target = Path.Combine(targetDir, Path.GetFileName(source))
			File.Copy(source, target, overwrite)

# Move methods

	[extension]
	static def move(hulk as Hulk.Core.Hulk, source as string, target as string):
		File.Move(source, target)

# Remove methods
	
	[extension]
	static def remove(hulk as Hulk.Core.Hulk, filename as string):
		File.Delete(filename)
	
	[extension]
	static def remove(hulk as Hulk.Core.Hulk, dirname as string, pattern as string):
		for fname in Directory.GetFiles(dirname, pattern):
			File.Delete(fname)

	[extension]
	static def remove(hulk as Hulk.Core.Hulk, sources as FileSet):
		for fname in sources.Files:
			File.Delete(fname)

# Directory methods

	[extension] 
	static def makeDir(hulk as Hulk.Core.Hulk, path as string):
		Directory.CreateDirectory(path)

	[extension]
	static def removeDir(hulk as Hulk.Core.Hulk, dirname as string):
		Directory.Delete(dirname)
	
	[extension]
	static def removeDir(hulk as Hulk.Core.Hulk, path as string, recursive as bool):
		Directory.Delete(path, recursive)

# Uptodate helper methods

	[extension]
	static def isUpToDate(hulk as Hulk.Core.Hulk, target as string, source as string):
		return true unless File.Exists(source)
		return false unless File.Exists(target)

		targetInfo = FileInfo(target)
		sourceInfo = FileInfo(source)

		return targetInfo.LastAccessTimeUtc >= sourceInfo.LastAccessTimeUtc

	[extension]
	static def isUpToDate(hulk as Hulk.Core.Hulk, target as string, sources as FileSet):
		for source in sources.Files:
			if not hulk.isUpToDate(target, source): return false
	
		return true

# FileSet wrapper methods

	[extension]
	static def fileset(hulk as Hulk.Core.Hulk):
		return FileSet()

	[extension]
	static def fileset(hulk as Hulk.Core.Hulk, glob as string):
		return FileSet(glob)
	
	[extension]
	static def fileset(hulk as Hulk.Core.Hulk, globs as List of string):
		return FileSet(globs)

# Textfile helper methods
		
	[extension]
	static def prependText(hulk as Hulk.Core.Hulk, filename as string, text as string):
		return unless hulk.exist(filename)
		
		original = hulk.readTextFile(filename)
		hulk.writeTextFile(filename, text + original)

	[extension]
	static def prependText(hulk as Hulk.Core.Hulk, targets as FileSet, text as string):
		for file in targets.Files:
			hulk.prependText(file, text)

	[extension]
	static def readTextFile(hulk as Hulk.Core.Hulk, filename as string):
		return File.ReadAllText(filename)
		
	[extension]
	static def writeTextFile(hulk as Hulk.Core.Hulk, filename as string, text as string):
		File.WriteAllText(filename, text)
		
	[extension]
	static def getFirstLine(hulk as Hulk.Core.Hulk, filename as string):
		try:
			f=File.OpenText(filename)
			return f.ReadLine()
		ensure:
			f.Dispose() unless f is null
