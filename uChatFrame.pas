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
  FMX.Edit, FMX.Layouts;

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
    procedure Button1Click(Sender: TObject);
  end;

implementation

uses
  uSharedData,
  uMainForm;

{$R *.fmx}

{ TChatFrame }


procedure TChatFrame.Button1Click(Sender: TObject);
begin
  uMainForm.MainForm.ShowExplore();
end;

end.
