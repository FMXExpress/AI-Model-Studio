program AIModelStudio;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMainForm in 'uMainForm.pas' {MainForm},
  uItemFrame in 'uItemFrame.pas' {FrameItem: TFrame},
  uPredictFrame in 'uPredictFrame.pas' {PredictFrame: TFrame},
  uReplicate in 'uReplicate.pas',
  uExploreCard in 'uExploreCard.pas' {ExploreCard: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
