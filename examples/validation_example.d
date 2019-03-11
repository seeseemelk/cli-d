/+ dub.sdl:
	dependency "cli-d" version="~>0.1.0"
+/
import std.stdio : writeln;
import std.conv;
import clid;
import clid.validate;

private struct Config
{
	@Parameter("file", 'f')
	@Description("The input file")
	@Validate!isFile @Required string file;

	@Parameter("number", 'n')
	@Description("Just a number")
	@Validate!isPositive int number;
}

void main()
{
	auto config = parseArguments!Config();
	writeln("File = " ~ config.file);
	writeln("Number = " ~ config.number.to!string);
}
