unit GenericsUtils;

interface

uses
  Generics.Collections;

type
  TArrayHelper = class helper for TArray
  public
    class function Contains<T>(Values: array of T; const Item: T): Boolean;
  end;

  TDictionary<TKey,TValue> = class(Generics.Collections.TDictionary<TKey,TValue>)
  public
    type
      TPairType = TPair<TKey,TValue>;
  end;

implementation

{ TArrayHelper }

class function TArrayHelper.Contains<T>(Values: array of T; const Item: T): Boolean;
var
  FoundIndex: Integer;
begin
  Sort<T>(Values);
  Result := BinarySearch<T>(Values, Item, FoundIndex);
end;

end.
