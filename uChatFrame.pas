unit uChatFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Controls.Presentation, FMX.MultiView, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, uReplicate, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.DBScope, FireDAC.Stan.StorageJSON, FireDAC.Stan.StorageBin,
  FMX.Edit, FMX.Layouts, FMX.Objects, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.Styles.Objects, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent;

type
  TChatFrame = class(TFrame)
    lvProjects: TListView;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    ToolBar1: TToolBar;
    Layout1: TLayout;
    edtProjectName: TEdit;
    LinkControlToField1: TLinkControlToField;
    Button1: TButton;
    chatBox: TVertScrollBox;
    Layout2: TLayout;
    Rectangle1: TRectangle;
    Memo1: TMemo;
    Layout3: TLayout;
    Circle1: TCircle;
    Layout4: TLayout;
    Image1: TImage;
    NetHTTPClient1: TNetHTTPClient;
    procedure Button1Click(Sender: TObject);
    procedure Memo1ApplyStyleLookup(Sender: TObject);
    procedure Circle1Click(Sender: TObject);
    procedure NetHTTPClient1RequestCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);
  private
    procedure Send();
  public
    procedure Refresh();
  end;

implementation

uses
  uSharedData,
  uMainForm,
  uChatTextCardFrame;

{$R *.fmx}

{ TChatFrame }


procedure TChatFrame.Button1Click(Sender: TObject);
begin
  uMainForm.MainForm.ShowExplore();
end;

procedure TChatFrame.Circle1Click(Sender: TObject);
begin
  TChatTextCardFrame.NewUser(Memo1.Text, chatBox);
  SharedData.AddMessage(Memo1.Text, TMessageRole.mrUser);
  Send();
  Memo1.Lines.Clear();
end;

procedure TChatFrame.Memo1ApplyStyleLookup(Sender: TObject);
begin
  var LBackground := TMemo(Sender).FindStyleResource('background') as TActiveStyleObject;

  if not Assigned(LBackground) then
    Exit;

  LBackground.Opacity := 0;
  LBackground.HitTest := False;
  LBackground.Repaint();
end;

procedure TChatFrame.NetHTTPClient1RequestCompleted(const Sender: TObject;
  const AResponse: IHTTPResponse);
begin
  TChatTextCardFrame.NewAssistant(AResponse.ContentAsString(), chatBox);
  SharedData.AddMessage(AResponse.ContentAsString(), TMessageRole.mrAssistant);
end;

procedure TChatFrame.Refresh;
begin
  for var LComp in chatBox do
    if (LComp is TFrame) then
      chatBox.Free();
end;

procedure TChatFrame.Send;
begin
  var LBody := '''
  {
    "input": {
      "image": "%s",
      "score_general_threshold": 0.35,
      "score_character_threshold": 0.85
    }
  }
  ''';
  LBody := String.Format(LBody, [Memo1.Lines.Text]);

  NetHttpClient1.ContentType := 'application/json';
  NetHttpClient1.ResponseTimeout := MaxInt;

  var LStream := TStringStream.Create(LBody);
  try
    LStream.Position := 0;
    NetHttpClient1.Post('http://192.168.88.108:5001/predictions', LStream);
  finally
    LStream.Free();
  end;
end;

end.
