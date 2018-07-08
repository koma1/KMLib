unit StringUtils;

interface

function SimpleInsert(const Source, Dest: string; Index: Integer): string; //выполняет то, что и должен выполнять стандартный Insert в Delphi, с которым без инета я так и не смог разобраться
//Trim's
function TrimLeftSubStr(const Source, SubStr: string): string; //убирает подстроку SubStr с левой части строки Source, если она там есть
function TrimRightSubStr(const Source, SubStr: string): string; //убирает подстроку SubStr с левой части строки Source, если она там есть
//coalesce's
function coalesce_str(const Arr: array of string): string;
function nvl_str(const str1, str2: string): string;

implementation

function SimpleInsert(const Source, Dest: string; Index: Integer): string;
begin
  Result := Copy(Source, 1, Index - 1)
      +
    Dest
      +
    Copy(Source, Index, Length(Source));
end;

function TrimLeftSubStr(const Source, SubStr: string): string;
begin
  if Pos(SubStr, Source) = 1 then
    Result := Copy(Source, 2, Length(Source));
end;

function TrimRightSubStr(const Source, SubStr: string): string;
begin
  if Copy(Source, Length(Source) - Length(SubStr) + 1, Length(SubStr)) = SubStr then
    Result := Copy(Source, 1, Length(Source) - Length(SubStr));
end;

function coalesce_str(const Arr: array of string): string;
var
  I: Integer;
begin
  Result := '';

  for I := Low(Arr) to High(Arr) do
    if Arr[I] <> '' then
      Exit(Arr[I]);
end;

function nvl_str(const str1, str2: string): string;
begin
  Result := coalesce_str([str1, str2]);
end;

end.
