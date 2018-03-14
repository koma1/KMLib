unit KMRegistry;

interface

uses
  Windows, Registry;

function GetRegString(Root: HKEY; Key: string; Name: string): string;

implementation

var
  RegReader, RegWritter: TRegistry;

function GetRegString(Root: HKEY; Key: string; Name: string): string;
begin
  RegReader.RootKey := Root;
  try
    RegReader.OpenKey(Key, False);
    Result := RegReader.ReadString(Name);
  finally
    RegReader.CloseKey;
  end;
end;

initialization
begin
  RegReader := TRegistry.Create(KEY_QUERY_VALUE);
  RegWritter := TRegistry.Create(KEY_ALL_ACCESS);
end;

finalization
begin
  RegReader.Free;
  RegWritter.Free;
end;

end.
