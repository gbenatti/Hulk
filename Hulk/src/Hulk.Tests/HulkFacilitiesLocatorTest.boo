namespace Hulk.Tests

import Boospec
import Boospec.ShouldMatcher

import System.IO

import Hulk.Core

fixture "Hulk Facilities Locator":
	declare:
		_tempPath as string
		
	setup:
		_tempPath = Path.GetTempPath()
		createFixtureFiles(_tempPath)

	testing "Should locate files in the facilities directory":
		locator = HulkFacilitiesLocator(_tempPath)
		locator.getFiles().Should.Have.Count == 3
		
	testing "Should combine files in the facilities directory and specific Oses ones":
		locator = HulkFacilitiesLocator(_tempPath)
		locator.getFiles(OsTypes.Win32).Should.Have.Count == 5
		locator.getFiles(OsTypes.OsX).Should.Have.Count == 6
		locator.getFiles(OsTypes.Unix).Should.Have.Count == 7

def createFixtureFiles(tempPath as string):
	facilitiesPath = Path.Combine(tempPath, "facilities")
	win32Path 		= Path.Combine(facilitiesPath, "win32")
	osxPath 		= Path.Combine(facilitiesPath, "osx")
	unixPath 		= Path.Combine(facilitiesPath, "unix")
		
	Directory.CreateDirectory(facilitiesPath)
	Directory.CreateDirectory(win32Path)
	Directory.CreateDirectory(osxPath)
	Directory.CreateDirectory(unixPath)
		
	touch(Path.Combine(facilitiesPath, "1.dll"))
	touch(Path.Combine(facilitiesPath, "2.dll"))
	touch(Path.Combine(facilitiesPath, "3.dll"))
	
	touch(Path.Combine(win32Path, "2.dll"))
	touch(Path.Combine(win32Path, "3.dll"))

	touch(Path.Combine(osxPath, "3.dll"))
	touch(Path.Combine(osxPath, "4.dll"))
	touch(Path.Combine(osxPath, "5.dll"))

	touch(Path.Combine(unixPath, "3.dll"))
	touch(Path.Combine(unixPath, "5.dll"))
	touch(Path.Combine(unixPath, "6.dll"))
	touch(Path.Combine(unixPath, "7.dll"))
	
def touch(filename as string):
	using f = File.CreateText(filename):
		f.Write("")

	