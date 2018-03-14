unit KMMath;

interface

function Min(Values: array of Extended): Extended; overload;
function Min(Values: array of Integer): Integer; overload;
function Max(Values: array of Extended): Extended; overload;
function Max(Values: array of Integer): Integer; overload;

implementation

function Min(Values: array of Extended): Extended;
var
  I: Integer;
begin
  Result := Values[0];
  for I := Low(Values) to High(Values) do
    if Values[I] < Result then
      Result := Values[I];
end;

function Min(Values: array of Integer): Integer;
var
  I: Integer;
begin
  Result := Values[0];
  for I := Low(Values) to High(Values) do
    if Values[I] < Result then
      Result := Values[I];
end;

function Max(Values: array of Extended): Extended;
var
  I: Integer;
begin
  Result := Values[0];
  for I := Low(Values) to High(Values) do
    if Values[I] > Result then
      Result := Values[I];
end;

function Max(Values: array of Integer): Integer;
var
  I: Integer;
begin
  Result := Values[0];
  for I := Low(Values) to High(Values) do
    if Values[I] > Result then
      Result := Values[I];
end;

end.
