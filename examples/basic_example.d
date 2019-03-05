/+ dub.sdl:
	dependency "cli-d" version="~>0.1.0"
+/
import std.stdio : writeln;
import clid;

private struct Config
{
	@Parameter("name", 'n')
	@Description("The name to display")
	@Required string name;
}

void main()
{
	auto config = parseArguments!Config();
	writeln("Hello " ~ config.name);
}
