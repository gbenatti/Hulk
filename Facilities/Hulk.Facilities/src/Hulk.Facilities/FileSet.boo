#############################################################################
# Based on Class FileSet from NUncle by "Ayende Rahien"

namespace Hulk.Facilities

import System
import System.IO     
import System.Globalization
import System.Collections            
import System.Text.RegularExpressions
import System.Collections.Generic

class FileSet:
	
	class Entry:
		[property(RegEx)]
		_re as regex
		[property(IsRecursive)]
		_recus as bool
		[property(BaseDirectory)]
		_baseDir as string
	
		def constructor(re as regex,  baseDir as string, recursive as bool):
			_re = re
			_recus = recursive
			_baseDir = baseDir
		
	# Escape windows' path seperator if neccecary
	static _seperator = Path.DirectorySeparatorChar.ToString(CultureInfo.InvariantCulture).Replace("\\","\\\\")
	 
	# replacements to do on the incoming patterns
	# the right side is the regex, the left side the replacing string
	# order IS meaningful
	static _patterns = (
	# This escpae the regex special characters
		("\\.","\\."), 
		("\\$","\\$"), 
		("\\^","\\^"), 
		("\\{","\\{"),
		("\\[","\\["),
		("\\(","\\("),
		("\\)","\\)"),
		("\\+","\\+"),
	# Select single character which is not a seperator
		("\\?","[^"+_seperator+"]?"),
	# Replace /*/ or /* with a search for 1..n instead of 0..n
	# This make sure that /*/ can't match "//" and that /ayende/* doesn't 
	# match "/ayende/"
		("(?<="+_seperator+")\\*(?=($|"+_seperator+"))","[^"+_seperator+"]+"),
	# Handle matching in the current directory an in all subfolders, so things
	# like src/**/*.cs will work
	# the ".|" is a placeholder, to avoid overwriting the value in the next regexes
		(_seperator + "\\*\\*" + _seperator, _seperator + "(.|?" + _seperator + ")?"),
	   	("\\*\\*" + _seperator, ".|(?<=^|" + _seperator + ")"),
	   	("\\*\\*",".|"),
	   	("\\*","[^"+_seperator+"]*"),
	# Here we fix all the .| problems we had before
	   	("\\.\\|","\\.*"),
	# This handles the case where the path is recursive but it doesn't ends with a
	# wild card, for example: **/bin, you want all the bin directories, but nothing more
		("(?<=[^\\?\\*])$","$")
		)
		
	_baseDirectory as string = Environment.CurrentDirectory
	virtual BaseDirectory as string:
		get:
			return _baseDirectory
		set:
			_baseDirectory = value
			
	[property(ThrowOnEmpty)]
	_throwOnEmpty = false
	
	_files = List of string()
	_directories = List of string()
	
	_scannedDirectories = List of string()
	# This is a hashtable whose keys are directories and value 
	# is whatever the directory is recursive or not
	_directoriesToScan = {}
	_scanned = false
	
	# This contain the compiled regex patterns
	_includes = []
	_excludes = []
	
	def constructor():
		_baseDirectory = DirectoryInfo(_baseDirectory).FullName
	
	def constructor(glob as string):
		_baseDirectory = DirectoryInfo(_baseDirectory).FullName
		Include(glob)
		
	def constructor(globs as List of string):
		_baseDirectory = DirectoryInfo(_baseDirectory).FullName
		for glob in globs:
			Include(glob)
			
	static def op_Implicit(patterns as Boo.Lang.List) as FileSet:
		fs = FileSet()
		for pattern in patterns:
			fs.Include(pattern)
		return fs

	def Include(pattern as string):
		AddRegEx(pattern,_includes)
		return self
		
	def Exclude(pattern as string):
		AddRegEx(pattern,_excludes)
		return self				
	
	protected def AddRegEx(pattern as string, list as IList): 
		cleanPattern = CleanPattern(pattern)
		firstWildCardIndex = cleanPattern.IndexOfAny("?*".ToCharArray())
		lastOriginalDirSeperator = cleanPattern.LastIndexOf(Path.DirectorySeparatorChar)
		
		if firstWildCardIndex != -1:
			modifiedPattern = cleanPattern.Substring(0,firstWildCardIndex)
		else:
			modifiedPattern = cleanPattern
		lastDirSeperatorWithoutWildCards = modifiedPattern.LastIndexOf(Path.DirectorySeparatorChar)
		regexPattern = cleanPattern.Substring(lastDirSeperatorWithoutWildCards+1);
		
		recursive = IsRecursive(cleanPattern, firstWildCardIndex, lastOriginalDirSeperator)
		baseDir = GetPatternDirectory(modifiedPattern, lastDirSeperatorWithoutWildCards)
		re = FormatRegex(regexPattern)
		entry = Entry(re,baseDir,recursive)
		
		# add directory to search and set it to recurs if it isn't already
		if(not _directoriesToScan[baseDir]):
			_directoriesToScan.Add(baseDir,recursive)  
		# This won't set it if it's false, so we won't override a
		# value of true.
		_directoriesToScan[baseDir] = true if recursive
		
		list.Add(entry)
		return entry
	
	private def GetPatternDirectory(pattern as string, lastDirSeperator as int) as string:
		searchDir = pattern
		
		if(lastDirSeperator != -1):
			searchDir = pattern.Substring(0,lastDirSeperator)
			searchDir += Path.DirectorySeparatorChar if searchDir.EndsWith(Path.VolumeSeparatorChar.ToString())
		else:                                                                       
			searchDir = string.Empty
		
		if not Path.IsPathRooted(searchDir):
			searchDir = Path.Combine(BaseDirectory, searchDir)
		
		return DirectoryInfo(searchDir).FullName

	# A pattern is recursive if:
	# 	- It contain ** - the directory wildcard
	#	- It contain a wildcard before the last directory seperator
	#	- It ends with a directory seperator - but this is handled in the CleanPattern() method
	private def IsRecursive(pattern as string, firstWildCardIndex as int, lastDirSeperator as int) as bool:
		hasDirWildCard = pattern.IndexOf("**")!=-1
		return hasDirWildCard or \
			firstWildCardIndex<lastDirSeperator
		
	Files:
		get:
			if not _scanned: Scan()
			return _files
	
	Directories:
		get:
			if not _scanned: Scan()
			return _directories
			
	private def FormatRegex(pattern as string) as regex:
		result = pattern
		for re,replacement in _patterns:
			result = regex(re).Replace(result,replacement)
		reOpts = RegexOptions.Compiled
		reOpts = reOpts | RegexOptions.IgnoreCase if not CaseSensitiveFileSystem()
		return Regex(result,reOpts)
	
	def ContainFileMoreRecentThan(lastWrite as DateTime) as bool:
		for file in Files:
			if File.GetLastWriteTime(file) > lastWrite:
				return true
		return false
		
	# replace '/' and '\' with the platform directory seperator
	# apped ** if the path ends with a directory seperator
	private def CleanPattern(pattern as string) as string:
		s = FileSystemHelper.CleanPattern(pattern)
		s += "**" if s.EndsWith(Path.DirectorySeparatorChar.ToString())
		return s
		
	virtual def Scan():       
		_files = List of string()
		_directories = List of string()
		_scannedDirectories = List of string()
		_scanned = false
		for entry in _directoriesToScan:
			ScanDir(entry.Key as string, entry.Value)
		_scanned = true
		if ThrowOnEmpty and _directories.Count == 0 and _files.Count==0:
			raise FileSetEmptyException();
		
	protected def ScanDir(path as string, recursive as bool):
		if _scannedDirectories.Contains(path): return
		_scannedDirectories.Add(path)  
		if not Directory.Exists(path): return
			
		pathCompare = path.ToLower() if not CaseSensitiveFileSystem()
		
		includeEntries = GetEntriesForPath(pathCompare, _includes)
		excludeEntries = GetEntriesForPath(pathCompare, _excludes)

		for directory in Directory.GetDirectories(path):
			# If recursive, then it'll have a chance to add itself on the recused ScanDir
			# otherwise, let it have a go and add it if need to
			if (recursive):
				ScanDir(directory, recursive)
			else:
				_directories.Add(directory) if IncludePath(directory, includeEntries, excludeEntries)
		
		for file in Directory.GetFiles(path):
			_files.Add(file) if IncludePath(file, includeEntries, excludeEntries)
		
		_directories.Add(path) if IncludePath(pathCompare, includeEntries, excludeEntries)
		
	private def IncludePath(path as string, includeEntries as IList, excludeEntries as IList) as bool:
		match = false           
		for entry as Entry in includeEntries:
			if (CheckPath(entry,path)):
				match = true
				break
		if(match):
			for entry as Entry in excludeEntries:
				return false if CheckPath(entry,path)
		return match
	
	public def CheckPath(entry as Entry, path as string):
		length = entry.BaseDirectory.Length
		pathWithoutBase = path.Substring(length)
		return entry.RegEx.IsMatch(pathWithoutBase)
		
	protected def GetEntriesForPath(path as string, list as IList): 
		entries = []
		for entry as Entry in list:
			base = entry.BaseDirectory
			base = base.ToLower() if not CaseSensitiveFileSystem()
			if(AreEqual(path,base)):
				entries.Add(entry)
			else:
				if(entry.IsRecursive):
					base += Path.DirectorySeparatorChar if not base.EndsWith(Path.DirectorySeparatorChar.ToString())
					if(path.StartsWith(base)):
						entries.Add(entry)
		return entries
	
	private def AreEqual(first as string, second as string) as bool:
		co = CompareOptions.None
		co = co | CompareOptions.IgnoreCase if not CaseSensitiveFileSystem()
		return CultureInfo.InvariantCulture.CompareInfo.Compare(first,second,co) == 0

	# Assume that only unix is case sensitive because Win32 & Mac OS
	# are not
	# 128 is the value of Unix in mono's PlatformID
	private def CaseSensitiveFileSystem() as bool:
		return cast(int,Environment.OSVersion.Platform) == 128
