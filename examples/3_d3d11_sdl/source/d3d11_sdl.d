module d3d11_sdl;

import bindbc.sdl;
import core.stdc.stdio;
import core.stdc.string;
import std.format;
import std.string;
import std.utf;

import directx.d3d11;

// our objects instances, keep in mind that this is thread-local
ID3D11Device device = null;
ID3D11DeviceContext context = null;
IDXGISwapChain swapchain = null;
ID3D11RenderTargetView backbuffer = null;

/////////////////////////
// Windows specific stuff

int main()
{
    SDLSupport sup = loadSDL();
    if(sup != sdlSupport)
    {
        if(sup == SDLSupport.badLibrary)
            MessageBox(null, "Unknown library version", "Library version error", MB_ICONERROR | MB_OK);
        else if(sup == SDLSupport.noLibrary)
        {
            MessageBox(null, "SDL2.dll not found", "DLL not found", MB_ICONERROR | MB_OK);
            return -1;
        }
    }
    SDL_Init(SDL_INIT_VIDEO);
    alias f = SDL_WindowFlags;
    SDL_Window* wnd = SDL_CreateWindow("D3D11 SDL example", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
    800, 600, f.SDL_WINDOW_ALLOW_HIGHDPI | f.SDL_WINDOW_RESIZABLE);
    SDL_SysWMinfo info;
    SDL_GetWindowWMInfo(wnd, &info);

    bool quit;
    SDL_Event ev;
    HWND hwnd = cast(HWND)info.info.win.window;
    InitD3D(hwnd);

    while(!quit)
    {
        SDL_PollEvent(&ev);
        switch(ev.type)
        {
            case SDL_EventType.SDL_QUIT:
                quit = true;
                break;
            case SDL_EventType.SDL_KEYDOWN:
                if(ev.key.keysym.sym == SDL_Keycode.SDLK_ESCAPE)
                    quit = true;
                break;
            default:
                break;
        }
        RenderFrame();
    }
    CleanD3D();
    
    return 0;
}

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
    device.CreateRenderTargetView(pBackBuffer, cast(D3D11_RENDER_TARGET_VIEW_DESC*)null, &backbuffer);
    pBackBuffer.Release();

    // set the render target as the back buffer
    context.OMSetRenderTargets(1u, &backbuffer, null);
    
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
