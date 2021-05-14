//--------------------------------------------------------------------------------------
// File: DXUT.cpp
//
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
//
// http://go.microsoft.com/fwlink/?LinkId=320437
//--------------------------------------------------------------------------------------
// #include "DXUT.h"


//static if(!debug)
import directx.dxgidebug;

enum DXUT_MIN_WINDOW_SIZE_X  = 200;
enum DXUT_MIN_WINDOW_SIZE_Y  = 200;
enum DXUT_COUNTER_STAT_LENGTH  = 2048;


//--------------------------------------------------------------------------------------
// Thread safety
//--------------------------------------------------------------------------------------
CRITICAL_SECTION    g_cs;
bool                g_bThreadSafe = true;


//--------------------------------------------------------------------------------------
// Automatically enters & leaves the CS upon object creation/deletion
//--------------------------------------------------------------------------------------
struct DXUTLock
{
    this() 
    {
        if( g_bThreadSafe )
            EnterCriticalSection( &g_cs ); 
    }
    ~this() 
    {
        if( g_bThreadSafe )
            LeaveCriticalSection( &g_cs ); 
    }
}

//--------------------------------------------------------------------------------------
// Helper macros to build member functions that access member variables with thread safety
//--------------------------------------------------------------------------------------
mixin template SET_ACCESSOR( x, string y )
{
    // inline void Set##y( x t )   { DXUTLock l; m_state.m_##y = t; };
    mixin("void Set"~y~"("~x.stringof~" t){DXUTLock l; m_state.m_"~y~" = t;};");
}       
mixin template GET_ACCESSOR( x, string y )
{
    // inline x Get##y()           { DXUTLock l; return m_state.m_##y; };
    mixin(x.stringof ~" Get"~y~ "{DXUTLock l; return m_state.m_"~y~";}");
}       
mixin template GET_SET_ACCESSOR( x, string y )
{
    mixin GET_ACCESSOR!(x, y);
    mixin SET_ACCESSOR!(x, y);
}   

mixin template SETP_ACCESSOR( x, string y )
{
    // inline void Set##y( x* t )  { DXUTLock l; m_state.m_##y = *t; };
    mixin("void Set"~y~"("~x.stringof~"* t){DXUTLock l; m_state.m_"~y~" = *t;}");
}      
mixin template GETP_ACCESSOR( x, string y )
{
    // inline x* Get##y()          { DXUTLock l; return &m_state.m_##y; };
    mixin(x.stringof~"* Get"~y~"(){DXUTLock l; return &m_state.m_"~y~";}");
}      
mixin template GETP_SETP_ACCESSOR( x, string y )
{
    mixin SETP_ACCESSOR!( x, y );
    mixin GETP_ACCESSOR!( x, y );
}


//--------------------------------------------------------------------------------------
// Stores timer callback info
//--------------------------------------------------------------------------------------
struct DXUT_TIMER
{
    LPDXUTCALLBACKTIMER pCallbackTimer;
    void* pCallbackUserContext;
    float fTimeoutInSecs;
    float fCountdown;
    bool bEnabled;
    UINT nID;
}


//--------------------------------------------------------------------------------------
// Stores DXUT state and data access is done with thread safety (if g_bThreadSafe==true)
//--------------------------------------------------------------------------------------
class DXUTState
{
    struct STATE
    {
        DXUTDeviceSettings*     m_CurrentDeviceSettings;   // current device settings
        IDXGIFactory1*          m_DXGIFactory;             // DXGI Factory object
        IDXGIAdapter1*          m_DXGIAdapter;            // The DXGI adapter object for the D3D11 device
        IDXGIOutput**           m_DXGIOutputArray;        // The array of output obj for the D3D11 adapter obj
        UINT                    m_DXGIOutputArraySize;    // Number of elements in m_D3D11OutputArray
        IDXGISwapChain*         m_DXGISwapChain;          // the D3D11 swapchain
        DXGI_SURFACE_DESC       m_BackBufferSurfaceDescDXGI; // D3D11 back buffer surface description
        bool                    m_RenderingOccluded;       // Rendering is occluded by another window
        bool                    m_DoNotStoreBufferSize;    // Do not store the buffer size on WM_SIZE messages

        // D3D11 specific
        ID3D11Device*           m_D3D11Device;             // the D3D11 rendering device
        ID3D11DeviceContext*	m_D3D11DeviceContext;	   // the D3D11 immediate device context
        D3D_FEATURE_LEVEL       m_D3D11FeatureLevel;	   // the D3D11 feature level that this device supports
        ID3D11Texture2D*        m_D3D11DepthStencil;       // the D3D11 depth stencil texture (optional)
        ID3D11DepthStencilView* m_D3D11DepthStencilView;   // the D3D11 depth stencil view (optional)
        ID3D11RenderTargetView* m_D3D11RenderTargetView;   // the D3D11 render target view
        ID3D11RasterizerState*  m_D3D11RasterizerState;    // the D3D11 Rasterizer state

        // D3D11.1 specific
        ID3D11Device1*          m_D3D11Device1;            // the D3D11.1 rendering device
        ID3D11DeviceContext1*	m_D3D11DeviceContext1;	   // the D3D11.1 immediate device context

        // D3D11.2 specific
        ID3D11Device2*          m_D3D11Device2;            // the D3D11.2 rendering device
        ID3D11DeviceContext2*	m_D3D11DeviceContext2;	   // the D3D11.2 immediate device context

        static if(USE_DIRECT3D11_3)
        {
            ID3D11Device3*          m_D3D11Device3;            // the D3D11.3 rendering device
            ID3D11DeviceContext3*	m_D3D11DeviceContext3;	   // the D3D11.3 immediate device context
                                                           // D3D11.3 specific
        }

        static if(USE_DIRECT3D11_4)
        {
            ID3D11Device4*          m_D3D11Device4;            // the D3D11.4 rendering device
            ID3D11DeviceContext4*	m_D3D11DeviceContext4;	   // the D3D11.4 immediate device context
                                                           // D3D11.4 specific
        }

        // General
        HWND  m_HWNDFocus;                  // the main app focus window
        HWND  m_HWNDDeviceFullScreen;       // the main app device window in fullscreen mode
        HWND  m_HWNDDeviceWindowed;         // the main app device window in windowed mode
        HMONITOR m_AdapterMonitor;          // the monitor of the adapter 
        HMENU m_Menu;                       // handle to menu

        UINT m_FullScreenBackBufferWidthAtModeChange;  // back buffer size of fullscreen mode right before switching to windowed mode.  Used to restore to same resolution when toggling back to fullscreen
        UINT m_FullScreenBackBufferHeightAtModeChange; // back buffer size of fullscreen mode right before switching to windowed mode.  Used to restore to same resolution when toggling back to fullscreen
        UINT m_WindowBackBufferWidthAtModeChange;  // back buffer size of windowed mode right before switching to fullscreen mode.  Used to restore to same resolution when toggling back to windowed mode
        UINT m_WindowBackBufferHeightAtModeChange; // back buffer size of windowed mode right before switching to fullscreen mode.  Used to restore to same resolution when toggling back to windowed mode
        DWORD m_WindowedStyleAtModeChange;  // window style
        WINDOWPLACEMENT m_WindowedPlacement;// record of windowed HWND position/show state/etc
        bool  m_TopmostWhileWindowed;       // if true, the windowed HWND is topmost 
        bool  m_Minimized;                  // if true, the HWND is minimized
        bool  m_Maximized;                  // if true, the HWND is maximized
        bool  m_MinimizedWhileFullscreen;   // if true, the HWND is minimized due to a focus switch away when fullscreen mode
        bool  m_IgnoreSizeChange;           // if true, DXUT won't reset the device upon HWND size change

        double m_Time;                      // current time in seconds
        double m_AbsoluteTime;              // absolute time in seconds
        float m_ElapsedTime;                // time elapsed since last frame

        HINSTANCE m_HInstance;              // handle to the app instance
        double m_LastStatsUpdateTime;       // last time the stats were updated
        DWORD m_LastStatsUpdateFrames;      // frames count since last time the stats were updated
        float m_FPS;                        // frames per second
        int   m_CurrentFrameNumber;         // the current frame number
        HHOOK m_KeyboardHook;               // handle to keyboard hook
        bool  m_AllowShortcutKeysWhenFullscreen; // if true, when fullscreen enable shortcut keys (Windows keys, StickyKeys shortcut, ToggleKeys shortcut, FilterKeys shortcut) 
        bool  m_AllowShortcutKeysWhenWindowed;   // if true, when windowed enable shortcut keys (Windows keys, StickyKeys shortcut, ToggleKeys shortcut, FilterKeys shortcut) 
        bool  m_AllowShortcutKeys;          // if true, then shortcut keys are currently disabled (Windows key, etc)
        bool  m_CallDefWindowProc;          // if true, DXUTStaticWndProc will call DefWindowProc for unhandled messages. Applications rendering to a dialog may need to set this to false.
        STICKYKEYS m_StartupStickyKeys;     // StickyKey settings upon startup so they can be restored later
        TOGGLEKEYS m_StartupToggleKeys;     // ToggleKey settings upon startup so they can be restored later
        FILTERKEYS m_StartupFilterKeys;     // FilterKey settings upon startup so they can be restored later

        bool  m_HandleEscape;               // if true, then DXUT will handle escape to quit
        bool  m_HandleAltEnter;             // if true, then DXUT will handle alt-enter to toggle fullscreen
        bool  m_HandlePause;                // if true, then DXUT will handle pause to toggle time pausing
        bool  m_ShowMsgBoxOnError;          // if true, then msgboxes are displayed upon errors
        bool  m_NoStats;                    // if true, then DXUTGetFrameStats() and DXUTGetDeviceStats() will return blank strings
        bool  m_ClipCursorWhenFullScreen;   // if true, then DXUT will keep the cursor from going outside the window when full screen
        bool  m_ShowCursorWhenFullScreen;   // if true, then DXUT will show a cursor when full screen
        bool  m_ConstantFrameTime;          // if true, then elapsed frame time will always be 0.05f seconds which is good for debugging or automated capture
        float m_TimePerFrame;               // the constant time per frame in seconds, only valid if m_ConstantFrameTime==true
        bool  m_WireframeMode;              // if true, then D3DRS_FILLMODE==D3DFILL_WIREFRAME else D3DRS_FILLMODE==D3DFILL_SOLID 
        bool  m_AutoChangeAdapter;          // if true, then the adapter will automatically change if the window is different monitor
        bool  m_WindowCreatedWithDefaultPositions; // if true, then CW_USEDEFAULT was used and the window should be moved to the right adapter
        int   m_ExitCode;                   // the exit code to be returned to the command line

        bool  m_DXUTInited;                 // if true, then DXUTInit() has succeeded
        bool  m_WindowCreated;              // if true, then DXUTCreateWindow() or DXUTSetWindow() has succeeded
        bool  m_DeviceCreated;              // if true, then DXUTCreateDevice() has succeeded

        bool  m_DXUTInitCalled;             // if true, then DXUTInit() was called
        bool  m_WindowCreateCalled;         // if true, then DXUTCreateWindow() or DXUTSetWindow() was called
        bool  m_DeviceCreateCalled;         // if true, then DXUTCreateDevice() was called

        bool  m_DeviceObjectsCreated;       // if true, then DeviceCreated callback has been called (if non-NULL)
        bool  m_DeviceObjectsReset;         // if true, then DeviceReset callback has been called (if non-NULL)
        bool  m_InsideDeviceCallback;       // if true, then the framework is inside an app device callback
        bool  m_InsideMainloop;             // if true, then the framework is inside the main loop
        bool  m_Active;                     // if true, then the app is the active top level window
        bool  m_TimePaused;                 // if true, then time is paused
        bool  m_RenderingPaused;            // if true, then rendering is paused
        int   m_PauseRenderingCount;        // pause rendering ref count
        int   m_PauseTimeCount;             // pause time ref count
        bool  m_DeviceLost;                 // if true, then the device is lost and needs to be reset
        bool  m_NotifyOnMouseMove;          // if true, include WM_MOUSEMOVE in mousecallback
        bool  m_Automation;                 // if true, automation is enabled
        bool  m_InSizeMove;                 // if true, app is inside a WM_ENTERSIZEMOVE
        UINT  m_TimerLastID;                // last ID of the DXUT timer
        bool  m_MessageWhenD3D11NotAvailable; 
        
        D3D_FEATURE_LEVEL  m_OverrideForceFeatureLevel; // if != -1, then overrid to use a featurelevel
        WCHAR[256] m_ScreenShotName;        // command line screen shot name
        bool m_SaveScreenShot;              // command line save screen shot
        bool m_ExitAfterScreenShot;         // command line exit after screen shot
        
        int   m_OverrideAdapterOrdinal;         // if != -1, then override to use this adapter ordinal
        bool  m_OverrideWindowed;               // if true, then force to start windowed
        int   m_OverrideOutput;                 // if != -1, then override to use the particular output on the adapter
        bool  m_OverrideFullScreen;             // if true, then force to start full screen
        int   m_OverrideStartX;                 // if != -1, then override to this X position of the window
        int   m_OverrideStartY;                 // if != -1, then override to this Y position of the window
        int   m_OverrideWidth;                  // if != 0, then override to this width
        int   m_OverrideHeight;                 // if != 0, then override to this height
        bool  m_OverrideForceHAL;               // if true, then force to HAL device (failing if one doesn't exist)
        bool  m_OverrideForceREF;               // if true, then force to REF device (failing if one doesn't exist)
        bool  m_OverrideForceWARP;              // if true, then force to WARP device (failing if one doesn't exist)
        bool  m_OverrideConstantFrameTime;      // if true, then force to constant frame time
        float m_OverrideConstantTimePerFrame;   // the constant time per frame in seconds if m_OverrideConstantFrameTime==true
        int   m_OverrideQuitAfterFrame;         // if != 0, then it will force the app to quit after that frame
        int   m_OverrideForceVsync;             // if == 0, then it will force the app to use D3DPRESENT_INTERVAL_IMMEDIATE, if == 1 force use of D3DPRESENT_INTERVAL_DEFAULT
        bool  m_AppCalledWasKeyPressed;         // true if the app ever calls DXUTWasKeyPressed().  Allows for optimzation
        bool  m_ReleasingSwapChain;             // if true, the app is releasing its swapchain
        bool  m_IsInGammaCorrectMode;           // Tell DXUTRes and DXUTMisc that we are in gamma correct mode

        LPDXUTCALLBACKMODIFYDEVICESETTINGS      m_ModifyDeviceSettingsFunc;     // modify Direct3D device settings callback
        LPDXUTCALLBACKDEVICEREMOVED             m_DeviceRemovedFunc;            // Direct3D device removed callback
        LPDXUTCALLBACKFRAMEMOVE                 m_FrameMoveFunc;                // frame move callback
        LPDXUTCALLBACKKEYBOARD                  m_KeyboardFunc;                 // keyboard callback
        LPDXUTCALLBACKMOUSE                     m_MouseFunc;                    // mouse callback
        LPDXUTCALLBACKMSGPROC                   m_WindowMsgFunc;                // window messages callback

        LPDXUTCALLBACKISD3D11DEVICEACCEPTABLE   m_IsD3D11DeviceAcceptableFunc;  // D3D11 is device acceptable callback
        LPDXUTCALLBACKD3D11DEVICECREATED        m_D3D11DeviceCreatedFunc;       // D3D11 device created callback
        LPDXUTCALLBACKD3D11SWAPCHAINRESIZED     m_D3D11SwapChainResizedFunc;    // D3D11 SwapChain reset callback
        LPDXUTCALLBACKD3D11SWAPCHAINRELEASING   m_D3D11SwapChainReleasingFunc;  // D3D11 SwapChain lost callback
        LPDXUTCALLBACKD3D11DEVICEDESTROYED      m_D3D11DeviceDestroyedFunc;     // D3D11 device destroyed callback
        LPDXUTCALLBACKD3D11FRAMERENDER          m_D3D11FrameRenderFunc;         // D3D11 frame render callback

        void* m_ModifyDeviceSettingsFuncUserContext;     // user context for modify Direct3D device settings callback
        void* m_DeviceRemovedFuncUserContext;            // user context for Direct3D device removed callback
        void* m_FrameMoveFuncUserContext;                // user context for frame move callback
        void* m_KeyboardFuncUserContext;                 // user context for keyboard callback
        void* m_MouseFuncUserContext;                    // user context for mouse callback
        void* m_WindowMsgFuncUserContext;                // user context for window messages callback

        void* m_IsD3D11DeviceAcceptableFuncUserContext;  // user context for is D3D11 device acceptable callback
        void* m_D3D11DeviceCreatedFuncUserContext;       // user context for D3D11 device created callback
        void* m_D3D11SwapChainResizedFuncUserContext;    // user context for D3D11 SwapChain resized callback
        void* m_D3D11SwapChainReleasingFuncUserContext;  // user context for D3D11 SwapChain releasing callback
        void* m_D3D11DeviceDestroyedFuncUserContext;     // user context for D3D11 device destroyed callback
        void* m_D3D11FrameRenderFuncUserContext;         // user context for D3D11 frame render callback

        bool[256] m_Keys;                                // array of key state
        bool[256] m_LastKeys;                            // array of last key state
        bool[5] m_MouseButtons;                          // array of mouse states

        // std::vector<DXUT_TIMER>*  m_TimerList;           // list of DXUT_TIMER structs
        DXUT_TIMER[]* m_TimerList;
        WCHAR[256] m_StaticFrameStats;                   // static part of frames stats 
        WCHAR[64] m_FPSStats;                            // fps stats
        WCHAR[256] m_FrameStats;                         // frame stats (fps, width, etc)
        WCHAR[256] m_DeviceStats;                        // device stats (description, device type, etc)
        WCHAR[256] m_WindowTitle;                        // window title
    }

    STATE m_state;

    this()
    {
        Create();
    }

    ~this()
    {
        Destroy();
    }

    void Create()
    {
        g_bThreadSafe = true;
        InitializeCriticalSectionAndSpinCount( &g_cs, 1000 );

        ZeroMemory( &m_state, sizeof( STATE ) );
        m_state.m_OverrideStartX = -1;
        m_state.m_OverrideStartY = -1;
        m_state.m_OverrideForceFeatureLevel = cast(D3D_FEATURE_LEVEL)0;
        m_state.m_ScreenShotName[0] = 0;
        m_state.m_SaveScreenShot = false;
        m_state.m_ExitAfterScreenShot = false;
        m_state.m_OverrideAdapterOrdinal = -1;
        m_state.m_OverrideOutput = -1;
        m_state.m_OverrideForceVsync = -1;
        m_state.m_AutoChangeAdapter = true;
        m_state.m_ShowMsgBoxOnError = true;
        m_state.m_AllowShortcutKeysWhenWindowed = true;
        m_state.m_Active = true;
        m_state.m_CallDefWindowProc = true;
        m_state.m_HandleEscape = true;
        m_state.m_HandleAltEnter = true;
        m_state.m_HandlePause = true;
        m_state.m_IsInGammaCorrectMode = true;
        m_state.m_FPS = 1.0f;
        m_state.m_MessageWhenD3D11NotAvailable = true;
    }

    void Destroy()
    {
        SAFE_DELETE( m_state.m_TimerList );
        DXUTShutdown();
        DeleteCriticalSection( &g_cs );
    }

    // Macros to define access functions for thread safe access into m_state 
    mixin GET_SET_ACCESSOR!( DXUTDeviceSettings*, "CurrentDeviceSettings" );

    // D3D11 specific
    mixin GET_SET_ACCESSOR!( IDXGIFactory1*, "DXGIFactory" );
    mixin GET_SET_ACCESSOR!( IDXGIAdapter1*, "DXGIAdapter" );
    mixin GET_SET_ACCESSOR!( IDXGIOutput**, "DXGIOutputArray" );
    mixin GET_SET_ACCESSOR!( UINT, "DXGIOutputArraySize" );
    mixin GET_SET_ACCESSOR!( IDXGISwapChain*, "DXGISwapChain" );
    mixin GETP_SETP_ACCESSOR!( DXGI_SURFACE_DESC, "BackBufferSurfaceDescDXGI" );
    mixin GET_SET_ACCESSOR!( bool, "RenderingOccluded" );
    mixin GET_SET_ACCESSOR!( bool, "DoNotStoreBufferSize" );

    mixin GET_SET_ACCESSOR!( ID3D11Device*, "D3D11Device" );
    mixin GET_SET_ACCESSOR!( ID3D11DeviceContext*, "D3D11DeviceContext" );
    mixin GET_SET_ACCESSOR!( D3D_FEATURE_LEVEL, "D3D11FeatureLevel" );
    mixin GET_SET_ACCESSOR!( ID3D11Texture2D*, "D3D11DepthStencil" );
    mixin GET_SET_ACCESSOR!( ID3D11DepthStencilView*, "D3D11DepthStencilView" );   
    mixin GET_SET_ACCESSOR!( ID3D11RenderTargetView*, "D3D11RenderTargetView" );
    mixin GET_SET_ACCESSOR!( ID3D11RasterizerState*, "D3D11RasterizerState" );

    mixin GET_SET_ACCESSOR!( ID3D11Device1*, "D3D11Device1" );
    mixin GET_SET_ACCESSOR!( ID3D11DeviceContext1*, "D3D11DeviceContext1" );

    mixin GET_SET_ACCESSOR!(ID3D11Device2*, "D3D11Device2");
    mixin GET_SET_ACCESSOR!(ID3D11DeviceContext2*, "D3D11DeviceContext2");

    static if(USE_DIRECT3D11_3)
    {
        mixin GET_SET_ACCESSOR!(ID3D11Device3*, "D3D11Device3");
        mixin GET_SET_ACCESSOR!(ID3D11DeviceContext3*, "D3D11DeviceContext3");
    }

    static if(USE_DIRECT3D11_4)
    {
        mixin GET_SET_ACCESSOR!(ID3D11Device4*, "D3D11Device4");
        mixin GET_SET_ACCESSOR!(ID3D11DeviceContext4*, "D3D11DeviceContext4");
    }

    mixin GET_SET_ACCESSOR!( HWND, "HWNDFocus" );
    mixin GET_SET_ACCESSOR!( HWND, "HWNDDeviceFullScreen" );
    mixin GET_SET_ACCESSOR!( HWND, "HWNDDeviceWindowed" );
    mixin GET_SET_ACCESSOR!( HMONITOR, "AdapterMonitor" );
    mixin GET_SET_ACCESSOR!( HMENU, "Menu" );   

    mixin GET_SET_ACCESSOR!( UINT, "FullScreenBackBufferWidthAtModeChange" );
    mixin GET_SET_ACCESSOR!( UINT, "FullScreenBackBufferHeightAtModeChange" );
    mixin GET_SET_ACCESSOR!( UINT, "WindowBackBufferWidthAtModeChange" );
    mixin GET_SET_ACCESSOR!( UINT, "WindowBackBufferHeightAtModeChange" );
    mixin GETP_SETP_ACCESSOR!( WINDOWPLACEMENT, "WindowedPlacement" );
    mixin GET_SET_ACCESSOR!( DWORD, "WindowedStyleAtModeChange" );
    mixin GET_SET_ACCESSOR!( bool, "TopmostWhileWindowed" );
    mixin GET_SET_ACCESSOR!( bool, "Minimized" );
    mixin GET_SET_ACCESSOR!( bool, "Maximized" );
    mixin GET_SET_ACCESSOR!( bool, "MinimizedWhileFullscreen" );
    mixin GET_SET_ACCESSOR!( bool, "IgnoreSizeChange" );   

    mixin GET_SET_ACCESSOR!( double, "Time" );
    mixin GET_SET_ACCESSOR!( double, "AbsoluteTime" );
    mixin GET_SET_ACCESSOR!( float, "ElapsedTime" );

    mixin GET_SET_ACCESSOR!( HINSTANCE, "HInstance" );
    mixin GET_SET_ACCESSOR!( double, "LastStatsUpdateTime" );   
    mixin GET_SET_ACCESSOR!( DWORD, "LastStatsUpdateFrames" );   
    mixin GET_SET_ACCESSOR!( float, "FPS" );    
    mixin GET_SET_ACCESSOR!( int, "CurrentFrameNumber" );
    mixin GET_SET_ACCESSOR!( HHOOK, "KeyboardHook" );
    mixin GET_SET_ACCESSOR!( bool, "AllowShortcutKeysWhenFullscreen" );
    mixin GET_SET_ACCESSOR!( bool, "AllowShortcutKeysWhenWindowed" );
    mixin GET_SET_ACCESSOR!( bool, "AllowShortcutKeys" );
    mixin GET_SET_ACCESSOR!( bool, "CallDefWindowProc" );
    mixin GET_SET_ACCESSOR!( STICKYKEYS, "StartupStickyKeys" );
    mixin GET_SET_ACCESSOR!( TOGGLEKEYS, "StartupToggleKeys" );
    mixin GET_SET_ACCESSOR!( FILTERKEYS, "StartupFilterKeys" );

    mixin GET_SET_ACCESSOR!( bool, "HandleEscape" );
    mixin GET_SET_ACCESSOR!( bool, "HandleAltEnter" );
    mixin GET_SET_ACCESSOR!( bool, "HandlePause" );
    mixin GET_SET_ACCESSOR!( bool, "ShowMsgBoxOnError" );
    mixin GET_SET_ACCESSOR!( bool, "NoStats" );
    mixin GET_SET_ACCESSOR!( bool, "ClipCursorWhenFullScreen" );   
    mixin GET_SET_ACCESSOR!( bool, "ShowCursorWhenFullScreen" );
    mixin GET_SET_ACCESSOR!( bool, "ConstantFrameTime" );
    mixin GET_SET_ACCESSOR!( float, "TimePerFrame" );
    mixin GET_SET_ACCESSOR!( bool, "WireframeMode" );   
    mixin GET_SET_ACCESSOR!( bool, "AutoChangeAdapter" );
    mixin GET_SET_ACCESSOR!( bool, "WindowCreatedWithDefaultPositions" );
    mixin GET_SET_ACCESSOR!( int, "ExitCode" );

    mixin GET_SET_ACCESSOR!( bool, "DXUTInited" );
    mixin GET_SET_ACCESSOR!( bool, "WindowCreated" );
    mixin GET_SET_ACCESSOR!( bool, "DeviceCreated" );
    mixin GET_SET_ACCESSOR!( bool, "DXUTInitCalled" );
    mixin GET_SET_ACCESSOR!( bool, "WindowCreateCalled" );
    mixin GET_SET_ACCESSOR!( bool, "DeviceCreateCalled" );
    mixin GET_SET_ACCESSOR!( bool, "InsideDeviceCallback" );
    mixin GET_SET_ACCESSOR!( bool, "InsideMainloop" );
    mixin GET_SET_ACCESSOR!( bool, "DeviceObjectsCreated" );
    mixin GET_SET_ACCESSOR!( bool, "DeviceObjectsReset" );
    mixin GET_SET_ACCESSOR!( bool, "Active" );
    mixin GET_SET_ACCESSOR!( bool, "RenderingPaused" );
    mixin GET_SET_ACCESSOR!( bool, "TimePaused" );
    mixin GET_SET_ACCESSOR!( int, "PauseRenderingCount" );
    mixin GET_SET_ACCESSOR!( int, "PauseTimeCount" );
    mixin GET_SET_ACCESSOR!( bool, "DeviceLost" );
    mixin GET_SET_ACCESSOR!( bool, "NotifyOnMouseMove" );
    mixin GET_SET_ACCESSOR!( bool, "Automation" );
    mixin GET_SET_ACCESSOR!( bool, "InSizeMove" );
    mixin GET_SET_ACCESSOR!( UINT, "TimerLastID" );
    mixin GET_SET_ACCESSOR!( bool, "MessageWhenD3D11NotAvailable" );
    mixin GET_SET_ACCESSOR!( bool, "AppCalledWasKeyPressed" );

    mixin GET_SET_ACCESSOR!( D3D_FEATURE_LEVEL, "OverrideForceFeatureLevel" );
    mixin GET_ACCESSOR!( WCHAR*, "ScreenShotName" );
    mixin GET_SET_ACCESSOR!( bool, "SaveScreenShot" );
    mixin GET_SET_ACCESSOR!( bool, "ExitAfterScreenShot" );
    
    mixin GET_SET_ACCESSOR!( int, "OverrideAdapterOrdinal" );
    mixin GET_SET_ACCESSOR!( bool, "OverrideWindowed" );
    mixin GET_SET_ACCESSOR!( int, "OverrideOutput" );
    mixin GET_SET_ACCESSOR!( bool, "OverrideFullScreen" );
    mixin GET_SET_ACCESSOR!( int, "OverrideStartX" );
    mixin GET_SET_ACCESSOR!( int, "OverrideStartY" );
    mixin GET_SET_ACCESSOR!( int, "OverrideWidth" );
    mixin GET_SET_ACCESSOR!( int, "OverrideHeight" );
    mixin GET_SET_ACCESSOR!( bool, "OverrideForceHAL" );
    mixin GET_SET_ACCESSOR!( bool, "OverrideForceREF" );
    mixin GET_SET_ACCESSOR!( bool, "OverrideForceWARP" );
    mixin GET_SET_ACCESSOR!( bool, "OverrideConstantFrameTime" );
    mixin GET_SET_ACCESSOR!( float, "OverrideConstantTimePerFrame" );
    mixin GET_SET_ACCESSOR!( int, "OverrideQuitAfterFrame" );
    mixin GET_SET_ACCESSOR!( int, "OverrideForceVsync" );
    mixin GET_SET_ACCESSOR!( bool, "ReleasingSwapChain" );
    mixin GET_SET_ACCESSOR!( bool, "IsInGammaCorrectMode" );
    
    mixin GET_SET_ACCESSOR!( LPDXUTCALLBACKMODIFYDEVICESETTINGS, "ModifyDeviceSettingsFunc" );
    mixin GET_SET_ACCESSOR!( LPDXUTCALLBACKDEVICEREMOVED, "DeviceRemovedFunc" );
    mixin GET_SET_ACCESSOR!( LPDXUTCALLBACKFRAMEMOVE, "FrameMoveFunc" );
    mixin GET_SET_ACCESSOR!( LPDXUTCALLBACKKEYBOARD, "KeyboardFunc" );
    mixin GET_SET_ACCESSOR!( LPDXUTCALLBACKMOUSE, "MouseFunc" );
    mixin GET_SET_ACCESSOR!( LPDXUTCALLBACKMSGPROC, "WindowMsgFunc" );

    mixin GET_SET_ACCESSOR!( LPDXUTCALLBACKISD3D11DEVICEACCEPTABLE, "IsD3D11DeviceAcceptableFunc" );
    mixin GET_SET_ACCESSOR!( LPDXUTCALLBACKD3D11DEVICECREATED, "D3D11DeviceCreatedFunc" );
    mixin GET_SET_ACCESSOR!( LPDXUTCALLBACKD3D11SWAPCHAINRESIZED, "D3D11SwapChainResizedFunc" );
    mixin GET_SET_ACCESSOR!( LPDXUTCALLBACKD3D11SWAPCHAINRELEASING, "D3D11SwapChainReleasingFunc" );
    mixin GET_SET_ACCESSOR!( LPDXUTCALLBACKD3D11DEVICEDESTROYED, "D3D11DeviceDestroyedFunc" );
    mixin GET_SET_ACCESSOR!( LPDXUTCALLBACKD3D11FRAMERENDER, "D3D11FrameRenderFunc" );

    mixin GET_SET_ACCESSOR!( void*, "ModifyDeviceSettingsFuncUserContext" );
    mixin GET_SET_ACCESSOR!( void*, "DeviceRemovedFuncUserContext" );
    mixin GET_SET_ACCESSOR!( void*, "FrameMoveFuncUserContext" );
    mixin GET_SET_ACCESSOR!( void*, "KeyboardFuncUserContext" );
    mixin GET_SET_ACCESSOR!( void*, "MouseFuncUserContext" );
    mixin GET_SET_ACCESSOR!( void*, "WindowMsgFuncUserContext" );

    mixin GET_SET_ACCESSOR!( void*, "IsD3D11DeviceAcceptableFuncUserContext" );
    mixin GET_SET_ACCESSOR!( void*, "D3D11DeviceCreatedFuncUserContext" );
    mixin GET_SET_ACCESSOR!( void*, "D3D11DeviceDestroyedFuncUserContext" );
    mixin GET_SET_ACCESSOR!( void*, "D3D11SwapChainResizedFuncUserContext" );
    mixin GET_SET_ACCESSOR!( void*, "D3D11SwapChainReleasingFuncUserContext" );
    mixin GET_SET_ACCESSOR!( void*, "D3D11FrameRenderFuncUserContext" );

    mixin GET_SET_ACCESSOR!(DXUT_TIMER[]*, TimerList );
    mixin GET_ACCESSOR!( bool*, "Keys" );
    mixin GET_ACCESSOR!( bool*, "LastKeys" );
    mixin GET_ACCESSOR!( bool*, "MouseButtons" );
    mixin GET_ACCESSOR!( WCHAR*, "StaticFrameStats" );
    mixin GET_ACCESSOR!( WCHAR*, "FPSStats" );
    mixin GET_ACCESSOR!( WCHAR*, "FrameStats" );
    mixin GET_ACCESSOR!( WCHAR*, "DeviceStats" );    
    mixin GET_ACCESSOR!( WCHAR*, "WindowTitle" );
};


//--------------------------------------------------------------------------------------
// Global state 
//--------------------------------------------------------------------------------------
DXUTState*          g_pDXUTState = null;

HRESULT DXUTCreateState()
{
    if( !g_pDXUTState )
    {
        // g_pDXUTState = new (std::nothrow) DXUTState;
        g_pDXUTState = DXUTState();
        if( !g_pDXUTState )
            return E_OUTOFMEMORY;
    }
    return S_OK;
}

void DXUTDestroyState()
{
    SAFE_DELETE( g_pDXUTState );
}

struct DXUTMemoryHelper
{
    this() { DXUTCreateState(); }
    ~this() { DXUTDestroyState(); }
};

ref DXUTState GetDXUTState()
{
    // This class will auto create the memory when its first accessed and delete it after the program exits WinMain.
    // However the application can also call DXUTCreateState() & DXUTDestroyState() independantly if its wants 
    static DXUTMemoryHelper memory;
    assert( g_pDXUTState );
    // _Analysis_assume_( g_pDXUTState );
    return *g_pDXUTState;
}


//--------------------------------------------------------------------------------------
// Internal helper functions 
//--------------------------------------------------------------------------------------
UINT DXUTGetBackBufferWidthFromDS(DXUTDeviceSettings* pNewDeviceSettings )     
{ 
    return pNewDeviceSettings.3d11.sd.BufferDesc.Width; 
}
UINT DXUTGetBackBufferHeightFromDS(DXUTDeviceSettings* pNewDeviceSettings )    
{ 
    return pNewDeviceSettings.3d11.sd.BufferDesc.Height; 
}
bool DXUTGetIsWindowedFromDS(DXUTDeviceSettings* pNewDeviceSettings )          
{ 
    if (!pNewDeviceSettings) 
        return true; 
    
    return pNewDeviceSettings.3d11.sd.Windowed ? true : false; 
}


//--------------------------------------------------------------------------------------
// External state access functions
//--------------------------------------------------------------------------------------
bool DXUTGetMSAASwapChainCreated()
{ 
    DXUTDeviceSettings *psettings = GetDXUTState().GetCurrentDeviceSettings();
    if ( !psettings )
        return false;
    return (psettings.3d11.sd.SampleDesc.Count > 1);
}
D3D_FEATURE_LEVEL DXUTGetD3D11DeviceFeatureLevel()  { return GetDXUTState().GetD3D11FeatureLevel(); }
IDXGISwapChain* DXUTGetDXGISwapChain()              { return GetDXUTState().GetDXGISwapChain(); }
ID3D11RenderTargetView* DXUTGetD3D11RenderTargetView() { return GetDXUTState().GetD3D11RenderTargetView(); }
ID3D11DepthStencilView* DXUTGetD3D11DepthStencilView() { return GetDXUTState().GetD3D11DepthStencilView(); }
DXGI_SURFACE_DESC* DXUTGetDXGIBackBufferSurfaceDesc() { return GetDXUTState().GetBackBufferSurfaceDescDXGI(); }
HINSTANCE DXUTGetHINSTANCE()                        { return GetDXUTState().GetHInstance(); }
HWND DXUTGetHWND()                                  { return DXUTIsWindowed() ? GetDXUTState().GetHWNDDeviceWindowed() : GetDXUTState().GetHWNDDeviceFullScreen(); }
HWND DXUTGetHWNDFocus()                             { return GetDXUTState().GetHWNDFocus(); }
HWND DXUTGetHWNDDeviceFullScreen()                  { return GetDXUTState().GetHWNDDeviceFullScreen(); }
HWND DXUTGetHWNDDeviceWindowed()                    { return GetDXUTState().GetHWNDDeviceWindowed(); }
RECT DXUTGetWindowClientRect()                      { RECT rc; GetClientRect( DXUTGetHWND(), &rc ); return rc; }
LONG DXUTGetWindowWidth()                           { RECT rc = DXUTGetWindowClientRect(); return (cast(LONG)rc.right - rc.left); }
LONG DXUTGetWindowHeight()                          { RECT rc = DXUTGetWindowClientRect(); return (cast(LONG)rc.bottom - rc.top); }
RECT DXUTGetWindowClientRectAtModeChange()          { RECT rc = { 0, 0, cast(LONG)( GetDXUTState().GetWindowBackBufferWidthAtModeChange() ), cast(LONG)( GetDXUTState().GetWindowBackBufferHeightAtModeChange() ) }; return rc; }
RECT DXUTGetFullsceenClientRectAtModeChange()       { RECT rc = { 0, 0, cast(LONG)( GetDXUTState().GetFullScreenBackBufferWidthAtModeChange() ), cast(LONG)( GetDXUTState().GetFullScreenBackBufferHeightAtModeChange() ) }; return rc; }
double DXUTGetTime()                                { return GetDXUTState().GetTime(); }
float DXUTGetElapsedTime()                          { return GetDXUTState().GetElapsedTime(); }
float DXUTGetFPS()                                  { return GetDXUTState().GetFPS(); }
LPCWSTR DXUTGetWindowTitle()                        { return GetDXUTState().GetWindowTitle(); }
LPCWSTR DXUTGetDeviceStats()                        { return GetDXUTState().GetDeviceStats(); }
bool DXUTIsRenderingPaused()                        { return GetDXUTState().GetPauseRenderingCount() > 0; }
bool DXUTIsTimePaused()                             { return GetDXUTState().GetPauseTimeCount() > 0; }
bool DXUTIsActive()                                 { return GetDXUTState().GetActive(); }
int DXUTGetExitCode()                               { return GetDXUTState().GetExitCode(); }
bool DXUTGetShowMsgBoxOnError()                     { return GetDXUTState().GetShowMsgBoxOnError(); }
bool DXUTGetAutomation()                            { return GetDXUTState().GetAutomation(); }
bool DXUTIsWindowed()                               { return DXUTGetIsWindowedFromDS( GetDXUTState().GetCurrentDeviceSettings() ); }
bool DXUTIsInGammaCorrectMode()                     { return GetDXUTState().GetIsInGammaCorrectMode(); }
IDXGIFactory1* DXUTGetDXGIFactory()                 { DXUTDelayLoadDXGI(); return GetDXUTState().GetDXGIFactory(); }

ID3D11Device* DXUTGetD3D11Device()                  { return GetDXUTState().GetD3D11Device(); }
ID3D11DeviceContext* DXUTGetD3D11DeviceContext()    { return GetDXUTState().GetD3D11DeviceContext(); }
ID3D11Device1* DXUTGetD3D11Device1()                { return GetDXUTState().GetD3D11Device1(); }
ID3D11DeviceContext1* DXUTGetD3D11DeviceContext1()  { return GetDXUTState().GetD3D11DeviceContext1(); }

ID3D11Device2* DXUTGetD3D11Device2()                { return GetDXUTState().GetD3D11Device2(); }
ID3D11DeviceContext2* DXUTGetD3D11DeviceContext2()  { return GetDXUTState().GetD3D11DeviceContext2(); }

static if(USE_DIRECT3D11_3)
{
    ID3D11Device3* DXUTGetD3D11Device3() { return GetDXUTState().GetD3D11Device3(); }
    ID3D11DeviceContext3* DXUTGetD3D11DeviceContext3() { return GetDXUTState().GetD3D11DeviceContext3(); }
}

static if(USE_DIRECT3D11_4)
{
    ID3D11Device4* DXUTGetD3D11Device4() { return GetDXUTState().GetD3D11Device4(); }
    ID3D11DeviceContext4* DXUTGetD3D11DeviceContext4() { return GetDXUTState().GetD3D11DeviceContext4(); }
}

//--------------------------------------------------------------------------------------
// External callback setup functions
//--------------------------------------------------------------------------------------

// General callbacks
void DXUTSetCallbackDeviceChanging( LPDXUTCALLBACKMODIFYDEVICESETTINGS pCallback,void* pUserContext )    { GetDXUTState().SetModifyDeviceSettingsFunc( pCallback ); GetDXUTState().SetModifyDeviceSettingsFuncUserContext( pUserContext ); }
void DXUTSetCallbackDeviceRemoved( LPDXUTCALLBACKDEVICEREMOVED pCallback,void* pUserContext )            { GetDXUTState().SetDeviceRemovedFunc( pCallback ); GetDXUTState().SetDeviceRemovedFuncUserContext( pUserContext ); }
void DXUTSetCallbackFrameMove( LPDXUTCALLBACKFRAMEMOVE pCallback,void* pUserContext )                    { GetDXUTState().SetFrameMoveFunc( pCallback );  GetDXUTState().SetFrameMoveFuncUserContext( pUserContext ); }
void DXUTSetCallbackKeyboard( LPDXUTCALLBACKKEYBOARD pCallback,void* pUserContext )                      { GetDXUTState().SetKeyboardFunc( pCallback );  GetDXUTState().SetKeyboardFuncUserContext( pUserContext ); }
void DXUTSetCallbackMouse( LPDXUTCALLBACKMOUSE pCallback, bool bIncludeMouseMove,void* pUserContext )    { GetDXUTState().SetMouseFunc( pCallback ); GetDXUTState().SetNotifyOnMouseMove( bIncludeMouseMove );  GetDXUTState().SetMouseFuncUserContext( pUserContext ); }
void DXUTSetCallbackMsgProc( LPDXUTCALLBACKMSGPROC pCallback,void* pUserContext )                        { GetDXUTState().SetWindowMsgFunc( pCallback );  GetDXUTState().SetWindowMsgFuncUserContext( pUserContext ); }

// Direct3D 11 callbacks
void DXUTSetCallbackD3D11DeviceAcceptable(LPDXUTCALLBACKISD3D11DEVICEACCEPTABLE pCallback, void* pUserContext )   { GetDXUTState().SetIsD3D11DeviceAcceptableFunc( pCallback ); GetDXUTState().SetIsD3D11DeviceAcceptableFuncUserContext( pUserContext ); }
void DXUTSetCallbackD3D11DeviceCreated(LPDXUTCALLBACKD3D11DEVICECREATED pCallback, void* pUserContext )           { GetDXUTState().SetD3D11DeviceCreatedFunc( pCallback ); GetDXUTState().SetD3D11DeviceCreatedFuncUserContext( pUserContext ); }
void DXUTSetCallbackD3D11SwapChainResized(LPDXUTCALLBACKD3D11SWAPCHAINRESIZED pCallback, void* pUserContext )     { GetDXUTState().SetD3D11SwapChainResizedFunc( pCallback );  GetDXUTState().SetD3D11SwapChainResizedFuncUserContext( pUserContext ); }
void DXUTSetCallbackD3D11FrameRender(LPDXUTCALLBACKD3D11FRAMERENDER pCallback, void* pUserContext )               { GetDXUTState().SetD3D11FrameRenderFunc( pCallback );  GetDXUTState().SetD3D11FrameRenderFuncUserContext( pUserContext ); }
void DXUTSetCallbackD3D11SwapChainReleasing(LPDXUTCALLBACKD3D11SWAPCHAINRELEASING pCallback, void* pUserContext ) { GetDXUTState().SetD3D11SwapChainReleasingFunc( pCallback );  GetDXUTState().SetD3D11SwapChainReleasingFuncUserContext( pUserContext ); }
void DXUTSetCallbackD3D11DeviceDestroyed(LPDXUTCALLBACKD3D11DEVICEDESTROYED pCallback, void* pUserContext )       { GetDXUTState().SetD3D11DeviceDestroyedFunc( pCallback );  GetDXUTState().SetD3D11DeviceDestroyedFuncUserContext( pUserContext ); }
void DXUTGetCallbackD3D11DeviceAcceptable(LPDXUTCALLBACKISD3D11DEVICEACCEPTABLE* ppCallback, void** ppUserContext )      { *ppCallback = GetDXUTState().GetIsD3D11DeviceAcceptableFunc(); *ppUserContext = GetDXUTState().GetIsD3D11DeviceAcceptableFuncUserContext(); }


//--------------------------------------------------------------------------------------
// Optionally parses the command line and sets if default hotkeys are handled
//
//       Possible command line parameters are:
//          -forcefeaturelevel:fl     forces app to use a specified direct3D11 feature level    
//          -screenshotexit:filename save a screenshot to the filename.bmp and exit.
//          -adapter:#              forces app to use this adapter # (fails if the adapter doesn't exist)
//          -output:#               forces app to use a particular output on the adapter (fails if the output doesn't exist) 
//          -windowed               forces app to start windowed
//          -fullscreen             forces app to start full screen
//          -forcehal               forces app to use HAL (fails if HAL doesn't exist)
//          -forceref               forces app to use REF (fails if REF doesn't exist)
//          -forcewarp              forces app to use WARP (fails if WARP doesn't exist)
//          -forcevsync:#           if # is 0, then vsync is disabled 
//          -width:#                forces app to use # for width. for full screen, it will pick the closest possible supported mode
//          -height:#               forces app to use # for height. for full screen, it will pick the closest possible supported mode
//          -startx:#               forces app to use # for the x coord of the window position for windowed mode
//          -starty:#               forces app to use # for the y coord of the window position for windowed mode
//          -constantframetime:#    forces app to use constant frame time, where # is the time/frame in seconds
//          -quitafterframe:x       forces app to quit after # frames
//          -noerrormsgboxes        prevents the display of message boxes generated by the framework so the application can be run without user interaction
//          -nostats                prevents the display of the stats
//          -automation             a hint to other components that automation is active 
//--------------------------------------------------------------------------------------
HRESULT DXUTInit( bool bParseCommandLine, 
                         bool bShowMsgBoxOnError, 
                         WCHAR* strExtraCommandLineParams, 
                         bool bThreadSafeDXUT )
{
    g_bThreadSafe = bThreadSafeDXUT;

    HRESULT hr = CoInitializeEx( null, COINIT_MULTITHREADED );
    if ( FAILED(hr) )
        return hr;

    GetDXUTState().SetDXUTInitCalled( true );

    // Not always needed, but lets the app create GDI dialogs
    InitCommonControls();

    // Save the current sticky/toggle/filter key settings so DXUT can restore them later
    STICKYKEYS sk = {sizeof(STICKYKEYS), 0};
    if ( !SystemParametersInfo(SPI_GETSTICKYKEYS, sizeof(STICKYKEYS), &sk, 0) )
        memset( &sk, 0, sizeof(sk) );
    GetDXUTState().SetStartupStickyKeys( sk );

    TOGGLEKEYS tk = {sizeof(TOGGLEKEYS), 0};
   if ( !SystemParametersInfo(SPI_GETTOGGLEKEYS, sizeof(TOGGLEKEYS), &tk, 0) )
        memset( &tk, 0, sizeof(tk) );
    GetDXUTState().SetStartupToggleKeys( tk );

    FILTERKEYS fk = {sizeof(FILTERKEYS), 0};
    if ( !SystemParametersInfo(SPI_GETFILTERKEYS, sizeof(FILTERKEYS), &fk, 0) )
        memset( &fk, 0, sizeof(fk) );
    GetDXUTState().SetStartupFilterKeys( fk );

    GetDXUTState().SetShowMsgBoxOnError( bShowMsgBoxOnError );

    if( bParseCommandLine )
        DXUTParseCommandLine( GetCommandLine() );
    if( strExtraCommandLineParams )
        DXUTParseCommandLine( strExtraCommandLineParams, false );

    // Reset the timer
    DXUTGetGlobalTimer().Reset();

    GetDXUTState().SetDXUTInited( true );

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Parses the command line for parameters.  See DXUTInit() for list 
//--------------------------------------------------------------------------------------
void DXUTParseCommandLine(WCHAR* strCommandLine, 
                          bool bIgnoreFirstCommand  )
{
    WCHAR* strCmdLine;
    WCHAR[MAX_PATH] strFlag;

    int nNumArgs;
    auto pstrArgList = CommandLineToArgvW( strCommandLine, &nNumArgs );
    int iArgStart = 0;
    if( bIgnoreFirstCommand )
        iArgStart = 1;
    for( int iArg = iArgStart; iArg < nNumArgs; iArg++ )
    {
        strCmdLine = pstrArgList[iArg];

        // Handle flag args
        if( *strCmdLine == '/' || *strCmdLine == '-' )
        {
            strCmdLine++;

            if( DXUTIsNextArg( strCmdLine, "forcefeaturelevel" ) )
            {
                if( DXUTGetCmdParam( strCmdLine, strFlag, MAX_PATH ) )
                {
                    static if(USE_DIRECT3D11_3 || USE_DIRECT3D11_4)
                    {
                        if (_wcsnicmp(strFlag, "D3D_FEATURE_LEVEL_12_1", MAX_PATH) == 0) {
                            GetDXUTState().SetOverrideForceFeatureLevel(D3D_FEATURE_LEVEL_12_1);
                        }
                        else if (_wcsnicmp(strFlag, "D3D_FEATURE_LEVEL_12_0", MAX_PATH) == 0) {
                            GetDXUTState().SetOverrideForceFeatureLevel(D3D_FEATURE_LEVEL_12_0);
                        }
                    }
                        
                    if (_wcsnicmp( strFlag, "D3D_FEATURE_LEVEL_11_1", MAX_PATH) == 0 ) {
                        GetDXUTState().SetOverrideForceFeatureLevel(D3D_FEATURE_LEVEL_11_1);
                    }else if (_wcsnicmp( strFlag, "D3D_FEATURE_LEVEL_11_0", MAX_PATH) == 0 ) {
                        GetDXUTState().SetOverrideForceFeatureLevel(D3D_FEATURE_LEVEL_11_0);
                    }else if (_wcsnicmp( strFlag, "D3D_FEATURE_LEVEL_10_1", MAX_PATH) == 0 ) {
                        GetDXUTState().SetOverrideForceFeatureLevel(D3D_FEATURE_LEVEL_10_1);
                    }else if (_wcsnicmp( strFlag, "D3D_FEATURE_LEVEL_10_0", MAX_PATH) == 0 ) {
                        GetDXUTState().SetOverrideForceFeatureLevel(D3D_FEATURE_LEVEL_10_0);
                    }else if (_wcsnicmp( strFlag, "D3D_FEATURE_LEVEL_9_3", MAX_PATH) == 0 ) {
                        GetDXUTState().SetOverrideForceFeatureLevel(D3D_FEATURE_LEVEL_9_3);
                    }else if (_wcsnicmp( strFlag, "D3D_FEATURE_LEVEL_9_2", MAX_PATH) == 0 ) {
                        GetDXUTState().SetOverrideForceFeatureLevel(D3D_FEATURE_LEVEL_9_2);
                    }else if (_wcsnicmp( strFlag, "D3D_FEATURE_LEVEL_9_1", MAX_PATH) == 0 ) {
                        GetDXUTState().SetOverrideForceFeatureLevel(D3D_FEATURE_LEVEL_9_1);
                    }
                    continue;
                }
            }
            
            if( DXUTIsNextArg( strCmdLine, "adapter" ) )
            {
                if( DXUTGetCmdParam( strCmdLine, strFlag, MAX_PATH ) )
                {
                    int nAdapter = _wtoi( strFlag );
                    GetDXUTState().SetOverrideAdapterOrdinal( nAdapter );
                    continue;
                }
            }

            if( DXUTIsNextArg( strCmdLine, "windowed" ) )
            {
                GetDXUTState().SetOverrideWindowed( true );
                continue;
            }

            if( DXUTIsNextArg( strCmdLine, "output" ) )
            {
                if( DXUTGetCmdParam( strCmdLine, strFlag, MAX_PATH ) )
                {
                    int Output = _wtoi( strFlag );
                    GetDXUTState().SetOverrideOutput( Output );
                    continue;
                }
            }

            if( DXUTIsNextArg( strCmdLine, "fullscreen" ) )
            {
                GetDXUTState().SetOverrideFullScreen( true );
                continue;
            }

            if( DXUTIsNextArg( strCmdLine, "forcehal" ) )
            {
                GetDXUTState().SetOverrideForceHAL( true );
                continue;
            }
            if( DXUTIsNextArg( strCmdLine, "screenshotexit" ) ) {
                if( DXUTGetCmdParam( strCmdLine, strFlag, MAX_PATH ) )
                {
                    GetDXUTState().SetExitAfterScreenShot( true );
                    GetDXUTState().SetSaveScreenShot( true );
                    swprintf_s( GetDXUTState().GetScreenShotName(), 256, "%ls.bmp", strFlag );
                    continue;
                }
            }
            if( DXUTIsNextArg( strCmdLine, "forceref" ) )
            {
                GetDXUTState().SetOverrideForceREF( true );
                continue;
            }
            if( DXUTIsNextArg( strCmdLine, "forcewarp" ) )
            {
                GetDXUTState().SetOverrideForceWARP( true );
                continue;
            }

            if( DXUTIsNextArg( strCmdLine, "forcevsync" ) )
            {
                if( DXUTGetCmdParam( strCmdLine, strFlag, MAX_PATH ) )
                {
                    int nOn = _wtoi( strFlag );
                    GetDXUTState().SetOverrideForceVsync( nOn );
                    continue;
                }
            }

            if( DXUTIsNextArg( strCmdLine, "width" ) )
            {
                if( DXUTGetCmdParam( strCmdLine, strFlag, MAX_PATH ) )
                {
                    int nWidth = _wtoi( strFlag );
                    GetDXUTState().SetOverrideWidth( nWidth );
                    continue;
                }
            }

            if( DXUTIsNextArg( strCmdLine, "height" ) )
            {
                if( DXUTGetCmdParam( strCmdLine, strFlag, MAX_PATH ) )
                {
                    int nHeight = _wtoi( strFlag );
                    GetDXUTState().SetOverrideHeight( nHeight );
                    continue;
                }
            }

            if( DXUTIsNextArg( strCmdLine, "startx" ) )
            {
                if( DXUTGetCmdParam( strCmdLine, strFlag, MAX_PATH ) )
                {
                    int nX = _wtoi( strFlag );
                    GetDXUTState().SetOverrideStartX( nX );
                    continue;
                }
            }

            if( DXUTIsNextArg( strCmdLine, "starty" ) )
            {
                if( DXUTGetCmdParam( strCmdLine, strFlag, MAX_PATH ) )
                {
                    int nY = _wtoi( strFlag );
                    GetDXUTState().SetOverrideStartY( nY );
                    continue;
                }
            }

            if( DXUTIsNextArg( strCmdLine, "constantframetime" ) )
            {
                float fTimePerFrame;
                if( DXUTGetCmdParam( strCmdLine, strFlag, MAX_PATH ) )
                    fTimePerFrame = cast( float )wcstod( strFlag, null );
                else
                    fTimePerFrame = 0.0333f;
                GetDXUTState().SetOverrideConstantFrameTime( true );
                GetDXUTState().SetOverrideConstantTimePerFrame( fTimePerFrame );
                DXUTSetConstantFrameTime( true, fTimePerFrame );
                continue;
            }

            if( DXUTIsNextArg( strCmdLine, "quitafterframe" ) )
            {
                if( DXUTGetCmdParam( strCmdLine, strFlag, MAX_PATH ) )
                {
                    int nFrame = _wtoi( strFlag );
                    GetDXUTState().SetOverrideQuitAfterFrame( nFrame );
                    continue;
                }
            }

            if( DXUTIsNextArg( strCmdLine, "noerrormsgboxes" ) )
            {
                GetDXUTState().SetShowMsgBoxOnError( false );
                continue;
            }

            if( DXUTIsNextArg( strCmdLine, "nostats" ) )
            {
                GetDXUTState().SetNoStats( true );
                continue;
            }

            if( DXUTIsNextArg( strCmdLine, "automation" ) )
            {
                GetDXUTState().SetAutomation( true );
                continue;
            }
        }

        // Unrecognized flag
        wcscpy_s( strFlag, MAX_PATH, strCmdLine );
        WCHAR* strSpace = strFlag;
        while( *strSpace && ( *strSpace > ' ' ) )
            strSpace++;
        *strSpace = 0;

        DXUTOutputDebugString( "Unrecognized flag: %ls", strFlag );
        strCmdLine += wcslen( strFlag );
    }

    LocalFree( pstrArgList );
}


//--------------------------------------------------------------------------------------
// Helper function for DXUTParseCommandLine
//--------------------------------------------------------------------------------------
bool DXUTIsNextArg( ref WCHAR* strCmdLine, const WCHAR* strArg )
{
    size_t nArgLen = wcslen( strArg );
    size_t nCmdLen = wcslen( strCmdLine );

    if( nCmdLen >= nArgLen &&
        _wcsnicmp( strCmdLine, strArg, nArgLen ) == 0 &&
        ( strCmdLine[nArgLen] == 0 || strCmdLine[nArgLen] == ':' ) )
    {
        strCmdLine += nArgLen;
        return true;
    }

    return false;
}


//--------------------------------------------------------------------------------------
// Helper function for DXUTParseCommandLine.  Updates strCmdLine and strFlag 
//      Example: if strCmdLine=="-width:1024 -forceref"
// then after: strCmdLine==" -forceref" and strFlag=="1024"
//--------------------------------------------------------------------------------------
bool DXUTGetCmdParam( ref WCHAR* strCmdLine, WCHAR* strFlag, int cchDest )
{
    if( *strCmdLine == ':' )
    {
        strCmdLine++; // Skip ':'

        // Place nul terminator in strFlag after current token
        wcscpy_s( strFlag, cchDest, strCmdLine );

        WCHAR* strSpace = strFlag;
        int count = 0;
        while( *strSpace && ( *strSpace > ' ' ) && (count < cchDest) )
        {
            ++strSpace;
            ++count;
        }
        *strSpace = 0;

        // Update strCmdLine
        strCmdLine += wcslen( strFlag );
        return true;
    }
    else
    {
        strFlag[0] = 0;
        return false;
    }
}


//--------------------------------------------------------------------------------------
// Creates a window with the specified window title, icon, menu, and 
// starting position.  If DXUTInit() has not already been called, it will
// call it with the default parameters.  Instead of calling this, you can 
// call DXUTSetWindow() to use an existing window.  
//--------------------------------------------------------------------------------------
HRESULT DXUTCreateWindow( const WCHAR* strWindowTitle, HINSTANCE hInstance,
                                 HICON hIcon, HMENU hMenu, int x, int y )
{
    HRESULT hr;

    // Not allowed to call this from inside the device callbacks
    if( GetDXUTState().GetInsideDeviceCallback() )
        return DXUT_ERR_MSGBOX("DXUTCreateWindow", E_FAIL );

    GetDXUTState().SetWindowCreateCalled( true );

    if( !GetDXUTState().GetDXUTInited() )
    {
        // If DXUTInit() was already called and failed, then fail.
        // DXUTInit() must first succeed for this function to succeed
        if( GetDXUTState().GetDXUTInitCalled() )
            return E_FAIL;

        // If DXUTInit() hasn't been called, then automatically call it
        // with default params
        hr = DXUTInit();
        if( FAILED( hr ) )
            return hr;
    }

    if( !DXUTGetHWNDFocus() )
    {
        if( !hInstance )
            hInstance = cast( HINSTANCE )GetModuleHandle( null );
        GetDXUTState().SetHInstance( hInstance );

        WCHAR[MAX_PATH] szExePath;
        GetModuleFileName( null, szExePath, MAX_PATH );
        if( !hIcon ) // If the icon is NULL, then use the first one found in the exe
            hIcon = ExtractIcon( hInstance, szExePath, 0 );

        // Register the windows class
        WNDCLASS wndClass;
        wndClass.style = CS_DBLCLKS;
        wndClass.lpfnWndProc = DXUTStaticWndProc;
        wndClass.cbClsExtra = 0;
        wndClass.cbWndExtra = 0;
        wndClass.hInstance = hInstance;
        wndClass.hIcon = hIcon;
        wndClass.hCursor = LoadCursor( null, IDC_ARROW );
        wndClass.hbrBackground = cast( HBRUSH )GetStockObject( BLACK_BRUSH );
        wndClass.lpszMenuName = null;
        wndClass.lpszClassName = "Direct3DWindowClass";

        if( !RegisterClass( &wndClass ) )
        {
            DWORD dwError = GetLastError();
            if( dwError != ERROR_CLASS_ALREADY_EXISTS )
                return DXUT_ERR_MSGBOX( "RegisterClass", HRESULT_FROM_WIN32(dwError) );
        }

        // Override the window's initial & size position if there were cmd line args
        if( GetDXUTState().GetOverrideStartX() != -1 )
            x = GetDXUTState().GetOverrideStartX();
        if( GetDXUTState().GetOverrideStartY() != -1 )
            y = GetDXUTState().GetOverrideStartY();

        GetDXUTState().SetWindowCreatedWithDefaultPositions( false );
        if( x == CW_USEDEFAULT && y == CW_USEDEFAULT )
            GetDXUTState().SetWindowCreatedWithDefaultPositions( true );

        // Find the window's initial size, but it might be changed later
        int nDefaultWidth = 800;
        int nDefaultHeight = 600;
        if( GetDXUTState().GetOverrideWidth() != 0 )
            nDefaultWidth = GetDXUTState().GetOverrideWidth();
        if( GetDXUTState().GetOverrideHeight() != 0 )
            nDefaultHeight = GetDXUTState().GetOverrideHeight();

        RECT rc;
        SetRect( &rc, 0, 0, nDefaultWidth, nDefaultHeight );
        AdjustWindowRect( &rc, WS_OVERLAPPEDWINDOW, ( hMenu ) ? true : false );

        WCHAR* strCachedWindowTitle = GetDXUTState().GetWindowTitle();
        wcscpy_s( strCachedWindowTitle, 256, strWindowTitle );

        // Create the render window
        HWND hWnd = CreateWindow( "Direct3DWindowClass", strWindowTitle, WS_OVERLAPPEDWINDOW,
                                  x, y, ( rc.right - rc.left ), ( rc.bottom - rc.top ), 0,
                                  hMenu, hInstance, 0 );
        if( !hWnd )
        {
            DWORD dwError = GetLastError();
            return DXUT_ERR_MSGBOX( "CreateWindow", HRESULT_FROM_WIN32(dwError) );
        }

        GetDXUTState().SetWindowCreated( true );
        GetDXUTState().SetHWNDFocus( hWnd );
        GetDXUTState().SetHWNDDeviceFullScreen( hWnd );
        GetDXUTState().SetHWNDDeviceWindowed( hWnd );
    }

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Sets a previously created window for the framework to use.  If DXUTInit() 
// has not already been called, it will call it with the default parameters.  
// Instead of calling this, you can call DXUTCreateWindow() to create a new window.  
//--------------------------------------------------------------------------------------
HRESULT DXUTSetWindow( HWND hWndFocus, HWND hWndDeviceFullScreen, HWND hWndDeviceWindowed, bool bHandleMessages )
{
    HRESULT hr;

    // Not allowed to call this from inside the device callbacks
    if( GetDXUTState().GetInsideDeviceCallback() )
        return DXUT_ERR_MSGBOX( "DXUTCreateWindow", E_FAIL );

    GetDXUTState().SetWindowCreateCalled( true );

    // To avoid confusion, we do not allow any HWND to be null here.  The
    // caller must pass in valid HWND for all three parameters.  The same
    // HWND may be used for more than one parameter.
    if( !hWndFocus || !hWndDeviceFullScreen || !hWndDeviceWindowed )
        return DXUT_ERR_MSGBOX( "DXUTSetWindow", E_INVALIDARG );

    // If subclassing the window, set the pointer to the local window procedure
    if( bHandleMessages )
    {
        // Switch window procedures
        LONG_PTR nResult = SetWindowLongPtr( hWndFocus, GWLP_WNDPROC, cast(LONG_PTR)DXUTStaticWndProc );

        DWORD dwError = GetLastError();
        if( nResult == 0 )
            return DXUT_ERR_MSGBOX( "SetWindowLongPtr", HRESULT_FROM_WIN32(dwError) );
    }

    if( !GetDXUTState().GetDXUTInited() )
    {
        // If DXUTInit() was already called and failed, then fail.
        // DXUTInit() must first succeed for this function to succeed
        if( GetDXUTState().GetDXUTInitCalled() )
            return E_FAIL;

        // If DXUTInit() hasn't been called, then automatically call it
        // with default params
        hr = DXUTInit();
        if( FAILED( hr ) )
            return hr;
    }

    WCHAR* strCachedWindowTitle = GetDXUTState().GetWindowTitle();
    GetWindowText( hWndFocus, strCachedWindowTitle, 255 );
    strCachedWindowTitle[255] = 0;

    HINSTANCE hInstance = cast( HINSTANCE )cast( LONG_PTR )GetWindowLongPtr( hWndFocus, GWLP_HINSTANCE );
    GetDXUTState().SetHInstance( hInstance );
    GetDXUTState().SetWindowCreatedWithDefaultPositions( false );
    GetDXUTState().SetWindowCreated( true );
    GetDXUTState().SetHWNDFocus( hWndFocus );
    GetDXUTState().SetHWNDDeviceFullScreen( hWndDeviceFullScreen );
    GetDXUTState().SetHWNDDeviceWindowed( hWndDeviceWindowed );

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Handles window messages 
//--------------------------------------------------------------------------------------
LRESULT DXUTStaticWndProc( HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam )
{
    
    // Consolidate the keyboard messages and pass them to the app's keyboard callback
    if( uMsg == WM_KEYDOWN ||
        uMsg == WM_SYSKEYDOWN ||
        uMsg == WM_KEYUP ||
        uMsg == WM_SYSKEYUP )
    {
        bool bKeyDown = ( uMsg == WM_KEYDOWN || uMsg == WM_SYSKEYDOWN );
        DWORD dwMask = ( 1 << 29 );
        bool bAltDown = ( ( lParam & dwMask ) != 0 );

        bool* bKeys = GetDXUTState().GetKeys();
        bKeys[ cast( BYTE )( wParam & 0xFF ) ] = bKeyDown;

        LPDXUTCALLBACKKEYBOARD pCallbackKeyboard = GetDXUTState().GetKeyboardFunc();
        if( pCallbackKeyboard )
            pCallbackKeyboard( cast( UINT )wParam, bKeyDown, bAltDown, GetDXUTState().GetKeyboardFuncUserContext() );
    }

    // Consolidate the mouse button messages and pass them to the app's mouse callback
    if( uMsg == WM_LBUTTONDOWN ||
        uMsg == WM_LBUTTONUP ||
        uMsg == WM_LBUTTONDBLCLK ||
        uMsg == WM_MBUTTONDOWN ||
        uMsg == WM_MBUTTONUP ||
        uMsg == WM_MBUTTONDBLCLK ||
        uMsg == WM_RBUTTONDOWN ||
        uMsg == WM_RBUTTONUP ||
        uMsg == WM_RBUTTONDBLCLK ||
        uMsg == WM_XBUTTONDOWN ||
        uMsg == WM_XBUTTONUP ||
        uMsg == WM_XBUTTONDBLCLK ||
        uMsg == WM_MOUSEWHEEL ||
        ( GetDXUTState().GetNotifyOnMouseMove() && uMsg == WM_MOUSEMOVE ) )
    {
        int xPos = cast( short )LOWORD( lParam );
        int yPos = cast( short )HIWORD( lParam );

        if( uMsg == WM_MOUSEWHEEL )
        {
            // WM_MOUSEWHEEL passes screen mouse coords
            // so convert them to client coords
            POINT pt;
            pt.x = xPos; pt.y = yPos;
            ScreenToClient( hWnd, &pt );
            xPos = pt.x; yPos = pt.y;
        }

        int nMouseWheelDelta = 0;
        if( uMsg == WM_MOUSEWHEEL )
            nMouseWheelDelta = cast( short )HIWORD( wParam );

        int nMouseButtonState = LOWORD( wParam );
        bool bLeftButton = ( ( nMouseButtonState & MK_LBUTTON ) != 0 );
        bool bRightButton = ( ( nMouseButtonState & MK_RBUTTON ) != 0 );
        bool bMiddleButton = ( ( nMouseButtonState & MK_MBUTTON ) != 0 );
        bool bSideButton1 = ( ( nMouseButtonState & MK_XBUTTON1 ) != 0 );
        bool bSideButton2 = ( ( nMouseButtonState & MK_XBUTTON2 ) != 0 );

        bool* bMouseButtons = GetDXUTState().GetMouseButtons();
        bMouseButtons[0] = bLeftButton;
        bMouseButtons[1] = bMiddleButton;
        bMouseButtons[2] = bRightButton;
        bMouseButtons[3] = bSideButton1;
        bMouseButtons[4] = bSideButton2;

        LPDXUTCALLBACKMOUSE pCallbackMouse = GetDXUTState().GetMouseFunc();
        if( pCallbackMouse )
            pCallbackMouse( bLeftButton, bRightButton, bMiddleButton, bSideButton1, bSideButton2, nMouseWheelDelta,
                            xPos, yPos, GetDXUTState().GetMouseFuncUserContext() );
    }

    // TODO - WM_POINTER for touch when on Windows 8.0

    // Pass all messages to the app's MsgProc callback, and don't 
    // process further messages if the apps says not to.
    LPDXUTCALLBACKMSGPROC pCallbackMsgProc = GetDXUTState().GetWindowMsgFunc();
    if( pCallbackMsgProc )
    {
        bool bNoFurtherProcessing = false;
        LRESULT nResult = pCallbackMsgProc( hWnd, uMsg, wParam, lParam, &bNoFurtherProcessing,
                                            GetDXUTState().GetWindowMsgFuncUserContext() );
        if( bNoFurtherProcessing )
            return nResult;
    }

    switch( uMsg )
    {
        case WM_PAINT:
        {          
            // Handle paint messages when the app is paused
            if( DXUTIsRenderingPaused() &&
                GetDXUTState().GetDeviceObjectsCreated() && GetDXUTState().GetDeviceObjectsReset() )
            {
                HRESULT hr;
                double fTime = DXUTGetTime();
                float fElapsedTime = DXUTGetElapsedTime();

                {
                    auto pd3dDevice = DXUTGetD3D11Device();
                    auto pDeferred = DXUTGetD3D11DeviceContext();
                    if( pd3dDevice )
                    {
                        LPDXUTCALLBACKD3D11FRAMERENDER pCallbackFrameRender = GetDXUTState().GetD3D11FrameRenderFunc();
                        if( pCallbackFrameRender &&
                            !GetDXUTState().GetRenderingOccluded() )
                        {
                            pCallbackFrameRender( pd3dDevice,pDeferred, fTime, fElapsedTime,
                                                  GetDXUTState().GetD3D11FrameRenderFuncUserContext() );
                        }

                        DWORD dwFlags = 0;
                        if( GetDXUTState().GetRenderingOccluded() )
                            dwFlags = DXGI_PRESENT_TEST;
                        else
                            dwFlags = GetDXUTState().GetCurrentDeviceSettings().3d11.PresentFlags;

                        auto pSwapChain = DXUTGetDXGISwapChain();
                        hr = pSwapChain.Present( 0, dwFlags );
                        if( DXGI_STATUS_OCCLUDED == hr )
                        {
                            // There is a window covering our entire rendering area.
                            // Don't render until we're visible again.
                            GetDXUTState().SetRenderingOccluded( true );
                        }
                        else if( SUCCEEDED( hr ) )
                        {
                            if( GetDXUTState().GetRenderingOccluded() )
                            {
                                // Now that we're no longer occluded
                                // allow us to render again
                                GetDXUTState().SetRenderingOccluded( false );
                            }
                        }
                    }
                }
            }
            break;
        }

        case WM_SIZE:
            
           if( SIZE_MINIMIZED == wParam )
            {
                DXUTPause( true, true ); // Pause while we're minimized

                GetDXUTState().SetMinimized( true );
                GetDXUTState().SetMaximized( false );
            }
            else
            {
                RECT rcCurrentClient;
                GetClientRect( DXUTGetHWND(), &rcCurrentClient );
                if( rcCurrentClient.top == 0 && rcCurrentClient.bottom == 0 )
                {
                    // Rapidly clicking the task bar to minimize and restore a window
                    // can cause a WM_SIZE message with SIZE_RESTORED when 
                    // the window has actually become minimized due to rapid change
                    // so just ignore this message
                }
                else if( SIZE_MAXIMIZED == wParam )
                {
                    if( GetDXUTState().GetMinimized() )
                        DXUTPause( false, false ); // Unpause since we're no longer minimized
                    GetDXUTState().SetMinimized( false );
                    GetDXUTState().SetMaximized( true );
                    DXUTCheckForWindowSizeChange();
                    DXUTCheckForWindowChangingMonitors();
                }
                else if( SIZE_RESTORED == wParam )
                {
                    //DXUTCheckForDXGIFullScreenSwitch();
                    if( GetDXUTState().GetMaximized() )
                    {
                        GetDXUTState().SetMaximized( false );
                        DXUTCheckForWindowSizeChange();
                        DXUTCheckForWindowChangingMonitors();
                    }
                    else if( GetDXUTState().GetMinimized() )
                    {
                        DXUTPause( false, false ); // Unpause since we're no longer minimized
                        GetDXUTState().SetMinimized( false );
                        DXUTCheckForWindowSizeChange();
                        DXUTCheckForWindowChangingMonitors();
                    }
                    else if( GetDXUTState().GetInSizeMove() )
                    {
                        // If we're neither maximized nor minimized, the window size 
                        // is changing by the user dragging the window edges.  In this 
                        // case, we don't reset the device yet -- we wait until the 
                        // user stops dragging, and a WM_EXITSIZEMOVE message comes.
                    }
                    else
                    {
                        // This WM_SIZE come from resizing the window via an API like SetWindowPos() so 
                        // resize and reset the device now.
                        DXUTCheckForWindowSizeChange();
                        DXUTCheckForWindowChangingMonitors();
                    }
                }
            }
            break;

        case WM_GETMINMAXINFO:
            ( cast( MINMAXINFO* )lParam ).ptMinTrackSize.x = DXUT_MIN_WINDOW_SIZE_X;
            ( cast( MINMAXINFO* )lParam ).ptMinTrackSize.y = DXUT_MIN_WINDOW_SIZE_Y;
            break;

        case WM_ENTERSIZEMOVE:
            // Halt frame movement while the app is sizing or moving
            DXUTPause( true, true );
            GetDXUTState().SetInSizeMove( true );
            break;

        case WM_EXITSIZEMOVE:
            DXUTPause( false, false );
            DXUTCheckForWindowSizeChange();
            DXUTCheckForWindowChangingMonitors();
            GetDXUTState().SetInSizeMove( false );
            break;

        case WM_SETCURSOR:
            if( DXUTIsActive() && !DXUTIsWindowed() )
            {
                if( !GetDXUTState().GetShowCursorWhenFullScreen() )
                    SetCursor( null );

                return true; // prevent Windows from setting cursor to window class cursor
            }
            break;

        case WM_ACTIVATEAPP:
            if( wParam == TRUE && !DXUTIsActive() ) // Handle only if previously not active 
            {
                GetDXUTState().SetActive( true );

                // Enable controller rumble & input when activating app
                DXUTEnableXInput( true );

                // The GetMinimizedWhileFullscreen() varible is used instead of !DXUTIsWindowed()
                // to handle the rare case toggling to windowed mode while the fullscreen application 
                // is minimized and thus making the pause count wrong
                if( GetDXUTState().GetMinimizedWhileFullscreen() )
                {
                    GetDXUTState().SetMinimizedWhileFullscreen( false );

                    DXUTToggleFullScreen();
                }

                // Upon returning to this app, potentially disable shortcut keys 
                // (Windows key, accessibility shortcuts) 
                DXUTAllowShortcutKeys( ( DXUTIsWindowed() ) ? GetDXUTState().GetAllowShortcutKeysWhenWindowed() :
                                       GetDXUTState().GetAllowShortcutKeysWhenFullscreen() );

            }
            else if( wParam == FALSE && DXUTIsActive() ) // Handle only if previously active 
            {
                GetDXUTState().SetActive( false );

                // Disable any controller rumble & input when de-activating app
                DXUTEnableXInput( false );

                if( !DXUTIsWindowed() )
                {
                    // Going from full screen to a minimized state 
                    ClipCursor( null );      // don't limit the cursor anymore
                    GetDXUTState().SetMinimizedWhileFullscreen( true );
                }

                // Restore shortcut keys (Windows key, accessibility shortcuts) to original state
                //
                // This is important to call here if the shortcuts are disabled, 
                // because if this is not done then the Windows key will continue to 
                // be disabled while this app is running which is very bad.
                // If the app crashes, the Windows key will return to normal.
                DXUTAllowShortcutKeys( true );
            }
            break;

        case WM_ENTERMENULOOP:
            // Pause the app when menus are displayed
            DXUTPause( true, true );
            break;

        case WM_EXITMENULOOP:
            DXUTPause( false, false );
            break;

        case WM_MENUCHAR:
            // A menu is active and the user presses a key that does not correspond to any mnemonic or accelerator key
            // So just ignore and don't beep
            return MAKELRESULT( 0, MNC_CLOSE );
            break;

        case WM_NCHITTEST:
            // Prevent the user from selecting the menu in full screen mode
            if( !DXUTIsWindowed() )
                return HTCLIENT;
            break;

        case WM_POWERBROADCAST:
            switch( wParam )
            {
                case PBT_APMQUERYSUSPEND:
                    // At this point, the app should save any data for open
                    // network connections, files, etc., and prepare to go into
                    // a suspended mode.  The app can use the MsgProc callback
                    // to handle this if desired.
                    return true;

                case PBT_APMRESUMESUSPEND:
                    // At this point, the app should recover any data, network
                    // connections, files, etc., and resume running from when
                    // the app was suspended. The app can use the MsgProc callback
                    // to handle this if desired.

                    // QPC may lose consistency when suspending, so reset the timer
                    // upon resume.
                    DXUTGetGlobalTimer().Reset();
                    GetDXUTState().SetLastStatsUpdateTime( 0 );
                    return true;
            }
            break;

        case WM_SYSCOMMAND:
            // Prevent moving/sizing in full screen mode
            switch( ( wParam & 0xFFF0 ) )
            {
                case SC_MOVE:
                case SC_SIZE:
                case SC_MAXIMIZE:
                case SC_KEYMENU:
                    if( !DXUTIsWindowed() )
                        return 0;
                    break;
            }
            break;

        case WM_KEYDOWN:
        {
            switch( wParam )
            {
                case VK_ESCAPE:
                {
                    if( GetDXUTState().GetHandleEscape() )
                        SendMessage( hWnd, WM_CLOSE, 0, 0 );
                    break;
                }

                case VK_PAUSE:
                {
                    if( GetDXUTState().GetHandlePause() )
                    {
                        bool bTimePaused = DXUTIsTimePaused();
                        bTimePaused = !bTimePaused;
                        if( bTimePaused )
                            DXUTPause( true, false );
                        else
                            DXUTPause( false, false );
                    }
                    break;
                }
            }
            break;
        }

        case WM_CLOSE:
        {
            HMENU hMenu;
            hMenu = GetMenu( hWnd );
            if( hMenu )
                DestroyMenu( hMenu );
            DestroyWindow( hWnd );
            UnregisterClass( "Direct3DWindowClass", null );
            GetDXUTState().SetHWNDFocus( null );
            GetDXUTState().SetHWNDDeviceFullScreen( null );
            GetDXUTState().SetHWNDDeviceWindowed( null );
            return 0;
        }

        case WM_DESTROY:
            PostQuitMessage( 0 );
            break;
    }

    // Don't allow the F10 key to act as a shortcut to the menu bar
    // by not passing these messages to the DefWindowProc only when
    // there's no menu present
    if( !GetDXUTState().GetCallDefWindowProc() || !GetDXUTState().GetMenu() &&
        ( uMsg == WM_SYSKEYDOWN || uMsg == WM_SYSKEYUP ) && wParam == VK_F10 )
        return 0;
    else
        return DefWindowProc( hWnd, uMsg, wParam, lParam );
}


//--------------------------------------------------------------------------------------
// Handles app's message loop and rendering when idle.  If DXUTCreateDevice()
// has not already been called, it will call DXUTCreateWindow() with the default parameters.  
//--------------------------------------------------------------------------------------
HRESULT DXUTMainLoop( HACCEL hAccel )
{
    HRESULT hr;

    // Not allowed to call this from inside the device callbacks or reenter
    if( GetDXUTState().GetInsideDeviceCallback() || GetDXUTState().GetInsideMainloop() )
    {
        if( ( GetDXUTState().GetExitCode() == 0 ) || ( GetDXUTState().GetExitCode() == 10 ) )
            GetDXUTState().SetExitCode( 1 );
        return DXUT_ERR_MSGBOX( "DXUTMainLoop", E_FAIL );
    }

    GetDXUTState().SetInsideMainloop( true );

    // If DXUTCreateDevice() has not already been called, 
    // then call DXUTCreateDevice() with the default parameters.         
    if( !GetDXUTState().GetDeviceCreated() )
    {
        if( GetDXUTState().GetDeviceCreateCalled() )
        {
            if( ( GetDXUTState().GetExitCode() == 0 ) || ( GetDXUTState().GetExitCode() == 10 ) )
                GetDXUTState().SetExitCode( 1 );
            return E_FAIL; // DXUTCreateDevice() must first succeed for this function to succeed
        }

        hr = DXUTCreateDevice(D3D_FEATURE_LEVEL_10_0, true, 800, 600);
        if( FAILED( hr ) )
        {
            if( ( GetDXUTState().GetExitCode() == 0 ) || ( GetDXUTState().GetExitCode() == 10 ) )
                GetDXUTState().SetExitCode( 1 );
            return hr;
        }
    }

    HWND hWnd = DXUTGetHWND();

    // DXUTInit() must have been called and succeeded for this function to proceed
    // DXUTCreateWindow() or DXUTSetWindow() must have been called and succeeded for this function to proceed
    // DXUTCreateDevice() or DXUTCreateDeviceFromSettings() must have been called and succeeded for this function to proceed
    if( !GetDXUTState().GetDXUTInited() || !GetDXUTState().GetWindowCreated() || !GetDXUTState().GetDeviceCreated() )
    {
        if( ( GetDXUTState().GetExitCode() == 0 ) || ( GetDXUTState().GetExitCode() == 10 ) )
            GetDXUTState().SetExitCode( 1 );
        return DXUT_ERR_MSGBOX( "DXUTMainLoop", E_FAIL );
    }

    // Now we're ready to receive and process Windows messages.
    bool bGotMsg;
    MSG msg;
    msg.message = WM_NULL;
    PeekMessage( &msg, null, 0U, 0U, PM_NOREMOVE );

    while( WM_QUIT != msg.message )
    {
        // Use PeekMessage() so we can use idle time to render the scene. 
        bGotMsg = ( PeekMessage( &msg, null, 0U, 0U, PM_REMOVE ) != 0 );

        if( bGotMsg )
        {
            // Translate and dispatch the message
            if( !hAccel || !hWnd ||
                0 == TranslateAccelerator( hWnd, hAccel, &msg ) )
            {
                TranslateMessage( &msg );
                DispatchMessage( &msg );
            }
        }
        else
        {
            // Render a frame during idle time (no messages are waiting)
            DXUTRender3DEnvironment();
        }
    }

    // Cleanup the accelerator table
    if( hAccel )
        DestroyAcceleratorTable( hAccel );

    GetDXUTState().SetInsideMainloop( false );

    return S_OK;
}


//======================================================================================
//======================================================================================
// Direct3D section
//======================================================================================
//======================================================================================
HRESULT DXUTCreateDevice(D3D_FEATURE_LEVEL reqFL,  bool bWindowed, int nSuggestedWidth, int nSuggestedHeight)
{
    HRESULT hr = S_OK; 
   
    // Not allowed to call this from inside the device callbacks
    if( GetDXUTState().GetInsideDeviceCallback() )
        return DXUT_ERR_MSGBOX( "DXUTCreateDevice", E_FAIL );

    GetDXUTState().SetDeviceCreateCalled( true );

    // If DXUTCreateWindow() or DXUTSetWindow() has not already been called, 
    // then call DXUTCreateWindow() with the default parameters.         
    if( !GetDXUTState().GetWindowCreated() )
    {
        // If DXUTCreateWindow() or DXUTSetWindow() was already called and failed, then fail.
        // DXUTCreateWindow() or DXUTSetWindow() must first succeed for this function to succeed
        if( GetDXUTState().GetWindowCreateCalled() )
            return E_FAIL;

        // If DXUTCreateWindow() or DXUTSetWindow() hasn't been called, then 
        // automatically call DXUTCreateWindow() with default params
        hr = DXUTCreateWindow();
        if( FAILED( hr ) )
            return hr;
    }
    
    DXUTDeviceSettings deviceSettings;
    DXUTApplyDefaultDeviceSettings(&deviceSettings);
    deviceSettings.MinimumFeatureLevel = reqFL;
    deviceSettings.d3d11.sd.BufferDesc.Width = nSuggestedWidth;
    deviceSettings.d3d11.sd.BufferDesc.Height = nSuggestedHeight;
    deviceSettings.d3d11.sd.Windowed = bWindowed;

    DXUTUpdateDeviceSettingsWithOverrides(&deviceSettings); 

    GetDXUTState().SetWindowBackBufferWidthAtModeChange(deviceSettings.d3d11.sd.BufferDesc.Width);
    GetDXUTState().SetWindowBackBufferHeightAtModeChange(deviceSettings.d3d11.sd.BufferDesc.Height);
    GetDXUTState().SetFullScreenBackBufferWidthAtModeChange(deviceSettings.d3d11.sd.BufferDesc.Width);
    GetDXUTState().SetFullScreenBackBufferHeightAtModeChange(deviceSettings.d3d11.sd.BufferDesc.Height);

    // Change to a Direct3D device created from the new device settings.  
    // If there is an existing device, then either reset or recreated the scene
    hr = DXUTChangeDevice( &deviceSettings, true );

    if ( hr ==  DXUTERR_NODIRECT3D && GetDXUTState().GetMessageWhenD3D11NotAvailable() )
    {
        OSVERSIONINFOEX osv;
        memset( &osv, 0, sizeof(osv) );
        osv.dwOSVersionInfoSize = sizeof(osv);
        GetVersionEx( (LPOSVERSIONINFO)&osv );

        if ( ( osv.dwMajorVersion > 6 )
            || ( osv.dwMajorVersion == 6 && osv.dwMinorVersion >= 1 ) 
            || ( osv.dwMajorVersion == 6 && osv.dwMinorVersion == 0 && osv.dwBuildNumber > 6002 ) )
        {
            MessageBox( 0, "Direct3D 11 components were not found.", "Error", MB_ICONEXCLAMATION );
           // This should not happen, but is here for completeness as the system could be
           // corrupted or some future OS version could pull D3D11.DLL for some reason
        }
        else if ( osv.dwMajorVersion == 6 && osv.dwMinorVersion == 0 && osv.dwBuildNumber == 6002 )
        {
            MessageBox( 0, "Direct3D 11 components were not found, but are available for"~
            " this version of Windows.\n"~
            "For details see Microsoft Knowledge Base Article #971644\n"~
            "http://go.microsoft.com/fwlink/?LinkId=160189", "Error", MB_ICONEXCLAMATION );
        }
        else if ( osv.dwMajorVersion == 6 && osv.dwMinorVersion == 0 )
        {
            MessageBox( 0, "Direct3D 11 components were not found. Please install the latest Service Pack.\n"~
            "For details see Microsoft Knowledge Base Article #935791\n"~
            "http://support.microsoft.com/kb/935791/", "Error", MB_ICONEXCLAMATION );
        }
        else
        {
            MessageBox( 0, "Direct3D 11 is not supported on this OS.", "Error", MB_ICONEXCLAMATION );
        }
    }

    if( FAILED( hr ) )
        return hr;
    
    return hr;
}


//--------------------------------------------------------------------------------------
// Tells the framework to change to a device created from the passed in device settings
// If DXUTCreateWindow() has not already been called, it will call it with the 
// default parameters.  Instead of calling this, you can call DXUTCreateDevice() 
//--------------------------------------------------------------------------------------
HRESULT DXUTCreateDeviceFromSettings( DXUTDeviceSettings* pDeviceSettings, bool bClipWindowToSingleAdapter )
{
    if ( !pDeviceSettings )
        return E_INVALIDARG;

    HRESULT hr;

    GetDXUTState().SetDeviceCreateCalled( true );

    // If DXUTCreateWindow() or DXUTSetWindow() has not already been called, 
    // then call DXUTCreateWindow() with the default parameters.         
    if( !GetDXUTState().GetWindowCreated() )
    {
        // If DXUTCreateWindow() or DXUTSetWindow() was already called and failed, then fail.
        // DXUTCreateWindow() or DXUTSetWindow() must first succeed for this function to succeed
        if( GetDXUTState().GetWindowCreateCalled() )
            return E_FAIL;

        // If DXUTCreateWindow() or DXUTSetWindow() hasn't been called, then 
        // automatically call DXUTCreateWindow() with default params
        hr = DXUTCreateWindow();
        if( FAILED( hr ) )
            return hr;
    }

    DXUTUpdateDeviceSettingsWithOverrides(pDeviceSettings); 

    GetDXUTState().SetWindowBackBufferWidthAtModeChange(pDeviceSettings.3d11.sd.BufferDesc.Width);
    GetDXUTState().SetWindowBackBufferHeightAtModeChange(pDeviceSettings.3d11.sd.BufferDesc.Height);
    GetDXUTState().SetFullScreenBackBufferWidthAtModeChange(pDeviceSettings.3d11.sd.BufferDesc.Width);
    GetDXUTState().SetFullScreenBackBufferHeightAtModeChange(pDeviceSettings.3d11.sd.BufferDesc.Height);

    // Change to a Direct3D device created from the new device settings.  
    // If there is an existing device, then either reset or recreate the scene
    hr = DXUTChangeDevice( pDeviceSettings, bClipWindowToSingleAdapter );
    if( FAILED( hr ) )
        return hr;

    return S_OK;
}


//--------------------------------------------------------------------------------------
// All device changes are sent to this function.  It looks at the current 
// device (if any) and the new device and determines the best course of action.  It 
// also remembers and restores the window state if toggling between windowed and fullscreen
// as well as sets the proper window and system state for switching to the new device.
//--------------------------------------------------------------------------------------
HRESULT DXUTChangeDevice( DXUTDeviceSettings* pNewDeviceSettings,
                          bool bClipWindowToSingleAdapter )
{
    if ( GetDXUTState().GetReleasingSwapChain() )
        return S_FALSE;

    HRESULT hr = S_OK;
    DXUTDeviceSettings* pOldDeviceSettings = GetDXUTState().GetCurrentDeviceSettings();

    if( !pNewDeviceSettings )
        return S_FALSE;

    hr = DXUTDelayLoadDXGI();

    if( FAILED( hr ) )
        return hr;

    // Make a copy of the pNewDeviceSettings on the heap
    DXUTDeviceSettings* pNewDeviceSettingsOnHeap = new (std::nothrow) DXUTDeviceSettings;
    if( !pNewDeviceSettingsOnHeap )
        return E_OUTOFMEMORY;
    memcpy( pNewDeviceSettingsOnHeap, pNewDeviceSettings, sizeof( DXUTDeviceSettings ) );
    pNewDeviceSettings = pNewDeviceSettingsOnHeap;

    GetDXUTState().SetCurrentDeviceSettings(pNewDeviceSettingsOnHeap);
    hr = DXUTSnapDeviceSettingsToEnumDevice(pNewDeviceSettingsOnHeap, false);

    if( FAILED( hr ) ) // the call will fail if no valid devices were found
    {
        DXUTDisplayErrorMessage( hr );
        return DXUT_ERR( "DXUTFindValidDeviceSettings", hr );
    }

    // If the ModifyDeviceSettings callback is non-NULL, then call it to let the app 
    // change the settings or reject the device change by returning false.
    LPDXUTCALLBACKMODIFYDEVICESETTINGS pCallbackModifyDeviceSettings = GetDXUTState().GetModifyDeviceSettingsFunc();
    if( pCallbackModifyDeviceSettings )
    {
        bool bContinue = pCallbackModifyDeviceSettings( pNewDeviceSettings,
                                                        GetDXUTState().GetModifyDeviceSettingsFuncUserContext() );
        if( !bContinue )
        {
            // The app rejected the device change by returning false, so just use the current device if there is one.
            if( !pOldDeviceSettings )
                DXUTDisplayErrorMessage( DXUTERR_NOCOMPATIBLEDEVICES );
            SAFE_DELETE( pNewDeviceSettings );
            return E_ABORT;
        }
        if( !GetDXUTState().GetDXGIFactory() ) // if DXUTShutdown() was called in the modify callback, just return
        {
            SAFE_DELETE( pNewDeviceSettings );
            return S_FALSE;
        }
        DXUTSnapDeviceSettingsToEnumDevice(pNewDeviceSettingsOnHeap, false); // modify the app specified settings to the closed enumerated settigns

        if( FAILED( hr ) ) // the call will fail if no valid devices were found
        {
            DXUTDisplayErrorMessage( hr );
            return DXUT_ERR( "DXUTFindValidDeviceSettings", hr );
        }

    }

    GetDXUTState().SetCurrentDeviceSettings( pNewDeviceSettingsOnHeap );

    DXUTPause( true, true );

    // Take note if the backbuffer width & height are 0 now as they will change after pd3dDevice.Reset()
    bool bKeepCurrentWindowSize = false;
    if( DXUTGetBackBufferWidthFromDS( pNewDeviceSettings ) == 0 &&
        DXUTGetBackBufferHeightFromDS( pNewDeviceSettings ) == 0 )
        bKeepCurrentWindowSize = true;

    //////////////////////////
    // Before reset
    /////////////////////////

    if( DXUTGetIsWindowedFromDS( pNewDeviceSettings ) )
    {
        // Going to windowed mode
        if( pOldDeviceSettings && !DXUTGetIsWindowedFromDS( pOldDeviceSettings ) )
        {
            // Going from fullscreen . windowed
            GetDXUTState().SetFullScreenBackBufferWidthAtModeChange( DXUTGetBackBufferWidthFromDS(
                                                                        pOldDeviceSettings ) );
            GetDXUTState().SetFullScreenBackBufferHeightAtModeChange( DXUTGetBackBufferHeightFromDS(
                                                                        pOldDeviceSettings ) );
        }
    }
    else
    {
        // Going to fullscreen mode
        if( !pOldDeviceSettings || ( pOldDeviceSettings && DXUTGetIsWindowedFromDS( pOldDeviceSettings ) ) )
        {
            // Transistioning to full screen mode from a standard window so 
            if( pOldDeviceSettings )
            {
                GetDXUTState().SetWindowBackBufferWidthAtModeChange( DXUTGetBackBufferWidthFromDS(
                                                                        pOldDeviceSettings ) );
                GetDXUTState().SetWindowBackBufferHeightAtModeChange( DXUTGetBackBufferHeightFromDS(
                                                                        pOldDeviceSettings ) );
            }
        }
    }

    if( pOldDeviceSettings )
        DXUTCleanup3DEnvironment( false );

    // Create the D3D device and call the app's device callbacks
    hr = DXUTCreate3DEnvironment11();
    if( FAILED( hr ) )
    {
        SAFE_DELETE( pOldDeviceSettings );
        DXUTCleanup3DEnvironment( true );
        DXUTDisplayErrorMessage( hr );
        DXUTPause( false, false );
        GetDXUTState().SetIgnoreSizeChange( false );
        return hr;
    }

    // Enable/disable StickKeys shortcut, ToggleKeys shortcut, FilterKeys shortcut, and Windows key 
    // to prevent accidental task switching
    DXUTAllowShortcutKeys( ( DXUTGetIsWindowedFromDS( pNewDeviceSettings ) ) ?
                           GetDXUTState().GetAllowShortcutKeysWhenWindowed() :
                           GetDXUTState().GetAllowShortcutKeysWhenFullscreen() );

    HMONITOR hAdapterMonitor = DXUTGetMonitorFromAdapter( pNewDeviceSettings );
    GetDXUTState().SetAdapterMonitor( hAdapterMonitor );

    // Update the device stats text
    DXUTUpdateStaticFrameStats();

    if( pOldDeviceSettings && !DXUTGetIsWindowedFromDS( pOldDeviceSettings ) &&
        DXUTGetIsWindowedFromDS( pNewDeviceSettings ) )
    {
        // Going from fullscreen . windowed

        // Restore the show state, and positions/size of the window to what it was
        // It is important to adjust the window size 
        // after resetting the device rather than beforehand to ensure 
        // that the monitor resolution is correct and does not limit the size of the new window.
        auto pwp = GetDXUTState().GetWindowedPlacement();
        SetWindowPlacement( DXUTGetHWNDDeviceWindowed(), pwp );

        // Also restore the z-order of window to previous state
        HWND hWndInsertAfter = GetDXUTState().GetTopmostWhileWindowed() ? HWND_TOPMOST : HWND_NOTOPMOST;
        SetWindowPos( DXUTGetHWNDDeviceWindowed(), hWndInsertAfter, 0, 0, 0, 0,
                      SWP_NOMOVE | SWP_NOREDRAW | SWP_NOSIZE );
    }

    // Check to see if the window needs to be resized.  
    // Handle cases where the window is minimized and maxmimized as well.
 
    bool bNeedToResize = false;
    if( DXUTGetIsWindowedFromDS( pNewDeviceSettings ) && // only resize if in windowed mode
        !bKeepCurrentWindowSize )                      // only resize if pp.BackbufferWidth/Height were not 0
    {
        UINT nClientWidth;
        UINT nClientHeight;
        if( IsIconic( DXUTGetHWNDDeviceWindowed() ) )
        {
            // Window is currently minimized. To tell if it needs to resize, 
            // get the client rect of window when its restored the 
            // hard way using GetWindowPlacement()
            WINDOWPLACEMENT wp = {};
            wp.length = sizeof( WINDOWPLACEMENT );
            GetWindowPlacement( DXUTGetHWNDDeviceWindowed(), &wp );

            if( ( wp.flags & WPF_RESTORETOMAXIMIZED ) != 0 && wp.showCmd == SW_SHOWMINIMIZED )
            {
                // WPF_RESTORETOMAXIMIZED means that when the window is restored it will
                // be maximized.  So maximize the window temporarily to get the client rect 
                // when the window is maximized.  GetSystemMetrics( SM_CXMAXIMIZED ) will give this 
                // information if the window is on the primary but this will work on multimon.
                ShowWindow( DXUTGetHWNDDeviceWindowed(), SW_RESTORE );
                RECT rcClient;
                GetClientRect( DXUTGetHWNDDeviceWindowed(), &rcClient );
                nClientWidth = ( UINT )( rcClient.right - rcClient.left );
                nClientHeight = ( UINT )( rcClient.bottom - rcClient.top );
                ShowWindow( DXUTGetHWNDDeviceWindowed(), SW_MINIMIZE );
            }
            else
            {
                // Use wp.rcNormalPosition to get the client rect, but wp.rcNormalPosition 
                // includes the window frame so subtract it
                RECT rcFrame = {};
                AdjustWindowRect( &rcFrame, GetDXUTState().GetWindowedStyleAtModeChange(), GetDXUTState().GetMenu() != 0 );
                LONG nFrameWidth = rcFrame.right - rcFrame.left;
                LONG nFrameHeight = rcFrame.bottom - rcFrame.top;
                nClientWidth = ( UINT )( wp.rcNormalPosition.right - wp.rcNormalPosition.left - nFrameWidth );
                nClientHeight = ( UINT )( wp.rcNormalPosition.bottom - wp.rcNormalPosition.top - nFrameHeight );
            }
        }
        else
        {
            // Window is restored or maximized so just get its client rect
            RECT rcClient;
            GetClientRect( DXUTGetHWNDDeviceWindowed(), &rcClient );
            nClientWidth = ( UINT )( rcClient.right - rcClient.left );
            nClientHeight = ( UINT )( rcClient.bottom - rcClient.top );
        }

        // Now that we know the client rect, compare it against the back buffer size
        // to see if the client rect is already the right size
        if( nClientWidth != DXUTGetBackBufferWidthFromDS( pNewDeviceSettings ) ||
            nClientHeight != DXUTGetBackBufferHeightFromDS( pNewDeviceSettings ) )
        {
            bNeedToResize = true;
        }

        if( bClipWindowToSingleAdapter && !IsIconic( DXUTGetHWNDDeviceWindowed() ) )
        {
            // Get the rect of the monitor attached to the adapter
            MONITORINFO miAdapter;
            miAdapter.cbSize = sizeof( MONITORINFO );
            hAdapterMonitor = DXUTGetMonitorFromAdapter( pNewDeviceSettings );
            DXUTGetMonitorInfo( hAdapterMonitor, &miAdapter );
            HMONITOR hWindowMonitor = DXUTMonitorFromWindow( DXUTGetHWND(), MONITOR_DEFAULTTOPRIMARY );

            // Get the rect of the window
            RECT rcWindow;
            GetWindowRect( DXUTGetHWNDDeviceWindowed(), &rcWindow );

            // Check if the window rect is fully inside the adapter's vitural screen rect
            if( ( rcWindow.left < miAdapter.rcWork.left ||
                  rcWindow.right > miAdapter.rcWork.right ||
                  rcWindow.top < miAdapter.rcWork.top ||
                  rcWindow.bottom > miAdapter.rcWork.bottom ) )
            {
                if( hWindowMonitor == hAdapterMonitor && IsZoomed( DXUTGetHWNDDeviceWindowed() ) )
                {
                    // If the window is maximized and on the same monitor as the adapter, then 
                    // no need to clip to single adapter as the window is already clipped 
                    // even though the rcWindow rect is outside of the miAdapter.rcWork
                }
                else
                {
                    bNeedToResize = true;
                }
            }
        }
    }

    // Only resize window if needed 

    if( bNeedToResize )
    {
        // Need to resize, so if window is maximized or minimized then restore the window
        if( IsIconic( DXUTGetHWNDDeviceWindowed() ) )
            ShowWindow( DXUTGetHWNDDeviceWindowed(), SW_RESTORE );
        if( IsZoomed( DXUTGetHWNDDeviceWindowed() ) ) // doing the IsIconic() check first also handles the WPF_RESTORETOMAXIMIZED case
            ShowWindow( DXUTGetHWNDDeviceWindowed(), SW_RESTORE );

        if( bClipWindowToSingleAdapter  )
        {
            // Get the rect of the monitor attached to the adapter
            MONITORINFO miAdapter;
            miAdapter.cbSize = sizeof( MONITORINFO );
            hAdapterMonitor = DXUTGetMonitorFromAdapter( pNewDeviceSettings );
            DXUTGetMonitorInfo( hAdapterMonitor, &miAdapter );

            // Get the rect of the monitor attached to the window
            MONITORINFO miWindow;
            miWindow.cbSize = sizeof( MONITORINFO );
            DXUTGetMonitorInfo( DXUTMonitorFromWindow( DXUTGetHWND(), MONITOR_DEFAULTTOPRIMARY ), &miWindow );

            // Do something reasonable if the BackBuffer size is greater than the monitor size
            int nAdapterMonitorWidth = miAdapter.rcWork.right - miAdapter.rcWork.left;
            int nAdapterMonitorHeight = miAdapter.rcWork.bottom - miAdapter.rcWork.top;

            int nClientWidth = DXUTGetBackBufferWidthFromDS( pNewDeviceSettings );
            int nClientHeight = DXUTGetBackBufferHeightFromDS( pNewDeviceSettings );

            // Get the rect of the window
            RECT rcWindow;
            GetWindowRect( DXUTGetHWNDDeviceWindowed(), &rcWindow );

            // Make a window rect with a client rect that is the same size as the backbuffer
            RECT rcResizedWindow;
            rcResizedWindow.left = 0;
            rcResizedWindow.right = nClientWidth;
            rcResizedWindow.top = 0;
            rcResizedWindow.bottom = nClientHeight;
            AdjustWindowRect( &rcResizedWindow, GetWindowLong( DXUTGetHWNDDeviceWindowed(), GWL_STYLE ),
                              GetDXUTState().GetMenu() != 0 );

            int nWindowWidth = rcResizedWindow.right - rcResizedWindow.left;
            int nWindowHeight = rcResizedWindow.bottom - rcResizedWindow.top;

            if( nWindowWidth > nAdapterMonitorWidth )
                nWindowWidth = nAdapterMonitorWidth;
            if( nWindowHeight > nAdapterMonitorHeight )
                nWindowHeight = nAdapterMonitorHeight;

            if( rcResizedWindow.left < miAdapter.rcWork.left ||
                rcResizedWindow.top < miAdapter.rcWork.top ||
                rcResizedWindow.right > miAdapter.rcWork.right ||
                rcResizedWindow.bottom > miAdapter.rcWork.bottom )
            {
                int nWindowOffsetX = ( nAdapterMonitorWidth - nWindowWidth ) / 2;
                int nWindowOffsetY = ( nAdapterMonitorHeight - nWindowHeight ) / 2;

                rcResizedWindow.left = miAdapter.rcWork.left + nWindowOffsetX;
                rcResizedWindow.top = miAdapter.rcWork.top + nWindowOffsetY;
                rcResizedWindow.right = miAdapter.rcWork.left + nWindowOffsetX + nWindowWidth;
                rcResizedWindow.bottom = miAdapter.rcWork.top + nWindowOffsetY + nWindowHeight;
            }

            // Resize the window.  It is important to adjust the window size 
            // after resetting the device rather than beforehand to ensure 
            // that the monitor resolution is correct and does not limit the size of the new window.
            SetWindowPos( DXUTGetHWNDDeviceWindowed(), 0, rcResizedWindow.left, rcResizedWindow.top, nWindowWidth,
                          nWindowHeight, SWP_NOZORDER );
        }
        else
        {
            // Make a window rect with a client rect that is the same size as the backbuffer
            RECT rcWindow = {};
            rcWindow.right = (long)( DXUTGetBackBufferWidthFromDS(pNewDeviceSettings) );
            rcWindow.bottom = (long)( DXUTGetBackBufferHeightFromDS(pNewDeviceSettings) );
            AdjustWindowRect( &rcWindow, GetWindowLong( DXUTGetHWNDDeviceWindowed(), GWL_STYLE ), GetDXUTState().GetMenu() != 0 );

            // Resize the window.  It is important to adjust the window size 
            // after resetting the device rather than beforehand to ensure 
            // that the monitor resolution is correct and does not limit the size of the new window.
            int cx = ( int )( rcWindow.right - rcWindow.left );
            int cy = ( int )( rcWindow.bottom - rcWindow.top );
            SetWindowPos( DXUTGetHWNDDeviceWindowed(), 0, 0, 0, cx, cy, SWP_NOZORDER | SWP_NOMOVE );
        }

        // Its possible that the new window size is not what we asked for.  
        // No window can be sized larger than the desktop, so see if the Windows OS resized the 
        // window to something smaller to fit on the desktop.  Also if WM_GETMINMAXINFO
        // will put a limit on the smallest/largest window size.
        RECT rcClient;
        GetClientRect( DXUTGetHWNDDeviceWindowed(), &rcClient );
        UINT nClientWidth = ( UINT )( rcClient.right - rcClient.left );
        UINT nClientHeight = ( UINT )( rcClient.bottom - rcClient.top );
        if( nClientWidth != DXUTGetBackBufferWidthFromDS( pNewDeviceSettings ) ||
            nClientHeight != DXUTGetBackBufferHeightFromDS( pNewDeviceSettings ) )
        {
            // If its different, then resize the backbuffer again.  This time create a backbuffer that matches the 
            // client rect of the current window w/o resizing the window.
            auto deviceSettings = DXUTGetDeviceSettings();
            deviceSettings.d3d11.sd.BufferDesc.Width = 0; 
            deviceSettings.d3d11.sd.BufferDesc.Height = 0;

            hr = DXUTChangeDevice( &deviceSettings, bClipWindowToSingleAdapter );
            if( FAILED( hr ) )
            {
                SAFE_DELETE( pOldDeviceSettings );
                DXUTCleanup3DEnvironment( true );
                DXUTPause( false, false );
                GetDXUTState().SetIgnoreSizeChange( false );
                return hr;
            }
        }
    }

    //if (DXUTGetIsWindowedFromDS( pNewDeviceSettings )) {
    //    RECT rcFrame = {};
    //    AdjustWindowRect( &rcFrame, GetDXUTState().GetWindowedStyleAtModeChange(), GetDXUTState().GetMenu() );
   // }

    // Make the window visible
    if( !IsWindowVisible( DXUTGetHWND() ) )
        ShowWindow( DXUTGetHWND(), SW_SHOW );

    // Ensure that the display doesn't power down when fullscreen but does when windowed
    if( !DXUTIsWindowed() )
        SetThreadExecutionState( ES_DISPLAY_REQUIRED | ES_CONTINUOUS );
    else
        SetThreadExecutionState( ES_CONTINUOUS );

    SAFE_DELETE( pOldDeviceSettings );
    GetDXUTState().SetIgnoreSizeChange( false );
    DXUTPause( false, false );
    GetDXUTState().SetDeviceCreated( true );

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Creates a DXGI factory object if one has not already been created  
//--------------------------------------------------------------------------------------
HRESULT DXUTDelayLoadDXGI()
{
    auto pDXGIFactory = GetDXUTState().GetDXGIFactory();
    if( !pDXGIFactory )
    {
        HRESULT hr = DXUT_Dynamic_CreateDXGIFactory1( IID_PPV_ARGS(&pDXGIFactory) );
        if ( FAILED(hr) )
            return hr;

        GetDXUTState().SetDXGIFactory( pDXGIFactory );
        if( !pDXGIFactory )
        {
            return DXUTERR_NODIRECT3D;
        }

        // DXGI 1.1 implies Direct3D 11
    }

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Updates the device settings with default values..  
//--------------------------------------------------------------------------------------
void DXUTUpdateDeviceSettingsWithOverrides( _Inout_ DXUTDeviceSettings* pDeviceSettings )
{
    // Override with settings from the command line
    if( GetDXUTState().GetOverrideWidth() != 0 )
    {
        pDeviceSettings.3d11.sd.BufferDesc.Width = GetDXUTState().GetOverrideWidth();
    }
    if( GetDXUTState().GetOverrideHeight() != 0 )
    {
        pDeviceSettings.3d11.sd.BufferDesc.Height = GetDXUTState().GetOverrideHeight();
    }

    if( GetDXUTState().GetOverrideAdapterOrdinal() != -1 )
    {
        pDeviceSettings.3d11.AdapterOrdinal = GetDXUTState().GetOverrideAdapterOrdinal();
    }

    if( GetDXUTState().GetOverrideFullScreen() )
    {
        pDeviceSettings.3d11.sd.Windowed = FALSE;
    }

    if( GetDXUTState().GetOverrideWindowed() )
    {
        pDeviceSettings.3d11.sd.Windowed = TRUE;
    }

    if( GetDXUTState().GetOverrideForceHAL() )
    {
        pDeviceSettings.3d11.DriverType = D3D_DRIVER_TYPE_HARDWARE;
    }

    if( GetDXUTState().GetOverrideForceREF() )
    {
        pDeviceSettings.3d11.DriverType = D3D_DRIVER_TYPE_REFERENCE;
    }

    if( GetDXUTState().GetOverrideForceWARP() )
    {
        pDeviceSettings.3d11.DriverType = D3D_DRIVER_TYPE_WARP;
        pDeviceSettings.3d11.sd.Windowed = TRUE;
    }

    if( GetDXUTState().GetOverrideForceVsync() == 0 )
    {
        pDeviceSettings.3d11.SyncInterval = 0;
    }
    else if( GetDXUTState().GetOverrideForceVsync() == 1 )
    {
        pDeviceSettings.3d11.SyncInterval = 1;
    }
  
    if (GetDXUTState().GetOverrideForceFeatureLevel() != 0)
    {
        pDeviceSettings.3d11.DeviceFeatureLevel = GetDXUTState().GetOverrideForceFeatureLevel();
    }
}


//--------------------------------------------------------------------------------------
// Sets the viewport, render target view, and depth stencil view.
//--------------------------------------------------------------------------------------
HRESULT DXUTSetupD3D11Views(ID3D11DeviceContext* pd3dDeviceContext )
{
    HRESULT hr = S_OK;

    // Setup the viewport to match the backbuffer
    D3D11_VIEWPORT vp;
    vp.Width = (FLOAT)DXUTGetDXGIBackBufferSurfaceDesc().Width;
    vp.Height = (FLOAT)DXUTGetDXGIBackBufferSurfaceDesc().Height;
    vp.MinDepth = 0;
    vp.MaxDepth = 1;
    vp.TopLeftX = 0;
    vp.TopLeftY = 0;
    pd3dDeviceContext.RSSetViewports( 1, &vp );

    // Set the render targets
    auto pRTV = GetDXUTState().GetD3D11RenderTargetView();
    auto pDSV = GetDXUTState().GetD3D11DepthStencilView();
    pd3dDeviceContext.OMSetRenderTargets( 1, &pRTV, pDSV );

    return hr;
}


//--------------------------------------------------------------------------------------
// Creates a render target view, and depth stencil texture and view.
//--------------------------------------------------------------------------------------
_Use_decl_annotations_
HRESULT DXUTCreateD3D11Views( ID3D11Device* pd3dDevice, ID3D11DeviceContext* pd3dImmediateContext,
                             DXUTDeviceSettings* pDeviceSettings )
{
    HRESULT hr = S_OK;
    auto pSwapChain = DXUTGetDXGISwapChain();
    ID3D11DepthStencilView* pDSV = null;
    ID3D11RenderTargetView* pRTV = null;

    // Get the back buffer and desc
    ID3D11Texture2D* pBackBuffer;
    hr = pSwapChain.GetBuffer( 0, IID_PPV_ARGS(&pBackBuffer) );
    if( FAILED( hr ) )
        return hr;
    D3D11_TEXTURE2D_DESC backBufferSurfaceDesc;
    pBackBuffer.GetDesc( &backBufferSurfaceDesc );

    // Create the render target view
    hr = pd3dDevice.CreateRenderTargetView( pBackBuffer, null, &pRTV );
    SAFE_RELEASE( pBackBuffer );
    if( FAILED( hr ) )
        return hr;
    DXUT_SetDebugName( pRTV, "DXUT" );
    GetDXUTState().SetD3D11RenderTargetView( pRTV );

    if( pDeviceSettings.3d11.AutoCreateDepthStencil )
    {
        // Create depth stencil texture
        ID3D11Texture2D* pDepthStencil = null;
        D3D11_TEXTURE2D_DESC descDepth;
        descDepth.Width = backBufferSurfaceDesc.Width;
        descDepth.Height = backBufferSurfaceDesc.Height;
        descDepth.MipLevels = 1;
        descDepth.ArraySize = 1;
        descDepth.Format = pDeviceSettings.3d11.AutoDepthStencilFormat;
        descDepth.SampleDesc.Count = pDeviceSettings.3d11.sd.SampleDesc.Count;
        descDepth.SampleDesc.Quality = pDeviceSettings.3d11.sd.SampleDesc.Quality;
        descDepth.Usage = D3D11_USAGE_DEFAULT;
        descDepth.BindFlags = D3D11_BIND_DEPTH_STENCIL;
        descDepth.CPUAccessFlags = 0;
        descDepth.MiscFlags = 0;
        hr = pd3dDevice.CreateTexture2D( &descDepth, null, &pDepthStencil );
        if( FAILED( hr ) )
            return hr;
        DXUT_SetDebugName( pDepthStencil, "DXUT" );
        GetDXUTState().SetD3D11DepthStencil( pDepthStencil );

        // Create the depth stencil view
        D3D11_DEPTH_STENCIL_VIEW_DESC descDSV;
        descDSV.Format = descDepth.Format;
        descDSV.Flags = 0;
        if( descDepth.SampleDesc.Count > 1 )
            descDSV.ViewDimension = D3D11_DSV_DIMENSION_TEXTURE2DMS;
        else
            descDSV.ViewDimension = D3D11_DSV_DIMENSION_TEXTURE2D;
        descDSV.Texture2D.MipSlice = 0;
        hr = pd3dDevice.CreateDepthStencilView( pDepthStencil, &descDSV, &pDSV );
        if( FAILED( hr ) )
            return hr;
        DXUT_SetDebugName( pDSV, "DXUT" );
        GetDXUTState().SetD3D11DepthStencilView( pDSV );
    }

    hr = DXUTSetupD3D11Views( pd3dImmediateContext );
    if( FAILED( hr ) )
        return hr;

    return hr;
}


//--------------------------------------------------------------------------------------
// Creates the 3D environment
//--------------------------------------------------------------------------------------
HRESULT DXUTCreate3DEnvironment11()
{
    HRESULT hr = S_OK;

    ID3D11Device* pd3d11Device = null;
    ID3D11DeviceContext* pd3dImmediateContext = null;
    D3D_FEATURE_LEVEL FeatureLevel = D3D_FEATURE_LEVEL_11_1;

    IDXGISwapChain* pSwapChain = null;
    auto pNewDeviceSettings = GetDXUTState().GetCurrentDeviceSettings();
    assert( pNewDeviceSettings );
    _Analysis_assume_( pNewDeviceSettings );
        
    auto pDXGIFactory = DXUTGetDXGIFactory();
    assert( pDXGIFactory );
    _Analysis_assume_( pDXGIFactory );
    hr = pDXGIFactory.MakeWindowAssociation( DXUTGetHWND(), 0  );

    // Try to create the device with the chosen settings
    IDXGIAdapter1* pAdapter = null;

    hr = S_OK;
    D3D_DRIVER_TYPE ddt = pNewDeviceSettings.3d11.DriverType;
    if( pNewDeviceSettings.3d11.DriverType == D3D_DRIVER_TYPE_HARDWARE ) 
    {
        hr = pDXGIFactory.EnumAdapters1( pNewDeviceSettings.3d11.AdapterOrdinal, &pAdapter );
        if ( FAILED( hr) ) 
        {
            return E_FAIL;
        }
        ddt = D3D_DRIVER_TYPE_UNKNOWN;    
    }
    else if (pNewDeviceSettings.3d11.DriverType == D3D_DRIVER_TYPE_WARP) 
    {
        ddt = D3D_DRIVER_TYPE_WARP;  
        pAdapter = null;
    }
    else if (pNewDeviceSettings.3d11.DriverType == D3D_DRIVER_TYPE_REFERENCE) 
    {
        ddt = D3D_DRIVER_TYPE_REFERENCE;
        pAdapter = null;
    }

    if( SUCCEEDED( hr ) )
    {
        hr = DXUT_Dynamic_D3D11CreateDevice( pAdapter,
                                             ddt,
                                             ( HMODULE )0,
                                             pNewDeviceSettings.3d11.CreateFlags,
                                             &pNewDeviceSettings.3d11.DeviceFeatureLevel,
                                             1,
                                             D3D11_SDK_VERSION,
                                             &pd3d11Device,
                                             &FeatureLevel,
                                             &pd3dImmediateContext
                                             );
            
        if ( FAILED( hr ) )
        {
            pAdapter = null;
            // Remote desktop does not allow you to enumerate the adapter.  In this case, we let D3D11 do the enumeration.
            if ( ddt == D3D_DRIVER_TYPE_UNKNOWN )
            { 
                hr = DXUT_Dynamic_D3D11CreateDevice( pAdapter,
                                                     D3D_DRIVER_TYPE_HARDWARE,
                                                     ( HMODULE )0,
                                                     pNewDeviceSettings.3d11.CreateFlags,
                                                     &pNewDeviceSettings.3d11.DeviceFeatureLevel,
                                                     1,
                                                     D3D11_SDK_VERSION,
                                                     &pd3d11Device,
                                                     &FeatureLevel,
                                                     &pd3dImmediateContext
                                                     );
            }
            if ( FAILED ( hr ) )
            {
                DXUT_ERR( "D3D11CreateDevice", hr );
                return DXUTERR_CREATINGDEVICE;
            }
        }
    }

// static if(!no_debug)
{
        if( SUCCEEDED( hr ) )
    {
        ID3D11Debug * d3dDebug = null;
        if( SUCCEEDED( pd3d11Device.QueryInterface(IID_PPV_ARGS(&d3dDebug) ) ) )
        {
            ID3D11InfoQueue* infoQueue = null;
            if( SUCCEEDED( d3dDebug.QueryInterface( IID_PPV_ARGS(&infoQueue) ) ) )
            {
                // ignore some "expected" errors
                D3D11_MESSAGE_ID denied [] =
                {
                    D3D11_MESSAGE_ID_SETPRIVATEDATA_CHANGINGPARAMS,
                };

                D3D11_INFO_QUEUE_FILTER filter;
                memset( &filter, 0, sizeof(filter) );
                filter.DenyList.NumIDs = _countof(denied);
                filter.DenyList.pIDList = denied;
                infoQueue.AddStorageFilterEntries( &filter );
                infoQueue.Release();
            }
            d3dDebug.Release();
        }
    }
}

    if( SUCCEEDED( hr ) )
    {
        IDXGIDevice1* pDXGIDev = null;
        hr = pd3d11Device.QueryInterface( IID_PPV_ARGS(&pDXGIDev) );
        if( SUCCEEDED( hr ) && pDXGIDev )
        {
            if ( !pAdapter ) 
            {
                IDXGIAdapter *pTempAdapter = null;
                V_RETURN( pDXGIDev.GetAdapter( &pTempAdapter ) );
                V_RETURN( pTempAdapter.QueryInterface( IID_PPV_ARGS(&pAdapter) ) );
                V_RETURN( pAdapter.GetParent( IID_PPV_ARGS(&pDXGIFactory) ) );
                SAFE_RELEASE ( pTempAdapter );
                if ( GetDXUTState().GetDXGIFactory() != pDXGIFactory )
                    GetDXUTState().GetDXGIFactory().Release();
                GetDXUTState().SetDXGIFactory( pDXGIFactory );
            }
        }
        SAFE_RELEASE( pDXGIDev );
        GetDXUTState().SetDXGIAdapter( pAdapter );
    }

    if( FAILED( hr ) )
    {
        DXUT_ERR( "D3D11CreateDevice", hr );
        return DXUTERR_CREATINGDEVICE;
    }

    // set default render state to msaa enabled
    D3D11_RASTERIZER_DESC drd = {
        D3D11_FILL_SOLID, //D3D11_FILL_MODE FillMode;
        D3D11_CULL_BACK,//D3D11_CULL_MODE CullMode;
        FALSE, //BOOL FrontCounterClockwise;
        0, //INT DepthBias;
        0.0f,//FLOAT DepthBiasClamp;
        0.0f,//FLOAT SlopeScaledDepthBias;
        TRUE,//BOOL DepthClipEnable;
        FALSE,//BOOL ScissorEnable;
        TRUE,//BOOL MultisampleEnable;
        FALSE//BOOL AntialiasedLineEnable;        
    };
    ID3D11RasterizerState* pRS = null;
    hr = pd3d11Device.CreateRasterizerState(&drd, &pRS);
    if ( FAILED( hr ) )
    {
        DXUT_ERR( "CreateRasterizerState", hr );
        return DXUTERR_CREATINGDEVICE;
    }
    DXUT_SetDebugName( pRS, "DXUT Default" );
    GetDXUTState().SetD3D11RasterizerState(pRS);
    pd3dImmediateContext.RSSetState(pRS);

    // Enumerate its outputs.
    UINT OutputCount, iOutput;
    for( OutputCount = 0; ; ++OutputCount )
    {
        IDXGIOutput* pOutput;
        if( FAILED( pAdapter.EnumOutputs( OutputCount, &pOutput ) ) )
            break;
        SAFE_RELEASE( pOutput );
    }
    auto ppOutputArray = new (std::nothrow) IDXGIOutput*[OutputCount];
    if( !ppOutputArray )
        return E_OUTOFMEMORY;
    for( iOutput = 0; iOutput < OutputCount; ++iOutput )
        pAdapter.EnumOutputs( iOutput, ppOutputArray + iOutput );
    GetDXUTState().SetDXGIOutputArray( ppOutputArray );
    GetDXUTState().SetDXGIOutputArraySize( OutputCount );

    // Create the swapchain
    hr = pDXGIFactory.CreateSwapChain( pd3d11Device, &pNewDeviceSettings.3d11.sd, &pSwapChain );
    if( FAILED( hr ) )
    {
        DXUT_ERR( "CreateSwapChain", hr );
        return DXUTERR_CREATINGDEVICE;
    }

    GetDXUTState().SetD3D11Device( pd3d11Device );
    GetDXUTState().SetD3D11DeviceContext( pd3dImmediateContext );
    GetDXUTState().SetD3D11FeatureLevel( FeatureLevel );
    GetDXUTState().SetDXGISwapChain( pSwapChain );

    assert( pd3d11Device );
    _Analysis_assume_( pd3d11Device );

    assert( pd3dImmediateContext );
    _Analysis_assume_( pd3dImmediateContext );

    // Direct3D 11.1
    {
        ID3D11Device1* pd3d11Device1 = null;
        hr = pd3d11Device.QueryInterface(IID_PPV_ARGS(&pd3d11Device1));
        if( SUCCEEDED( hr ) && pd3d11Device1 )
        {
            GetDXUTState().SetD3D11Device1( pd3d11Device1 );

            ID3D11DeviceContext1* pd3dImmediateContext1 = null;
            hr = pd3dImmediateContext.QueryInterface(IID_PPV_ARGS(&pd3dImmediateContext1));
            if( SUCCEEDED( hr ) && pd3dImmediateContext1 )
            {
                GetDXUTState().SetD3D11DeviceContext1( pd3dImmediateContext1 ); 
            }
        }
    }

    // Direct3D 11.2
    {
        ID3D11Device2* pd3d11Device2 = null;
        hr = pd3d11Device.QueryInterface(IID_PPV_ARGS(&pd3d11Device2));
        if (SUCCEEDED(hr) && pd3d11Device2)
        {
            GetDXUTState().SetD3D11Device2(pd3d11Device2);

            ID3D11DeviceContext2* pd3dImmediateContext2 = null;
            hr = pd3dImmediateContext.QueryInterface(IID_PPV_ARGS(&pd3dImmediateContext2));
            if (SUCCEEDED(hr) && pd3dImmediateContext2)
            {
                GetDXUTState().SetD3D11DeviceContext2(pd3dImmediateContext2);
            }
        }
    }

static if(USE_DIRECT3D11_3)
{
    // Direct3D 11.3
    {
        ID3D11Device3* pd3d11Device3 = null;
        hr = pd3d11Device.QueryInterface( IID_PPV_ARGS(&pd3d11Device3) );
        if (SUCCEEDED(hr) && pd3d11Device3)
        {
            GetDXUTState().SetD3D11Device3(pd3d11Device3);

            ID3D11DeviceContext3* pd3dImmediateContext3 = null;
            hr = pd3dImmediateContext.QueryInterface(IID_PPV_ARGS(&pd3dImmediateContext3));
            if (SUCCEEDED(hr) && pd3dImmediateContext3)
            {
                GetDXUTState().SetD3D11DeviceContext3(pd3dImmediateContext3);
            }
        }
    }
}
    
static if(USE_DIRECT3D11_4)
{
    // Direct3D 11.4
    {
        ID3D11Device4* pd3d11Device4 = null;
        hr = pd3d11Device.QueryInterface(IID_PPV_ARGS(&pd3d11Device4));
        if (SUCCEEDED(hr) && pd3d11Device4)
        {
            GetDXUTState().SetD3D11Device4(pd3d11Device4);

            ID3D11DeviceContext4* pd3dImmediateContext4 = null;
            hr = pd3dImmediateContext.QueryInterface(IID_PPV_ARGS(&pd3dImmediateContext4));
            if (SUCCEEDED(hr) && pd3dImmediateContext4)
            {
                GetDXUTState().SetD3D11DeviceContext4(pd3dImmediateContext4);
            }
        }
    }
}

    // If switching to REF, set the exit code to 11.  If switching to HAL and exit code was 11, then set it back to 0.
    if( pNewDeviceSettings.3d11.DriverType == D3D_DRIVER_TYPE_REFERENCE && GetDXUTState().GetExitCode() == 0 )
        GetDXUTState().SetExitCode( 10 );
    else if( pNewDeviceSettings.3d11.DriverType == D3D_DRIVER_TYPE_HARDWARE && GetDXUTState().GetExitCode() == 10 )
        GetDXUTState().SetExitCode( 0 );

    // Update back buffer desc before calling app's device callbacks
    DXUTUpdateBackBufferDesc();

    // Setup cursor based on current settings (window/fullscreen mode, show cursor state, clip cursor state)
    DXUTSetupCursor();

    // Update the device stats text
    auto pd3dEnum = DXUTGetD3D11Enumeration();
    assert( pd3dEnum );
    _Analysis_assume_( pd3dEnum );
    auto pAdapterInfo = pd3dEnum.GetAdapterInfo( pNewDeviceSettings.3d11.AdapterOrdinal );
    DXUTUpdateD3D11DeviceStats( pNewDeviceSettings.3d11.DriverType, pNewDeviceSettings.3d11.DeviceFeatureLevel, &pAdapterInfo.AdapterDesc );

    // Call the app's device created callback if non-NULL
    auto pBackBufferSurfaceDesc = DXUTGetDXGIBackBufferSurfaceDesc();
    GetDXUTState().SetInsideDeviceCallback( true );
    auto pCallbackDeviceCreated = GetDXUTState().GetD3D11DeviceCreatedFunc();
    hr = S_OK;
    if( pCallbackDeviceCreated )
        hr = pCallbackDeviceCreated( DXUTGetD3D11Device(), pBackBufferSurfaceDesc,
                                     GetDXUTState().GetD3D11DeviceCreatedFuncUserContext() );
    GetDXUTState().SetInsideDeviceCallback( false );
    if( !DXUTGetD3D11Device() ) // Handle DXUTShutdown from inside callback
        return E_FAIL;
    if( FAILED( hr ) )
    {
        DXUT_ERR( "DeviceCreated callback", hr );
        return ( hr == DXUTERR_MEDIANOTFOUND ) ? DXUTERR_MEDIANOTFOUND : DXUTERR_CREATINGDEVICEOBJECTS;
    }
    GetDXUTState().SetDeviceObjectsCreated( true );

    // Setup the render target view and viewport
    hr = DXUTCreateD3D11Views( pd3d11Device, pd3dImmediateContext, pNewDeviceSettings );
    if( FAILED( hr ) )
    {
        DXUT_ERR( "DXUTCreateD3D11Views", hr );
        return DXUTERR_CREATINGDEVICEOBJECTS;
    }

    // Call the app's swap chain reset callback if non-NULL
    GetDXUTState().SetInsideDeviceCallback( true );
    LPDXUTCALLBACKD3D11SWAPCHAINRESIZED pCallbackSwapChainResized = GetDXUTState().GetD3D11SwapChainResizedFunc();
    hr = S_OK;
    if( pCallbackSwapChainResized )
        hr = pCallbackSwapChainResized( DXUTGetD3D11Device(), pSwapChain, pBackBufferSurfaceDesc,
                                        GetDXUTState().GetD3D11SwapChainResizedFuncUserContext() );
    GetDXUTState().SetInsideDeviceCallback( false );
    if( !DXUTGetD3D11Device() ) // Handle DXUTShutdown from inside callback
        return E_FAIL;
    if( FAILED( hr ) )
    {
        DXUT_ERR( "DeviceReset callback", hr );
        return ( hr == DXUTERR_MEDIANOTFOUND ) ? DXUTERR_MEDIANOTFOUND : DXUTERR_RESETTINGDEVICEOBJECTS;
    }
    GetDXUTState().SetDeviceObjectsReset( true );

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Resets the 3D environment by:
//      - Calls the device lost callback 
//      - Resets the device
//      - Stores the back buffer description
//      - Sets up the full screen Direct3D cursor if requested
//      - Calls the device reset callback 
//--------------------------------------------------------------------------------------
HRESULT DXUTReset3DEnvironment11()
{
    HRESULT hr;

    GetDXUTState().SetDeviceObjectsReset( false );
    DXUTPause( true, true );

    bool bDeferredDXGIAction = false;
    auto pDeviceSettings = GetDXUTState().GetCurrentDeviceSettings();
    auto pSwapChain = DXUTGetDXGISwapChain();
    assert( pSwapChain );
    _Analysis_assume_( pSwapChain );
    
    DXGI_SWAP_CHAIN_DESC SCDesc;
    if ( FAILED( pSwapChain.GetDesc(&SCDesc)) )
        memset( &SCDesc, 0, sizeof(SCDesc) );

    // Resize backbuffer and target of the swapchain in case they have changed.
    // For windowed mode, use the client rect as the desired size. Unlike D3D9,
    // we can't use 0 for width or height.  Therefore, fill in the values from
    // the window size. For fullscreen mode, the width and height should have
    // already been filled with the desktop resolution, so don't change it.
    if( pDeviceSettings.3d11.sd.Windowed && SCDesc.Windowed )
    {
        RECT rcWnd;
        GetClientRect( DXUTGetHWND(), &rcWnd );
        pDeviceSettings.3d11.sd.BufferDesc.Width = rcWnd.right - rcWnd.left;
        pDeviceSettings.3d11.sd.BufferDesc.Height = rcWnd.bottom - rcWnd.top;
    }

    // If the app wants to switch from windowed to fullscreen or vice versa,
    // call the swapchain's SetFullscreenState
    // mode.
    if( SCDesc.Windowed != pDeviceSettings.3d11.sd.Windowed )
    {
        // Set the fullscreen state
        if( pDeviceSettings.3d11.sd.Windowed )
        {
            V_RETURN( pSwapChain.SetFullscreenState( FALSE, null ) );
            bDeferredDXGIAction = true;
        }
        else
        {
            // Set fullscreen state by setting the display mode to fullscreen, then changing the resolution
            // to the desired value.

            // SetFullscreenState causes a WM_SIZE message to be sent to the window.  The WM_SIZE message calls
            // DXUTCheckForDXGIBufferChange which normally stores the new height and width in 
            // pDeviceSettings.3d11.sd.BufferDesc.  SetDoNotStoreBufferSize tells DXUTCheckForDXGIBufferChange
            // not to store the height and width so that we have the correct values when calling ResizeTarget.

            GetDXUTState().SetDoNotStoreBufferSize( true );
            V_RETURN( pSwapChain.SetFullscreenState( TRUE, null ) );
            GetDXUTState().SetDoNotStoreBufferSize( false );

            V_RETURN( pSwapChain.ResizeTarget( &pDeviceSettings.3d11.sd.BufferDesc ) );
            bDeferredDXGIAction = true;
        }
    }
    else
    {
        if( pDeviceSettings.3d11.sd.BufferDesc.Width == SCDesc.BufferDesc.Width &&
            pDeviceSettings.3d11.sd.BufferDesc.Height == SCDesc.BufferDesc.Height &&
            pDeviceSettings.3d11.sd.BufferDesc.Format != SCDesc.BufferDesc.Format )
        {
            DXUTResizeDXGIBuffers( 0, 0, !pDeviceSettings.3d11.sd.Windowed );
            bDeferredDXGIAction = true;
        }
        else if( pDeviceSettings.3d11.sd.BufferDesc.Width != SCDesc.BufferDesc.Width ||
                 pDeviceSettings.3d11.sd.BufferDesc.Height != SCDesc.BufferDesc.Height )
        {
            V_RETURN( pSwapChain.ResizeTarget( &pDeviceSettings.3d11.sd.BufferDesc ) );
            bDeferredDXGIAction = true;
        }
    }

    // If no deferred DXGI actions are to take place, mark the device as reset.
    // If there is a deferred DXGI action, then the device isn't reset until DXGI sends us a 
    // window message.  Only then can we mark the device as reset.
    if( !bDeferredDXGIAction )
        GetDXUTState().SetDeviceObjectsReset( true );
    DXUTPause( false, false );

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Render the 3D environment by:
//      - Checking if the device is lost and trying to reset it if it is
//      - Get the elapsed time since the last frame
//      - Calling the app's framemove and render callback
//      - Calling Present()
//--------------------------------------------------------------------------------------
void DXUTRender3DEnvironment()
{
    HRESULT hr;

    auto pd3dDevice = DXUTGetD3D11Device();
    if( !pd3dDevice )
        return;

    auto pd3dImmediateContext = DXUTGetD3D11DeviceContext();
    if( !pd3dImmediateContext )
        return;

    auto pSwapChain = DXUTGetDXGISwapChain();
    if( !pSwapChain )
        return;

    if( DXUTIsRenderingPaused() || !DXUTIsActive() || GetDXUTState().GetRenderingOccluded() )
    {
        // Window is minimized/paused/occluded/or not exclusive so yield CPU time to other processes
        Sleep( 50 );
    }

    // Get the app's time, in seconds. Skip rendering if no time elapsed
    double fTime, fAbsTime; float fElapsedTime;
    DXUTGetGlobalTimer().GetTimeValues( &fTime, &fAbsTime, &fElapsedTime );

    // Store the time for the app
    if( GetDXUTState().GetConstantFrameTime() )
    {
        fElapsedTime = GetDXUTState().GetTimePerFrame();
        fTime = DXUTGetTime() + fElapsedTime;
    }

    GetDXUTState().SetTime( fTime );
    GetDXUTState().SetAbsoluteTime( fAbsTime );
    GetDXUTState().SetElapsedTime( fElapsedTime );

    // Update the FPS stats
    DXUTUpdateFrameStats();

    DXUTHandleTimers();

    // Animate the scene by calling the app's frame move callback
    LPDXUTCALLBACKFRAMEMOVE pCallbackFrameMove = GetDXUTState().GetFrameMoveFunc();
    if( pCallbackFrameMove )
    {
        pCallbackFrameMove( fTime, fElapsedTime, GetDXUTState().GetFrameMoveFuncUserContext() );
        pd3dDevice = DXUTGetD3D11Device();
        if( !pd3dDevice ) // Handle DXUTShutdown from inside callback
            return;
    }

    if( !GetDXUTState().GetRenderingPaused() )
    {
        // Render the scene by calling the app's render callback
        LPDXUTCALLBACKD3D11FRAMERENDER pCallbackFrameRender = GetDXUTState().GetD3D11FrameRenderFunc();
        if( pCallbackFrameRender && !GetDXUTState().GetRenderingOccluded() )
        {
            pCallbackFrameRender( pd3dDevice, pd3dImmediateContext, fTime, fElapsedTime,
                                  GetDXUTState().GetD3D11FrameRenderFuncUserContext() );
            
            pd3dDevice = DXUTGetD3D11Device();
            if( !pd3dDevice ) // Handle DXUTShutdown from inside callback
                return;
        }

        version(debug)
        {
            // The back buffer should always match the client rect 
            // if the Direct3D backbuffer covers the entire window
            RECT rcClient;
            GetClientRect( DXUTGetHWND(), &rcClient );
            if( !IsIconic( DXUTGetHWND() ) )
            {
                GetClientRect( DXUTGetHWND(), &rcClient );
                
                assert( DXUTGetDXGIBackBufferSurfaceDesc().Width == (UINT)rcClient.right );
                assert( DXUTGetDXGIBackBufferSurfaceDesc().Height == (UINT)rcClient.bottom );
            }
        }
    }

    if ( GetDXUTState().GetSaveScreenShot() )
    {
        DXUTSnapD3D11Screenshot( GetDXUTState().GetScreenShotName(), false );
    }
    if ( GetDXUTState().GetExitAfterScreenShot() )
    {
        DXUTShutdown();
        return;
    }

    DWORD dwFlags = 0;
    if( GetDXUTState().GetRenderingOccluded() )
        dwFlags = DXGI_PRESENT_TEST;
    else
        dwFlags = GetDXUTState().GetCurrentDeviceSettings().3d11.PresentFlags;
    UINT SyncInterval = GetDXUTState().GetCurrentDeviceSettings().3d11.SyncInterval;

    // Show the frame on the primary surface.
    hr = pSwapChain.Present( SyncInterval, dwFlags );
    if( DXGI_STATUS_OCCLUDED == hr )
    {
        // There is a window covering our entire rendering area.
        // Don't render until we're visible again.
        GetDXUTState().SetRenderingOccluded( true );
    }
    else if( DXGI_ERROR_DEVICE_RESET == hr )
    {
        // If a mode change happened, we must reset the device
        if( FAILED( hr = DXUTReset3DEnvironment11() ) )
        {
            if( DXUTERR_RESETTINGDEVICEOBJECTS == hr ||
                DXUTERR_MEDIANOTFOUND == hr )
            {
                DXUTDisplayErrorMessage( hr );
                DXUTShutdown();
                return;
            }
            else
            {
                // Reset failed, but the device wasn't lost so something bad happened, 
                // so recreate the device to try to recover
                auto pDeviceSettings = GetDXUTState().GetCurrentDeviceSettings();
                if( FAILED( DXUTChangeDevice( pDeviceSettings, false ) ) )
                {
                    DXUTShutdown();
                    return;
                }

                // How to handle display orientation changes in full-screen mode?
            }
        }
    }
    else if( DXGI_ERROR_DEVICE_REMOVED == hr )
    {
        // Use a callback to ask the app if it would like to find a new device.  
        // If no device removed callback is set, then look for a new device
        if( FAILED( DXUTHandleDeviceRemoved() ) )
        {
            // Perhaps get more information from pD3DDevice.GetDeviceRemovedReason()?
            DXUTDisplayErrorMessage( DXUTERR_DEVICEREMOVED );
            DXUTShutdown();
            return;
        }
    }
    else if( SUCCEEDED( hr ) )
    {
        if( GetDXUTState().GetRenderingOccluded() )
        {
            // Now that we're no longer occluded
            // allow us to render again
            GetDXUTState().SetRenderingOccluded( false );
        }
    }

    // Update current frame #
    int nFrame = GetDXUTState().GetCurrentFrameNumber();
    nFrame++;
    GetDXUTState().SetCurrentFrameNumber( nFrame );

    // Check to see if the app should shutdown due to cmdline
    if( GetDXUTState().GetOverrideQuitAfterFrame() != 0 )
    {
        if( nFrame > GetDXUTState().GetOverrideQuitAfterFrame() )
            DXUTShutdown();
    }

    return;
}


//--------------------------------------------------------------------------------------
// Cleans up the 3D environment by:
//      - Calls the device lost callback 
//      - Calls the device destroyed callback 
//      - Releases the D3D device
//--------------------------------------------------------------------------------------
void DXUTCleanup3DEnvironment(bool bReleaseSettings )
{
    auto pd3dDevice = DXUTGetD3D11Device();

    if( pd3dDevice )
    {
        if (GetDXUTState().GetD3D11RasterizerState()) 
            GetDXUTState().GetD3D11RasterizerState().Release();

        // Call the app's SwapChain lost callback
        GetDXUTState().SetInsideDeviceCallback( true );
        if( GetDXUTState().GetDeviceObjectsReset() )
        {
            LPDXUTCALLBACKD3D11SWAPCHAINRELEASING pCallbackSwapChainReleasing =
                GetDXUTState().GetD3D11SwapChainReleasingFunc();
            if( pCallbackSwapChainReleasing )
                pCallbackSwapChainReleasing( GetDXUTState().GetD3D11SwapChainReleasingFuncUserContext() );
            GetDXUTState().SetDeviceObjectsReset( false );
        }

        // Release our old depth stencil texture and view 
        auto pDS = GetDXUTState().GetD3D11DepthStencil();
        SAFE_RELEASE( pDS );
        GetDXUTState().SetD3D11DepthStencil( null );
        auto pDSV = GetDXUTState().GetD3D11DepthStencilView();
        SAFE_RELEASE( pDSV );
        GetDXUTState().SetD3D11DepthStencilView( null );

        // Cleanup the render target view
        auto pRTV = GetDXUTState().GetD3D11RenderTargetView();
        SAFE_RELEASE( pRTV );
        GetDXUTState().SetD3D11RenderTargetView( null );

        // Call the app's device destroyed callback
        if( GetDXUTState().GetDeviceObjectsCreated() )
        {
            auto pCallbackDeviceDestroyed = GetDXUTState().GetD3D11DeviceDestroyedFunc();
            if( pCallbackDeviceDestroyed )
                pCallbackDeviceDestroyed( GetDXUTState().GetD3D11DeviceDestroyedFuncUserContext() );
            GetDXUTState().SetDeviceObjectsCreated( false );
        }

        GetDXUTState().SetInsideDeviceCallback( false );

        // Release the swap chain
        GetDXUTState().SetReleasingSwapChain( true );
        auto pSwapChain = DXUTGetDXGISwapChain();
        if( pSwapChain )
        {
            pSwapChain.SetFullscreenState( FALSE, 0 );
        }
        SAFE_RELEASE( pSwapChain );
        GetDXUTState().SetDXGISwapChain( null );
        GetDXUTState().SetReleasingSwapChain( false );

        // Release the outputs.
        auto ppOutputArray = GetDXUTState().GetDXGIOutputArray();
        UINT OutputCount = GetDXUTState().GetDXGIOutputArraySize();
        for( UINT o = 0; o < OutputCount; ++o )
        SAFE_RELEASE( ppOutputArray[o] );
        delete[] ppOutputArray;
        GetDXUTState().SetDXGIOutputArray( null );
        GetDXUTState().SetDXGIOutputArraySize( 0 );

        // Release the D3D adapter.
        auto pAdapter = GetDXUTState().GetDXGIAdapter();
        SAFE_RELEASE( pAdapter );
        GetDXUTState().SetDXGIAdapter( null );

        // Call ClearState to avoid tons of messy debug spew telling us that we're deleting bound objects
        auto pImmediateContext = DXUTGetD3D11DeviceContext();
        assert( pImmediateContext );
        pImmediateContext.ClearState();
        pImmediateContext.Flush();

        // Release the D3D11 immediate context (if it exists) because it has a extra ref count on it
        SAFE_RELEASE( pImmediateContext );
        GetDXUTState().SetD3D11DeviceContext( null );

        auto pImmediateContext1 = DXUTGetD3D11DeviceContext1();
        SAFE_RELEASE( pImmediateContext1 );
        GetDXUTState().SetD3D11DeviceContext1( null );

        auto pImmediateContext2 = DXUTGetD3D11DeviceContext2();
        SAFE_RELEASE(pImmediateContext2);
        GetDXUTState().SetD3D11DeviceContext2(null);

static if(USE_DIRECT3D11_3)
{
        auto pImmediateContext3 = DXUTGetD3D11DeviceContext3();
        SAFE_RELEASE(pImmediateContext3);
        GetDXUTState().SetD3D11DeviceContext3(null);
}

static if(USE_DIRECT3D11_4)
{
        auto pImmediateContext4 = DXUTGetD3D11DeviceContext4();
        SAFE_RELEASE(pImmediateContext4);
        GetDXUTState().SetD3D11DeviceContext4(null);
}

        // Report live objects
        if ( pd3dDevice )
        {
#ifndef NDEBUG
            ID3D11Debug * d3dDebug = null;
            if( SUCCEEDED( pd3dDevice.QueryInterface( IID_PPV_ARGS(&d3dDebug) ) ) )
            {
                d3dDebug.ReportLiveDeviceObjects( D3D11_RLDO_SUMMARY | D3D11_RLDO_DETAIL );
                d3dDebug.Release();
            }
#endif

            auto pd3dDevice1 = DXUTGetD3D11Device1();
            SAFE_RELEASE( pd3dDevice1 );
            GetDXUTState().SetD3D11Device1(null);

            auto pd3dDevice2 = DXUTGetD3D11Device2();
            SAFE_RELEASE(pd3dDevice2);
            GetDXUTState().SetD3D11Device2(null);

static if(USE_DIRECT3D11_3)
{
    auto pd3dDevice3 = DXUTGetD3D11Device3();
    SAFE_RELEASE(pd3dDevice3);
    GetDXUTState().SetD3D11Device3(null);
}

static if(USE_DIRECT3D11_4)
{
    auto pd3dDevice4 = DXUTGetD3D11Device4();
    SAFE_RELEASE(pd3dDevice4);
    GetDXUTState().SetD3D11Device4(null);
}

            // Release the D3D device and in debug configs, displays a message box if there 
            // are unrelease objects.
            UINT references = pd3dDevice.Release();
            if( references > 0 )
            {
                DXUTDisplayErrorMessage( DXUTERR_NONZEROREFCOUNT );
                DXUT_ERR( "DXUTCleanup3DEnvironment", DXUTERR_NONZEROREFCOUNT );
            }
        }
        GetDXUTState().SetD3D11Device( null );

#ifndef NDEBUG
        {
            IDXGIDebug* dxgiDebug = null;
            if ( SUCCEEDED( DXUT_Dynamic_DXGIGetDebugInterface( IID_IDXGIDebug, reinterpret_cast<void**>( &dxgiDebug ) ) ) )
            {
                dxgiDebug.ReportLiveObjects( DXGI_DEBUG_ALL, DXGI_DEBUG_RLO_ALL );
                dxgiDebug.Release();
            }
        }
#endif

        if( bReleaseSettings )
        {
            auto pOldDeviceSettings = GetDXUTState().GetCurrentDeviceSettings();
            SAFE_DELETE(pOldDeviceSettings);
            GetDXUTState().SetCurrentDeviceSettings( null );
        }

        auto pBackBufferSurfaceDesc = GetDXUTState().GetBackBufferSurfaceDescDXGI();
        ZeroMemory( pBackBufferSurfaceDesc, sizeof( DXGI_SURFACE_DESC ) );

        GetDXUTState().SetDeviceCreated( false );
    }
}


//--------------------------------------------------------------------------------------
// Low level keyboard hook to disable Windows key to prevent accidental task switching.  
//--------------------------------------------------------------------------------------
LRESULT CALLBACK DXUTLowLevelKeyboardProc( int nCode, WPARAM wParam, LPARAM lParam )
{
    if( nCode < 0 || nCode != HC_ACTION )  // do not process message 
        return CallNextHookEx( GetDXUTState().GetKeyboardHook(), nCode, wParam, lParam );

    bool bEatKeystroke = false;
    auto p = reinterpret_cast<KBDLLHOOKSTRUCT*>( lParam );
    switch( wParam )
    {
        case WM_KEYDOWN:
        case WM_KEYUP:
            {
                bEatKeystroke = ( !GetDXUTState().GetAllowShortcutKeys() &&
                                  ( p.vkCode == VK_LWIN || p.vkCode == VK_RWIN ) );
                break;
            }
    }

    if( bEatKeystroke )
        return 1;
    else
        return CallNextHookEx( GetDXUTState().GetKeyboardHook(), nCode, wParam, lParam );
}


//--------------------------------------------------------------------------------------
// Controls how DXUT behaves when fullscreen and windowed mode with regard to 
// shortcut keys (Windows keys, StickyKeys shortcut, ToggleKeys shortcut, FilterKeys shortcut) 
//--------------------------------------------------------------------------------------
void DXUTSetShortcutKeySettings( bool bAllowWhenFullscreen, bool bAllowWhenWindowed )
{
    GetDXUTState().SetAllowShortcutKeysWhenWindowed( bAllowWhenWindowed );
    GetDXUTState().SetAllowShortcutKeysWhenFullscreen( bAllowWhenFullscreen );

    // DXUTInit() records initial accessibility states so don't change them until then
    if( GetDXUTState().GetDXUTInited() )
    {
        if( DXUTIsWindowed() )
            DXUTAllowShortcutKeys( GetDXUTState().GetAllowShortcutKeysWhenWindowed() );
        else
            DXUTAllowShortcutKeys( GetDXUTState().GetAllowShortcutKeysWhenFullscreen() );
    }
}


//--------------------------------------------------------------------------------------
// Enables/disables Windows keys, and disables or restores the StickyKeys/ToggleKeys/FilterKeys 
// shortcut to help prevent accidental task switching
//--------------------------------------------------------------------------------------
void DXUTAllowShortcutKeys(bool bAllowKeys )
{
    GetDXUTState().SetAllowShortcutKeys( bAllowKeys );

    if( bAllowKeys )
    {
        // Restore StickyKeys/etc to original state and enable Windows key      
        STICKYKEYS sk = GetDXUTState().GetStartupStickyKeys();
        TOGGLEKEYS tk = GetDXUTState().GetStartupToggleKeys();
        FILTERKEYS fk = GetDXUTState().GetStartupFilterKeys();

        SystemParametersInfo( SPI_SETSTICKYKEYS, sizeof( STICKYKEYS ), &sk, 0 );
        SystemParametersInfo( SPI_SETTOGGLEKEYS, sizeof( TOGGLEKEYS ), &tk, 0 );
        SystemParametersInfo( SPI_SETFILTERKEYS, sizeof( FILTERKEYS ), &fk, 0 );

        // Remove the keyboard hoook when it isn't needed to prevent any slow down of other apps
        if( GetDXUTState().GetKeyboardHook() )
        {
            UnhookWindowsHookEx( GetDXUTState().GetKeyboardHook() );
            GetDXUTState().SetKeyboardHook( null );
        }
    }
    else
    {
        // Set low level keyboard hook if haven't already
        if( !GetDXUTState().GetKeyboardHook() )
        {
            // Set the low-level hook procedure.
            HHOOK hKeyboardHook = SetWindowsHookEx( WH_KEYBOARD_LL, DXUTLowLevelKeyboardProc,
                                                    GetModuleHandle( null ), 0 );
            GetDXUTState().SetKeyboardHook( hKeyboardHook );
        }

        // Disable StickyKeys/etc shortcuts but if the accessibility feature is on, 
        // then leave the settings alone as its probably being usefully used

        STICKYKEYS skOff = GetDXUTState().GetStartupStickyKeys();
        if( ( skOff.dwFlags & SKF_STICKYKEYSON ) == 0 )
        {
            // Disable the hotkey and the confirmation
            skOff.dwFlags &= ~SKF_HOTKEYACTIVE;
            skOff.dwFlags &= ~SKF_CONFIRMHOTKEY;

            SystemParametersInfo( SPI_SETSTICKYKEYS, sizeof( STICKYKEYS ), &skOff, 0 );
        }

        TOGGLEKEYS tkOff = GetDXUTState().GetStartupToggleKeys();
        if( ( tkOff.dwFlags & TKF_TOGGLEKEYSON ) == 0 )
        {
            // Disable the hotkey and the confirmation
            tkOff.dwFlags &= ~TKF_HOTKEYACTIVE;
            tkOff.dwFlags &= ~TKF_CONFIRMHOTKEY;

            SystemParametersInfo( SPI_SETTOGGLEKEYS, sizeof( TOGGLEKEYS ), &tkOff, 0 );
        }

        FILTERKEYS fkOff = GetDXUTState().GetStartupFilterKeys();
        if( ( fkOff.dwFlags & FKF_FILTERKEYSON ) == 0 )
        {
            // Disable the hotkey and the confirmation
            fkOff.dwFlags &= ~FKF_HOTKEYACTIVE;
            fkOff.dwFlags &= ~FKF_CONFIRMHOTKEY;

            SystemParametersInfo( SPI_SETFILTERKEYS, sizeof( FILTERKEYS ), &fkOff, 0 );
        }
    }
}


//--------------------------------------------------------------------------------------
// Pauses time or rendering.  Keeps a ref count so pausing can be layered
//--------------------------------------------------------------------------------------
_Use_decl_annotations_
void DXUTPause( bool bPauseTime, bool bPauseRendering )
{
    int nPauseTimeCount = GetDXUTState().GetPauseTimeCount();
    if( bPauseTime ) nPauseTimeCount++;
    else
        nPauseTimeCount--;
    if( nPauseTimeCount < 0 ) nPauseTimeCount = 0;
    GetDXUTState().SetPauseTimeCount( nPauseTimeCount );

    int nPauseRenderingCount = GetDXUTState().GetPauseRenderingCount();
    if( bPauseRendering ) nPauseRenderingCount++;
    else
        nPauseRenderingCount--;
    if( nPauseRenderingCount < 0 ) nPauseRenderingCount = 0;
    GetDXUTState().SetPauseRenderingCount( nPauseRenderingCount );

    if( nPauseTimeCount > 0 )
    {
        // Stop the scene from animating
        DXUTGetGlobalTimer().Stop();
    }
    else
    {
        // Restart the timer
        DXUTGetGlobalTimer().Start();
    }

    GetDXUTState().SetRenderingPaused( nPauseRenderingCount > 0 );
    GetDXUTState().SetTimePaused( nPauseTimeCount > 0 );
}


//--------------------------------------------------------------------------------------
// Starts a user defined timer callback
//--------------------------------------------------------------------------------------
_Use_decl_annotations_
HRESULT DXUTSetTimer( LPDXUTCALLBACKTIMER pCallbackTimer, float fTimeoutInSecs, UINT* pnIDEvent,
                             void* pCallbackUserContext )
{
    if( !pCallbackTimer )
        return DXUT_ERR_MSGBOX( "DXUTSetTimer", E_INVALIDARG );

    DXUT_TIMER DXUTTimer;
    DXUTTimer.pCallbackTimer = pCallbackTimer;
    DXUTTimer.pCallbackUserContext = pCallbackUserContext;
    DXUTTimer.fTimeoutInSecs = fTimeoutInSecs;
    DXUTTimer.fCountdown = fTimeoutInSecs;
    DXUTTimer.bEnabled = true;
    DXUTTimer.nID = GetDXUTState().GetTimerLastID() + 1;
    GetDXUTState().SetTimerLastID( DXUTTimer.nID );

    auto pTimerList = GetDXUTState().GetTimerList();
    if( !pTimerList )
    {
        pTimerList = new (std::nothrow) std::vector<DXUT_TIMER>;
        if( !pTimerList )
            return E_OUTOFMEMORY;
        GetDXUTState().SetTimerList( pTimerList );
    }

    pTimerList.push_back( DXUTTimer );

    if( pnIDEvent )
        *pnIDEvent = DXUTTimer.nID;

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Stops a user defined timer callback
//--------------------------------------------------------------------------------------
HRESULT DXUTKillTimer(UINT nIDEvent )
{
    auto pTimerList = GetDXUTState().GetTimerList();
    if( !pTimerList )
        return S_FALSE;

    bool bFound = false;

    for( auto it = pTimerList.begin(); it != pTimerList.end(); ++it )
    {
        DXUT_TIMER DXUTTimer = *it;
        if( DXUTTimer.nID == nIDEvent )
        {
            DXUTTimer.bEnabled = false;
            *it = DXUTTimer;
            bFound = true;
            break;
        }
    }

    if( !bFound )
        return DXUT_ERR_MSGBOX( "DXUTKillTimer", E_INVALIDARG );

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Internal helper function to handle calling the user defined timer callbacks
//--------------------------------------------------------------------------------------
void DXUTHandleTimers()
{
    float fElapsedTime = DXUTGetElapsedTime();

    auto pTimerList = GetDXUTState().GetTimerList();
    if( !pTimerList )
        return;

    // Walk through the list of timer callbacks
    for( auto it = pTimerList.begin(); it != pTimerList.end(); ++it )
    {
        DXUT_TIMER DXUTTimer = *it;
        if( DXUTTimer.bEnabled )
        {
            DXUTTimer.fCountdown -= fElapsedTime;

            // Call the callback if count down expired
            if( DXUTTimer.fCountdown < 0 )
            {
                DXUTTimer.pCallbackTimer( DXUTTimer.nID, DXUTTimer.pCallbackUserContext );
                // The callback my have changed the timer.
                DXUTTimer = *it;
                DXUTTimer.fCountdown = DXUTTimer.fTimeoutInSecs;
            }
            *it = DXUTTimer;
        }
    }
}


//--------------------------------------------------------------------------------------
// Display an custom error msg box 
//--------------------------------------------------------------------------------------
void DXUTDisplayErrorMessage(HRESULT hr )
{
    WCHAR strBuffer[512];

    int nExitCode;
    bool bFound = true;
    switch( hr )
    {
        case DXUTERR_NODIRECT3D:
        {
            nExitCode = 2;
            wcscpy_s( strBuffer, ARRAYSIZE(strBuffer), "Could not initialize Direct3D 11. " );
            break;
        }
        case DXUTERR_NOCOMPATIBLEDEVICES:    
            nExitCode = 3; 
            if( GetSystemMetrics(SM_REMOTESESSION) != 0 )
                wcscpy_s( strBuffer, ARRAYSIZE(strBuffer), "Direct3D does not work over a remote session." ); 
            else
                wcscpy_s( strBuffer, ARRAYSIZE(strBuffer), "Could not find any compatible Direct3D devices." ); 
            break;
        case DXUTERR_MEDIANOTFOUND:          nExitCode = 4; wcscpy_s( strBuffer, ARRAYSIZE(strBuffer), "Could not find required media." ); break;
        case DXUTERR_NONZEROREFCOUNT:        nExitCode = 5; wcscpy_s( strBuffer, ARRAYSIZE(strBuffer), "The Direct3D device has a non-zero reference count, meaning some objects were not released." ); break;
        case DXUTERR_CREATINGDEVICE:         nExitCode = 6; wcscpy_s( strBuffer, ARRAYSIZE(strBuffer), "Failed creating the Direct3D device." ); break;
        case DXUTERR_RESETTINGDEVICE:        nExitCode = 7; wcscpy_s( strBuffer, ARRAYSIZE(strBuffer), "Failed resetting the Direct3D device." ); break;
        case DXUTERR_CREATINGDEVICEOBJECTS:  nExitCode = 8; wcscpy_s( strBuffer, ARRAYSIZE(strBuffer), "An error occurred in the device create callback function." ); break;
        case DXUTERR_RESETTINGDEVICEOBJECTS: nExitCode = 9; wcscpy_s( strBuffer, ARRAYSIZE(strBuffer), "An error occurred in the device reset callback function." ); break;
        // nExitCode 10 means the app exited using a REF device 
        case DXUTERR_DEVICEREMOVED:          nExitCode = 11; wcscpy_s( strBuffer, ARRAYSIZE(strBuffer), "The Direct3D device was removed."  ); break;
        default: bFound = false; nExitCode = 1; break; // nExitCode 1 means the API was incorrectly called

    }   

    GetDXUTState().SetExitCode(nExitCode);

    bool bShowMsgBoxOnError = GetDXUTState().GetShowMsgBoxOnError();
    if( bFound && bShowMsgBoxOnError )
    {
        if( DXUTGetWindowTitle()[0] == 0 )
            MessageBox( DXUTGetHWND(), strBuffer, "DXUT Application", MB_ICONERROR | MB_OK );
        else
            MessageBox( DXUTGetHWND(), strBuffer, DXUTGetWindowTitle(), MB_ICONERROR | MB_OK );
    }
}


//--------------------------------------------------------------------------------------
// Internal function to map MK_* to an array index
//--------------------------------------------------------------------------------------
int DXUTMapButtonToArrayIndex(BYTE vButton )
{
    switch( vButton )
    {
        case MK_LBUTTON:
            return 0;
        case VK_MBUTTON:
        case MK_MBUTTON:
            return 1;
        case MK_RBUTTON:
            return 2;
        case VK_XBUTTON1:
        case MK_XBUTTON1:
            return 3;
        case VK_XBUTTON2:
        case MK_XBUTTON2:
            return 4;
    }

    return 0;
}


//--------------------------------------------------------------------------------------
// Toggle between full screen and windowed
//--------------------------------------------------------------------------------------
HRESULT DXUTToggleFullScreen()
{
    auto deviceSettings = DXUTGetDeviceSettings();
    if ( deviceSettings.d3d11.DriverType == D3D_DRIVER_TYPE_WARP )
    {
        // WARP driver type doesn't support fullscreen
        return S_FALSE;
    }

    auto orginalDeviceSettings = DXUTGetDeviceSettings();
    
    deviceSettings.d3d11.sd.Windowed = !deviceSettings.d3d11.sd.Windowed;

    HRESULT hr;
    if (!deviceSettings.d3d11.sd.Windowed)
    {
        DXGI_MODE_DESC adapterDesktopDisplayMode;
        hr = DXUTGetD3D11AdapterDisplayMode( deviceSettings.d3d11.AdapterOrdinal, 0, &adapterDesktopDisplayMode );
        if ( FAILED(hr) )
        {
            static const DXGI_MODE_DESC s_adapterDesktopDisplayMode =
            {
                800, 600, { 0, 0 }, DXGI_FORMAT_R8G8B8A8_UNORM_SRGB
            };
            memcpy(&adapterDesktopDisplayMode, &s_adapterDesktopDisplayMode, sizeof(DXGI_MODE_DESC));
        }
           
        deviceSettings.d3d11.sd.BufferDesc = adapterDesktopDisplayMode;
    }
    else
    {
        RECT r = DXUTGetWindowClientRectAtModeChange();
        deviceSettings.d3d11.sd.BufferDesc.Height = r.bottom;
        deviceSettings.d3d11.sd.BufferDesc.Width = r.right;
    }

    hr = DXUTChangeDevice( &deviceSettings, false );

    // If hr == E_ABORT, this means the app rejected the device settings in the ModifySettingsCallback so nothing changed
    if( FAILED( hr ) && ( hr != E_ABORT ) )
    {
        // Failed creating device, try to switch back.
        HRESULT hr2 = DXUTChangeDevice( &orginalDeviceSettings, false );
        if( FAILED( hr2 ) )
        {
            // If this failed, then shutdown
            DXUTShutdown();
        }
    }

    return hr;
}


//--------------------------------------------------------------------------------------
// Toggle between HAL/REF and WARP
//--------------------------------------------------------------------------------------
HRESULT DXUTToggleWARP ()
{
    auto deviceSettings = DXUTGetDeviceSettings();

    if ( deviceSettings.d3d11.DriverType == D3D_DRIVER_TYPE_HARDWARE || deviceSettings.d3d11.DriverType == D3D_DRIVER_TYPE_REFERENCE )
    {
        if ( !deviceSettings.d3d11.sd.Windowed )
        {
            // WARP driver type doesn't support fullscreen
            return S_FALSE;
        }

        deviceSettings.d3d11.DriverType = D3D_DRIVER_TYPE_WARP;
    }
    else if ( deviceSettings.d3d11.DriverType == D3D_DRIVER_TYPE_WARP )
    {
        deviceSettings.d3d11.DriverType = D3D_DRIVER_TYPE_HARDWARE;
    }
    
    HRESULT hr = DXUTSnapDeviceSettingsToEnumDevice(&deviceSettings, false);
    if( SUCCEEDED( hr ) )
    {
        DXUTDeviceSettings orginalDeviceSettings = DXUTGetDeviceSettings();

        // Create a Direct3D device using the new device settings.  
        // If there is an existing device, then it will either reset or recreate the scene.
        hr = DXUTChangeDevice( &deviceSettings, false );

        // If hr == E_ABORT, this means the app rejected the device settings in the ModifySettingsCallback so nothing changed
        if( FAILED( hr ) && ( hr != E_ABORT ) )
        {
            // Failed creating device, try to switch back.
            HRESULT hr2 = DXUTChangeDevice( &orginalDeviceSettings, false );
            if( FAILED( hr2 ) )
            {
                // If this failed, then shutdown
                DXUTShutdown();
            }
        }
    }

    return hr;
}


//--------------------------------------------------------------------------------------
// Toggle between HAL/WARP and REF
//--------------------------------------------------------------------------------------
HRESULT DXUTToggleREF()
{
    auto deviceSettings = DXUTGetDeviceSettings();

    if ( deviceSettings.d3d11.DriverType == D3D_DRIVER_TYPE_HARDWARE )
    {
        deviceSettings.d3d11.DriverType = D3D_DRIVER_TYPE_REFERENCE;
    }
    else if ( deviceSettings.d3d11.DriverType == D3D_DRIVER_TYPE_REFERENCE )
    {
        deviceSettings.d3d11.DriverType = D3D_DRIVER_TYPE_HARDWARE;
    }
    else if ( deviceSettings.d3d11.DriverType == D3D_DRIVER_TYPE_WARP )
    {
        if ( !deviceSettings.d3d11.sd.Windowed )
        {
            // WARP driver type doesn't support fullscreen
            return S_FALSE;
        }

        deviceSettings.d3d11.DriverType = D3D_DRIVER_TYPE_REFERENCE;
    }

    HRESULT hr = DXUTSnapDeviceSettingsToEnumDevice(&deviceSettings, false);
    if( SUCCEEDED( hr ) )
    {
        auto orginalDeviceSettings = DXUTGetDeviceSettings();

        // Create a Direct3D device using the new device settings.  
        // If there is an existing device, then it will either reset or recreate the scene.
        hr = DXUTChangeDevice( &deviceSettings, false );

        // If hr == E_ABORT, this means the app rejected the device settings in the ModifySettingsCallback so nothing changed
        if( FAILED( hr ) && ( hr != E_ABORT ) )
        {
            // Failed creating device, try to switch back.
            HRESULT hr2 = DXUTChangeDevice( &orginalDeviceSettings, false );
            if( FAILED( hr2 ) )
            {
                // If this failed, then shutdown
                DXUTShutdown();
            }
        }
    }

    return hr;
}

//--------------------------------------------------------------------------------------
// Checks to see if DXGI has switched us out of fullscreen or windowed mode
//--------------------------------------------------------------------------------------
void DXUTCheckForDXGIFullScreenSwitch()
{
    auto pDeviceSettings = GetDXUTState().GetCurrentDeviceSettings();
    auto pSwapChain = DXUTGetDXGISwapChain();
    assert( pSwapChain );
    _Analysis_assume_( pSwapChain );
    DXGI_SWAP_CHAIN_DESC SCDesc;
    if ( FAILED(pSwapChain.GetDesc(&SCDesc)) )
        memset( &SCDesc, 0, sizeof(SCDesc) );

    BOOL bIsWindowed = ( BOOL )DXUTIsWindowed();
    if( bIsWindowed != SCDesc.Windowed )
    {
        pDeviceSettings.3d11.sd.Windowed = SCDesc.Windowed;

        auto deviceSettings = DXUTGetDeviceSettings();

        if( bIsWindowed )
        {
            GetDXUTState().SetWindowBackBufferWidthAtModeChange( deviceSettings.d3d11.sd.BufferDesc.Width );
            GetDXUTState().SetWindowBackBufferHeightAtModeChange( deviceSettings.d3d11.sd.BufferDesc.Height );
        }
        else
        {
            GetDXUTState().SetFullScreenBackBufferWidthAtModeChange( deviceSettings.d3d11.sd.BufferDesc.Width );
            GetDXUTState().SetFullScreenBackBufferHeightAtModeChange( deviceSettings.d3d11.sd.BufferDesc.Height );
        }
    }
}

_Use_decl_annotations_
void DXUTResizeDXGIBuffers( UINT Width, UINT Height, BOOL bFullScreen )
{
    HRESULT hr = S_OK;
    RECT rcCurrentClient;
    GetClientRect( DXUTGetHWND(), &rcCurrentClient );

    auto pDevSettings = GetDXUTState().GetCurrentDeviceSettings();
    assert( pDevSettings );
    _Analysis_assume_( pDevSettings );

    auto pSwapChain = DXUTGetDXGISwapChain();

    auto pd3dDevice = DXUTGetD3D11Device();
    assert( pd3dDevice );
    _Analysis_assume_( pd3dDevice );

    auto pd3dImmediateContext = DXUTGetD3D11DeviceContext();
    assert( pd3dImmediateContext );
    _Analysis_assume_( pd3dImmediateContext );

    // Determine if we're fullscreen
    pDevSettings.3d11.sd.Windowed = !bFullScreen;

    // Call releasing
    GetDXUTState().SetInsideDeviceCallback( true );
    LPDXUTCALLBACKD3D11SWAPCHAINRELEASING pCallbackSwapChainReleasing = GetDXUTState().GetD3D11SwapChainReleasingFunc
        ();
    if( pCallbackSwapChainReleasing )
        pCallbackSwapChainReleasing( GetDXUTState().GetD3D11SwapChainResizedFuncUserContext() );
    GetDXUTState().SetInsideDeviceCallback( false );

    // Release our old depth stencil texture and view 
    auto pDS = GetDXUTState().GetD3D11DepthStencil();
    SAFE_RELEASE( pDS );
    GetDXUTState().SetD3D11DepthStencil( null );
    auto pDSV = GetDXUTState().GetD3D11DepthStencilView();
    SAFE_RELEASE( pDSV );
    GetDXUTState().SetD3D11DepthStencilView( null );

    // Release our old render target view
    auto pRTV = GetDXUTState().GetD3D11RenderTargetView();
    SAFE_RELEASE( pRTV );
    GetDXUTState().SetD3D11RenderTargetView( null );

    // Alternate between 0 and DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH when resizing buffers.
    // When in windowed mode, we want 0 since this allows the app to change to the desktop
    // resolution from windowed mode during alt+enter.  However, in fullscreen mode, we want
    // the ability to change display modes from the Device Settings dialog.  Therefore, we
    // want to set the DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH flag.
    UINT Flags = 0;
    if( bFullScreen )
        Flags = DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH;

    // ResizeBuffers
    V( pSwapChain.ResizeBuffers( pDevSettings.3d11.sd.BufferCount,
                                  Width,
                                  Height,
                                  pDevSettings.3d11.sd.BufferDesc.Format,
                                  Flags ) );

    if( !GetDXUTState().GetDoNotStoreBufferSize() )
    {
        pDevSettings.3d11.sd.BufferDesc.Width = ( UINT )rcCurrentClient.right;
        pDevSettings.3d11.sd.BufferDesc.Height = ( UINT )rcCurrentClient.bottom;
    }

    // Save off backbuffer desc
    DXUTUpdateBackBufferDesc();

    // Update the device stats text
    DXUTUpdateStaticFrameStats();

    // Setup the render target view and viewport
    hr = DXUTCreateD3D11Views( pd3dDevice, pd3dImmediateContext, pDevSettings );
    if( FAILED( hr ) )
    {
        DXUT_ERR( "DXUTCreateD3D11Views", hr );
        return;
    }

    // Setup cursor based on current settings (window/fullscreen mode, show cursor state, clip cursor state)
    DXUTSetupCursor();

    // Call the app's SwapChain reset callback
    GetDXUTState().SetInsideDeviceCallback( true );
    auto pBackBufferSurfaceDesc = DXUTGetDXGIBackBufferSurfaceDesc();
    LPDXUTCALLBACKD3D11SWAPCHAINRESIZED pCallbackSwapChainResized = GetDXUTState().GetD3D11SwapChainResizedFunc();
    hr = S_OK;
    if( pCallbackSwapChainResized )
        hr = pCallbackSwapChainResized( pd3dDevice, pSwapChain, pBackBufferSurfaceDesc,
                                        GetDXUTState().GetD3D11SwapChainResizedFuncUserContext() );
    GetDXUTState().SetInsideDeviceCallback( false );
    if( FAILED( hr ) )
    {
        // If callback failed, cleanup
        DXUT_ERR( "DeviceResetCallback", hr );
        if( hr != DXUTERR_MEDIANOTFOUND )
            hr = DXUTERR_RESETTINGDEVICEOBJECTS;

        GetDXUTState().SetInsideDeviceCallback( true );
        pCallbackSwapChainReleasing =
            GetDXUTState().GetD3D11SwapChainReleasingFunc();
        if( pCallbackSwapChainReleasing )
            pCallbackSwapChainReleasing( GetDXUTState().GetD3D11SwapChainResizedFuncUserContext() );
        GetDXUTState().SetInsideDeviceCallback( false );
        DXUTPause( false, false );
        PostQuitMessage( 0 );
    }
    else
    {
        GetDXUTState().SetDeviceObjectsReset( true );
        DXUTPause( false, false );
    }
}

//--------------------------------------------------------------------------------------
// Checks if DXGI buffers need to change
//--------------------------------------------------------------------------------------
void DXUTCheckForDXGIBufferChange()
{
    if(DXUTGetDXGISwapChain() && !GetDXUTState().GetReleasingSwapChain() )
    {
        //DXUTgetdxgi
        auto pSwapChain = DXUTGetDXGISwapChain();
        assert(pSwapChain);
        _Analysis_assume_(pSwapChain);

// workaround for SAL bug in DXGI header
#pragma warning(push)
#pragma warning( disable:4616 6309 6387 )
        // Determine if we're fullscreen
        BOOL bFullScreen;
        if ( FAILED(pSwapChain.GetFullscreenState(&bFullScreen, null)) )
            bFullScreen = FALSE;
#pragma warning(pop)

        DXUTResizeDXGIBuffers( 0, 0, bFullScreen );

        ShowWindow( DXUTGetHWND(), SW_SHOW );
    }
}

//--------------------------------------------------------------------------------------
// Checks if the window client rect has changed and if it has, then reset the device
//--------------------------------------------------------------------------------------
void DXUTCheckForWindowSizeChange()
{
    // Skip the check for various reasons
          
    if( GetDXUTState().GetIgnoreSizeChange() || !GetDXUTState().GetDeviceCreated() )
        return;

    DXUTCheckForDXGIBufferChange();
}


//--------------------------------------------------------------------------------------
// Checks to see if the HWND changed monitors, and if it did it creates a device 
// from the monitor's adapter and recreates the scene.
//--------------------------------------------------------------------------------------
void DXUTCheckForWindowChangingMonitors()
{
    // Skip this check for various reasons
    if( !GetDXUTState().GetAutoChangeAdapter() ||
        GetDXUTState().GetIgnoreSizeChange() || !GetDXUTState().GetDeviceCreated() || !DXUTIsWindowed() )
        return;

    HRESULT hr;
    HMONITOR hWindowMonitor = DXUTMonitorFromWindow( DXUTGetHWND(), MONITOR_DEFAULTTOPRIMARY );
    HMONITOR hAdapterMonitor = GetDXUTState().GetAdapterMonitor();
    if( hWindowMonitor != hAdapterMonitor )
    {
        UINT newOrdinal;
        if( SUCCEEDED( DXUTGetAdapterOrdinalFromMonitor( hWindowMonitor, &newOrdinal ) ) )
        {
            // Find the closest valid device settings with the new ordinal
            auto deviceSettings = DXUTGetDeviceSettings();
            deviceSettings.d3d11.AdapterOrdinal = newOrdinal;
            UINT newOutput;
            if( SUCCEEDED( DXUTGetOutputOrdinalFromMonitor( hWindowMonitor, &newOutput ) ) )
                deviceSettings.d3d11.Output = newOutput;

            hr = DXUTSnapDeviceSettingsToEnumDevice( &deviceSettings, false );
            if( SUCCEEDED( hr ) )
            {
                // Create a Direct3D device using the new device settings.  
                // If there is an existing device, then it will either reset or recreate the scene.
                hr = DXUTChangeDevice( &deviceSettings, false );

                // If hr == E_ABORT, this means the app rejected the device settings in the ModifySettingsCallback
                if( hr == E_ABORT )
                {
                    // so nothing changed and keep from attempting to switch adapters next time
                    GetDXUTState().SetAutoChangeAdapter( false );
                }
                else if( FAILED( hr ) )
                {
                    DXUTShutdown();
                    DXUTPause( false, false );
                    return;
                }
            }
        }
    }
}


//--------------------------------------------------------------------------------------
// Returns the HMONITOR attached to an adapter/output
//--------------------------------------------------------------------------------------
HMONITOR DXUTGetMonitorFromAdapter(DXUTDeviceSettings* pDeviceSettings )
{
    auto pD3DEnum = DXUTGetD3D11Enumeration();
    assert( pD3DEnum );
    _Analysis_assume_( pD3DEnum );
    auto pOutputInfo = pD3DEnum.GetOutputInfo( pDeviceSettings.3d11.AdapterOrdinal,
                                                pDeviceSettings.3d11.Output );
    if( !pOutputInfo )
        return 0;
    return DXUTMonitorFromRect( &pOutputInfo.esc.DesktopCoordinates, MONITOR_DEFAULTTONEAREST );
}


//--------------------------------------------------------------------------------------
// Look for an adapter ordinal that is tied to a HMONITOR
//--------------------------------------------------------------------------------------
_Use_decl_annotations_
HRESULT DXUTGetAdapterOrdinalFromMonitor( HMONITOR hMonitor, UINT* pAdapterOrdinal )
{
    *pAdapterOrdinal = 0;

    // Get the monitor handle information
    MONITORINFOEX mi;
    mi.cbSize = sizeof( MONITORINFOEX );
    DXUTGetMonitorInfo( hMonitor, &mi );

    // Search for this monitor in our enumeration hierarchy.
    auto pd3dEnum = DXUTGetD3D11Enumeration();
    auto pAdapterList = pd3dEnum.GetAdapterInfoList();
    for( auto it = pAdapterList.cbegin(); it != pAdapterList.cend(); ++it )
    {
        auto pAdapterInfo = *it;
        for( auto jit = pAdapterInfo.outputInfoList.cbegin(); jit != pAdapterInfo.outputInfoList.cend(); ++jit )
        {
            auto pOutputInfo = *jit;
            // Convert output device name from MBCS to Unicode
            if( wcsncmp( pOutputInfo.esc.DeviceName, mi.szDevice, sizeof( mi.szDevice ) / sizeof
                         ( mi.szDevice[0] ) ) == 0 )
            {
                *pAdapterOrdinal = pAdapterInfo.AdapterOrdinal;
                return S_OK;
            }
        }
    }
    return E_FAIL;
}


//--------------------------------------------------------------------------------------
// Look for a monitor ordinal that is tied to a HMONITOR (D3D11-only)
//--------------------------------------------------------------------------------------
_Use_decl_annotations_
HRESULT DXUTGetOutputOrdinalFromMonitor( HMONITOR hMonitor, UINT* pOutputOrdinal )
{
    // Get the monitor handle information
    MONITORINFOEX mi;
    mi.cbSize = sizeof( MONITORINFOEX );
    DXUTGetMonitorInfo( hMonitor, &mi );

    // Search for this monitor in our enumeration hierarchy.
    auto pd3dEnum = DXUTGetD3D11Enumeration();
    auto pAdapterList = pd3dEnum.GetAdapterInfoList();
    for( auto it = pAdapterList.cbegin(); it != pAdapterList.cend(); ++it )
    {
        auto pAdapterInfo = *it;
        for( auto jit = pAdapterInfo.outputInfoList.cbegin(); jit != pAdapterInfo.outputInfoList.cend(); ++jit )
        {
            auto pOutputInfo = *jit;
            DXGI_OUTPUT_DESC Desc;
            if ( FAILED(pOutputInfo.m_pOutput.GetDesc(&Desc)) )
                memset( &Desc, 0, sizeof(Desc) );

            if( hMonitor == Desc.Monitor )
            {
                *pOutputOrdinal = pOutputInfo.Output;
                return S_OK;
            }
        }
    }

    return E_FAIL;
}


//--------------------------------------------------------------------------------------
// This method is called when D3DERR_DEVICEREMOVED is returned from an API.  DXUT
// calls the application's DeviceRemoved callback to inform it of the event.  The
// application returns true if it wants DXUT to look for a closest device to run on.
// If no device is found, or the app returns false, DXUT shuts down.
//--------------------------------------------------------------------------------------
HRESULT DXUTHandleDeviceRemoved()
{
    HRESULT hr = S_OK;

    // Device has been removed. Call the application's callback if set.  If no callback
    // has been set, then just look for a new device
    bool bLookForNewDevice = true;
    LPDXUTCALLBACKDEVICEREMOVED pDeviceRemovedFunc = GetDXUTState().GetDeviceRemovedFunc();
    if( pDeviceRemovedFunc )
        bLookForNewDevice = pDeviceRemovedFunc( GetDXUTState().GetDeviceRemovedFuncUserContext() );

    if( bLookForNewDevice )
    {
        auto pDeviceSettings = GetDXUTState().GetCurrentDeviceSettings();


        hr = DXUTSnapDeviceSettingsToEnumDevice( pDeviceSettings, false);
        if( SUCCEEDED( hr ) )
        {
            // Change to a Direct3D device created from the new device settings
            // that is compatible with the removed device.
            hr = DXUTChangeDevice( pDeviceSettings, false );
            if( SUCCEEDED( hr ) )
                return S_OK;
        }
    }

    // The app does not wish to continue or continuing is not possible.
    return DXUTERR_DEVICEREMOVED;
}


//--------------------------------------------------------------------------------------
// Stores back buffer surface desc in GetDXUTState().GetBackBufferSurfaceDesc10()
//--------------------------------------------------------------------------------------
void DXUTUpdateBackBufferDesc()
{
    HRESULT hr;
    ID3D11Texture2D* pBackBuffer;
    auto pSwapChain = GetDXUTState().GetDXGISwapChain();
    assert( pSwapChain );
    _Analysis_assume_( pSwapChain );
    hr = pSwapChain.GetBuffer( 0, IID_PPV_ARGS(&pBackBuffer) );
    auto pBBufferSurfaceDesc = GetDXUTState().GetBackBufferSurfaceDescDXGI();
    ZeroMemory( pBBufferSurfaceDesc, sizeof( DXGI_SURFACE_DESC ) );
    if( SUCCEEDED( hr ) )
    {
        D3D11_TEXTURE2D_DESC TexDesc;
        pBackBuffer.GetDesc( &TexDesc );
        pBBufferSurfaceDesc.Width = ( UINT )TexDesc.Width;
        pBBufferSurfaceDesc.Height = ( UINT )TexDesc.Height;
        pBBufferSurfaceDesc.Format = TexDesc.Format;
        pBBufferSurfaceDesc.SampleDesc = TexDesc.SampleDesc;
        SAFE_RELEASE( pBackBuffer );
    }
}


//--------------------------------------------------------------------------------------
// Setup cursor based on current settings (window/fullscreen mode, show cursor state, clip cursor state)
//--------------------------------------------------------------------------------------
void DXUTSetupCursor()
{
    // Clip cursor if requested
    if( !DXUTIsWindowed() && GetDXUTState().GetClipCursorWhenFullScreen() )
    {
        // Confine cursor to full screen window
        RECT rcWindow;
        GetWindowRect( DXUTGetHWNDDeviceFullScreen(), &rcWindow );
        ClipCursor( &rcWindow );
    }
    else
    {
        ClipCursor( null );
    }
}


//--------------------------------------------------------------------------------------
// Updates the static part of the frame stats so it doesn't have be generated every frame
//--------------------------------------------------------------------------------------
void DXUTUpdateStaticFrameStats()
{
    if( GetDXUTState().GetNoStats() )
        return;

    auto pDeviceSettings = GetDXUTState().GetCurrentDeviceSettings();
    if( !pDeviceSettings )
        return;

    // D3D11
    auto pd3dEnum = DXUTGetD3D11Enumeration();
    if( !pd3dEnum )
        return;

    auto pDeviceSettingsCombo = pd3dEnum.GetDeviceSettingsCombo(
        pDeviceSettings.3d11.AdapterOrdinal,
        pDeviceSettings.3d11.sd.BufferDesc.Format, pDeviceSettings.3d11.sd.Windowed );
    if( !pDeviceSettingsCombo )
        return;

    WCHAR strFmt[100];
    wcscpy_s( strFmt, 100, DXUTDXGIFormatToString( pDeviceSettingsCombo.BackBufferFormat, false ) );

    WCHAR strMultiSample[100];
    swprintf_s( strMultiSample, 100, " (MS%u, Q%u)", pDeviceSettings.3d11.sd.SampleDesc.Count,
                        pDeviceSettings.3d11.sd.SampleDesc.Quality );
    auto pstrStaticFrameStats = GetDXUTState().GetStaticFrameStats();
    swprintf_s( pstrStaticFrameStats, 256, "D3D11 %%ls Vsync %ls (%ux%u), %ls%ls",
                        ( pDeviceSettings.3d11.SyncInterval == 0 ) ? "off" : "on",
                        pDeviceSettings.3d11.sd.BufferDesc.Width, pDeviceSettings.3d11.sd.BufferDesc.Height,
                        strFmt, strMultiSample );
}


//--------------------------------------------------------------------------------------
// Updates the frames/sec stat once per second
//--------------------------------------------------------------------------------------
void DXUTUpdateFrameStats()
{
    if( GetDXUTState().GetNoStats() )
        return;

    // Keep track of the frame count
    double fLastTime = GetDXUTState().GetLastStatsUpdateTime();
    DWORD dwFrames = GetDXUTState().GetLastStatsUpdateFrames();
    double fAbsTime = GetDXUTState().GetAbsoluteTime();
    dwFrames++;
    GetDXUTState().SetLastStatsUpdateFrames( dwFrames );

    // Update the scene stats once per second
    if( fAbsTime - fLastTime > 1.0f )
    {
        float fFPS = ( float )( dwFrames / ( fAbsTime - fLastTime ) );
        GetDXUTState().SetFPS( fFPS );
        GetDXUTState().SetLastStatsUpdateTime( fAbsTime );
        GetDXUTState().SetLastStatsUpdateFrames( 0 );

        auto pstrFPS = GetDXUTState().GetFPSStats();
        swprintf_s( pstrFPS, 64, "%0.2f fps ", fFPS );
    }
}


//--------------------------------------------------------------------------------------
// Returns a string describing the current device.  If bShowFPS is true, then
// the string contains the frames/sec.  If "-nostats" was used in 
// the command line, the string will be blank
//--------------------------------------------------------------------------------------
LPCWSTR DXUTGetFrameStats(bool bShowFPS )
{
    auto pstrFrameStats = GetDXUTState().GetFrameStats();
    const WCHAR* pstrFPS = ( bShowFPS ) ? GetDXUTState().GetFPSStats() : "";
    WCHAR* pstrStats = GetDXUTState().GetStaticFrameStats();
    swprintf_s( pstrFrameStats, 256, pstrStats, pstrFPS );
    return pstrFrameStats;
}


//--------------------------------------------------------------------------------------
// Updates the string which describes the device 
//--------------------------------------------------------------------------------------
#pragma warning( suppress : 6101 )
_Use_decl_annotations_
void DXUTUpdateD3D11DeviceStats( D3D_DRIVER_TYPE DeviceType, D3D_FEATURE_LEVEL featureLevel, DXGI_ADAPTER_DESC* pAdapterDesc )
{
    if( GetDXUTState().GetNoStats() )   
        return;

    // Store device description
    auto pstrDeviceStats = GetDXUTState().GetDeviceStats();
    if( DeviceType == D3D_DRIVER_TYPE_REFERENCE )
        wcscpy_s( pstrDeviceStats, 256, "REFERENCE" );
    else if( DeviceType == D3D_DRIVER_TYPE_HARDWARE )
        wcscpy_s( pstrDeviceStats, 256, "HARDWARE" );
    else if( DeviceType == D3D_DRIVER_TYPE_SOFTWARE )
        wcscpy_s( pstrDeviceStats, 256, "SOFTWARE" );
    else if( DeviceType == D3D_DRIVER_TYPE_WARP )
        wcscpy_s( pstrDeviceStats, 256, "WARP" );

    if( DeviceType == D3D_DRIVER_TYPE_HARDWARE )
    {
        // Be sure not to overflow m_strDeviceStats when appending the adapter 
        // description, since it can be long.  
        wcscat_s( pstrDeviceStats, 256, ": " );

        // Try to get a unique description from the CD3D11EnumDeviceSettingsCombo
        auto pDeviceSettings = GetDXUTState().GetCurrentDeviceSettings();
        if( !pDeviceSettings )
            return;

        auto pd3dEnum = DXUTGetD3D11Enumeration();
        assert( pd3dEnum );
        _Analysis_assume_( pd3dEnum );
        auto pDeviceSettingsCombo = pd3dEnum.GetDeviceSettingsCombo(
            pDeviceSettings.3d11.AdapterOrdinal,
            pDeviceSettings.3d11.sd.BufferDesc.Format, pDeviceSettings.3d11.sd.Windowed );
        if( pDeviceSettingsCombo )
            wcscat_s( pstrDeviceStats, 256, pDeviceSettingsCombo.pAdapterInfo.szUniqueDescription );
        else
            wcscat_s( pstrDeviceStats, 256, pAdapterDesc.escription );
    }

    switch( featureLevel )
    {
    case D3D_FEATURE_LEVEL_9_1:
        wcscat_s( pstrDeviceStats, 256, " (FL 9.1)" );
        break;
    case D3D_FEATURE_LEVEL_9_2:
        wcscat_s( pstrDeviceStats, 256, " (FL 9.2)" );
        break;
    case D3D_FEATURE_LEVEL_9_3:
        wcscat_s( pstrDeviceStats, 256, " (FL 9.3)" );
        break;
    case D3D_FEATURE_LEVEL_10_0:
        wcscat_s( pstrDeviceStats, 256, " (FL 10.0)" );
        break;
    case D3D_FEATURE_LEVEL_10_1:
        wcscat_s( pstrDeviceStats, 256, " (FL 10.1)" );
        break;
    case D3D_FEATURE_LEVEL_11_0:
        wcscat_s( pstrDeviceStats, 256, " (FL 11.0)" );
        break;
    case D3D_FEATURE_LEVEL_11_1:
        wcscat_s( pstrDeviceStats, 256, " (FL 11.1)" );
        break;
#if defined(USE_DIRECT3D11_3) || defined(USE_DIRECT3D11_4)
    case D3D_FEATURE_LEVEL_12_0:
        wcscat_s(pstrDeviceStats, 256, " (FL 12.0)");
        break;
    case D3D_FEATURE_LEVEL_12_1:
        wcscat_s(pstrDeviceStats, 256, " (FL 12.1)");
        break;
#endif
    }
}


//--------------------------------------------------------------------------------------
// Misc functions
//--------------------------------------------------------------------------------------
DXUTDeviceSettings DXUTGetDeviceSettings()
{
    // Return a copy of device settings of the current device.  If no device exists yet, then
    // return a blank device settings struct
    auto pDS = GetDXUTState().GetCurrentDeviceSettings();
    if( pDS )
    {
        return *pDS;
    }
    else
    {
        DXUTDeviceSettings ds = {};
        return ds;
    }
}

bool DXUTIsVsyncEnabled()
{
    auto pDS = GetDXUTState().GetCurrentDeviceSettings();
    if( pDS )
    {
        return ( pDS.3d11.SyncInterval == 0 );
    }
    else
    {
        return true;
    }
};

bool DXUTIsKeyDown(BYTE vKey )
{
    bool* bKeys = GetDXUTState().GetKeys();
    if( vKey >= 0xA0 && vKey <= 0xA5 )  // VK_LSHIFT, VK_RSHIFT, VK_LCONTROL, VK_RCONTROL, VK_LMENU, VK_RMENU
        return GetAsyncKeyState( vKey ) != 0; // these keys only are tracked via GetAsyncKeyState()
    else if( vKey >= 0x01 && vKey <= 0x06 && vKey != 0x03 ) // mouse buttons (VK_*BUTTON)
        return DXUTIsMouseButtonDown( vKey );
    else
        return bKeys[vKey];
}

bool DXUTWasKeyPressed(BYTE vKey )
{
    bool* bLastKeys = GetDXUTState().GetLastKeys();
    bool* bKeys = GetDXUTState().GetKeys();
    GetDXUTState().SetAppCalledWasKeyPressed( true );
    return ( !bLastKeys[vKey] && bKeys[vKey] );
}

bool DXUTIsMouseButtonDown(BYTE vButton )
{
    bool* bMouseButtons = GetDXUTState().GetMouseButtons();
    int nIndex = DXUTMapButtonToArrayIndex( vButton );
    return bMouseButtons[nIndex];
}

void DXUTSetMultimonSettings(bool bAutoChangeAdapter )
{
    GetDXUTState().SetAutoChangeAdapter( bAutoChangeAdapter );
}

_Use_decl_annotations_
void DXUTSetHotkeyHandling( bool bAltEnterToToggleFullscreen, bool bEscapeToQuit, bool bPauseToToggleTimePause )
{
    GetDXUTState().SetHandleEscape( bEscapeToQuit );
    GetDXUTState().SetHandleAltEnter( bAltEnterToToggleFullscreen );
    GetDXUTState().SetHandlePause( bPauseToToggleTimePause );
}

_Use_decl_annotations_
void DXUTSetCursorSettings( bool bShowCursorWhenFullScreen, bool bClipCursorWhenFullScreen )
{
    GetDXUTState().SetClipCursorWhenFullScreen( bClipCursorWhenFullScreen );
    GetDXUTState().SetShowCursorWhenFullScreen( bShowCursorWhenFullScreen );
    DXUTSetupCursor();
}

void DXUTSetWindowSettings(bool bCallDefWindowProc )
{
    GetDXUTState().SetCallDefWindowProc( bCallDefWindowProc );
}

_Use_decl_annotations_
void DXUTSetConstantFrameTime( bool bEnabled, float fTimePerFrame )
{
    if( GetDXUTState().GetOverrideConstantFrameTime() )
    {
        bEnabled = GetDXUTState().GetOverrideConstantFrameTime();
        fTimePerFrame = GetDXUTState().GetOverrideConstantTimePerFrame();
    }
    GetDXUTState().SetConstantFrameTime( bEnabled );
    GetDXUTState().SetTimePerFrame( fTimePerFrame );
}


//--------------------------------------------------------------------------------------
// Resets the state associated with DXUT 
//--------------------------------------------------------------------------------------
void DXUTResetFrameworkState()
{
    GetDXUTState().Destroy();
    GetDXUTState().Create();
}


//--------------------------------------------------------------------------------------
// Closes down the window.  When the window closes, it will cleanup everything
//--------------------------------------------------------------------------------------
void DXUTShutdown(int nExitCode )
{
    HWND hWnd = DXUTGetHWND();
    if( hWnd )
        SendMessage( hWnd, WM_CLOSE, 0, 0 );

    GetDXUTState().SetExitCode( nExitCode );

    DXUTCleanup3DEnvironment( true );

    // Restore shortcut keys (Windows key, accessibility shortcuts) to original state
    // This is important to call here if the shortcuts are disabled, 
    // because accessibility setting changes are permanent.
    // This means that if this is not done then the accessibility settings 
    // might not be the same as when the app was started. 
    // If the app crashes without restoring the settings, this is also true so it
    // would be wise to backup/restore the settings from a file so they can be 
    // restored when the crashed app is run again.
    DXUTAllowShortcutKeys( true );

    // Shutdown D3D11
    auto pDXGIFactory = GetDXUTState().GetDXGIFactory();
    SAFE_RELEASE( pDXGIFactory );
    GetDXUTState().SetDXGIFactory( null );
}


//--------------------------------------------------------------------------------------
// Tells DXUT whether to operate in gamma correct mode
//--------------------------------------------------------------------------------------
void DXUTSetIsInGammaCorrectMode(bool bGammaCorrect )
{
    GetDXUTState().SetIsInGammaCorrectMode( bGammaCorrect );
}


//--------------------------------------------------------------------------------------
void DXUTApplyDefaultDeviceSettings(DXUTDeviceSettings *modifySettings)
{
    ZeroMemory( modifySettings, sizeof( DXUTDeviceSettings ) );

    modifySettings.3d11.AdapterOrdinal = 0;
    modifySettings.3d11.AutoCreateDepthStencil = true;
    modifySettings.3d11.AutoDepthStencilFormat = DXGI_FORMAT_D24_UNORM_S8_UINT;
    version(debug)
    {
        modifySettings.3d11.CreateFlags |= D3D11_CREATE_DEVICE_DEBUG;
    }
    else
    {
        modifySettings.3d11.CreateFlags = 0;
    }
    modifySettings.3d11.DriverType = D3D_DRIVER_TYPE_HARDWARE;
    modifySettings.3d11.Output = 0;
    modifySettings.3d11.PresentFlags = 0;
    modifySettings.3d11.sd.BufferCount = 2;
    modifySettings.3d11.sd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM_SRGB;
    modifySettings.3d11.sd.BufferDesc.Height = 600;
    modifySettings.3d11.sd.BufferDesc.RefreshRate.Numerator = 0;
    modifySettings.3d11.sd.BufferDesc.RefreshRate.Denominator = 0;
    modifySettings.3d11.sd.BufferDesc.Scaling = DXGI_MODE_SCALING_UNSPECIFIED;
    modifySettings.3d11.sd.BufferDesc.ScanlineOrdering = DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED;
    modifySettings.3d11.sd.BufferDesc.Width = 800;
    modifySettings.3d11.sd.BufferUsage = 32;
    modifySettings.3d11.sd.Flags = DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH ;
    modifySettings.3d11.sd.OutputWindow = DXUTGetHWND();
    modifySettings.3d11.sd.SampleDesc.Count = 1;
    modifySettings.3d11.sd.SampleDesc.Quality = 0;
    modifySettings.3d11.sd.SwapEffect = DXGI_SWAP_EFFECT_DISCARD;
    modifySettings.3d11.sd.Windowed = TRUE;
    modifySettings.3d11.SyncInterval = 0;
}


//--------------------------------------------------------------------------------------
// Update settings based on what is enumeratabled
//--------------------------------------------------------------------------------------
_Use_decl_annotations_
HRESULT DXUTSnapDeviceSettingsToEnumDevice( DXUTDeviceSettings* pDeviceSettings, bool forceEnum,  D3D_FEATURE_LEVEL forceFL )
{
    if( GetSystemMetrics(SM_REMOTESESSION) != 0 )
    {
        pDeviceSettings.3d11.sd.Windowed = TRUE;
    }   
    int bestModeIndex=0;
    int bestMSAAIndex=0;

    //DXUTSetDefaultDeviceSettings
    CD3D11Enumeration *pEnum = DXUTGetD3D11Enumeration( forceEnum, true, forceFL);

    CD3D11EnumAdapterInfo* pAdapterInfo = null; 
    auto pAdapterList = pEnum.GetAdapterInfoList();
    for( auto it = pAdapterList.cbegin(); it != pAdapterList.cend(); ++it )
    {
        auto tempAdapterInfo = *it;
        if (tempAdapterInfo.AdapterOrdinal == pDeviceSettings.3d11.AdapterOrdinal) pAdapterInfo = tempAdapterInfo;
    }
    if ( !pAdapterInfo )
    {
        if ( pAdapterList.empty() || pDeviceSettings.3d11.AdapterOrdinal > 0 )
        {
            return E_FAIL; // no adapters found.
        }
        pAdapterInfo = *pAdapterList.cbegin();
    }
    CD3D11EnumDeviceSettingsCombo* pDeviceSettingsCombo = null;
    float biggestScore = 0;

    for( size_t iDeviceCombo = 0; iDeviceCombo < pAdapterInfo.eviceSettingsComboList.size(); iDeviceCombo++ )
    {
        CD3D11EnumDeviceSettingsCombo* tempDeviceSettingsCombo = pAdapterInfo.eviceSettingsComboList[ iDeviceCombo ];
    
        int bestMode;
        int bestMSAA;
        float score = DXUTRankD3D11DeviceCombo(tempDeviceSettingsCombo, &(pDeviceSettings.3d11), bestMode, bestMSAA );
        if (score > biggestScore)
        {
            biggestScore = score;
            pDeviceSettingsCombo = tempDeviceSettingsCombo;
            bestModeIndex = bestMode;
            bestMSAAIndex = bestMSAA;
        }
    }
    if (!pDeviceSettingsCombo )
    {
        return E_FAIL; // no settings found.
    }

    pDeviceSettings.3d11.AdapterOrdinal = pDeviceSettingsCombo.AdapterOrdinal;
    pDeviceSettings.3d11.DriverType = pDeviceSettingsCombo.eviceType;
    pDeviceSettings.3d11.Output = pDeviceSettingsCombo.Output;
    
    pDeviceSettings.3d11.sd.Windowed = pDeviceSettingsCombo.Windowed;
    if( GetSystemMetrics(SM_REMOTESESSION) != 0 )
    {
        pDeviceSettings.3d11.sd.Windowed = TRUE;
    }   
    if (pDeviceSettingsCombo.pOutputInfo)
    {
        auto bestDisplayMode = pDeviceSettingsCombo.pOutputInfo.isplayModeList[ bestModeIndex ];
        if (!pDeviceSettingsCombo.Windowed)
        {
            pDeviceSettings.3d11.sd.BufferDesc.Height = bestDisplayMode.Height;
            pDeviceSettings.3d11.sd.BufferDesc.Width = bestDisplayMode.Width;
            pDeviceSettings.3d11.sd.BufferDesc.RefreshRate.Numerator = bestDisplayMode.RefreshRate.Numerator;
            pDeviceSettings.3d11.sd.BufferDesc.RefreshRate.Denominator = bestDisplayMode.RefreshRate.Denominator;
            pDeviceSettings.3d11.sd.BufferDesc.Scaling = bestDisplayMode.Scaling;
            pDeviceSettings.3d11.sd.BufferDesc.ScanlineOrdering = bestDisplayMode.ScanlineOrdering;
        }
    }
    if (pDeviceSettings.3d11.DeviceFeatureLevel == 0)
        pDeviceSettings.3d11.DeviceFeatureLevel = pDeviceSettingsCombo.pDeviceInfo.SelectedLevel;

    if ( pDeviceSettings.3d11.DriverType == D3D_DRIVER_TYPE_WARP )
    {
        D3D_FEATURE_LEVEL maxWarpFL = pEnum.GetWARPFeaturevel();

        if ( pDeviceSettings.3d11.DeviceFeatureLevel > maxWarpFL )
            pDeviceSettings.3d11.DeviceFeatureLevel = maxWarpFL;
    }

    if ( pDeviceSettings.3d11.DriverType == D3D_DRIVER_TYPE_REFERENCE )
    {
        D3D_FEATURE_LEVEL maxRefFL = pEnum.GetREFFeaturevel();

        if ( pDeviceSettings.3d11.DeviceFeatureLevel > maxRefFL )
            pDeviceSettings.3d11.DeviceFeatureLevel = maxRefFL;
    }

    pDeviceSettings.3d11.sd.SampleDesc.Count = pDeviceSettingsCombo.multiSampleCountList[ bestMSAAIndex ];
    if (pDeviceSettings.3d11.sd.SampleDesc.Quality > pDeviceSettingsCombo.multiSampleQualityList[ bestMSAAIndex ] - 1)
        pDeviceSettings.3d11.sd.SampleDesc.Quality = pDeviceSettingsCombo.multiSampleQualityList[ bestMSAAIndex ] - 1;
        
    pDeviceSettings.3d11.sd.BufferDesc.Format = pDeviceSettingsCombo.BackBufferFormat;

    return S_OK;
}
