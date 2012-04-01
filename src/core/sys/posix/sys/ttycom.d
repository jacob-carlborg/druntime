/**
 * Copyright: Copyright (c) 2012 Jacob Carlborg
 * Authors: Jacob Carlborg
 * Version: Initial created: Mar 18, 2012
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module core.sys.posix.sys.ttycom;

import core.sys.posix.sys.ioccom;
import core.sys.posix.sys.time;
import core.sys.posix.termios;

version (OSX)
{
    struct winsize
    {
    	ushort ws_row;
    	ushort ws_col;
    	ushort ws_xpixel;
    	ushort ws_ypixel;
    }

    enum TIOCMODG = _IOR!('t', 3, int);
    enum TIOCMODS = _IOW!('t', 4, int);
    enum TIOCM_LE = 0001;
    enum TIOCM_DTR = 0002;
    enum TIOCM_RTS = 0004;
    enum TIOCM_ST = 0010;
    enum TIOCM_SR = 0020;
    enum TIOCM_CTS = 0040;
    enum TIOCM_CAR = 0100;
    enum TIOCM_CD = TIOCM_CAR;
    enum TIOCM_RNG = 0200;
    enum TIOCM_RI = TIOCM_RNG;
    enum TIOCM_DSR = 0400;
    enum TIOCEXCL = _IO!('t', 13);
    enum TIOCNXCL = _IO!('t', 14);
    enum TIOCFLUSH = _IOW!('t', 16, int);
    enum TIOCGETA = _IOR!('t', 19, termios);
    enum TIOCSETA = _IOW!('t', 20, termios);
    enum TIOCSETAW = _IOW!('t', 21, termios);
    enum TIOCSETAF = _IOW!('t', 22, termios);
    enum TIOCGETD = _IOR!('t', 26, int);
    enum TIOCSETD = _IOW!('t', 27, int);
    enum TIOCIXON = _IO!('t', 129);
    enum TIOCIXOFF = _IO!('t', 128);
    enum TIOCSBRK = _IO!('t', 123);
    enum TIOCCBRK = _IO!('t', 122);
    enum TIOCSDTR = _IO!('t', 121);
    enum TIOCCDTR = _IO!('t', 120);
    enum TIOCGPGRP = _IOR!('t', 119, int);
    enum TIOCSPGRP = _IOW!('t', 118, int);
    enum TIOCOUTQ = _IOR!('t', 115, int);
    enum TIOCSTI = _IOW!('t', 114, char);
    enum TIOCNOTTY = _IO!('t', 113);
    enum TIOCPKT = _IOW!('t', 112, int);
    enum TIOCPKT_DATA = 0x00;
    enum TIOCPKT_FLUSHREAD = 0x01;
    enum TIOCPKT_FLUSHWRITE = 0x02;
    enum TIOCPKT_STOP = 0x04;
    enum TIOCPKT_START = 0x08;
    enum TIOCPKT_NOSTOP = 0x10;
    enum TIOCPKT_DOSTOP = 0x20;
    enum TIOCPKT_IOCTL = 0x40;
    enum TIOCSTOP = _IO!('t', 111);
    enum TIOCSTART = _IO!('t', 110);
    enum TIOCMSET = _IOW!('t', 109, int);
    enum TIOCMBIS = _IOW!('t', 108, int);
    enum TIOCMBIC = _IOW!('t', 107, int);
    enum TIOCMGET = _IOR!('t', 106, int);
    enum TIOCREMOTE = _IOW!('t', 105, int);
    enum TIOCGWINSZ = _IOR!('t', 104, winsize);
    enum TIOCSWINSZ = _IOW!('t', 103, winsize);
    enum TIOCUCNTL = _IOW!('t', 102, int);
    enum TIOCSTAT = _IO!('t', 101);
    enum TIOCSCONS = _IO!('t', 99);
    enum TIOCCONS = _IOW!('t', 98, int);
    enum TIOCSCTTY = _IO!('t', 97);
    enum TIOCEXT = _IOW!('t', 96, int);
    enum TIOCSIG = _IO!('t', 95);
    enum TIOCDRAIN = _IO!('t', 94);
    enum TIOCMSDTRWAIT = _IOW!('t', 91, int);
    enum TIOCMGDTRWAIT = _IOR!('t', 90, int);
    enum TIOCTIMESTAMP = _IOR!('t', 89, timeval);
    enum TIOCDCDTIMESTAMP = _IOR!('t', 88, timeval);
    enum TIOCSDRAINWAIT = _IOW!('t', 87, int);
    enum TIOCGDRAINWAIT = _IOR!('t', 86, int);
    enum TIOCDSIMICROCODE = _IO!('t', 85);
    enum TIOCPTYGRANT = _IO!('t', 84);
    enum TIOCPTYGNAME = _IOC!(IOC_OUT, 't', 83, 128);
    enum TIOCPTYUNLK = _IO!('t', 82);
    enum TTYDISC = 0;
    enum TABLDISC = 3;
    enum SLIPDISC = 4;
    enum PPPDISC = 5;
    
    template UIOCCMD (uint n)
    {
        enum UIOCCMD = _IO!('u', n);
    }
}