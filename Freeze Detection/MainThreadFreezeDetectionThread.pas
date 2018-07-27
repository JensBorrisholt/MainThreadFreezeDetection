unit MainThreadFreezeDetectionThread;

interface

uses
  System.Classes, System.SysUtils, VCL.Forms, StackTraceU;

{$M+}

type
  TOnStackTrace = procedure(AStackTrace: TStackTrace) of object;
  TOnStackTraceReference = reference to procedure(AStackTrace: TStackTrace);

  TMainThreadFreezeDetectionThread = class;

  TMainThreadFreezeDetection = class(TComponent)
  strict private
    FFreezeDetection: TMainThreadFreezeDetectionThread;
    function GetActive: Boolean;
    function GetMainWindowHandle: THandle;
    function GetThreadID: THandle;
    procedure SetActive(const Value: Boolean);
    procedure SetFreezeTimeout(const Value: Cardinal);
    function GetFreezeTimeout: Cardinal;
  private
    function GetOnStackTrace: TOnStackTrace;
    function GetOnStackTraceReference: TOnStackTraceReference;
    procedure SetOnStackTrace(const Value: TOnStackTrace);
    procedure SetOnStackTraceReference(const Value: TOnStackTraceReference);
  published
    property Active: Boolean read GetActive write SetActive;
    property TargetThreadID: THandle read GetThreadID;
    property MainThreadHandle: THandle read GetMainWindowHandle;
    property FreezeTimeout: Cardinal read GetFreezeTimeout write SetFreezeTimeout;
    property OnStackTrace: TOnStackTrace read GetOnStackTrace write SetOnStackTrace;
    property OnStackTraceReference: TOnStackTraceReference read GetOnStackTraceReference write SetOnStackTraceReference;
  public
    constructor Create(AOwner: TForm); reintroduce;
    destructor Destroy; override;
  end;

  TMainThreadFreezeDetectionThread = class(TThread)
  strict private
    FMainWindowHandle: THandle;
    FThreadID: THandle;
    FActive: Boolean;
    FFreezeTimeout: Cardinal;
    FOnStackTrace: TOnStackTrace;
    FOnStackTraceReference: TOnStackTraceReference;
    procedure DoHandleStackTrace(AStackTrace: TStackTrace);
  protected
    procedure Execute; override;
  published
    property Active: Boolean read FActive write FActive;
    property FreezeTimeout: Cardinal read FFreezeTimeout write FFreezeTimeout;
    property TargetThreadID: THandle read FThreadID;
    property MainThreadHandle: THandle read FMainWindowHandle;
    property OnStackTrace: TOnStackTrace read FOnStackTrace write FOnStackTrace;
    property OnStackTraceReference: TOnStackTraceReference read FOnStackTraceReference write FOnStackTraceReference;
  public
    constructor Create(aMainWindowHandle: THandle; aThreadID: THandle = 0; aFreezeTimeout: Cardinal = MSecsPerSec * 5); reintroduce;
  end;

implementation

uses
  System.Diagnostics, System.TimeSpan, WinApi.Windows, WinApi.Messages;

{ TMainThreadFreezeDetectionThread }

constructor TMainThreadFreezeDetectionThread.Create(aMainWindowHandle: THandle; aThreadID: THandle = 0; aFreezeTimeout: Cardinal = MSecsPerSec * 5);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FMainWindowHandle := aMainWindowHandle;
  FFreezeTimeout := aFreezeTimeout;

  FThreadID := aThreadID;
  if FThreadID = 0 then
    FThreadID := GetCurrentThreadID;

  FActive := True;
end;

procedure TMainThreadFreezeDetectionThread.DoHandleStackTrace(AStackTrace: TStackTrace);
begin
  if Assigned(FOnStackTrace) then
    FOnStackTrace(AStackTrace);
  if Assigned(FOnStackTraceReference) then
    FOnStackTraceReference(AStackTrace);
end;

procedure TMainThreadFreezeDetectionThread.Execute;
var
  Frozen: Boolean;
  WaitResult: NativeUInt;
  StopWatch: TStopwatch;
  StackTrace: TStackTrace;
begin
  inherited;
  while not Terminated do
  begin
    Sleep(100);

    if (not FActive) or Terminated then
      continue;

    Frozen := (SendMessageTimeout(FMainWindowHandle, WM_NULL, 0, 0, SMTO_BLOCK, 50, @WaitResult) = 0) and (GetLastError = ERROR_TIMEOUT);

    if (not Frozen) or (not FActive) or Terminated then
    begin
      StopWatch.Reset;
      continue;
    end;

    if not StopWatch.IsRunning then
      StopWatch := TStopwatch.StartNew;

    if StopWatch.ElapsedMilliseconds >= FFreezeTimeout then
    begin
      StackTrace := TStackTrace.Create(False, FThreadID);
      try
        DoHandleStackTrace(StackTrace);
      finally
        StackTrace.free;
      end;

      StopWatch.Reset;
    end;
  end;
end;

{ TMainThreadFreezeDetection }

constructor TMainThreadFreezeDetection.Create(AOwner: TForm);
begin
  Assert(AOwner <> nil, 'Owner must ba a form');
  inherited Create(AOwner);
  FFreezeDetection := TMainThreadFreezeDetectionThread.Create(AOwner.Handle);
end;

destructor TMainThreadFreezeDetection.Destroy;
begin
  FFreezeDetection.Terminate;
  inherited;
end;

function TMainThreadFreezeDetection.GetActive: Boolean;
begin
  Result := FFreezeDetection.Active;
end;

function TMainThreadFreezeDetection.GetFreezeTimeout: Cardinal;
begin
  Result := FFreezeDetection.FreezeTimeout;
end;

function TMainThreadFreezeDetection.GetMainWindowHandle: THandle;
begin
  Result := FFreezeDetection.MainThreadHandle;
end;

function TMainThreadFreezeDetection.GetOnStackTrace: TOnStackTrace;
begin
  Result := FFreezeDetection.OnStackTrace;
end;

function TMainThreadFreezeDetection.GetOnStackTraceReference: TOnStackTraceReference;
begin
  Result := FFreezeDetection.OnStackTraceReference;
end;

function TMainThreadFreezeDetection.GetThreadID: THandle;
begin
  Result := FFreezeDetection.TargetThreadID;
end;

procedure TMainThreadFreezeDetection.SetActive(const Value: Boolean);
begin
  FFreezeDetection.Active := Value;
end;

procedure TMainThreadFreezeDetection.SetFreezeTimeout(const Value: Cardinal);
begin
  FFreezeDetection.FreezeTimeout := Value;
end;

procedure TMainThreadFreezeDetection.SetOnStackTrace(const Value: TOnStackTrace);
begin
  FFreezeDetection.OnStackTrace := Value;
end;

procedure TMainThreadFreezeDetection.SetOnStackTraceReference(const Value: TOnStackTraceReference);
begin
  FFreezeDetection.OnStackTraceReference := Value;
end;

end.
