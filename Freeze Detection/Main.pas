unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, MainThreadFreezeDetectionThread,
  Vcl.ComCtrls;

type
  TMainForm = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation
uses
  StackTraceU;
{$R *.dfm}

procedure TMainForm.Button1Click(Sender: TObject);
begin
  Sleep(6000);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  with TMainThreadFreezeDetection.Create(Self) do
    OnStackTraceReference := procedure (AStackTrace: TStackTrace)
    begin
       Memo1.Lines.Assign(AStackTrace.StakTrace);
    end;
end;

end.
