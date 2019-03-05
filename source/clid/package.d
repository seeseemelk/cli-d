module clid;

public import clid.attributes;
import clid.help;
import clid.parse;

C parseArguments(C)(string[] args)
{
	auto config = parse!C(args);
	validateConfig(config);
	return config;
}

C parseArguments(C)()
{
	import core.runtime : Runtime;

	return parseArguments!C(Runtime.args()[1 .. $]);
}
