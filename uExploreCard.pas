unit uExploreCard;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Objects, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent;

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
    procedure NetHTTPClient1RequestCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);
    procedure NetHTTPClient1RequestError(const Sender: TObject;
      const AError: string);
    procedure NetHTTPClient1RequestException(const Sender: TObject;
      const AError: Exception);
  private
    FImage: TStream;
    FBusy: boolean;
    FModelName: string;
    FDescription: string;
    FRunCount: integer;
    FCoverImageUrl: string;
    function FormatRunCount(): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    procedure Init();

    property ModelName: string read FModelName write FModelName;
    property Description: string read FDescription write FDescription;
    property RunCount: integer read FRunCount write FRunCount;
    property CoverImageUrl: string read FCoverImageUrl write FCoverImageUrl;
  end;

implementation

uses
  System.SyncObjs;

{$R *.fmx}

constructor TExploreCard.Create(AOwner: TComponent);
begin
  inherited;
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
  if RunCount >= 1000000000 then
    Result := Format('%0.1fB', [RunCount / 1000000000]) // Billion
  else if RunCount >= 1000000 then
    Result := Format('%0.1fM', [RunCount / 1000000]) // Million
  else if RunCount >= 1000 then
    Result := Format('%0.1fK', [RunCount / 1000]) // Thousand
  else
    Result := IntToStr(RunCount); // Regular number
end;

procedure TExploreCard.Init;
begin
  lbName.Text := FModelName;
  lbDescription.Text := FDescription;
  lbRuns.Text := #$1F680 + ' ' + FormatRunCount();

  aniConverImage.Enabled := true;
  aniConverImage.Visible := true;
  NetHttpClient1.Get(FCoverImageUrl);
end;

end.
