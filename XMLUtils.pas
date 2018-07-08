// XML tiny utilites (KMLibrary)
// Andrey Komarov (C) 2018
unit XMLUtils;

interface

uses
  System.SysUtils;

function MakeXMLAttr(const AName, AValue: string): string;
function MakeXMLNode(const AName, AttributesText: string;
  const ChildNodesText: string = ''): string;
function DateTimeToXMLFormat(DateTime: TDateTime): string;

var
  XMLFormatSettings: TFormatSettings;

implementation

function MakeXMLAttr(const AName, AValue: string): string;
begin
  Result := Format('%s="%s"', [AName, AValue]);
end;

function MakeXMLNode(const AName, AttributesText: string;
  const ChildNodesText: string = ''): string;
begin
  if (AttributesText = '') and (ChildNodesText = '') then
    Result := '<' + AName + '/>' //empty node
  else if (ChildNodesText = '') then
    Result := '<' + AName + ' ' + AttributesText + '/>' //short node - node with attr's only
  else
    Result := '<' + AName + '>' + AttributesText + '</' + AName + '>' //full node with attr's and subnodes
end;

function DateTimeToXMLFormat(DateTime: TDateTime): string;
begin
  Result := DateTimeToStr(DateTime, XMLFormatSettings);
  Result := StringReplace(Result, ' ', ' T', []);
  Result := StringReplace(Result, ' T ', ' T', []);
end;

initialization
begin
  XMLFormatSettings.DateSeparator := '-';
  XMLFormatSettings.TimeSeparator := ':';
  XMLFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  XMLFormatSettings.LongTimeFormat := 'T h:mm:ss';
  XMLFormatSettings.DecimalSeparator := '.';
end;

end.
