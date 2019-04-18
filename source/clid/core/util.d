module clid.core.util;

import std.traits : hasUDA, getUDAs;
import std.meta : Alias;

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
template value(C, alias m)
{
	alias value = __traits(getMember, C, m);
}

/**
 * Wrapper around __traits(getMember, ...)
 */
template value(alias c, alias m)
{
	alias value = __traits(getMember, c, m);
}

/**
 * Wrapper around hasUDA!(...)
 */
template hasUDAV(C, alias m, T)
{
	alias hasUDAV = hasUDA!(value!(C, m), T);
}

/**
 * Wrapper around hasUDA!(...)
 */
template hasUDAV(C, alias m, alias t)
{
	alias hasUDAV = hasUDA!(value!(C, m), t);
}

/**
 * Wrapper around hasUDA!(...)
 */
template hasUDAV(alias c, alias m, alias t)
{
	alias hasUDAV = hasUDA!(value!(c, m), t);
}

/**
 * Checks if given template has a parameter attribute.
 */
template hasParameter(alias E)
{
	alias hasParameter = Alias!(hasUDA!(E, Parameter));
}

/**
 * Checks if given template has a parameter attribute.
 */
template hasParameter(C, alias E)
{
	alias hasParameter = Alias!(hasUDA!(value!(C, E), Parameter));
}

/**
 * Checks if the given struct has a short parameter.
 * Params:
 *  parameter The short flag that the parameter should have.
 */
bool hasShortParameter(C)(dchar parameter)
{
	static foreach (member; __traits(allMembers, C))
	{
		static if (hasParameter!(member) && getParameter!(member).shortName == parameter)
		{
			return true;
		}
	}

	return false;
}

/**
 * Checks if the given struct has a long parameter.
 * Params:
 *  parameter The long flag that the parameter should have.
 */
bool hasLongParameter(C)(string parameter)
{
	static foreach (member; __traits(allMembers, C))
	{
		if (hasParameter!(C, member) && getParameter!(C, member).longName == parameter)
			return true;
	}
	return false;
}

/**
 * Gets the parameter attribute connected to an element.
 */
template getParameter(alias E)
{
	alias getParameter = Alias!(getUDAs!(E, Parameter)[0]);
}

/**
 * Gets the parameter attribute connected to an element.
 */
template getParameter(C, alias E)
{
	alias getParameter = Alias!(getUDAs!(value!(C, E), Parameter)[0]);
}

/**
 * Checks if the element has a description attribute.
 */
template hasDescription(alias E)
{
	alias hasDescription = Alias!(hasUDA!(E, Description));
}

/**
 * Gets the description attribute of an element.
 */
template getDescription(alias E)
{
	alias getDescription = Alias!(getUDAs!(E, Description)[0]);
}
