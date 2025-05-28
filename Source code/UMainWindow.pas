Unit UMainWindow;

Interface

// Used libraries
Uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, ComObj, System.SysUtils, Graphics,
  {Added ->} USearchItem, USortedList, UAddProduct,
             USharedData, uUsefulProc;

// Form's type
Type
  TFMainWindow = Class(TForm)
    LTitle: TLabel;
    LData: TLabel;
    EDay: TEdit;
    LPoint1: TLabel;
    EMonth: TEdit;
    LPoint2: TLabel;
    EYear: TEdit;
    BCheck: TButton;
    LItemsDone: TLabel;
    LItemsNotDone: TLabel;
    MItemsDone: TMemo;
    MItemsNotDone: TMemo;
    BAddItem: TButton;
    BSortItems: TButton;
    BSearchItem: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    BSaveAsFile: TButton;
    SDItemData: TSaveDialog;
    Procedure BAddItemClick(Sender: TObject);
    Procedure BSortItemsClick(Sender: TObject);
    Procedure BSearchItemClick(Sender: TObject);
    Procedure EDayEnter(Sender: TObject);
    Procedure EMonthEnter(Sender: TObject);
    Procedure EYearEnter(Sender: TObject);
    Procedure EDayExit(Sender: TObject);
    Procedure EMonthExit(Sender: TObject);
    Procedure EYearExit(Sender: TObject);
    Procedure BCheckClick(Sender: TObject);
    Procedure BSaveAsFileClick(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
  FMainWindow: TFMainWindow;

Implementation

{$R *.dfm}

// Open form FAddProduct
Procedure TFMainWindow.BAddItemClick(Sender: TObject);
Begin
  Self.Hide;
  FAddProduct.Show;
End;

// Check tasks for completed or not completed
Procedure TFMainWindow.BCheckClick(Sender: TObject);
Var
  ItemSearch: PItem;
  Item: TThisItem;
  ItemTaken: boolean;
  Error, AllErrors: Integer;
{
 ItemSearch - list of items
 Item - current item
 ItemTaken - check if user data >= item's data
 Error, AllErrors - code error
}
Begin
  // Initialisation
  Error := 0;
  AllErrors := 0;

  ItemSearch := ItemList;
  MItemsDone.Clear;
  MItemsNotDone.Clear;

  // For each item
  While (ItemSearch <> nil) and (AllErrors = 0) do
  Begin

    // Data of delivered item
    If (EDay.Text <> 'ДД')
      and (EMonth.Text <> 'ММ')
      and (EYear.Text <> 'ГГГГ') then
    Begin
      Val(EDay.Text, Item.Deadline.Day, Error);
      AllErrors := AllErrors + Error;
      Val(EMonth.Text, Item.Deadline.Month, Error);
      AllErrors := AllErrors + Error;
      Val(EYear.Text, Item.Deadline.Year, Error);
      AllErrors := AllErrors + Error;
    End;

    // Check day
    If not ( (AllErrors = 0) and (Item.Deadline.Day > 0)
            and ((Item.Deadline.Day < 30 + Ord((Item.Deadline.Month mod 2 = 0) and (Item.Deadline.Month <> 2)))) ) then
      AllErrors := AllErrors + 11;

    // Check month
    If not ( (AllErrors = 0) and (Item.Deadline.Month > 0)
            and (Item.Deadline.Month < 13) ) then
      AllErrors := AllErrors + 22;

    // Result of checking
    If AllErrors > 0 then
      ShowMessage('Введите дату корректно')
    Else
    Begin

      // If item has already taken
      ItemTaken := ( (ItemSearch.ThisItem.TakenData.Year < Item.Deadline.Year)
              or ((ItemSearch.ThisItem.TakenData.Year = Item.Deadline.Year)
                and (ItemSearch.ThisItem.TakenData.Month < Item.Deadline.Month))
              or ((ItemSearch.ThisItem.TakenData.Year = Item.Deadline.Year)
                and (ItemSearch.ThisItem.TakenData.Month = Item.Deadline.Month)
                and (ItemSearch.ThisItem.TakenData.Day < Item.Deadline.Day)) );

      // If current data > deadline
      if ItemTaken and ItemSearch.ThisItem.ReadyOrNot then
        PrintItem(ItemSearch.ThisItem, MItemsDone)
      Else
        // If item has already taken
        If ItemTaken then
          PrintItem(ItemSearch.ThisItem, MItemsNotDone);

      ItemSearch := ItemSearch^.ItemNext;
    End;
  End;
End;

// To save data
Procedure TFMainWindow.BSaveAsFileClick(Sender: TObject);
Var
  Print: Boolean;
  ThisFile: File of TThisItem;
  IndexType, FullData: String;
  MyExcel: Variant;
  Ind, Error: Integer;
{
 Print - can be prined
 ThisFile - typed file
 IndexType - '.txt'/'.xlsx'
 FullData - user's data
 MyExcel - excel's file's variable
 Ind - index
 Error - code error
}
Begin
  // Initialisation
  Error := 0;

  // List in start position
  InStart;

  // If user want to save
  If SDItemData.Execute then
  Begin

    // If in txt format
    // else in xlsx format
    If SDItemData.FilterIndex = 1 then
    Begin
      IndexType := '.txt';
      SDItemData.DefaultExt := 'txt';
      AssignFile(ThisFile, SDItemData.FileName);
      Rewrite(ThisFile);
    End
    Else
    Begin
      IndexType := '.xlsx';
      SDItemData.DefaultExt := 'xlsx';
      try
        MyExcel := CreateOleObject('Excel.Application');
      except
        ShowMessage('Необходимо установить Excel');
        Error := 1;
      end;

      // If excel was downloaded
      If Error = 0 then
      Begin
        MyExcel.Workbooks.Add;

        MyExcel.Cells[1, 1].Value := 'Группа';
        MyExcel.Cells[1, 2].Value := 'Марка';
        MyExcel.Cells[1, 3].Value := 'Дата доставки';
        MyExcel.Cells[1, 4].Value := 'Дата исполнения заказа';
        MyExcel.Cells[1, 5].Value := 'Готовность';

        MyExcel.Columns[3].ColumnWidth := 15.83;
        MyExcel.Columns[4].ColumnWidth := 25.83;
        MyExcel.Columns[5].ColumnWidth := 14.17;

        MyExcel.Range['a1:e1'].Font.Size := 14;
        MyExcel.Range['a1:e1'].Font.Bold := True;
        MyExcel.Range['a1:e1'].Font.Color := clBlue;
        Ind := 2;
      End;
    End;

    // Can write in file
    Print := (Error = 0);

    // If user choosed txt format
    While (IndexType = '.txt') and Print do
    Begin
      Write(ThisFile, ItemList.ThisItem);

      If ItemList^.ItemNext <> nil then
        ItemList := ItemList^.ItemNext
      Else
      Begin
        Print := False;
        CloseFile(ThisFile);
      End;
    End;

    // If user choosed xlsx format
    While (IndexType = '.xlsx') and Print do
    Begin
      MyExcel.Cells[Ind, 1].Value := ItemList.ThisItem.Group;
      MyExcel.Cells[Ind, 2].Value := ItemList.ThisItem.Marka;

      FullData := IntToStr(ItemList.ThisItem.TakenData.Day) + '.';
      FullData := FullData + IntToStr(ItemList.ThisItem.TakenData.Month) + '.';
      FullData := FullData + IntToStr(ItemList.ThisItem.TakenData.Year);
      MyExcel.Cells[Ind, 3].Value := FullData;

      FullData := IntToStr(ItemList.ThisItem.Deadline.Day) + '.';
      FullData := FullData + IntToStr(ItemList.ThisItem.Deadline.Month) + '.';
      FullData := FullData + IntToStr(ItemList.ThisItem.Deadline.Year);
      MyExcel.Cells[Ind, 4].Value := FullData;

      MyExcel.Cells[Ind, 5].Value := 'Выполнен';
      If not ItemList.ThisItem.ReadyOrNot then
      Begin
        MyExcel.Cells[Ind, 5].Value := 'Не выполнен';
        MyExcel.Range['a' + IntToStr(Ind) + ':e' + IntToStr(Ind)].Font.Color := clRed;
      End;

      MyExcel.Range['a' + IntToStr(Ind) + ':e' + IntToStr(Ind)].Font.Size := 14;

      If ItemList^.ItemNext <> nil then
      Begin
        ItemList := ItemList^.ItemNext;
        Inc(Ind);
      End
      Else
      Begin
        Print := False;
        MyExcel.ActiveWorkbook.SaveAs(SDItemData.FileName);
        MyExcel.ActiveWorkbook.Close;
        MyExcel.Quit;
      End;
    End;
  End;

  // List in start position
  InStart;
End;

// Open window with other operations with data
procedure TFMainWindow.BSearchItemClick(Sender: TObject);
begin
  Self.Hide;
  OpenWinOthers;
  FSearchItem.Show;
end;

// Open window with sort data
Procedure TFMainWindow.BSortItemsClick(Sender: TObject);
Begin
  Self.Hide;
  FSortedList.Show;
End;

// Write 'ДД' if user didn't write anything
Procedure TFMainWindow.EDayEnter(Sender: TObject);
Begin
  ENameEnter(EDay, 'ДД');
End;

// Clear 'ДД' if user wrote something
Procedure TFMainWindow.EDayExit(Sender: TObject);
Begin
  ENameExit(EDay, 'ДД');
End;

// Write 'ММ' if user didn't write anything
Procedure TFMainWindow.EMonthEnter(Sender: TObject);
Begin
  ENameEnter(EMonth, 'ММ');
End;

// Clear 'ММ' if user wrote something
Procedure TFMainWindow.EMonthExit(Sender: TObject);
Begin
  ENameExit(EMonth, 'ММ');
End;

// Write 'ГГГГ' if user didn't write anything
Procedure TFMainWindow.EYearEnter(Sender: TObject);
Begin
  ENameEnter(EYear, 'ГГГГ');
End;

// Clear 'ГГГГ' if user wrote something
Procedure TFMainWindow.EYearExit(Sender: TObject);
Begin
  ENameExit(EYear, 'ГГГГ');
End;

End.
