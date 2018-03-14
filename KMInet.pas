unit KMInet;

interface

uses
  Windows, SysUtils, Classes, WinInet, KMTiny, KMSys;

const
  ContentLenHeaderName = 'Content-Length';

type
  TInternet = Pointer;

  EKMWinInet = class(Exception);

  EWinInet = class(Exception); //все ошибки WinInet'a

  EWINetwork = class(EWinInet); //сетевые ошибки

  EWIProtocol = class(EWinInet); //ошибки протокола

  EWIHTTP = class(EWIProtocol); //ошибки HTTP-протокола
  EWIFTP = class(EWIProtocol); //ошибки FTP-протокола

  TKMInetClient = class(TObject)
  private
    FContent: TStream;
    FResponseHeaders: TStringList;
    FBytesRead: Int64;
    function GetResponseCodeText: string;
    function GetResponseCode: Integer;
    function GetResponseHeaderByIndex(Index: Integer): string;
    function GetResponseHeaderByName(Name: string): string;
    function GetResponseHeadersCount: Integer;
    function GetResponseRaw: string;
    function GetResponseHeaderExists(Name: string): Boolean;
    function GetResponseHeaderIndex(Name: string): Integer;
    function GetContentLength: Int64;
  public
    constructor Create;
    procedure Get(URL: string);
    property Content: TStream read FContent write FContent;
    property ResponseHeadersCount: Integer read GetResponseHeadersCount;
    property ResponseHeaderExists[Name: string]: Boolean read GetResponseHeaderExists;
    property ResponseHeaderIndex[Name: string]: Integer read GetResponseHeaderIndex;
    property ResponseHeaderByName[Name: string]: string read GetResponseHeaderByName;
    property ResponseHeaderByIndex[Index: Integer]: string read GetResponseHeaderByIndex;
    property ResponseCode: Integer read GetResponseCode;
    property ResponseCodeText: string read GetResponseCodeText;
    property ResponseRaw: string read GetResponseRaw;
    property BytesRead: Int64 read FBytesRead;
    property ContentLength: Int64 read GetContentLength;
  end;

implementation

const
  BUF_SIZE = 81920;

var
  hInet: TInternet;

{ TKMInetClient }

constructor TKMInetClient.Create;
begin
  FResponseHeaders := TStringList.Create;
  FResponseHeaders.NameValueSeparator := ':';
end;

procedure TKMInetClient.Get(URL: string);
var
  URLComponents: TURLComponents;
  hReq: TInternet;
  BytesRead, Len: Cardinal;
  RawHeaders: string;
  Buff: Pointer;
  aURL: string;
begin
  FResponseHeaders.Clear;

  if not Assigned(Content) then
    raise EKMWinInet.Create('Content stream must be created!');

  Content.Size := 0;

  if URL = '' then
    raise EKMWinInet.Create('URL can not be empty!');

  if hInet = nil then
    raise EWinInet.Create(KMFormat('InternetOpen() failed!\n\n\q%s\q', [GetLastErrorText]));

  Len := INTERNET_MAX_URL_LENGTH;
  SetLength(aURL, Len);
  if not InternetCanonicalizeUrl(PChar(URL), @aURL[1], Len, ICU_BROWSER_MODE) then
    raise EWinInet.Create(KMFormat('InternetCanonicalizeUrl() failed!\n\n\q%s\q', [GetLastErrorText]));

  SetLength(aURL, Len);
  URL := aURL;

  ZeroMemory(@URLComponents, SizeOf(TURLComponents));
  URLComponents.dwStructSize := SizeOf(TURLComponents);
  if not InternetCrackURL(PChar(URL), Length(URL), 0, URLComponents) then
    raise EWinInet.Create(KMFormat('InternetCrackURL() failed!\n\n\q%s\q', [GetLastErrorText]));

  hReq := InternetOpenUrl(hInet, PChar(URL), nil, 0, 0, 0);
  if hReq = nil then
    raise EWINetwork.Create(KMFormat('InternetOpenUrl() failed!\n\n\q%s\q', [GetLastErrorText]));

    try
      BytesRead := 0;
      Len := 0;

      //если протокол - HTTP - запрашиваем HTTP-заголовки ответа
      if ((URLComponents.nScheme = INTERNET_SCHEME_HTTP) or (URLComponents.nScheme = INTERNET_SCHEME_HTTPS)) then
        if (not HttpQueryInfo(hReq, HTTP_QUERY_RAW_HEADERS_CRLF, @RawHeaders, Len, BytesRead)) and
           (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
            begin
              SetLength(RawHeaders, Len);
              if not HttpQueryInfo(hReq, HTTP_QUERY_RAW_HEADERS_CRLF, @RawHeaders[1], Len, BytesRead) then
                raise EWIHTTP.Create(KMFormat('HttpQueryInfo() failed!\n\n\q%s\q', [GetLastErrorText]));

              FResponseHeaders.Text := RawHeaders;
            end
        else
          raise EWIHTTP.Create(KMFormat('HttpQueryInfo() failed!\n\n\q%s\q', [GetLastErrorText]));

      FBytesRead := 0;

      GetMem(Buff, BUF_SIZE);
        try
          repeat
            if not InternetReadFile(hReq, Buff, BUF_SIZE, BytesRead) then
              raise EWINetwork.Create(KMFormat('InternetReadFile() failed!\n\n\q%s\q', [GetLastErrorText]));

            Inc(FBytesRead, BytesRead);
            Content.Size := Content.Size + BytesRead;
            Content.Write(Buff^, BytesRead);
          until BytesRead < 1;

          //Сравниваем размер загруженных данных с размером представленных данных (для HTTP)
          if ((URLComponents.nScheme = INTERNET_SCHEME_HTTP)
            or (URLComponents.nScheme = INTERNET_SCHEME_HTTPS)) then
          if (GetContentLength > -1) and (GetContentLength <> FBytesRead) then
            raise EKMWinInet.Create('Mismatch size between downloaded part and content size');
        finally
          FreeMem(Buff);
        end;
    finally
      InternetCloseHandle(hReq);
    end;
end;

function TKMInetClient.GetResponseCode: Integer;
var
  s: string;
begin
  s := GetResponseCodeText;
  s := Copy(s, 1, Pos(' ', s) - 1);

  Result := StrToIntDef(s, -1);
end;

function TKMInetClient.GetResponseCodeText: string;
begin
  if FResponseHeaders.Count > 0 then
    begin
      Result := FResponseHeaders[0];
      Result := Copy(Result, Pos(' ', Result) + 1, Length(Result));
    end
  else
    Result := '';
end;

function TKMInetClient.GetResponseHeaderIndex(Name: string): Integer;
var
  i: Integer;
begin
  Result := -1;

  with FResponseHeaders do
    if Count > 0 then
      for i := 1 to Count - 1 do
        if Names[i] = Name then
          Result := i - 1
end;

function TKMInetClient.GetResponseHeaderExists(Name: string): Boolean;
begin
  Result := GetResponseHeaderIndex(Name) > -1;
end;

function TKMInetClient.GetResponseHeaderByIndex(Index: Integer): string;
begin
  Result := Trim(FResponseHeaders.ValueFromIndex[Index + 1]);
end;

function TKMInetClient.GetResponseHeaderByName(Name: string): string;
begin
  Result := Trim(FResponseHeaders.Values[Name]);
end;

function TKMInetClient.GetResponseHeadersCount: Integer;
begin
  Result := FResponseHeaders.Count - 1;
end;

function TKMInetClient.GetResponseRaw: string;
begin
  Result := FResponseHeaders.Text;
end;

function TKMInetClient.GetContentLength: Int64;
begin
  if GetResponseHeaderExists(ContentLenHeaderName) then
    Result := StrToInt64Def(GetResponseHeaderByName(ContentLenHeaderName), -1)
  else
    Result := -1;
end;

initialization
begin
  hInet := InternetOpen(nil, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
end;

finalization
begin
  if hInet <> nil then
    InternetCloseHandle(hInet);
end;

end.
