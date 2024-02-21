unit uItemFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, System.Skia, FMX.Skia, FMX.Layouts;

type
  TFrameItem = class(TFrame)
    Panel1: TPanel;
    TitleLabel: TLabel;
    Line1: TLine;
    DescriptionLabel: TLabel;
    EmojiLabel: TLabel;
    Timer: TTimer;
    Layout1: TLayout;
    procedure Panel1Click(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FImageURL: String;
    procedure LoadImageIntoControl(const ImageURL: string; ParentControl: TFmxObject);
  end;

implementation

{$R *.fmx}

uses
  uMainForm,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
  System.IOUtils, System.Hash, System.Threading, System.RegularExpressions;


procedure TFrameItem.Panel1Click(Sender: TObject);
begin
  MainForm.LoadModel(Self.TagString);
end;


procedure TFrameItem.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  if Self.FImageURL<>'' then
  begin
    if MainForm.ImageQueueMT.Lookup('url',Self.FImageURL,'stage')=99 then
      LoadImageIntoControl(Self.FImageURL, Layout1)
    else
      Timer.Enabled := False;
  end;
end;

function ExtractFileExtFromURL(const URL: string): string;
var
  RegEx: TRegEx;
  Match: TMatch;
begin
  // Regular expression to extract the file extension from the URL
  RegEx := TRegEx.Create('(?<=\.)[A-Za-z0-9]+$');
  Match := RegEx.Match(URL);
  if Match.Success then
    Result := '.' + Match.Value
  else
    Result := '';
end;

procedure TFrameItem.LoadImageIntoControl(const ImageURL: string; ParentControl: TFmxObject);
var
  NetHTTPClient: TNetHTTPClient;
  Response: IHTTPResponse;
  ImageStream, CacheStream: TMemoryStream;
  ImageControl: TControl;
  CacheFileName, CacheDir, FileExt: string;
begin
  TTask.Run(procedure begin
    CacheDir := TPath.Combine(ExtractFilePath(ParamStr(0)), 'ImageCache');
    // Ensure cache directory exists
    if not TDirectory.Exists(CacheDir) then
      TDirectory.CreateDirectory(CacheDir);

    // Generate a unique filename based on the URL
    CacheFileName := TPath.Combine(CacheDir, THashMD5.GetHashString(ImageURL));
    FileExt := LowerCase(ExtractFileExtFromURL(ImageURL));
    CacheFileName := CacheFileName + FileExt;

    // Check if the image is already cached
    if TFile.Exists(CacheFileName) then
    begin
      ImageStream := TMemoryStream.Create;
      ImageStream.LoadFromFile(CacheFileName);
    end
    else
    begin
      NetHTTPClient := TNetHTTPClient.Create(Self);
      try
        // Download the image
        Response := NetHTTPClient.Get(ImageURL);
        if Response.StatusCode = 200 then
        begin
          ImageStream := TMemoryStream.Create;
          ImageStream.LoadFromStream(Response.ContentStream);
          ImageStream.Position := 0;

          ImageStream.SaveToFile(CacheFileName);
        end;
      finally
        NetHTTPClient.Free;
      end;
    end;

    if Assigned(ImageStream) then
    try
      TThread.Synchronize(nil,procedure begin
        // Determine if the image is animated or not
        if FileExt = '.gif' then
        begin
          ImageControl := TSkAnimatedImage.Create(ParentControl);
          TSkAnimatedImage(ImageControl).LoadFromStream(ImageStream);
        end
        else
        begin
          ImageControl := TImage.Create(ParentControl);
          TImage(ImageControl).Bitmap.LoadFromStream(ImageStream);
        end;

        // Parent the new control and set properties
        ImageControl.Parent := ParentControl;
        ImageControl.Align := TAlignLayout.Client;
        ImageControl.HitTest := False;
      end);
    finally
      ImageStream.Free;
    end;
  end);

  Timer.Free;
end;


end.
