program FreezeDetection;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  MainThreadFreezeDetectionThread in 'MainThreadFreezeDetectionThread.pas',
  StackTraceU in 'StackTraceU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  ReportMemoryLeaksOnShutdown := True;
  Application.Run;
end.
