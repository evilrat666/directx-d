module directx.win32;
public import std.c.windows.windows;

public import std.c.windows.com;

HRESULT MAKE_HRESULT(bool s, uint f, uint c) {
	return (s << 31) | (f << 16) | c;
}

union LARGE_INTEGER {
	struct {
		uint LowPart;
		int  HighPart;
	}
	long QuadPart;
}

alias LARGE_INTEGER LUID;
alias size_t SIZE_T;

alias uint UINT32;
alias ulong UINT64;

alias HANDLE HMONITOR;
alias ubyte UINT8;
alias const(void)* LPCVOID;


// ======= XAudio2 stuff
version(HAS_WIN32)
{
}
else
{
// some predefinitions
align(1)
struct WAVEFORMATEX
{
	align(1):
	WORD        wFormatTag;         /* format type */
	WORD        nChannels;          /* number of channels (i.e. mono, stereo...) */
	DWORD       nSamplesPerSec;     /* sample rate */
	DWORD       nAvgBytesPerSec;    /* for buffer estimation */
	WORD        nBlockAlign;        /* block size of data */
	WORD        wBitsPerSample;     /* number of bits per sample of mono data */
	WORD        cbSize;             /* the count in bytes of the size of */
	/* extra information (after cbSize) */
}
//WAVEFORMATEX, *PWAVEFORMATEX, NEAR *NPWAVEFORMATEX, FAR *LPWAVEFORMATEX;

struct WAVEFORMATEXTENSIBLE
{
	WAVEFORMATEX Format;          // Base WAVEFORMATEX data
	union Samples
	{
		WORD wValidBitsPerSample; // Valid bits in each sample container
		WORD wSamplesPerBlock;    // Samples per block of audio data; valid
                                  // if wBitsPerSample=0 (but rarely used).
		WORD wReserved;           // Zero if neither case above applies.
	}
	DWORD dwChannelMask;          // Positions of the audio channels
	GUID SubFormat;               // Format identifier GUID
}
}