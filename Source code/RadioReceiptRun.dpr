program RadioReceiptRun;

uses
  Vcl.Forms,
  UMainWindow in 'UMainWindow.pas' {FMainWindow},
  UAddProduct in 'UAddProduct.pas' {FAddProduct},
  USortedList in 'USortedList.pas' {FSortedList},
  USearchItem in 'USearchItem.pas' {FSearchItem},
  USharedData in 'USharedData.pas',
  uUsefulProc in 'uUsefulProc.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMainWindow, FMainWindow);
  Application.CreateForm(TFAddProduct, FAddProduct);
  Application.CreateForm(TFSortedList, FSortedList);
  Application.CreateForm(TFSearchItem, FSearchItem);
  Application.Run;
end.
