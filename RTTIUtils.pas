unit RTTIUtils;

interface

uses
  System.TypInfo;

function IsOrdProp(PropInfo: PPropInfo): Boolean;
function CheckDefaultValue(AInstance: TObject; PropInfo: PPropInfo): Boolean;
{ TODO : подтипы определять не по символьному имени }
function TypeIsDateTime(const ATypeInfo: PTypeInfo): Boolean;
function TypeIsDate(const ATypeInfo: PTypeInfo): Boolean;
function TypeIsTime(const ATypeInfo: PTypeInfo): Boolean;
function TypeIsBoolean(const ATypeInfo: PTypeInfo): Boolean;

implementation

function TypeIsDateTime(const ATypeInfo: PTypeInfo): Boolean; //ToDo
begin
  Result := ATypeInfo^.TypeData^.BaseType = TypeInfo(TDateTime);
end;

function TypeIsDate(const ATypeInfo: PTypeInfo): Boolean; //ToDo
begin
  Result := ATypeInfo^.TypeData^.BaseType = TypeInfo(TDate);
end;

function TypeIsTime(const ATypeInfo: PTypeInfo): Boolean; //ToDo
begin
  Result := ATypeInfo^.TypeData^.BaseType = TypeInfo(TTime);
end;

function TypeIsBoolean(const ATypeInfo: PTypeInfo): Boolean;
begin
  Result := ATypeInfo^.TypeData^.BaseType = TypeInfo(Boolean);
end;

function IsOrdProp(PropInfo: PPropInfo): Boolean;
begin
  Result := (TypeIsBoolean(PropInfo.PropType^)) or (PropInfo^.PropType^^.Kind in
    [tkChar, tkAnsiChar, tkWChar, tkClass, tkInteger, tkClassRef, tkInt64]);
end;

function CheckDefaultValue(AInstance: TObject; PropInfo: PPropInfo): Boolean;
begin
  Result := not
    ((IsOrdProp(PropInfo))
      and
    (PropInfo.Default = GetOrdProp(AInstance, PropInfo)));
end;

end.
