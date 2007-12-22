{
  Copyright 2002-2006 Michalis Kamburelis.

  This file is part of "Kambi VRML game engine".

  "Kambi VRML game engine" is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  "Kambi VRML game engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with "Kambi VRML game engine"; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

{ @abstract(Various helper things for Xlib.)

  In initialization of this unit
  we register our own Xlib ErrorHandler that doesn't halt the program
  in case of error. It raises @link(EXlibError) with appropriate Message.
  This allows to use ObjectPascal exceptions to handle Xlib errors,
  so we can gracefully finalize our program, or (in special
  cases) catch the exception etc. Default Xlib ErrorHandler
  was just printing error message and unconditionally stopping program,
  so it wasn's very nice.

  In finalization of this unit we set back previous error handler.
}

unit XlibUtils;

{$I kambiconf.inc}

interface

uses Xlib, X, XUtil, SysUtils, KambiUtils;

const
  { }
  XlibDLL = 'libX11.so';
  XmuDLL = 'libXmu.so';

type
  XBool = Xlib.TBool;

  TXStandardColormap_Array = array[0..High(Word)]of TXStandardColormap;
  PXStandardColormap_Array = ^TXStandardColormap_Array;

const
  XBool_true = true;
  XBool_false = false;

type
  EXlibError = class(Exception);

{ ---------------------------------------------------------------------------- }
{ @section(xutil.h (XLibDLL)) }

{ }
function XSetStandardProperties(dpy: PDisplay; win: TWindow; window_name: pchar;
  icon_name: pchar; icon_pixmap: TPixmap; argv: PPChar; argc: Integer;
  hints: PXSizeHints): integer; cdecl; external XLibDLL;
function XSetStandardProperties_Pascal(dpy: PDisplay; win: TWindow;
  window_name: pchar; icon_name: pchar; icon_pixmap: TPixmap; hints: PXSizeHints)
  :integer;

procedure XSetWMProperties_Pascal(Display: PDisplay; W: TWindow;
  WindowName: PXTextProperty; IconName: PXTextProperty;
  NormalHints: PXSizeHints; WMHints: PXWMHints; ClassHints: PXClassHint);

{ ---------------------------------------------------------------------------- }
{ @section(xlib.h (XLibDLL)) }

{ }
function XParseGeometry(parsestring: PChar; x_return, y_return: PInteger;
  width_return, height_return: PLongWord): integer; cdecl; external XlibDLL;

{ ---------------------------------------------------------------------------- }
{ @section(Xmu/StdCmap.h (XmuDLL)) }

{ }
function XmuLookupStandardColormap(dpy: PDisplay; screen: integer;
  AVisualid: TVisualID; depth: Longword; AProperty: TAtom; replace, retain: XBool)
  :TStatus; cdecl; external XmuDLL;

implementation

type
  TArray_PChar = packed array[0..High(Word)]of PChar;
  PArray_PChar=^TArray_PChar;

procedure CreateArgCV(out argc_ret: Longint; out argv_ret: PPChar);
{ Na podstawie ParamCount i ParamStr konstruujemy argc i argv
  aby udawaly parametry main () z ANSI C.
  Zawsze zwalniaj potem z pamieci argv przez DestroyArgV. }
var i: Integer;
    argv: PArray_PChar absolute argv_ret;
begin
 argc_ret := ParamCount+1;
 GetMem(Pointer(argv),(argc_ret+1)*SizeOf(PChar));
 for i := 0 to ParamCount do
  argv^[i] := StrNew(PChar(ParamStr(i))); { KOPIUJEMY ParamStr do nowego PChara- tak najbezpieczniej }
 argv^[argc_ret] := nil; { ostatni element tablicy argv[] powinien byc ustawiony na nil }
end;

procedure DestroyArgV(var argv_ret: PPChar);
var i: integer;
    argv: PArray_PChar absolute argv_ret;
begin
 for i := 0 to ParamCount do StrDispose(argv^[i]);
 FreeMemNiling(Pointer(argv));
end;

function XSetStandardProperties_Pascal(dpy: PDisplay; win: TWindow;
  window_name: pchar; icon_name: pchar;icon_pixmap: TPixmap;
  hints: PXSizeHints): integer;
{ simplified version of XSetStandardProperties }
var argc: Longint;
    argv: PPChar;
begin
 CreateArgCV(argc, argv);
 result := XSetStandardProperties(dpy, win, window_name, icon_name,
   icon_pixmap, argv, argc, hints);
 DestroyArgV(argv);
end;

procedure XSetWMProperties_Pascal(Display: PDisplay; W: TWindow;
  WindowName: PXTextProperty;
  IconName: PXTextProperty; NormalHints: PXSizeHints; WMHints:
  PXWMHints; ClassHints: PXClassHint);
var argc: Longint;
    argv: PPChar;
begin
 CreateArgCV(argc, argv);
 XSetWMProperties(Display, W, WindowName, IconName, argv, argc, NormalHints, WMHints, ClassHints);
 DestroyArgV(argv);
end;

{ some mine things ------------------------------------------------------------ }

function XlibErrorHandler_RaiseEXlibError(display: PDisplay; error: PXErrorEvent)
  :integer; cdecl;
{ rzuca wyjatek EXlibError z odpowiednio skonstruowanym Text'em.
  Ta funkcja jest dobra aby ja zarejestrowac przez XSetErrorHandler. }
var error_name_buf, major_request_name_buf :array[0..1023]of char;
    s: string;
begin
 XGetErrorText(display, error^.error_code, @error_name_buf, SizeOf(error_name_buf));
 XGetErrorDatabaseText(display, 'XRequest', PChar(IntToStr(error^.request_code)),
   '(not found in X database)',
   @major_request_name_buf, SizeOf(major_request_name_buf));

 s := Format('Xlib error ''%s'' (%d) at request ''%s'' (%d)',
   [PChar(@error_name_buf), error^.error_code,
    PChar(@major_request_name_buf), error^.request_code]);

 if error^.minor_code <> 0 then
 begin

{ TODO: jak zrobic ponizsze ? Skad wziac ExtensionName ?? Wiem ze ono jest
  zakodowane w request_code. }
{  XGetErrorDatabaseText(display, 'XRequest',
    PChar(ExtensionName +'.' +IntToStr(error.minor_code)),
    '(not found in X database)',
    @ext_request_name_buf, SizeOf(ext_request_name_buf));
  s += Format(' (extension request ''%s'' (%d)',
    [PChar(@ext_request_name_buf), error.minor_code]);
}
  s += Format(' (extension request (%d)', [error^.minor_code]);
 end;

 raise EXlibError.Create(s);

 result := 0; { this instruction is unreachable, it is only to avoid compiler warnings }
end;

var oldXLibErrorHandler: TXErrorHandler;
initialization
 oldXLibErrorHandler := XSetErrorHandler(@XlibErrorHandler_RaiseEXlibError);
finalization
 XSetErrorHandler(oldXLibErrorHandler);
end.