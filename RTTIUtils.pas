unit RTTIUtils;

interface

uses
  System.TypInfo;

function IsOrdProp(PropInfo: PPropInfo): Boolean;
function CheckDefaultValue(AInstance: TObject; PropInfo: PPropInfo): Boolean;
{ TODO : может инфу тут надо брать о BaseType'e? }
function IsDateTimeProp(const PropInfo: PPropInfo): Boolean;
function IsDateProp(const PropInfo: PPropInfo): Boolean;
function IsTimeProp(const PropInfo: PPropInfo): Boolean;
function IsBooleanProp(PropInfo: PPropInfo): Boolean;

implementation

function IsDateTimeProp(const PropInfo: PPropInfo): Boolean; //ToDo
begin
  Result := (PropInfo.PropType^^.Name = 'TDateTime');
end;

function IsDateProp(const PropInfo: PPropInfo): Boolean; //ToDo
begin
  Result := (PropInfo.PropType^^.Name = 'TDate')
end;

function IsTimeProp(const PropInfo: PPropInfo): Boolean; //ToDo
begin
  Result := (PropInfo.PropType^^.Name = 'TTime');
end;

function IsBooleanProp(PropInfo: PPropInfo): Boolean;
begin
  Result := PropInfo.PropType^^.TypeData^.BaseType = TypeInfo(Boolean);
end;

function IsOrdProp(PropInfo: PPropInfo): Boolean;
begin
  Result := (IsBooleanProp(PropInfo)) or (PropInfo^.PropType^^.Kind in
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
