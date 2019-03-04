module clid.util;

import std.traits : hasUDA, getUDAs;

import clid.attributes;
import clid.validate;

/**
 * Checks if a given struct is a valid configuration struct.
 */
void validateStruct(C)()
{
	static assert(is(C == struct), "Configuration object must be a struct");
	static foreach (member; __traits(allMembers, C))
	{
		static if (!hasUDAV!(C, member, Parameter))
		{
			static assert(!hasUDAV!(C, member, Description),
					"Cannot have @Description without @Parameter in command line argument struct.");
			static assert(!hasUDAV!(C, member, Validate),
					"Cannot have @Validate without @Parameter in command line argument struct.");
		}
	}
}

/**
 * Wrapper around __traits(getMember, ...)
 */
template Value(C, alias m)
{
	alias Value = __traits(getMember, C, m);
}

/**
 * Wrapper around __traits(getMember, ...)
 */
template Value(alias c, alias m)
{
	alias Value = __traits(getMember, c, m);
}

/**
 * Wrapper around hasUDA!(...)
 */
template hasUDAV(C, alias m, T)
{
	alias hasUDAV = hasUDA!(Value!(C, m), T);
}

/**
 * Wrapper around hasUDA!(...)
 */
template hasUDAV(C, alias m, alias t)
{
	alias hasUDAV = hasUDA!(Value!(C, m), t);
}

/**
 * Wrapper around hasUDA!(...)
 */
template hasUDAV(alias c, alias m, alias t)
{
	alias hasUDAV = hasUDA!(Value!(c, m), t);
}
