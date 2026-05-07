unit DatasetIterator.Test;

interface

uses
  DUnitX.TestFramework, Data.DB, Datasnap.DBClient, DatasetIterator;

type
  [TestFixture]
  TDatasetIteratorTest = class
  private
    FDataSet: TClientDataSet;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestForInLoop_ShouldIterateAllRecords;

    [Test]
    procedure TestForEach_ShouldIterateAllRecords;

    [Test]
    procedure TestForEach_WithBookmark_ShouldRestorePosition;

    [Test]
    procedure TestForEach_WithoutBookmark_ShouldNotRestorePosition;

    [Test]
    procedure TestForEach_WithFilter_ShouldIgnoreFilterDuringLoopAndRestoreAfter;

    [Test]
    procedure TestEmptyDataset_ShouldNotFail;
  end;

implementation

uses
  System.SysUtils;

procedure TDatasetIteratorTest.Setup;
begin
  FDataSet := TClientDataSet.Create(nil);
  FDataSet.FieldDefs.Add('ID', ftInteger);
  FDataSet.FieldDefs.Add('Name', ftString, 50);
  FDataSet.CreateDataSet;

  FDataSet.AppendRecord([1, 'Record 1']);
  FDataSet.AppendRecord([2, 'Record 2']);
  FDataSet.AppendRecord([3, 'Record 3']);
end;

procedure TDatasetIteratorTest.TearDown;
begin
  FDataSet.Free;
end;

procedure TDatasetIteratorTest.TestForInLoop_ShouldIterateAllRecords;
var
  LCount: Integer;
begin
  LCount := 0;
  for var DS in FDataSet do
  begin
    Inc(LCount);
    Assert.AreEqual(LCount, DS.FieldByName('ID').AsInteger);
  end;
  Assert.AreEqual(3, LCount, 'Should have iterated exactly 3 times.');
end;

procedure TDatasetIteratorTest.TestForEach_ShouldIterateAllRecords;
var
  LCount: Integer;
begin
  LCount := 0;
  // Usando a sobrecarga sem parâmetros que aplica os decorators padrões
  FDataSet.ForEach(procedure(DS: TDataSet)
    begin
      Inc(LCount);
      Assert.AreEqual(LCount, DS.FieldByName('ID').AsInteger);
    end);
  Assert.AreEqual(3, LCount, 'Should have iterated exactly 3 times.');
end;

procedure TDatasetIteratorTest.TestForEach_WithBookmark_ShouldRestorePosition;
begin
  FDataSet.First;
  FDataSet.Next; // Move to record 2
  Assert.AreEqual(2, FDataSet.FieldByName('ID').AsInteger);

  // Default configuration includes Bookmark
  FDataSet.ForEach(procedure(DS: TDataSet)
    begin
      // Just iterate
    end);

  Assert.AreEqual(2, FDataSet.FieldByName('ID').AsInteger, 'Should restore bookmark to record 2');
end;

procedure TDatasetIteratorTest.TestForEach_WithoutBookmark_ShouldNotRestorePosition;
begin
  FDataSet.First; // Record 1

  // Use only First decorator
  FDataSet.ForEach(procedure(DS: TDataSet)
    begin
      // Iterating will end up at EOF
    end,
    [TDatasetIterationConfigFirst]);

  Assert.IsTrue(FDataSet.Eof, 'Should be at EOF because bookmark was not preserved');
end;

procedure TDatasetIteratorTest.TestForEach_WithFilter_ShouldIgnoreFilterDuringLoopAndRestoreAfter;
var
  LCount: Integer;
begin
  FDataSet.Filter := 'ID = 1';
  FDataSet.Filtered := True;

  LCount := 0;
  // Use Filter decorator to temporarily disable the filter during iteration
  FDataSet.ForEach(procedure(DS: TDataSet)
    begin
      Inc(LCount);
    end,
    [TDatasetIterationConfigFirst, TDatasetIterationConfigFilter]);

  Assert.AreEqual(3, LCount, 'Should have iterated exactly 3 times because filter was ignored.');
  Assert.IsTrue(FDataSet.Filtered, 'Should restore Filtered state to True');
  Assert.AreEqual('ID = 1', FDataSet.Filter, 'Should restore Filter text');
end;

procedure TDatasetIteratorTest.TestEmptyDataset_ShouldNotFail;
var
  LEmptyDataset: TClientDataSet;
  LCount: Integer;
begin
  LEmptyDataset := TClientDataSet.Create(nil);
  try
    LEmptyDataset.FieldDefs.Add('ID', ftInteger);
    LEmptyDataset.CreateDataSet;

    LCount := 0;
    for var DS in LEmptyDataset do
      Inc(LCount);

    Assert.AreEqual(0, LCount, 'Empty dataset should iterate 0 times.');
  finally
    LEmptyDataset.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TDatasetIteratorTest);

end.
