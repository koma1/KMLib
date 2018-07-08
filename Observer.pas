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
    property EventObject: TObject read GetObject; //объект, в котором произошло событие
  end;

  TEvent = class(TInterfacedObject, IEvent) //событие над объектом
  private
    FObject: TObject; //объект, в котором произошло событие
    function GetObject: TObject;
  public
    constructor Create(AObject: TObject);
    property AObject: TObject read GetObject;
  end;
  TEventClass = class of TEvent;

  TEventObjectFree = class(TEvent); //событие разрушения объекта AObject

  TEventObjectModified = class(TEvent); //событие изменения объекта AObject

  IObserver = interface //наблюдатель
    procedure Event(Event: TEvent); //случилось событие - тут мы его получаем и обрабатываем
  end;

  IObservable = interface //наблюдаемое
    procedure SendNotify(Event: IEvent); //разошлем всем подписчикам событие
    procedure SubscribeEvent(Observer: IObserver; EventClass: TEventClass); //подписаться на тип события
    procedure UnsubscribeEvent(Observer: IObserver; EventClass: TEventClass); //отписаться от уведомлений
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
    procedure SendNotify(Event: IEvent); //случилось событие AEvent - разошлем всем подписчикам
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
