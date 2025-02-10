unit uStartModelLog;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Effects,
  FMX.Objects, FMX.Layouts;

type
  TStartModelLog = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Rectangle1: TRectangle;
    ShadowEffect2: TShadowEffect;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FAction: TProc;
  public
    function Show(const AContinueAction: TProc): TProc<string>; reintroduce;
    procedure Done();
  end;

var
  StartModelLog: TStartModelLog;

implementation

uses
  uMainForm;

{$R *.fmx}

{ TStartModelLog }

procedure TStartModelLog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

function TStartModelLog.Show(const AContinueAction: TProc): TProc<string>;
begin
  inherited Show();

  FAction := AContinueAction;

  Result := procedure(ALog: string) begin
    Memo1.Lines.Add(ALog);
  end;
end;

procedure TStartModelLog.Button1Click(Sender: TObject);
begin
  Close();
  FAction();
end;

procedure TStartModelLog.Button2Click(Sender: TObject);
begin
  Close();
end;

procedure TStartModelLog.Done;
begin
  Button1.Enabled := true;
  Button2.Enabled := true;
  Self.BringToFront();
end;

end.
