program generate_x3d_nodes_to_pascal;

uses SysUtils, CastleParameters, CastleClassUtils, CastleStringUtils,
  CastleTimeUtils, CastleLog, CastleColors, CastleUtils,
  CastleApplicationProperties;

procedure GenerateOutput(const X3DNodeType, PascalNodeType,
  OutputInterface, OutputImplementation: string);
var
  OutputFileName: string;
begin
  OutputFileName := '../../auto_generated_node_helpers/x3dnodes_' +
    LowerCase(X3DNodeType) + '.inc';

  StringToFile(OutputFileName,
    '{ -*- buffer-read-only: t -*-' + NL +
    '' + NL +
    '  Copyright 2015-2017 Michalis Kamburelis.' + NL +
    '' + NL +
    '  This file is part of "Castle Game Engine".' + NL +
    '' + NL +
    '  "Castle Game Engine" is free software; see the file COPYING.txt,' + NL +
    '  included in this distribution, for details about the copyright.' + NL +
    '' + NL +
    '  "Castle Game Engine" is distributed in the hope that it will be useful,' + NL +
    '  but WITHOUT ANY WARRANTY; without even the implied warranty of' + NL +
    '  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.' + NL +
    '' + NL +
    '  ----------------------------------------------------------------------------' + NL +
    '}' + NL +
    '' + NL +
    '{ Automatically generated node properties.' + NL +
    '' + NL +
    '  Do not edit this file manually!' + NL +
    '  To add new properties, add them to text files in nodes_specification/components/ ,' + NL +
    '  and regenerate include files by running' + NL +
    '  nodes_specification/generate_x3d_nodes_to_pascal.lpr .' + NL +
    '' + NL +
    '  The documentation for properties should go to x3dnodes_documentation.txt . }' + NL +
    '' + NL +
    '{$ifdef read_interface}' + NL +
    NL +
    // 'type' + NL +
    OutputInterface +
    '{$endif read_interface}' + NL +
    '' + NL +
    '{$ifdef read_implementation}' + NL +
    NL +
    OutputImplementation +
    '{$endif read_implementation}' + NL
  );
end;

function FieldTypeX3DToPascal(const X3DName: string): string;
begin
  if X3DName = 'SFFloat' then
    Result := 'Single' else
  if X3DName = 'SFDouble' then
    Result := 'Double' else
  if X3DName = 'SFTime' then
    Result := 'TFloatTime' else
  if X3DName = 'SFVec2f' then
    Result := 'TVector2Single' else
  if X3DName = 'SFVec3f' then
    Result := 'TVector3Single' else
  if X3DName = 'SFVec4f' then
    Result := 'TVector4Single' else
  if X3DName = 'SFVec2d' then
    Result := 'TVector2Double' else
  if X3DName = 'SFVec3d' then
    Result := 'TVector3Double' else
  if X3DName = 'SFVec4d' then
    Result := 'TVector4Double' else
  if X3DName = 'SFInt32' then
    Result := 'Integer' else
  if X3DName = 'SFBool' then
    Result := 'boolean' else
  if X3DName = 'SFRotation' then
    Result := 'TVector4Single' else
  if X3DName = 'SFColor' then
    Result := 'TCastleColorRGB' else
  if X3DName = 'SFColorRGBA' then
    Result := 'TCastleColor' else
  // Note that many SFString are enums, and they should be converted to enums
  // in ObjectPascal. We capture enums outside of this function.
  if X3DName = 'SFString' then
    Result := 'string' else
  if X3DName = 'SFMatrix3f' then
    Result := 'TMatrix3Single' else
  if X3DName = 'SFMatrix4f' then
    Result := 'TMatrix4Single' else
//  if X3DName = 'SFNode' then // nope, because these should be typed accordingly in ObjectPascal
//    Result := 'TXxx' else
    Result := '';
end;

function FieldLooksLikeEnum(const Line: string; const Tokens: TCastleStringList): boolean;
var
  X3DFieldType{, X3DFieldName}: string;
begin
  X3DFieldType := Tokens[0];
  //X3DFieldName := Tokens[2];
  Result :=
    (X3DFieldType = 'SFString') and
    (Pos('["', Line) <> 0) and
   ((Pos('"]', Line) <> 0) or (Pos('...]', Line) <> 0));
  if Result then
    WritelnWarning('Input', 'Detected as enum, not converting ' + Line);
end;

function NodeTypeX3DToPascal(const X3DName: string): string;
begin
  Result := X3DName;
  if IsPrefix('X3D', X3DName) then
  begin
    { On X3DViewpointNode, we have both
      TAbstractX3DViewpointNode and TAbstractViewpointNode,
      to support also older VRML versions. Similar for grouping. }
    if (X3DName <> 'X3DViewpointNode') and
       (X3DName <> 'X3DGroupingNode') then
      Result := PrefixRemove('X3D', Result, true);
    Result := 'Abstract' + Result;
  end;
  Result := SuffixRemove('Node', Result, true);
  Result := 'T' + Result + 'Node';
end;

var
  NodePrivateInterface, NodePublicInterface, NodeImplementation: string;

procedure ProcessFile(const InputFileName: string);
var
  F: TTextReader;
  PosComment: Integer;
  Tokens: TCastleStringList;
  Line, LineWithComment, X3DNodeType, PascalNodeType,
    X3DFieldName, PascalFieldName, X3DFieldType, PascalFieldType,
    PascalFieldNameOriginal: string;
begin
  F := TTextReader.Create(InputFileName);
  try
    while not F.Eof do
    begin
      LineWithComment := F.Readln;
      Line := LineWithComment;
      { remove comments }
      PosComment := Pos('#', Line);
      if PosComment <> 0 then
        SetLength(Line, PosComment - 1);
      { avoid empty lines (after comment removal) }
      if Trim(Line) <> '' then
      begin
        Tokens := CreateTokens(Line);
        try
          { node start }
          if (Tokens.Count >= 2) and
             (Tokens[Tokens.Count - 1] = '{') and
             ((Tokens.Count = 2) or (Tokens[1] = ':')) then
          begin
            X3DNodeType := Tokens[0];
            PascalNodeType := NodeTypeX3DToPascal(X3DNodeType);
            // from 2 to Tokens.Count - 2 are ancestor names, just strip comma
            // X3DAncestorType... := SuffixRemove(',', Tokens[...]);
          end else
          { node end }
          if (Tokens.Count = 1) and
             (Tokens[0] = '}') then
           begin
             if (NodePrivateInterface <> '') or
                (NodePublicInterface <> '') or
                (NodeImplementation <> '') then
               Writeln(ErrOutput, 'NOTE: Node does not have any helpers (for now), generating empty include file: ' + X3DNodeType);

             if NodePrivateInterface <> '' then
               NodePrivateInterface := '  private' + NL + NodePrivateInterface;
             if NodePublicInterface <> '' then
               NodePublicInterface := '  public' + NL + NodePublicInterface;

             GenerateOutput(X3DNodeType, PascalNodeType,
               // '  ' + PascalNodeType + 'Helper = class helper for ' + PascalNodeType + NL +
               NodePrivateInterface +
               NodePublicInterface +
               // '  end;' + NL +
               NL,
               '{ ' + PascalNodeType + ' ----------------------------------------------- }' + NL +
               NL +
               NodeImplementation);

             X3DNodeType := '';
             NodePrivateInterface := '';
             NodePublicInterface := '';
             NodeImplementation := '';
           end else
           { field/event inside node }
           if (Tokens.Count >= 3) and
              (FieldTypeX3DToPascal(Tokens[0]) <> '') then
           begin
             if FieldLooksLikeEnum(LineWithComment, Tokens) then
               Continue;
             X3DFieldName := Tokens[2];
             if (X3DFieldName = 'solid') or
                (X3DFieldName = 'repeatS') or
                (X3DFieldName = 'repeatT') or
                (X3DFieldName = 'cycleInterval') or
                ((X3DFieldName = 'position') and (X3DNodeType = 'Viewpoint')) or
                ((X3DFieldName = 'position') and (X3DNodeType = 'OrthoViewpoint')) or
                ((X3DFieldName = 'position') and (X3DNodeType = 'GeoViewpoint')) or
                ((X3DFieldName = 'orientation') and (X3DNodeType = 'X3DViewpointNode')) or
                ((X3DFieldName = 'magnificationFilter') and (X3DNodeType = 'TextureProperties')) or
                ((X3DFieldName = 'minificationFilter') and (X3DNodeType = 'TextureProperties')) or
                (X3DFieldName = 'linetype')
                // TODO: bboxCenter and bboxSize should also be removed from here someday,
                // we should convert them manually to BBox: TBox3D to support our TBox3D type.
                then
             begin
               Writeln(ErrOutput, 'NOTE: Not processing, this field has special implementation: ' + X3DFieldName);
               Continue;
             end;
             if (X3DNodeType = 'X3DMetadataObject') or
                (X3DNodeType = 'X3DFogObject') or
                (X3DNodeType = 'X3DPickableObject') or
                (X3DNodeType = 'LOD') then
             begin
               Writeln(ErrOutput, 'NOTE: Not processing, this node has special implementation: ' + X3DNodeType);
               Continue;
             end;
             PascalFieldName := X3DFieldName;

             { rename some field names to avoid collisions }
             if PascalFieldName = 'on' then
               PascalFieldName := 'IsOn'
             else
             if PascalFieldName = 'name' then
               PascalFieldName := 'NameField';

             PascalFieldName[1] := UpCase(PascalFieldName[1]);
             PascalFieldNameOriginal := X3DFieldName;
             PascalFieldNameOriginal[1] := UpCase(PascalFieldNameOriginal[1]);
             PascalFieldNameOriginal := 'Fd' + PascalFieldNameOriginal;
             X3DFieldType := Tokens[0];
             PascalFieldType := FieldTypeX3DToPascal(X3DFieldType);
             if (Tokens[1] <> '[in,out]') and
                (Tokens[1] <> '[]') then
             begin
               WritelnWarning('Input', 'Only fields (inputOutput or initializeOnly) are supported now: ' + X3DFieldName);
               Continue;
             end;
             if X3DNodeType = '' then
             begin
               WritelnWarning('Input', 'Field found, but not inside a node: ' + X3DFieldName);
               Continue;
             end;
             NodePrivateInterface +=
               '    function Get' + PascalFieldName + ': ' + PascalFieldType + ';' + NL +
               '    procedure Set' + PascalFieldName + '(const Value: ' + PascalFieldType + ');' + NL;
             NodePublicInterface +=
               '    property ' + PascalFieldName + ': ' + PascalFieldType + ' read Get' + PascalFieldName + ' write Set' + PascalFieldName + ';' + NL;
             NodeImplementation +=
               'function ' + PascalNodeType + '.Get' + PascalFieldName + ': ' + PascalFieldType + ';' + NL +
               'begin' + NL +
               '  Result := ' + PascalFieldNameOriginal + '.Value;' + NL +
               'end;' + NL +
               NL +
               'procedure ' + PascalNodeType + '.Set' + PascalFieldName + '(const Value: ' + PascalFieldType + ');' + NL +
               'begin' + NL +
               '  ' + PascalFieldNameOriginal + '.Send(Value);' + NL +
               'end;' + NL +
               NL;
           end else
           begin
             WritelnWarning('Input', 'Line not understood, possibly field type not handled: ' + Line);
             Continue;
           end;
        finally FreeAndNil(Tokens) end;
      end;
    end;
  finally FreeAndNil(F) end;
end;

var
  I: Integer;
begin
  ApplicationProperties.OnWarning.Add(@ApplicationProperties.WriteWarningOnConsole);

  NodePrivateInterface := '';
  NodePublicInterface := '';
  NodeImplementation := '';

  Parameters.CheckHighAtLeast(1);
  for I := 1 to Parameters.High do
    ProcessFile(Parameters[I]);
end.
