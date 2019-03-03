module clid.parse;

import std.stdio : writeln;
import core.stdc.stdlib : exit;
import std.traits : hasUDA, getUDAs, hasMember;
import std.conv : text;

import clid.basicattributes;
import clid.help;
import clid.util;

alias StringConsumer = void delegate(string);

private struct ParseState
{
    bool expectArgument = false;
    StringConsumer argumentConsumer = null;
}

private C parse(C)(string[] args)
{
    ValidateStruct!C();
    C c;
    //StringConsumer nextArgumentConsumer = null;
    ParseState state;

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

    return c;
}

private void parseArgument(C)(ref ParseState state, ref C c, string arg)
{
    /*if (arg.length < 2)
        fail("Malformed argument '" ~ arg ~ "'");
    else if (arg.length == 2)
    {
        if (arg[0] != '-' || arg[1] == '-')
            fail("Malformed argument '" ~ arg ~ "'");
        else
            parseRawArgument(state, c, arg[1 .. $]);
    }
    else if (arg.length > 2)
    {
        if (arg[0 .. 2] == "--")
            parseRawArgument(state, c, arg[2 .. $]);
        else if (arg[0] == '-')
        {
            foreach (flag; arg[1 .. $ - 1])
            {
                parseRawArgument(state, c, text(flag), true);
            }
            parseRawArgument(state, c, text(arg[$ - 1]));
        }
        else
            fail("Malformed argument '" ~ arg ~ "'");
    }*/
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

private void parseShortArgument(C)(ref ParseState state, ref C c, dchar flag,
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

private void parseLongArgument(C)(ref ParseState state, ref C c, string arg)
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

private void validateConfig(C)(C c)
{
    foreach (member; __traits(allMembers, C))
    {
        foreach (uda; getUDAs!(__traits(getMember, c, member), Validate))
        {
            if (uda.validate(__traits(getMember, c, member)) == false)
                exit(1);
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

        @Parameter("bool", 'b')
        bool b;
    }

    immutable Config config = parse!Config(["--foo", "a_string", "-b", "-n", "5"]);
    import std.stdio : writeln;

    assert(config.value == "a_string", "String value not read from arguments");
    assert(config.number == 5, "Integer value not read from arguments");
    assert(config.b == true, "Bool not set from arguments");
}

bool alwaysFalse(int n)
{
    writeln("Validator executed");
    return true;
}

unittest
{

    struct Config
    {
        @Parameter("bool", 'b')
        bool b;

        @Parameter("num", 'n') @Validate!int(&alwaysFalse) int number;
    }

    immutable Config config = parse!Config(["-bn", "5"]);
    config.validateConfig();
    import std.stdio : writeln;

    assert(config.number == 5, "Integer value not read from arguments");
    assert(config.b == true, "Bool not set from arguments");
}
