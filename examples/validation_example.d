/+ dub.sdl:
	dependency "cli-d" version="~>0.1.0"
+/
import std.stdio : writeln;
import clid;
import clid.validate;

private struct Config
{
	@Parameter("file", 'f')
	@Description("The input file")
	@Validate!isFile @Required string file;
}

void main()
{
	auto config = parseArguments!Config();
	writeln("Reading " ~ config.file);
}
