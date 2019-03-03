module clid.basicattributes;

/**
 * This attribute will mark a property as a command line argument.
 */
struct Parameter
{
    /** A single character flag. */
    dchar shortName;
    /** A multi-character flag. */
    string longName;

    /**
     * Params:
     *  longName = A larger string that will be used as a long flag. (e.g.: --flag)
     *  shortName = A single character that will be used as the short flag. (e.g.: -f)
     */
    this(string longName, dchar shortName = ' ')
    {
        this.longName = longName;
        this.shortName = shortName;
    }

    /**
     * Checks if this parameter flag name equals a string.
     * Params:
     *  arg = The argument to check against.
     */
    bool equals(string arg) immutable
    {
        return arg.length == 1 ? shortName == arg[0] : longName == arg;
    }
}

/**
 * This attribute will give a description to an argument.
 */
struct Description
{
    /**
     * The description of the argument.
     */
    string description;

    /**
     * Params: description = The description to give to this argument.
     */
    this(string description)
    {
        this.description = description;
    }
}

struct Validate(V)
{
    private bool function(int) validator;

    this(bool function(int) validator)
    {
        this.validator = validator;
    }

    bool validate(V)(V v)
    {
        return validator(v);
    }
}
/*
class TestValidator(string) : Validator
{
    bool validate(string v)
    {
        import std.stdio : writeln;

        writeln("Wow");
        return false;
    }
}
*/
