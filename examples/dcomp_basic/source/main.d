
import core.sys.windows.windows;
import std.windows.charset;
import std.utf;

import directx.d3d11, directx.d2d1_1, directx.dcomp;

// missing ex window flags
immutable WS_EX_NOREDIRECTIONBITMAP = 0x00200000;

private void checkFailure(HRESULT hr)
{
    import std.conv : to;
    if(hr.FAILED) throw new Exception("Failed COM: " ~ hr.to!string);
}

class GraphicsDevice
{
    ID3D11Device device3; ID2D1Device device2; IDCompositionDesktopDevice compDevice;
    IDCompositionTarget target; IDCompositionVisual2 root;

    this(HWND hwTarget)
    {
        IDXGIDevice devicex;
        D3D11CreateDevice(null, D3D_DRIVER_TYPE_HARDWARE, null,
            D3D11_CREATE_DEVICE_BGRA_SUPPORT | D3D11_CREATE_DEVICE_DEBUG, null, 0, D3D11_SDK_VERSION,
            &this.device3, null, null).checkFailure();
        this.device3.QueryInterface(&IID_IDXGIDevice, cast(void**)&devicex).checkFailure();
        scope(exit) devicex.Release();
        const cp = D2D1_CREATION_PROPERTIES(D2D1_THREADING_MODE_SINGLE_THREADED, D2D1_DEBUG_LEVEL_ERROR, D2D1_DEVICE_CONTEXT_OPTIONS_NONE);
        D2D1CreateDevice(devicex, &cp, &this.device2).checkFailure();
        DCompositionCreateDevice2(this.device2, &IID_IDCompositionDesktopDevice, cast(void**)&this.compDevice).checkFailure();

        this.compDevice.CreateTargetForHwnd(hwTarget, FALSE, &this.target).checkFailure();
        this.compDevice.CreateVisual(&this.root).checkFailure();
        this.target.SetRoot(this.root).checkFailure();
        this.compDevice.Commit().checkFailure();
    }
    ~this()
    {
        this.root.Release(); this.target.Release();
        this.compDevice.Release(); this.device2.Release(); this.device3.Release();
    }
}

extern(Windows) int WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR, int)
{
    import core.runtime : Runtime;

    try
    {
        Runtime.initialize(); scope(exit) Runtime.terminate();

        WNDCLASSEXA wce;
        wce.cbSize = wce.sizeof;
        wce.hInstance = hInstance;
        wce.lpszClassName = "dxdcompExample".toMBSz;
        wce.lpfnWndProc = &WndProc;
        wce.hCursor = LoadCursorW(null, IDC_ARROW);
        const wndclass = RegisterClassExA(&wce);
        if(wndclass == 0) throw new Exception("RegisterClassEx failed");

        auto hw = CreateWindowExW(WS_EX_NOREDIRECTIONBITMAP | WS_EX_APPWINDOW, cast(wchar*)wndclass, "dcomp example".toUTF16z,
            WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, null, null, hInstance, null);
        if(hw is null) throw new Exception("CreateWindowEx failed");

        auto g = new GraphicsDevice(hw);

        hw.ShowWindow(SW_SHOWNORMAL);
        MSG msg;
        while(GetMessageA(&msg, null, 0, 0) > 0) DispatchMessageA(&msg);
        return cast(int)msg.wParam;
    }
    catch(Exception e)
    {
        MessageBoxA(null, e.toString.toMBSz, null, MB_OK);
        return -1;
    }
}

extern(Windows) nothrow LRESULT WndProc(HWND hw, UINT msg, WPARAM wp, LPARAM lp)
{
    switch(msg)
    {
    case WM_DESTROY: PostQuitMessage(0); return 0;
    default: return DefWindowProc(hw, msg, wp, lp);
    }
}

/+
import core.sys.windows.windows;
import core.stdc.stdio;
import core.stdc.string;
import std.stdio;
import std.string;
import std.utf;

import directx.d3d11;

// our objects instances, keep in mind that this is thread-local
ID3D11Device device;
ID3D11DeviceContext context;
IDXGISwapChain swapchain;
ID3D11RenderTargetView backbuffer;

/////////////////////////
// Windows specific stuff

extern(Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    int result;

	import core.runtime;
	try
    {
        Runtime.initialize();
		result = myWinMain();
		Runtime.terminate();
    }

    catch (Exception e)            // catch any uncaught exceptions
    {
        MessageBox(null, toUTF16z(e.msg), "Error", MB_OK | MB_ICONEXCLAMATION);
        result = 0; // failed
    }

	return result;
}


extern(Windows)
LRESULT WindowProc(HWND hWnd, uint uMsg, WPARAM wParam, LPARAM lParam) nothrow
{
    switch (uMsg)
    {
        case WM_COMMAND:
            break;
			
        case WM_PAINT:
            break;

        case WM_DESTROY:
            PostQuitMessage(0);
            break;

        default:
            break;
    }

    return DefWindowProc(hWnd, uMsg, wParam, lParam);
}


int myWinMain()
{
	HINSTANCE hInst = GetModuleHandle(null);
    WNDCLASS  wc;

    wc.lpszClassName = "DWndClass";
    wc.style         = CS_OWNDC | CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc   = &WindowProc;
    wc.hInstance     = hInst;
    wc.hIcon         = LoadIcon(cast(HINSTANCE) null, IDI_APPLICATION);
    wc.hCursor       = LoadCursor(cast(HINSTANCE) null, IDC_CROSS);
    wc.hbrBackground = cast(HBRUSH) (COLOR_WINDOW + 1);
    wc.lpszMenuName  = null;
    wc.cbClsExtra    = wc.cbWndExtra = 0;

    auto a = RegisterClass(&wc);
    assert(a); //note that asserts only run in debug mode

    HWND hWnd;
    hWnd = CreateWindow("DWndClass", "D3D Window", WS_THICKFRAME |
                         WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SYSMENU | WS_VISIBLE,
                         CW_USEDEFAULT, CW_USEDEFAULT, 400, 300, HWND_DESKTOP,
                         cast(HMENU) null, hInst, null);
    assert(hWnd);

  
    // init our pipeline
    InitD3D(hWnd);
    
    // our main loop
    MSG msg;
    while(true)
    {
        if( PeekMessage(&msg, null, 0, 0, PM_REMOVE) ){
            TranslateMessage(&msg);
            DispatchMessage(&msg);
            
            if( msg.message == WM_QUIT )
                break;
        }

        // clear, draw, present
        RenderFrame();
    }
    
    // release resources
    CleanD3D();

    return S_OK;
}

///////////////////////////////////////
//// Direct3D stuff

void InitD3D(HWND hWnd)
{
    // create a struct to hold information about the swap chain
    DXGI_SWAP_CHAIN_DESC scd;

    // fill the swap chain description struct
    scd.BufferCount = 1;                                    // one back buffer
    scd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;     // use 32-bit color
    scd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;      // how swap chain is to be used
    scd.OutputWindow = hWnd;                                // the window to be used
    scd.SampleDesc.Count = 4;                               // how many multisamples
    scd.Windowed = TRUE;                                    // windowed/full-screen mode

    // create a device, device context and swap chain using the information in the scd struct
    D3D11CreateDeviceAndSwapChain(null,
                                  D3D_DRIVER_TYPE_HARDWARE,
                                  null,
                                  0,
                                  null,
                                  0,
                                  D3D11_SDK_VERSION,
                                  &scd,
                                  &swapchain,
                                  &device,
                                  null,
                                  &context);

    // get the address of the back buffer
    ID3D11Texture2D pBackBuffer;
    swapchain.GetBuffer(0, &IID_ID3D11Texture2D, cast(void**)&pBackBuffer);
    
    // use the back buffer address to create the render target
    device.CreateRenderTargetView(pBackBuffer, null, &backbuffer);
    pBackBuffer.Release();

    // set the render target as the back buffer
    context.OMSetRenderTargets(1, &backbuffer, null);
    
    // Set the viewport
    D3D11_VIEWPORT viewport;
    viewport.TopLeftX = 0;
    viewport.TopLeftY = 0;
    viewport.Width = 800;
    viewport.Height = 600;

    context.RSSetViewports(1, &viewport);
}

void RenderFrame()
{
    float[4] color = [0.0f, 0.2f, 0.4f, 1.0f];
    // clear the back buffer to a deep blue
    context.ClearRenderTargetView(backbuffer, color.ptr);

    // do 3D rendering on the back buffer here

    // switch the back buffer and the front buffer
    swapchain.Present(0, 0);
}

void CleanD3D()
{
    // close and release all existing COM objects
    if(swapchain) swapchain.Release();
    if(backbuffer) backbuffer.Release();
    if(device) device.Release();
    if(context) context.Release();
}
+/
