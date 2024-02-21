unit uPredictFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ExtCtrls, FMX.Controls.Presentation, REST.Types,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Response.Adapter,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.TabControl, FMX.WebBrowser,
  System.Skia, FMX.Skia;

type
  TPredictFrame = class(TFrame)
    ProgressBar: TProgressBar;
    PredictResponse: TRESTResponse;
    PredictClient: TRESTClient;
    PredictRequest: TRESTRequest;
    PredictDSA: TRESTResponseDataSetAdapter;
    PredictMT: TFDMemTable;
    LaunchTimer: TTimer;
    Progresstimer: TTimer;
    NetHTTPClient: TNetHTTPClient;
    TabControl: TTabControl;
    PreviewTI: TTabItem;
    JSONTI: TTabItem;
    JSONMemo: TMemo;
    VSB: TVertScrollBox;
    procedure LaunchTimerTimer(Sender: TObject);
    procedure ProgresstimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadResponse(APredictMT: TFDMemTable; AResponse: String);
    procedure GetURLData(const URL: string; LResponseStream: TStream);
  end;

implementation

{$R *.fmx}

uses uMainForm, System.JSON, System.NetEncoding, StrUtils;


function GetFileTypeFromDataURL(const DataURL: string): string;
var
  StartPos, EndPos: Integer;
  MediaType: string;
begin
  Result := '';

  if StartsText('data:', DataURL) then
  begin
    StartPos := Pos(':', DataURL) + 1;
    EndPos := Pos(';', DataURL) - StartPos;

    // Extract the media type part
    MediaType := Copy(DataURL, StartPos, EndPos);

    // Extract file type from media type (e.g., 'image/png' -> 'png')
    StartPos := LastDelimiter('/', MediaType) + 1;
    Result := Copy(MediaType, StartPos, MaxInt);
  end;
end;


function ParseJSONStrArray(const JSONStr: String): TArray<String>;
var
  JSONArray: TJSONArray;
  I: Integer;
begin
  JSONArray := TJSONObject.ParseJSONValue(JSONStr) as TJSONArray;
  try
    SetLength(Result, JSONArray.Count);
    for I := 0 to JSONArray.Count - 1 do
    begin
      //Result[I] := JSONArray.Items[I].Value;

      if JSONArray.Items[I] is TJSONString then
        Result[I] := TJSONString(JSONArray.Items[I]).Value
      else
        Result[I] := JSONArray.Items[I].ToString;
    end;
  finally
    JSONArray.Free;
  end;
end;

function IsJSONObject(const s: string): Boolean;
var
  JSONValue: TJSONValue;
begin
  Result := False;
  try
    JSONValue := TJSONObject.ParseJSONValue(s);
    try
      if JSONValue is TJSONObject then
        Result := True;
    finally
      JSONValue.Free;
    end;
  except
    on E: EJSONException do
      // Do nothing; Result remains False
  end;
end;

function IsJSONArray(const s: string): Boolean;
var
  JSONValue: TJSONValue;
begin
  Result := False;
  try
    JSONValue := TJSONObject.ParseJSONValue(s);
    try
      if JSONValue is TJSONArray then
        Result := True;
    finally
      JSONValue.Free;
    end;
  except
    on E: EJSONException do
      // Do nothing; Result remains False
  end;
end;

procedure TPredictFrame.ProgresstimerTimer(Sender: TObject);
begin
  if ProgressBar.Value=ProgressBar.Max then
    ProgressBar.Value := ProgressBar.Min
  else
    ProgressBar.Value := ProgressBar.Value+5;
end;

function ExtractFileExtFromURL(const URL: string): string;
var
  LastSlashIndex, LastDotIndex: Integer;
begin
  LastSlashIndex := LastDelimiter('/', URL);
  LastDotIndex := LastDelimiter('.', URL);

  if (LastDotIndex > LastSlashIndex) then
    Result := Copy(URL, LastDotIndex + 1, Length(URL))
  else
    Result := ''; // No extension found
end;

function FormatJSON(const JSONStr: string): string;
var
  JSONValue: TJSONValue;
begin
  JSONValue := TJSONObject.ParseJSONValue(JSONStr);
  if Assigned(JSONValue) then
  try
    // Use TJSONFormat for pretty-printing
    Result := JSONValue.Format(2);
  finally
    JSONValue.Free;
  end
  else
    Result := JSONStr;
end;


procedure TPredictFrame.GetURLData(const URL: string; LResponseStream: TStream);
var
//  NetHTTPClient: TNetHTTPClient;
  Base64Content, ContentType: string;
  StartOfBase64: Integer;
begin
  if URL.StartsWith('http://') or URL.StartsWith('https://') then
  begin
    // Handle HTTP URL
//    NetHTTPClient := TNetHTTPClient.Create(nil);
    try
      NetHTTPClient.Get(URL, LResponseStream);
    finally
//      NetHTTPClient.Free;
    end;
  end
  else if URL.StartsWith('data:') then
  begin
    // Handle Data URL
    StartOfBase64 := Pos('base64,', URL);
    if StartOfBase64 > 0 then
    begin
      Inc(StartOfBase64, Length('base64,') - 1);
      Base64Content := URL.Substring(StartOfBase64);
      LResponseStream.WriteData(TNetEncoding.Base64.DecodeStringToBytes(Base64Content));
    end;
  end;
end;

procedure TPredictFrame.LoadResponse(APredictMT: TFDMemTable; AResponse: String);
var
LFileExt: String;
begin
  JSONMemo.Lines.Text := FormatJSON(AResponse);

  var LResponse := '';

  if IsJSONArray(APredictMT.FieldByName('output').AsWideString) then
  begin
    var OutputArray := ParseJSONStrArray(APredictMT.FieldByName('output').AsWideString);

    if IsJSONObject(OutputArray[Low(OutputArray)]) then
    begin
        var LMemo := TMemo.Create(Self);
        LMemo.Parent := VSB;
        LMemo.Align := TAlignLayout.Client;
        LMemo.WordWrap := True;
        LMemo.Lines.Text := FormatJSON(APredictMT.FieldByName('output').AsWideString);
    end
    else
    for var I := 0 to High(OutputArray) do
    begin
      LResponse := LResponse+OutputArray[I];

      LFileExt := GetFileTypeFromDataURL(LResponse);
      if LFileExt='' then
        LFileExt := ExtractFileExtFromURL(OutputArray[I]);

      if ((LFileExt='png') OR (LFileExt='jpg')) then
      begin

        var LResponseStream := TMemoryStream.Create;

        GetURLData(OutputArray[I], LResponseStream);

        var ImageViewer := TImageViewer.Create(Self);
        ImageViewer.Parent := VSB;
        ImageViewer.Align := TAlignLayout.Top;
        ImageViewer.Bitmap.LoadFromStream(LResponseStream);
        ImageViewer.Height := ImageViewer.Bitmap.Height;

        LResponseStream.Free;
      end
      else if ((LFileExt='') or (LeftStr(LResponse, 4)<>'http')) then
      begin
        var LMemo := TMemo.Create(Self);
        LMemo.Parent := VSB;
        LMemo.Align := TAlignLayout.Client;
        LMemo.WordWrap := True;
        LMemo.Lines.Text := LResponse;
      end;
    end;

  end
  else
  begin
    LResponse := APredictMT.FieldByName('output').AsWideString;

    if IsJSONObject(LResponse) then
    begin
        var LMemo := TMemo.Create(Self);
        LMemo.Parent := VSB;
        LMemo.Align := TAlignLayout.Client;
        LMemo.WordWrap := True;
        LMemo.Lines.Text := FormatJSON(LResponse);
    end
    else
    begin

      LFileExt := GetFileTypeFromDataURL(LResponse);
      if LFileExt='' then
        LFileExt := ExtractFileExtFromURL(LResponse);

      if ((LFileExt='png') OR (LFileExt='jpg')) then
      begin
        var LResponseStream := TMemoryStream.Create;

        GetURLData(LResponse, LResponseStream);

        var ImageViewer := TImageViewer.Create(Self);
        ImageViewer.Parent := VSB;
        ImageViewer.Align := TAlignLayout.Client;
        ImageViewer.Bitmap.LoadFromStream(LResponseStream);

        LResponseStream.Free;
      end
      else if ((LFileExt='mp4')) then
      begin
        var WB := TWebBrowser.Create(Self);
        WB.Parent := VSB;
        WB.Align := TAlignLayout.Client;
        WB.WindowsEngine := TWindowsEngine.EdgeIfAvailable;
        WB.Navigate(LResponse);
      end
      else if ((LFileExt='gif')) then
      begin

        var LResponseStream := TMemoryStream.Create;

        GetURLData(LResponse, LResponseStream);

        var AImage := TSkAnimatedImage.Create(Self);
        AImage.Parent := VSB;
        AImage.Align := TAlignLayout.Client;
        AImage.LoadFromStream(LResponseStream);

        LResponseStream.Free;
      end
      else if ((LFileExt='') or (LeftStr(LResponse, 4)<>'http')) then
      begin
        var LMemo := TMemo.Create(Self);
        LMemo.Parent := VSB;
        LMemo.Align := TAlignLayout.Client;
        LMemo.WordWrap := True;
        LMemo.Lines.Text := LResponse;
      end;
    end;


  end;
end;

procedure TPredictFrame.LaunchTimerTimer(Sender: TObject);
begin
  PredictRequest.Execute;

  var F := PredictMT.FindField('status');
  if F<>nil then
  begin
    if F.AsWideString='processing' then
    begin
      MainForm.XrayMemo.Lines.Append('GET Request');
      MainForm.XrayMemo.Lines.Append('URL:');
      MainForm.XrayMemo.Lines.Append(PredictClient.BaseURL+'/'+PredictRequest.Resource+#13#10);

      MainForm.XrayMemo.Lines.Append('Response');
      MainForm.XrayMemo.Lines.Append(FormatJSON(PredictResponse.Content)+#13#10);

    {  if PredictMT.FindField('output')<>nil then
      begin
        var LResponse := '';

        if IsJSONArray(PredictMT.FieldByName('output').AsWideString) then
        begin
          var OutputArray := ParseJSONStrArray(PredictMT.FieldByName('output').AsWideString);

          for var I := 0 to High(OutputArray) do
          begin
            LResponse := LResponse+OutputArray[I];
          end;
        end
        else
          LResponse := PredictMT.FieldByName('output').AsWideString;

        //FriendMessage(LResponse);
      end;                           }

    end
    else
    if F.AsWideString='succeeded' then
    begin
      LaunchTimer.Enabled := False;
      MainForm.XrayMemo.Lines.Append('GET Request');
      MainForm.XrayMemo.Lines.Append('URL:');
      MainForm.XrayMemo.Lines.Append(PredictClient.BaseURL+'/'+PredictRequest.Resource+#13#10);

      MainForm.XrayMemo.Lines.Append('Response');
      MainForm.XrayMemo.Lines.Append(FormatJSON(PredictResponse.Content)+#13#10);

      LoadResponse(PredictMT, PredictResponse.Content);

      ProgressBar.Visible := False;
      Progresstimer.Enabled := False;
      //GenerateButton.Enabled := True;

    end
    else
    if F.AsWideString='failed' then
    begin
      LaunchTimer.Enabled := False;

      MainForm.XrayMemo.Lines.Append('GET Request');
      MainForm.XrayMemo.Lines.Append('URL:');
      MainForm.XrayMemo.Lines.Append(PredictClient.BaseURL+'/'+PredictRequest.Resource+#13#10);

      MainForm.XrayMemo.Lines.Append('Response');
      MainForm.XrayMemo.Lines.Append(FormatJSON(PredictResponse.Content)+#13#10);

      ProgressBar.Visible := False;
      //GenerateButton.Enabled := True;
      ShowMessage(PredictMT.FieldByName('error').AsWideString);
    end;
  end;

end;

end.
