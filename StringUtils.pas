unit StringUtils;

interface

function RandomString(MinLen, MaxLen: Integer): string; //���������� ��������� ����� ��������� �������� (���. �������, �������� � ���������)
function GetRandomString(StrArray: array of string): string; //��������� ������� �������� ������������ ������ �� �������
function SimpleInsert(const Source, Dest: string; Index: Integer): string; //��������� ��, ��� � ������ ��������� ����������� Insert � Delphi, � ������� ��� ����� � ��� � �� ���� �����������
//Trim's
function TrimLeftSubStr(const Source, SubStr: string): string; //������� ��������� SubStr � ����� ����� ������ Source, ���� ��� ��� ����
function TrimRightSubStr(const Source, SubStr: string): string; //������� ��������� SubStr � ����� ����� ������ Source, ���� ��� ��� ����
//coalesce's
function coalesce_str(const Arr: array of string): string;
function nvl_str(const str1, str2: string): string;

implementation

function RandomString(MinLen, MaxLen: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := MinLen to Random(MaxLen - MinLen) + MinLen do
    Result := Result + Chr( Random(Ord('Z') - Ord('a')) + Ord('a') );
end;

function GetRandomString(StrArray: array of string): string;
begin
  Result := StrArray[Random(Length(StrArray) - 1) + 1];
end;

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
