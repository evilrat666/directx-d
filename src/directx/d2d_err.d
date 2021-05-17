module directx.d2d_err;
import core.sys.windows.winerror : ERROR_INSUFFICIENT_BUFFER;
enum D2DERR_BAD_NUMBER = 0x88990011;
enum D2DERR_BITMAP_BOUND_AS_TARGET = 0x88990025L;
enum D2DERR_BITMAP_CANNOT_DRAW = 0x88990021L;
enum D2DERR_CYCLIC_GRAPH = 0x88990020L;
enum D2DERR_DISPLAY_FORMAT_NOT_SUPPORTED = 0x88990009;
enum D2DERR_DISPLAY_STATE_INVALID = 0x88990006;
enum D2DERR_EFFECT_IS_NOT_REGISTERED = 0x88990028L;
enum D2DERR_EXCEEDS_MAX_BITMAP_SIZE = 0x8899001D;
enum D2DERR_INCOMPATIBLE_BRUSH_TYPES = 0x88990018;
///The supplied buffer is too small to accommodate the data.
enum D2DERR_INSUFFICIENT_BUFFER = ERROR_INSUFFICIENT_BUFFER;
enum D2DERR_INSUFFICIENT_DEVICE_CAPABILITIES = 0x88990026L;
enum D2DERR_INTERMEDIATE_TOO_LARGE = 0x88990027L;
enum D2DERR_INTERNAL_ERROR = 0x88990008;
enum D2DERR_INVALID_CALL = 0x8899000A;
enum D2DERR_INVALID_GRAPH_CONFIGURATION = 0x8899001EL;
enum D2DERR_INVALID_INTERNAL_GRAPH_CONFIGURATION = 0x8899001FL;
enum D2DERR_INVALID_PROPERTY = 0x88990029L;
enum D2DERR_INVALID_TARGET = 0x88990024L;
enum D2DERR_LAYER_ALREADY_IN_USE = 0x88990013;
enum D2DERR_MAX_TEXTURE_SIZE_EXCEEDED = 0x8899000F;
enum D2DERR_NO_HARDWARE_DEVICE = 0x8899000B;
enum D2DERR_NO_SUBPROPERTIES = 0x8899002AL;
enum D2DERR_NOT_INITIALIZED = 0x88990002;
enum D2DERR_ORIGINAL_TARGET_NOT_BOUND = 0x88990023L;
enum D2DERR_OUTSTANDING_BITMAP_REFERENCES = 0x88990022L;
///The operation can't complete while you have outstanding references to the target bitmap.
enum D2DERR_POP_CALL_DID_NOT_MATCH_PUSH = 0x88990014;
///The application attempted to pop a layer off the stack when a clip was at the top, or pop a clip off the stack when a layer was at the top.
enum D2DERR_PRINT_FORMAT_NOT_SUPPORTED = 0x8899002CL;
///This error occurs during print control creation (ID2D1Device::CreatePrintControl) to indicate that the Direct2D print control (ID2D1PrintControl) can't support any of the package target types that represent printer formats.
enum D2DERR_PRINT_JOB_CLOSED = 0x8899002BL;
///The application called ID2D1PrintControl::AddPage or ID2D1PrintControl::Close after the print job is already finished.
enum D2DERR_PUSH_POP_UNBALANCED = 0x88990016;
///The application did not pop all clips and layers off the stack, or it attempted to pop too many clips or layers off the stack.
// enum D2DERR_RECREATE_TARGET = 0x8899000C;
///A presentation error has occurred that may be recoverable. The caller needs to re-create the render target then attempt to render the frame again.
enum D2DERR_RENDER_TARGET_HAS_LAYER_OR_CLIPRECT = 0x88990017;
///The requested operation cannot be performed until all layers and clips have been popped off the stack.
enum D2DERR_SCANNER_FAILED = 0x88990004;
///The geometry scanner failed to process the data.
enum D2DERR_SCREEN_ACCESS_DENIED = 0x88990005;
///Direct2D could not access the screen.
enum D2DERR_SHADER_COMPILE_FAILED = 0x8899000E;
///Shader compilation failed.
enum D2DERR_TARGET_NOT_GDI_COMPATIBLE = 0x8899001A;
///The render target is not compatible with GDI.
enum D2DERR_TEXT_EFFECT_IS_WRONG_TYPE = 0x8899001B;
///A text client drawing effect object is of the wrong type.
enum D2DERR_TEXT_RENDERER_NOT_RELEASED = 0x8899001C;
///An application is holding a reference to the IDWriteTextRenderer interface after the corresponding DrawTextor DrawTextLayout call has returned.
enum D2DERR_TOO_MANY_SHADER_ELEMENTS = 0x8899000D;
///Shader construction failed because it was too complex.
enum D2DERR_TOO_MANY_TRANSFORM_INPUTS = 0x8899002DL;
///An effect attempted to use a transform with too many inputs.
enum D2DERR_UNSUPPORTED_OPERATION = 0x88990003;
///The requested operation is not supported.
enum D2DERR_UNSUPPORTED_PIXEL_FORMAT = 0x88982F80;
///The pixel format is not supported.
enum D2DERR_UNSUPPORTED_VERSION = 0x88990010;
///The requested Direct2D version is not supported.
enum D2DERR_WIN32_ERROR = 0x88990019;
///An unknown Win32 failure occurred.
enum D2DERR_WRONG_FACTORY = 0x88990012;
///Objects used together were not all created from the same factory instance.
enum D2DERR_WRONG_RESOURCE_DOMAIN = 0x88990015;
///The resource used was created by a render target in a different resource domain.
enum D2DERR_WRONG_STATE = 0x88990001;
///The object was not in the correct state to process the method.
enum D2DERR_ZERO_VECTOR = 0x88990007;