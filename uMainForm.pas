unit uMainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, REST.Types,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  System.Rtti, FMX.Grid.Style, FMX.StdCtrls, FMX.MultiView,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Response.Adapter, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.Controls, FMX.Layouts, Fmx.Bind.Navigator, Data.Bind.Grid,
  Data.Bind.DBScope, FMX.Edit, FireDAC.Stan.StorageJSON, FireDAC.Stan.StorageBin,
  System.Generics.Collections, FMX.TabControl, FMX.Memo.Types, FMX.Memo,
  DosCommand, FMX.BufferedLayout, FMX.Objects, uPredictFrame;

type
  TPropertyDetail = record
    Name: string;
    DataType: string;
    Title: string;
    Description: string;
    Default: string;
    // Initialize the record fields
    constructor Create(const AName, ADataType, ATitle, ADescription, ADefault: string);
  end;

  TMainForm = class(TForm)
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    FDMemTable1: TFDMemTable;
    StringGrid1: TStringGrid;
    MultiView1: TMultiView;
    Button1: TButton;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    BindNavigator1: TBindNavigator;
    ModelsMT: TFDMemTable;
    BindSourceDB2: TBindSourceDB;
    LinkGridToDataSourceBindSourceDB2: TLinkGridToDataSource;
    Button2: TButton;
    Edit1: TEdit;
    Button3: TButton;
    SaveButton: TButton;
    LoadButton: TButton;
    ToolBar1: TToolBar;
    FDStanStorageBinLink1: TFDStanStorageBinLink;
    ModelClient: TRESTClient;
    ModelRequest: TRESTRequest;
    ModelResponse: TRESTResponse;
    ModelDSA: TRESTResponseDataSetAdapter;
    ModelResponseMT: TFDMemTable;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    XrayMemo: TMemo;
    ModelLoadTimer: TTimer;
    ModelsPB: TProgressBar;
    ModelsLabel: TLabel;
    ModelStatusTimer: TTimer;
    StatusBar1: TStatusBar;
    ProgressBar: TProgressBar;
    DosCommand: TDosCommand;
    Memo1: TMemo;
    Splitter1: TSplitter;
    TabItem3: TTabItem;
    CardsVSB: TVertScrollBox;
    FlowLayout: TFlowLayout;
    ModelTabItem: TTabItem;
    Layout1: TLayout;
    Layout2: TLayout;
    RunButton: TButton;
    Layout4: TLayout;
    Label1: TLabel;
    LocationSwitch: TSwitch;
    Label2: TLabel;
    InitializeButton: TButton;
    Layout5: TLayout;
    GenerateButton: TButton;
    Panel1: TPanel;
    TitleLabel: TLabel;
    Line1: TLine;
    DescriptionLabel: TLabel;
    EmojiLabel: TLabel;
    MaterialOxfordBlueSB: TStyleBook;
    Layout3: TLayout;
    SearchEdit: TEdit;
    SearchButton: TButton;
    ImageQueueMT: TFDMemTable;
    ImageQueueTimer: TTimer;
    APIKeyEdit: TEdit;
    APIKeyButton: TButton;
    Progresstimer: TTimer;
    PredictTimer: TTimer;
    PredictResponse: TRESTResponse;
    PredictClient: TRESTClient;
    PredictRequest: TRESTRequest;
    PredictDSA: TRESTResponseDataSetAdapter;
    PredictMT: TFDMemTable;
    InputLayout: TLayout;
    Splitter2: TSplitter;
    OutputLayout: TLayout;
    Line2: TLine;
    Label3: TLabel;
    Line3: TLine;
    Label4: TLabel;
    InnerInputLayout: TLayout;
    LaunchTimer: TTimer;
    OpenDialog: TOpenDialog;
    PredictQueueMT: TFDMemTable;
    PortEdit: TEdit;
    GPUCheckBox: TCheckBox;
    ModelPB: TProgressBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure LoadButtonClick(Sender: TObject);
    procedure SearchButtonClick(Sender: TObject);
    procedure ModelLoadTimerTimer(Sender: TObject);
    procedure RunButtonClick(Sender: TObject);
    procedure DosCommandNewLine(ASender: TObject; const ANewLine: string;
      AOutputType: TOutputType);
    procedure FlowLayoutResized(Sender: TObject);
    procedure InitializeButtonClick(Sender: TObject);
    procedure GenerateButtonClick(Sender: TObject);
    procedure ImageQueueTimerTimer(Sender: TObject);
    procedure APIKeyButtonClick(Sender: TObject);
    procedure ProgresstimerTimer(Sender: TObject);
    procedure PredictTimerTimer(Sender: TObject);
    procedure LaunchTimerTimer(Sender: TObject);
    procedure LocationSwitchSwitch(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FModelsBusy: Boolean;
    FCard: Integer;
    PF: TPredictFrame;
    procedure Restore(ALoadImages: Boolean);
    procedure LoadTemplate(TemplateId: Integer);
    procedure LoadModel(AModelUrl: String);
    procedure LoadButtonOnClick(Sender: TObject);
    procedure CreatePropertyControls(const PropDetail: TPropertyDetail; ParentLayout: TVertScrollBox);
    procedure DosCommandTerminated(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  uItemFrame, System.Threading, System.NetEncoding, System.Net.Mime, System.Math, System.JSON, ShellAPI, Windows, System.IOUtils;

constructor TPropertyDetail.Create(const AName, ADataType, ATitle, ADescription, ADefault: string);
begin
  Name := AName;
  DataType := ADataType;
  Title := ATitle;
  Description := ADescription;
  Default := ADefault;
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

function JSONQuote(const AValue: string): string;
var
  JSONStr: TJSONString;
begin
  JSONStr := TJSONString.Create(AValue);
  try
    Result := JSONStr.ToJSON;
  finally
    JSONStr.Free;
  end;
end;

function MemoryStreamToBase64(const MemoryStream: TMemoryStream): string;
var
  OutputStringStream: TStringStream;
  Base64Encoder: TBase64Encoding;
  MimeType: string;
begin
  MemoryStream.Position := 0;
  OutputStringStream := TStringStream.Create('', TEncoding.ASCII);
  try
    Base64Encoder := TBase64Encoding.Create;
    try
      Base64Encoder.Encode(MemoryStream, OutputStringStream);
      MimeType := 'image/png';
      Result := 'data:' + MimeType + ';base64,' + OutputStringStream.DataString.Replace(#13#10,'');
    finally
      Base64Encoder.Free;
    end;
  finally
    OutputStringStream.Free;
  end;
end;

procedure TMainForm.LoadButtonOnClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    TEdit(TButton(Sender).Parent).Text := OpenDialog.FileName;
    var LFileExt := TPath.GetExtension(OpenDialog.FileName);
    if ((LFileExt='.png') OR (LFileExt='.jpg') OR (LFileExt='.jpeg')) then
    begin
      TImage(TButton(Sender).TagObject).Bitmap.LoadFromFile(OpenDialog.Filename);
      TImage(TButton(Sender).TagObject).Height := 512;
      TLayout(TImage(TButton(Sender).TagObject).TagObject).Height := 512+TLayout(TEdit(TButton(Sender).Parent).Parent).Height;
    end;
  end;
end;

procedure AdjustFlowLayoutHeight(FlowLayout: TFlowLayout);
var
  TotalHeight, CurrentRowWidth, RowHeight: Single;
  I: Integer;
  Control: TControl;
  const
    HorizontalSpacing = 10; // Adjust these values as needed
    VerticalSpacing = 10;
begin
  TotalHeight := 0;
  CurrentRowWidth := FlowLayout.Padding.Left; // Start with the left padding
  RowHeight := 0;

  for I := 0 to FlowLayout.ControlsCount - 1 do
  begin
    Control := FlowLayout.Controls[I];

    // Check if adding this control would exceed the width of the FlowLayout
    if (CurrentRowWidth + Control.Width + FlowLayout.Padding.Right > FlowLayout.Width) and (I > 0) then
    begin
      // Start a new row
      TotalHeight := TotalHeight + RowHeight + VerticalSpacing;
      CurrentRowWidth := FlowLayout.Padding.Left;
      RowHeight := 0;
    end;

    // Update the current row width and row height
    if CurrentRowWidth > FlowLayout.Padding.Left then
      CurrentRowWidth := CurrentRowWidth + HorizontalSpacing;
    CurrentRowWidth := CurrentRowWidth + Control.Width;
    RowHeight := Max(RowHeight, Control.Height);
  end;

  // Add the height of the last row
  TotalHeight := TotalHeight + RowHeight;

  // Set the height of the FlowLayout
  FlowLayout.Height := TotalHeight + FlowLayout.Padding.Top + FlowLayout.Padding.Bottom;
end;



procedure TMainForm.Restore(ALoadImages: Boolean);
var
  LCard: TFrameItem;
  LStream: TStream;
  LScene: TBufferedLayout;
begin

  ModelsMT.First;
  while not ModelsMT.Eof do
    begin

      if ALoadImages=True then
        ImageQueueMT.AppendRecord([ModelsMT.FieldByName('cover_image_url').AsString,0]);

      LScene := TBufferedLayout.Create(Self);
      LCard := TFrameItem.Create(Self);
      LCard.Name := 'Card'+FCard.ToString;
      LCard.Align := TAlignLayout.Client;
//      LCard.Position.Y := 999999999;
      LCard.TagString := ModelsMT.FieldByName('url').AsWideString;
      //LCard.EmojiLabel.Text := ModelsMT.FieldByName('emoji').AsWideString;
      LCard.FImageURL := ModelsMT.FieldByName('cover_image_url').AsString;
      LCard.TitleLabel.Text := ModelsMT.FieldByName('owner').AsWideString + '/' + ModelsMT.FieldByName('name').AsWideString;
      LCard.DescriptionLabel.Text := ModelsMT.FieldByName('description').AsWideString;
      LScene.Height := LCard.Height;
      LScene.Width := LCard.Width;
      LCard.Parent := LScene;
      //LScene.Align := TAlignLayout.Top;
      LScene.Parent := FlowLayout;

      Inc(FCard);

      ModelsMT.Next;
    end;

    AdjustFlowLayoutHeight(FlowLayout);
end;

procedure TMainForm.LoadTemplate(TemplateId: Integer);
begin
  //MainForm.TabControl.ActiveTab := MainForm.DroidTabItem;
  //TemplatesMT.Locate('id', VarArrayOf([TemplateId]));
  //PromptMemo.Lines.Text := TemplatesMT.FieldByName('prompt').AsWideString;
  //HintLabel.Text := TemplatesMT.FieldByName('prompthint').AsWideString;
end;

procedure TMainForm.LocationSwitchSwitch(Sender: TObject);
begin
  if LocationSwitch.IsChecked=True then
  begin
    RunButton.Visible := False;
    InitializeButton.Visible := False;
  end
  else
  begin
    RunButton.Visible := True;
    InitializeButton.Visible := True;
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
      Result[I] := JSONArray.Items[I].Value;
  finally
    JSONArray.Free;
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

procedure TMainForm.PredictTimerTimer(Sender: TObject);
begin {
  var F := PredictMT.FindField('status');
  if F<>nil then
  begin
    if F.AsWideString='processing' then
    begin
      XrayMemo.Lines.Append('GET Request');
      XrayMemo.Lines.Append('URL:');
      XrayMemo.Lines.Append(PredictClient.BaseURL+'/'+PredictRequest.Resource+#13#10);

      XrayMemo.Lines.Append('Response');
      XrayMemo.Lines.Append(PredictResponse.Content+#13#10);

      if PredictMT.FindField('output')<>nil then
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
      end;

    end
    else
    if F.AsWideString='succeeded' then
    begin
      //Timer1.Enabled := False;
      XrayMemo.Lines.Append('GET Request');
      XrayMemo.Lines.Append('URL:');
      XrayMemo.Lines.Append(PredictClient.BaseURL+'/'+PredictRequest.Resource+#13#10);

      XrayMemo.Lines.Append('Response');
      XrayMemo.Lines.Append(PredictResponse.Content+#13#10);

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
      //FCurrentMessage := nil;

      ProgressBar.Visible := False;
      GenerateButton.Enabled := True;

    end
    else
    if F.AsWideString='failed' then
    begin
     // Timer1.Enabled := False;

      XrayMemo.Lines.Append('GET Request');
      XrayMemo.Lines.Append('URL:');
      XrayMemo.Lines.Append(PredictClient.BaseURL+'/'+PredictRequest.Resource+#13#10);

      XrayMemo.Lines.Append('Response');
      XrayMemo.Lines.Append(PredictResponse.Content+#13#10);

      ProgressBar.Visible := False;
      GenerateButton.Enabled := True;
      ShowMessage(PredictMT.FieldByName('error').AsWideString);
    end;
  end; }
end;

procedure TMainForm.ProgresstimerTimer(Sender: TObject);
begin
    if ProgressBar.Value=ProgressBar.Max then
      ProgressBar.Value := ProgressBar.Min
    else
      ProgressBar.Value := ProgressBar.Value+5;

    if ModelPB.Value=ModelPB.Max then
      ModelPB.Value := ModelPB.Min
    else
      ModelPB.Value := ModelPB.Value+5;
end;

function ParseOpenApiSchema(const JsonStr: string): TList<TPropertyDetail>;
var
  JsonObj, Components, Schemas, Input, Properties, Prop: TJSONObject;
  JsonValue: TJSONValue;
  Pair: TJSONPair;
begin
  Result := TList<TPropertyDetail>.Create;
  try
    JsonObj := TJSONObject.ParseJSONValue(JsonStr) as TJSONObject;
    if not Assigned(JsonObj) then Exit;
    // Navigate to the 'components -> schemas -> input -> properties' path

    var openapi := JsonObj.GetValue('openapi_schema') as TJSONObject;
    if Assigned(openapi) then
    begin
    Components := openapi.GetValue('components') as TJSONObject;
    if Assigned(Components) then
    begin
      Schemas := Components.GetValue('schemas') as TJSONObject;
      if Assigned(Schemas) then
      begin
        Input := Schemas.GetValue('Input') as TJSONObject;
        if Assigned(Input) then
        begin
          Properties := Input.GetValue('properties') as TJSONObject;
          if Assigned(Properties) then
          begin
            for Pair in Properties do
            begin
              Prop := Pair.JsonValue as TJSONObject;
              Result.Add(TPropertyDetail.Create(
                {Name := } Pair.JsonString.Value,
                {DataType := } Prop.GetValue<string>('type', ''),
                {Title := } Prop.GetValue<string>('title', ''),
                {Description := } Prop.GetValue<string>('description', ''),
                {Default := } Prop.GetValue<string>('default', '')
              ));
            end;
          end;
        end;
      end;
    end;
    end;
  finally
    JsonObj.Free;
  end;
end;



procedure LoadJsonIntoMemTable(const JsonString: string; MemTable: TFDMemTable);
var
  JSONArray: TJSONArray;
  JSONValue: TJSONValue;
  JSONObject: TJSONObject;
  I: Integer;
begin
  JSONArray := TJSONObject.ParseJSONValue(JsonString) as TJSONArray;
  if JSONArray = nil then Exit;
  try
    MemTable.DisableControls;
    try
      //MemTable.Open;
      //MemTable.EmptyDataSet;
      for I := 0 to JSONArray.Count - 1 do
      begin
        JSONValue := JSONArray.Items[I];
        JSONObject := JSONValue as TJSONObject;
        var URL := JSONObject.GetValue<string>('url', '');
        if MemTable.Locate('url', URL, [])=False then
        begin
          MemTable.Append;
          MemTable.FieldByName('url').AsString := URL;
        end
        else
          MemTable.Edit;
          MemTable.FieldByName('owner').AsString := JSONObject.GetValue<string>('owner', '');
          MemTable.FieldByName('name').AsString := JSONObject.GetValue<string>('name', '');
          MemTable.FieldByName('description').AsString := JSONObject.GetValue<string>('description', '');
          MemTable.FieldByName('visibility').AsString := JSONObject.GetValue<string>('visibility', '');
          MemTable.FieldByName('github_url').AsString := JSONObject.GetValue<string>('github_url', '');
          MemTable.FieldByName('paper_url').AsString := JSONObject.GetValue<string>('paper_url', '');
          MemTable.FieldByName('license_url').AsString := JSONObject.GetValue<string>('license_url', '');
          MemTable.FieldByName('run_count').AsInteger := JSONObject.GetValue<Integer>('run_count', 0);
          MemTable.FieldByName('cover_image_url').AsString := JSONObject.GetValue<string>('cover_image_url', '');
          // For nested JSON objects, you might need to convert them to string or handle differently
          MemTable.FieldByName('default_example').AsString := JSONObject.GetValue<TJSONValue>('default_example', TJSONNull.Create).ToString;
          MemTable.FieldByName('latest_version').AsString := JSONObject.GetValue<TJSONValue>('latest_version', TJSONNull.Create).ToString;
          try
          MemTable.Post;
          except
          end;
      end;
    finally
      MemTable.EnableControls;
    end;
  finally
    JSONArray.Free;
  end;
end;

function GetIdFromJson(const JsonString: string): string;
var
  JSONObject: TJSONObject;
  JSONValue: TJSONValue;
begin
  Result := '';
  JSONObject := TJSONObject.ParseJSONValue(JsonString) as TJSONObject;
  if Assigned(JSONObject) then
  try
    JSONValue := JSONObject.GetValue('id');
    if Assigned(JSONValue) then
      Result := JSONValue.Value;
  finally
    JSONObject.Free;
  end;
end;


procedure TMainForm.APIKeyButtonClick(Sender: TObject);
begin
 APIKeyEdit.Visible := not APIKeyEdit.Visible;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  RESTClient1.BaseURL := 'https://api.replicate.com/v1/models';
  RESTRequest1.Params[0].Value := 'Token ' + APIKeyEdit.Text;
  RESTRequest1.Execute;
  LoadJsonIntoMemTable(FDMemTable1.FieldByName('results').AsWideString,ModelsMT);

end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  ModelsPB.Visible := True;
  ModelLoadTimer.Enabled := True;
  ProgressBar.Visible := True;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  Edit1.Text := 'docker run -d -p '+PortEdit.Text+':5000 --gpus=all r8.im/' + ModelsMT.FieldByName('owner').AsWideString+'/'+ModelsMT.FieldByName('name').AsWideString+'@sha256:'+GetIdFromJson(ModelsMT.FieldByName('latest_version').AsWideString);
end;

procedure TMainForm.CreatePropertyControls(const PropDetail: TPropertyDetail; ParentLayout: TVertScrollBox);
var
  NewLayout, EditLayout: TLayout;
  NameLabel, DataTypeLabel, TitleLabel, DescriptionLabel: TLabel;
  EditField: TEdit;
  LImage: TImage;
  I: Integer;
begin
  var LDataType := PropDetail.DataType;

  if LDataType='' then
    if TryStrToInt(PropDetail.Default,I)=True then
      LDataType := 'integer';

  // Create a new layout for each property
  NewLayout := TLayout.Create(ParentLayout);
  NewLayout.Parent := ParentLayout;
  NewLayout.Align := TAlignLayout.Top;
  NewLayout.Height := 100; // Adjust as needed
  NewLayout.Margins.Rect := RectF(5, 5, 5, 5);
  DataTypeLabel := TLabel.Create(NewLayout);
  DataTypeLabel.Parent := NewLayout;
  DataTypeLabel.Text := 'Data Type: ' + PropDetail.DataType;
  DataTypeLabel.Position.Y := 30;
  DataTypeLabel.Align := TAlignLayout.Bottom;
  TitleLabel := TLabel.Create(NewLayout);
  TitleLabel.Parent := NewLayout;
  TitleLabel.Text := 'Title ('+PropDetail.Name+'): ' + PropDetail.Title;
  TitleLabel.Position.Y := 50;
  TitleLabel.Align := TAlignLayout.Top;
  DescriptionLabel := TLabel.Create(NewLayout);
  DescriptionLabel.Parent := NewLayout;
  DescriptionLabel.Text := 'Description: ' + PropDetail.Description;
  DescriptionLabel.Position.Y := 70;
  DescriptionLabel.Align := TAlignLayout.Bottom;
  // Create and configure the edit field
  EditLayout := TLayout.Create(NewLayout);
  EditLayout.Parent := NewLayout;
  EditLayout.Height := 50; // Adjust height as necessary
  EditLayout.Position.Y := 100; // Position below the last label
  EditLayout.Align := TAlignLayout.Client;

  EditField := TEdit.Create(EditLayout);
  EditField.Parent := NewLayout;
  EditField.TagString := PropDetail.Name; // Storing the property name in TagString
  EditField.TextPrompt := 'Enter ' + PropDetail.Name;
  EditField.Align := TAlignLayout.Top; // Align to fill the remaining space
  EditField.Height := 50;
  EditField.Text := PropDetail.Default;
  EditField.Hint := LDataType;

  if LDataType='string' then
    if (PropDetail.Name.IndexOf('image')>-1) OR (PropDetail.Name = 'mask')  OR (PropDetail.Name = 'img') then
    begin
      LImage := TImage.Create(EditLayout);
      LImage.Parent := EditLayout;
      LImage.Align := TAlignLayout.Client;
      LImage.TagObject := NewLayout;

      var LLoadButton := TButton.Create(NewLayout);
      LLoadButton.Parent := EditField;
      LLoadButton.StyleLookup := 'optionstoolbutton';
      LLoadButton.Align := TAlignLayout.Right;
      LLoadButton.OnClick := LoadButtonOnClick;
      LLoadButton.TagObject := LImage;
    end;


  // Create and configure labels
//  NameLabel := TLabel.Create(EditField);
//  NameLabel.Parent := EditField;
//  NameLabel.Text := PropDetail.Name;
//  NameLabel.AutoSize := True;
//  NameLabel.TextAlign := TTextAlign.Trailing;
  //NameLabel.Position.Y := 10;
//  NameLabel.Align := TAlignLayout.Right;

end;

procedure AddEditsToJson(Control: TFmxObject; JSONObj: TJSONObject);
var
  I: Integer;
  ChildControl: TFmxObject;
  Edit: TEdit;
begin
  for I := 0 to Control.ChildrenCount - 1 do
  begin
    ChildControl := Control.Children[I];

    if ChildControl is TEdit then
    begin
      Edit := TEdit(ChildControl);
      if Edit.Hint = 'boolean' then
      begin
        if Edit.Text<>'' then
          if (Edit.Text='true') then
            JSONObj.AddPair(Edit.TagString, true)
          else
            JSONObj.AddPair(Edit.TagString, false);
      end
      else if Edit.Hint = 'integer' then
      begin
        if Edit.Text<>'' then
         JSONObj.AddPair(Edit.TagString, Edit.Text.ToInt64);
      end
      else if Edit.Hint = 'number' then
      begin
        if Edit.Text<>'' then
          JSONObj.AddPair(Edit.TagString, Edit.Text.ToDouble);
      end
      else if Edit.Hint = '' then
      begin
        if Edit.Text<>'' then
          JSONObj.AddPair(Edit.TagString, TJSONString.Create(Edit.Text));
      end
      else if Edit.Hint = 'string' then
      begin
        if Edit.Text<>'' then
        begin
          var LString := '';

          if TFile.Exists(Edit.Text) then
          begin
              var LSourceStream := TMemoryStream.Create;
              LSourceStream.LoadFromFile(Edit.Text);
              LString := MemoryStreamToBase64(LSourceStream);
              LSourceStream.Free;
          end
          else
            LString := Edit.Text;

          JSONObj.AddPair(Edit.TagString, TJSONString.Create(LString));
        end;
      end;
    end
    else
    begin
      // Recursive call for nested layouts
      AddEditsToJson(ChildControl, JSONObj);
    end;
  end;
end;

function EditsToJSON(AVersion: String; Control: TFmxObject): string;
var
  JSONObj, OuterJSONObj: TJSONObject;
begin
  JSONObj := TJSONObject.Create;
  try
    AddEditsToJson(Control, JSONObj);

    OuterJSONObj := TJSONObject.Create;
    try
      OuterJSONObj.AddPair('version', AVersion);
      OuterJSONObj.AddPair('input', JSONObj);
      Result := OuterJSONObj.ToString;
    finally
      OuterJSONObj.Free;
    end;

  finally
  end;
end;

procedure TMainForm.LoadModel(AModelUrl: String);
var
  JsonStr: string;
  PropertyList: TList<TPropertyDetail>;
  PropDetail: TPropertyDetail;
begin
  for var I := InnerInputLayout.ChildrenCount - 1 downto 0 do
    InnerInputLayout.Children[I].Free;

  if ModelsMT.Locate('url',AModelUrl,[]) then
  begin
    TitleLabel.Text := ModelsMT.FieldByName('owner').AsWideString + '/' + ModelsMT.FieldByName('name').AsWideString;
    DescriptionLabel.Text := ModelsMT.FieldByName('description').AsWideString;
    JsonStr := ModelsMT.FieldByName('latest_version').AsWideString; // Your JSON string here
    PropertyList := ParseOpenApiSchema(JsonStr);
    var ParentVSB := TVertScrollBox.Create(InnerInputLayout);
    ParentVSB.Align := TAlignLayout.Client;
    ParentVSB.Parent := InnerInputLayout;
    try
      for PropDetail in PropertyList do
      begin
        CreatePropertyControls(PropDetail, ParentVSB);
        // Do something with each property, e.g., display its details
        //ShowMessage(Format('Name: %s, Type: %s, Title: %s, Description: %s',
        //  [PropDetail.Name, PropDetail.DataType, PropDetail.Title, PropDetail.Description]));
      end;
    finally
      PropertyList.Free;
    end;

    if Assigned(PF) then
      FreeAndNil(PF);
  end;

  TabControl1.ActiveTab := ModelTabItem;

end;

procedure TMainForm.DosCommandNewLine(ASender: TObject; const ANewLine: string;
  AOutputType: TOutputType);
begin
    Memo1.Lines.Append(ANewLine);
end;

procedure TMainForm.FlowLayoutResized(Sender: TObject);
begin
AdjustFlowLayoutHeight(FlowLayout);
end;

procedure TMainForm.GenerateButtonClick(Sender: TObject);
var
  JSONString: string;
begin
  ModelPB.Value := 0;
  ModelPB.Visible := True;
  GenerateButton.Enabled := False;

  if LocationSwitch.IsChecked=True then
  begin
    ModelClient.BaseURL := 'https://api.replicate.com/v1/predictions';
    ModelRequest.Params[0].Value := 'Token ' + APIKeyEdit.Text;
  end
  else
  begin
    var APort := PortEdit.Text;
    ModelClient.BaseURL := 'http://localhost:'+APort+'/predictions';
  end;

  JSONString := EditsToJSON(GetIdFromJson(ModelsMT.FieldByName('latest_version').AsWideString), InnerInputLayout); // Replace 'YourLayout' with your TLayout instance
  ModelRequest.Params[1].Value := JSONString;

  XrayMemo.Lines.Append('POST Request');
  XrayMemo.Lines.Append('URL:');
  XrayMemo.Lines.Append(ModelClient.BaseURL+#13#10);
  XrayMemo.Lines.Append('Payload:');
  XrayMemo.Lines.Append(FormatJSON(JSONString));
  XrayMemo.Lines.Append('');

  TTask.Run(procedure begin
  ModelRequest.Execute;

  TThread.Synchronize(nil,procedure begin
    XrayMemo.Lines.Append('Response ' + ModelResponse.StatusText + ':');
    try
      XrayMemo.Lines.Append(FormatJSON(ModelResponse.Content));
    except
      XrayMemo.Lines.Append(ModelResponse.Content);
    end;
    XrayMemo.Lines.Append('');
  end);

  var F := ModelResponseMT.FindField('status');
  if F<>nil then
  begin
    if F.AsWideString='starting' then
    begin
      //ModelRequest.Resource := ModelResponseMT.FieldByName('id').AsWideString;

      TThread.Synchronize(nil,procedure begin
        if Assigned(PF) then
          FreeAndNil(PF);

        PF := TPredictFrame.Create(Self);

        PF.PredictRequest.Resource := ModelResponseMT.FieldByName('id').AsWideString;
        PF.Parent := OutputLayout;
        PF.Align := TAlignLayout.Client;
        PF.LaunchTimer.Enabled := True;

        ModelStatustimer.Enabled := True;
      end);
    end
    else if F.AsWideString='succeeded' then
    begin
      TThread.Synchronize(nil,procedure begin

        if Assigned(PF) then
          FreeAndNil(PF);

        PF := TPredictFrame.Create(Self);

        PF.Parent := OutputLayout;
        PF.Align := TAlignLayout.Client;
        PF.LoadResponse(ModelResponseMT, ModelResponse.Content);
        PF.ProgressBar.Visible := False;

        PF.Progresstimer.Enabled := False;
      end);
    end
    else
    begin
      TThread.Synchronize(nil,procedure begin

        //ProgressBar.Visible := False;
        RunButton.Enabled := True;
        GenerateButton.Enabled := True;
        ShowMessage(F.AsWideString);
      end);
    end;
  end;

  TThread.Synchronize(nil,procedure begin
    ModelPB.Visible := False;
    GenerateButton.Enabled := True;
  end);

  end);

end;

procedure TMainForm.ImageQueueTimerTimer(Sender: TObject);
begin
  ImageQueueMT.First;
  while not ImageQueueMT.Eof do
  begin
    if ImageQueueMT.FieldByName('stage').AsInteger=0 then
    begin
      ImageQueueMT.Edit;
      ImageQueueMT.FieldByName('stage').AsInteger := 99;
      ImageQueueMT.Post;
    end
    else
      ImageQueueMT.Next;
  end;
end;

procedure TMainForm.InitializeButtonClick(Sender: TObject);
begin
  //ShellExecute(0, 'open', PChar('cmd.exe'), PChar('/C start /MIN "C:\Program Files\Docker\Docker\Docker Desktop.exe"'), nil, SW_SHOWNORMAL);

 // DosCommand.CommandLine := '"C:\Program Files\Docker\Docker\Docker Desktop.exe"';
 // DosCommand.Execute;
  ShellExecute(0, 'open', PChar('"C:\Program Files\Docker\Docker\Docker Desktop.exe"'), nil, nil, SW_SHOWNORMAL);

  var APort := '5100';
  DosCommand.CommandLine := 'docker pull r8.im/' + ModelsMT.FieldByName('owner').AsWideString+'/'+ModelsMT.FieldByName('name').AsWideString+'@sha256:'+GetIdFromJson(ModelsMT.FieldByName('latest_version').AsWideString);
  //DosCommand.Execute;
  ShellExecute(0, 'open', PChar('cmd.exe'), PChar('/C '+DosCommand.CommandLine), nil, SW_SHOWNORMAL);
end;

procedure TMainForm.SaveClick(Sender: TObject);
begin
  ModelsMT.SaveToFile(ExtractFilePath(ParamStr(0)) + 'data.fds');
end;

procedure TMainForm.SearchButtonClick(Sender: TObject);
begin
  TabControl1.ActiveTab := TabItem3;

  ModelsMT.Filtered := False;
  ModelsMT.Filter := 'Name LIKE ''%'+SearchEdit.Text+'%'' OR Description LIKE ''%'+SearchEdit.Text+'%'' OR Owner LIKE ''%'+SearchEdit.Text+'%''';
  ModelsMT.Filtered := True;

  for var I := FlowLayout.ChildrenCount - 1 downto 0 do
    FlowLayout.Children[I].Free;

  Restore(True);
end;

procedure TMainForm.ModelLoadTimerTimer(Sender: TObject);
begin
  if FModelsBusy=False then
  begin
    FModelsBusy := True;
    if FDMemTable1.FieldByName('next').AsWideString<>'' then
    begin
      RESTClient1.BaseURL := FDMemTable1.FieldByName('next').AsWideString;
      RESTRequest1.Params[0].Value := 'Token ' + APIKeyEdit.Text;
      RESTRequest1.Execute;
      LoadJsonIntoMemTable(FDMemTable1.FieldByName('results').AsWideString,ModelsMT);
    end
    else
    begin
      ModelLoadTimer.Enabled := False;
      ModelsPB.Visible := False;
      ProgressBar.Visible := False;
    end;
    FModelsBusy := False;
  end;
end;

procedure TMainForm.LaunchTimerTimer(Sender: TObject);
begin
  LaunchTimer.Enabled := False;
  LoadButtonClick(Sender);
end;

procedure TMainForm.LoadButtonClick(Sender: TObject);
begin
  ModelsMT.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'data.fds');
  ModelsMT.IndexesActive := True;
  ModelsLabel.Text := ModelsMT.RecordCount.ToString;

  Restore(False);
end;

procedure TMainForm.DosCommandTerminated(Sender: TObject);
begin
  (Sender as TDosCommand).Free;
end;

procedure TMainForm.RunButtonClick(Sender: TObject);
var
  LPort, LGPU, JSONString: string;
begin
  LPort := PortEdit.Text;
  if GPUCheckBox.IsChecked then
    LGPU := '--gpus=all ';

  var DC := TDosCommand.Create(Self);
  try
    DC.CommandLine := 'docker run --name '+
    ModelsMT.FieldByName('owner').AsWideString+
    '_'+ModelsMT.FieldByName('name').AsWideString+
    ' -d -p '+
    LPort+':5000 '+
    LGPU+
    'r8.im/' +
    ModelsMT.FieldByName('owner').AsWideString+
    '/'+
    ModelsMT.FieldByName('name').AsWideString+
    '@sha256:'+
    GetIdFromJson(ModelsMT.FieldByName('latest_version').AsWideString);

    DC.OnTerminated := DosCommandTerminated;

    //DC.Execute;

    ShellExecute(0, 'open', PChar('cmd.exe'), PChar('/C '+DC.CommandLine), nil, SW_SHOWNORMAL);
  except
    DC.Free;
  end;
end;

end.
