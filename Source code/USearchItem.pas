Unit USearchItem;

Interface

// Used libraries
Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  {Added ->} USharedData, uUsefulProc;

// Form's type
Type
  TFSearchItem = class(TForm)
    BBack: TButton;
    LTitle: TLabel;
    EMarka: TEdit;
    ETakenData: TEdit;
    EDeadline: TEdit;
    EReadyOrNot: TEdit;
    EGroup: TEdit;
    BSearch: TButton;
    MFoundItems: TMemo;
    LFoundItems: TLabel;
    BChange: TButton;
    BDelete: TButton;
    BChangeThisItem: TButton;
    BBackOneStep: TButton;
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
    Procedure BSearchClick(Sender: TObject);
    Procedure BDeleteClick(Sender: TObject);
    Procedure BChangeClick(Sender: TObject);
    Procedure BChangeThisItemClick(Sender: TObject);
    Procedure BBackOneStepClick(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
  FSearchItem: TFSearchItem;

Implementation

{$R *.dfm}

Var
  FoundedNum: Integer;

// Click on back button
Procedure TFSearchItem.BBackClick(Sender: TObject);
Begin
  Self.Close;
  OpenMainMenu;
  If Assigned(Application.MainForm) then
    Application.MainForm.Show;
  LTitle.Caption := 'Операции над радиоаппаратурой';
  LFoundItems.Caption := 'Список найденых радиоаппаратур:';
  BChange.Visible := False;
  BSearch.Visible := False;
  BDelete.Visible := False;
  BChangeThisItem.Visible := False;
  BBackOneStep.Visible := False;
End;

// Click on back button (not main menu)
Procedure TFSearchItem.BBackOneStepClick(Sender: TObject);
Begin
  OpenWinOthers;
End;

// Find item
Procedure TFSearchItem.BSearchClick(Sender: TObject);
Var
  ItemSearch: PItem;
  Founded: boolean;
{
 ItemSearch - item's list
 Founded - check if item was founded
}
Begin
  // Initialisation
  FoundedNum := 0;
  ItemSearch := ItemList;
  MFoundItems.Clear;

  // For each item
  While ItemSearch <> nil do
  Begin
    // Check item
    Founded := FindingItem(EGroup, EMarka, ETakenData, EDeadline, EReadyOrNot, ItemSearch);

    // If item was founded
    If Founded then
    Begin
      inc(FoundedNum);
      PrintItem(ItemSearch.ThisItem, MFoundItems);
    End;

    ItemSearch := ItemSearch^.ItemNext;
  End;
End;

// Delete item
Procedure TFSearchItem.BDeleteClick(Sender: TObject);
Var
  ItemDelete: PItem;
  Founded: Boolean;
  NextCycle: Boolean;
{
 ItemDelete - ite,'s list
 Founded - if item was founded to delete
 NextCycle - flag for the next cycle
}
Begin
  // Initialisation
  ItemDelete := ItemList;
  NextCycle := True;

  MFoundItems.Clear;

  // can see the next item
  While NextCycle do
  Begin
    // Check item
    Founded := FindingItem(EGroup, EMarka, ETakenData, EDeadline, EReadyOrNot, ItemDelete);

    // If item was founded
    If Founded then
    Begin
      // If not the first item in the list
      If ItemDelete^.ItemPrev <> nil then
        ItemDelete.ItemPrev^.ItemNext := ItemDelete^.ItemNext;

      // If not the last item in the list
      If ItemDelete^.ItemNext <> nil then
      Begin
        ItemDelete := ItemDelete^.ItemNext;
        Dispose(ItemDelete^.ItemPrev);

        If ItemDelete^.ItemPrev <> nil then
          ItemDelete^.ItemPrev := ItemDelete.ItemPrev^.ItemPrev;
      End
      Else
      Begin
        ItemDelete := ItemDelete^.ItemPrev;

        If ItemDelete <> nil then
          Dispose(ItemDelete^.ItemNext)
        Else
        Begin
          ItemList := ItemDelete;
          NextCycle := False;
        End;
      End;
    End
    Else
      If (ItemDelete <> nil) and (ItemDelete^.ItemNext <> nil) then
        ItemDelete := ItemDelete^.ItemNext
      Else
      Begin
        ItemList := ItemDelete;
        InStart;
        NextCycle := False;
      End;
  End;

  BChange.Enabled := True;
  BSearch.Enabled := True;
  BDelete.Enabled := True;

  // If no items in the list
  If ItemList = nil then
  Begin
    BChange.Enabled := False;
    BSearch.Enabled := False;
    BDelete.Enabled := False;
  End;

  ShowMessage('Удаление завершено успешно!');
End;

// Swap item
Procedure TFSearchItem.BChangeClick(Sender: TObject);
Var
  ItemTemp: PItem;
  Founded: Boolean;
  Counter: integer;
{
 ItemTemp - time variable with item's data
 Founded - is item founded
 Counter - counter
}
Begin
  // Initialisation
  ItemTemp := ItemList;
  Counter := 0;

  MFoundItems.Clear;

  // If the list with items
  While ItemTemp <> nil do
  Begin
    // Chack item
    Founded := FindingItem(EGroup, EMarka, ETakenData, EDeadline, EReadyOrNot, ItemTemp);

    // Increase amount of items
    Inc(Counter, Ord(Founded));

    // If item was founded
    If Founded then
    Begin
      ItemChange := ItemTemp.ThisItem;
      PrintItem(ItemTemp.ThisItem, MFoundItems);
    End;

    ItemTemp := ItemTemp^.ItemNext;
  End;

  // If found only one item
  If Counter = 1 then
  Begin
    BChange.Visible := False;
    BSearch.Visible := False;
    BDelete.Visible := False;
    BChangeThisItem.Top := BDelete.Top;
    BChangeThisItem.Left := BDelete.Left;
    BChangeThisItem.Visible := True;
    BBackOneStep.Top := BSearch.Top;
    BBackOneStep.Left := BSearch.Left;
    BBackOneStep.Visible := True;

    EGroup.Text := '';
    ENameExit(EGroup, 'Наименование группы изделий (телевизор и т. п.)');
    EMarka.Text := '';
    ENameExit(EMarka, 'Марка изделия (LG, Samsung и т. д.)');
    ETakenData.Text := '';
    ENameExit(ETakenData, 'Дата приёмки в ремонт (ДД.ММ.ГГГГ)');
    EDeadline.Text := '';
    ENameExit(EDeadline, 'Дата исполнения заказа (ДД.ММ.ГГГГ)');
    EReadyOrNot.Text := '';
    ENameExit(EReadyOrNot, 'Состояние готовности заказа ((не) выполнен)');

    LTitle.Caption := 'Введите новые характеристики';
    LFoundItems.Caption := 'Вместо:';
  End
  Else
    // If found not only one item
    ShowMessage('Необходимо, чтобы только одна радиоаппаратура подходила под характеристики');
End;

// Swap this item
Procedure TFSearchItem.BChangeThisItemClick(Sender: TObject);
Var
  ItemTemp: TAnswer;
// ItemTemp - time variable with item's data
Begin
  // Add in time variable
  ItemTemp := AddItem(EGroup.Text, EMarka.Text, ETakenData.Text, EDeadline.Text, EReadyOrNot.Text, MFoundItems);

  // If data is clear
  If ItemTemp.CodeError = 0 then
  Begin
    While not IsTheSame(ItemList.ThisItem, ItemChange) do
      ItemList := ItemList^.ItemNext;

    ItemList.ThisItem := ItemTemp.ThisItem;

    MFoundItems.Clear;

    // list in start position
    InStart;
    LFoundItems.Caption := 'Весь список:';

    // Print list
    PrintList(ItemList, MFoundItems);
  End;
End;

// Write 'Дата исполнения заказа (ДД.ММ.ГГГГ)'
// if user didn't write anything
Procedure TFSearchItem.EDeadlineEnter(Sender: TObject);
Begin
  ENameEnter(EDeadline, 'Дата исполнения заказа (ДД.ММ.ГГГГ)');
End;

// Clear 'Дата исполнения заказа (ДД.ММ.ГГГГ)'
// if user wrote something
Procedure TFSearchItem.EDeadlineExit(Sender: TObject);
Begin
  ENameExit(EDeadline, 'Дата исполнения заказа (ДД.ММ.ГГГГ)');
End;

// Write 'Наименование группы изделий (телевизор и т. п.)'
// if user didn't write anything
Procedure TFSearchItem.EGroupEnter(Sender: TObject);
Begin
  ENameEnter(EGroup, 'Наименование группы изделий (телевизор и т. п.)');
End;

// Clear 'Наименование группы изделий (телевизор и т. п.)'
// if user wrote something
Procedure TFSearchItem.EGroupExit(Sender: TObject);
Begin
  ENameExit(EGroup, 'Наименование группы изделий (телевизор и т. п.)');
End;

// Write 'Марка изделия (LG, Samsung и т. д.)'
// if user didn't write anything
Procedure TFSearchItem.EMarkaEnter(Sender: TObject);
Begin
  ENameEnter(EMarka, 'Марка изделия (LG, Samsung и т. д.)');
End;

// Clear 'Марка изделия (LG, Samsung и т. д.)'
// if user wrote something
Procedure TFSearchItem.EMarkaExit(Sender: TObject);
Begin
  ENameExit(EMarka, 'Марка изделия (LG, Samsung и т. д.)');
End;

// Write 'Состояние готовности заказа ((не) выполнен)'
// if user didn't write anything
Procedure TFSearchItem.EReadyOrNotEnter(Sender: TObject);
Begin
  ENameEnter(EReadyOrNot, 'Состояние готовности заказа ((не) выполнен)');
End;

// Clear 'Состояние готовности заказа ((не) выполнен)'
// if user wrote something
Procedure TFSearchItem.EReadyOrNotExit(Sender: TObject);
Begin
  ENameExit(EReadyOrNot, 'Состояние готовности заказа ((не) выполнен)');
End;

// Write 'Дата приёмки в ремонт (ДД.ММ.ГГГГ)'
// if user didn't write anything
Procedure TFSearchItem.ETakenDataEnter(Sender: TObject);
Begin
  ENameEnter(ETakenData, 'Дата приёмки в ремонт (ДД.ММ.ГГГГ)');
End;

// Clear 'Дата приёмки в ремонт (ДД.ММ.ГГГГ)'
// if user wrote something
Procedure TFSearchItem.ETakenDataExit(Sender: TObject);
Begin
  ENameExit(ETakenData, 'Дата приёмки в ремонт (ДД.ММ.ГГГГ)');
End;

End.
