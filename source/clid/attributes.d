module clid.attributes;

/**
 * This attribute will mark a property as a command line argument.
 */
struct Parameter
{
	/** A single character flag. */
	dchar shortName;
	/** A multi-character flag. */
	string longName;

	/**
     * Params:
     *  longName = A larger string that will be used as a long flag. (e.g.: --flag)
     *  shortName = A single character that will be used as the short flag. (e.g.: -f)
     */
	this(string longName, dchar shortName = ' ')
	{
		this.longName = longName;
		this.shortName = shortName;
	}

	/**
     * Checks if this parameter flag name equals a string.
     * Params:
     *  arg = The argument to check against.
     */
	bool equals(string arg) immutable
	{
		return arg.length == 1 ? shortName == arg[0] : longName == arg;
	}
}

/**
 * This attribute will give a description to an argument.
 */
struct Description
{
	/**
     * The description of the argument.
     */
	string description;

	/**
	 * A single word that describes the value of the option.
	 * E.g.: for an options --time, the optionType could be "secs".
	 * In the help file this would then be listed as:
	 *    --time secs     The time that has passen
	 */
	string optionType;

	/**
     * Params:
	 * 	description = The description to give to this argument.
	 * 	optionType = The optionType to give to this argument.
     */
	this(string description, string optionType = "")
	{
		this.description = description;
		this.optionType = optionType;
	}
}

/**
 * Marks that the given argument is required to be given.
 */
struct Required
{

}
