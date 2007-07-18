{
  Copyright 2004-2006 Michalis Kamburelis.

  This file is part of "Kambi's OpenGL Pascal units".

  "Kambi's OpenGL Pascal units" is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  "Kambi's OpenGL Pascal units" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with "Kambi's OpenGL Pascal units"; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

{ Demo of
  - using multiple windows with GLWindow unit
  - instead of registering OnXxx callbacks overriding EventXxx methods
    (more OOP approach)
  - TGLOutlineTTFont rendered with depth (3d letters)

  Started as program based on NeHe 14th tutorial. Now the things insprired
  by NeHe 14th tutorial are in implementation of TGLOutlineFont for
  Windows in OpenGLWinFonts. This program evolved to something completely
  different.
}

program multi_glwindow;

{$apptype GUI}

uses
  OpenGLh, GLWindow, SysUtils, KambiUtils, OpenGLFonts, OpenGLTTFonts,
  TTF_BitstreamVeraSans_Unit, KambiGLUtils, Keys;

type
  TMyWindow = class(TGLWindowDemo)
    FontGL, FontGLLines: TGLOutlineFont_Abstract;
    RotX, RotY, RotZ, MoveX, MoveY, MoveZ :TGLfloat;
    OnlyLines: boolean;
    Text: string;
    LightCol3f, DarkCol3f: TVector3f;
    Rotating: boolean;

    procedure EventDraw; override;
    procedure EventIdle; override;
    procedure EventResize; override;
    procedure EventInit; override;
    procedure EventClose; override;
    procedure EventKeyDown(key: TKey; c: char); override;
  end;

procedure TMyWindow.EventDraw;
begin
 inherited;

 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
 glLoadIdentity();
 glTranslatef(MoveX, MoveY, MoveZ);

 glRotatef(RotX, 1, 0, 0);
 glRotatef(RotY, 0, 1, 0);
 glRotatef(RotZ ,0, 0, 1);

 // Pulsing Colors Based On The Rotation
//  glColor3f(cos(rot/20.0), sin(rot/25.0), 0.5*cos(rot/17.0));
//  glColor3f(0.5+cos(rot/20.0)/2, 0.5+sin(rot/25.0)/2, 0.5+0.5*cos(rot/17.0)/2);

 glScalef(0.08, 0.08, 0.08);
 glColorv(LightCol3f);
 if OnlyLines then
 begin
  FontGLLines.Print(Text);
 end else
 begin
  glPushMatrix;
  FontGL.Print(Text);
  glPopMatrix;
  glColorv(DarkCol3f);
  FontGLLines.Print(Text);
 end;
end;

procedure TMyWindow.EventIdle;

  function B(val: boolean): integer;
  begin if val then result := 1 else result := -1 end;

  procedure GLChange(var a: TGLfloat; change: TGLFloat);
  begin
   a += change;
   PostRedisplay;
  end;

begin
 inherited;

 if KeysDown[K_X] then GLChange(RotX, B(mkShift in ModifiersDown)*0.6);
 if KeysDown[K_Y] then GLChange(RotY, B(mkShift in ModifiersDown)*0.6);
 if KeysDown[K_Z] then GLChange(RotZ, B(mkShift in ModifiersDown)*0.6);

 if KeysDown[K_Left] then GLChange(MoveX, -0.1);
 if KeysDown[K_Right] then GLChange(MoveX, 0.1);
 if KeysDown[K_Down] then GLChange(MoveY, -0.1);
 if KeysDown[K_Up] then GLChange(MoveY, 0.1);
 if KeysDown[K_PageUp] then GLChange(MoveZ, 0.1);
 if KeysDown[K_PageDown] then GLChange(MoveZ, -0.1);

 if Rotating then
 begin
  GLChange(Roty, -0.1);
  GLChange(Rotz, 0.1);
 end;
end;

procedure TMyWindow.EventResize;
begin
 inherited;

 glViewport(0, 0, Width, Height);
 ProjectionGLPerspective(45.0, Width/Height, 0.1, 100.0);
end;

procedure TMyWindow.EventInit;
begin
 inherited;

 glEnable(GL_DEPTH_TEST);
 //fontgl := TGLOutlineFont.Create(0, 255, 0, 2, WGL_FONT_POLYGONS, 'Comic Sans MS');
 FontGL := TGLOutlineFont.Create(@TTF_BitstreamVeraSans, 40);
 FontGLLines := TGLOutlineFont.Create(@TTF_BitstreamVeraSans, 40, true);
end;

procedure TMyWindow.EventClose;
begin
 FreeAndNil(FontGL);
 FreeAndNil(FontGLLines);

 inherited;
end;

procedure TMyWindow.EventKeyDown(key: TKey; c: char);
begin
 inherited;
 case c of
  'l':begin
       OnlyLines := not OnlyLines;
       PostRedisplay
      end;
 end;
end;

var i: integer;
    Windws: array[0..4]of TMyWindow;
begin
 for i := 0 to High(Windws) do
 begin
  Windws[i] := TMyWindow.Create;

  Windws[i].MoveZ := -10;
  Windws[i].Text := 'Window number '+IntToStr(i);
  Windws[i].LightCol3f := Vector3f(Random*1.5, Random*1.5, Random*1.5);
  Windws[i].DarkCol3f := Vector3f(Random*0.7, Random*0.7, Random*0.7);
  Windws[i].Rotating := Odd(i);

  Windws[i].Caption := IntToStr(i)+
    ' : outline font + multiple windows under GLWindow demo';
  Windws[i].Width := 200;
  Windws[i].Height := 200;
  Windws[i].Left := 30 + 250 * (i mod 3);
  Windws[i].Top := 30 + 250 * (i div 3);
 end;
 try
  for i := 0 to High(Windws) do Windws[i].Init;
  glwm.Loop; { Loop will end when the last window is closed by the user }
 finally
  for i := 0 to High(Windws) do FreeAndNil(Windws[i]);
 end;
end.
