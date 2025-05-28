Unit UAddProduct;

Interface

// Used libraries
Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ComObj,
  {Added ->} USharedData, uUsefulProc;

// Form's type
Type
  TFAddProduct = Class(TForm)
    BBack: TButton;
    LTitle: TLabel;
    EMarka: TEdit;
    ETakenData: TEdit;
    EDeadline: TEdit;
    EReadyOrNot: TEdit;
    BAddItem: TButton;
    EGroup: TEdit;
    MAdded: TMemo;
    LAdded: TLabel;
    BUploadFile: TButton;
    ODForFile: TOpenDialog;
    Procedure BAddItemClick(Sender: TObject);
    Procedure BBackClick(Sender: TObject);
    Procedure EGroupEnter(Sender: TObject);
    Procedure EGroupExit(Sender: TObject);
    Procedure EMarkaEnter(Sender: TObject);
    Procedure EMarkaExit(Sender: TObject);
    Procedure ETakenDataEnter(Sender: TObject);
    Procedure ETakenDataExit(Sender: TObject);
    Procedure EDeadlineEnter(Sender: TObject);
    Procedure EDeadlineExit(Sender: TObject);
    Procedure EReadyOrNotEnter(Sender: TObject);
    Procedure EReadyOrNotExit(Sender: TObject);
    Procedure BUploadFileClick(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
  FAddProduct: TFAddProduct;


Implementation

{$R *.dfm}

// Add item button
Procedure TFAddProduct.BAddItemClick(Sender: TObject);
Var
  ItemTemp: TAnswer;
// ItemTemp - time variable with item's data
Begin
  // Add in time variable
  ItemTemp := AddItem(EGroup.Text, EMarka.Text, ETakenData.Text,
                      EDeadline.Text, EReadyOrNot.Text, MAdded);

  // If data is clear
  If ItemTemp.CodeError = 0 then
  Begin
    If ItemList = nil then
    Begin
      New(ItemList);
      ItemList^.ItemPrev := nil;
      ItemList^.ItemNext := nil;
      ItemList.ThisItem := ItemTemp.ThisItem;
    End
    Else
    Begin
      While ItemList^.ItemNext <> nil do
        ItemList := ItemList^.ItemNext;

      New(ItemList^.ItemNext);
      ItemList.ItemNext^.ItemPrev := ItemList;
      ItemList := ItemList^.ItemNext;
      ItemList.ThisItem := ItemTemp.ThisItem;
      ItemList^.ItemNext := nil;
    End;

    // List in start position
    InStart;
  End;
End;

// Click on back button
Procedure TFAddProduct.BBackClick(Sender: TObject);
Begin
  Self.Close;
  OpenMainMenu;
  If Assigned(Application.MainForm) then
    Application.MainForm.Show;
End;

// Check can item be added
Function CanBeAdded(var ThisExcel: Variant; i: Integer): Boolean;
Begin
  Result := not VarIsEmpty(ThisExcel.Cells[i, 1].Value);
  Result := Result or not VarIsEmpty(ThisExcel.Cells[i, 2].Value);
  Result := Result or not VarIsEmpty(ThisExcel.Cells[i, 3].Value);
  Result := Result or not VarIsEmpty(ThisExcel.Cells[i, 4].Value);
  Result := Result or not VarIsEmpty(ThisExcel.Cells[i, 5].Value);
End;

// Click on upload file
Procedure TFAddProduct.BUploadFileClick(Sender: TObject);
Var
  ThisFile: File of TThisItem;
  ItemFile: TThisItem;
  IndexType, S1, S2, S3, S4, S5: String;
  MyExcel: Variant;
  Ind: Integer;
  ItemTemp: TAnswer;
{
 ThisFile - typed file's variable
 ItemFile - item in file
 ItemIndex - item's index
 S1, S2, S3, S4, S5 - cells in excel
 MyExcel - excel's file variable
 Ind - index
 ItemTemp - function's return value
}
Begin
  // If user want to open the file
  If ODForFile.Execute then
  Begin

    // If in txt format
    // else in xlsx format
    If ODForFile.FilterIndex = 1 then
    Begin
      IndexType := '.txt';
      ODForFile.DefaultExt := 'txt';
      AssignFile(ThisFile, ODForFile.FileName);

      If FileExists(ODForFile.FileName) then
        Reset(ThisFile)
      Else
      Begin
        ShowMessage('Файл не найден');
        IndexType := 'txt Error';
      End;
    End
    Else
    Begin
      IndexType := '.xlsx';
      ODForFile.DefaultExt := 'xlsx';
      Ind := 2;
      MyExcel := CreateOleObject('Excel.Application');
      ItemTemp.CodeError := 0;

      If FileExists(ODForFile.FileName) then
        MyExcel.Workbooks.Open(ODForFile.FileName)
      Else
      Begin
        MyExcel := Unassigned;
        ShowMessage('Файл не найден');
        IndexType := 'xlsx Error';
      end;
    End;

    MAdded.Clear;

    // Upload from txt file
    While (IndexType = '.txt') and not EOF(ThisFile) do
    Begin
      If ItemList = nil then
      Begin
        New(ItemList);
        ItemList^.ItemPrev := nil;
        ItemList^.ItemNext := nil;
      End;

      Read(ThisFile, ItemFile);
      ItemList.ThisItem := ItemFile;
      PrintItem(ItemFile, MAdded);

      If not EOF(ThisFile) then
      Begin
        New(ItemList^.ItemNext);
        ItemList^.ItemNext^.ItemPrev := ItemList;
        ItemList := ItemList^.ItemNext;
        ItemList^.ItemNext := nil;
      End;
    End;

    // Close text file
    If IndexType = '.txt' then
      CloseFile(ThisFile);

    // Upload from xlsx file
    While (IndexType = '.xlsx') and CanBeAdded(MyExcel, Ind)
      and (ItemTemp.CodeError = 0) do
    Begin
      S1 := MyExcel.Cells[Ind, 1].Value;
      S2 := MyExcel.Cells[Ind, 2].Value;
      S3 := MyExcel.Cells[Ind, 3].Value;
      S4 := MyExcel.Cells[Ind, 4].Value;
      S5 := MyExcel.Cells[Ind, 5].Value;

      // Add in time variable
      ItemTemp := AddItem(S1, S2, S3, S4, S5, MAdded);

      // If data is clear
      If (ItemTemp.CodeError = 0) and CanBeAdded(MyExcel, Ind) then
      Begin
        If ItemList = nil then
        Begin
          New(ItemList);
          ItemList^.ItemPrev := nil;
          ItemList^.ItemNext := nil;
        End;

        ItemList.ThisItem := ItemTemp.ThisItem;
        Inc(Ind);

        New(ItemList^.ItemNext);
        ItemList^.ItemNext^.ItemPrev := ItemList;
        ItemList := ItemList^.ItemNext;
        ItemList^.ItemNext := nil;
      End
      Else
        If ItemList <> nil then
        Begin
          ItemList := ItemList^.ItemPrev;
          Dispose(ItemList^.ItemNext);
          ItemList^.ItemNext := nil;
        End;
    End;
  End;

  // List in start position
  InStart;
end;

// Write 'Дата исполнения заказа (ДД.ММ.ГГГГ)'
// if user didn't write anything
Procedure TFAddProduct.EDeadlineEnter(Sender: TObject);
Begin
  ENameEnter(EDeadline, 'Дата исполнения заказа (ДД.ММ.ГГГГ)');
End;

// Clear 'Дата исполнения заказа (ДД.ММ.ГГГГ)'
// if user wrote something
Procedure TFAddProduct.EDeadlineExit(Sender: TObject);
Begin
  ENameExit(EDeadline, 'Дата исполнения заказа (ДД.ММ.ГГГГ)');
End;

// Write 'Наименование группы изделий (телевизор и т. п.)'
// if user didn't write anything
Procedure TFAddProduct.EGroupEnter(Sender: TObject);
Begin
  ENameEnter(EGroup, 'Наименование группы изделий (телевизор и т. п.)');
End;

// Clear 'Наименование группы изделий (телевизор и т. п.)'
// if user wrote something
Procedure TFAddProduct.EGroupExit(Sender: TObject);
Begin
  ENameExit(EGroup, 'Наименование группы изделий (телевизор и т. п.)');
End;

// Write 'Марка изделия (LG, Samsung и т. д.)'
// if user didn't write anything
Procedure TFAddProduct.EMarkaEnter(Sender: TObject);
Begin
  ENameEnter(EMarka, 'Марка изделия (LG, Samsung и т. д.)');
End;

// Clear 'Марка изделия (LG, Samsung и т. д.)'
// if user wrote something
Procedure TFAddProduct.EMarkaExit(Sender: TObject);
Begin
  ENameExit(EMarka, 'Марка изделия (LG, Samsung и т. д.)');
End;

// Write 'Состояние готовности заказа ((не) выполнен)'
// if user didn't write anything
Procedure TFAddProduct.EReadyOrNotEnter(Sender: TObject);
Begin
  ENameEnter(EReadyOrNot, 'Состояние готовности заказа ((не) выполнен)');
End;

// Clear 'Состояние готовности заказа ((не) выполнен)'
// if user wrote something
Procedure TFAddProduct.EReadyOrNotExit(Sender: TObject);
Begin
  ENameExit(EReadyOrNot, 'Состояние готовности заказа ((не) выполнен)');
End;

// Write 'Дата приёмки в ремонт (ДД.ММ.ГГГГ)'
// if user didn't write anything
Procedure TFAddProduct.ETakenDataEnter(Sender: TObject);
Begin
  ENameEnter(ETakenData, 'Дата приёмки в ремонт (ДД.ММ.ГГГГ)');
End;

// Clear 'Дата приёмки в ремонт (ДД.ММ.ГГГГ)'
// if user wrote something
Procedure TFAddProduct.ETakenDataExit(Sender: TObject);
Begin
  ENameExit(ETakenData, 'Дата приёмки в ремонт (ДД.ММ.ГГГГ)');
End;

End.
