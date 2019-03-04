module clid.util;

import std.traits : hasUDA, getUDAs;

import clid.basicattributes;
import clid.validate;

void ValidateStruct(C)()
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

template Value(C, alias m)
{
	alias Value = __traits(getMember, C, m);
}

template Value(alias c, alias m)
{
	alias Value = __traits(getMember, c, m);
}

template hasUDAV(C, alias m, T)
{
	alias hasUDAV = hasUDA!(Value!(C, m), T);
}

template hasUDAV(C, alias m, alias t)
{
	alias hasUDAV = hasUDA!(Value!(C, m), t);
}

template hasUDAV(alias c, alias m, alias t)
{
	alias hasUDAV = hasUDA!(Value!(c, m), t);
}
