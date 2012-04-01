/**
 * Copyright: Copyright (c) 2012 Jacob Carlborg
 * Authors: Jacob Carlborg
 * Version: Initial created: Mar 18, 2012
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module core.sys.posix.sys.ioccom;

version (OSX)
{
    enum IOCPARM_MASK = 0x1fff;

    template IOCPARM_LEN (x)
    {
    	enum IOCPARM_LEN = (x >> 16) & IOCPARM_MASK;
    }

    template IOCBASECMD (x)
    {
    	enum IOCBASECMD = x & ~(IOCPARM_MASK << 16);
    }

    template IOCGROUP (x)
    {
    	enum IOCGROUP = (x >> 8) & 0xff;
    }

    template IOCPARM_MAX (x)
    {
    	enum IOCPARM_MAX = IOCPARM_MAX + 1;
    }

    enum : uint
    {
    	IOC_VOID = 0x20000000,
    	IOC_OUT = 0x40000000,
    	IOC_IN = 0x80000000,
    	IOC_INOUT = IOC_IN | IOC_OUT,
    	IOC_DIRMASK = 0xe0000000
    }

    template _IOC (uint inout_, char group, uint num, size_t len)
    {
    	enum _IOC = inout_ | ((len & IOCPARM_MASK) << 16) | (group << 8) | num;
    }

    template _IO (char g, uint n)
    {
    	enum _IO = _IOC!(IOC_VOID, g, n, 0);
    }

    template _IOR (char g, uint n, t)
    {
    	enum _IOR = _IOC!(IOC_OUT, g, n, t.sizeof);
    }

    template _IOW (char g, uint n, t)
    {
    	enum _IOW = _IOC!(IOC_IN, g, n, t.sizeof);
    }

    template _IOWR (char g, uint n, t)
    {
    	enum _IOWR = _IOC!(IOC_INOUT, g, n, t.sizeof);
    }
}