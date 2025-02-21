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
  FMX.Styles.Objects;

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
    procedure Button1Click(Sender: TObject);
    procedure Memo1ApplyStyleLookup(Sender: TObject);
    procedure Circle1Click(Sender: TObject);
  end;

implementation

uses
  uSharedData,
  uMainForm,
  uChatUserTextCardFrame;

{$R *.fmx}

{ TChatFrame }


procedure TChatFrame.Button1Click(Sender: TObject);
begin
  uMainForm.MainForm.ShowExplore();
end;

procedure TChatFrame.Circle1Click(Sender: TObject);
begin
  TChatTextCardFrame.New(Memo1.Text, chatBox);
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

end.
