unit Observer;

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  ///
  /// EVENTS
  ///

  IEvent = interface
    function GetObject: TObject;
    property EventObject: TObject read GetObject; //������, � ������� ��������� �������
  end;

  TEvent = class(TInterfacedObject, IEvent) //������� ��� ��������
  private
    FObject: TObject; //������, � ������� ��������� �������
    function GetObject: TObject;
  public
    constructor Create(AObject: TObject);
    property AObject: TObject read GetObject;
  end;
  TEventClass = class of TEvent;

  TEventObjectFree = class(TEvent); //������� ���������� ������� AObject

  TEventObjectModified = class(TEvent); //������� ��������� ������� AObject

  IObserver = interface //�����������
    procedure Event(Event: TEvent); //��������� ������� - ��� �� ��� �������� � ������������
  end;

  IObservable = interface //�����������
    procedure SendNotify(Event: IEvent); //�������� ���� ����������� �������
    procedure SubscribeEvent(Observer: IObserver; EventClass: TEventClass); //����������� �� ��� �������
    procedure UnsubscribeEvent(Observer: IObserver; EventClass: TEventClass); //���������� �� �����������
    procedure RemoveObserver(Observer: IObserver);
  end;

  TObservableEvent = TPair<IObserver, TEventClass>;

  TObservableEventList = class
  private
    FList: TList<TObservableEvent>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(AObserver: IObserver; EventClass: TEventClass);
    procedure Remove(AObserver: IObserver; EventClass: TEventClass);
    procedure RemoveObserver(AObserver: IObserver);
    procedure SendNotify(Event: IEvent); //��������� ������� AEvent - �������� ���� �����������
  end;

implementation

{ TObservableEvents }

constructor TObservableEventList.Create;
begin
  FList := TList<TObservableEvent>.Create;
end;

destructor TObservableEventList.Destroy;
begin
  FList.Free;

  inherited;
end;

procedure TObservableEventList.Add(AObserver: IObserver; EventClass: TEventClass);
var
  ObservableEvent: TObservableEvent;
begin
  ObservableEvent := TObservableEvent.Create(AObserver, EventClass);

  if not FList.Contains(ObservableEvent) then
    FList.Add(ObservableEvent);
end;

procedure TObservableEventList.Remove(AObserver: IObserver; EventClass: TEventClass);
begin
  FList.Remove(TObservableEvent.Create(AObserver, EventClass));
end;

procedure TObservableEventList.RemoveObserver(AObserver: IObserver);
var
  Item: TObservableEvent;
begin
  for Item in FList do
    if Item.Key = AObserver then
      FList.Remove(Item);
end;

procedure TObservableEventList.SendNotify(Event: IEvent);
var
  Item: TObservableEvent;
begin
  for Item in FList do
    if (Event is TEvent) and (TEvent(Event).InheritsFrom(Item.Value)) then
      Item.Key.Event(TEvent(Event));
end;

{ TEvent }

constructor TEvent.Create(AObject: TObject);
begin
  FObject := AObject;
end;

function TEvent.GetObject: TObject;
begin
  Result := FObject;
end;

end.
