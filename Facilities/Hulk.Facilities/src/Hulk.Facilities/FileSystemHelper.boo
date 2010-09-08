namespace Hulk.Facilities

import System
import System.IO

class FileSystemHelper:
"""Description of FileSystemHelper"""

	# Convert / or \ to the normal directory seperator
	static def CleanPattern(pattern as string) as string:
		s = pattern.Replace(char('/'),Path.DirectorySeparatorChar)
		return s.Replace(char('\\'),Path.DirectorySeparatorChar)
