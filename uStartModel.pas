unit uStartModel;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Effects,
  FMX.Objects, FMX.Layouts, uReplicate;

type
  TStartModel = class(TForm)
    Memo1: TMemo;
    btnChat: TButton;
    btnClose: TButton;
    Rectangle1: TRectangle;
    ShadowEffect2: TShadowEffect;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnChatClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    procedure InternalStart(const AModel: TModel);
  public
    procedure Done();

    class procedure Start(const AModel: TModel); static;
  end;

var
  StartModel: TStartModel;

implementation

uses
  System.Threading,
  uMainForm,
  uSharedData,
  uDocker;

{$R *.fmx}

{ TStartModelLog }

procedure TStartModel.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TStartModel.btnChatClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TStartModel.btnCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TStartModel.Done;
begin
  btnChat.Enabled := true;
  btnClose.Enabled := true;
  btnChat.Visible := true;
  btnClose.Visible := true;
end;

procedure TStartModel.InternalStart(const AModel: TModel);
begin
  var LModel := AModel;

  btnChat.Visible := false;
  btnClose.Visible := false;

  // Start a new offline chat for the given model
  var LStartChat := procedure() begin
    SharedData.StartChatOffline(LModel.Id);
    uMainForm.MainForm.ShowChat();
  end;

  case TDockerUtility.GetContainerStatus(LModel) of
    TContainerStatus.none: ;
    // Do not show the log window
    TContainerStatus.running: begin
      LStartChat();
      Exit;
    end;
    else
      TDockerUtility.DeleteContainer(LModel);
  end;

  // Tries to run a new container and only show the log window in case of error
  if TDockerUtility.IsImageInstalled(LModel) then begin

    TDockerUtility.RunOrStart(LModel, procedure(ALog: string) begin
      Memo1.Lines.Add(ALog);
    end);

    if Memo1.Lines.Text.ToLower().Contains('error') then begin
      Done();
      ShowModal();
      if ModalResult = mrOk then
        LStartChat();
    end else
      LStartChat();

    Exit;
  end;

  // Pull the image - show the log window
  TTask.Run(procedure() begin
    TDockerUtility.Run(LModel, procedure(ALog: string) begin
      var ALocalLog := ALog;

      TThread.Queue(nil, procedure() begin
        Memo1.Lines.Add(ALocalLog);
      end);
    end);

    TThread.Queue(nil, procedure() begin
      Done();
    end);
  end);

  ShowModal();
  if ModalResult = mrOk then
    LStartChat();
end;

class procedure TStartModel.Start(const AModel: TModel);
begin
  var LForm := TStartModel.Create(Application);
  LForm.InternalStart(AModel);
end;

end.
