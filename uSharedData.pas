unit uSharedData;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.StorageBin, FireDAC.Stan.StorageJSON, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TSharedData = class(TDataModule)
    mtChatModel: TFDMemTable;
    mtChatModelid: TStringField;
    mtChatModelProjects: TFDMemTable;
    mtChatModelProjectsid: TGuidField;
    mtChatModelProjectsmodel_id: TStringField;
    mtChatModelProjectsname: TStringField;
    mtChatModelProjectsdesc: TStringField;
    mtChatModelProjectsmode: TByteField;
    mtProjectChatMessages: TFDMemTable;
    mtProjectChatMessagesid: TGuidField;
    mtProjectChatMessagesproject_id: TGuidField;
    mtProjectChatMessagesseq: TIntegerField;
    mtProjectChatMessagesdata: TBlobField;
    mtProjectChatMessagesrole: TByteField;
    dsModel: TDataSource;
    dsModelProject: TDataSource;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    mtChatModelProjectscreated_at: TDateTimeField;
    procedure mtProjectChatMessagesNewRecord(DataSet: TDataSet);
    procedure DataModuleCreate(Sender: TObject);
    procedure mtProjectChatMessagesAfterPost(DataSet: TDataSet);
    procedure mtChatModelAfterPost(DataSet: TDataSet);
    procedure mtChatModelProjectsAfterPost(DataSet: TDataSet);
    procedure mtChatModelProjectsNewRecord(DataSet: TDataSet);
  private
    FRoot: string;
    procedure LoadDataSet(const ADatS: TFDMemTable; const ADatSFile: string);
  public
    function GenerateProjectName(): string;
    function StartChatOffline(
      const AModelId: string; const AName: string = ''): TGUID;
  end;

  TChatMode = (cmOnline, cmOffline);

var
  SharedData: TSharedData;

implementation

uses
  System.IOUtils;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TSharedData.DataModuleCreate(Sender: TObject);
begin
  FRoot := TPath.Combine(
    TPath.GetDocumentsPath(),
    'AIModelStudio',
    'db');

  if not TDirectory.Exists(FRoot) then
    TDirectory.CreateDirectory(FRoot);

  LoadDataSet(mtChatModel, 'chat_model.json');
  LoadDataSet(mtChatModelProjects, 'chat_model_projects.json');
  LoadDataSet(mtProjectChatMessages, 'chat_model_project_messages.json');
end;

procedure TSharedData.mtChatModelAfterPost(DataSet: TDataSet);
begin
  TFDMemTable(DataSet).SaveToFile(
    TPath.Combine(
      FRoot,
      'chat_model.json'),
    TFDStorageFormat.sfJSON);
end;

procedure TSharedData.mtChatModelProjectsAfterPost(DataSet: TDataSet);
begin
  TFDMemTable(DataSet).SaveToFile(
    TPath.Combine(
      FRoot,
      'chat_model_projects.json'),
    TFDStorageFormat.sfJSON);
end;

procedure TSharedData.mtChatModelProjectsNewRecord(DataSet: TDataSet);
begin
  mtChatModelProjectsmodel_id.Assign(mtChatModelid);
  mtChatModelProjectscreated_at.AsDateTime := Now();
end;

procedure TSharedData.mtProjectChatMessagesAfterPost(DataSet: TDataSet);
begin
  mtProjectChatMessages.SaveToFile(
    TPath.Combine(
      FRoot,
      'chat_model_project_messages.json'),
    TFDStorageFormat.sfJSON);
end;

procedure TSharedData.mtProjectChatMessagesNewRecord(DataSet: TDataSet);
begin
  mtProjectChatMessagesproject_id.Assign(mtChatModelProjectsmodel_id);
end;

function TSharedData.GenerateProjectName: string;
begin
  Result := 'New Project';
end;

procedure TSharedData.LoadDataSet(const ADatS: TFDMemTable; const ADatSFile: string);
begin
  var LDataBase := TPath.Combine(FRoot, ADatSFile);

  if TFile.Exists(LDataBase) then
    ADatS.LoadFromFile(LDataBase)
  else
    ADatS.CreateDataSet();
end;

function TSharedData.StartChatOffline(const AModelId: string;
  const AName: string): TGUID;
begin
  mtChatModel.Filter := String.Format('id=%s', [
    AModelId.QuotedString()]);
  mtChatModel.Filtered := true;

  mtChatModelProjects.Filter := String.Format('mode=%d', [
    Ord(TChatMode.cmOffline)]);
  mtChatModelProjects.Filtered := true;

  Result := TGUID.NewGuid();

  mtChatModel.Append();
  mtChatModelid.AsString := AModelId;
  mtChatModel.Post();

  mtChatModelProjects.Append();
  mtChatModelProjectsid.AsGuid := Result;
  if AName.Trim().IsEmpty() then begin
    mtChatModelProjectsname.AsString := 'New Project '
      + Succ(mtChatModelProjects.RecordCount).ToString()
  end else
    mtChatModelProjectsname.AsString := AName;
  mtChatModelProjectsmode.AsInteger := Ord(TChatMode.cmOffline);
  mtChatModelProjects.Post();
end;

end.
