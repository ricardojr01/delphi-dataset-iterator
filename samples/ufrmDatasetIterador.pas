unit ufrmDatasetIterador;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB, Datasnap.DBClient, DatasetIterator;

type
  TFDatasetIteratorSample = class(TForm)
    btnTeste: TButton;
    mmDebug: TMemo;
    procedure btnTesteClick(Sender: TObject);
  protected
    procedure PrintDebug(AMessage: string);
    procedure PrintDebugFmt(const AFormat: string; const AArgs: array of const);
    procedure PrintDatasetData(AClientDataset: TClientDataset);
    procedure PrintDatasetInformation(AClientDataset: TClientDataset; ADecorators: array of TDatasetIterationConfigDecoratorClass);
  end;

var
  FDatasetIteratorSample: TFDatasetIteratorSample;

implementation

{$R *.dfm}

procedure TFDatasetIteratorSample.PrintDebug(AMessage: string);
begin
  mmDebug.Lines.Add(AMessage);
end;

procedure TFDatasetIteratorSample.PrintDebugFmt(const AFormat: string;
  const AArgs: array of const);
begin
  PrintDebug(Format(AFormat, AArgs));
end;

procedure TFDatasetIteratorSample.PrintDatasetData(
  AClientDataset: TClientDataset);
begin
  PrintDebugFmt('ID: %d | Name: %s | Age: %d',
    [AClientDataset.FieldByName('ID').AsInteger,
     AClientDataset.FieldByName('Nome').AsString,
     AClientDataset.FieldByName('Idade').AsInteger]);
end;

procedure TFDatasetIteratorSample.PrintDatasetInformation(
  AClientDataset: TClientDataset;
  ADecorators: array of TDatasetIterationConfigDecoratorClass);
const
  cBooleanStr: array[Boolean] of string = ('FALSE', 'TRUE');
var
  LDecoratorsStr: string;
begin
  LDecoratorsStr := '';
  for var LDecorator in ADecorators do
  begin
    if LDecoratorsStr <> '' then
      LDecoratorsStr := LDecoratorsStr + ', ';
    LDecoratorsStr := LDecoratorsStr + LDecorator.ClassName;
  end;

  if LDecoratorsStr = '' then
    LDecoratorsStr := 'None';

  PrintDebugFmt('Decorators applied: [%s]', [LDecoratorsStr]);

  PrintDebug('Dataset information (Before)');
  PrintDebugFmt('  RecordCount: %d',[AClientDataset.RecordCount]);
  PrintDebugFmt('  RecNo:  %d',[AClientDataset.RecNo]);
  PrintDebugFmt('  Filtered: %s',[cBooleanStr[AClientDataset.Filtered]]);
  PrintDebugFmt('  Filter: %s',[AClientDataset.Filter]);
  PrintDebug('');

  PrintDebug('Dataset records:');
  AClientDataset.ForEach(
    procedure(DS: TDataSet)
    begin
      PrintDebugFmt('ID: %d | Name: %s | Age: %d',
        [DS.FieldByName('ID').AsInteger,
         DS.FieldByName('Nome').AsString,
         DS.FieldByName('Idade').AsInteger]);
    end,
    ADecorators);
  PrintDebug('');

  PrintDebug('Dataset information (After)');
  PrintDebugFmt('  RecordCount: %d',[AClientDataset.RecordCount]);
  PrintDebugFmt('  RecNo:  %d',[AClientDataset.RecNo]);
  PrintDebugFmt('  Filtered: %s',[cBooleanStr[AClientDataset.Filtered]]);
  PrintDebugFmt('  Filter: %s',[AClientDataset.Filter]);
  PrintDebug('');
  PrintDebug('');
end;

procedure TFDatasetIteratorSample.btnTesteClick(Sender: TObject);
var
  ClientDataset: TClientDataset;
begin
  mmDebug.Clear;

  ClientDataset := TClientDataset.Create(nil);
  try
    with ClientDataset.FieldDefs do
    begin
      Add('ID', ftInteger);
      Add('Nome', ftString, 50);
      Add('Idade', ftInteger);
    end;

    ClientDataset.CreateDataSet;
    ClientDataset.AppendRecord([1,'João', 30]);
    ClientDataset.AppendRecord([2,'Maria', 25]);
    ClientDataset.AppendRecord([3,'Carlos', 40]);

    PrintDebug('Start Example');
    PrintDebug('');

    PrintDebug('-------------------------------------------------------------');
    PrintDebug('Print: current state');
    PrintDebug('-------------------------------------------------------------');
    PrintDatasetInformation(ClientDataset, []);

    PrintDebug('-------------------------------------------------------------');
    PrintDebug('Print: Test 1');
    PrintDebug('-------------------------------------------------------------');
    PrintDatasetInformation(ClientDataset, [TDatasetIterationConfigFirst]);

    PrintDebug('-------------------------------------------------------------');
    PrintDebug('Print: Test 2');
    PrintDebug('-------------------------------------------------------------');

    ClientDataset.RecNo := 2;
    PrintDebug('Code:');
    PrintDebug('  ClientDataset.RecNo := 2;');
    PrintDebug('');

    PrintDatasetInformation(ClientDataset, [TDatasetIterationConfigBookmark, TDatasetIterationConfigControls, TDatasetIterationConfigFirst]);

    PrintDebug('-------------------------------------------------------------');
    PrintDebug('Print: Test 3 (Active Filter - Without Filter Decorator)');
    PrintDebug('-------------------------------------------------------------');

    ClientDataset.Filter := 'ID = 1';
    ClientDataset.Filtered := True;
    PrintDebug('Code:');
    PrintDebug('  ClientDataset.Filter := ''ID = 1'';');
    PrintDebug('  ClientDataset.Filtered := True;');
    PrintDebug('');

    PrintDatasetInformation(ClientDataset, [TDatasetIterationConfigBookmark, TDatasetIterationConfigControls, TDatasetIterationConfigFirst]);

    PrintDebug('-------------------------------------------------------------');
    PrintDebug('Print: Test 4 (Active Filter - With Filter Decorator)');
    PrintDebug('-------------------------------------------------------------');

    PrintDebug('Code:');
    PrintDebug('  Decorators: [..., TDatasetIterationConfigFilter]');
    PrintDebug('');

    PrintDatasetInformation(ClientDataset, [TDatasetIterationConfigBookmark, TDatasetIterationConfigControls, TDatasetIterationConfigFirst, TDatasetIterationConfigFilter]);

    PrintDebug('Checking filter restoration:');
    if ClientDataset.Filtered then
      PrintDebug('  [SUCCESS] Filter was restored successfully!')
    else
      PrintDebug('  [ERROR] Filter was NOT restored!');
    PrintDebug('');

    PrintDebug('-------------------------------------------------------------');
    PrintDebug('Print: Test 5 (For..in loop)');
    PrintDebug('-------------------------------------------------------------');

    PrintDebug('Code:');
    PrintDebug('  for var DS in ClientDataset do');
    PrintDebug('    ...');
    PrintDebug('');

    PrintDebug('Dataset records:');
    for var DS in ClientDataset do
    begin
      PrintDebugFmt('ID: %d | Name: %s | Age: %d',
        [DS.FieldByName('ID').AsInteger,
         DS.FieldByName('Nome').AsString,
         DS.FieldByName('Idade').AsInteger]);
    end;
    PrintDebug('');

  finally
    FreeAndNil(ClientDataset);
  end;
end;

end.

