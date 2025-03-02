program AIModelStudio;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMainForm in 'uMainForm.pas' {MainForm},
  uItemFrame in 'uItemFrame.pas' {FrameItem: TFrame},
  uPredictFrame in 'uPredictFrame.pas' {PredictFrame: TFrame},
  uReplicate in 'uReplicate.pas',
  uExploreCard in 'uExploreCard.pas' {ExploreCard: TFrame},
  uRunCommand in 'uRunCommand.pas',
  uStartModel in 'uStartModel.pas' {StartModel},
  uChatFrame in 'uChatFrame.pas' {ChatFrame: TFrame},
  uSharedData in 'uSharedData.pas' {SharedData: TDataModule},
  uDocker in 'uDocker.pas',
  uChatCardFrame in 'chat\uChatCardFrame.pas' {ChatCardFrame: TFrame},
  uChatTextCardFrame in 'chat\uChatTextCardFrame.pas' {ChatTextCardFrame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TSharedData, SharedData);
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

