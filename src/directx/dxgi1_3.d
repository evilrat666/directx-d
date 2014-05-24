module directx.dxgi1_3;

import directx.dxgi;
import directx.win32;
import directx.com;
import directx.dxgi1_2;


enum DXGI_CREATE_FACTORY_DEBUG = 0x1;
extern(Windows) HRESULT CreateDXGIFactory2(UINT Flags, REFIID riid, /*out*/ void** ppFactory);
extern(Windows) HRESULT DXGIGetDebugInterface1(UINT Flags, REFIID riid, /*out*/ void** pDebug);



mixin( uuid!(IDXGIDevice3, "6007896c-3244-4afd-bf18-a6d3beda5023") );
interface IDXGIDevice3 : IDXGIDevice2
{
	extern(Windows):
	void Trim();

}



struct DXGI_MATRIX_3X2_F
{
	FLOAT _11;
	FLOAT _12;
	FLOAT _21;
	FLOAT _22;
	FLOAT _31;
	FLOAT _32;
}


mixin( uuid!(IDXGISwapChain2, "a8be2ac4-199f-4946-b331-79599fb98de7") );
interface IDXGISwapChain2 : IDXGISwapChain1
{
	extern(Windows):
	HRESULT SetSourceSize( 
            UINT Width,
            UINT Height);

	HRESULT GetSourceSize( 
            /*out*/ UINT* pWidth,
            /*out*/ UINT* pHeight);

	HRESULT SetMaximumFrameLatency( 
            UINT MaxLatency);

	HRESULT GetMaximumFrameLatency( 
            /*out*/ UINT* pMaxLatency);

	HANDLE GetFrameLatencyWaitableObject();

	HRESULT SetMatrixTransform( 
            const(DXGI_MATRIX_3X2_F)* pMatrix);

	HRESULT GetMatrixTransform( 
            /*out*/ DXGI_MATRIX_3X2_F* pMatrix);

}
    

mixin( uuid!(IDXGIOutput2, "595e39d1-2724-4663-99b1-da969de28364") );
interface IDXGIOutput2 : IDXGIOutput1
{
	extern(Windows):
	BOOL SupportsOverlays();

}


mixin( uuid!(IDXGIFactory3, "25483823-cd46-4c7d-86ca-47aa95b837bd") );
interface IDXGIFactory3 : IDXGIFactory2
{
	extern(Windows):
	UINT GetCreationFlags();

}
    

struct DXGI_DECODE_SWAP_CHAIN_DESC
{
	UINT Flags;
}

alias DXGI_MULTIPLANE_OVERLAY_YCbCr_FLAGS = int;
enum : DXGI_MULTIPLANE_OVERLAY_YCbCr_FLAGS
{
	DXGI_MULTIPLANE_OVERLAY_YCbCr_FLAG_NOMINAL_RANGE	= 0x1,
	DXGI_MULTIPLANE_OVERLAY_YCbCr_FLAG_BT709	= 0x2,
	DXGI_MULTIPLANE_OVERLAY_YCbCr_FLAG_xvYCC	= 0x4
}


mixin( uuid!(IDXGIDecodeSwapChain, "2633066b-4514-4c7a-8fd8-12ea98059d18") );
interface IDXGIDecodeSwapChain : IUnknown
{
	extern(Windows):
	HRESULT PresentBuffer( 
            UINT BufferToPresent,
            UINT SyncInterval,
            UINT Flags);

	HRESULT SetSourceRect( 
            const(RECT)* pRect);

	HRESULT SetTargetRect( 
            const(RECT)* pRect);

	HRESULT SetDestSize( 
            UINT Width,
            UINT Height);

	HRESULT GetSourceRect( 
            /*out*/ RECT* pRect);

	HRESULT GetTargetRect( 
            /*out*/ RECT* pRect);

	HRESULT GetDestSize( 
            /*out*/ UINT* pWidth,
            /*out*/ UINT* pHeight);

	HRESULT SetColorSpace( 
            DXGI_MULTIPLANE_OVERLAY_YCbCr_FLAGS ColorSpace);

	DXGI_MULTIPLANE_OVERLAY_YCbCr_FLAGS GetColorSpace();

}


mixin( uuid!(IDXGIFactoryMedia, "41e7d1f2-a591-4f7b-a2e5-fa9c843e1c12") );
interface IDXGIFactoryMedia : IUnknown
{
	extern(Windows):
	HRESULT CreateSwapChainForCompositionSurfaceHandle( 
            IUnknown pDevice,
            HANDLE hSurface,
            const(DXGI_SWAP_CHAIN_DESC1)* pDesc,
            IDXGIOutput pRestrictToOutput,
            /*out*/ IDXGISwapChain1* ppSwapChain);

	HRESULT CreateDecodeSwapChainForCompositionSurfaceHandle( 
            IUnknown pDevice,
            HANDLE hSurface,
            DXGI_DECODE_SWAP_CHAIN_DESC* pDesc,
            IDXGIResource pYuvDecodeBuffers,
            IDXGIOutput pRestrictToOutput,
            /*out*/ IDXGIDecodeSwapChain* ppSwapChain);

}

 
alias DXGI_FRAME_PRESENTATION_MODE = int;
enum : DXGI_FRAME_PRESENTATION_MODE
{
	DXGI_FRAME_PRESENTATION_MODE_COMPOSED	= 0,
	DXGI_FRAME_PRESENTATION_MODE_OVERLAY	= 1,
	DXGI_FRAME_PRESENTATION_MODE_NONE	= 2
}

struct DXGI_FRAME_STATISTICS_MEDIA
{
	UINT PresentCount;
	UINT PresentRefreshCount;
	UINT SyncRefreshCount;
	LARGE_INTEGER SyncQPCTime;
	LARGE_INTEGER SyncGPUTime;
	DXGI_FRAME_PRESENTATION_MODE CompositionMode;
	UINT ApprovedPresentDuration;
}


mixin( uuid!(IDXGISwapChainMedia, "dd95b90b-f05f-4f6a-bd65-25bfb264bd84") );
interface IDXGISwapChainMedia : IUnknown
{
	extern(Windows):
	HRESULT GetFrameStatisticsMedia( 
            /*out*/ DXGI_FRAME_STATISTICS_MEDIA* pStats);

	HRESULT SetPresentDuration( 
            UINT Duration);

	HRESULT CheckPresentDurationSupport( 
            UINT DesiredPresentDuration,
            /*out*/ UINT* pClosestSmallerPresentDuration,
            /*out*/ UINT* pClosestLargerPresentDuration);

}