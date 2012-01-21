{
  Copyright 2006-2012 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Menu items (suitable for TCastleOnScreenMenu) to control the TXmlSoundEngine. }
unit CastleSoundMenu;

interface

uses CastleWindow, OnScreenMenu, XmlSoundEngine;

type
  { An abstract class for CastleSoundMenu items.
    In the future maybe such idea will be incorporated into OnScreenMenu unit. }
  TOnScreenMenuItem = class
  private
    FWindow: TCastleWindowBase;
  protected
    property Window: TCastleWindowBase read FWindow;
  public
    { Creates and adds this menu item to Menu. }
    constructor Create(AWindow: TCastleWindowBase; Menu: TCastleOnScreenMenu);
    function Title: string; virtual; abstract;
    function Accessory: TMenuAccessory; virtual;
    procedure Selected; virtual;
    procedure AccessoryValueChanged; virtual;
  end;

  TSoundMenuItem = class(TOnScreenMenuItem)
  private
    FSoundEngine: TXmlSoundEngine;
  protected
    property SoundEngine: TXmlSoundEngine read FSoundEngine;
  public
    constructor Create(AWindow: TCastleWindowBase; Menu: TCastleOnScreenMenu;
      ASoundEngine: TXmlSoundEngine);
  end;

  TSoundInfoMenuItem = class(TSoundMenuItem)
  public
    function Title: string; override;
    procedure Selected; override;
  end;

  { Float slider suitable for volume setting.
    Range is always [0 .. 1] and when the slider is exactly
    on 0.0 position it shows "Off". }
  TMenuVolumeSlider = class(TMenuFloatSlider)
    constructor Create(const AValue: Single);
    function ValueToStr(const AValue: Single): string; override;
  end;

  TSoundVolumeMenuItem = class(TSoundMenuItem)
  private
    FSlider: TMenuVolumeSlider;
    property Slider: TMenuVolumeSlider read FSlider;
  public
    constructor Create(AWindow: TCastleWindowBase; Menu: TCastleOnScreenMenu;
      ASoundEngine: TXmlSoundEngine);

    { Call this if volume changed by something outside of this class. }
    procedure RefreshAccessory;

    function Title: string; override;
    function Accessory: TMenuAccessory; override;
    procedure AccessoryValueChanged; override;
  end;

  TMusicVolumeMenuItem = class(TSoundMenuItem)
  private
    FSlider: TMenuVolumeSlider;
    property Slider: TMenuVolumeSlider read FSlider;
  public
    constructor Create(AWindow: TCastleWindowBase; Menu: TCastleOnScreenMenu;
      ASoundEngine: TXmlSoundEngine);

    { Call this if volume changed by something outside of this class. }
    procedure RefreshAccessory;

    function Title: string; override;
    function Accessory: TMenuAccessory; override;
    procedure AccessoryValueChanged; override;
  end;

implementation

uses Classes, CastleClassUtils, CastleUtils, CastleMessages;

{ TOnScreenMenuItem ---------------------------------------------------------------- }

constructor TOnScreenMenuItem.Create(AWindow: TCastleWindowBase; Menu: TCastleOnScreenMenu);
begin
  inherited Create;
  Menu.Items.AddObject(Title, Accessory);
  FWindow := AWindow;
end;

function TOnScreenMenuItem.Accessory: TMenuAccessory;
begin
  Result := nil;
end;

procedure TOnScreenMenuItem.Selected;
begin
end;

procedure TOnScreenMenuItem.AccessoryValueChanged;
begin
end;

{ TSoundMenuItem ----------------------------------------------------------- }

constructor TSoundMenuItem.Create(AWindow: TCastleWindowBase;
  Menu: TCastleOnScreenMenu; ASoundEngine: TXmlSoundEngine);
begin
  inherited Create(AWindow, Menu);
  FSoundEngine := ASoundEngine;
end;

{ TSoundInfoMenuItem ------------------------------------------------------- }

function TSoundInfoMenuItem.Title: string;
begin
  Result := 'View sound information';
end;

procedure TSoundInfoMenuItem.Selected;
var
  S: TStringList;
begin
  S := TStringList.Create;
  try
    S.Append('Sound library (OpenAL) status:');
    S.Append('');
    Strings_AddSplittedString(S, SoundEngine.SoundInitializationReport, nl);

    MessageOK(Window, S, taLeft);
  finally S.Free end;
end;

{ TMenuVolumeSlider ---------------------------------------------------- }

constructor TMenuVolumeSlider.Create(const AValue: Single);
begin
  inherited Create(0, 1, AValue);
end;

function TMenuVolumeSlider.ValueToStr(const AValue: Single): string;
begin
  if AValue = 0.0 then
    Result := 'Off' else
    Result := inherited ValueToStr(AValue);
end;

{ TSoundVolumeMenuItem ----------------------------------------------------- }

constructor TSoundVolumeMenuItem.Create(AWindow: TCastleWindowBase; Menu: TCastleOnScreenMenu;
  ASoundEngine: TXmlSoundEngine);
begin
  FSlider := TMenuVolumeSlider.Create(ASoundEngine.Volume);
  inherited;
end;

function TSoundVolumeMenuItem.Title: string;
begin
  Result := 'Volume';
end;

function TSoundVolumeMenuItem.Accessory: TMenuAccessory;
begin
  Result := FSlider;
end;

procedure TSoundVolumeMenuItem.AccessoryValueChanged;
begin
  SoundEngine.Volume := Slider.Value;
end;

procedure TSoundVolumeMenuItem.RefreshAccessory;
begin
  Slider.Value := SoundEngine.Volume;
end;

{ TMusicVolumeMenuItem ----------------------------------------------------- }

constructor TMusicVolumeMenuItem.Create(AWindow: TCastleWindowBase; Menu: TCastleOnScreenMenu;
  ASoundEngine: TXmlSoundEngine);
begin
  FSlider := TMenuVolumeSlider.Create(ASoundEngine.MusicPlayer.MusicVolume);
  inherited;
end;

function TMusicVolumeMenuItem.Title: string;
begin
  Result := 'Music volume';
end;

function TMusicVolumeMenuItem.Accessory: TMenuAccessory;
begin
  Result := FSlider;
end;

procedure TMusicVolumeMenuItem.AccessoryValueChanged;
begin
  SoundEngine.MusicPlayer.MusicVolume := Slider.Value;
end;

procedure TMusicVolumeMenuItem.RefreshAccessory;
begin
  Slider.Value := SoundEngine.MusicPlayer.MusicVolume;
end;

end.
