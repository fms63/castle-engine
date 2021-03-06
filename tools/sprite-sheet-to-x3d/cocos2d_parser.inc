procedure Cocos2DParser;
  procedure ReadQuad(const ASrc: string; out V1, V2, V3, V4: integer);
  var
    R: TRegExpr;
  begin
    R := TRegExpr.Create;
    try
      R.Expression := '{{(\d+),(\d+)},{(\d+),(\d+)}}';
      if R.Exec(ASrc) and (R.SubExprMatchCount = 4) then
      begin
        V1 := StrToInt(R.Match[1]);
        V2 := StrToInt(R.Match[2]);
        V3 := StrToInt(R.Match[3]);
        V4 := StrToInt(R.Match[4]);
      end;
    finally
      FreeAndNil(R);
    end;
  end;

  procedure ReadDual(const ASrc: string; out V1, V2: integer);
  var
    R: TRegExpr;
  begin
    R := TRegExpr.Create;
    try
      R.Expression := '{(\d+),(\d+)}';
      if R.Exec(ASrc) and (R.SubExprMatchCount = 2) then
      begin
        V1 := StrToInt(R.Match[1]);
        V2 := StrToInt(R.Match[2]);
      end;
    finally
      FreeAndNil(R);
    end;
  end;

  procedure ReadDual(const ASrc: string; out V1, V2: single);
  var
    R: TRegExpr;
  begin
    R := TRegExpr.Create;
    try
      R.Expression := '{(\d+.*\d*),(\d+.*\d*)}';
      if R.Exec(ASrc) and (R.SubExprMatchCount = 2) then
      begin
        V1 := StrToFloat(R.Match[1]);
        V2 := StrToFloat(R.Match[2]);
      end;
    finally
      FreeAndNil(R);
    end;
  end;

var
  Doc: TXMLDocument;
  Dict, N, N2, N3: TDOMElement;
  AniName,
  Key: string;
  Frame: TFrame;
  HasAnchor,
  HasOriginFrame: boolean;
  X, Y, W, H, OW, OH, FX, FY, FW, FH: integer;
  AX, AY: single;
begin
  Doc := URLReadXML(SSFullPath);
  try
    Dict := Doc.FindNode('plist').FirstChild as TDOMElement;
    N := Dict.FirstChild as TDOMElement;
    while N <> nil do
    begin
      if N.TextContent = 'frames' then
      begin
        N := N.NextSibling as TDOMElement;
        N2 := N.FirstChild as TDOMElement;
        while N2 <> nil do
        begin
          if N2.NodeName = 'key' then
          begin
            AniName := N2.TextData;
          end
          else
          if N2.NodeName = 'dict' then
          begin
            N3 := N2.FirstChild as TDOMElement;
            AX := 0.5;
            AY := 0.5;
            HasAnchor := false;
            HasOriginFrame := false;
            while N3 <> nil do
            begin
              if (N3.TextContent = 'frame') or (N3.TextContent = 'textureRect') then
              begin
                N3 := N3.NextSibling as TDOMElement;
                ReadQuad(N3.TextData, X, Y, W, H);
              end
              else
              if N3.TextContent = 'sourceColorRect' then
              begin
                N3 := N3.NextSibling as TDOMElement;
                ReadQuad(N3.TextData, FX, FY, FW, FH);
                HasOriginFrame := true;
              end
              else
              if N3.TextContent = 'anchor' then
              begin
                N3 := N3.NextSibling as TDOMElement;
                ReadDual(N3.TextData, AX, AY);
                HasAnchor := true;
              end
              else
              if N3.TextContent = 'sourceSize' then
              begin
                N3 := N3.NextSibling as TDOMElement;
                ReadDual(N3.TextData, OW, OH);
              end;
              N3 := N3.NextSibling as TDOMElement;
            end;
            Frame.X1 := X;
            Frame.Y1 := Y;
            Frame.W := W;
            Frame.H := H;
            Frame.X2 := X + W;
            Frame.Y2 := Y + H;
            if HasAnchor then
            begin
              Frame.AX := AX;
              Frame.AY := AY;
            end
            else
            if HasOriginFrame then
            begin
              CalculateAnchor(FX, FY, OW, OH,
                  X, Y, Frame.W, Frame.H,
                  Frame.AX, Frame.AY);
            end;
            KeyParser(AniName, Key);
            AddFrame(Key, Frame);
          end;
          N2 := N2.NextSibling as TDOMElement;
        end;
      end
      else
      if N.TextContent = 'metadata' then
      begin
        N := N.NextSibling as TDOMElement;
        N2 := N.FirstChild as TDOMElement;
        while N2 <> nil do
        begin
          if (N2.TextContent = 'textureFileName') then
          begin
            N2 := N2.NextSibling as TDOMElement;
            Meta.Name := N2.TextData;
            ReadMeta(Meta);
          end;
          N2 := N2.NextSibling as TDOMElement;
        end;
      end;
      N := N.NextSibling as TDOMElement;
    end;
  finally
    FreeAndNil(Doc);
  end;
end;
