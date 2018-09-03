unit KMObjects;

interface

uses
  System.SysUtils;

type
  TProgressEvent = procedure(Sender: TObject; Position: Integer; Max: Integer) of object;
  TExceptionNotifyEvent = procedure(Sender: TObject;
    const AException: Exception; var Handled: Boolean) of object;

implementation

end.
 