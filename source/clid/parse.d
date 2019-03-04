module clid.parse;

import std.stdio : writeln, stderr;
import core.stdc.stdlib : exit;
import std.traits : hasUDA, getUDAs, hasMember, getSymbolsByUDA;
import std.conv : text;

import clid.basicattributes;
import clid.help;
import clid.util;
import clid.validate;

alias StringConsumer = void delegate(string);

/*
private struct ParseState
{
	bool expectArgument = false;
	StringConsumer argumentConsumer = null;
}
*/

private struct ParseState(C)
{
	bool expectArgument = false;
	StringConsumer argumentConsumer = null;
	mixin RequireStruct!C requires;
}

private mixin template RequireStruct(C)
{
	static foreach (member; getSymbolsByUDA!(C, Required))
	{
		mixin("bool " ~ member.stringof ~ ";");
	}
}

private C parse(C)(string[] args)
{
	ValidateStruct!C();
	C c;
	ParseState!C state;

	foreach (string arg; args)
	{
		if (state.expectArgument == true)
		{
			state.argumentConsumer(arg);
			state.expectArgument = false;
		}
		else if (arg == "-h" || arg == "--help")
		{
			printHelp(c);
			exit(0);
		}
		else
		{
			parseArgument(state, c, arg);
		}
	}

	if (state.expectArgument)
	{
		stderr.writeln("Incomplete argument");
		exit(1);
	}
	checkRequires(state);

	return c;
}

private void checkRequires(C)(ref ParseState!C state)
{
	bool failed = false;
	static foreach (member; __traits(allMembers, state.requires))
	{
		if (!mixin("state.requires." ~ member))
		{
			stderr.writeln("Missing required argument --" ~ getUDAs!(Value!(C,
					member), Parameter)[0].longName);
			failed = true;
		}
	}
	if (failed)
		exit(1);
}

private void parseArgument(C)(ref ParseState!C state, ref C c, string arg)
{
	if (arg.length < 2)
		fail("Malformed argument '" ~ arg ~ "'");
	else if (arg[0] == '-' && arg[1] != '-')
	{
		foreach (flag; arg[1 .. $ - 1])
		{
			parseShortArgument(state, c, flag);
		}
		parseShortArgument(state, c, arg[$ - 1], true);
	}
	else if (arg.length >= 3 && arg[0] == '-' && arg[1] == '-')
	{
		parseLongArgument(state, c, arg[2 .. $]);
	}
	else
		fail("Malformed argument '" ~ arg ~ "'");
}

private void parseShortArgument(C)(ref ParseState!C state, ref C c, dchar flag,
		immutable bool allowArgs = false)
{
	foreach (member; __traits(allMembers, C))
	{
		static if (hasUDA!(__traits(getMember, c, member), Parameter))
		{
			if (getUDAs!(__traits(getMember, c, member), Parameter)[0].shortName == flag)
			{
				static if (is(typeof(__traits(getMember, c, member)) == bool))
				{
					__traits(getMember, c, member) = true;
					return;
				}
				else
				{
					if (allowArgs)
					{
						import std.conv : to;

						state.expectArgument = true;
						state.argumentConsumer = (value) {
							static if (hasUDAV!(c, member, Required))
								mixin("state.requires." ~ member ~ " = true;");
							__traits(getMember, c, member) = to!(typeof(__traits(getMember,
									c, member)))(value);
						};
						return;
					}
					else
						fail("Illegal argument " ~ flag.text);
				}
			}
		}
	}
	fail("Unkown argument " ~ flag.text);
}

private void parseLongArgument(C)(ref ParseState!C state, ref C c, string arg)
{
	foreach (member; __traits(allMembers, C))
	{
		static if (hasUDA!(__traits(getMember, c, member), Parameter))
		{
			if (getUDAs!(__traits(getMember, c, member), Parameter)[0].longName == arg)
			{
				static if (is(typeof(__traits(getMember, c, member)) == bool))
				{
					__traits(getMember, c, member) = true;
					return;
				}
				else
				{
					import std.conv : to;

					state.expectArgument = true;
					state.argumentConsumer = (value) {
						static if (hasUDAV!(c, member, Required))
							mixin("state.requires." ~ member ~ " = true;");
						__traits(getMember, c, member) = to!(typeof(__traits(getMember, c, member)))(
								value);
					};
					return;
				}
			}
		}
	}
	fail("Illegal argument " ~ arg);
}

private void fail(string message)
{
	writeln(message);
	exit(1);
}

/**
 * Validates a configuration struct.
 * Each property should be marked using @Validate!validator.
 * The validator will be called using the argument used (e.g.: "--help"),
 * and with the actual value given.
 * Params: c = The configuration struct to validate.
 */
void validateConfig(C)(C c)
{
	foreach (member; __traits(allMembers, C))
	{
		static if (hasUDA!(__traits(getMember, c, member), Parameter))
		{
			Parameter parameter = getUDAs!(__traits(getMember, c, member), Parameter)[0];
			foreach (uda; getUDAs!(__traits(getMember, c, member), Validate))
			{
				if (uda("--" ~ parameter.longName, __traits(getMember, c, member)) == false)
					exit(1);
			}
		}
	}
}

// ======================
// Unit tests start here.
// ======================

unittest
{
	struct Config
	{
		@Parameter("foo", 'f')
		string value;

		@Parameter("num", 'n')
		int number;

		@Parameter("req", 'r')
		@Required int required;

		@Parameter("bool", 'b')
		bool b;
	}

	immutable Config config = parse!Config(["--foo", "a_string", "-b", "-n", "5", "--req"]);
	import std.stdio : writeln;

	assert(config.value == "a_string", "String value not read from arguments");
	assert(config.number == 5, "Integer value not read from arguments");
	assert(config.b == true, "Bool not set from arguments");
}

unittest
{

	struct Config
	{
		@Parameter("bool", 'b')
		bool b;

		@Parameter("file", 'f') @Validate!doesNotExist string file;
	}

	immutable Config config = parse!Config(["-bf", "some-random-file-that-should-not-exist"]);
	config.validateConfig();
	import std.stdio : writeln;

	assert(config.file == "some-random-file-that-should-not-exist",
			"String not read from arguments");
	assert(config.b == true, "Bool not set from arguments");
}
