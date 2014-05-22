// This module contains some GDI definitions and functions required by DirectX
module directx.wingdi;

import directx.win32;

enum LF_FACESIZE = 32;

struct tagLOGFONTA
{
    LONG      lfHeight;
    LONG      lfWidth;
    LONG      lfEscapement;
    LONG      lfOrientation;
    LONG      lfWeight;
    BYTE      lfItalic;
    BYTE      lfUnderline;
    BYTE      lfStrikeOut;
    BYTE      lfCharSet;
    BYTE      lfOutPrecision;
    BYTE      lfClipPrecision;
    BYTE      lfQuality;
    BYTE      lfPitchAndFamily;
    CHAR[LF_FACESIZE]      lfFaceName;
}
alias LOGFONTA = tagLOGFONTA;
alias PLOGFONTA = LOGFONTA*;
alias NPLOGFONTA = LOGFONTA*;
alias LPLOGFONTA = LOGFONTA*;

struct tagLOGFONTW
{
    LONG      lfHeight;
    LONG      lfWidth;
    LONG      lfEscapement;
    LONG      lfOrientation;
    LONG      lfWeight;
    BYTE      lfItalic;
    BYTE      lfUnderline;
    BYTE      lfStrikeOut;
    BYTE      lfCharSet;
    BYTE      lfOutPrecision;
    BYTE      lfClipPrecision;
    BYTE      lfQuality;
    BYTE      lfPitchAndFamily;
    WCHAR[LF_FACESIZE]     lfFaceName;
}
alias LOGFONTW = tagLOGFONTW;
alias PLOGFONTW = LOGFONTW*;
alias NPLOGFONTW = LOGFONTW*;
alias LPLOGFONTW = LOGFONTW*;

alias LOGFONT = LOGFONTW;
alias PLOGFONT = PLOGFONTW;
alias NPLOGFONT = NPLOGFONTW;
alias LPLOGFONT = LPLOGFONTW;
