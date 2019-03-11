module clid.validate;

import std.stdio : stderr;
import std.traits : FunctionTypeOf, Parameters;

/**
 * Validates a command line argument.
 */
bool Validate(alias f)(string arg, int n) @property // @suppress(dscanner.style.phobos_naming_convention)
if (is(FunctionTypeOf!(f) == function) && is(Parameters!(f)[1] == int))
{
	return f(arg, n);
}

/**
 * Validates a command line argument.
 */
bool Validate(alias f)(string arg, string str) @property // @suppress(dscanner.style.phobos_naming_convention)
if (is(FunctionTypeOf!(f) == function) && is(Parameters!(f)[1] == string))
{
	return f(arg, str);
}

/**
 * Validates that the string is not empty.
 */
bool isNotEmpty(string arg, string str)
{
	if (str.length == 0)
	{
		stderr.writeln("Argument " ~ arg ~ " must not be empty string");
		return false;
	}
	return true;
}

/**
 * Validates that argument refers to a valid file.
 */
bool isFile(string arg, string str)
{
	import std.file : exists, fileIsFile = isFile;

	if (!str.exists || !str.fileIsFile)
	{
		stderr.writeln("Argument " ~ arg ~ " must refer to a file that exists");
		return false;
	}
	return true;
}

/**
 * Validates that argument refers to a valid directory.
 */
bool isDir(string arg, string str)
{
	import std.file : exists, dirIsDir = isDir;

	if (!str.exists || !str.dirIsDir)
	{
		stderr.writeln("Argument " ~ arg ~ " must refer to a directory that exists");
		return false;
	}
	return true;
}

/**
 * Validates that the argument does not refer to anything on the filesystem.
 */
bool doesNotExist(string arg, string str)
{
	import std.file : exists;

	if (str.exists)
	{
		stderr.writeln("Argument " ~ arg ~ " must not refer to a file that already exists");
		return false;
	}
	return true;
}

bool isPositive(string arg, int value)
{
	if (value < 0)
	{
		stderr.writeln("Argument " ~ arg ~ " must be positive");
		return false;
	}
	return true;
}

bool isNegative(string arg, int value)
{
	if (value > 0)
	{
		stderr.writeln("Argument " ~ arg ~ " must be negative");
		return false;
	}
	return true;
}

bool isPortNumber(string arg, int value)
{
	if (value > 0 && value < 65536)
		return true;
	stderr.writeln("Argument " ~ arg ~ " must be a port number within range of [1, 65535]");
	return false;
}
