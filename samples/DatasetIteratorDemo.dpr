program DatasetIteratorDemo;

uses
  Vcl.Forms,
  ufrmDatasetIterador in 'ufrmDatasetIterador.pas' {FDatasetIteratorSample},
  DatasetIterator in '..\src\DatasetIterator.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFDatasetIteratorSample, FDatasetIteratorSample);
  Application.Run;
end.
