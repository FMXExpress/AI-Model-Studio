unit uDocker;

interface

uses
  System.SysUtils,
  System.Classes,
  uReplicate;

type
  TContainerStatus = (none, running, exited, created, paused, dead);

  TDockerUtility = class
  private
    class function MakeContainerName(
      const AModel: TModel): string; static;
  public
    class function GetContainerStatus(
      const AModel: TModel): TContainerStatus; static;
    class function GetContainerPort(
      const AModel: TModel): integer; static;
    class function GetNextPortAvailable(): integer;

    class function IsImageInstalled(
      const AModel: TModel): boolean; static;
    class function IsContainerRunning(
      const AModel: TModel): boolean; static;


    class procedure DeleteContainer(
      const AModel: TModel); static;

    class procedure Run(
      const AModel: TModel;
      const ACallback: TProc<string>); static;
    class procedure Start(
      const AModel: TModel;
      const ACallback: TProc<string>); static;
    class procedure RunOrStart(
      const AModel: TModel;
      const ACallback: TProc<string>); static;
  end;

implementation

uses
  System.Threading,
  System.Hash,
  uRunCommand,
  System.TypInfo;

{ TDockerUtility }

class function TDockerUtility.MakeContainerName(const AModel: TModel): string;
begin
  Result := THashMD5.GetHashString(AModel.Id);
end;

class function TDockerUtility.IsContainerRunning(const AModel: TModel): boolean;
begin
  Result := GetContainerStatus(AModel) = TContainerStatus.running;
end;

class function TDockerUtility.IsImageInstalled(const AModel: TModel): boolean;
begin
  var LCmd := 'docker images -q '
    + 'r8.im/'
    + AModel.Id
    + '@sha256:'
    + AModel.LatestVersion.Id;

  Result := not RunCommand(LCmd).Trim().IsEmpty();
end;

class procedure TDockerUtility.DeleteContainer(const AModel: TModel);
begin
  RunCommand(String.Format('docker rm %s', [MakeContainerName(AModel)]))
end;

class function TDockerUtility.GetContainerPort(const AModel: TModel): integer;
begin
  var LOutput := RunCommand(
    String.Format('docker port %s 5000', [
      MakeContainerName(AModel)]));

  Result := StrToIntDef(LOutput, 0);
end;

class function TDockerUtility.GetContainerStatus(const AModel: TModel): TContainerStatus;
begin
  var LContainerName := MakeContainerName(AModel);

  var LCmd := 'docker inspect '
   + '-f "{{.State.Status}}" '
   + '%s';

  LCmd := String.Format(LCmd, [LContainerName]);

  var LOutput := RunCommand(LCmd);

  if LOutput.Trim().IsEmpty() then
    Exit(TContainerStatus.None);

  var LStatusEnum := GetEnumValue(TypeInfo(TContainerStatus), LOutput.Trim());
  if (LStatusEnum > Ord(High(TContainerStatus))) then
    Exit(TContainerStatus.None);

  Result := TContainerStatus(
    GetEnumValue(TypeInfo(TContainerStatus), LOutput.Trim()));
end;

class function TDockerUtility.GetNextPortAvailable: integer;
begin
  Result := 5001;

  var LOutput := RunCommand('docker ps --format "{{.Names}} {{.Ports}}"');
  var LLines := LOutput.Split([sLineBreak]);

  //'57150e2a3e54e054ee66c06ed5441522 0.0.0.0:6000->5000/tcp
  for var LLine in LLines do
  begin
    var LStartPos := LLine.IndexOf(':') + 1;
    var LEndPos := LLine.IndexOf('->');

    if (LStartPos >= LEndPos) then
      Continue;

    var LPortStr := LLine.Substring(LStartPos, LEndPos - LStartPos);
    var LPort := StrToIntDef(LPortStr, 5000) + 1;

    if LPort > Result then
      Result := LPort;
  end;
end;

class procedure TDockerUtility.Run(const AModel: TModel;
  const ACallback: TProc<string>);
begin
  var LCmd := 'docker run -d -p '
    + GetNextPortAvailable().ToString() + ':5000 '
    + '--name '
    + MakeContainerName(AModel) + ' '
    //+ '--gpus=all '
    + 'r8.im/'
    + AModel.Id
    + '@sha256:'
    + AModel.LatestVersion.Id;

  RunCommand(LCmd, ACallback);
end;

class procedure TDockerUtility.Start(const AModel: TModel;
  const ACallback: TProc<string>);
begin
  RunCommand(
    String.Format('docker start %s', [MakeContainerName(AModel)]),
    ACallback
  );
end;

class procedure TDockerUtility.RunOrStart(const AModel: TModel;
  const ACallback: TProc<string>);
const
  NON_RUNNING_STATUSES = [
    TContainerStatus.exited,
    TContainerStatus.created,
    TContainerStatus.paused,
    TContainerStatus.dead
  ];
begin
  if GetContainerStatus(AModel) in NON_RUNNING_STATUSES then
    Start(AModel, ACallback)
  else
    Run(AModel, ACallback);
end;

end.
