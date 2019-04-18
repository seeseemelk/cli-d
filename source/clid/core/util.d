module clid.core.util;

import std.traits : hasUDA, getUDAs;
import std.meta : Alias, anySatisfy;

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
template getParameter(C, alias e)
{
	alias getParameter = Alias!(getUDAs!(value!(C, e), Parameter)[0]);
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

/**
 * Checks if a given parameter is required.
 */
template isRequired(alias E)
{
	alias isRequired = Alias!(hasUDA!(E, Required));
}

/**
 * Checks if a given parameter is required.
 */
template isRequired(C, alias e)
{
	alias isRequired = Alias!(isRequired!(value!(C, e)));
}

/**
 * Checks if a given parameter is a named parameter.
 */
template isNamedParameter(alias e)
{
	alias isNamedParameter = Alias!(getParameter!(e).longName.length > 0);
}

/**
 * Checks if a given parameter is a named parameter.
 */
template isNamedParameter(alias C, alias e)
{
	alias isNamedParameter = isNamedParameter!(value!(C, e));
}

private template hasNamedParameters(C, members...)
{
	static if (isNamedParameter!(C, members[0]))
		alias hasNamedParameters = Alias!true;
	else static if (members.length == 1)
		alias hasNamedParameters = isNamedParameter!(C, members[0]);
	else
		alias hasNamedParameters = hasNamedParameters!(C, members[1 .. $]);
}

private template hasNamedParameters(C, member)
{
	alias hasNamedParameters = isNamedParameter!(C, members[i]);
}

/**
 * Checks if the struct has a named parameter.
 */
alias hasNamedParameters(C) = hasNamedParameters!(C, __traits(allMembers, C));

private template hasUnnamedParameters(C, members...)
{
	static if (!isNamedParameter!(C, members[0]))
		alias hasUnnamedParameters = Alias!true;
	else static if (members.length == 1)
		alias hasUnnamedParameters = Alias!(!isNamedParameter!(C, members[0]));
	else
		alias hasUnnamedParameters = hasUnnamedParameters!(C, members[1 .. $]);
}

/**
 * Checks if the struct has an unamed parameter.
 */
alias hasUnnamedParameters(C) = hasUnnamedParameters!(C, __traits(allMembers, C));
