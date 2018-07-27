unit StackTraceU;

interface

uses
  Winapi.Windows,
  System.Classes;

type
  TStackTrace = class
  strict private
    FStakTrace: TStrings;
  public
    constructor Create(aRaw: Boolean; aThreadID: DWORD); reintroduce;
    destructor Destroy; override;
    property StakTrace: TStrings read FStakTrace;
  end;

implementation

uses
  System.Generics.Collections, System.SysUtils, System.Win.Registry, System.IOUtils,
  JCLDebug;

{ TStacktrace }
constructor TStackTrace.Create(aRaw: Boolean; aThreadID: DWORD);
var
  StackList: TJclStackInfoList;
  Info: TJclLocationInfo;
  i: Integer;
  Item: TJclStackInfoItem;
begin
  inherited Create;
  FStakTrace := TStringList.Create;

  StackList := nil;
  try
    StackList := JclCreateThreadStackTraceFromID(aRaw, aThreadID);
    StackList.AddToStrings(FStakTrace, True, True, True, True);

    for i := 0 to StackList.Count - 1 do
    begin
      Item := StackList.Items[i];
      GetLocationInfo(Item.CallerAddr, Info);
    end;
  finally
    StackList.Free;
  end;
end;

destructor TStackTrace.Destroy;
begin
  FStakTrace.Free;
  inherited;
end;

initialization

finalization

end.
