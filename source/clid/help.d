module clid.help;

import std.traits : hasUDA, getUDAs;
import std.meta : Alias;
import std.string : leftJustify;

import clid.basicattributes;
import clid.util;

/**
 * Print help information for a given configuration struct.
 * Params: c = The configuration struct to print help information for.
 */
void printHelp(C)(C c)
{
	import std.stdio : stderr;

	ValidateStruct!C();
	stderr.write(getHelp(c));
}

private string getHelp(C)(C c) // @suppress(dscanner.suspicious.unused_parameter)
{
	import std.ascii : newline;

	string str = usage() ~ newline ~ newline;

	static foreach (member; __traits(allMembers, C))
	{
		str ~= Describe!(__traits(getMember, c, member)) ~ newline;
	}
	str ~= "\t-h, --help".leftJustify(30) ~ "Show this help\n";
	return str;
}

private template GetFlagName(alias E)
{
	static assert(getUDAs!(E, Parameter).length == 1, "Must have at most 1 @Parameter attribute.");
	static if (getUDAs!(E, Parameter)[0].shortName == ' ')
	{
		alias GetFlagName = Alias!("    --" ~ getUDAs!(E, Parameter)[0].longName);
	}
	else
	{
		alias GetFlagName = Alias!("-" ~ getUDAs!(E,
				Parameter)[0].shortName ~ ", --" ~ getUDAs!(E, Parameter)[0].longName);
	}
}

private template GetFlagValue(alias E)
{
	import std.uni : toUpper;

	static if (hasUDA!(E, Description) && getUDAs!(E, Description)[0].optionType.length > 0)
	{
		alias GetFlagValue = Alias!(" " ~ getUDAs!(E, Description)[0].optionType);
	}
	else static if (is(typeof(E) : bool))
	{
		alias GetFlagValue = Alias!("");
	}
	else
	{
		alias GetFlagValue = Alias!(" " ~ typeof(E).stringof.toUpper);
	}
}

private template GetFlag(alias E)
{
	alias GetFlag = Alias!(GetFlagName!(E) ~ GetFlagValue!(E));
}

private template GetDescriptionOnly(alias E)
{
	static if (hasUDA!(E, Description))
		alias GetDescriptionOnly = Alias!(getUDAs!(E, Description)[0].description);
	else
		alias GetDescriptionOnly = Alias!("");
}

private template GetDescription(alias E)
{
	static if (hasUDA!(E, Required))
		alias GetDescription = Alias!("[REQUIRED] " ~ GetDescriptionOnly!(E));
	else
		alias GetDescription = GetDescriptionOnly!(E);
}

private template Describe(alias E)
{
	static if (!hasUDA!(E, Description) && !hasUDA!(E, Required))
	{
		alias Describe = Alias!('\t' ~ GetFlag!(E));
	}
	else
	{
		alias Describe = Alias!(leftJustify('\t' ~ GetFlag!(E), 30) ~ GetDescription!(E));
	}
}

private string usage()
{
	import core.runtime : Runtime;

	return "Usage: " ~ Runtime.args()[0] ~ " [OPTION...]";
}

// ======================
// Unit tests start here.
// ======================

unittest
{
	struct Config
	{
		@Parameter("foo", 'f')
		@Description("Foobar")
		int value;

		@Parameter("str", 's')
		@Description("Just a string")
		string stringValue;

		@Parameter("time", 't')
		@Description("Interval time", "secs")
		int time;

		@Parameter("bar")
		@Description("A random description")
		@Required bool other;
	}

	immutable Config config;
	static assert(GetFlag!(config.value) == "-f, --foo INT");
	static assert(GetDescription!(config.value) == "Foobar");

	printHelp(config);
}

unittest
{
	struct Config
	{
		@Parameter("foo")
		int value;
	}

	immutable Config config;
	static assert(GetFlag!(config.value) == "    --foo INT");
	//static assert(Describe!(config.value) == "\t    --foo INT");
}
