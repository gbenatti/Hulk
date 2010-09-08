namespace Hulk.Facilities.Osx

class IO:
# Permissions helpers

	[extension]
	static def changeMod(hulk as Hulk.Core.Hulk, filename as string, mode as int):
		Mono.Unix.Native.Syscall.chmod(filename, Mono.Unix.Native.FilePermissions.ToObject(Mono.Unix.Native.FilePermissions, mode))
