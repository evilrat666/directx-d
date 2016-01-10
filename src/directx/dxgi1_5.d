module directx.dxgi1_5;

import directx.com;
import directx.dxgiformat;
import directx.dxgi1_2;
import directx.dxgi1_4;

mixin(uuid!(IDXGIOutput5, "80a07424-ab52-42eb-833c-0c42fd282d98"));
extern (C++) interface IDXGIOutput5 : IDXGIOutput4 {
    HRESULT DuplicateOutput1( 
        IUnknown pDevice,
        UINT Flags,
        UINT SupportedFormatsCount,
        const(DXGI_FORMAT)* pSupportedFormats,
        IDXGIOutputDuplication* ppOutputDuplication);
}
