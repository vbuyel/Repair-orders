Unit USortedList;

Interface

// Used libraries
Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  {Added ->} USharedData, uUsefulProc;

// Form's type
Type
  TFSortedList = Class(TForm)
    BBack: TButton;
    LTitle: TLabel;
    MSortedList: TMemo;
    BSort: TButton;
    CBChooseSort: TComboBox;
    Procedure SortItems(Sendr: TObject);
    Procedure BBackClick(Sender: TObject);
    Procedure CBChooseSortSelected(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
  FSortedList: TFSortedList;

Implementation

{$R *.dfm}

// When user choosed a methon to sort
Procedure TFSortedList.CBChooseSortSelected(Sender: TObject);
Begin
  BSort.Enabled := True;
End;

// Sort items
Procedure TFSortedList.SortItems(Sendr: TObject);
Var
  Temp: PItem;
  SortedArray: Array of PItem;
  i: integer;
{
 Temp - time variable with item's data
 SortedArray - array with all items
 i - index
}
Begin
  // Inicialisation
  i := 1;
  SetLength(SortedArray,  i);

  MSortedList.Clear;

  // Array initialisation
  While ItemList^.ItemNext <> nil do
  Begin
    Inc(i);
    SetLength(SortedArray,  i);
    ItemList := ItemList^.ItemNext;
  End;

  // list in start position
  InStart;

  // For each item in array
  For i := 0 to length(SortedArray)-1 do
  Begin
    Temp := ItemList;
    ItemList := ItemList^.ItemNext;
    Temp^.ItemNext := nil;
    If ItemList <> nil then
      ItemList^.ItemPrev := nil;

    SortedArray[i] := Temp;
  End;

  // If array consist more then 1 item
  If length(SortedArray) > 1 then
  Begin
    // Sort years  (For instance: 2025, ..., 2020)
    QuickSort(SortedArray, 0, length(SortedArray)-1, 'Year', (CBChooseSort.ItemIndex = 0));

    // Sort months (For instance: 09.2025, 08.2025, ..., 10.2020)
    QuickSort(SortedArray, 0, length(SortedArray)-1, 'Month', (CBChooseSort.ItemIndex = 0));

    // Sort days   (For instance: 11.09.2025, 13.09.2025, ..., 21.10.2020)
    QuickSort(SortedArray, 0, length(SortedArray)-1, 'Day', (CBChooseSort.ItemIndex = 0));
  End;

  // Take top item
  ItemList := SortedArray[0];

  // From array to list
  For i := 0 to length(SortedArray)-1 do
  Begin
    If i = 0 then
      SortedArray[i]^.ItemPrev := nil
    Else
      SortedArray[i]^.ItemPrev := SortedArray[i-1];

    If i = length(SortedArray)-1 then
      SortedArray[i]^.ItemNext := nil
    Else
      SortedArray[i]^.ItemNext := SortedArray[i+1];
  End;

  // Print this list
  PrintList(ItemList, MSortedList);
End;

// Click on back button
Procedure TFSortedList.BBackClick(Sender: TObject);
Begin
  Self.Close;
  OpenMainMenu;
  If Assigned(Application.MainForm) then
    Application.MainForm.Show;
End;

End.
