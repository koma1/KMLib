unit Math.Combinatory;

//http://studlab.com/news/sochetanija/2011-12-02-254

interface

type
  TBoolArr = array of Boolean;
  TBool2D = array of TBoolArr;

function GetCombinations(_n: Integer; _k: Integer): TBool2D;

implementation

const
 n1=100;
type
 TIntArrN1=array[1..n1] of integer;

var
  n, k: Integer;
  Bool2D: TBool2D;

procedure _Add(var Bool2D: TBool2D; const BoolRec: array of Boolean);
var
  J: Integer;
begin
    SetLength(Bool2D, Length(Bool2D) + 1);
    SetLength(Bool2D[High(Bool2D)], Length(BoolRec));
    for J := Low(BoolRec) to High(BoolRec) do
      Bool2D[High(Bool2D)][J] := BoolRec[J];
end;

procedure output_p(x: TIntArrN1; k: Integer);
var
  e: Integer;
  b: array of Boolean;
begin
  SetLength(b, n);
  for e := 1 to k do
    b[x[e] - 1] := True;
  _Add(Bool2D, b);
end;

function GetCombinations(_n: Integer; _k: Integer): TBool2D;
var
 x,min,max : TIntArrN1;
 i,j:integer;
begin
  Bool2D := nil;

  n := _n;
  k := _k;

  i := 0;

  for j:=1 to _k do
  begin
    max[j]:=_n-j+1;
    min[j]:=_k-j+1;
    x[j]:=min[j]
  end;

  while i<=_k do
  begin
    output_p(x, k);

    i:=1;
    while (i<=_k) and (x[i]=max[i]) do i:=i+1;
    if i<=_k then x[i]:=x[i]+1;
    for j:=i-1 downto 1 do
    begin
      min[j]:= x[j+1]+1;
      x[j]:=min[j]
    end
  end;

  Result := Bool2D;
end;

end.
