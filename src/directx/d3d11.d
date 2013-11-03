module directx.d3d11;
/*-------------------------------------------------------------------------------------
 *
 * Copyright (c) Microsoft Corporation
 *
 *-------------------------------------------------------------------------------------*/
public import directx.d3d11contants;

import directx.dxgi;
import directx.d3dcommon;


enum _FACD3D11 = 0x87c;
enum _FACD3D11DEBUG	= _FACD3D11 + 1;

HRESULT MAKE_D3D11_HRESULT(T)(T code) {
	return MAKE_HRESULT(1, _FACD3D11, code);
}

HRESULT MAKE_D3D11_STATUS(T)(T code) {
	return MAKE_HRESULT(0, _FACD3D11, code);
}

alias D3D11_ERROR_TOO_MANY_UNIQUE_STATE_OBJECTS  MAKE_D3D11_HRESULT(1);
alias D3D11_ERROR_FILE_NOT_FOUND  MAKE_D3D11_HRESULT(2);
alias D3D11_ERROR_TOO_MANY_UNIQUE_VIEW_OBJECTS  MAKE_D3D11_HRESULT(3);
alias D3D11_ERROR_DEFERRED_CONTEXT_MAP_WITHOUT_INITIAL_DISCARD  MAKE_D3D11_HRESULT(4);

version(D3D11_HELPERS)
{
struct CD3D11_DEFAULT {};
extern(C) const(CD3D11_DEFAULT) D3D11_DEFAULT;
}

extern(C):

enum D3D11_INPUT_CLASSIFICATION
{
	D3D11_INPUT_PER_VERTEX_DATA = 0,
	D3D11_INPUT_PER_INSTANCE_DATA = 1
}

enum D3D11_APPEND_ALIGNED_ELEMENT = ( 0xffffffff );

struct D3D11_INPUT_ELEMENT_DESC
{
	LPCSTR SemanticName;
	UINT SemanticIndex;
	DXGI_FORMAT Format;
	UINT InputSlot;
	UINT AlignedByteOffset;
	D3D11_INPUT_CLASSIFICATION InputSlotClass;
	UINT InstanceDataStepRate;
}

enum D3D11_FILL_MODE
{
	D3D11_FILL_WIREFRAME	= 2,
	D3D11_FILL_SOLID	= 3
}

alias D3D11_PRIMITIVE_TOPOLOGY D3D_PRIMITIVE_TOPOLOGY;

alias D3D11_PRIMITIVE D3D_PRIMITIVE;


enum D3D11_CULL_MODE
{
	D3D11_CULL_NONE	= 1,
	D3D11_CULL_FRONT	= 2,
	D3D11_CULL_BACK	= 3
}

struct D3D11_SO_DECLARATION_ENTRY
{
	UINT Stream;
	LPCSTR SemanticName;
	UINT SemanticIndex;
	BYTE StartComponent;
	BYTE ComponentCount;
	BYTE OutputSlot;
}

struct D3D11_VIEWPORT
{
	FLOAT TopLeftX;
	FLOAT TopLeftY;
	FLOAT Width;
	FLOAT Height;
	FLOAT MinDepth;
	FLOAT MaxDepth;
}

enum D3D11_RESOURCE_DIMENSION
{
	D3D11_RESOURCE_DIMENSION_UNKNOWN	= 0,
	D3D11_RESOURCE_DIMENSION_BUFFER	= 1,
	D3D11_RESOURCE_DIMENSION_TEXTURE1D	= 2,
	D3D11_RESOURCE_DIMENSION_TEXTURE2D	= 3,
	D3D11_RESOURCE_DIMENSION_TEXTURE3D	= 4
}

alias D3D11_SRV_DIMENSION D3D_SRV_DIMENSION;


enum D3D11_DSV_DIMENSION
{
	D3D11_DSV_DIMENSION_UNKNOWN	= 0,
	D3D11_DSV_DIMENSION_TEXTURE1D	= 1,
	D3D11_DSV_DIMENSION_TEXTURE1DARRAY	= 2,
	D3D11_DSV_DIMENSION_TEXTURE2D	= 3,
	D3D11_DSV_DIMENSION_TEXTURE2DARRAY	= 4,
	D3D11_DSV_DIMENSION_TEXTURE2DMS	= 5,
	D3D11_DSV_DIMENSION_TEXTURE2DMSARRAY	= 6
}

enum D3D11_RTV_DIMENSION
{
	D3D11_RTV_DIMENSION_UNKNOWN	= 0,
	D3D11_RTV_DIMENSION_BUFFER	= 1,
	D3D11_RTV_DIMENSION_TEXTURE1D	= 2,
	D3D11_RTV_DIMENSION_TEXTURE1DARRAY	= 3,
	D3D11_RTV_DIMENSION_TEXTURE2D	= 4,
	D3D11_RTV_DIMENSION_TEXTURE2DARRAY	= 5,
	D3D11_RTV_DIMENSION_TEXTURE2DMS	= 6,
	D3D11_RTV_DIMENSION_TEXTURE2DMSARRAY	= 7,
	D3D11_RTV_DIMENSION_TEXTURE3D	= 8
}

enum D3D11_UAV_DIMENSION
{
	D3D11_UAV_DIMENSION_UNKNOWN	= 0,
	D3D11_UAV_DIMENSION_BUFFER	= 1,
	D3D11_UAV_DIMENSION_TEXTURE1D	= 2,
	D3D11_UAV_DIMENSION_TEXTURE1DARRAY	= 3,
	D3D11_UAV_DIMENSION_TEXTURE2D	= 4,
	D3D11_UAV_DIMENSION_TEXTURE2DARRAY	= 5,
	D3D11_UAV_DIMENSION_TEXTURE3D	= 8
}

enum D3D11_USAGE
{
	D3D11_USAGE_DEFAULT	= 0,
	D3D11_USAGE_IMMUTABLE	= 1,
	D3D11_USAGE_DYNAMIC	= 2,
	D3D11_USAGE_STAGING	= 3
}


enum D3D11_BIND_FLAG
{
	D3D11_BIND_VERTEX_BUFFER	= 0x1L,
	D3D11_BIND_INDEX_BUFFER	= 0x2L,
	D3D11_BIND_CONSTANT_BUFFER	= 0x4L,
	D3D11_BIND_SHADER_RESOURCE	= 0x8L,
	D3D11_BIND_STREAM_OUTPUT	= 0x10L,
	D3D11_BIND_RENDER_TARGET	= 0x20L,
	D3D11_BIND_DEPTH_STENCIL	= 0x40L,
	D3D11_BIND_UNORDERED_ACCESS	= 0x80L
}

enum D3D11_CPU_ACCESS_FLAG
{
	D3D11_CPU_ACCESS_WRITE	= 0x10000L,
	D3D11_CPU_ACCESS_READ	= 0x20000L
}

enum D3D11_RESOURCE_MISC_FLAG
{
	D3D11_RESOURCE_MISC_GENERATE_MIPS	= 0x1L,
	D3D11_RESOURCE_MISC_SHARED	= 0x2L,
	D3D11_RESOURCE_MISC_TEXTURECUBE	= 0x4L,
	D3D11_RESOURCE_MISC_DRAWINDIRECT_ARGS	= 0x10L,
	D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS	= 0x20L,
	D3D11_RESOURCE_MISC_BUFFER_STRUCTURED	= 0x40L,
	D3D11_RESOURCE_MISC_RESOURCE_CLAMP	= 0x80L,
	D3D11_RESOURCE_MISC_SHARED_KEYEDMUTEX	= 0x100L,
	D3D11_RESOURCE_MISC_GDI_COMPATIBLE	= 0x200L
}

enum D3D11_MAP
{
	D3D11_MAP_READ	= 1,
	D3D11_MAP_WRITE	= 2,
	D3D11_MAP_READ_WRITE	= 3,
	D3D11_MAP_WRITE_DISCARD	= 4,
	D3D11_MAP_WRITE_NO_OVERWRITE	= 5
}


enum D3D11_MAP_FLAG
{
	D3D11_MAP_FLAG_DO_NOT_WAIT	= 0x100000L
}

enum D3D11_RAISE_FLAG
{
	D3D11_RAISE_FLAG_DRIVER_INTERNAL_ERROR	= 0x1L
}


enum D3D11_CLEAR_FLAG
{
	D3D11_CLEAR_DEPTH	= 0x1L,
	D3D11_CLEAR_STENCIL	= 0x2L
}

alias D3D11_RECT RECT;

struct D3D11_BOX
{
	UINT left;
	UINT top;
	UINT front;
	UINT right;
	UINT bottom;
	UINT back;
}


mixin( uuid!(ID3D11DeviceChild, "1841e5c8-16b0-489b-bcc8-44cfb0d5deae") );
interface ID3D11DeviceChild : IUnknown
{
    extern(Windows):
	void GetDevice( 
				ID3D11Device* ppDevice);

	HRESULT  GetPrivateData( 
				REFGUID guid,
				UINT* pDataSize,
				void* pData);

	HRESULT SetPrivateData( 
				REFGUID guid,
				UINT DataSize,
				const void* pData);

	HRESULT SetPrivateDataInterface( 
				REFGUID guid,
				const(IUnknown) pData);
        
}
    


enum D3D11_COMPARISON_FUNC
{
	D3D11_COMPARISON_NEVER	= 1,
	D3D11_COMPARISON_LESS	= 2,
	D3D11_COMPARISON_EQUAL	= 3,
	D3D11_COMPARISON_LESS_EQUAL	= 4,
	D3D11_COMPARISON_GREATER	= 5,
	D3D11_COMPARISON_NOT_EQUAL	= 6,
	D3D11_COMPARISON_GREATER_EQUAL	= 7,
	D3D11_COMPARISON_ALWAYS	= 8
}

enum D3D11_DEPTH_WRITE_MASK
{
	D3D11_DEPTH_WRITE_MASK_ZERO	= 0,
	D3D11_DEPTH_WRITE_MASK_ALL	= 1
}

enum D3D11_STENCIL_OP
{
	D3D11_STENCIL_OP_KEEP	= 1,
	D3D11_STENCIL_OP_ZERO	= 2,
	D3D11_STENCIL_OP_REPLACE	= 3,
	D3D11_STENCIL_OP_INCR_SAT	= 4,
	D3D11_STENCIL_OP_DECR_SAT	= 5,
	D3D11_STENCIL_OP_INVERT	= 6,
	D3D11_STENCIL_OP_INCR	= 7,
	D3D11_STENCIL_OP_DECR	= 8
}

struct D3D11_DEPTH_STENCILOP_DESC
{
    D3D11_STENCIL_OP StencilFailOp;
    D3D11_STENCIL_OP StencilDepthFailOp;
    D3D11_STENCIL_OP StencilPassOp;
    D3D11_COMPARISON_FUNC StencilFunc;
} 	D3D11_DEPTH_STENCILOP_DESC;

struct D3D11_DEPTH_STENCIL_DESC
{
	BOOL DepthEnable;
	D3D11_DEPTH_WRITE_MASK DepthWriteMask;
	D3D11_COMPARISON_FUNC DepthFunc;
	BOOL StencilEnable;
	UINT8 StencilReadMask;
	UINT8 StencilWriteMask;
	D3D11_DEPTH_STENCILOP_DESC FrontFace;
	D3D11_DEPTH_STENCILOP_DESC BackFace;
}


mixin( uuid!(ID3D11DepthStencilState, "03823efb-8d8f-4e1c-9aa2-f64bb2cbfdf1") );
interface ID3D11DepthStencilState : ID3D11DeviceChild
{
	extern(Windows):
	void GetDesc( 
				D3D11_DEPTH_STENCIL_DESC* pDesc);
}


enum D3D11_BLEND
{
	D3D11_BLEND_ZERO	= 1,
	D3D11_BLEND_ONE	= 2,
	D3D11_BLEND_SRC_COLOR	= 3,
	D3D11_BLEND_INV_SRC_COLOR	= 4,
	D3D11_BLEND_SRC_ALPHA	= 5,
	D3D11_BLEND_INV_SRC_ALPHA	= 6,
	D3D11_BLEND_DEST_ALPHA	= 7,
	D3D11_BLEND_INV_DEST_ALPHA	= 8,
	D3D11_BLEND_DEST_COLOR	= 9,
	D3D11_BLEND_INV_DEST_COLOR	= 10,
	D3D11_BLEND_SRC_ALPHA_SAT	= 11,
	D3D11_BLEND_BLEND_FACTOR	= 14,
	D3D11_BLEND_INV_BLEND_FACTOR	= 15,
	D3D11_BLEND_SRC1_COLOR	= 16,
	D3D11_BLEND_INV_SRC1_COLOR	= 17,
	D3D11_BLEND_SRC1_ALPHA	= 18,
	D3D11_BLEND_INV_SRC1_ALPHA	= 19
}

enum D3D11_BLEND_OP
{
	D3D11_BLEND_OP_ADD	= 1,
	D3D11_BLEND_OP_SUBTRACT	= 2,
	D3D11_BLEND_OP_REV_SUBTRACT	= 3,
	D3D11_BLEND_OP_MIN	= 4,
	D3D11_BLEND_OP_MAX	= 5
}

enum D3D11_COLOR_WRITE_ENABLE
{
	D3D11_COLOR_WRITE_ENABLE_RED	= 1,
	D3D11_COLOR_WRITE_ENABLE_GREEN	= 2,
	D3D11_COLOR_WRITE_ENABLE_BLUE	= 4,
	D3D11_COLOR_WRITE_ENABLE_ALPHA	= 8,
	D3D11_COLOR_WRITE_ENABLE_ALL	= ( ( ( D3D11_COLOR_WRITE_ENABLE_RED | D3D11_COLOR_WRITE_ENABLE_GREEN )  | D3D11_COLOR_WRITE_ENABLE_BLUE )  | D3D11_COLOR_WRITE_ENABLE_ALPHA ) 
}

struct D3D11_RENDER_TARGET_BLEND_DESC
{
	BOOL BlendEnable;
	D3D11_BLEND SrcBlend;
	D3D11_BLEND DestBlend;
	D3D11_BLEND_OP BlendOp;
	D3D11_BLEND SrcBlendAlpha;
	D3D11_BLEND DestBlendAlpha;
	D3D11_BLEND_OP BlendOpAlpha;
	UINT8 RenderTargetWriteMask;
}

struct D3D11_BLEND_DESC
{
	BOOL AlphaToCoverageEnable;
	BOOL IndependentBlendEnable;
	D3D11_RENDER_TARGET_BLEND_DESC[8] RenderTarget;
}


mixin( uuid!(ID3D11BlendState, "75b68faa-347d-4159-8f45-a0640f01cd9a") );
interface ID3D11BlendState : ID3D11DeviceChild
{
	extern(Windows):
	void GetDesc( 
				D3D11_BLEND_DESC *pDesc);
}

struct D3D11_RASTERIZER_DESC
{
	D3D11_FILL_MODE FillMode;
	D3D11_CULL_MODE CullMode;
	BOOL FrontCounterClockwise;
	INT DepthBias;
	FLOAT DepthBiasClamp;
	FLOAT SlopeScaledDepthBias;
	BOOL DepthClipEnable;
	BOOL ScissorEnable;
	BOOL MultisampleEnable;
	BOOL AntialiasedLineEnable;
}


 mixin( uuid!(ID3D11RasterizerState, "9bb4ab81-ab1a-4d8f-b506-fc04200b6ee7") );
 interface ID3D11RasterizerState : ID3D11DeviceChild
 {
	extern(Windows):
	void GetDesc( 
				D3D11_RASTERIZER_DESC* pDesc);
}

struct D3D11_SUBRESOURCE_DATA
{
	const void* pSysMem;
	UINT SysMemPitch;
	UINT SysMemSlicePitch;
}

struct D3D11_MAPPED_SUBRESOURCE
{
	void* pData;
	UINT RowPitch;
	UINT DepthPitch;
}


mixin( uuid!(ID3D11Resource, "dc8e63f3-d12b-4952-b47b-5e45026a862d") );
interface ID3D11Resource : ID3D11DeviceChild
{
	extern(Windows):
	void GetType( 
				D3D11_RESOURCE_DIMENSION* pResourceDimension);

	void SetEvictionPriority( 
				UINT EvictionPriority);

	UINT GetEvictionPriority();
}
    
struct D3D11_BUFFER_DESC
{
	UINT ByteWidth;
	D3D11_USAGE Usage;
	UINT BindFlags;
	UINT CPUAccessFlags;
	UINT MiscFlags;
	UINT StructureByteStride;
}


mixin( uuid!(ID3D11Buffer, "48570b85-d1ee-4fcd-a250-eb350722b037") );
interface ID3D11Buffer : ID3D11Resource
{
	extern(Windows):
	void GetDesc( 
				D3D11_BUFFER_DESC* pDesc);
}
    
struct D3D11_TEXTURE1D_DESC
{
	UINT Width;
	UINT MipLevels;
	UINT ArraySize;
	DXGI_FORMAT Format;
	D3D11_USAGE Usage;
	UINT BindFlags;
	UINT CPUAccessFlags;
	UINT MiscFlags;
}


mixin( uuid!(ID3D11Texture1D, "f8fb5c27-c6b3-4f75-a4c8-439af2ef564c") );
interface ID3D11Texture1D : ID3D11Resource
{
	extern(Windows):
	void GetDesc( 
				D3D11_TEXTURE1D_DESC* pDesc);

}
    
struct D3D11_TEXTURE2D_DESC
{
	UINT Width;
	UINT Height;
	UINT MipLevels;
	UINT ArraySize;
	DXGI_FORMAT Format;
	DXGI_SAMPLE_DESC SampleDesc;
	D3D11_USAGE Usage;
	UINT BindFlags;
	UINT CPUAccessFlags;
	UINT MiscFlags;
}


mixin( uuid!(ID3D11Texture2D, "6f15aaf2-d208-4e89-9ab4-489535d34f9c") );
interface ID3D11Texture2D : ID3D11Resource
{
	extern(Windows):
	void GetDesc( 
				D3D11_TEXTURE2D_DESC* pDesc);
}
  
struct D3D11_TEXTURE3D_DESC
{
	UINT Width;
	UINT Height;
	UINT Depth;
	UINT MipLevels;
	DXGI_FORMAT Format;
	D3D11_USAGE Usage;
	UINT BindFlags;
	UINT CPUAccessFlags;
	UINT MiscFlags;
}


mixin( uuid!(ID3D11Texture3D, "037e866e-f56d-4357-a8af-9dabbe6e250e") );
interface ID3D11Texture3D : ID3D11Resource
{
	extern(Windows):
	void GetDesc( 
				D3D11_TEXTURE3D_DESC* pDesc);
}
    

enum D3D11_TEXTURECUBE_FACE
{
	D3D11_TEXTURECUBE_FACE_POSITIVE_X	= 0,
	D3D11_TEXTURECUBE_FACE_NEGATIVE_X	= 1,
	D3D11_TEXTURECUBE_FACE_POSITIVE_Y	= 2,
	D3D11_TEXTURECUBE_FACE_NEGATIVE_Y	= 3,
	D3D11_TEXTURECUBE_FACE_POSITIVE_Z	= 4,
	D3D11_TEXTURECUBE_FACE_NEGATIVE_Z	= 5
}


mixin( uuid!( ID3D11View, "839d1216-bb2e-412b-b7f4-a9dbebe08ed1") );
interface ID3D11View : ID3D11DeviceChild
{
	extern(Windows):
	void GetResource( 
				ID3D11Resource* ppResource);
}

    
struct D3D11_BUFFER_SRV
{
	union 
	{
		UINT FirstElement;
		UINT ElementOffset;
	}
	union 
	{
		UINT NumElements;
		UINT ElementWidth;
	}
}


enum D3D11_BUFFEREX_SRV_FLAG
{
	D3D11_BUFFEREX_SRV_FLAG_RAW	= 0x1
}


struct D3D11_BUFFEREX_SRV
{
	UINT FirstElement;
	UINT NumElements;
	UINT Flags;
}


struct D3D11_TEX1D_SRV
{
	UINT MostDetailedMip;
	UINT MipLevels;
}


struct D3D11_TEX1D_ARRAY_SRV
{
	UINT MostDetailedMip;
	UINT MipLevels;
	UINT FirstArraySlice;
	UINT ArraySize;
}

struct D3D11_TEX2D_SRV
{
	UINT MostDetailedMip;
	UINT MipLevels;
}

struct D3D11_TEX2D_ARRAY_SRV
{
	UINT MostDetailedMip;
	UINT MipLevels;
	UINT FirstArraySlice;
	UINT ArraySize;
}

struct D3D11_TEX3D_SRV
{
	UINT MostDetailedMip;
	UINT MipLevels;
}

struct D3D11_TEXCUBE_SRV
{
	UINT MostDetailedMip;
	UINT MipLevels;
}

struct D3D11_TEXCUBE_ARRAY_SRV
{
	UINT MostDetailedMip;
	UINT MipLevels;
	UINT First2DArrayFace;
	UINT NumCubes;
}

struct D3D11_TEX2DMS_SRV
{
	UINT UnusedField_NothingToDefine;
}

struct D3D11_TEX2DMS_ARRAY_SRV
{
	UINT FirstArraySlice;
	UINT ArraySize;
}

struct D3D11_SHADER_RESOURCE_VIEW_DESC
{
	DXGI_FORMAT Format;
	D3D11_SRV_DIMENSION ViewDimension;
	union 
	{
		D3D11_BUFFER_SRV Buffer;
		D3D11_TEX1D_SRV Texture1D;
		D3D11_TEX1D_ARRAY_SRV Texture1DArray;
		D3D11_TEX2D_SRV Texture2D;
		D3D11_TEX2D_ARRAY_SRV Texture2DArray;
		D3D11_TEX2DMS_SRV Texture2DMS;
		D3D11_TEX2DMS_ARRAY_SRV Texture2DMSArray;
		D3D11_TEX3D_SRV Texture3D;
		D3D11_TEXCUBE_SRV TextureCube;
		D3D11_TEXCUBE_ARRAY_SRV TextureCubeArray;
		D3D11_BUFFEREX_SRV BufferEx;
	}
}


mixin( uuid!(ID3D11ShaderResourceView, "b0e06fe0-8192-4e1a-b1ca-36d7414710b2") );
interface ID3D11ShaderResourceView : ID3D11View
{
	extern(Windows):
	void GetDesc( 
				D3D11_SHADER_RESOURCE_VIEW_DESC* pDesc);
}


struct D3D11_BUFFER_RTV
{
	union 
    {
		UINT FirstElement;
		UINT ElementOffset;
	}
    union 
	{
		UINT NumElements;
		UINT ElementWidth;
	}
}

struct D3D11_TEX1D_RTV
{
	UINT MipSlice;
}

struct D3D11_TEX1D_ARRAY_RTV
{
	UINT MipSlice;
	UINT FirstArraySlice;
	UINT ArraySize;
}

struct D3D11_TEX2D_RTV
{
	UINT MipSlice;
}

struct D3D11_TEX2DMS_RTV
{
	UINT UnusedField_NothingToDefine;
}

struct D3D11_TEX2D_ARRAY_RTV
{
	UINT MipSlice;
	UINT FirstArraySlice;
	UINT ArraySize;
}

struct D3D11_TEX2DMS_ARRAY_RTV
{
	UINT FirstArraySlice;
	UINT ArraySize;
}

struct D3D11_TEX3D_RTV
{
	UINT MipSlice;
	UINT FirstWSlice;
	UINT WSize;
}

struct D3D11_RENDER_TARGET_VIEW_DESC
{
	DXGI_FORMAT Format;
	D3D11_RTV_DIMENSION ViewDimension;
	union 
	{
		D3D11_BUFFER_RTV Buffer;
		D3D11_TEX1D_RTV Texture1D;
		D3D11_TEX1D_ARRAY_RTV Texture1DArray;
		D3D11_TEX2D_RTV Texture2D;
		D3D11_TEX2D_ARRAY_RTV Texture2DArray;
		D3D11_TEX2DMS_RTV Texture2DMS;
		D3D11_TEX2DMS_ARRAY_RTV Texture2DMSArray;
		D3D11_TEX3D_RTV Texture3D;
	}
}


mixin( uuid!(ID3D11RenderTargetView, "dfdba067-0b8d-4865-875b-d7b4516cc164") );
interface ID3D11RenderTargetView : ID3D11View
{
	extern(Windows):
	void GetDesc( 
				D3D11_RENDER_TARGET_VIEW_DESC* pDesc);
}
    
struct D3D11_TEX1D_DSV
{
	UINT MipSlice;
}

struct D3D11_TEX1D_ARRAY_DSV
{
	UINT MipSlice;
	UINT FirstArraySlice;
	UINT ArraySize;
}

struct D3D11_TEX2D_DSV
{
	UINT MipSlice;
}

struct D3D11_TEX2D_ARRAY_DSV
{
	UINT MipSlice;
	UINT FirstArraySlice;
	UINT ArraySize;
}

struct D3D11_TEX2DMS_DSV
{
	UINT UnusedField_NothingToDefine;
}

struct D3D11_TEX2DMS_ARRAY_DSV
{
	UINT FirstArraySlice;
	UINT ArraySize;
}


enum D3D11_DSV_FLAG
{
	D3D11_DSV_READ_ONLY_DEPTH	= 0x1L,
	D3D11_DSV_READ_ONLY_STENCIL	= 0x2L
}

struct D3D11_DEPTH_STENCIL_VIEW_DESC
{
	DXGI_FORMAT Format;
	D3D11_DSV_DIMENSION ViewDimension;
	UINT Flags;
	union 
	{
		D3D11_TEX1D_DSV Texture1D;
		D3D11_TEX1D_ARRAY_DSV Texture1DArray;
		D3D11_TEX2D_DSV Texture2D;
		D3D11_TEX2D_ARRAY_DSV Texture2DArray;
		D3D11_TEX2DMS_DSV Texture2DMS;
		D3D11_TEX2DMS_ARRAY_DSV Texture2DMSArray;
	}
}


mixin( uuid!(ID3D11DepthStencilView, "9fdac92a-1876-48c3-afad-25b94f84a9b6") );
interface ID3D11DepthStencilView : ID3D11View
{
	extern(Windows);
    void GetDesc( 
				D3D11_DEPTH_STENCIL_VIEW_DESC* pDesc);
}
  

enum D3D11_BUFFER_UAV_FLAG
{
	D3D11_BUFFER_UAV_FLAG_RAW	= 0x1,
	D3D11_BUFFER_UAV_FLAG_APPEND	= 0x2,
	D3D11_BUFFER_UAV_FLAG_COUNTER	= 0x4
}

struct D3D11_BUFFER_UAV
{
	UINT FirstElement;
	UINT NumElements;
	UINT Flags;
}

struct D3D11_TEX1D_UAV
{
    UINT MipSlice;
}

struct D3D11_TEX1D_ARRAY_UAV
{
	UINT MipSlice;
	UINT FirstArraySlice;
	UINT ArraySize;
}

struct D3D11_TEX2D_UAV
{
	UINT MipSlice;
}

struct D3D11_TEX2D_ARRAY_UAV
{
	UINT MipSlice;
	UINT FirstArraySlice;
	UINT ArraySize;
}

struct D3D11_TEX3D_UAV
{
	UINT MipSlice;
	UINT FirstWSlice;
	UINT WSize;
}

struct D3D11_UNORDERED_ACCESS_VIEW_DESC
{
	DXGI_FORMAT Format;
	D3D11_UAV_DIMENSION ViewDimension;
	union 
	{
		D3D11_BUFFER_UAV Buffer;
		D3D11_TEX1D_UAV Texture1D;
		D3D11_TEX1D_ARRAY_UAV Texture1DArray;
		D3D11_TEX2D_UAV Texture2D;
		D3D11_TEX2D_ARRAY_UAV Texture2DArray;
		D3D11_TEX3D_UAV Texture3D;
	}
}


mixin( uuid!( ID3D11UnorderedAccessView, "28acf509-7f5c-48f6-8611-f316010a6380") );
interface ID3D11UnorderedAccessView : ID3D11View
{
	extern(Windows):
	void GetDesc( 
				D3D11_UNORDERED_ACCESS_VIEW_DESC* pDesc);
}
   

mixin( uuid!(ID3D11VertexShader, "3b301d64-d678-4289-8897-22f8928b72f3") );
interface ID3D11VertexShader : ID3D11DeviceChild
{
	extern(Windows):
}
    

mixin( uuid!(ID3D11HullShader, "8e5c6061-628a-4c8e-8264-bbe45cb3d5dd") );
interface ID3D11HullShader : ID3D11DeviceChild
{
	extern(Windows):
}


mixin( uuid!(ID3D11DomainShader, "f582c508-0f36-490c-9977-31eece268cfa") );
interface ID3D11DomainShader : ID3D11DeviceChild
{
	extern(Windows):
}


mixin( uuid!( ID3D11GeometryShader, "38325b96-effb-4022-ba02-2e795b70275c") );
interface ID3D11GeometryShader : ID3D11DeviceChild
{
	extern(Windows):
}


mixin( uuid!(ID3D11PixelShader, "ea82e40d-51dc-4f33-93d4-db7c9125ae8c") );
interface ID3D11PixelShader : ID3D11DeviceChild
{
	extern(Windows):
}


mixin( uuid!( ID3D11ComputeShader, "4f5b196e-c2bd-495e-bd01-1fded38e4969") );
interface ID3D11ComputeShader : ID3D11DeviceChild
{
	extern(Windows):
}


mixin( uuid!( ID3D11InputLayout, "e4819ddc-4cf0-4025-bd26-5de82a3e07b7") );
interface ID3D11InputLayout : ID3D11DeviceChild
{
	extern(Windows):
}


enum D3D11_FILTER
{
	D3D11_FILTER_MIN_MAG_MIP_POINT	= 0,
	D3D11_FILTER_MIN_MAG_POINT_MIP_LINEAR	= 0x1,
	D3D11_FILTER_MIN_POINT_MAG_LINEAR_MIP_POINT	= 0x4,
	D3D11_FILTER_MIN_POINT_MAG_MIP_LINEAR	= 0x5,
	D3D11_FILTER_MIN_LINEAR_MAG_MIP_POINT	= 0x10,
	D3D11_FILTER_MIN_LINEAR_MAG_POINT_MIP_LINEAR	= 0x11,
	D3D11_FILTER_MIN_MAG_LINEAR_MIP_POINT	= 0x14,
	D3D11_FILTER_MIN_MAG_MIP_LINEAR	= 0x15,
	D3D11_FILTER_ANISOTROPIC	= 0x55,
	D3D11_FILTER_COMPARISON_MIN_MAG_MIP_POINT	= 0x80,
	D3D11_FILTER_COMPARISON_MIN_MAG_POINT_MIP_LINEAR	= 0x81,
	D3D11_FILTER_COMPARISON_MIN_POINT_MAG_LINEAR_MIP_POINT	= 0x84,
	D3D11_FILTER_COMPARISON_MIN_POINT_MAG_MIP_LINEAR	= 0x85,
	D3D11_FILTER_COMPARISON_MIN_LINEAR_MAG_MIP_POINT	= 0x90,
	D3D11_FILTER_COMPARISON_MIN_LINEAR_MAG_POINT_MIP_LINEAR	= 0x91,
	D3D11_FILTER_COMPARISON_MIN_MAG_LINEAR_MIP_POINT	= 0x94,
	D3D11_FILTER_COMPARISON_MIN_MAG_MIP_LINEAR	= 0x95,
	D3D11_FILTER_COMPARISON_ANISOTROPIC	= 0xd5
}


enum D3D11_FILTER_TYPE
{
	D3D11_FILTER_TYPE_POINT	= 0,
	D3D11_FILTER_TYPE_LINEAR	= 1
}

enum D3D11_FILTER_TYPE_MASK = ( 0x3 );
enum D3D11_MIN_FILTER_SHIFT = ( 4 );
enum D3D11_MAG_FILTER_SHIFT = ( 2 );
enum D3D11_MIP_FILTER_SHIFT = ( 0 );
enum D3D11_COMPARISON_FILTERING_BIT = ( 0x80 );
enum D3D11_ANISOTROPIC_FILTERING_BIT = ( 0x40 );

D3D11_FILTER D3D11_ENCODE_BASIC_FILTER(T0, T1, T2, T3)( T0 min, T1 mag, T2 mip, T3 bComparison ){
    return ( cast( D3D11_FILTER ) (                                                   
    ( ( bComparison ) ? D3D11_COMPARISON_FILTERING_BIT : 0 ) |             
    ( ( ( min ) & D3D11_FILTER_TYPE_MASK ) << D3D11_MIN_FILTER_SHIFT ) |   
    ( ( ( mag ) & D3D11_FILTER_TYPE_MASK ) << D3D11_MAG_FILTER_SHIFT ) |
    ( ( ( mip ) & D3D11_FILTER_TYPE_MASK ) << D3D11_MIP_FILTER_SHIFT ) ) );
}

D3D11_FILTER D3D11_ENCODE_ANISOTROPIC_FILTER(T)(T bComparison ){
    return ( cast( D3D11_FILTER ) (
    D3D11_ANISOTROPIC_FILTERING_BIT |
    D3D11_ENCODE_BASIC_FILTER( D3D11_FILTER_TYPE.D3D11_FILTER_TYPE_LINEAR,
                            D3D11_FILTER_TYPE.D3D11_FILTER_TYPE_LINEAR,
                            D3D11_FILTER_TYPE.D3D11_FILTER_TYPE_LINEAR,
                            bComparison )));
}


D3D11_FILTER_TYPE D3D11_DECODE_MAG_FILTER(T)( d3d11Filter ){
    return ( cast( D3D11_FILTER_TYPE )
            ( ( ( d3d11Filter ) >> D3D11_MAG_FILTER_SHIFT ) & D3D11_FILTER_TYPE_MASK ) ) ;
}


D3D11_FILTER_TYPE D3D11_DECODE_MIN_FILTER(T)(T d3d11Filter ){                                                             
    return ( cast( D3D11_FILTER_TYPE )                                                    
            ( ( ( d3d11Filter ) >> D3D11_MIN_FILTER_SHIFT ) & D3D11_FILTER_TYPE_MASK ) );
}
    
bool D3D11_DECODE_IS_COMPARISON_FILTER(T)(T d3d11Filter ){
    return cast(bool)( ( d3d11Filter ) & D3D11_COMPARISON_FILTERING_BIT );
}
bool D3D11_DECODE_IS_ANISOTROPIC_FILTER(T)(T d3d11Filter ){
    return cast(bool)( ( ( d3d11Filter ) & D3D11_ANISOTROPIC_FILTERING_BIT ) &&
                      ( D3D11_FILTER_TYPE.D3D11_FILTER_TYPE_LINEAR == D3D11_DECODE_MIN_FILTER( d3d11Filter ) ) &&
                      ( D3D11_FILTER_TYPE.D3D11_FILTER_TYPE_LINEAR == D3D11_DECODE_MAG_FILTER( d3d11Filter ) ) &&
                      ( D3D11_FILTER_TYPE.D3D11_FILTER_TYPE_LINEAR == D3D11_DECODE_MIP_FILTER( d3d11Filter ) ) );
}

							
enum D3D11_TEXTURE_ADDRESS_MODE
{
	D3D11_TEXTURE_ADDRESS_WRAP	= 1,
	D3D11_TEXTURE_ADDRESS_MIRROR	= 2,
	D3D11_TEXTURE_ADDRESS_CLAMP	= 3,
	D3D11_TEXTURE_ADDRESS_BORDER	= 4,
	D3D11_TEXTURE_ADDRESS_MIRROR_ONCE	= 5
}

struct D3D11_SAMPLER_DESC
{
	D3D11_FILTER Filter;
	D3D11_TEXTURE_ADDRESS_MODE AddressU;
	D3D11_TEXTURE_ADDRESS_MODE AddressV;
	D3D11_TEXTURE_ADDRESS_MODE AddressW;
	FLOAT MipLODBias;
	UINT MaxAnisotropy;
	D3D11_COMPARISON_FUNC ComparisonFunc;
	FLOAT[ 4 ] BorderColor;
	FLOAT MinLOD;
	FLOAT MaxLOD;
}

	
mixin( uuid!( ID3D11SamplerState, "da6fea51-564c-4487-9810-f0d0f9b4e3a5") );
interface ID3D11SamplerState : ID3D11DeviceChild
{
	extern(Windows):
	void GetDesc( 
				D3D11_SAMPLER_DESC* pDesc);
}
    

enum D3D11_FORMAT_SUPPORT
{
	D3D11_FORMAT_SUPPORT_BUFFER	= 0x1,
	D3D11_FORMAT_SUPPORT_IA_VERTEX_BUFFER	= 0x2,
	D3D11_FORMAT_SUPPORT_IA_INDEX_BUFFER	= 0x4,
	D3D11_FORMAT_SUPPORT_SO_BUFFER	= 0x8,
	D3D11_FORMAT_SUPPORT_TEXTURE1D	= 0x10,
	D3D11_FORMAT_SUPPORT_TEXTURE2D	= 0x20,
	D3D11_FORMAT_SUPPORT_TEXTURE3D	= 0x40,
	D3D11_FORMAT_SUPPORT_TEXTURECUBE	= 0x80,
	D3D11_FORMAT_SUPPORT_SHADER_LOAD	= 0x100,
	D3D11_FORMAT_SUPPORT_SHADER_SAMPLE	= 0x200,
	D3D11_FORMAT_SUPPORT_SHADER_SAMPLE_COMPARISON	= 0x400,
	D3D11_FORMAT_SUPPORT_SHADER_SAMPLE_MONO_TEXT	= 0x800,
	D3D11_FORMAT_SUPPORT_MIP	= 0x1000,
	D3D11_FORMAT_SUPPORT_MIP_AUTOGEN	= 0x2000,
	D3D11_FORMAT_SUPPORT_RENDER_TARGET	= 0x4000,
	D3D11_FORMAT_SUPPORT_BLENDABLE	= 0x8000,
	D3D11_FORMAT_SUPPORT_DEPTH_STENCIL	= 0x10000,
	D3D11_FORMAT_SUPPORT_CPU_LOCKABLE	= 0x20000,
	D3D11_FORMAT_SUPPORT_MULTISAMPLE_RESOLVE	= 0x40000,
	D3D11_FORMAT_SUPPORT_DISPLAY	= 0x80000,
	D3D11_FORMAT_SUPPORT_CAST_WITHIN_BIT_LAYOUT	= 0x100000,
	D3D11_FORMAT_SUPPORT_MULTISAMPLE_RENDERTARGET	= 0x200000,
	D3D11_FORMAT_SUPPORT_MULTISAMPLE_LOAD	= 0x400000,
	D3D11_FORMAT_SUPPORT_SHADER_GATHER	= 0x800000,
	D3D11_FORMAT_SUPPORT_BACK_BUFFER_CAST	= 0x1000000,
	D3D11_FORMAT_SUPPORT_TYPED_UNORDERED_ACCESS_VIEW	= 0x2000000,
	D3D11_FORMAT_SUPPORT_SHADER_GATHER_COMPARISON	= 0x4000000
}


enum D3D11_FORMAT_SUPPORT2
{
	D3D11_FORMAT_SUPPORT2_UAV_ATOMIC_ADD	= 0x1,
	D3D11_FORMAT_SUPPORT2_UAV_ATOMIC_BITWISE_OPS	= 0x2,
	D3D11_FORMAT_SUPPORT2_UAV_ATOMIC_COMPARE_STORE_OR_COMPARE_EXCHANGE	= 0x4,
	D3D11_FORMAT_SUPPORT2_UAV_ATOMIC_EXCHANGE	= 0x8,
	D3D11_FORMAT_SUPPORT2_UAV_ATOMIC_SIGNED_MIN_OR_MAX	= 0x10,
	D3D11_FORMAT_SUPPORT2_UAV_ATOMIC_UNSIGNED_MIN_OR_MAX	= 0x20,
	D3D11_FORMAT_SUPPORT2_UAV_TYPED_LOAD	= 0x40,
	D3D11_FORMAT_SUPPORT2_UAV_TYPED_STORE	= 0x80
}


mixin( uuid!(ID3D11Asynchronous, "4b35d0cd-1e15-4258-9c98-1b1333f6dd3b") );
interface ID3D11Asynchronous : ID3D11DeviceChild
{
	extern(Windows):
				UINT GetDataSize();
}
    

enum D3D11_ASYNC_GETDATA_FLAG
{
	D3D11_ASYNC_GETDATA_DONOTFLUSH	= 0x1
}


enum D3D11_QUERY
{
	D3D11_QUERY_EVENT	= 0,
	D3D11_QUERY_OCCLUSION	= ( D3D11_QUERY_EVENT + 1 ) ,
	D3D11_QUERY_TIMESTAMP	= ( D3D11_QUERY_OCCLUSION + 1 ) ,
	D3D11_QUERY_TIMESTAMP_DISJOINT	= ( D3D11_QUERY_TIMESTAMP + 1 ) ,
	D3D11_QUERY_PIPELINE_STATISTICS	= ( D3D11_QUERY_TIMESTAMP_DISJOINT + 1 ) ,
	D3D11_QUERY_OCCLUSION_PREDICATE	= ( D3D11_QUERY_PIPELINE_STATISTICS + 1 ) ,
	D3D11_QUERY_SO_STATISTICS	= ( D3D11_QUERY_OCCLUSION_PREDICATE + 1 ) ,
	D3D11_QUERY_SO_OVERFLOW_PREDICATE	= ( D3D11_QUERY_SO_STATISTICS + 1 ) ,
	D3D11_QUERY_SO_STATISTICS_STREAM0	= ( D3D11_QUERY_SO_OVERFLOW_PREDICATE + 1 ) ,
	D3D11_QUERY_SO_OVERFLOW_PREDICATE_STREAM0	= ( D3D11_QUERY_SO_STATISTICS_STREAM0 + 1 ) ,
	D3D11_QUERY_SO_STATISTICS_STREAM1	= ( D3D11_QUERY_SO_OVERFLOW_PREDICATE_STREAM0 + 1 ) ,
	D3D11_QUERY_SO_OVERFLOW_PREDICATE_STREAM1	= ( D3D11_QUERY_SO_STATISTICS_STREAM1 + 1 ) ,
	D3D11_QUERY_SO_STATISTICS_STREAM2	= ( D3D11_QUERY_SO_OVERFLOW_PREDICATE_STREAM1 + 1 ) ,
	D3D11_QUERY_SO_OVERFLOW_PREDICATE_STREAM2	= ( D3D11_QUERY_SO_STATISTICS_STREAM2 + 1 ) ,
	D3D11_QUERY_SO_STATISTICS_STREAM3	= ( D3D11_QUERY_SO_OVERFLOW_PREDICATE_STREAM2 + 1 ) ,
	D3D11_QUERY_SO_OVERFLOW_PREDICATE_STREAM3	= ( D3D11_QUERY_SO_STATISTICS_STREAM3 + 1 ) 
}


enum D3D11_QUERY_MISC_FLAG
{
	D3D11_QUERY_MISC_PREDICATEHINT	= 0x1
}

struct D3D11_QUERY_DESC
{
	D3D11_QUERY Query;
	UINT MiscFlags;
}

	
mixin( uuid!(ID3D11Query, "d6c00747-87b7-425e-b84d-44d108560afd") );
interface ID3D11Query : ID3D11Asynchronous
{
	extern(Windows):
	void GetDesc( 
				D3D11_QUERY_DESC* pDesc);
}


mixin( uuid!(ID3D11Predicate, "9eb576dd-9f77-4d86-81aa-8bab5fe490e2") );
interface ID3D11Predicate : ID3D11Query
{
	extern(Windows):
}
    

struct D3D11_QUERY_DATA_TIMESTAMP_DISJOINT
{
	UINT64 Frequency;
	BOOL Disjoint;
}

struct D3D11_QUERY_DATA_PIPELINE_STATISTICS
{
	UINT64 IAVertices;
	UINT64 IAPrimitives;
	UINT64 VSInvocations;
	UINT64 GSInvocations;
	UINT64 GSPrimitives;
	UINT64 CInvocations;
	UINT64 CPrimitives;
	UINT64 PSInvocations;
	UINT64 HSInvocations;
	UINT64 DSInvocations;
	UINT64 CSInvocations;
}

struct D3D11_QUERY_DATA_SO_STATISTICS
{
	UINT64 NumPrimitivesWritten;
	UINT64 PrimitivesStorageNeeded;
}


enum D3D11_COUNTER
{
	D3D11_COUNTER_DEVICE_DEPENDENT_0	= 0x40000000
}


enum D3D11_COUNTER_TYPE
{
	D3D11_COUNTER_TYPE_FLOAT32	= 0,
	D3D11_COUNTER_TYPE_UINT16	= ( D3D11_COUNTER_TYPE_FLOAT32 + 1 ) ,
	D3D11_COUNTER_TYPE_UINT32	= ( D3D11_COUNTER_TYPE_UINT16 + 1 ) ,
	D3D11_COUNTER_TYPE_UINT64	= ( D3D11_COUNTER_TYPE_UINT32 + 1 ) 
}

struct D3D11_COUNTER_DESC
{
	D3D11_COUNTER Counter;
	UINT MiscFlags;
}

	
struct D3D11_COUNTER_INFO
{
	D3D11_COUNTER LastDeviceDependentCounter;
	UINT NumSimultaneousCounters;
	UINT8 NumDetectableParallelUnits;
}


mixin( uuid!(ID3D11Counter, "6e8c49fb-a371-4770-b440-29086022b741") );
interface ID3D11Counter : ID3D11Asynchronous
{
	extern(Windows):
	void GetDesc( 
				D3D11_COUNTER_DESC* pDesc);
}


enum D3D11_STANDARD_MULTISAMPLE_QUALITY_LEVELS
{	
	D3D11_STANDARD_MULTISAMPLE_PATTERN	= 0xffffffff,
	D3D11_CENTER_MULTISAMPLE_PATTERN	= 0xfffffffe
}


enum D3D11_DEVICE_CONTEXT_TYPE
{
	D3D11_DEVICE_CONTEXT_IMMEDIATE	= 0,
	D3D11_DEVICE_CONTEXT_DEFERRED	= ( D3D11_DEVICE_CONTEXT_IMMEDIATE + 1 ) 
}

struct D3D11_CLASS_INSTANCE_DESC
{
	UINT InstanceId;
	UINT InstanceIndex;
	UINT TypeId;
	UINT ConstantBuffer;
	UINT BaseConstantBufferOffset;
	UINT BaseTexture;
	UINT BaseSampler;
	BOOL Created;
}


mixin( uuid!(ID3D11ClassInstance, "a6cd7faa-b0b7-4a2f-9436-8662a65797cb") );
interface ID3D11ClassInstance : ID3D11DeviceChild
{
	extern(Windows):
	void GetClassLinkage( 
				ID3D11ClassLinkage* ppLinkage);

	void GetDesc( 
				D3D11_CLASS_INSTANCE_DESC* pDesc);
        
	void GetInstanceName( 
				LPSTR pInstanceName,
				SIZE_T* pBufferLength);

	void GetTypeName( 
				LPSTR pTypeName,
				SIZE_T* pBufferLength);
}
    

mixin( uuid!(ID3D11ClassLinkage, "ddf57cba-9543-46e4-a12b-f207a0fe7fed") );
interface ID3D11ClassLinkage : ID3D11DeviceChild
{
	extern(Windows):
	HRESULT GetClassInstance( 
				LPCSTR pClassInstanceName,
				UINT InstanceIndex,
				ID3D11ClassInstance* ppInstance);

	HRESULT CreateClassInstance( 
				LPCSTR pClassTypeName,
				UINT ConstantBufferOffset,
				UINT ConstantVectorOffset,
				UINT TextureOffset,
				UINT SamplerOffset,
				ID3D11ClassInstance* ppInstance);
}
    

mixin( uuid!(ID3D11CommandList, "a24bc4d1-769e-43f7-8013-98ff566c18e2") );
interface ID3D11CommandList : ID3D11DeviceChild
{
	extern(Windows):
				UINT GetContextFlags();
}
    

enum D3D11_FEATURE
{
	D3D11_FEATURE_THREADING	= 0,
	D3D11_FEATURE_DOUBLES	= ( D3D11_FEATURE_THREADING + 1 ) ,
	D3D11_FEATURE_FORMAT_SUPPORT	= ( D3D11_FEATURE_DOUBLES + 1 ) ,
	D3D11_FEATURE_FORMAT_SUPPORT2	= ( D3D11_FEATURE_FORMAT_SUPPORT + 1 ) ,
	D3D11_FEATURE_D3D10_X_HARDWARE_OPTIONS	= ( D3D11_FEATURE_FORMAT_SUPPORT2 + 1 ) 
}

struct D3D11_FEATURE_DATA_THREADING
{
    BOOL DriverConcurrentCreates;
    BOOL DriverCommandLists;
}

struct D3D11_FEATURE_DATA_DOUBLES
{
	BOOL DoublePrecisionFloatShaderOps;
}

struct D3D11_FEATURE_DATA_FORMAT_SUPPORT
{
	DXGI_FORMAT InFormat;
	UINT OutFormatSupport;
}

struct D3D11_FEATURE_DATA_FORMAT_SUPPORT2
{
	DXGI_FORMAT InFormat;
	UINT OutFormatSupport2;
}

struct D3D11_FEATURE_DATA_D3D10_X_HARDWARE_OPTIONS
{
	BOOL ComputeShaders_Plus_RawAndStructuredBuffers_Via_Shader_4_x;
}


mixin( uuid!(ID3D11DeviceContext, "c0bfa96c-e089-44fb-8eaf-26f8796190da") );
interface ID3D11DeviceContext : ID3D11DeviceChild
{
	extern(Windows):
	void VSSetConstantBuffers( 
				UINT StartSlot,
				UINT NumBuffers,
				const(ID3D11Buffer)* ppConstantBuffers);

	void PSSetShaderResources( 
				UINT StartSlot,
				UINT NumViews,
				const(ID3D11ShaderResourceView)* ppShaderResourceViews);
        
	void PSSetShader( 
				ID3D11PixelShader pPixelShader,
				const(ID3D11ClassInstance)* ppClassInstances,
				UINT NumClassInstances);
        
	void PSSetSamplers( 
				UINT StartSlot,
				UINT NumSamplers,
				const(ID3D11SamplerState)* ppSamplers);
        
	void VSSetShader( 
				ID3D11VertexShader pVertexShader,
				const(ID3D11ClassInstance)* ppClassInstances,
				UINT NumClassInstances);
        
	void DrawIndexed( 
				UINT IndexCount,
				UINT StartIndexLocation,
				INT BaseVertexLocation);

	void Draw( 
				UINT VertexCount,
				UINT StartVertexLocation);

	HRESULT Map( 
				ID3D11Resource pResource,
				UINT Subresource,
				D3D11_MAP MapType,
				UINT MapFlags,
				D3D11_MAPPED_SUBRESOURCE* pMappedResource);

	void Unmap( 
				ID3D11Resource* pResource,
				UINT Subresource);

	void PSSetConstantBuffers( 
				UINT StartSlot,
				UINT NumBuffers,
				const(ID3D11Buffer)* ppConstantBuffers);

	void IASetInputLayout( 
				ID3D11InputLayout* pInputLayout);

	void IASetVertexBuffers( 
				UINT StartSlot,
				UINT NumBuffers,
				const(ID3D11Buffer)* ppVertexBuffers,
				const UINT* pStrides,
				const UINT* pOffsets);

	void IASetIndexBuffer( 
				ID3D11Buffer* pIndexBuffer,
				DXGI_FORMAT Format,
				UINT Offset);

	void DrawIndexedInstanced( 
				UINT IndexCountPerInstance,
				UINT InstanceCount,
				UINT StartIndexLocation,
				INT BaseVertexLocation,
				UINT StartInstanceLocation);

	void DrawInstanced( 
				UINT VertexCountPerInstance,
				UINT InstanceCount,
				UINT StartVertexLocation,
				UINT StartInstanceLocation);

	void GSSetConstantBuffers( 
				UINT StartSlot,
				UINT NumBuffers,
				const(ID3D11Buffer)* ppConstantBuffers);

	void GSSetShader( 
				ID3D11GeometryShader pShader,
				const(ID3D11ClassInstance)* ppClassInstances,
				UINT NumClassInstances);

	void IASetPrimitiveTopology( 
				D3D11_PRIMITIVE_TOPOLOGY Topology);

	void VSSetShaderResources( 
				UINT StartSlot,
				UINT NumViews,
				const(ID3D11ShaderResourceView)* ppShaderResourceViews);

	void VSSetSamplers( 
				UINT StartSlot,
				UINT NumSamplers,
				const(ID3D11SamplerState)* ppSamplers);

	void Begin( 
				ID3D11Asynchronous pAsync);

	void End( 
				ID3D11Asynchronous pAsync);
        
	HRESULT GetData( 
				ID3D11Asynchronous pAsync,
				void* pData,
				UINT DataSize,
				UINT GetDataFlags);

	void SetPredication( 
				ID3D11Predicate pPredicate,
				BOOL PredicateValue);

	void GSSetShaderResources( 
				UINT StartSlot,
				UINT NumViews,
				const(ID3D11ShaderResourceView)* ppShaderResourceViews);

	void GSSetSamplers( 
				UINT StartSlot,
				UINT NumSamplers,
				const(ID3D11SamplerState)* ppSamplers);

	void OMSetRenderTargets( 
				UINT NumViews,
				const(ID3D11RenderTargetView)* ppRenderTargetViews,
				ID3D11DepthStencilView pDepthStencilView);

	void OMSetRenderTargetsAndUnorderedAccessViews( 
				UINT NumRTVs,
				const(ID3D11RenderTargetView)* ppRenderTargetViews,
				ID3D11DepthStencilView pDepthStencilView,
				UINT UAVStartSlot,
				UINT NumUAVs,
				const(ID3D11UnorderedAccessView)* ppUnorderedAccessViews,
				const(UINT)* pUAVInitialCounts);

	void OMSetBlendState( 
				ID3D11BlendState pBlendState,
				FLOAT[ 4 ] BlendFactor,
				UINT SampleMask);

	void OMSetDepthStencilState( 
				ID3D11DepthStencilState pDepthStencilState,
				UINT StencilRef);

	void SOSetTargets( 
				UINT NumBuffers,
				const(ID3D11Buffer)* ppSOTargets,
				const(UINT)* pOffsets);

	void DrawAuto();

	void DrawIndexedInstancedIndirect( 
				ID3D11Buffer pBufferForArgs,
				UINT AlignedByteOffsetForArgs);

	void DrawInstancedIndirect( 
				ID3D11Buffer pBufferForArgs,
				UINT AlignedByteOffsetForArgs);

	void Dispatch( 
				UINT ThreadGroupCountX,
				UINT ThreadGroupCountY,
				UINT ThreadGroupCountZ);

	void DispatchIndirect( 
				ID3D11Buffer pBufferForArgs,
				UINT AlignedByteOffsetForArgs);

	void RSSetState( 
				ID3D11RasterizerState pRasterizerState);

	void RSSetViewports( 
				UINT NumViewports,
				const(D3D11_VIEWPORT)* pViewports);

	void RSSetScissorRects( 
				UINT NumRects,
				const(D3D11_RECT)* pRects);

	void CopySubresourceRegion( 
				ID3D11Resource pDstResource,
				UINT DstSubresource,
				UINT DstX,
				UINT DstY,
				UINT DstZ,
				ID3D11Resource pSrcResource,
				UINT SrcSubresource,
				const(D3D11_BOX)* pSrcBox);

	void CopyResource( 
				ID3D11Resource pDstResource,
				ID3D11Resource pSrcResource);

	void UpdateSubresource( 
				ID3D11Resource pDstResource,
				UINT DstSubresource,
				const(D3D11_BOX)* pDstBox,
				const void* pSrcData,
				UINT SrcRowPitch,
				UINT SrcDepthPitch);

	void CopyStructureCount( 
				ID3D11Buffer pDstBuffer,
				UINT DstAlignedByteOffset,
				ID3D11UnorderedAccessView pSrcView);

	void ClearRenderTargetView( 
				ID3D11RenderTargetView pRenderTargetView,
				FLOAT[ 4 ] ColorRGBA);

	void ClearUnorderedAccessViewUint( 
				ID3D11UnorderedAccessView pUnorderedAccessView,
				UINT[ 4 ] Values);

	void ClearUnorderedAccessViewFloat( 
				ID3D11UnorderedAccessView pUnorderedAccessView,
				FLOAT[ 4 ] Values);

	void ClearDepthStencilView( 
				ID3D11DepthStencilView pDepthStencilView,
				UINT ClearFlags,
				FLOAT Depth,
				UINT8 Stencil);

	void GenerateMips( 
				ID3D11ShaderResourceView pShaderResourceView);

	void SetResourceMinLOD( 
				ID3D11Resource pResource,
				FLOAT MinLOD);

	FLOAT GetResourceMinLOD( 
				ID3D11Resource pResource);

	void ResolveSubresource( 
				ID3D11Resource pDstResource,
				UINT DstSubresource,
				ID3D11Resource pSrcResource,
				UINT SrcSubresource,
				DXGI_FORMAT Format);

	void ExecuteCommandList( 
				ID3D11CommandList pCommandList,
				BOOL RestoreContextState);

	void HSSetShaderResources( 
				UINT StartSlot,
				UINT NumViews,
				const(ID3D11ShaderResourceView)* ppShaderResourceViews);

	void HSSetShader( 
				ID3D11HullShader pHullShader,
				const(ID3D11ClassInstance)* ppClassInstances,
				UINT NumClassInstances);

	void HSSetSamplers( 
				UINT StartSlot,
				UINT NumSamplers,
				const(ID3D11SamplerState)* ppSamplers);

	void HSSetConstantBuffers( 
				UINT StartSlot,
				UINT NumBuffers,
				const(ID3D11Buffer)* ppConstantBuffers);

	void DSSetShaderResources( 
				UINT StartSlot,
				UINT NumViews,
				const(ID3D11ShaderResourceView)* ppShaderResourceViews);

	void DSSetShader( 
				ID3D11DomainShader pDomainShader,
				const(ID3D11ClassInstance)* ppClassInstances,
				UINT NumClassInstances);

	void DSSetSamplers( 
				UINT StartSlot,
				UINT NumSamplers,
				const(ID3D11SamplerState)* ppSamplers);

	void DSSetConstantBuffers( 
				UINT StartSlot,
				UINT NumBuffers,
				const(ID3D11Buffer)* ppConstantBuffers);

	void CSSetShaderResources( 
				UINT StartSlot,
				UINT NumViews,
				const(ID3D11ShaderResourceView)* ppShaderResourceViews);

	void CSSetUnorderedAccessViews( 
				UINT StartSlot,
				UINT NumUAVs,
				const(ID3D11UnorderedAccessView)* ppUnorderedAccessViews,
				const(UINT)* pUAVInitialCounts);

	void CSSetShader( 
				ID3D11ComputeShader pComputeShader,
				const(ID3D11ClassInstance)* ppClassInstances,
				UINT NumClassInstances);

	void CSSetSamplers( 
				UINT StartSlot,
				UINT NumSamplers,
				const(ID3D11SamplerState)* ppSamplers);
        
	void CSSetConstantBuffers( 
				UINT StartSlot,
				UINT NumBuffers,
				const(ID3D11Buffer)* ppConstantBuffers);
        
	void VSGetConstantBuffers( 
				UINT StartSlot,
				UINT NumBuffers,
				ID3D11Buffer* ppConstantBuffers);

	void PSGetShaderResources( 
				UINT StartSlot,
				UINT NumViews,
				ID3D11ShaderResourceView* ppShaderResourceViews);

	void PSGetShader( 
				ID3D11PixelShader* ppPixelShader,
				const(ID3D11ClassInstance)* ppClassInstances,
				UINT* pNumClassInstances);

	void PSGetSamplers( 
				UINT StartSlot,
				UINT NumSamplers,
				ID3D11SamplerState* ppSamplers);

	void VSGetShader( 
				ID3D11VertexShader* ppVertexShader,
				const(ID3D11ClassInstance)* ppClassInstances,
				UINT* pNumClassInstances);

	void PSGetConstantBuffers( 
				UINT StartSlot,
				UINT NumBuffers,
				ID3D11Buffer* ppConstantBuffers);

	void IAGetInputLayout( 
				ID3D11InputLayout* ppInputLayout);

	void IAGetVertexBuffers( 
				UINT StartSlot,
				UINT NumBuffers,
				ID3D11Buffer* ppVertexBuffers,
				UINT* pStrides,
				UINT* pOffsets);

	void IAGetIndexBuffer( 
				ID3D11Buffer* pIndexBuffer,
				DXGI_FORMAT* Format,
				UINT* Offset);

	void GSGetConstantBuffers( 
				UINT StartSlot,
				UINT NumBuffers,
				ID3D11Buffer* ppConstantBuffers);

	void GSGetShader( 
				ID3D11GeometryShader* ppGeometryShader,
				const(ID3D11ClassInstance)* ppClassInstances,
				UINT* pNumClassInstances);

	void IAGetPrimitiveTopology( 
				D3D11_PRIMITIVE_TOPOLOGY* pTopology);

	void VSGetShaderResources( 
				UINT StartSlot,
				UINT NumViews,
				ID3D11ShaderResourceView* ppShaderResourceViews);

	void VSGetSamplers( 
				UINT StartSlot,
				UINT NumSamplers,
				ID3D11SamplerState* ppSamplers);

	void GetPredication( 
				ID3D11Predicate* ppPredicate,
				BOOL* pPredicateValue);

	void GSGetShaderResources( 
				UINT StartSlot,
				UINT NumViews,
				ID3D11ShaderResourceView* ppShaderResourceViews);

	void GSGetSamplers( 
				UINT StartSlot,
				UINT NumSamplers,
				ID3D11SamplerState* ppSamplers);

	void OMGetRenderTargets( 
				UINT NumViews,
				ID3D11RenderTargetView* ppRenderTargetViews,
				ID3D11DepthStencilView* ppDepthStencilView);

	void OMGetRenderTargetsAndUnorderedAccessViews( 
				UINT NumRTVs,
				ID3D11RenderTargetView* ppRenderTargetViews,
				ID3D11DepthStencilView* ppDepthStencilView,
				UINT UAVStartSlot,
				UINT NumUAVs,
				ID3D11UnorderedAccessView* ppUnorderedAccessViews);

	void OMGetBlendState( 
				ID3D11BlendState* ppBlendState,
				FLOAT[ 4 ] BlendFactor,
				UINT* pSampleMask);

	void OMGetDepthStencilState( 
				ID3D11DepthStencilState* ppDepthStencilState,
				UINT* pStencilRef);

	void SOGetTargets( 
				UINT NumBuffers,
				ID3D11Buffer* ppSOTargets);

	void RSGetState( 
				ID3D11RasterizerState* ppRasterizerState);

	void RSGetViewports( 
				UINT* pNumViewports,
				D3D11_VIEWPORT* pViewports);

	void RSGetScissorRects( 
				UINT* pNumRects,
				D3D11_RECT* pRects);

	void HSGetShaderResources( 
				UINT StartSlot,
				UINT NumViews,
				ID3D11ShaderResourceView* ppShaderResourceViews);

	void HSGetShader( 
				ID3D11HullShader* ppHullShader,
				ID3D11ClassInstance* ppClassInstances,
				UINT* pNumClassInstances);

	void HSGetSamplers( 
				UINT StartSlot,
				UINT NumSamplers,
				ID3D11SamplerState* ppSamplers);

	void HSGetConstantBuffers( 
				UINT StartSlot,
				UINT NumBuffers,
				ID3D11Buffer* ppConstantBuffers);

	void DSGetShaderResources( 
				UINT StartSlot,
				UINT NumViews,
				ID3D11ShaderResourceView* ppShaderResourceViews);

	void DSGetShader( 
				ID3D11DomainShader* ppDomainShader,
				ID3D11ClassInstance* ppClassInstances,
				UINT* pNumClassInstances);

	void DSGetSamplers( 
				UINT StartSlot,
				UINT NumSamplers,
				ID3D11SamplerState* ppSamplers);

	void DSGetConstantBuffers( 
				UINT StartSlot,
				UINT NumBuffers,
				ID3D11Buffer* ppConstantBuffers);

	void CSGetShaderResources( 
				UINT StartSlot,
				UINT NumViews,
				ID3D11ShaderResourceView* ppShaderResourceViews);

	void CSGetUnorderedAccessViews( 
				UINT StartSlot,
				UINT NumUAVs,
				ID3D11UnorderedAccessView* ppUnorderedAccessViews);

	void CSGetShader( 
				ID3D11ComputeShader* ppComputeShader,
				ID3D11ClassInstance* ppClassInstances,
				UINT* pNumClassInstances);

	void CSGetSamplers( 
				UINT StartSlot,
				UINT NumSamplers,
				ID3D11SamplerState* ppSamplers);

	void CSGetConstantBuffers( 
				UINT StartSlot,
				UINT NumBuffers,
				ID3D11Buffer* ppConstantBuffers);

	void ClearState();

	void Flush();

	D3D11_DEVICE_CONTEXT_TYPE GetType();

	UINT GetContextFlags();

	HRESULT FinishCommandList( 
				BOOL RestoreDeferredContextState,
				ID3D11CommandList* ppCommandList);
}


mixin( uuid!(ID3D11Device, "db6f6ddb-ac77-4e88-8253-819df9bbf140") );
interface ID3D11Device : IUnknown
{
	extern(Windows):
	HRESULT CreateBuffer( 
				const(D3D11_BUFFER_DESC)* pDesc,
				const(D3D11_SUBRESOURCE_DATA)* pInitialData,
				ID3D11Buffer* ppBuffer);

	HRESULT CreateTexture1D( 
				const(D3D11_TEXTURE1D_DESC)* pDesc,
				const(D3D11_SUBRESOURCE_DATA)* pInitialData,
				ID3D11Texture1D* ppTexture1D);

	HRESULT CreateTexture2D( 
				const(D3D11_TEXTURE2D_DESC)* pDesc,
				const(D3D11_SUBRESOURCE_DATA)* pInitialData,
				ID3D11Texture2D* ppTexture2D);

	HRESULT CreateTexture3D( 
				const(D3D11_TEXTURE3D_DESC)* pDesc,
				const(D3D11_SUBRESOURCE_DATA)* pInitialData,
				ID3D11Texture3D* ppTexture3D);

	HRESULT CreateShaderResourceView( 
				ID3D11Resource pResource,
				const(D3D11_SHADER_RESOURCE_VIEW_DESC)* pDesc,
				ID3D11ShaderResourceView* ppSRView);

	HRESULT CreateUnorderedAccessView( 
				ID3D11Resource pResource,
				const(D3D11_UNORDERED_ACCESS_VIEW_DESC)* pDesc,
				ID3D11UnorderedAccessView* ppUAView);

	HRESULT CreateRenderTargetView( 
				ID3D11Resource pResource,
				const(D3D11_RENDER_TARGET_VIEW_DESC)* pDesc,
				ID3D11RenderTargetView* ppRTView);

	HRESULT CreateDepthStencilView( 
				ID3D11Resource pResource,
				const(D3D11_DEPTH_STENCIL_VIEW_DESC)* pDesc,
				ID3D11DepthStencilView* ppDepthStencilView);

	HRESULT CreateInputLayout( 
				const(D3D11_INPUT_ELEMENT_DESC)* pInputElementDescs,
				UINT NumElements,
				const void* pShaderBytecodeWithInputSignature,
				SIZE_T BytecodeLength,
				ID3D11InputLayout* ppInputLayout);

	HRESULT CreateVertexShader( 
				const void* pShaderBytecode,
				SIZE_T BytecodeLength,
				ID3D11ClassLinkage pClassLinkage,
				ID3D11VertexShader* ppVertexShader);

	HRESULT CreateGeometryShader( 
				const void* pShaderBytecode,
				SIZE_T BytecodeLength,
				ID3D11ClassLinkage pClassLinkage,
				ID3D11GeometryShader* ppGeometryShader);

	HRESULT CreateGeometryShaderWithStreamOutput( 
				const void* pShaderBytecode,
				SIZE_T BytecodeLength,
				const(D3D11_SO_DECLARATION_ENTRY)* pSODeclaration,
				UINT NumEntries,
				const(UINT)* pBufferStrides,
				UINT NumStrides,
				UINT RasterizedStream,
				ID3D11ClassLinkage pClassLinkage,
				ID3D11GeometryShader* ppGeometryShader);

	HRESULT CreatePixelShader( 
				const void* pShaderBytecode,
				SIZE_T BytecodeLength,
				ID3D11ClassLinkage pClassLinkage,
				ID3D11PixelShader* ppPixelShader);

	HRESULT CreateHullShader( 
				const void* pShaderBytecode,
				SIZE_T BytecodeLength,
				ID3D11ClassLinkage pClassLinkage,
				ID3D11HullShader* ppHullShader);

	HRESULT CreateDomainShader( 
				const void* pShaderBytecode,
				SIZE_T BytecodeLength,
				ID3D11ClassLinkage pClassLinkage,
				ID3D11DomainShader* ppDomainShader);

	HRESULT CreateComputeShader( 
				const void* pShaderBytecode,
				SIZE_T BytecodeLength,
				ID3D11ClassLinkage pClassLinkage,
				ID3D11ComputeShader* ppComputeShader);

	HRESULT CreateClassLinkage( 
				ID3D11ClassLinkage* ppLinkage);
        
	HRESULT CreateBlendState( 
				const(D3D11_BLEND_DESC)* pBlendStateDesc,
				ID3D11BlendState* ppBlendState);

	HRESULT CreateDepthStencilState( 
				const(D3D11_DEPTH_STENCIL_DESC)* pDepthStencilDesc,
				ID3D11DepthStencilState* ppDepthStencilState);

	HRESULT CreateRasterizerState( 
				const(D3D11_RASTERIZER_DESC)* pRasterizerDesc,
				ID3D11RasterizerState* ppRasterizerState);

	HRESULT CreateSamplerState( 
				const(D3D11_SAMPLER_DESC)* pSamplerDesc,
				ID3D11SamplerState* ppSamplerState);

	HRESULT CreateQuery( 
				const(D3D11_QUERY_DESC)* pQueryDesc,
				ID3D11Query* ppQuery);

	HRESULT CreatePredicate( 
				const(D3D11_QUERY_DESC)* pPredicateDesc,
				ID3D11Predicate* ppPredicate);

	HRESULT CreateCounter( 
				const(D3D11_COUNTER_DESC)* pCounterDesc,
				ID3D11Counter* ppCounter);

	HRESULT CreateDeferredContext( 
				UINT ContextFlags,
				ID3D11DeviceContext* ppDeferredContext);

	HRESULT OpenSharedResource( 
				HANDLE hResource,
				REFIID ReturnedInterface,
				void** ppResource);

	HRESULT CheckFormatSupport( 
				DXGI_FORMAT Format,
				UINT* pFormatSupport);

	HRESULT CheckMultisampleQualityLevels( 
				DXGI_FORMAT Format,
				UINT SampleCount,
				UINT* pNumQualityLevels);

	void CheckCounterInfo( 
				D3D11_COUNTER_INFO *pCounterInfo);

	HRESULT CheckCounter( 
				const(D3D11_COUNTER_DESC)* pDesc,
				D3D11_COUNTER_TYPE* pType,
				UINT* pActiveCounters,
				LPSTR szName,
				UINT* pNameLength,
				LPSTR szUnits,
				UINT* pUnitsLength,
				LPSTR szDescription,
				UINT* pDescriptionLength);

	HRESULT CheckFeatureSupport( 
				D3D11_FEATURE Feature,
				void* pFeatureSupportData,
				UINT FeatureSupportDataSize);

	HRESULT GetPrivateData( 
				REFGUID guid,
				UINT* pDataSize,
				void* pData);

	HRESULT SetPrivateData( 
				REFGUID guid,
				UINT DataSize,
				const void* pData);

	HRESULT SetPrivateDataInterface( 
				REFGUID guid,
				const IUnknown pData);

	D3D_FEATURE_LEVEL GetFeatureLevel();

	UINT GetCreationFlags();

	HRESULT GetDeviceRemovedReason();

	void GetImmediateContext( 
				ID3D11DeviceContext* ppImmediateContext);

	HRESULT SetExceptionMode( 
				UINT RaiseFlags);

	UINT GetExceptionMode();
}


enum D3D11_CREATE_DEVICE_FLAG
{
	D3D11_CREATE_DEVICE_SINGLETHREADED	= 0x1,
	D3D11_CREATE_DEVICE_DEBUG	= 0x2,
	D3D11_CREATE_DEVICE_SWITCH_TO_REF	= 0x4,
	D3D11_CREATE_DEVICE_PREVENT_INTERNAL_THREADING_OPTIMIZATIONS	= 0x8,
	D3D11_CREATE_DEVICE_BGRA_SUPPORT	= 0x20
}

enum D3D11_SDK_VERSION = ( 7 );

//public import directx._d3d10.d3d10_1;
version(D3D11_IGNORE_SDK_LAYERS) 
import directx.d3d11sdklayers;

//public import directx._d3d10misc;
//public import directx._d3d10shader;
//public import directx._d3d10effect; 
//public import directx._d3d10_1shader;

///////////////////////////////////////////////////////////////////////////
// D3D11CreateDevice
// ------------------
//
// pAdapter
//      If NULL, D3D11CreateDevice will choose the primary adapter and
//      create a new instance from a temporarily created IDXGIFactory.
//      If non-NULL, D3D11CreateDevice will register the appropriate
//      device, if necessary (via IDXGIAdapter::RegisterDrver), before
//      creating the device.
// DriverType
//      Specifies the driver type to be created: hardware, reference or
//      null.
// Software
//      HMODULE of a DLL implementing a software rasterizer. Must be NULL for
//      non-Software driver types.
// Flags
//      Any of those documented for D3D11CreateDeviceAndSwapChain.
// pFeatureLevels
//      Any of those documented for D3D11CreateDeviceAndSwapChain.
// FeatureLevels
//      Size of feature levels array.
// SDKVersion
//      SDK version. Use the D3D11_SDK_VERSION macro.
// ppDevice
//      Pointer to returned interface. May be NULL.
// pFeatureLevel
//      Pointer to returned feature level. May be NULL.
// ppImmediateContext
//      Pointer to returned interface. May be NULL.
//
// Return Values
//  Any of those documented for 
//          CreateDXGIFactory1
//          IDXGIFactory::EnumAdapters
//          IDXGIAdapter::RegisterDriver
//          D3D11CreateDevice
//
///////////////////////////////////////////////////////////////////////////
alias extern(Windows) function HRESULT ( IDXGIAdapter, 
    D3D_DRIVER_TYPE, HMODULE, UINT, 
    const(D3D_FEATURE_LEVEL)*,
    UINT FeatureLevels, UINT, ID3D11Device*, 
    D3D_FEATURE_LEVEL*, ID3D11DeviceContext* ) PFN_D3D11_CREATE_DEVICE;

extern(Windows)
HRESULT D3D11CreateDevice(
    IDXGIAdapter pAdapter,
    D3D_DRIVER_TYPE DriverType,
    HMODULE Software,
    UINT Flags,
    const(D3D_FEATURE_LEVEL)* pFeatureLevels,
    UINT FeatureLevels,
    UINT SDKVersion,
    ID3D11Device* ppDevice,
    D3D_FEATURE_LEVEL* pFeatureLevel,
    ID3D11DeviceContext* ppImmediateContext );

///////////////////////////////////////////////////////////////////////////
// D3D11CreateDeviceAndSwapChain
// ------------------------------
//
// ppAdapter
//      If NULL, D3D11CreateDevice will choose the primary adapter and 
//      create a new instance from a temporarily created IDXGIFactory.
//      If non-NULL, D3D11CreateDevice will register the appropriate
//      device, if necessary (via IDXGIAdapter::RegisterDrver), before
//      creating the device.
// DriverType
//      Specifies the driver type to be created: hardware, reference or
//      null.
// Software
//      HMODULE of a DLL implementing a software rasterizer. Must be NULL for
//      non-Software driver types.
// Flags
//      Any of those documented for D3D11CreateDevice.
// pFeatureLevels
//      Array of any of the following:
//          D3D_FEATURE_LEVEL_11_0
//          D3D_FEATURE_LEVEL_10_1
//          D3D_FEATURE_LEVEL_10_0
//          D3D_FEATURE_LEVEL_9_3
//          D3D_FEATURE_LEVEL_9_2
//          D3D_FEATURE_LEVEL_9_1
//      Order indicates sequence in which instantiation will be attempted. If
//      NULL, then the implied order is the same as previously listed (i.e. 
//      prefer most features available). 
// FeatureLevels
//      Size of feature levels array.
// SDKVersion
//      SDK version. Use the D3D11_SDK_VERSION macro.
// pSwapChainDesc
//      Swap chain description, may be NULL.
// ppSwapChain
//      Pointer to returned interface. May be NULL.
// ppDevice
//      Pointer to returned interface. May be NULL.
// pFeatureLevel
//      Pointer to returned feature level. May be NULL.
// ppImmediateContext
//      Pointer to returned interface. May be NULL.
//
// Return Values
//  Any of those documented for 
//          CreateDXGIFactory1
//          IDXGIFactory::EnumAdapters
//          IDXGIAdapter::RegisterDriver
//          D3D11CreateDevice
//          IDXGIFactory::CreateSwapChain
//
///////////////////////////////////////////////////////////////////////////

alias extern(Windows) function HRESULT ( IDXGIAdapter, 
    D3D_DRIVER_TYPE, HMODULE, UINT, 
    const(D3D_FEATURE_LEVEL)*, 
    UINT FeatureLevels, UINT, const(DXGI_SWAP_CHAIN_DESC)*, 
    IDXGISwapChain*, ID3D11Device*, 
    D3D_FEATURE_LEVEL*, ID3D11DeviceContext* ) PFN_D3D11_CREATE_DEVICE_AND_SWAP_CHAIN;

extern(Windows)
HRESULT D3D11CreateDeviceAndSwapChain(
    IDXGIAdapter pAdapter,
    D3D_DRIVER_TYPE DriverType,
    HMODULE Software,
    UINT Flags,
    const(D3D_FEATURE_LEVEL)* pFeatureLevels,
    UINT FeatureLevels,
    UINT SDKVersion,
    const(DXGI_SWAP_CHAIN_DESC)* pSwapChainDesc,
    IDXGISwapChain* ppSwapChain,
    ID3D11Device* ppDevice,
    D3D_FEATURE_LEVEL* pFeatureLevel,
    ID3D11DeviceContext* ppImmediateContext );


