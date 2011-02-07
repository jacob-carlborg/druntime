/**
 * This module provides OS specific helper function for DLL support
 *
 * Copyright: Copyright Digital Mars 2010 - 2010.
 * License:   <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>.
 * Authors:   Rainer Schuetze
 */

/*          Copyright Digital Mars 2010 - 2010.
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE_1_0.txt or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
 */

module core.dll_helper;

version( Windows )
{
    import core.sys.windows.windows;
    import core.stdc.string;
    import core.runtime;

    public import core.thread_helper;

    ///////////////////////////////////////////////////////////////////
    // support fixing implicit TLS for dynamically loaded DLLs on Windows XP

    extern (C)
    {
        extern __gshared void* _tlsstart;
        extern __gshared void* _tlsend;
        extern __gshared int   _tls_index;
        extern __gshared void* _tls_callbacks_a;
    }

private:
    struct dll_helper_aux
    {
        // don't let symbols leak into other modules
        struct LdrpTlsListEntry
        {
            LdrpTlsListEntry* next;
            LdrpTlsListEntry* prev;
            void* tlsstart;
            void* tlsend;
            void* ptr_tlsindex;
            void* callbacks;
            void* zerofill;
            int   tlsindex;
        }

        alias extern(Windows)
        void* fnRtlAllocateHeap(void* HeapHandle, uint Flags, uint Size);

        // find a code sequence and return the (relative) address that follows
        static void* findCodeReference( void* adr, int len, ref ubyte[] pattern, bool relative )
        {
            if( !adr )
                return null;

            ubyte* code = cast(ubyte*) adr;
            for( int p = 0; p < len; p++ )
            {
                if( code[ p .. p + pattern.length ] == pattern[ 0 .. $ ] )
                {
                    ubyte* padr = code + p + pattern.length;
                    if( relative )
                        return padr + 4 + *cast(int*) padr;
                    return *cast(void**) padr;
                }
            }
            return null;
        }

        // crawl through ntdll to find function _LdrpAllocateTls@0 and references
        //  to _LdrpNumberOfTlsEntries, _NtdllBaseTag and _LdrpTlsList
        // LdrInitializeThunk
        // -> _LdrpInitialize@12
        // -> _LdrpInitializeThread@4
        // -> _LdrpAllocateTls@0
        // -> je chunk
        //     _LdrpNumberOfTlsEntries - number of entries in TlsList
        //     _NtdllBaseTag           - tag used for RtlAllocateHeap
        //     _LdrpTlsList            - root of the double linked list with TlsList entries

        static __gshared int* pNtdllBaseTag; // remembered for reusage in addTlsData

        static __gshared ubyte[] jmp_LdrpInitialize = [ 0x33, 0xED, 0xE9 ]; // xor ebp,ebp; jmp _LdrpInitialize
        static __gshared ubyte[] jmp__LdrpInitialize = [ 0x5D, 0xE9 ]; // pop ebp; jmp __LdrpInitialize
        static __gshared ubyte[] call_LdrpInitializeThread = [ 0xFF, 0x75, 0x08, 0xE8 ]; // push [ebp+8]; call _LdrpInitializeThread
        static __gshared ubyte[] call_LdrpAllocateTls = [ 0x00, 0x00, 0xE8 ]; // jne 0xc3; call _LdrpAllocateTls
        static __gshared ubyte[] jne_LdrpAllocateTls = [ 0x0f, 0x85 ]; // jne body_LdrpAllocateTls
        static __gshared ubyte[] mov_LdrpNumberOfTlsEntries = [ 0x8B, 0x0D ]; // mov ecx, _LdrpNumberOfTlsEntries
        static __gshared ubyte[] mov_NtdllBaseTag = [ 0x51, 0x8B, 0x0D ]; // push ecx; mov ecx, _NtdllBaseTag
        static __gshared ubyte[] mov_LdrpTlsList = [ 0x8B, 0x3D ]; // mov edi, _LdrpTlsList

        static LdrpTlsListEntry* addTlsListEntry( void** peb, void* tlsstart, void* tlsend, void* tls_callbacks_a, int* tlsindex )
        {
            HANDLE hnd = GetModuleHandleA( "NTDLL" );
            assert( hnd, "cannot get module handle for ntdll" );
            ubyte* fn = cast(ubyte*) GetProcAddress( hnd, "LdrInitializeThunk" );
            assert( fn, "cannot find LdrInitializeThunk in ntdll" );

            try
            {
                void* pLdrpInitialize = findCodeReference( fn, 20, jmp_LdrpInitialize, true );
                void* p_LdrpInitialize = findCodeReference( pLdrpInitialize, 40, jmp__LdrpInitialize, true );
                void* pLdrpInitializeThread = findCodeReference( p_LdrpInitialize, 200, call_LdrpInitializeThread, true );
                void* pLdrpAllocateTls = findCodeReference( pLdrpInitializeThread, 40, call_LdrpAllocateTls, true );
                void* pBodyAllocateTls = findCodeReference( pLdrpAllocateTls, 40, jne_LdrpAllocateTls, true );

                int* pLdrpNumberOfTlsEntries = cast(int*) findCodeReference( pBodyAllocateTls, 20, mov_LdrpNumberOfTlsEntries, false );
                pNtdllBaseTag = cast(int*) findCodeReference( pBodyAllocateTls, 30, mov_NtdllBaseTag, false );
                LdrpTlsListEntry* pLdrpTlsList = cast(LdrpTlsListEntry*)findCodeReference( pBodyAllocateTls, 60, mov_LdrpTlsList, false );

                if( !pLdrpNumberOfTlsEntries || !pNtdllBaseTag || !pLdrpTlsList )
                    return null;

                fnRtlAllocateHeap* fnAlloc = cast(fnRtlAllocateHeap*) GetProcAddress( hnd, "RtlAllocateHeap" );
                if( !fnAlloc )
                    return null;

                // allocate new TlsList entry (adding 0xC0000 to the tag is obviously a flag also usesd by
                //  the nt-loader, could be the result of HEAP_MAKE_TAG_FLAGS(0,HEAP_NO_SERIALIZE|HEAP_GROWABLE)
                //  but this is not documented in the msdn entry for RtlAlloateHeap
                void* heap = peb[6];
                LdrpTlsListEntry* entry = cast(LdrpTlsListEntry*) (*fnAlloc)( heap, *pNtdllBaseTag | 0xc0000, LdrpTlsListEntry.sizeof );
                if( !entry )
                    return null;

                // fill entry
                entry.tlsstart = tlsstart;
                entry.tlsend = tlsend;
                entry.ptr_tlsindex = tlsindex;
                entry.callbacks = tls_callbacks_a;
                entry.zerofill = null;
                entry.tlsindex = *pLdrpNumberOfTlsEntries;

                // and add it to the end of TlsList
                *tlsindex = *pLdrpNumberOfTlsEntries;
                entry.next = pLdrpTlsList;
                entry.prev = pLdrpTlsList.prev;
                pLdrpTlsList.prev.next = entry;
                pLdrpTlsList.prev = entry;
                (*pLdrpNumberOfTlsEntries)++;

                return entry;
            }
            catch( Exception e )
            {
                // assert( false, e.msg );
                return null;
            }
        }

        // reallocate TLS array and create a copy of the TLS data section
        static bool addTlsData( void** teb, void* tlsstart, void* tlsend, int tlsindex )
        {
            try
            {
                HANDLE hnd = GetModuleHandleA( "NTDLL" );
                assert( hnd, "cannot get module handle for ntdll" );

                fnRtlAllocateHeap* fnAlloc = cast(fnRtlAllocateHeap*) GetProcAddress( hnd, "RtlAllocateHeap" );
                if( !fnAlloc || !pNtdllBaseTag )
                    return false;

                void** peb = cast(void**) teb[12];
                void* heap = peb[6];

                int sz = tlsend - tlsstart;
                void* tlsdata = cast(void*) (*fnAlloc)( heap, *pNtdllBaseTag | 0xc0000, sz );
                if( !tlsdata )
                    return false;

                // no relocations! not even self-relocations. Windows does not do them.
                core.stdc.string.memcpy( tlsdata, tlsstart, sz );

                // create copy of tls pointer array
                void** array = cast(void**) (*fnAlloc)( heap, *pNtdllBaseTag | 0xc0000, (tlsindex + 1) * (void*).sizeof );
                if( !array )
                    return false;

                if( tlsindex > 0 && teb[11] )
                    core.stdc.string.memcpy( array, teb[11], tlsindex * (void*).sizeof);
                array[tlsindex] = tlsdata;
                teb[11] = cast(void*) array;

                // let the old array leak, in case a oncurrent thread is still relying on it
            }
            catch( Exception e )
            {
                // assert( false, e.msg );
                return false;
            }
            return true;
        }

        alias bool BOOLEAN;

        struct UNICODE_STRING
        {
            short Length;
            short MaximumLength;
            wchar* Buffer;
        }

        struct LIST_ENTRY
        {
            LIST_ENTRY* next;
            LIST_ENTRY* prev;
        }

        // the following structures can be found here: http://undocumented.ntinternals.net/
        struct LDR_MODULE
        {
            LIST_ENTRY      InLoadOrderModuleList;
            LIST_ENTRY      InMemoryOrderModuleList;
            LIST_ENTRY      InInitializationOrderModuleList;
            PVOID           BaseAddress;
            PVOID           EntryPoint;
            ULONG           SizeOfImage;
            UNICODE_STRING  FullDllName;
            UNICODE_STRING  BaseDllName;
            ULONG           Flags;
            SHORT           LoadCount;
            SHORT           TlsIndex;
            LIST_ENTRY      HashTableEntry;
            ULONG           TimeDateStamp;
        }

        struct PEB_LDR_DATA
        {
            ULONG           Length;
            BOOLEAN         Initialized;
            PVOID           SsHandle;
            LIST_ENTRY      InLoadOrderModuleList;
            LIST_ENTRY      InMemoryOrderModuleList;
            LIST_ENTRY      InInitializationOrderModuleList;
        }

        static LDR_MODULE* findLdrModule( HINSTANCE hInstance, void** peb )
        {
            PEB_LDR_DATA* ldrData = cast(PEB_LDR_DATA*) peb[3];
            LIST_ENTRY* root = &ldrData.InLoadOrderModuleList;
            for(LIST_ENTRY* entry = root.next; entry != root; entry = entry.next)
            {
                LDR_MODULE *ldrMod = cast(LDR_MODULE*) entry;
                if(ldrMod.BaseAddress == hInstance)
                    return ldrMod;
            }
            return null;
        }

        static bool setDllTlsUsage( HINSTANCE hInstance, void** peb )
        {
            try
            {
                LDR_MODULE *thisMod = findLdrModule( hInstance, peb );
                if( !thisMod )
                    return false;

                thisMod.TlsIndex = -1;  // uses TLS (not the index itself)
                thisMod.LoadCount = -1; // never unload
                return true;
            }
            catch( Exception e )
            {
                // assert( false, e.msg );
                return false;
            }
        }
    }

public:
    /* *****************************************************
     * Fix implicit thread local storage for the case when a DLL is loaded
     * dynamically after process initialization.
     * The link time variables are passed to allow placing this function into
     * an RTL DLL itself.
     * The problem is described in Bugzilla 3342 and
     * http://www.nynaeve.net/?p=187, to quote from the latter:
     *
     * "When a DLL using implicit TLS is loaded, because the loader doesn't process the TLS
     *  directory, the _tls_index value is not initialized by the loader, nor is there space
     *  allocated for module's TLS data in the ThreadLocalStoragePointer arrays of running
     *  threads. The DLL continues to load, however, and things will appear to work... until the
     *  first access to a __declspec(thread) variable occurs, that is."
     *
     * _tls_index is initialized by the compiler to 0, so we can use this as a test.
     */
    bool dll_fixTLS( HINSTANCE hInstance, void* tlsstart, void* tlsend, void* tls_callbacks_a, int* tlsindex )
    {
        /* If the OS has allocated a TLS slot for us, we don't have to do anything
         * tls_index 0 means: the OS has not done anything, or it has allocated slot 0
         * Vista and later Windows systems should do this correctly and not need
         * this function.
         */
        if( *tlsindex != 0 )
            return true;

        void** peb;
        asm
        {
            mov EAX,FS:[0x30];
            mov peb, EAX;
        }
        dll_helper_aux.LDR_MODULE *ldrMod = dll_helper_aux.findLdrModule( hInstance, peb );
        if( !ldrMod )
            return false; // not in module list, bail out
        if( ldrMod.TlsIndex != 0 )
            return true;  // the OS has already setup TLS

        dll_helper_aux.LdrpTlsListEntry* entry = dll_helper_aux.addTlsListEntry( peb, tlsstart, tlsend, tls_callbacks_a, tlsindex );
        if( !entry )
            return false;

        if( !enumProcessThreads(
            function (uint id, void* context) {
                dll_helper_aux.LdrpTlsListEntry* entry = cast(dll_helper_aux.LdrpTlsListEntry*) context;
                return dll_helper_aux.addTlsData( getTEB( id ), entry.tlsstart, entry.tlsend, entry.tlsindex );
            }, entry ) )
            return false;

        ldrMod.TlsIndex = -1;  // flag TLS usage (not the index itself)
        ldrMod.LoadCount = -1; // prevent unloading of the DLL,
                               // since XP does not keep track of used TLS entries
        return true;
    }

    // fixup TLS storage, initialize runtime and attach to threads
    // to be called from DllMain with reason DLL_PROCESS_ATTACH
    bool dll_process_attach( HINSTANCE hInstance, bool attach_threads,
                             void* tlsstart, void* tlsend, void* tls_callbacks_a, int* tlsindex )
    {
        if( !dll_fixTLS( hInstance, tlsstart, tlsend, tls_callbacks_a, tlsindex ) )
            return false;

        Runtime.initialize();

        if( !attach_threads )
            return true;

        // attach to all other threads
        return enumProcessThreads(
            function (uint id, void* context) {
                if( !thread_findByAddr( id ) )
                {
                    thread_attachByAddr( id );
                    thread_moduleTlsCtor( id );
                }
                return true;
            }, null );
    }

    // same as above, but only usable if druntime is linked statically
    bool dll_process_attach( HINSTANCE hInstance, bool attach_threads = true )
    {
        return dll_process_attach( hInstance, attach_threads,
                                   &_tlsstart, &_tlsend, &_tls_callbacks_a, &_tls_index );
    }

    // to be called from DllMain with reason DLL_PROCESS_DETACH
    void dll_process_detach( HINSTANCE hInstance, bool detach_threads = true )
    {
        // detach from all other threads
        if( detach_threads )
            enumProcessThreads(
                function (uint id, void* context) {
                    if( id != GetCurrentThreadId() && thread_findByAddr( id ) )
                    {
                        thread_moduleTlsDtor( id );
                        thread_detachByAddr( id );
                    }
                    return true;
                }, null );

        Runtime.terminate();
    }

    /* Make sure that tlsCtorRun is itself a tls variable
     */
    static bool tlsCtorRun;
    static this() { tlsCtorRun = true; }

    // to be called from DllMain with reason DLL_THREAD_ATTACH
    void dll_thread_attach( bool attach_thread = true, bool initTls = true )
    {
        if( attach_thread && !thread_findByAddr( GetCurrentThreadId() ) )
            thread_attachThis();
        if( initTls && !tlsCtorRun ) // avoid duplicate calls
            _moduleTlsCtor();
    }

    // to be called from DllMain with reason DLL_THREAD_DETACH
    void dll_thread_detach( bool detach_thread = true, bool exitTls = true )
    {
        if( exitTls )
            _moduleTlsDtor();
        if( detach_thread )
            thread_detachThis();
    }
}
