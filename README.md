# CLI.d
`CLI.d` is a library that allows super easy, yet powerful parsing of command
line arguments.
It supports the following features:

  - Easy linkage from flags to struct members.
  - Long and short flags (e.g.: `-f` and `--file` flags).
  - Combining multiple short flags (e.g.: `-rvf` instead of `-r -v -f` or `--recursive --verbose --file`)
  - Automatic generation of help file during compile time.
  - Marking flags as required.
  - Validating arguments during parsing.
  - Automatic error messages.

## Basics
In order to parse command line arguments using `CLI.d`, an arguments struct
first needs to be created.
An arguments struct is any type of struct that has members with the attribute `@Parameter`.
After creating the struct it can be parsed using the `parseArguments` function.

```d
import clid;

private struct MyConfig
{
  @Parameter("foo", 'f')
  string myArgument;
}

void main()
{
  auto config = parseArguments!MyConfig();
}
```

Note that each argument must have a long flag, but may optionally have a short flag.

```d
private struct MyConfig
{
  @Parameter("foo")
  string onlyLongFlag

  @Parameter("bar", 'b')
  string bothLongAndShortFlag;
}
```

## Validation
Arguments can automatically be validated.
For instance, to mark an argument as being required, simply adding `@Required`
will cause an error message to be displayed if the user forgot to add it.

```d
private struct MyConfig
{
  @Parameter("foo", 'f')
  @Required
  string myArgument;
}
```

If one of the parameters has to refer to a file, a validator can be used.
Adding a validator will make sure that the argument always refers to a valid file.
If not, a proper error message will be displayed.

```d
private struct MyConfig
{
  @Parameter("file", 'f')
  @Validate!isFile
  @Required
  string myArgument;

  @Parameter("file", 'f')
  @Validate!isFile
  string optionalFile;
}
```

## Help files
The `parseArguments` function will automatically handle the flags `-h` and `--help`,
but in order to have a really nice help file descriptions have to be added to each member.
This is done using `@Description`

```d
private struct MyConfig
{
  @Parameter("file")
  @Description("The file to read")
  string file;
}
```

# Examples
Check working examples in the `examples` directory.
Each example can be compiled using `dub build --single [EXAMPLE]`.
