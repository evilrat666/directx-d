module directx.ddraw_err;

import core.sys.windows.windows:S_OK, S_FALSE, MAKE_HRESULT, HRESULT, E_FAIL, E_INVALIDARG,
E_OUTOFMEMORY, E_NOTIMPL, CO_E_NOTINITIALIZED;

enum _FACDD =  0x876;

HRESULT MAKE_DDHRESULT(HRESULT code)
{
    return MAKE_HRESULT(1, _FACDD, code);
}




/****************************************************************************
 *
 * DIRECTDRAW FX CAPABILITY FLAGS
 *
 ****************************************************************************/

/*
 * Uses arithmetic operations to stretch and shrink surfaces during blt
 * rather than pixel doubling techniques.  Along the Y axis.
 */
enum DDFXCAPS_BLTARITHSTRETCHY = 0x00000020;

/*
 * Uses arithmetic operations to stretch during blt
 * rather than pixel doubling techniques.  Along the Y axis. Only
 * works for x1, x2, etc.
 */
enum DDFXCAPS_BLTARITHSTRETCHYN = 0x00000010;

/*
 * Supports mirroring left to right in blt.
 */
enum DDFXCAPS_BLTMIRRORLEFTRIGHT = 0x00000040;

/*
 * Supports mirroring top to bottom in blt.
 */
enum DDFXCAPS_BLTMIRRORUPDOWN = 0x00000080;

/*
 * Supports arbitrary rotation for blts.
 */
enum DDFXCAPS_BLTROTATION = 0x00000100;

/*
 * Supports 90 degree rotations for blts.
 */
enum DDFXCAPS_BLTROTATION90 = 0x00000200;

/*
 * DirectDraw supports arbitrary shrinking of a surface along the
 * x axis (horizontal direction) for blts.
 */
enum DDFXCAPS_BLTSHRINKX = 0x00000400;

/*
 * DirectDraw supports integer shrinking (1x,2x,) of a surface
 * along the x axis (horizontal direction) for blts.
 */
enum DDFXCAPS_BLTSHRINKXN = 0x00000800;

/*
 * DirectDraw supports arbitrary shrinking of a surface along the
 * y axis (horizontal direction) for blts.
 */
enum DDFXCAPS_BLTSHRINKY = 0x00001000;

/*
 * DirectDraw supports integer shrinking (1x,2x,) of a surface
 * along the y axis (vertical direction) for blts.
 */
enum DDFXCAPS_BLTSHRINKYN = 0x00002000;

/*
 * DirectDraw supports arbitrary stretching of a surface along the
 * x axis (horizontal direction) for blts.
 */
enum DDFXCAPS_BLTSTRETCHX = 0x00004000;

/*
 * DirectDraw supports integer stretching (1x,2x,) of a surface
 * along the x axis (horizontal direction) for blts.
 */
enum DDFXCAPS_BLTSTRETCHXN = 0x00008000;

/*
 * DirectDraw supports arbitrary stretching of a surface along the
 * y axis (horizontal direction) for blts.
 */
enum DDFXCAPS_BLTSTRETCHY = 0x00010000;

/*
 * DirectDraw supports integer stretching (1x,2x,) of a surface
 * along the y axis (vertical direction) for blts.
 */
enum DDFXCAPS_BLTSTRETCHYN = 0x00020000;

/*
 * Uses arithmetic operations to stretch and shrink surfaces during
 * overlay rather than pixel doubling techniques.  Along the Y axis
 * for overlays.
 */
enum DDFXCAPS_OVERLAYARITHSTRETCHY = 0x00040000;

/*
 * Uses arithmetic operations to stretch surfaces during
 * overlay rather than pixel doubling techniques.  Along the Y axis
 * for overlays. Only works for x1, x2, etc.
 */
enum DDFXCAPS_OVERLAYARITHSTRETCHYN = 0x00000008;

/*
 * DirectDraw supports arbitrary shrinking of a surface along the
 * x axis (horizontal direction) for overlays.
 */
enum DDFXCAPS_OVERLAYSHRINKX = 0x00080000;

/*
 * DirectDraw supports integer shrinking (1x,2x,) of a surface
 * along the x axis (horizontal direction) for overlays.
 */
enum DDFXCAPS_OVERLAYSHRINKXN = 0x00100000;

/*
 * DirectDraw supports arbitrary shrinking of a surface along the
 * y axis (horizontal direction) for overlays.
 */
enum DDFXCAPS_OVERLAYSHRINKY = 0x00200000;

/*
 * DirectDraw supports integer shrinking (1x,2x,) of a surface
 * along the y axis (vertical direction) for overlays.
 */
enum DDFXCAPS_OVERLAYSHRINKYN = 0x00400000;

/*
 * DirectDraw supports arbitrary stretching of a surface along the
 * x axis (horizontal direction) for overlays.
 */
enum DDFXCAPS_OVERLAYSTRETCHX = 0x00800000;

/*
 * DirectDraw supports integer stretching (1x,2x,) of a surface
 * along the x axis (horizontal direction) for overlays.
 */
enum DDFXCAPS_OVERLAYSTRETCHXN = 0x01000000;

/*
 * DirectDraw supports arbitrary stretching of a surface along the
 * y axis (horizontal direction) for overlays.
 */
enum DDFXCAPS_OVERLAYSTRETCHY = 0x02000000;

/*
 * DirectDraw supports integer stretching (1x,2x,) of a surface
 * along the y axis (vertical direction) for overlays.
 */
enum DDFXCAPS_OVERLAYSTRETCHYN = 0x04000000;

/*
 * DirectDraw supports mirroring of overlays across the vertical axis
 */
enum DDFXCAPS_OVERLAYMIRRORLEFTRIGHT = 0x08000000;

/*
 * DirectDraw supports mirroring of overlays across the horizontal axis
 */
enum DDFXCAPS_OVERLAYMIRRORUPDOWN = 0x10000000;

/*
 * DirectDraw supports deinterlacing of overlay surfaces
 */
enum DDFXCAPS_OVERLAYDEINTERLACE = 0x20000000;

/*
 * Driver can do alpha blending for blits.
 */
enum DDFXCAPS_BLTALPHA = 0x00000001;


/*
 * Driver can do surface-reconstruction filtering for warped blits.
 */
enum DDFXCAPS_BLTFILTER = DDFXCAPS_BLTARITHSTRETCHY;

/*
 * Driver can do alpha blending for overlays.
 */
enum DDFXCAPS_OVERLAYALPHA = 0x00000004;


/*
 * Driver can do surface-reconstruction filtering for warped overlays.
 */
enum DDFXCAPS_OVERLAYFILTER = DDFXCAPS_OVERLAYARITHSTRETCHY;

/****************************************************************************
 *
 * DIRECTDRAW STEREO VIEW CAPABILITIES
 *
 ****************************************************************************/

/*
 * This flag used to be DDSVCAPS_ENIGMA, which is now obsolete
 */

enum DDSVCAPS_RESERVED1 = 0x00000001;

/*
 * This flag used to be DDSVCAPS_FLICKER, which is now obsolete
 */
enum DDSVCAPS_RESERVED2 = 0x00000002;

/*
 * This flag used to be DDSVCAPS_REDBLUE, which is now obsolete
 */
enum DDSVCAPS_RESERVED3 = 0x00000004;

/*
 * This flag used to be DDSVCAPS_SPLIT, which is now obsolete
 */
enum DDSVCAPS_RESERVED4 = 0x00000008;

/*
 * The stereo view is accomplished with switching technology
 */

enum DDSVCAPS_STEREOSEQUENTIAL = 0x00000010;



/****************************************************************************
 *
 * DIRECTDRAWPALETTE CAPABILITIES
 *
 ****************************************************************************/

/*
 * Index is 4 bits.  There are sixteen color entries in the palette table.
 */
enum DDPCAPS_4BIT = 0x00000001;

/*
 * Index is onto a 8 bit color index.  This field is only valid with the
 * DDPCAPS_1BIT, DDPCAPS_2BIT or DDPCAPS_4BIT capability and the target
 * surface is in 8bpp. Each color entry is one byte long and is an index
 * into destination surface's 8bpp palette.
 */
enum DDPCAPS_8BITENTRIES = 0x00000002;

/*
 * Index is 8 bits.  There are 256 color entries in the palette table.
 */
enum DDPCAPS_8BIT = 0x00000004;

/*
 * Indicates that this DIRECTDRAWPALETTE should use the palette color array
 * passed into the lpDDColorArray parameter to initialize the DIRECTDRAWPALETTE
 * object.
 * This flag is obsolete. DirectDraw always initializes the color array from
 * the lpDDColorArray parameter. The definition remains for source-level
 * compatibility.
 */
enum DDPCAPS_INITIALIZE = 0x00000000;

/*
 * This palette is the one attached to the primary surface.  Changing this
 * table has immediate effect on the display unless DDPSETPAL_VSYNC is specified
 * and supported.
 */
enum DDPCAPS_PRIMARYSURFACE = 0x00000010;

/*
 * This palette is the one attached to the primary surface left.  Changing
 * this table has immediate effect on the display for the left eye unless
 * DDPSETPAL_VSYNC is specified and supported.
 */
enum DDPCAPS_PRIMARYSURFACELEFT = 0x00000020;

/*
 * This palette can have all 256 entries defined
 */
enum DDPCAPS_ALLOW256 = 0x00000040;

/*
 * This palette can have modifications to it synced with the monitors
 * refresh rate.
 */
enum DDPCAPS_VSYNC = 0x00000080;

/*
 * Index is 1 bit.  There are two color entries in the palette table.
 */
enum DDPCAPS_1BIT = 0x00000100;

/*
 * Index is 2 bit.  There are four color entries in the palette table.
 */
enum DDPCAPS_2BIT = 0x00000200;

/*
 * The peFlags member of PALETTEENTRY denotes an 8 bit alpha value
 */
enum DDPCAPS_ALPHA = 0x00000400;


/****************************************************************************
 *
 * DIRECTDRAWPALETTE SETENTRY CONSTANTS
 *
 ****************************************************************************/


/****************************************************************************
 *
 * DIRECTDRAWPALETTE GETENTRY CONSTANTS
 *
 ****************************************************************************/

/* 0 is the only legal value */

/****************************************************************************
 *
 * DIRECTDRAWSURFACE SETPRIVATEDATA CONSTANTS
 *
 ****************************************************************************/

/*
 * The passed pointer is an IUnknown ptr. The cbData argument to SetPrivateData
 * must be set to sizeof(IUnknown*). DirectDraw will call AddRef through this
 * pointer and Release when the private data is destroyed. This includes when
 * the surface or palette is destroyed before such priovate data is destroyed.
 */
enum DDSPD_IUNKNOWNPOINTER = 0x00000001;

/*
 * Private data is only valid for the current state of the object,
 * as determined by the uniqueness value.
 */
enum DDSPD_VOLATILE = 0x00000002;


/****************************************************************************
 *
 * DIRECTDRAWSURFACE SETPALETTE CONSTANTS
 *
 ****************************************************************************/


/****************************************************************************
 *
 * DIRECTDRAW BITDEPTH CONSTANTS
 *
 * NOTE:  These are only used to indicate supported bit depths.   These
 * are flags only, they are not to be used as an actual bit depth.   The
 * absolute numbers 1, 2, 4, 8, 16, 24 and 32 are used to indicate actual
 * bit depths in a surface or for changing the display mode.
 *
 ****************************************************************************/

/*
 * 1 bit per pixel.
 */
enum DDBD_1 = 0x00004000;

/*
 * 2 bits per pixel.
 */
enum DDBD_2 = 0x00002000;

/*
 * 4 bits per pixel.
 */
enum DDBD_4 = 0x00001000;

/*
 * 8 bits per pixel.
 */
enum DDBD_8 = 0x00000800;

/*
 * 16 bits per pixel.
 */
enum DDBD_16 = 0x00000400;

/*
 * 24 bits per pixel.
 */
enum DDBD_24 = 0X00000200;

/*
 * 32 bits per pixel.
 */
enum DDBD_32 = 0x00000100;

/****************************************************************************
 *
 * DIRECTDRAWSURFACE SET/GET COLOR KEY FLAGS
 *
 ****************************************************************************/

/*
 * Set if the structure contains a color space.  Not set if the structure
 * contains a single color key.
 */
enum DDCKEY_COLORSPACE = 0x00000001;

/*
 * Set if the structure specifies a color key or color space which is to be
 * used as a destination color key for blt operations.
 */
enum DDCKEY_DESTBLT = 0x00000002;

/*
 * Set if the structure specifies a color key or color space which is to be
 * used as a destination color key for overlay operations.
 */
enum DDCKEY_DESTOVERLAY = 0x00000004;

/*
 * Set if the structure specifies a color key or color space which is to be
 * used as a source color key for blt operations.
 */
enum DDCKEY_SRCBLT = 0x00000008;

/*
 * Set if the structure specifies a color key or color space which is to be
 * used as a source color key for overlay operations.
 */
enum DDCKEY_SRCOVERLAY = 0x00000010;


/****************************************************************************
 *
 * DIRECTDRAW COLOR KEY CAPABILITY FLAGS
 *
 ****************************************************************************/

/*
 * Supports transparent blting using a color key to identify the replaceable
 * bits of the destination surface for RGB colors.
 */
enum DDCKEYCAPS_DESTBLT = 0x00000001;

/*
 * Supports transparent blting using a color space to identify the replaceable
 * bits of the destination surface for RGB colors.
 */
enum DDCKEYCAPS_DESTBLTCLRSPACE = 0x00000002;

/*
 * Supports transparent blting using a color space to identify the replaceable
 * bits of the destination surface for YUV colors.
 */
enum DDCKEYCAPS_DESTBLTCLRSPACEYUV = 0x00000004;

/*
 * Supports transparent blting using a color key to identify the replaceable
 * bits of the destination surface for YUV colors.
 */
enum DDCKEYCAPS_DESTBLTYUV = 0x00000008;

/*
 * Supports overlaying using colorkeying of the replaceable bits of the surface
 * being overlayed for RGB colors.
 */
enum DDCKEYCAPS_DESTOVERLAY = 0x00000010;

/*
 * Supports a color space as the color key for the destination for RGB colors.
 */
enum DDCKEYCAPS_DESTOVERLAYCLRSPACE = 0x00000020;

/*
 * Supports a color space as the color key for the destination for YUV colors.
 */
enum DDCKEYCAPS_DESTOVERLAYCLRSPACEYUV = 0x00000040;

/*
 * Supports only one active destination color key value for visible overlay
 * surfaces.
 */
enum DDCKEYCAPS_DESTOVERLAYONEACTIVE = 0x00000080;

/*
 * Supports overlaying using colorkeying of the replaceable bits of the
 * surface being overlayed for YUV colors.
 */
enum DDCKEYCAPS_DESTOVERLAYYUV = 0x00000100;

/*
 * Supports transparent blting using the color key for the source with
 * this surface for RGB colors.
 */
enum DDCKEYCAPS_SRCBLT = 0x00000200;

/*
 * Supports transparent blting using a color space for the source with
 * this surface for RGB colors.
 */
enum DDCKEYCAPS_SRCBLTCLRSPACE = 0x00000400;

/*
 * Supports transparent blting using a color space for the source with
 * this surface for YUV colors.
 */
enum DDCKEYCAPS_SRCBLTCLRSPACEYUV = 0x00000800;

/*
 * Supports transparent blting using the color key for the source with
 * this surface for YUV colors.
 */
enum DDCKEYCAPS_SRCBLTYUV = 0x00001000;

/*
 * Supports overlays using the color key for the source with this
 * overlay surface for RGB colors.
 */
enum DDCKEYCAPS_SRCOVERLAY = 0x00002000;

/*
 * Supports overlays using a color space as the source color key for
 * the overlay surface for RGB colors.
 */
enum DDCKEYCAPS_SRCOVERLAYCLRSPACE = 0x00004000;

/*
 * Supports overlays using a color space as the source color key for
 * the overlay surface for YUV colors.
 */
enum DDCKEYCAPS_SRCOVERLAYCLRSPACEYUV = 0x00008000;

/*
 * Supports only one active source color key value for visible
 * overlay surfaces.
 */
enum DDCKEYCAPS_SRCOVERLAYONEACTIVE = 0x00010000;

/*
 * Supports overlays using the color key for the source with this
 * overlay surface for YUV colors.
 */
enum DDCKEYCAPS_SRCOVERLAYYUV = 0x00020000;

/*
 * there are no bandwidth trade-offs for using colorkey with an overlay
 */
enum DDCKEYCAPS_NOCOSTOVERLAY = 0x00040000;


/****************************************************************************
 *
 * DIRECTDRAW PIXELFORMAT FLAGS
 *
 ****************************************************************************/

/*
 * The surface has alpha channel information in the pixel format.
 */
enum DDPF_ALPHAPIXELS = 0x00000001;

/*
 * The pixel format contains alpha only information
 */
enum DDPF_ALPHA = 0x00000002;

/*
 * The FourCC code is valid.
 */
enum DDPF_FOURCC = 0x00000004;

/*
 * The surface is 4-bit color indexed.
 */
enum DDPF_PALETTEINDEXED4 = 0x00000008;

/*
 * The surface is indexed into a palette which stores indices
 * into the destination surface's 8-bit palette.
 */
enum DDPF_PALETTEINDEXEDTO8 = 0x00000010;

/*
 * The surface is 8-bit color indexed.
 */
enum DDPF_PALETTEINDEXED8 = 0x00000020;

/*
 * The RGB data in the pixel format structure is valid.
 */
enum DDPF_RGB = 0x00000040;

/*
 * The surface will accept pixel data in the format specified
 * and compress it during the write.
 */
enum DDPF_COMPRESSED = 0x00000080;

/*
 * The surface will accept RGB data and translate it during
 * the write to YUV data.  The format of the data to be written
 * will be contained in the pixel format structure.  The DDPF_RGB
 * flag will be set.
 */
enum DDPF_RGBTOYUV = 0x00000100;

/*
 * pixel format is YUV - YUV data in pixel format struct is valid
 */
enum DDPF_YUV = 0x00000200;

/*
 * pixel format is a z buffer only surface
 */
enum DDPF_ZBUFFER = 0x00000400;

/*
 * The surface is 1-bit color indexed.
 */
enum DDPF_PALETTEINDEXED1 = 0x00000800;

/*
 * The surface is 2-bit color indexed.
 */
enum DDPF_PALETTEINDEXED2 = 0x00001000;

/*
 * The surface contains Z information in the pixels
 */
enum DDPF_ZPIXELS = 0x00002000;

/*
 * The surface contains stencil information along with Z
 */
enum DDPF_STENCILBUFFER = 0x00004000;

/*
 * Premultiplied alpha format -- the color components have been
 * premultiplied by the alpha component.
 */
enum DDPF_ALPHAPREMULT = 0x00008000;


/*
 * Luminance data in the pixel format is valid.
 * Use this flag for luminance-only or luminance+alpha surfaces,
 * the bit depth is then ddpf.dwLuminanceBitCount.
 */
enum DDPF_LUMINANCE = 0x00020000;

/*
 * Luminance data in the pixel format is valid.
 * Use this flag when hanging luminance off bumpmap surfaces,
 * the bit mask for the luminance portion of the pixel is then
 * ddpf.dwBumpLuminanceBitMask
 */
enum DDPF_BUMPLUMINANCE = 0x00040000;

/*
 * Bump map dUdV data in the pixel format is valid.
 */
enum DDPF_BUMPDUDV = 0x00080000;


/*===========================================================================
 *
 *
 * DIRECTDRAW CALLBACK FLAGS
 *
 *
 *==========================================================================*/

/****************************************************************************
 *
 * DIRECTDRAW ENUMSURFACES FLAGS
 *
 ****************************************************************************/

/*
 * Enumerate all of the surfaces that meet the search criterion.
 */
enum DDENUMSURFACES_ALL = 0x00000001;

/*
 * A search hit is a surface that matches the surface description.
 */
enum DDENUMSURFACES_MATCH = 0x00000002;

/*
 * A search hit is a surface that does not match the surface description.
 */
enum DDENUMSURFACES_NOMATCH = 0x00000004;

/*
 * Enumerate the first surface that can be created which meets the search criterion.
 */
enum DDENUMSURFACES_CANBECREATED = 0x00000008;

/*
 * Enumerate the surfaces that already exist that meet the search criterion.
 */
enum DDENUMSURFACES_DOESEXIST = 0x00000010;


/****************************************************************************
 *
 * DIRECTDRAW SETDISPLAYMODE FLAGS
 *
 ****************************************************************************/

/*
 * The desired mode is a standard VGA mode
 */
enum DDSDM_STANDARDVGAMODE = 0x00000001;


/****************************************************************************
 *
 * DIRECTDRAW ENUMDISPLAYMODES FLAGS
 *
 ****************************************************************************/

/*
 * Enumerate Modes with different refresh rates.  EnumDisplayModes guarantees
 * that a particular mode will be enumerated only once.  This flag specifies whether
 * the refresh rate is taken into account when determining if a mode is unique.
 */
enum DDEDM_REFRESHRATES = 0x00000001;

/*
 * Enumerate VGA modes. Specify this flag if you wish to enumerate supported VGA
 * modes such as mode 0x13 in addition to the usual ModeX modes (which are always
 * enumerated if the application has previously called SetCooperativeLevel with the
 * DDSCL_ALLOWMODEX flag set).
 */
enum DDEDM_STANDARDVGAMODES = 0x00000002;


/****************************************************************************
 *
 * DIRECTDRAW SETCOOPERATIVELEVEL FLAGS
 *
 ****************************************************************************/

/*
 * Exclusive mode owner will be responsible for the entire primary surface.
 * GDI can be ignored. used with DD
 */
enum DDSCL_FULLSCREEN = 0x00000001;

/*
 * allow CTRL_ALT_DEL to work while in fullscreen exclusive mode
 */
enum DDSCL_ALLOWREBOOT = 0x00000002;

/*
 * prevents DDRAW from modifying the application window.
 * prevents DDRAW from minimize/restore the application window on activation.
 */
enum DDSCL_NOWINDOWCHANGES = 0x00000004;

/*
 * app wants to work as a regular Windows application
 */
enum DDSCL_NORMAL = 0x00000008;

/*
 * app wants exclusive access
 */
enum DDSCL_EXCLUSIVE = 0x00000010;


/*
 * app can deal with non-windows display modes
 */
enum DDSCL_ALLOWMODEX = 0x00000040;

/*
 * this window will receive the focus messages
 */
enum DDSCL_SETFOCUSWINDOW = 0x00000080;

/*
 * this window is associated with the DDRAW object and will
 * cover the screen in fullscreen mode
 */
enum DDSCL_SETDEVICEWINDOW = 0x00000100;

/*
 * app wants DDRAW to create a window to be associated with the
 * DDRAW object
 */
enum DDSCL_CREATEDEVICEWINDOW = 0x00000200;

/*
 * App explicitly asks DDRAW/D3D to be multithread safe. This makes D3D
 * take the global crtisec more frequently.
 */
enum DDSCL_MULTITHREADED = 0x00000400;

/*
 * App specifies that it would like to keep the FPU set up for optimal Direct3D
 * performance (single precision and exceptions disabled) so Direct3D
 * does not need to explicitly set the FPU each time. This is assumed by
 * default in DirectX 7. See also DDSCL_FPUPRESERVE
 */
enum DDSCL_FPUSETUP = 0x00000800;

/*
 * App specifies that it needs either double precision FPU or FPU exceptions
 * enabled. This makes Direct3D explicitly set the FPU state eah time it is
 * called. Setting the flag will reduce Direct3D performance. The flag is
 * assumed by default in DirectX 6 and earlier. See also DDSCL_FPUSETUP
 */
enum DDSCL_FPUPRESERVE = 0x00001000;


/****************************************************************************
 *
 * DIRECTDRAW BLT FLAGS
 *
 ****************************************************************************/

/*
 * Use the alpha information in the pixel format or the alpha channel surface
 * attached to the destination surface as the alpha channel for this blt.
 */
enum DDBLT_ALPHADEST = 0x00000001;

/*
 * Use the dwConstAlphaDest field in the DDBLTFX structure as the alpha channel
 * for the destination surface for this blt.
 */
enum DDBLT_ALPHADESTCONSTOVERRIDE = 0x00000002;

/*
 * The NEG suffix indicates that the destination surface becomes more
 * transparent as the alpha value increases. (0 is opaque)
 */
enum DDBLT_ALPHADESTNEG = 0x00000004;

/*
 * Use the lpDDSAlphaDest field in the DDBLTFX structure as the alpha
 * channel for the destination for this blt.
 */
enum DDBLT_ALPHADESTSURFACEOVERRIDE = 0x00000008;

/*
 * Use the dwAlphaEdgeBlend field in the DDBLTFX structure as the alpha channel
 * for the edges of the image that border the color key colors.
 */
enum DDBLT_ALPHAEDGEBLEND = 0x00000010;

/*
 * Use the alpha information in the pixel format or the alpha channel surface
 * attached to the source surface as the alpha channel for this blt.
 */
enum DDBLT_ALPHASRC = 0x00000020;

/*
 * Use the dwConstAlphaSrc field in the DDBLTFX structure as the alpha channel
 * for the source for this blt.
 */
enum DDBLT_ALPHASRCCONSTOVERRIDE = 0x00000040;

/*
 * The NEG suffix indicates that the source surface becomes more transparent
 * as the alpha value increases. (0 is opaque)
 */
enum DDBLT_ALPHASRCNEG = 0x00000080;

/*
 * Use the lpDDSAlphaSrc field in the DDBLTFX structure as the alpha channel
 * for the source for this blt.
 */
enum DDBLT_ALPHASRCSURFACEOVERRIDE = 0x00000100;

/*
 * Do this blt asynchronously through the FIFO in the order received.  If
 * there is no room in the hardware FIFO fail the call.
 */
enum DDBLT_ASYNC = 0x00000200;

/*
 * Uses the dwFillColor field in the DDBLTFX structure as the RGB color
 * to fill the destination rectangle on the destination surface with.
 */
enum DDBLT_COLORFILL = 0x00000400;

/*
 * Uses the dwDDFX field in the DDBLTFX structure to specify the effects
 * to use for the blt.
 */
enum DDBLT_DDFX = 0x00000800;

/*
 * Uses the dwDDROPS field in the DDBLTFX structure to specify the ROPS
 * that are not part of the Win32 API.
 */
enum DDBLT_DDROPS = 0x00001000;

/*
 * Use the color key associated with the destination surface.
 */
enum DDBLT_KEYDEST = 0x00002000;

/*
 * Use the dckDestColorkey field in the DDBLTFX structure as the color key
 * for the destination surface.
 */
enum DDBLT_KEYDESTOVERRIDE = 0x00004000;

/*
 * Use the color key associated with the source surface.
 */
enum DDBLT_KEYSRC = 0x00008000;

/*
 * Use the dckSrcColorkey field in the DDBLTFX structure as the color key
 * for the source surface.
 */
enum DDBLT_KEYSRCOVERRIDE = 0x00010000;

/*
 * Use the dwROP field in the DDBLTFX structure for the raster operation
 * for this blt.  These ROPs are the same as the ones defined in the Win32 API.
 */
enum DDBLT_ROP = 0x00020000;

/*
 * Use the dwRotationAngle field in the DDBLTFX structure as the angle
 * (specified in 1/100th of a degree) to rotate the surface.
 */
enum DDBLT_ROTATIONANGLE = 0x00040000;

/*
 * Z-buffered blt using the z-buffers attached to the source and destination
 * surfaces and the dwZBufferOpCode field in the DDBLTFX structure as the
 * z-buffer opcode.
 */
enum DDBLT_ZBUFFER = 0x00080000;

/*
 * Z-buffered blt using the dwConstDest Zfield and the dwZBufferOpCode field
 * in the DDBLTFX structure as the z-buffer and z-buffer opcode respectively
 * for the destination.
 */
enum DDBLT_ZBUFFERDESTCONSTOVERRIDE = 0x00100000;

/*
 * Z-buffered blt using the lpDDSDestZBuffer field and the dwZBufferOpCode
 * field in the DDBLTFX structure as the z-buffer and z-buffer opcode
 * respectively for the destination.
 */
enum DDBLT_ZBUFFERDESTOVERRIDE = 0x00200000;

/*
 * Z-buffered blt using the dwConstSrcZ field and the dwZBufferOpCode field
 * in the DDBLTFX structure as the z-buffer and z-buffer opcode respectively
 * for the source.
 */
enum DDBLT_ZBUFFERSRCCONSTOVERRIDE = 0x00400000;

/*
 * Z-buffered blt using the lpDDSSrcZBuffer field and the dwZBufferOpCode
 * field in the DDBLTFX structure as the z-buffer and z-buffer opcode
 * respectively for the source.
 */
enum DDBLT_ZBUFFERSRCOVERRIDE = 0x00800000;

/*
 * wait until the device is ready to handle the blt
 * this will cause blt to not return DDERR_WASSTILLDRAWING
 */
enum DDBLT_WAIT = 0x01000000;

/*
 * Uses the dwFillDepth field in the DDBLTFX structure as the depth value
 * to fill the destination rectangle on the destination Z-buffer surface
 * with.
 */
enum DDBLT_DEPTHFILL = 0x02000000;


/*
 * Return immediately (with DDERR_WASSTILLDRAWING) if the device is not
 * ready to schedule the blt at the time Blt() is called.
 */
enum DDBLT_DONOTWAIT = 0x08000000;

/*
 * These flags indicate a presentation blt (i.e. a blt
 * that moves surface contents from an offscreen back buffer to the primary
 * surface). The driver is not allowed to "queue"  more than three such blts.
 * The "end" of the presentation blt is indicated, since the
 * blt may be clipped, in which case the runtime will call the driver with 
 * several blts. All blts (even if not clipped) are tagged with DDBLT_PRESENTATION
 * and the last (even if not clipped) additionally with DDBLT_LAST_PRESENTATION.
 * Thus the true rule is that the driver must not schedule a DDBLT_PRESENTATION
 * blt if there are 3 or more DDBLT_PRESENTLAST blts in the hardware pipe.
 * If there are such blts in the pipe, the driver should return DDERR_WASSTILLDRAWING
 * until the oldest queued DDBLT_LAST_PRESENTATION blts has been retired (i.e. the
 * pixels have been actually written to the primary surface). Once the oldest blt
 * has been retired, the driver is free to schedule the current blt.
 * The goal is to provide a mechanism whereby the device's hardware queue never
 * gets more than 3 frames ahead of the frames being generated by the application.
 * When excessive queueing occurs, applications become unusable because the application
 * visibly lags user input, and such problems make windowed interactive applications impossible.
 * Some drivers may not have sufficient knowledge of their hardware's FIFO to know
 * when a certain blt has been retired. Such drivers should code cautiously, and 
 * simply not allow any frames to be queued at all. DDBLT_LAST_PRESENTATION should cause
 * such drivers to return DDERR_WASSTILLDRAWING until the accelerator is completely
 * finished- exactly as if the application had called Lock on the source surface
 * before calling Blt. 
 * In other words, the driver is allowed and encouraged to 
 * generate as much latency as it can, but never more than 3 frames worth.
 * Implementation detail: Drivers should count blts against the SOURCE surface, not
 * against the primary surface. This enables multiple parallel windowed application
 * to function more optimally.
 * This flag is passed only to DX8 or higher drivers.
 *
 * APPLICATIONS DO NOT SET THESE FLAGS. THEY ARE SET BY THE DIRECTDRAW RUNTIME.
 * 
 */
enum DDBLT_PRESENTATION = 0x10000000;
enum DDBLT_LAST_PRESENTATION = 0x20000000;

/*
 * If DDBLT_EXTENDED_FLAGS is set, then the driver should re-interpret
 * other flags according to the definitions that follow.
 * For example, bit 0 (0x00000001) means DDBLT_ALPHADEST, unless
 * DDBLT_EXTENDED_FLAGS is also set, in which case bit 0 means
 * DDBLT_EXTENDED_LINEAR_CONTENT.
 * Only DirectX9 and higher drivers will be given extended blt flags.
 * Only flags explicitly mentioned here should be re-interpreted.
 * All other flags retain their original meanings.
 *
 * List of re-interpreted flags:
 *
 * Bit Hex value   New meaning                                  old meaning
 * ---------------------------------------------------------------
 *  2  0x00000004  DDBLT_EXTENDED_LINEAR_CONTENT                DDBLT_ALPHADESTNEG
 *  4  0x00000010  DDBLT_EXTENDED_PRESENTATION_STRETCHFACTOR    DDBLT_ALPHAEDGEBLEND
 *
 *
 * NOTE: APPLICATIONS SHOULD NOT SET THIS FLAG. THIS FLAG IS INTENDED
 * FOR USE BY THE DIRECT3D RUNTIME.
 */
enum DDBLT_EXTENDED_FLAGS = 0x40000000;

/*
 * EXTENDED FLAG. SEE DEFINITION OF DDBLT_EXTENDED_FLAGS.
 * This flag indidcates that the source surface contains content in a
 * linear color space. The driver may perform gamma correction to the
 * desktop color space (i.e. sRGB, gamma 2.2) as part of this blt.
 * If the device can perform such a conversion as part of the copy,
 * the driver should also set D3DCAPS3_LINEAR_TO_SRGB_PRESENTATION
 *
 * NOTE: APPLICATIONS SHOULD NOT SET THIS FLAG. THIS FLAG IS INTENDED
 * FOR USE BY THE DIRECT3D RUNTIME. Use IDirect3DSwapChain9::Present
 * and specify D3DPRESENT_LINEAR_CONTENT in order to use this functionality.
 */ 
enum DDBLT_EXTENDED_LINEAR_CONTENT = 0x00000004;


/****************************************************************************
 *
 * BLTFAST FLAGS
 *
 ****************************************************************************/

enum DDBLTFAST_NOCOLORKEY = 0x00000000;
enum DDBLTFAST_SRCCOLORKEY = 0x00000001;
enum DDBLTFAST_DESTCOLORKEY = 0x00000002;
enum DDBLTFAST_WAIT = 0x00000010;
enum DDBLTFAST_DONOTWAIT = 0x00000020;

/****************************************************************************
 *
 * FLIP FLAGS
 *
 ****************************************************************************/

enum DDFLIP_WAIT = 0x00000001;

/*
 * Indicates that the target surface contains the even field of video data.
 * This flag is only valid with an overlay surface.
 */
enum DDFLIP_EVEN = 0x00000002;

/*
 * Indicates that the target surface contains the odd field of video data.
 * This flag is only valid with an overlay surface.
 */
enum DDFLIP_ODD = 0x00000004;

/*
 * Causes DirectDraw to perform the physical flip immediately and return
 * to the application. Typically, what was the front buffer but is now the back
 * buffer will still be visible (depending on timing) until the next vertical
 * retrace. Subsequent operations involving the two flipped surfaces will
 * not check to see if the physical flip has finished (i.e. will not return
 * DDERR_WASSTILLDRAWING for that reason (but may for other reasons)).
 * This allows an application to perform Flips at a higher frequency than the
 * monitor refresh rate, but may introduce visible artifacts.
 * Only effective if DDCAPS2_FLIPNOVSYNC is set. If that bit is not set,
 * DDFLIP_NOVSYNC has no effect.
 */
enum DDFLIP_NOVSYNC = 0x00000008;


/*
 * Flip Interval Flags. These flags indicate how many vertical retraces to wait between
 * each flip. The default is one. DirectDraw will return DDERR_WASSTILLDRAWING for each
 * surface involved in the flip until the specified number of vertical retraces has
 * ocurred. Only effective if DDCAPS2_FLIPINTERVAL is set. If that bit is not set,
 * DDFLIP_INTERVALn has no effect.
 */

/*
 * DirectDraw will flip on every other vertical sync
 */
enum DDFLIP_INTERVAL2 = 0x02000000;


/*
 * DirectDraw will flip on every third vertical sync
 */
enum DDFLIP_INTERVAL3 = 0x03000000;


/*
 * DirectDraw will flip on every fourth vertical sync
 */
enum DDFLIP_INTERVAL4 = 0x04000000;

/*
 * DirectDraw will flip and display a main stereo surface
 */
enum DDFLIP_STEREO = 0x00000010;

/*
 * On IDirectDrawSurface7 and higher interfaces, the default is DDFLIP_WAIT. If you wish
 * to override the default and use time when the accelerator is busy (as denoted by
 * the DDERR_WASSTILLDRAWING return code) then use DDFLIP_DONOTWAIT.
 */
enum DDFLIP_DONOTWAIT = 0x00000020;


/****************************************************************************
 *
 * DIRECTDRAW SURFACE OVERLAY FLAGS
 *
 ****************************************************************************/

/*
 * Use the alpha information in the pixel format or the alpha channel surface
 * attached to the destination surface as the alpha channel for the
 * destination overlay.
 */
enum DDOVER_ALPHADEST = 0x00000001;

/*
 * Use the dwConstAlphaDest field in the DDOVERLAYFX structure as the
 * destination alpha channel for this overlay.
 */
enum DDOVER_ALPHADESTCONSTOVERRIDE = 0x00000002;

/*
 * The NEG suffix indicates that the destination surface becomes more
 * transparent as the alpha value increases.
 */
enum DDOVER_ALPHADESTNEG = 0x00000004;

/*
 * Use the lpDDSAlphaDest field in the DDOVERLAYFX structure as the alpha
 * channel destination for this overlay.
 */
enum DDOVER_ALPHADESTSURFACEOVERRIDE = 0x00000008;

/*
 * Use the dwAlphaEdgeBlend field in the DDOVERLAYFX structure as the alpha
 * channel for the edges of the image that border the color key colors.
 */
enum DDOVER_ALPHAEDGEBLEND = 0x00000010;

/*
 * Use the alpha information in the pixel format or the alpha channel surface
 * attached to the source surface as the source alpha channel for this overlay.
 */
enum DDOVER_ALPHASRC = 0x00000020;

/*
 * Use the dwConstAlphaSrc field in the DDOVERLAYFX structure as the source
 * alpha channel for this overlay.
 */
enum DDOVER_ALPHASRCCONSTOVERRIDE = 0x00000040;

/*
 * The NEG suffix indicates that the source surface becomes more transparent
 * as the alpha value increases.
 */
enum DDOVER_ALPHASRCNEG = 0x00000080;

/*
 * Use the lpDDSAlphaSrc field in the DDOVERLAYFX structure as the alpha channel
 * source for this overlay.
 */
enum DDOVER_ALPHASRCSURFACEOVERRIDE = 0x00000100;

/*
 * Turn this overlay off.
 */
enum DDOVER_HIDE = 0x00000200;

/*
 * Use the color key associated with the destination surface.
 */
enum DDOVER_KEYDEST = 0x00000400;

/*
 * Use the dckDestColorkey field in the DDOVERLAYFX structure as the color key
 * for the destination surface
 */
enum DDOVER_KEYDESTOVERRIDE = 0x00000800;

/*
 * Use the color key associated with the source surface.
 */
enum DDOVER_KEYSRC = 0x00001000;

/*
 * Use the dckSrcColorkey field in the DDOVERLAYFX structure as the color key
 * for the source surface.
 */
enum DDOVER_KEYSRCOVERRIDE = 0x00002000;

/*
 * Turn this overlay on.
 */
enum DDOVER_SHOW = 0x00004000;

/*
 * Add a dirty rect to an emulated overlayed surface.
 */
enum DDOVER_ADDDIRTYRECT = 0x00008000;

/*
 * Redraw all dirty rects on an emulated overlayed surface.
 */
enum DDOVER_REFRESHDIRTYRECTS = 0x00010000;

/*
 * Redraw the entire surface on an emulated overlayed surface.
 */
enum DDOVER_REFRESHALL = 0x00020000;


/*
 * Use the overlay FX flags to define special overlay FX
 */
enum DDOVER_DDFX = 0x00080000;

/*
 * Autoflip the overlay when ever the video port autoflips
 */
enum DDOVER_AUTOFLIP = 0x00100000;

/*
 * Display each field of video port data individually without
 * causing any jittery artifacts
 */
enum DDOVER_BOB = 0x00200000;

/*
 * Indicates that bob/weave decisions should not be overridden by other
 * interfaces.
 */
enum DDOVER_OVERRIDEBOBWEAVE = 0x00400000;

/*
 * Indicates that the surface memory is composed of interleaved fields.
 */
enum DDOVER_INTERLEAVED = 0x00800000;

/*
 * Indicates that bob will be performed using hardware rather than
 * software or emulated.
 */
enum DDOVER_BOBHARDWARE = 0x01000000;

/*
 * Indicates that overlay FX structure contains valid ARGB scaling factors.
 */
enum DDOVER_ARGBSCALEFACTORS = 0x02000000;

/*
 * Indicates that ARGB scaling factors can be degraded to fit driver capabilities.
 */
enum DDOVER_DEGRADEARGBSCALING = 0x04000000;



/****************************************************************************
 *
 * DIRECTDRAWSURFACE SETSURFACEDESC FLAGS
 *
 ****************************************************************************/

/*
 * The default.  The GDI DC will be tore down.
 */
enum DDSETSURFACEDESC_RECREATEDC = 0x00000000;     // default;

/*
 * The default.  The GDI DC will be kept.
 */
enum DDSETSURFACEDESC_PRESERVEDC = 0x00000001;


/****************************************************************************
 *
 * DIRECTDRAWSURFACE LOCK FLAGS
 *
 ****************************************************************************/

/*
 * The default.  Set to indicate that Lock should return a valid memory pointer
 * to the top of the specified rectangle.  If no rectangle is specified then a
 * pointer to the top of the surface is returned.
 */
enum DDLOCK_SURFACEMEMORYPTR = 0x00000000;     // default;

/*
 * Set to indicate that Lock should wait until it can obtain a valid memory
 * pointer before returning.  If this bit is set, Lock will never return
 * DDERR_WASSTILLDRAWING.
 */
enum DDLOCK_WAIT = 0x00000001;

/*
 * Set if an event handle is being passed to Lock.  Lock will trigger the event
 * when it can return the surface memory pointer requested.
 */
enum DDLOCK_EVENT = 0x00000002;

/*
 * Indicates that the surface being locked will only be read from.
 */
enum DDLOCK_READONLY = 0x00000010;

/*
 * Indicates that the surface being locked will only be written to
 */
enum DDLOCK_WRITEONLY = 0x00000020;


/*
 * Indicates that a system wide lock should not be taken when this surface
 * is locked. This has several advantages (cursor responsiveness, ability
 * to call more Windows functions, easier debugging) when locking video
 * memory surfaces. However, an application specifying this flag must
 * comply with a number of conditions documented in the help file.
 * Furthermore, this flag cannot be specified when locking the primary.
 */
enum DDLOCK_NOSYSLOCK = 0x00000800;

/*
 * Used only with Direct3D Vertex Buffer Locks. Indicates that no vertices
 * that were referred to in Draw*PrimtiveVB calls since the start of the
 * frame (or the last lock without this flag) will be modified during the
 * lock. This can be useful when one is only appending data to the vertex
 * buffer
 */
enum DDLOCK_NOOVERWRITE = 0x00001000;

/*
 * Indicates that no assumptions will be made about the contents of the
 * surface or vertex buffer during this lock.
 * This enables two things:
 * -    Direct3D or the driver may provide an alternative memory
 *      area as the vertex buffer. This is useful when one plans to clear the
 *      contents of the vertex buffer and fill in new data.
 * -    Drivers sometimes store surface data in a re-ordered format.
 *      When the application locks the surface, the driver is forced to un-re-order
 *      the surface data before allowing the application to see the surface contents.
 *      This flag is a hint to the driver that it can skip the un-re-ordering process
 *      since the application plans to overwrite every single pixel in the surface
 *      or locked rectangle (and so erase any un-re-ordered pixels anyway).
 *      Applications should always set this flag when they intend to overwrite the entire
 *      surface or locked rectangle.
 */
enum DDLOCK_DISCARDCONTENTS = 0x00002000;
 /*
  * DDLOCK_OKTOSWAP is an older, less informative name for DDLOCK_DISCARDCONTENTS
  */
enum DDLOCK_OKTOSWAP = 0x00002000;

/*
 * On IDirectDrawSurface7 and higher interfaces, the default is DDLOCK_WAIT. If you wish
 * to override the default and use time when the accelerator is busy (as denoted by
 * the DDERR_WASSTILLDRAWING return code) then use DDLOCK_DONOTWAIT.
 */
enum DDLOCK_DONOTWAIT = 0x00004000;

/*
 * This indicates volume texture lock with front and back specified.
 */
enum DDLOCK_HASVOLUMETEXTUREBOXRECT = 0x00008000;

/*
 * This indicates that the driver should not update dirty rect information for this lock.
 */
enum DDLOCK_NODIRTYUPDATE = 0x00010000;


/****************************************************************************
 *
 * DIRECTDRAWSURFACE PAGELOCK FLAGS
 *
 ****************************************************************************/

/*
 * No flags defined at present
 */


/****************************************************************************
 *
 * DIRECTDRAWSURFACE PAGEUNLOCK FLAGS
 *
 ****************************************************************************/

/*
 * No flags defined at present
 */


/****************************************************************************
 *
 * DIRECTDRAWSURFACE BLT FX FLAGS
 *
 ****************************************************************************/

/*
 * If stretching, use arithmetic stretching along the Y axis for this blt.
 */
enum DDBLTFX_ARITHSTRETCHY = 0x00000001;

/*
 * Do this blt mirroring the surface left to right.  Spin the
 * surface around its y-axis.
 */
enum DDBLTFX_MIRRORLEFTRIGHT = 0x00000002;

/*
 * Do this blt mirroring the surface up and down.  Spin the surface
 * around its x-axis.
 */
enum DDBLTFX_MIRRORUPDOWN = 0x00000004;

/*
 * Schedule this blt to avoid tearing.
 */
enum DDBLTFX_NOTEARING = 0x00000008;

/*
 * Do this blt rotating the surface one hundred and eighty degrees.
 */
enum DDBLTFX_ROTATE180 = 0x00000010;

/*
 * Do this blt rotating the surface two hundred and seventy degrees.
 */
enum DDBLTFX_ROTATE270 = 0x00000020;

/*
 * Do this blt rotating the surface ninety degrees.
 */
enum DDBLTFX_ROTATE90 = 0x00000040;

/*
 * Do this z blt using dwZBufferLow and dwZBufferHigh as  range values
 * specified to limit the bits copied from the source surface.
 */
enum DDBLTFX_ZBUFFERRANGE = 0x00000080;

/*
 * Do this z blt adding the dwZBufferBaseDest to each of the sources z values
 * before comparing it with the desting z values.
 */
enum DDBLTFX_ZBUFFERBASEDEST = 0x00000100;

/****************************************************************************
 *
 * DIRECTDRAWSURFACE OVERLAY FX FLAGS
 *
 ****************************************************************************/

/*
 * If stretching, use arithmetic stretching along the Y axis for this overlay.
 */
enum DDOVERFX_ARITHSTRETCHY = 0x00000001;

/*
 * Mirror the overlay across the vertical axis
 */
enum DDOVERFX_MIRRORLEFTRIGHT = 0x00000002;

/*
 * Mirror the overlay across the horizontal axis
 */
enum DDOVERFX_MIRRORUPDOWN = 0x00000004;

/*
 * Deinterlace the overlay, if possible
 */
enum DDOVERFX_DEINTERLACE = 0x00000008;


/****************************************************************************
 *
 * DIRECTDRAW WAITFORVERTICALBLANK FLAGS
 *
 ****************************************************************************/

/*
 * return when the vertical blank interval begins
 */
enum DDWAITVB_BLOCKBEGIN = 0x00000001;

/*
 * set up an event to trigger when the vertical blank begins
 */
enum DDWAITVB_BLOCKBEGINEVENT = 0x00000002;

/*
 * return when the vertical blank interval ends and display begins
 */
enum DDWAITVB_BLOCKEND = 0x00000004;

/****************************************************************************
 *
 * DIRECTDRAW GETFLIPSTATUS FLAGS
 *
 ****************************************************************************/

/*
 * is it OK to flip now?
 */
enum DDGFS_CANFLIP = 0x00000001;

/*
 * is the last flip finished?
 */
enum DDGFS_ISFLIPDONE = 0x00000002;

/****************************************************************************
 *
 * DIRECTDRAW GETBLTSTATUS FLAGS
 *
 ****************************************************************************/

/*
 * is it OK to blt now?
 */
enum DDGBS_CANBLT = 0x00000001;

/*
 * is the blt to the surface finished?
 */
enum DDGBS_ISBLTDONE = 0x00000002;


/****************************************************************************
 *
 * DIRECTDRAW ENUMOVERLAYZORDER FLAGS
 *
 ****************************************************************************/

/*
 * Enumerate overlays back to front.
 */
enum DDENUMOVERLAYZ_BACKTOFRONT = 0x00000000;

/*
 * Enumerate overlays front to back
 */
enum DDENUMOVERLAYZ_FRONTTOBACK = 0x00000001;

/****************************************************************************
 *
 * DIRECTDRAW UPDATEOVERLAYZORDER FLAGS
 *
 ****************************************************************************/

/*
 * Send overlay to front
 */
enum DDOVERZ_SENDTOFRONT = 0x00000000;

/*
 * Send overlay to back
 */
enum DDOVERZ_SENDTOBACK = 0x00000001;

/*
 * Move Overlay forward
 */
enum DDOVERZ_MOVEFORWARD = 0x00000002;

/*
 * Move Overlay backward
 */
enum DDOVERZ_MOVEBACKWARD = 0x00000003;

/*
 * Move Overlay in front of relative surface
 */
enum DDOVERZ_INSERTINFRONTOF = 0x00000004;

/*
 * Move Overlay in back of relative surface
 */
enum DDOVERZ_INSERTINBACKOF = 0x00000005;


/****************************************************************************
 *
 * DIRECTDRAW SETGAMMARAMP FLAGS
 *
 ****************************************************************************/

/*
 * Request calibrator to adjust the gamma ramp according to the physical
 * properties of the display so that the result should appear identical
 * on all systems.
 */
enum DDSGR_CALIBRATE = 0x00000001;


/****************************************************************************
 *
 * DIRECTDRAW STARTMODETEST FLAGS
 *
 ****************************************************************************/

/*
 * Indicates that the mode being tested has passed
 */
enum DDSMT_ISTESTREQUIRED = 0x00000001;


/****************************************************************************
 *
 * DIRECTDRAW EVALUATEMODE FLAGS
 *
 ****************************************************************************/

/*
 * Indicates that the mode being tested has passed
 */
enum DDEM_MODEPASSED = 0x00000001;

/*
 * Indicates that the mode being tested has failed
 */
enum DDEM_MODEFAILED = 0x00000002;


/*===========================================================================
 *
 *
 * DIRECTDRAW RETURN CODES
 *
 * The return values from DirectDraw Commands and Surface that return an HRESULT
 * are codes from DirectDraw concerning the results of the action
 * requested by DirectDraw.
 *
 *==========================================================================*/

/*
 * Status is OK
 *
 * Issued by: DirectDraw Commands and all callbacks
 */
enum DD_OK = S_OK;
enum DD_FALSE = S_FALSE;

/****************************************************************************
 *
 * DIRECTDRAW ENUMCALLBACK RETURN VALUES
 *
 * EnumCallback returns are used to control the flow of the DIRECTDRAW and
 * DIRECTDRAWSURFACE object enumerations.   They can only be returned by
 * enumeration callback routines.
 *
 ****************************************************************************/

/*
 * stop the enumeration
 */
enum DDENUMRET_CANCEL = 0;

/*
 * continue the enumeration
 */
enum DDENUMRET_OK = 1;

/****************************************************************************
 *
 * DIRECTDRAW ERRORS
 *
 * Errors are represented by negative values and cannot be combined.
 *
 ****************************************************************************/

/*
 * This object is already initialized
 */
enum DDERR_ALREADYINITIALIZED = MAKE_DDHRESULT( 5 );

/*
 * This surface can not be attached to the requested surface.
 */
enum DDERR_CANNOTATTACHSURFACE = MAKE_DDHRESULT( 10 );

/*
 * This surface can not be detached from the requested surface.
 */
enum DDERR_CANNOTDETACHSURFACE = MAKE_DDHRESULT( 20 );

/*
 * Support is currently not available.
 */
enum DDERR_CURRENTLYNOTAVAIL = MAKE_DDHRESULT( 40 );

/*
 * An exception was encountered while performing the requested operation
 */
enum DDERR_EXCEPTION = MAKE_DDHRESULT( 55 );

/*
 * Generic failure.
 */
enum DDERR_GENERIC = E_FAIL;

/*
 * Height of rectangle provided is not a multiple of reqd alignment
 */
enum DDERR_HEIGHTALIGN = MAKE_DDHRESULT( 90 );

/*
 * Unable to match primary surface creation request with existing
 * primary surface.
 */
enum DDERR_INCOMPATIBLEPRIMARY = MAKE_DDHRESULT( 95 );

/*
 * One or more of the caps bits passed to the callback are incorrect.
 */
enum DDERR_INVALIDCAPS = MAKE_DDHRESULT( 100 );

/*
 * DirectDraw does not support provided Cliplist.
 */
enum DDERR_INVALIDCLIPLIST = MAKE_DDHRESULT( 110 );

/*
 * DirectDraw does not support the requested mode
 */
enum DDERR_INVALIDMODE = MAKE_DDHRESULT( 120 );

/*
 * DirectDraw received a pointer that was an invalid DIRECTDRAW object.
 */
enum DDERR_INVALIDOBJECT = MAKE_DDHRESULT( 130 );

/*
 * One or more of the parameters passed to the callback function are
 * incorrect.
 */
enum DDERR_INVALIDPARAMS = E_INVALIDARG;

/*
 * pixel format was invalid as specified
 */
enum DDERR_INVALIDPIXELFORMAT = MAKE_DDHRESULT( 145 );

/*
 * Rectangle provided was invalid.
 */
enum DDERR_INVALIDRECT = MAKE_DDHRESULT( 150 );

/*
 * Operation could not be carried out because one or more surfaces are locked
 */
enum DDERR_LOCKEDSURFACES = MAKE_DDHRESULT( 160 );

/*
 * There is no 3D present.
 */
enum DDERR_NO3D = MAKE_DDHRESULT( 170 );

/*
 * Operation could not be carried out because there is no alpha accleration
 * hardware present or available.
 */
enum DDERR_NOALPHAHW = MAKE_DDHRESULT( 180 );

/*
 * Operation could not be carried out because there is no stereo
 * hardware present or available.
 */
enum DDERR_NOSTEREOHARDWARE = MAKE_DDHRESULT( 181 );

/*
 * Operation could not be carried out because there is no hardware
 * present which supports stereo surfaces
 */
enum DDERR_NOSURFACELEFT = MAKE_DDHRESULT( 182 );



/*
 * no clip list available
 */
enum DDERR_NOCLIPLIST = MAKE_DDHRESULT( 205 );

/*
 * Operation could not be carried out because there is no color conversion
 * hardware present or available.
 */
enum DDERR_NOCOLORCONVHW = MAKE_DDHRESULT( 210 );

/*
 * Create function called without DirectDraw object method SetCooperativeLevel
 * being called.
 */
enum DDERR_NOCOOPERATIVELEVELSET = MAKE_DDHRESULT( 212 );

/*
 * Surface doesn't currently have a color key
 */
enum DDERR_NOCOLORKEY = MAKE_DDHRESULT( 215 );

/*
 * Operation could not be carried out because there is no hardware support
 * of the dest color key.
 */
enum DDERR_NOCOLORKEYHW = MAKE_DDHRESULT( 220 );

/*
 * No DirectDraw support possible with current display driver
 */
enum DDERR_NODIRECTDRAWSUPPORT = MAKE_DDHRESULT( 222 );

/*
 * Operation requires the application to have exclusive mode but the
 * application does not have exclusive mode.
 */
enum DDERR_NOEXCLUSIVEMODE = MAKE_DDHRESULT( 225 );

/*
 * Flipping visible surfaces is not supported.
 */
enum DDERR_NOFLIPHW = MAKE_DDHRESULT( 230 );

/*
 * There is no GDI present.
 */
enum DDERR_NOGDI = MAKE_DDHRESULT( 240 );

/*
 * Operation could not be carried out because there is no hardware present
 * or available.
 */
enum DDERR_NOMIRRORHW = MAKE_DDHRESULT( 250 );

/*
 * Requested item was not found
 */
enum DDERR_NOTFOUND = MAKE_DDHRESULT( 255 );

/*
 * Operation could not be carried out because there is no overlay hardware
 * present or available.
 */
enum DDERR_NOOVERLAYHW = MAKE_DDHRESULT( 260 );

/*
 * Operation could not be carried out because the source and destination
 * rectangles are on the same surface and overlap each other.
 */
enum DDERR_OVERLAPPINGRECTS = MAKE_DDHRESULT( 270 );

/*
 * Operation could not be carried out because there is no appropriate raster
 * op hardware present or available.
 */
enum DDERR_NORASTEROPHW = MAKE_DDHRESULT( 280 );

/*
 * Operation could not be carried out because there is no rotation hardware
 * present or available.
 */
enum DDERR_NOROTATIONHW = MAKE_DDHRESULT( 290 );

/*
 * Operation could not be carried out because there is no hardware support
 * for stretching
 */
enum DDERR_NOSTRETCHHW = MAKE_DDHRESULT( 310 );

/*
 * DirectDrawSurface is not in 4 bit color palette and the requested operation
 * requires 4 bit color palette.
 */
enum DDERR_NOT4BITCOLOR = MAKE_DDHRESULT( 316 );

/*
 * DirectDrawSurface is not in 4 bit color index palette and the requested
 * operation requires 4 bit color index palette.
 */
enum DDERR_NOT4BITCOLORINDEX = MAKE_DDHRESULT( 317 );

/*
 * DirectDraw Surface is not in 8 bit color mode and the requested operation
 * requires 8 bit color.
 */
enum DDERR_NOT8BITCOLOR = MAKE_DDHRESULT( 320 );

/*
 * Operation could not be carried out because there is no texture mapping
 * hardware present or available.
 */
enum DDERR_NOTEXTUREHW = MAKE_DDHRESULT( 330 );

/*
 * Operation could not be carried out because there is no hardware support
 * for vertical blank synchronized operations.
 */
enum DDERR_NOVSYNCHW = MAKE_DDHRESULT( 335 );

/*
 * Operation could not be carried out because there is no hardware support
 * for zbuffer blting.
 */
enum DDERR_NOZBUFFERHW = MAKE_DDHRESULT( 340 );

/*
 * Overlay surfaces could not be z layered based on their BltOrder because
 * the hardware does not support z layering of overlays.
 */
enum DDERR_NOZOVERLAYHW = MAKE_DDHRESULT( 350 );

/*
 * The hardware needed for the requested operation has already been
 * allocated.
 */
enum DDERR_OUTOFCAPS = MAKE_DDHRESULT( 360 );

/*
 * DirectDraw does not have enough memory to perform the operation.
 */
enum DDERR_OUTOFMEMORY = E_OUTOFMEMORY;

/*
 * DirectDraw does not have enough memory to perform the operation.
 */
enum DDERR_OUTOFVIDEOMEMORY = MAKE_DDHRESULT( 380 );

/*
 * hardware does not support clipped overlays
 */
enum DDERR_OVERLAYCANTCLIP = MAKE_DDHRESULT( 382 );

/*
 * Can only have ony color key active at one time for overlays
 */
enum DDERR_OVERLAYCOLORKEYONLYONEACTIVE = MAKE_DDHRESULT( 384 );

/*
 * Access to this palette is being refused because the palette is already
 * locked by another thread.
 */
enum DDERR_PALETTEBUSY = MAKE_DDHRESULT( 387 );

/*
 * No src color key specified for this operation.
 */
enum DDERR_COLORKEYNOTSET = MAKE_DDHRESULT( 400 );

/*
 * This surface is already attached to the surface it is being attached to.
 */
enum DDERR_SURFACEALREADYATTACHED = MAKE_DDHRESULT( 410 );

/*
 * This surface is already a dependency of the surface it is being made a
 * dependency of.
 */
enum DDERR_SURFACEALREADYDEPENDENT = MAKE_DDHRESULT( 420 );

/*
 * Access to this surface is being refused because the surface is already
 * locked by another thread.
 */
enum DDERR_SURFACEBUSY = MAKE_DDHRESULT( 430 );

/*
 * Access to this surface is being refused because no driver exists
 * which can supply a pointer to the surface.
 * This is most likely to happen when attempting to lock the primary
 * surface when no DCI provider is present.
 * Will also happen on attempts to lock an optimized surface.
 */
enum DDERR_CANTLOCKSURFACE = MAKE_DDHRESULT( 435 );

/*
 * Access to Surface refused because Surface is obscured.
 */
enum DDERR_SURFACEISOBSCURED = MAKE_DDHRESULT( 440 );

/*
 * Access to this surface is being refused because the surface is gone.
 * The DIRECTDRAWSURFACE object representing this surface should
 * have Restore called on it.
 */
enum DDERR_SURFACELOST = MAKE_DDHRESULT( 450 );

/*
 * The requested surface is not attached.
 */
enum DDERR_SURFACENOTATTACHED = MAKE_DDHRESULT( 460 );

/*
 * Height requested by DirectDraw is too large.
 */
enum DDERR_TOOBIGHEIGHT = MAKE_DDHRESULT( 470 );

/*
 * Size requested by DirectDraw is too large --  The individual height and
 * width are OK.
 */
enum DDERR_TOOBIGSIZE = MAKE_DDHRESULT( 480 );

/*
 * Width requested by DirectDraw is too large.
 */
enum DDERR_TOOBIGWIDTH = MAKE_DDHRESULT( 490 );

/*
 * Action not supported.
 */
enum DDERR_UNSUPPORTED = E_NOTIMPL;

/*
 * Pixel format requested is unsupported by DirectDraw
 */
enum DDERR_UNSUPPORTEDFORMAT = MAKE_DDHRESULT( 510 );

/*
 * Bitmask in the pixel format requested is unsupported by DirectDraw
 */
enum DDERR_UNSUPPORTEDMASK = MAKE_DDHRESULT( 520 );

/*
 * The specified stream contains invalid data
 */
enum DDERR_INVALIDSTREAM = MAKE_DDHRESULT( 521 );

/*
 * vertical blank is in progress
 */
enum DDERR_VERTICALBLANKINPROGRESS = MAKE_DDHRESULT( 537 );

/*
 * Informs DirectDraw that the previous Blt which is transfering information
 * to or from this Surface is incomplete.
 */
enum DDERR_WASSTILLDRAWING = MAKE_DDHRESULT( 540 );


/*
 * The specified surface type requires specification of the COMPLEX flag
 */
enum DDERR_DDSCAPSCOMPLEXREQUIRED = MAKE_DDHRESULT( 542 );


/*
 * Rectangle provided was not horizontally aligned on reqd. boundary
 */
enum DDERR_XALIGN = MAKE_DDHRESULT( 560 );

/*
 * The GUID passed to DirectDrawCreate is not a valid DirectDraw driver
 * identifier.
 */
enum DDERR_INVALIDDIRECTDRAWGUID = MAKE_DDHRESULT( 561 );

/*
 * A DirectDraw object representing this driver has already been created
 * for this process.
 */
enum DDERR_DIRECTDRAWALREADYCREATED = MAKE_DDHRESULT( 562 );

/*
 * A hardware only DirectDraw object creation was attempted but the driver
 * did not support any hardware.
 */
enum DDERR_NODIRECTDRAWHW = MAKE_DDHRESULT( 563 );

/*
 * this process already has created a primary surface
 */
enum DDERR_PRIMARYSURFACEALREADYEXISTS = MAKE_DDHRESULT( 564 );

/*
 * software emulation not available.
 */
enum DDERR_NOEMULATION = MAKE_DDHRESULT( 565 );

/*
 * region passed to Clipper::GetClipList is too small.
 */
enum DDERR_REGIONTOOSMALL = MAKE_DDHRESULT( 566 );

/*
 * an attempt was made to set a clip list for a clipper objec that
 * is already monitoring an hwnd.
 */
enum DDERR_CLIPPERISUSINGHWND = MAKE_DDHRESULT( 567 );

/*
 * No clipper object attached to surface object
 */
enum DDERR_NOCLIPPERATTACHED = MAKE_DDHRESULT( 568 );

/*
 * Clipper notification requires an HWND or
 * no HWND has previously been set as the CooperativeLevel HWND.
 */
enum DDERR_NOHWND = MAKE_DDHRESULT( 569 );

/*
 * HWND used by DirectDraw CooperativeLevel has been subclassed,
 * this prevents DirectDraw from restoring state.
 */
enum DDERR_HWNDSUBCLASSED = MAKE_DDHRESULT( 570 );

/*
 * The CooperativeLevel HWND has already been set.
 * It can not be reset while the process has surfaces or palettes created.
 */
enum DDERR_HWNDALREADYSET = MAKE_DDHRESULT( 571 );

/*
 * No palette object attached to this surface.
 */
enum DDERR_NOPALETTEATTACHED = MAKE_DDHRESULT( 572 );

/*
 * No hardware support for 16 or 256 color palettes.
 */
enum DDERR_NOPALETTEHW = MAKE_DDHRESULT( 573 );

/*
 * If a clipper object is attached to the source surface passed into a
 * BltFast call.
 */
enum DDERR_BLTFASTCANTCLIP = MAKE_DDHRESULT( 574 );

/*
 * No blter.
 */
enum DDERR_NOBLTHW = MAKE_DDHRESULT( 575 );

/*
 * No DirectDraw ROP hardware.
 */
enum DDERR_NODDROPSHW = MAKE_DDHRESULT( 576 );

/*
 * returned when GetOverlayPosition is called on a hidden overlay
 */
enum DDERR_OVERLAYNOTVISIBLE = MAKE_DDHRESULT( 577 );

/*
 * returned when GetOverlayPosition is called on a overlay that UpdateOverlay
 * has never been called on to establish a destionation.
 */
enum DDERR_NOOVERLAYDEST = MAKE_DDHRESULT( 578 );

/*
 * returned when the position of the overlay on the destionation is no longer
 * legal for that destionation.
 */
enum DDERR_INVALIDPOSITION = MAKE_DDHRESULT( 579 );

/*
 * returned when an overlay member is called for a non-overlay surface
 */
enum DDERR_NOTAOVERLAYSURFACE = MAKE_DDHRESULT( 580 );

/*
 * An attempt was made to set the cooperative level when it was already
 * set to exclusive.
 */
enum DDERR_EXCLUSIVEMODEALREADYSET = MAKE_DDHRESULT( 581 );

/*
 * An attempt has been made to flip a surface that is not flippable.
 */
enum DDERR_NOTFLIPPABLE = MAKE_DDHRESULT( 582 );

/*
 * Can't duplicate primary & 3D surfaces, or surfaces that are implicitly
 * created.
 */
enum DDERR_CANTDUPLICATE = MAKE_DDHRESULT( 583 );

/*
 * Surface was not locked.  An attempt to unlock a surface that was not
 * locked at all, or by this process, has been attempted.
 */
enum DDERR_NOTLOCKED = MAKE_DDHRESULT( 584 );

/*
 * Windows can not create any more DCs, or a DC was requested for a paltte-indexed
 * surface when the surface had no palette AND the display mode was not palette-indexed
 * (in this case DirectDraw cannot select a proper palette into the DC)
 */
enum DDERR_CANTCREATEDC = MAKE_DDHRESULT( 585 );

/*
 * No DC was ever created for this surface.
 */
enum DDERR_NODC = MAKE_DDHRESULT( 586 );

/*
 * This surface can not be restored because it was created in a different
 * mode.
 */
enum DDERR_WRONGMODE = MAKE_DDHRESULT( 587 );

/*
 * This surface can not be restored because it is an implicitly created
 * surface.
 */
enum DDERR_IMPLICITLYCREATED = MAKE_DDHRESULT( 588 );

/*
 * The surface being used is not a palette-based surface
 */
enum DDERR_NOTPALETTIZED = MAKE_DDHRESULT( 589 );


/*
 * The display is currently in an unsupported mode
 */
enum DDERR_UNSUPPORTEDMODE = MAKE_DDHRESULT( 590 );

/*
 * Operation could not be carried out because there is no mip-map
 * texture mapping hardware present or available.
 */
enum DDERR_NOMIPMAPHW = MAKE_DDHRESULT( 591 );

/*
 * The requested action could not be performed because the surface was of
 * the wrong type.
 */
enum DDERR_INVALIDSURFACETYPE = MAKE_DDHRESULT( 592 );


/*
 * Device does not support optimized surfaces, therefore no video memory optimized surfaces
 */
enum DDERR_NOOPTIMIZEHW = MAKE_DDHRESULT( 600 );

/*
 * Surface is an optimized surface, but has not yet been allocated any memory
 */
enum DDERR_NOTLOADED = MAKE_DDHRESULT( 601 );

/*
 * Attempt was made to create or set a device window without first setting
 * the focus window
 */
enum DDERR_NOFOCUSWINDOW = MAKE_DDHRESULT( 602 );

/*
 * Attempt was made to set a palette on a mipmap sublevel
 */
enum DDERR_NOTONMIPMAPSUBLEVEL = MAKE_DDHRESULT( 603 );

/*
 * A DC has already been returned for this surface. Only one DC can be
 * retrieved per surface.
 */
enum DDERR_DCALREADYCREATED = MAKE_DDHRESULT( 620 );

/*
 * An attempt was made to allocate non-local video memory from a device
 * that does not support non-local video memory.
 */
enum DDERR_NONONLOCALVIDMEM = MAKE_DDHRESULT( 630 );

/*
 * The attempt to page lock a surface failed.
 */
enum DDERR_CANTPAGELOCK = MAKE_DDHRESULT( 640 );


/*
 * The attempt to page unlock a surface failed.
 */
enum DDERR_CANTPAGEUNLOCK = MAKE_DDHRESULT( 660 );

/*
 * An attempt was made to page unlock a surface with no outstanding page locks.
 */
enum DDERR_NOTPAGELOCKED = MAKE_DDHRESULT( 680 );

/*
 * There is more data available than the specified buffer size could hold
 */
enum DDERR_MOREDATA = MAKE_DDHRESULT( 690 );

/*
 * The data has expired and is therefore no longer valid.
 */
enum DDERR_EXPIRED = MAKE_DDHRESULT( 691 );

/*
 * The mode test has finished executing.
 */
enum DDERR_TESTFINISHED = MAKE_DDHRESULT( 692 );

/*
 * The mode test has switched to a new mode.
 */
enum DDERR_NEWMODE = MAKE_DDHRESULT( 693 );

/*
 * D3D has not yet been initialized.
 */
enum DDERR_D3DNOTINITIALIZED = MAKE_DDHRESULT( 694 );

/*
 * The video port is not active
 */
enum DDERR_VIDEONOTACTIVE = MAKE_DDHRESULT( 695 );

/*
 * The monitor does not have EDID data.
 */
enum DDERR_NOMONITORINFORMATION = MAKE_DDHRESULT( 696 );

/*
 * The driver does not enumerate display mode refresh rates.
 */
enum DDERR_NODRIVERSUPPORT = MAKE_DDHRESULT( 697 );

/*
 * Surfaces created by one direct draw device cannot be used directly by
 * another direct draw device.
 */
enum DDERR_DEVICEDOESNTOWNSURFACE = MAKE_DDHRESULT( 699 );



/*
 * An attempt was made to invoke an interface member of a DirectDraw object
 * created by CoCreateInstance() before it was initialized.
 */
enum DDERR_NOTINITIALIZED = CO_E_NOTINITIALIZED;