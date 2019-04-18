module clid.core.help;

import std.traits : hasUDA, getUDAs;
import std.meta : Alias;
import std.string : leftJustify;

import clid.attributes;
import clid.core.util;

/**
 * Print help information for a given configuration struct.
 * Params: c = The configuration struct to print help information for.
 */
void printHelp(C)(C c)
{
	import std.stdio : stderr;

	validateStruct!C();
	stderr.write(getHelp(c));
}

private string getHelp(C)(C c) // @suppress(dscanner.suspicious.unused_parameter)
{
	import std.ascii : newline;

	string str = usage() ~ newline ~ newline;

	static foreach (member; __traits(allMembers, C))
	{
		str ~= describe!(__traits(getMember, c, member)) ~ newline;
	}

	static if (!hasShortParameter!(C)('h') && !hasLongParameter!C("help"))
	{
		str ~= "\t-h, --help".leftJustify(30) ~ "Show this help\n";
	}
	else static if (!hasShortParameter!C('h'))
	{
		str ~= "\t    --help".leftJustify(30) ~ "Show this help\n";
	}
	else static if (!hasLongParameter!C("help"))
	{
		str ~= "\t-h        ".leftJustify(30) ~ "Show this help\n";
	}
	return str;
}

private template getFlagName(alias E)
{
	static if (getParameter!(E).shortName == ' ')
	{
		alias getFlagName = Alias!("    --" ~ getParameter!(E).longName);
	}
	else
	{
		alias getFlagName = Alias!("-" ~ getParameter!(E)
				.shortName ~ ", --" ~ getParameter!(E).longName);
	}
}

private template getFlagUnit(alias E)
{
	import std.uni : toUpper;

	static if (hasDescription!(E) && getDescription!(E).optionUnit.length > 0)
	{
		alias getFlagUnit = Alias!(" " ~ getDescription!(E).optionUnit);
	}
	else static if (is(typeof(E) : bool))
	{
		alias getFlagUnit = Alias!("");
	}
	else
	{
		alias getFlagUnit = Alias!(" " ~ typeof(E).stringof.toUpper);
	}
}

private template getFlag(alias E)
{
	alias getFlag = Alias!(getFlagName!(E) ~ getFlagUnit!(E));
}

private template getOnlyDescription(alias E)
{
	static if (hasDescription!(E))
		alias getOnlyDescription = Alias!(getDescription!(E).description);
	else
		alias getOnlyDescription = Alias!("");
}

private template getFullDescription(alias E)
{
	static if (hasUDA!(E, Required))
		alias getFullDescription = Alias!("[REQUIRED] " ~ getOnlyDescription!(E));
	else
		alias getFullDescription = getOnlyDescription!(E);
}

private template describe(alias E)
{
	static if (!hasUDA!(E, Description) && !hasUDA!(E, Required))
	{
		alias describe = Alias!('\t' ~ getFlag!(E));
	}
	else
	{
		alias describe = Alias!(leftJustify('\t' ~ getFlag!(E), 30) ~ getFullDescription!(E));
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
	static assert(getFlag!(config.value) == "-f, --foo INT");
	static assert(getFullDescription!(config.value) == "Foobar");

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
	static assert(getFlag!(config.value) == "    --foo INT");
}
