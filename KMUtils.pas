unit KMUtils;

interface

uses
  Windows, SysUtils, Controls, StdCtrls, DateUtils, KMTiny, Classes, ExtCtrls,
  Clipbrd, Graphics;

var
  BorderSize: Integer = 8;

function GetWindowText(Window: THandle): string;
function AppMessage(Text: string; Flags: Integer): Integer; overload;
function AppMessage(Format: string; const Args: array of TVarRec;
  Flags: Integer): Integer; overload;
function QuestionBox(Text: string): Boolean; overload;
function QuestionBox(Format: string; const Args: array of TVarRec): Boolean; overload;
procedure WarningBox(Text: string); overload;
procedure WarningBox(Format: string; const Args: array of TVarRec); overload;
procedure InfoBox(Text: string); overload;
procedure InfoBox(Format: string; const Args: array of TVarRec); overload;
procedure ErrorBox(Text: string); overload;
procedure ErrorBox(Format: string; const Args: array of TVarRec); overload;
procedure FatalError(Text: string; ExitCode: Integer = 0); overload;
procedure FatalError(Format: string; const Args: array of TVarRec;
  ExitCode: Integer = 0); overload;
function GetMyInternalName: string;

//function CopyTextToClipboard(Text: string);

procedure AutoSizeControl(Control: TWinControl);
procedure SetEditEnabledState(Edit: TCustomEdit; Enabled: Boolean);
function FullMonthsBetween(ANow, AThen: TDate): Cardinal;

procedure CopyTextToClipboard(Text: string);
function PasteTextFromClipboard: string;

function FindItemByText(ListControl: TCustomListControl; ItemText: string): Integer;
function SetItemByText(ListControl: TCustomListControl; ItemText: string): Integer;

implementation

var
  CB :TClipboard;

function GetWindowText(Window: THandle): string;
var
  Len: Integer;
  P: PChar;
begin
  Len := Windows.GetWindowTextLength(Window);

  GetMem(P, Len);
    try
      Windows.GetWindowText(Window, P, Len);
      Result := P;
    finally
      FreeMem(P);
    end;
end;

function AppMessage(Text: string; Flags: Integer): Integer; overload;
begin
  Result := MessageBox(GetForegroundWindow, PChar(Text),
    PChar(GetWindowText(GetForegroundWindow)), Flags or MB_APPLMODAL);
end;

function AppMessage(Format: string; const Args: array of TVarRec;
  Flags: Integer): Integer; overload;
begin
  Result := AppMessage(KMFormat(Format, Args), Flags);
end;

procedure WarningBox(Text: string); overload;
begin
  AppMessage(Text, MB_OK or MB_ICONWARNING);
end;

procedure WarningBox(Format: string; const Args: array of TVarRec); overload;
begin
  WarningBox(KMFormat(Format, Args));
end;

procedure ErrorBox(Text: string); overload;
begin
  AppMessage(Text, MB_OK or MB_ICONERROR);
end;

procedure ErrorBox(Format: string; const Args: array of TVarRec); overload;
begin
  ErrorBox(KMFormat(Format, Args));
end;

procedure InfoBox(Text: string); overload;
begin
  AppMessage(Text, MB_OK or MB_ICONINFORMATION);
end;

procedure InfoBox(Format: string; const Args: array of TVarRec); overload;
begin
  InfoBox(KMFormat(Format, Args));
end;

function QuestionBox(Text: string): Boolean; overload;
begin
  Result := (AppMessage(Text, MB_YESNO or MB_ICONQUESTION) = mrYes);
end;

function QuestionBox(Format: string; const Args: array of TVarRec): Boolean; overload;
begin
  Result := QuestionBox(KMFormat(Format, Args));
end;

procedure FatalError(Text: string; ExitCode: Integer = 0); overload;
begin
  ErrorBox(Text);
  ExitProcess(ExitCode);
end;

procedure FatalError(Format: string; const Args: array of TVarRec;
  ExitCode: Integer = 0); overload;
begin
  FatalError(KMFormat(Format, Args), ExitCode);
end;

function GetMyInternalName: string;
var
  rs:TResourceStream;
  m:TMemoryStream;
  p:pointer;
  s:cardinal;
begin
  m:=TMemoryStream.Create;
  try
    rs:=TResourceStream.CreateFromID(HInstance,1,RT_VERSION);
    try
      m.CopyFrom(rs,rs.Size);
    finally
      rs.Free;
    end;
    m.Position:=0;
    if VerQueryValue(m.Memory,PChar('\\StringFileInfo\\'+
      IntToHex(GetThreadLocale,4)+IntToHex(GetACP,4)+'\\InternalName'),p,s) or
        VerQueryValue(m.Memory,'\\StringFileInfo\\040904E4\\InternalName',p,s) then //en-us
          Result:=PChar(p)+' '+Result;
  finally
    m.Free;
  end;
end;

procedure AutoSizeControl(Control: TWinControl);
var
  i: Integer;
  Height, Width: Integer;
begin
  Height := 0;
  Width := 0;
  for i := 0 to Control.ControlCount - 1 do
    begin
      if (Control.Controls[i].Top + Control.Controls[i].Height) > Height then
        Height := Control.Controls[i].Top + Control.Controls[i].Height;
      if (Control.Controls[i].Left + Control.Controls[i].Width) > Width then
        Width := Control.Controls[i].Left + Control.Controls[i].Width;
    end;
  Control.Height := Height + BorderSize;
  Control.Width := Width + BorderSize;
end;

procedure SetEditEnabledState(Edit: TCustomEdit; Enabled: Boolean);
begin
  Edit.Enabled := Enabled;
  if Enabled then
    TEdit(Edit).Color := clWindow
  else
    TEdit(Edit).Color := clBtnFace;
end;

function FindItemByText(ListControl: TCustomListControl; ItemText: string): Integer;
var
  i: Integer;
begin
  Result := -1;

  if (ListControl is TCustomCombo) then
    for i := 0 to TCustomCombo(ListControl).Items.Count - 1 do
      if TCustomCombo(ListControl).Items[i] = ItemText then
        begin
          Result := i;
          Exit;
        end;
        
  if (ListControl is TCustomListBox) then
    for i := 0 to TCustomListBox(ListControl).Items.Count - 1 do
      if TCustomListBox(ListControl).Items[i] = ItemText then
        begin
          Result := i;
          Exit;
        end;
end;

function SetItemByText(ListControl: TCustomListControl; ItemText: string): Integer;
begin
  Result := FindItemByText(ListControl, ItemText);
  ListControl.ItemIndex := Result;
end;

function FullMonthsBetween(ANow, AThen: TDate): Cardinal;
var
  Y1, M1, Y2, M2, X: Word;
begin
  DecodeDateTime(ANow, Y1, M1, X, X, X, X, X);
  DecodeDateTime(AThen, Y2, M2, X, X, X, X, X);
  Result := abs((Y1 * MonthsPerYear + M1) - (Y2 * MonthsPerYear + M2));
end;

procedure CopyTextToClipboard(Text: string);
begin
  CB.AsText := Text;
end;

function PasteTextFromClipboard: string;
begin
  Result := CB.AsText;
end;

initialization
begin
  CB := TClipboard.Create;
end;

finalization
begin
  CB.Free;
end;

end.
