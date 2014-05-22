// some decls for Direct2D
module directx.wincodec;

import directx.com;
import directx.win32;

alias WICPixelFormatGUID = GUID;
alias WICInProcPointer = BYTE*;
alias WICColor = UINT32;

alias WICBitmapPaletteType = int;
enum : WICBitmapPaletteType
{
        WICBitmapPaletteTypeCustom	= 0,
        WICBitmapPaletteTypeMedianCut	= 0x1,
        WICBitmapPaletteTypeFixedBW	= 0x2,
        WICBitmapPaletteTypeFixedHalftone8	= 0x3,
        WICBitmapPaletteTypeFixedHalftone27	= 0x4,
        WICBitmapPaletteTypeFixedHalftone64	= 0x5,
        WICBitmapPaletteTypeFixedHalftone125	= 0x6,
        WICBitmapPaletteTypeFixedHalftone216	= 0x7,
        WICBitmapPaletteTypeFixedWebPalette	= WICBitmapPaletteTypeFixedHalftone216,
        WICBitmapPaletteTypeFixedHalftone252	= 0x8,
        WICBitmapPaletteTypeFixedHalftone256	= 0x9,
        WICBitmapPaletteTypeFixedGray4	= 0xa,
        WICBitmapPaletteTypeFixedGray16	= 0xb,
        WICBitmapPaletteTypeFixedGray256	= 0xc,
        WICBITMAPPALETTETYPE_FORCE_DWORD	= 0x7fffffff
}

struct WICRect
{
	INT X;
	INT Y;
	INT Width;
	INT Height;
}

mixin( uuid!(IWICBitmapSource, "00000120-a8f2-4877-ba0a-fd2b6645fb94") );
interface IWICBitmapSource : IUnknown
{
	extern(Windows):
    HRESULT GetSize( 
            /* [out] */ UINT* puiWidth,
            /* [out] */ UINT* puiHeight);
        
	HRESULT GetPixelFormat( 
            /* [out] */ WICPixelFormatGUID pPixelFormat);
        
    HRESULT GetResolution( 
            /* [out] */ double* pDpiX,
            /* [out] */ double* pDpiY);
        
    HRESULT CopyPalette( 
            /* [in] */ IWICPalette pIPalette);
        
    HRESULT CopyPixels( 
            /* [unique][in] */ const (WICRect)* prc,
            /* [in] */ UINT cbStride,
            /* [in] */ UINT cbBufferSize,
            /* [size_is][out] */  BYTE* pbBuffer);        
}
    
mixin( uuid!(IWICBitmap, "00000121-a8f2-4877-ba0a-fd2b6645fb94") );
interface IWICBitmap : IWICBitmapSource
{
	extern(Windows):
	HRESULT Lock( 
            /* [unique][in] */ const (WICRect)* prcLock,
            /* [in] */ DWORD flags,
            /* [out] */ IWICBitmapLock* ppILock);
        
    HRESULT SetPalette( 
            /* [in] */ IWICPalette pIPalette);
        
    HRESULT SetResolution( 
            /* [in] */ double dpiX,
            /* [in] */ double dpiY);
        
}

mixin( uuid!(IWICBitmapLock, "00000123-a8f2-4877-ba0a-fd2b6645fb94") );
interface IWICBitmapLock : IUnknown
{
	extern(Windows):
	HRESULT GetSize( 
            /* [out] */ UINT* puiWidth,
            /* [out] */ UINT* puiHeight);
        
	HRESULT GetStride( 
            /* [out] */ UINT* pcbStride);
        
    HRESULT GetDataPointer( 
            /* [out] */ UINT* pcbBufferSize,
            /* [size_is][size_is][out] */ WICInProcPointer ppbData);
        
    HRESULT GetPixelFormat( 
            /* [out] */ WICPixelFormatGUID pPixelFormat);

}

mixin( uuid!(IWICPalette, "00000040-a8f2-4877-ba0a-fd2b6645fb94") );
interface IWICPalette : IUnknown
{
    extern(Windows):
    HRESULT InitializePredefined( 
            /* [in] */ WICBitmapPaletteType ePaletteType,
            /* [in] */ BOOL fAddTransparentColor);
        
    HRESULT InitializeCustom( 
            /* [size_is][in] */ WICColor *pColors,
            /* [in] */ UINT cCount);
        
    HRESULT InitializeFromBitmap( 
            /* [in] */ IWICBitmapSource pISurface,
            /* [in] */ UINT cCount,
            /* [in] */ BOOL fAddTransparentColor);
        
    HRESULT InitializeFromPalette( 
            /* [in] */ IWICPalette pIPalette);
        
    HRESULT GetType( 
            /* [out] */ WICBitmapPaletteType* pePaletteType);
        
    HRESULT GetColorCount( 
            /* [out] */ UINT* pcCount);
        
    HRESULT GetColors( 
            /* [in] */ UINT cCount,
            /* [size_is][out] */ WICColor *pColors,
            /* [out] */ UINT* pcActualColors);
        
    HRESULT IsBlackWhite( 
            /* [out] */ BOOL* pfIsBlackWhite);
        
    HRESULT IsGrayscale( 
            /* [out] */ BOOL* pfIsGrayscale);
        
    HRESULT HasAlpha( 
            /* [out] */ BOOL* pfHasAlpha);

}