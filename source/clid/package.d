module clid;

public import clid.attributes;
import clid.core.help;
import clid.core.parse;

C parseArguments(C)(string[] args)
{
	return parse!C(args);
}

C parseArguments(C)()
{
	import core.runtime : Runtime;

	return parseArguments!C(Runtime.args()[1 .. $]);
}
