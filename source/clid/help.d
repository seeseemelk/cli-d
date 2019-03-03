module clid.help;

import std.traits : getUDAs;
import std.meta : Alias;

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
    str ~= "\t-h, --help\tShow this help\n";
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

    static if (is(typeof(E) : bool))
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

private template GetDescription(alias E)
{
    static assert(getUDAs!(E, Description).length == 1,
            "Must have at most 1 @Description attribute.");
    alias GetDescription = Alias!(getUDAs!(E, Description)[0].description);
}

private template Describe(alias E)
{
    static if (getUDAs!(E, Description).length == 0)
    {
        alias Describe = Alias!('\t' ~ GetFlag!(E));
    }
    else
    {
        alias Describe = Alias!('\t' ~ GetFlag!(E) ~ '\t' ~ GetDescription!(E));
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

        @Parameter("bar")
        bool other;
    }

    immutable Config config;
    static assert(GetFlag!(config.value) == "-f, --foo INT");
    static assert(GetDescription!(config.value) == "Foobar");
    static assert(Describe!(config.value) == "\t-f, --foo INT\tFoobar");

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
    static assert(Describe!(config.value) == "\t    --foo INT");
}
