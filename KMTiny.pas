unit KMTiny;

{$I-}

interface

uses
  Windows, SysUtils;

var
  QuoteChar: Char = #39;

type
  TFileVersionInfo = record
    CompanyName,
    FileDescription,
    FileVersion,
    InternalName,
    LegalCopyRight,
    LegalTradeMark,
    OriginalFileName,
    ProductName,
    ProductVersion,
    Comments: string;
    FileVersionMajor,
    FileVersionMinor,
    FileVersionRelease,
    FileVersionBuild,
    ProductVersionMajor,
    ProductVersionMinor,
    ProductVersionRelease,
    ProductVersionBuild: Word;
  end;

const
  CmdLineSwitchChar = '-';

function XMLDateToDateTime(XMLDate: string; var DateTime: TDateTime): Boolean;
function TryStrToWord(S: string; var W: Word): Boolean;
function SubStrExtract(S: string; Delimiter: string; Number: Integer): string;
function SubStrCount(S: string; SubString: string): Integer;
function SubStrPos(S: string; SubString: string; Number: Integer = 1): Integer;
function SubStrLeft(S: string; Delimiter: string): string;
function SubStrRight(S: string; Delimiter: string): string;
function AppendToFile(FileName: string; S: string): Boolean;
function GetAppVersionInfo(sAppNamePath: string; var FileVersionInfo: TFileVersionInfo): Boolean;
function KMFormat(Format: string; const Args: array of TVarRec): string;
function FindCmdLineArg(Swich: Char; Key: string; IgnoreCase: Boolean): Integer;
function GetCmdLineArgValue(Switch: Char; Key: string;
  IgnoreCase: Boolean): string;

function iif(Condition: Boolean; ResultT, ResultF: Variant): Variant;

implementation

function XMLDateToDateTime(XMLDate: string; var DateTime: TDateTime): Boolean;
var
  FS: TFormatSettings;
begin
  Result := Pos('T', XMLDate) > 0;
  if Result then
    begin
      FS.DateSeparator := '-';
      FS.TimeSeparator := ':';
      FS.ShortDateFormat := 'yyyy-mm-dd';
      FS.LongTimeFormat := 'Thh:mm:ss';
      XMLDate[Pos('T', XMLDate)] := ' ';
      try
        DateTime := StrToDateTime(XMLDate, FS);
      except
        Result := False;
      end;
    end
end;

function TryStrToWord(S: string; var W: Word): Boolean;
var
  i: Integer;
begin
  Result := TryStrToInt(S, i) and (i <= High(Word));
  if Result then
    W := Word(i);
end;

function SubStrExtract(S: string; Delimiter: string; Number: Integer): string;
var
  p1, p2: Integer;
begin
  S := Delimiter + S + Delimiter;
  p1 := SubStrPos(S, Delimiter, Number);
  p2 := SubStrPos(S, Delimiter, Number + 1);
  Result := Copy(S, p1 + Length(Delimiter), p2 - p1 - Length(Delimiter));
end;

function SubStrCount(S: string; SubString: string): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to (Length(S) - Length(SubString)) do
    if Copy(S, i, Length(SubString)) = SubString then
      Inc(Result);
end;

function SubStrPos(S: string; SubString: string; Number: Integer = 1): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(S) do
    if Copy(S, i, Length(SubString)) = SubString then
      begin
        Dec(Number);
        if Number = 0 then
          Result := i;
      end;
end;

function SubStrLeft(S: string; Delimiter: string): string;
begin
  Result := SubStrExtract(S, Delimiter, 1);
end;

function SubStrRight(S: string; Delimiter: string): string;
begin
  Result := SubStrExtract(S, Delimiter, SubStrCount(S, Delimiter) + 1);
end;

function AppendToFile(FileName: string; S: string): Boolean;
var
  F: TextFile;
begin
  Result := True;
  AssignFile(F, FileName);
  try
    if FileExists(FileName) then
      Append(F)
    else
      Rewrite(F);
    try
      Writeln(F, S);
    finally
      CloseFile(F);
    end;
  except
    Result := False;
  end;
end;

function GetAppVersionInfo(sAppNamePath: string; var FileVersionInfo: TFileVersionInfo): Boolean;
var
  VerSize: integer;
  VerBuf: PChar;
  VerBufValue: pointer;
  VerHandle: cardinal;
  VerBufLen: cardinal;
  VerKey: string; 

  function GetInfo(ThisKey: string): string; 
  begin 
    Result := '';
    VerKey := '\StringFileInfo\' + IntToHex(loword(integer(VerBufValue^)), 4) + 
    IntToHex(hiword(integer(VerBufValue^)), 4) + '\' + ThisKey; 
    if VerQueryValue(VerBuf, PChar(VerKey), VerBufValue, VerBufLen) then 
      Result := StrPas(VerBufValue); 
  end; 

  function QueryValue(ThisValue: string): string; 
  begin 
    Result := ''; 
    if GetFileVersionInfo(PChar(sAppNamePath), VerHandle, VerSize, VerBuf) and
      VerQueryValue(VerBuf, '\VarFileInfo\Translation', VerBufValue, VerBufLen) then
          Result := GetInfo(ThisValue);
  end;

  function ParsePEVersionStr(sVersion: string; var Major, Minor, Release, Build: Word): Boolean;
  begin
    Result := (SubStrCount(sVersion, '.') = 3) and
      (TryStrToWord(SubStrExtract(sVersion, '.', 1), Major))
        and
      (TryStrToWord(SubStrExtract(sVersion, '.', 2), Minor))
        and
      (TryStrToWord(SubStrExtract(sVersion, '.', 3), Release))
        and
      (TryStrToWord(SubStrExtract(sVersion, '.', 4), Build));
  end;

begin
  VerSize := GetFileVersionInfoSize(PChar(sAppNamePath), VerHandle);
  Result := VerSize > 0;
  if Result then
    with FileVersionInfo do
      begin
        try
          VerBuf := AllocMem(VerSize);
            try
              CompanyName      := QueryValue('CompanyName');
              FileDescription  := QueryValue('FileDescription');
              FileVersion      := QueryValue('FileVersion');
              InternalName     := QueryValue('InternalName');
              LegalCopyRight   := QueryValue('LegalCopyRight');
              LegalTradeMark   := QueryValue('LegalTradeMark');
              OriginalFileName := QueryValue('OriginalFileName');
              ProductName      := QueryValue('ProductName');
              ProductVersion   := QueryValue('ProductVersion');
              Comments         := QueryValue('Comments');
            finally
              FreeMem(VerBuf, VerSize);
            end;
        except
          Result := False;
        end;
        ParsePEVersionStr(FileVersion, FileVersionMajor, FileVersionMinor, FileVersionRelease, FileVersionBuild);
        ParsePEVersionStr(ProductVersion, ProductVersionMajor, ProductVersionMinor, ProductVersionRelease, ProductVersionBuild);
      end;
end;

function KMFormat(Format: string; const Args: array of TVarRec): string;
const
  CharSpec = '\c';
var
  i: Integer;
  c: Char;
begin
  Format := StringReplace(Format, '\n', sLineBreak, [rfReplaceAll]);
  Format := StringReplace(Format, '\t', chr(VK_TAB), [rfReplaceAll]);
  Format := StringReplace(Format, '\q', QuoteChar, [rfReplaceAll]);

  while Pos(CharSpec, Format) > 0 do
    begin
      i := Pos(CharSpec, Format);
      c := Chr(StrToInt('$' + Copy(Format, i + Length(CharSpec), 2)));
      Delete(Format, i, Length(CharSpec) + 2);
      Insert(c, Format, i);
    end;

  Result := SysUtils.Format(Format, Args);
end;


{function CmdLineKeyValue(KeyName: string; var KeyValue: string;
  IgnoreCase: Boolean; Switch: string; Delimiter: Char): Boolean; overload;
var
  i: Integer;
  SParam: string;
begin
  Result := False;
  KeyValue := '';
  if IgnoreCase then
      KeyName := UpperCase(KeyName);

  for i := 1 to ParamCount do
    begin
      if IgnoreCase then
        SParam := UpperCase(ParamStr(i))
      else
        SParam := ParamStr(i);
      Result := Pos(Switch + KeyName + Delimiter, SParam) = 1;
      if Result then
          KeyValue := Copy(ParamStr(i), Length(Switch) + Length(KeyName) + 2, Length(ParamStr(i)));
      if not Result then
        Result := Pos(Switch + KeyName, SParam) = 1;
    end;
end;}

function FindCmdLineArg(Swich: Char; Key: string; IgnoreCase: Boolean): Integer;
var
  i: Integer;
  Param: string;
begin
  Result := -1;
  if IgnoreCase then
    Key := UpperCase(Key);
  for i := 1 to ParamCount do
    begin
      if IgnoreCase then
        Param := UpperCase(ParamStr(i))
      else
        Param := ParamStr(i);
      if Param = (Swich + Key) then
        Result := i;
    end;
end;


function GetCmdLineArgValue(Switch: Char; Key: string;
  IgnoreCase: Boolean): string;
var
  _Pos: Integer;
begin
  Result := '';
  _Pos := FindCmdLineArg(Switch, Key, IgnoreCase);
  if _Pos > 0 then
    Result := ParamStr(_Pos + 1);
end;

function iif(Condition: Boolean; ResultT, ResultF: Variant): Variant;
begin
  if Condition then
    Result := ResultT
  else
    Result := ResultF;
end;

end.
