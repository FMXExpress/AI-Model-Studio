unit uExploreCard;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  System.Threading, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Objects, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, FMX.Menus, uReplicate;

type
  TExploreCard = class(TFrame)
    imgCover: TImage;
    layDetails: TLayout;
    lbName: TLabel;
    lbDescription: TLabel;
    lbRuns: TLabel;
    aniConverImage: TAniIndicator;
    NetHTTPClient1: TNetHTTPClient;
    recCard: TRectangle;
    PopupMenu1: TPopupMenu;
    miRunLocally: TMenuItem;
    miRunOnline: TMenuItem;
    miModelDetails: TMenuItem;
    layBar: TLayout;
    btnOptions: TButton;
    procedure NetHTTPClient1RequestCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);
    procedure NetHTTPClient1RequestError(const Sender: TObject;
      const AError: string);
    procedure NetHTTPClient1RequestException(const Sender: TObject;
      const AError: Exception);
    procedure miModelDetailsClick(Sender: TObject);
    procedure miRunLocallyClick(Sender: TObject);
    procedure miRunOnlineClick(Sender: TObject);
    procedure btnOptionsClick(Sender: TObject);
  private
    FModel: TModel;
    FImage: TStream;
    FBusy: boolean;
    function FormatRunCount(): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    procedure Init(const AModel: TModel);
  end;

implementation

uses
  System.SyncObjs,
  uStartModel,
  uMainForm;

{$R *.fmx}

procedure TExploreCard.btnOptionsClick(Sender: TObject);
begin
  var LParent := Self.Parent;
  while Assigned(LParent) do
    if LParent is TCustomForm then
      Break
    else
      LParent := LParent.Parent;

  if not Assigned(LParent) then
    Exit;

  var LPos := TCustomForm(LParent).ClientToScreen(
    btnOptions.LocalToAbsolute(PointF(0, btnOptions.Height)));
  PopupMenu1.Popup(LPos.X, LPos.Y);
end;

constructor TExploreCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FImage := TMemoryStream.Create();
end;

destructor TExploreCard.Destroy;
begin
  TSpinWait.SpinUntil(
    function(): boolean
    begin
      Result := not FBusy;
    end);

  FImage.Free();
  FModel.Free();
  inherited;
end;

procedure TExploreCard.NetHTTPClient1RequestCompleted(const Sender: TObject;
  const AResponse: IHTTPResponse);
begin
  FImage.CopyFrom(AResponse.ContentStream);
  FBusy := true;
  TThread.ForceQueue(nil, procedure() begin
    try
      try
        imgCover.Bitmap.LoadFromStream(FImage);
      except
        //
      end;
      aniConverImage.Enabled := false;
      aniConverImage.Visible := false;
    finally
      FBusy := false;
    end;
  end, 100);
end;

procedure TExploreCard.NetHTTPClient1RequestError(const Sender: TObject;
  const AError: string);
begin
  aniConverImage.Enabled := false;
  aniConverImage.Visible := false;
end;

procedure TExploreCard.NetHTTPClient1RequestException(const Sender: TObject;
  const AError: Exception);
begin
  aniConverImage.Enabled := false;
  aniConverImage.Visible := false;
end;

function TExploreCard.FormatRunCount: string;
begin
  if FModel.RunCount >= 1000000000 then
    Result := Format('%0.1fB', [FModel.RunCount / 1000000000]) // Billion
  else if FModel.RunCount >= 1000000 then
    Result := Format('%0.1fM', [FModel.RunCount / 1000000]) // Million
  else if FModel.RunCount >= 1000 then
    Result := Format('%0.1fK', [FModel.RunCount / 1000]) // Thousand
  else
    Result := IntToStr(FModel.RunCount); // Regular number
end;

procedure TExploreCard.Init(const AModel: TModel);
begin
  Assert(Assigned(AModel), 'Param "AModel" not assigned.');

  FModel := AModel.Clone();

  lbName.Text := FModel.Id;
  lbDescription.Text := FModel.Description;
  lbRuns.Text := #$1F680 + ' ' + FormatRunCount();

  aniConverImage.Enabled := true;
  aniConverImage.Visible := true;
  NetHttpClient1.Get(FModel.CoverImageUrl);
end;

procedure TExploreCard.miModelDetailsClick(Sender: TObject);
begin
  ShowMessage('Show model details here');
end;

procedure TExploreCard.miRunLocallyClick(Sender: TObject);
begin
  TStartModel.Start(FModel);
end;

procedure TExploreCard.miRunOnlineClick(Sender: TObject);
begin
  ShowMessage('Start a new chat online here');
end;

end.
