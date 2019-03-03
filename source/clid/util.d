module clid.util;

void ValidateStruct(C)()
{
    static assert(is(C == struct), "Configuration object must be a struct");
}
