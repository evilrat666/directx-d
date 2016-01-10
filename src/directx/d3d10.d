module directx.d3d10;
/*-------------------------------------------------------------------------------------
 *
 * Copyright (c) Microsoft Corporation
 *
 *-------------------------------------------------------------------------------------*/

public import directx.dxgi;
public import directx.d3dcommon;

version (none): // TODO: implement

__gshared _D3D10CreateDevice      D3D10CreateDevice;
__gshared _D3D10CreateDevice1     D3D10CreateDevice1;

extern (Windows) {
    alias _D3D10CreateDevice = HRESULT function(
                                                IDXGIAdapter      pAdapter,
                                                D3D10_DRIVER_TYPE DriverType,
                                                HMODULE           Software,
                                                UINT              Flags,
                                                UINT              SDKVersion,
                                                ID3D10Device      *ppDevice);

    alias _D3D10CreateDevice1 = HRESULT function(
                                                 IDXGIAdapter         pAdapter,
                                                 D3D10_DRIVER_TYPE    DriverType,
                                                 HMODULE              Software,
                                                 UINT                 Flags,
                                                 D3D10_FEATURE_LEVEL1 HardwareLevel,
                                                 UINT                 SDKVersion,
                                                 ID3D10Device1        *ppDevice);
}

alias DWORD D3D10_DRIVER_TYPE;
enum : D3D10_DRIVER_TYPE { 
    D3D10_DRIVER_TYPE_HARDWARE   = 0,
    D3D10_DRIVER_TYPE_REFERENCE  = 1,
    D3D10_DRIVER_TYPE_NULL       = 2,
    D3D10_DRIVER_TYPE_SOFTWARE   = 3,
    D3D10_DRIVER_TYPE_WARP       = 5
}
