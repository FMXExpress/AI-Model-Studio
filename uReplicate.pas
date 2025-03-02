unit uReplicate;

interface

uses  
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  System.Rtti,
  System.Generics.Collections,
  System.NetConsts,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.JSON.Types,
  System.JSON.Serializers,
  System.JSON.Readers,
  System.JSON.Writers;

type
  TReplicateClient = class;

  TAnyConverter = class(TJsonConverter)
  public
    function CanConvert(ATypeInf: PTypeInfo): Boolean; override;
    function ReadJson(const AReader: TJsonReader; ATypeInf: PTypeInfo;
      const AExistingValue: TValue; const ASerializer: TJsonSerializer)
      : TValue; override;
    procedure WriteJson(const AWriter: TJsonWriter; const AValue: TValue;
      const ASerializer: TJsonSerializer); override;

    class function Convert(const AReader: TJsonReader;
      const ATypeInf: PTypeInfo; const ASerializer: TJsonSerializer): TValue;
  end;

  TAnyArrayConverter = class(TJsonConverter)
  public
    function CanConvert(ATypeInf: PTypeInfo): Boolean; override;
    function ReadJson(const AReader: TJsonReader; ATypeInf: PTypeInfo;
      const AExistingValue: TValue; const ASerializer: TJsonSerializer)
      : TValue; override;
    procedure WriteJson(const AWriter: TJsonWriter; const AValue: TValue;
      const ASerializer: TJsonSerializer); override;

    class function Convert(const AReader: TJsonReader; 
      const ATypeInf: PTypeInfo; const ASerializer: TJsonSerializer): TValue;
  end;
  
  TDictConverter = class(TJsonConverter)
  public
    function CanConvert(ATypeInf: PTypeInfo): Boolean; override;
    function ReadJson(const AReader: TJsonReader; ATypeInf: PTypeInfo;
      const AExistingValue: TValue; const ASerializer: TJsonSerializer)
      : TValue; override;
    procedure WriteJson(const AWriter: TJsonWriter; const AValue: TValue;
      const ASerializer: TJsonSerializer); override;

    class function Convert(const AReader: TJsonReader;
      const ATypeInf: PTypeInfo; const ASerializer: TJsonSerializer): TValue;
  end;

  TAny = TValue;
  TAnyArray = TArray<TAny>;
  TDictPair = TPair<string, TAny>;
  TDict = TArray<TDictPair>;

  TResourceClass = class of TResource;
  /// <summary>
  /// A base class for representing a single object on the server.
  /// </summary>
  TResource = class(TPersistent);

  /// <summary>
  /// A version of a model.
  /// </summary>
  TVersion = class(TResource)
  private
    [JsonName('id')]
    FId: string;
    [JsonName('created_at')]
    FCreatedAt: TDateTime;
    [JsonName('cog_version')]
    FCogVersion: string;
    [JsonName('openapi_schema')]
    FOpenAPISchema: TDict;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    /// <summary>
    /// The unique ID of the version.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// When the version was created.
    /// </summary>
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;

    /// <summary>
    /// The version of the Cog used to create the version.
    /// </summary>
    property CogVersion: string read FCogVersion write FCogVersion;

    /// <summary>
    /// An OpenAPI description of the model inputs and outputs.
    /// </summary>
    property OpenAPISchema: TDict read FOpenAPISchema write FOpenAPISchema;
  end;

  /// <summary>
  /// A prediction made by a model hosted on Replicate.
  /// </summary>
  TPrediction = class(TResource)
  private
    [JsonName('id')]
    FId: string;
    [JsonName('model')]
    FModel: string;
    [JsonName('version')]
    FVersion: string;
    [JsonName('status')]
    FStatus: string;
    [JsonName('input')]
    FInput: TDict;
    [JsonName('output')]
    FOutput: TAny;
    [JsonName('logs')]
    FLogs: string;
    [JsonName('error')]
    FError: string;
    [JsonName('metrics')]
    FMetrics: TDict;
    [JsonName('created_at')]
    FCreatedAt: string;
    [JsonName('started_at')]
    FStartedAt: string;
    [JsonName('completed_at')]
    FCompletedAt: string;
    [JsonName('urls')]
    FUrls: TDict;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    /// <summary>
    /// The unique ID of the prediction.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// An identifier for the model used to create the prediction, in the form "owner/name".
    /// </summary>
    property Model: string read FModel write FModel;

    /// <summary>
    /// An identifier for the version of the model used to create the prediction.
    /// </summary>
    property Version: string read FVersion write FVersion;

    /// <summary>
    /// The status of the prediction.
    /// </summary>
    property Status: string read FStatus write FStatus;

    /// <summary>
    /// The input to the prediction.
    /// </summary>
    property Input: TDict read FInput write FInput;

    /// <summary>
    /// The output of the prediction.
    /// </summary>
    property Output: TAny read FOutput write FOutput;

    /// <summary>
    /// The logs of the prediction.
    /// </summary>
    property Logs: string read FLogs write FLogs;

    /// <summary>
    /// The error encountered during the prediction, if any.
    /// </summary>
    property Error: string read FError write FError;

    /// <summary>
    /// Metrics for the prediction.
    /// </summary>
    property Metrics: TDict read FMetrics write FMetrics;

    /// <summary>
    /// When the prediction was created.
    /// </summary>
    property CreatedAt: string read FCreatedAt write FCreatedAt;

    /// <summary>
    /// When the prediction was started.
    /// </summary>
    property StartedAt: string read FStartedAt write FStartedAt;

    /// <summary>
    /// When the prediction was completed, if finished.
    /// </summary>
    property CompletedAt: string read FCompletedAt write FCompletedAt;

    /// <summary>
    /// URLs associated with the prediction.
    /// </summary>
    property Urls: TDict read FUrls write FUrls;
  end;

  /// <summary>
  /// A machine learning model hosted on Replicate.
  /// </summary>
  TModel = class(TResource)
  private
    [JsonName('urls')]
    FUrl: string;
    [JsonName('owner')]
    FOwner: string;
    [JsonName('name')]
    FName: string;
    [JsonName('description')]
    FDescription: string;
    [JsonName('visibility')] // private or public
    FVisibility: string;
    [JsonName('github_url')]
    FGitHubUrl: string;
    [JsonName('paper_url')]
    FPaperUrl: string;
    [JsonName('license_url')]
    FLicenseUrl: string;
    [JsonName('run_count')]
    FRunCount: Integer;
    [JsonName('cover_image_url')]
    FCoverImageUrl: string;
    [JsonName('default_example')]
    FDefaultExample: TPrediction;
    [JsonName('latest_version')]
    FLatestVersion: TVersion;
    function GetId: string;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create();
    destructor Destroy(); override;

    function Clone(): TModel;

    /// <summary>
    /// The URL of the model.
    /// </summary>
    property Url: string read FUrl write FUrl;

    /// <summary>
    /// The owner of the model.
    /// </summary>
    property Owner: string read FOwner write FOwner;

    /// <summary>
    /// The name of the model.
    /// </summary>
    property Name: string read FName write FName;

    /// <summary>
    /// The description of the model.
    /// </summary>
    property Description: string read FDescription write FDescription;

    /// <summary>
    /// The visibility of the model. Can be 'public' or 'private'.
    /// </summary>
    property Visibility: string read FVisibility write FVisibility;

    /// <summary>
    /// The GitHub URL of the model.
    /// </summary>
    property GitHubUrl: string read FGitHubUrl write FGitHubUrl;

    /// <summary>
    /// The URL of the paper related to the model.
    /// </summary>
    property PaperUrl: string read FPaperUrl write FPaperUrl;

    /// <summary>
    /// The URL of the license for the model.
    /// </summary>
    property LicenseUrl: string read FLicenseUrl write FLicenseUrl;

    /// <summary>
    /// The number of runs of the model.
    /// </summary>
    property RunCount: Integer read FRunCount write FRunCount;

    /// <summary>
    /// The URL of the cover image for the model.
    /// </summary>
    property CoverImageUrl: string read FCoverImageUrl write FCoverImageUrl;

    /// <summary>
    /// The default example of the model.
    /// </summary>
    property DefaultExample: TPrediction read FDefaultExample write FDefaultExample;

    /// <summary>
    /// The latest version of the model.
    /// </summary>
    property LatestVersion: TVersion read FLatestVersion write FLatestVersion;

    /// <summary>
    /// Return the qualified model name, in the format "owner/name".
    /// </summary>
    property Id: string read GetId;
  end;

  /// <summary>
  /// A page of results from the API.
  /// </summary>
  TPage<T: class> = class(TPersistent)
  private
    [JsonName('previous')]
    FPrevious: string;
    [JsonName('next')]
    FNext: string;
    [JsonName('results')]
    FResults: TArray<T>;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    destructor Destroy(); override;
    /// <summary>
    /// A pointer to the previous page of results.
    /// </summary>
    property Previous: string read FPrevious write FPrevious;
    /// <summary>
    /// AA pointer to the next page of results.
    /// </summary>
    property Next: string read FNext write FNext;
    /// <summary>
    /// The results on this page.
    /// </summary>
    property Results: TArray<T> read FResults write FResults;
  end;

  TReplicateClient = class
  public type
    TModels = class
    private
      [unsafe]
      FClient: TReplicateClient;
    public
      constructor Create(const AClient: TReplicateClient);
      /// <summary>
      /// List all public models.
      /// </summary>
      /// <param name="ACursor">
      /// The cursor to use for pagination. Use the value of `Page.next` or `Page.previous`.
      /// </param>
      /// <returns>
      /// A page of of models.
      /// </returns>
      function List(const ACursor: string): TPage<TModel>;
      procedure AsyncList(const ACursor: string;
        const ACallback: TProc<TPage<TModel>, Exception>);
      /// <summary>
      /// Search for public models.
      /// </summary>
      /// <param name="AQuery">
      /// The search query.
      /// </param>
      /// <returns>
      /// A page of of models.
      /// </returns>
      function Search(const AQuery: string): TPage<TModel>;
      procedure AsyncSearch(const AQuery: string;
        const ACallback: TProc<TPage<TModel>, Exception>);
    end;
  private
    FBaseUrl: string;
    FToken: string;
    FModels: TModels;
    procedure Request(
      const AMethod: string; 
      const APath: string;
      const APrepareCallback: TProc<THttpClient, TStream>; 
      const AResponseCallback: TProc<IHTTPResponse>);
    procedure CheckResponse(const AResponse: IHTTPResponse);
  public
    constructor Create();
    destructor Destroy(); override;
    
    property BaseUrl: string read FBaseUrl write FBaseUrl;
    property Token: string read FToken write FToken;
    property Models: TModels read FModels;
  end;

  ETokenNotProvided = class(Exception);

  EResponseError = class(Exception);

implementation

uses
  System.StrUtils,
  System.IOUtils,
  System.Variants,
  System.Threading;

var
  GlobalSerializer: TJsonSerializer;

{ TAnyConverter }

function TAnyConverter.CanConvert(ATypeInf: PTypeInfo): Boolean;
begin
  Result := ATypeInf = TypeInfo(TAny);
end;

function TAnyConverter.ReadJson(const AReader: TJsonReader; ATypeInf: PTypeInfo;
  const AExistingValue: TValue; const ASerializer: TJsonSerializer): TValue;
begin
  Result := Convert(AReader, ATypeInf, ASerializer);
end;

procedure TAnyConverter.WriteJson(const AWriter: TJsonWriter;
  const AValue: TValue; const ASerializer: TJsonSerializer);
begin
  inherited;
end;

class function TAnyConverter.Convert(const AReader: TJsonReader;
  const ATypeInf: PTypeInfo; const ASerializer: TJsonSerializer): TValue;
begin
  repeat
    case AReader.TokenType of
      TJsonToken.StartObject:
        Exit(TDictConverter.Convert(AReader, nil, ASerializer));
      TJsonToken.StartArray:
        Exit(TAnyArrayConverter.Convert(AReader, nil, ASerializer));
      TJsonToken.Integer,
      TJsonToken.Float,
      TJsonToken.String,
      TJsonToken.Date,
      TJsonToken.Bytes,
      TJsonToken.Boolean:
        Exit(AReader.Value);
      TJsonToken.StartConstructor:
        Exit(AReader.Value);
      TJsonToken.Null,
      TJsonToken.Undefined:
        //AReader.Skip();
        Exit(TValue.Empty);
    end;
  until not AReader.Read();
end;

{ TAnyArrayConverter }

function TAnyArrayConverter.CanConvert(ATypeInf: PTypeInfo): Boolean;
begin
  Result := ATypeInf = TypeInfo(TAnyArray);
end;

function TAnyArrayConverter.ReadJson(const AReader: TJsonReader;
  ATypeInf: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
begin
  Result := Convert(AReader, ATypeInf, ASerializer);
end;

procedure TAnyArrayConverter.WriteJson(const AWriter: TJsonWriter;
  const AValue: TValue; const ASerializer: TJsonSerializer);
begin
  inherited;
end;

class function TAnyArrayConverter.Convert(const AReader: TJsonReader;
  const ATypeInf: PTypeInfo; const ASerializer: TJsonSerializer): TValue;
begin
  var LArray: TAnyArray := nil;
  
  while AReader.Read() do
    case AReader.TokenType of
      TJsonToken.EndArray:
        Break;
      TJsonToken.Comment:
        // ignore
      ;
      else begin
        LArray := LArray + [
          TAnyConverter.Convert(AReader, nil, ASerializer)];
      end;
    end;
  
  Result := TValue.From<TAnyArray>(LArray);
end;

{ TDictConverter }

function TDictConverter.CanConvert(ATypeInf: PTypeInfo): Boolean;
begin
  Result := ATypeInf = TypeInfo(TDict);
end;

function TDictConverter.ReadJson(const AReader: TJsonReader;
  ATypeInf: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
begin
  Result := Convert(AReader, ATypeInf, ASerializer);
end;

procedure TDictConverter.WriteJson(const AWriter: TJsonWriter;
  const AValue: TValue; const ASerializer: TJsonSerializer);
begin
  inherited;
end;

class function TDictConverter.Convert(const AReader: TJsonReader;
  const ATypeInf: PTypeInfo; const ASerializer: TJsonSerializer): TValue;
begin

  var LMakePair := function(): TDictPair begin
    var LKey := AReader.Value.AsString;
    var LValue := TAnyConverter.Convert(AReader, nil, ASerializer);
    Result := TDictPair.Create(LKey, LValue);
  end;

  var LValues := TList<TDictPair>.Create();
  try
    while AReader.Read() do
      case AReader.TokenType of
        TJsonToken.PropertyName:
          LValues.Add(LMakePair());
        TJsonToken.EndObject:
          Break;
      end;

    Result := TValue.From<TDict>(LValues.ToArray());
  finally
    LValues.Free();
  end;
end;

{ TVersion }

procedure TVersion.AssignTo(Dest: TPersistent);
begin
  TVersion(Dest).FId := FId;
  TVersion(Dest).FCreatedAt := FCreatedAt;
  TVersion(Dest).FCogVersion := FCogVersion;
  TVersion(Dest).FOpenAPISchema := FOpenAPISchema;
end;

{ TPrediction }

procedure TPrediction.AssignTo(Dest: TPersistent);
begin
  TPrediction(Dest).FId := FId;
  TPrediction(Dest).FModel := FModel;
  TPrediction(Dest).FVersion := FVersion;
  TPrediction(Dest).FStatus := FStatus;
  TPrediction(Dest).FInput := FInput;
  TPrediction(Dest).FOutput := FOutput;
  TPrediction(Dest).FLogs := FLogs;
  TPrediction(Dest).FError := FError;
  TPrediction(Dest).FMetrics := FMetrics;
  TPrediction(Dest).FCreatedAt := FCreatedAt;
  TPrediction(Dest).FStartedAt := FStartedAt;
  TPrediction(Dest).FCompletedAt := FCompletedAt;
  TPrediction(Dest).FUrls := FUrls;
end;

{ TModel }

constructor TModel.Create();
begin
  inherited;
  FDefaultExample := TPrediction.Create();
  FLatestVersion := TVersion.Create();
end;

destructor TModel.Destroy;
begin
  FLatestVersion.Free();
  FDefaultExample.Free();
  inherited;
end;

procedure TModel.AssignTo(Dest: TPersistent);
begin
  TModel(Dest).FUrl := FUrl;
  TModel(Dest).FOwner := FOwner;
  TModel(Dest).FName := FName;
  TModel(Dest).FDescription := FDescription;
  TModel(Dest).FVisibility := FVisibility;
  TModel(Dest).FGitHubUrl := FGitHubUrl;
  TModel(Dest).FPaperUrl := FPaperUrl;
  TModel(Dest).FLicenseUrl := FLicenseUrl;
  TModel(Dest).FRunCount := FRunCount;
  TModel(Dest).FCoverImageUrl := FCoverImageUrl;
  TModel(Dest).FDefaultExample := TPrediction.Create();
  TModel(Dest).FLatestVersion := TVersion.Create();

  TModel(Dest).FDefaultExample.Assign(FDefaultExample);
  TModel(Dest).FLatestVersion.Assign(FLatestVersion);
end;

function TModel.Clone: TModel;
begin
  Result := TModel.Create();
  Result.Assign(Self);
end;

function TModel.GetId: string;
begin
  Result := FOwner + '/' + FName;
end;

{ TPage<T> }

procedure TPage<T>.AssignTo(Dest: TPersistent);
begin
  TPage<T>(Dest).FPrevious := FPrevious;
  TPage<T>(Dest).FNext := FNext;

  var LResults: TArray<T> := nil;
  for var LResult in FResults do
    if LResult is TResource then begin
      var LClone := TResourceClass(LResult.ClassType).Create();
      LClone.Assign(TPersistent(LResult));
      LResults := LResults + [T(LClone)];
    end;

  TPage<T>(Dest).FResults := LResults;
end;

destructor TPage<T>.Destroy;
begin
  for var LItem in FResults do
    LItem.Free();
  inherited;
end;

{ TReplicateClient }

constructor TReplicateClient.Create;
begin
  FModels := TModels.Create(Self);
end;

destructor TReplicateClient.Destroy;
begin
  FModels.Free();
  inherited;
end;

procedure TReplicateClient.Request(const AMethod: string; 
  const APath: string;
  const APrepareCallback: TProc<THttpClient, TStream>;
  const AResponseCallback: TProc<IHTTPResponse>);
begin
  var LUri := 'https://api.replicate.com';

  if not FBaseUrl.IsEmpty() then
    LUri := FBaseUrl;
                       
  LUri := LUri + APath.Replace(LUri, String.Empty, []);

  if FToken.Trim().IsEmpty() then
    raise ETokenNotProvided.Create('Token not provided');
  
  var LClient := THttpClient.Create();
  try
    var LContent := TStringStream.Create(String.Empty, TEncoding.UTF8);
    try
      LClient.CustomHeaders['Authorization'] := 'Bearer ' + FToken;
      
      if Assigned(APrepareCallback) then
        APrepareCallback(LClient, LContent);
      
      LContent.Position := 0;
      var LResponse := IHTTPResponse(LClient.Execute(AMethod, LUri, LContent));
      CheckResponse(LResponse);
      AResponseCallback(LResponse);          
    finally
      LContent.Free();
    end;    
  finally
    LClient.Free();
  end; 
end;

procedure TReplicateClient.CheckResponse(const AResponse: IHTTPResponse);
begin
  if (AResponse.StatusCode div 100) <> 2 then
    raise EResponseError.CreateFmt(
      'Request failed with status %d - %s', [
        AResponse.StatusCode,
        AResponse.StatusText]);
end;

{ TReplicateClient.TModels }

constructor TReplicateClient.TModels.Create(const AClient: TReplicateClient);
begin
  FClient := AClient;
end;

function TReplicateClient.TModels.List(const ACursor: string): TPage<TModel>;
begin
  var LResult := nil;
  
  FClient.Request(
    'GET',
    IfThen(ACursor.IsEmpty(), '/v1/models', ACursor),
    nil,
    procedure(AResponse: IHTTPResponse)
    begin
      TFile.WriteAllText('C:\Dev\Delphi\Projects\AI-Model-Studio\log.json', AResponse.ContentAsString());
      LResult := GlobalSerializer.Deserialize<TPage<TModel>>(
        AResponse.ContentAsString());
    end);

  Result := LResult;
end;

procedure TReplicateClient.TModels.AsyncList(const ACursor: string;
  const ACallback: TProc<TPage<TModel>, Exception>);
begin
  TTask.Run(procedure() begin
    try
      ACallback(List(ACursor), nil);
    except
      on E: Exception do
        ACallback(nil, AcquireExceptionObject() as Exception);
    end;
  end);
end;

function TReplicateClient.TModels.Search(const AQuery: string): TPage<TModel>;
begin
  var LResult := nil;

  FClient.Request(
    'QUERY',
    '/v1/models',
    procedure(AClient: THttpClient; AContent: TStream)
    begin
      AClient.ContentType := 'text/plain';

      var LBody := TEncoding.UTF8.GetBytes(AQuery);
      AContent.WriteBuffer(LBody[0], Length(LBody));
    end,
    procedure(AResponse: IHTTPResponse)
    begin
      TFile.WriteAllText('C:\Dev\Delphi\Projects\AI-Model-Studio\log.json', AResponse.ContentAsString());
      LResult := GlobalSerializer.Deserialize<TPage<TModel>>(
        AResponse.ContentAsString());
    end);

  Result := LResult;
end;

procedure TReplicateClient.TModels.AsyncSearch(const AQuery: string;
  const ACallback: TProc<TPage<TModel>, Exception>);
begin
  TTask.Run(procedure() begin
    try
      ACallback(Search(AQuery), nil);
    except
      on E: Exception do
        ACallback(nil, AcquireExceptionObject() as Exception);
    end;
  end);
end;

initialization
  GlobalSerializer := TJSONSerializer.Create();
  GlobalSerializer.Converters.Add(TAnyConverter.Create());
  GlobalSerializer.Converters.Add(TAnyArrayConverter.Create());
  GlobalSerializer.Converters.Add(TDictConverter.Create());
  //GlobalSerializer.Formatting := TJsonFormatting.Indented;

finalization
  GlobalSerializer := TJSONSerializer.Create();
  for var LItem in GlobalSerializer.Converters do
    LItem.Free();
end.
