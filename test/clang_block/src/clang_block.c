void voidVoidArgs(void(^block)(void))
{
    block();
}

int intVoidArgs(int(^block)(void))
{
    return block();
}

void voidIntArgs(void(^block)(int), int arg)
{
    block(arg);
}

int intIntArgs(int(^block)(int), int arg)
{
    return block(arg);
}
