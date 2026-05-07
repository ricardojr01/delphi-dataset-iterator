unit DatasetIterator;

interface

uses
  Data.DB, System.SysUtils, System.Classes;

type
  IDatasetIterationConfigDecorator = interface
  ['{7A25AAA3-C193-49AD-8B4E-81604AA179AD}']
  end;

  TDatasetIterationConfigDecorator = class(TInterfacedObject, IDatasetIterationConfigDecorator)
  protected
    FDataSet: TDataSet;
    FConfiguracao: IDatasetIterationConfigDecorator;
  public
    constructor Create(const ADataSet: TDataSet; AConfiguracao: IDatasetIterationConfigDecorator = nil); virtual;
  end;

  TDatasetIterationConfigDecoratorClass = class of TDatasetIterationConfigDecorator;

  TDatasetIterationConfigBookmark = class(TDatasetIterationConfigDecorator)
  private
    FBookmark: TBookmark;
  public
    constructor Create(const ADataSet: TDataSet; AConfiguracao: IDatasetIterationConfigDecorator = nil); override;
    destructor Destroy; override;
  end;

  TDatasetIterationConfigFilter = class(TDatasetIterationConfigDecorator)
  private
    FFiltered: Boolean;
    FFilter: string;
  public
    constructor Create(const ADataSet: TDataSet; AConfiguracao: IDatasetIterationConfigDecorator = nil); override;
    destructor Destroy; override;
  end;

  TDatasetIterationConfigControls = class(TDatasetIterationConfigDecorator)
  public
    constructor Create(const ADataSet: TDataSet; AConfiguracao: IDatasetIterationConfigDecorator = nil); override;
    destructor Destroy; override;
  end;

  TDatasetIterationConfigFirst = class(TDatasetIterationConfigDecorator)
  public
    constructor Create(const ADataSet: TDataSet; AConfiguracao: IDatasetIterationConfigDecorator = nil); override;
  end;

  TDataSetEnumerator = class
  private
    FDataSet: TDataSet;
    FStartOfFile: Boolean;
    FDecorator: IDatasetIterationConfigDecorator;
  public
    constructor Create(ADataSet: TDataSet); overload;
    constructor Create(ADataSet: TDataSet; ADecorators: array of TDatasetIterationConfigDecoratorClass); overload;
    function GetCurrent: TDataSet;
    function MoveNext: Boolean;
    property Current: TDataSet read GetCurrent;
  end;

  TDataSetHelper = class helper for TDataSet
  private
    function CreateDecorators(ADecorators: array of TDatasetIterationConfigDecoratorClass): IDatasetIterationConfigDecorator;
  public
    procedure ForEach(AAction: TProc<TDataSet>); overload;
    procedure ForEach(AAction: TProc<TDataSet>; ADecorators: array of TDatasetIterationConfigDecoratorClass); overload;
    function GetEnumerator: TDataSetEnumerator;
  end;

implementation

{ TDatasetIterationConfigDecorator }

constructor TDatasetIterationConfigDecorator.Create(const ADataSet: TDataSet; AConfiguracao: IDatasetIterationConfigDecorator);
begin
  inherited Create;
  FDataSet := ADataSet;
  FConfiguracao := AConfiguracao;
end;

{ TDatasetIterationConfigBookmark }

constructor TDatasetIterationConfigBookmark.Create(const ADataSet: TDataSet; AConfiguracao: IDatasetIterationConfigDecorator);
begin
  inherited Create(ADataSet, AConfiguracao);
  FBookmark := FDataSet.GetBookmark;
end;

destructor TDatasetIterationConfigBookmark.Destroy;
begin
  if Assigned(FDataSet) then
  begin
    if FDataSet.BookmarkValid(FBookmark) then
      FDataSet.GotoBookmark(FBookmark);
    FDataSet.FreeBookmark(FBookmark);
  end;
  inherited;
end;

{ TDatasetIterationConfigFilter }

constructor TDatasetIterationConfigFilter.Create(const ADataSet: TDataSet; AConfiguracao: IDatasetIterationConfigDecorator);
begin
  inherited Create(ADataSet, AConfiguracao);
  FFilter := FDataSet.Filter;
  FFiltered := FDataSet.Filtered;
  
  FDataSet.Filtered := False;
  FDataSet.Filter := '';
end;

destructor TDatasetIterationConfigFilter.Destroy;
begin
  if Assigned(FDataSet) then
  begin
    FDataSet.Filter := FFilter;
    if FFiltered then
      FDataSet.Filtered := FFiltered;
  end;
  inherited;
end;

{ TDatasetIterationConfigControls }

constructor TDatasetIterationConfigControls.Create(const ADataSet: TDataSet; AConfiguracao: IDatasetIterationConfigDecorator);
begin
  inherited Create(ADataSet, AConfiguracao);
  FDataSet.DisableControls;
end;

destructor TDatasetIterationConfigControls.Destroy;
begin
  if Assigned(FDataSet) then
    FDataSet.EnableControls;
  inherited;
end;

{ TDatasetIterationConfigFirst }

constructor TDatasetIterationConfigFirst.Create(const ADataSet: TDataSet; AConfiguracao: IDatasetIterationConfigDecorator);
begin
  inherited Create(ADataSet, AConfiguracao);
  FDataSet.First;
end;

{ TDataSetEnumerator }

constructor TDataSetEnumerator.Create(ADataSet: TDataSet);
begin
  Create(ADataSet, [TDatasetIterationConfigBookmark, TDatasetIterationConfigControls, TDatasetIterationConfigFirst]);
end;

constructor TDataSetEnumerator.Create(ADataSet: TDataSet; ADecorators: array of TDatasetIterationConfigDecoratorClass);
begin
  FDataSet := ADataSet;
  FStartOfFile := True;
  FDecorator := FDataSet.CreateDecorators(ADecorators);
end;

function TDataSetEnumerator.GetCurrent: TDataSet;
begin
  Result := FDataSet;
end;

function TDataSetEnumerator.MoveNext: Boolean;
begin
  if FStartOfFile then
  begin
    FStartOfFile := False;
    Result := not FDataSet.IsEmpty;
  end
  else
  begin
    FDataSet.Next;
    Result := not FDataSet.Eof;
  end;
end;

{ TDataSetHelper }

function TDataSetHelper.CreateDecorators(ADecorators: array of TDatasetIterationConfigDecoratorClass): IDatasetIterationConfigDecorator;
var
  I: Integer;
begin
  Result := nil;
  for I := Low(ADecorators) to High(ADecorators) do
    Result := ADecorators[I].Create(Self, Result);
end;

procedure TDataSetHelper.ForEach(AAction: TProc<TDataSet>);
begin
  ForEach(AAction, [TDatasetIterationConfigBookmark, TDatasetIterationConfigControls, TDatasetIterationConfigFirst]);
end;

procedure TDataSetHelper.ForEach(AAction: TProc<TDataSet>; ADecorators: array of TDatasetIterationConfigDecoratorClass);
var
  LDecorator: IDatasetIterationConfigDecorator;
begin
  if not Assigned(AAction) then
    Exit;

  LDecorator := CreateDecorators(ADecorators);

  while not Self.Eof do
  begin
    AAction(Self);
    Self.Next;
  end;
end;

function TDataSetHelper.GetEnumerator: TDataSetEnumerator;
begin
  Result := TDataSetEnumerator.Create(Self);
end;

end.
