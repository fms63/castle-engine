{
  Copyright 2008 Michalis Kamburelis.

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

{ KambiScript vector and matrix types and built-in functions. }
unit KambiScriptVectors;

interface

uses VectorMath, KambiScript;

type
  TKamScriptVec2f = class(TKamScriptValue)
  private
    class procedure HandleAdd(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleSubtract(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleNegate(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleEqual(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleNotEqual(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);

    class procedure HandleVector(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorGet(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorSet(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorGetCount(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorLength(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorSqrLength(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorDot(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);

    FValue: TVector2Single;
    procedure SetValue(const AValue: TVector2Single);
  public
    property Value: TVector2Single read FValue write SetValue;

    procedure AssignValue(Source: TKamScriptValue); override;
  end;

  TKamScriptVec3f = class(TKamScriptValue)
  private
    class procedure HandleAdd(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleSubtract(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleNegate(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleEqual(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleNotEqual(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);

    class procedure HandleVector(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorGet(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorSet(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorGetCount(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorLength(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorSqrLength(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorDot(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);

    class procedure HandleVectorCross(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);

    FValue: TVector3Single;
    procedure SetValue(const AValue: TVector3Single);
  public
    property Value: TVector3Single read FValue write SetValue;

    procedure AssignValue(Source: TKamScriptValue); override;
  end;

  TKamScriptVec4f = class(TKamScriptValue)
  private
    class procedure HandleAdd(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleSubtract(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleNegate(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleEqual(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleNotEqual(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);

    class procedure HandleVector(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorGet(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorSet(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorGetCount(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorLength(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorSqrLength(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
    class procedure HandleVectorDot(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);

    FValue: TVector4Single;
    procedure SetValue(const AValue: TVector4Single);
  public
    property Value: TVector4Single read FValue write SetValue;

    procedure AssignValue(Source: TKamScriptValue); override;
  end;

  TKamScriptVector = class(TKamScriptFunction)
  public
    class function Name: string; override;
    class function ShortName: string; override;
  end;

  TKamScriptVectorGet = class(TKamScriptFunction)
  public
    class function Name: string; override;
    class function ShortName: string; override;
  end;

  TKamScriptVectorSet = class(TKamScriptFunction)
  protected
    procedure CheckArguments; override;
  public
    class function Name: string; override;
    class function ShortName: string; override;
  end;

  TKamScriptVectorGetCount = class(TKamScriptFunction)
  public
    class function Name: string; override;
    class function ShortName: string; override;
  end;

  TKamScriptVectorLength = class(TKamScriptFunction)
  public
    class function Name: string; override;
    class function ShortName: string; override;
  end;

  TKamScriptVectorSqrLength = class(TKamScriptFunction)
  public
    class function Name: string; override;
    class function ShortName: string; override;
  end;

  TKamScriptVectorDot = class(TKamScriptFunction)
  public
    class function Name: string; override;
    class function ShortName: string; override;
  end;

  TKamScriptVectorCross = class(TKamScriptFunction)
  public
    class function Name: string; override;
    class function ShortName: string; override;
  end;

implementation

uses KambiScriptCoreFunctions, KambiUtils;

{$define VectorGetCount := 2}
{$define TKamScriptVecXx := TKamScriptVec2f}
{$define TVectorXxx := TVector2Single}
{$define RegisterVecXxFunctions := RegisterVec2fFunctions}
{$I kambiscriptvectors_implement_vector.inc}

{$define VectorGetCount := 3}
{$define TKamScriptVecXx := TKamScriptVec3f}
{$define TVectorXxx := TVector3Single}
{$define RegisterVecXxFunctions := RegisterVec3fFunctions}
{$I kambiscriptvectors_implement_vector.inc}

{$define VectorGetCount := 4}
{$define TKamScriptVecXx := TKamScriptVec4f}
{$define TVectorXxx := TVector4Single}
{$define RegisterVecXxFunctions := RegisterVec4fFunctions}
{$I kambiscriptvectors_implement_vector.inc}

class procedure TKamScriptVec3f.HandleVectorCross(AFunction: TKamScriptFunction; const Arguments: array of TKamScriptValue; var AResult: TKamScriptValue; var ParentOfResult: boolean);
begin
  CreateValueIfNeeded(AResult, ParentOfResult, TKamScriptVec3f);
  TKamScriptVec3f(AResult).Value :=
    VectorProduct( TKamScriptVec3f(Arguments[0]).Value,
                   TKamScriptVec3f(Arguments[1]).Value );
end;

{ TKamScriptFunction descendants --------------------------------------------- }

class function TKamScriptVector.Name: string;
begin
  Result := 'vector';
end;

class function TKamScriptVector.ShortName: string;
begin
  Result := 'vector';
end;

class function TKamScriptVectorGet.Name: string;
begin
  Result := 'vector_get';
end;

class function TKamScriptVectorGet.ShortName: string;
begin
  Result := 'vector_get';
end;

class function TKamScriptVectorSet.Name: string;
begin
  Result := 'vector_set';
end;

class function TKamScriptVectorSet.ShortName: string;
begin
  Result := 'vector_set';
end;

procedure TKamScriptVectorSet.CheckArguments;
begin
  inherited;
  if not ( (Args[0] is TKamScriptValue) and
           TKamScriptValue(Args[0]).Writeable ) then
    raise EKamScriptFunctionArgumentsError.Create('First argument of "vector_set" function is not a writeable operand');
end;

class function TKamScriptVectorGetCount.Name: string;
begin
  Result := 'vector_get_count';
end;

class function TKamScriptVectorGetCount.ShortName: string;
begin
  Result := 'vector_get_count';
end;

class function TKamScriptVectorLength.Name: string;
begin
  Result := 'vector_length';
end;

class function TKamScriptVectorLength.ShortName: string;
begin
  Result := 'vector_length';
end;

class function TKamScriptVectorSqrLength.Name: string;
begin
  Result := 'vector_sqr_length';
end;

class function TKamScriptVectorSqrLength.ShortName: string;
begin
  Result := 'vector_sqr_length';
end;

class function TKamScriptVectorDot.Name: string;
begin
  Result := 'vector_dot';
end;

class function TKamScriptVectorDot.ShortName: string;
begin
  Result := 'vector_dot';
end;

class function TKamScriptVectorCross.Name: string;
begin
  Result := 'vector_cross';
end;

class function TKamScriptVectorCross.ShortName: string;
begin
  Result := 'vector_cross';
end;

{ unit init/fini ------------------------------------------------------------- }

initialization
  RegisterVec2fFunctions;
  RegisterVec3fFunctions;
  RegisterVec4fFunctions;

  FunctionHandlers.RegisterHandler(@TKamScriptVec3f(nil).HandleVectorCross, TKamScriptVectorCross, [TKamScriptVec3f, TKamScriptVec3f], false);
end.
