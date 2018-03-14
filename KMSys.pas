unit KMSys;

interface

uses
  Windows, SysUtils;

function GetLastErrorText: string;

implementation

function GetLastErrorText: string;
begin
  Result := SysErrorMessage(GetLastError);
end;

end.
