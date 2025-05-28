Unit uUsefulProc;

Interface

// Used libraries
Uses
  Vcl.StdCtrls, SysUtils, USharedData, Graphics, Dialogs;

Procedure PrintItem(ItemPrint: TThisItem; ThisMemo: TMemo);
Procedure InStart;
Procedure PrintList(List: PItem; ThisMemo: TMemo);
Procedure QuickSort(var IArray: Array of PItem; Left, Right: Integer; KeyWord: String; WhichWay: Boolean);
Function AddTakenData(TakenData: String; var ThisItem: TThisItem): Integer;
Function AddDeadline(Deadline: String; var ThisItem: TThisItem): Integer;
Procedure ENameEnter(EName: TEdit; Text: String);
Procedure ENameExit(EName: TEdit; Text: String);
Function FindingItem(EGroup, EMarka, ETakenData, EDeadline, EReadyOrNot: TEdit;
                      ItemSearch: PItem): boolean;
Function IsTheSame(F, S: TThisItem): Boolean;
Function AddItem(Group, Marka, TakenData, Deadline, ReadyOrNot: String;
                  Memo: TMemo): TAnswer;
Procedure OpenWinOthers;
Procedure OpenMainMenu;

implementation

Uses
  USearchItem, UMainWindow;

// Clear the field
Procedure ENameEnter(EName: TEdit; Text: String);
{
 EName - edit's name
 Text - text to clear
}
Begin
  If EName.Text = Text then
  Begin
    EName.Text := '';
    EName.Font.Color := clBlack;
  End;
End;

// Fill the field
Procedure ENameExit(EName: TEdit; Text: String);
{
 EName - edit's name
 Text - text to fill
}
Begin
  If EName.Text = '' then
  Begin
    EName.Text := Text;
    EName.Font.Color := clGray;
  End;
End;

// Print item in memo
Procedure PrintItem(ItemPrint: TThisItem; ThisMemo: TMemo);
{
 ItemPrint - current item
 ThisMemo - current memo
}
Begin
  ThisMemo.Lines.Add(String(ItemPrint.Group));
  ThisMemo.Lines.Add('- ' + String(ItemPrint.Marka));
  ThisMemo.Lines.Add('- ' + IntToStr(ItemPrint.TakenData.Day)
    + '.' + IntToStr(ItemPrint.TakenData.Month)
    + '.' + IntToStr(ItemPrint.TakenData.Year));
  ThisMemo.Lines.Add('- ' + IntToStr(ItemPrint.Deadline.Day)
    + '.' + IntToStr(ItemPrint.Deadline.Month)
    + '.' + IntToStr(ItemPrint.Deadline.Year));
  if ItemPrint.ReadyOrNot then ThisMemo.Lines.Add('Выполнен')
  else ThisMemo.Lines.Add('Не выполнен');
  ThisMemo.Lines.Add('');
End;

// In start position
Procedure InStart;
Begin
  while (ItemList <> nil) and (ItemList^.ItemPrev <> nil) do
    ItemList := ItemList^.ItemPrev;
End;

// Print the list
Procedure PrintList(List: PItem; ThisMemo: TMemo);
{
 List - the list eith all items
 ThisMemo - current memo
}
Var
  CanPrint: Boolean;
  Item: TThisItem;
{
 CanPrint - can be printed
 Item - current item
}
Begin
  CanPrint := True;

  // If item can be printed
  While (List <> nil) and (CanPrint) do
  Begin
    Item := List.ThisItem;
    PrintItem(Item, ThisMemo);

    If List^.ItemNext <> nil then
      List := List^.ItemNext
    Else
      CanPrint := False;
  End;
End;

// Partition for QuickSort
Function Partition(var ThisArray: Array of PItem; ThisLeft, ThisRight: Integer; ThisKW: String; ThisWay: Boolean): Integer;
{
 ThisArray - array with all items
 ThisLeft - current left edge
 ThisRight - current right edge
 ThisKW - key word to sort
 ThisWay - choosed way to sort
}
Var
  TempD, ThisD: TData;
  SwapIt: PItem;
  Index, i: Integer;
{
 SwapIt, TempD, ThisD - time variable with item's data
 Index, i - index
}
Begin
  // Initialisation

  // Depends on choosed way to sort
  If ThisWay then
    TempD := ThisArray[ThisLeft].ThisItem.Deadline
  Else
    ThisD := ThisArray[ThisLeft].ThisItem.Deadline;

  Index := ThisLeft;

  // For each item in current array
  For i := ThisLeft to ThisRight do
  Begin
    // Depends on choosed way to sort
    If ThisWay then
      ThisD := ThisArray[i].ThisItem.Deadline
    Else
      TempD := ThisArray[i].ThisItem.Deadline;

    // Depends on key word
    If ((ThisKW = 'Year') and (TempD.Year < ThisD.Year))
      or ((ThisKW = 'Month') and (TempD.Year = ThisD.Year)
        and (TempD.Month < ThisD.Month))
      or ((ThisKW = 'Day') and (TempD.Year = ThisD.Year)
        and (TempD.Month = ThisD.Month) and (TempD.Day < ThisD.Day)) then
    Begin
      Inc(Index);

      // Swap items
      SwapIt := ThisArray[Index];
      ThisArray[Index] := ThisArray[i];
      ThisArray[i] := SwapIt;
    End;
  End;

  // Swap item[currnt middle] with [current left edge]
  SwapIt := ThisArray[Index];
  ThisArray[Index] := ThisArray[ThisLeft];
  ThisArray[ThisLeft] := SwapIt;

  // Middle index
  Result := Index;
End;

// QuickSort
Procedure QuickSort(var IArray: Array of PItem; Left, Right: Integer; KeyWord: String; WhichWay: Boolean);
{
 ThisArray - array with all items
 ThisLeft - current left edge
 ThisRight - current right edge
 ThisKW - key word to sort
 ThisWay - choosed way to sort
}
Var
  Mid: Integer;
{
 Mid - middle index
}
Begin

  If Left < Right then
  Begin
    // Find current middle index
    Mid := Partition(IArray, Left, Right, KeyWord, WhichWay);

    // Sort new subarray
    QuickSort(IArray, Left, Mid - 1, KeyWord, WhichWay);
    QuickSort(IArray, Mid + 1, Right, KeyWord, WhichWay);
  End;

End;

// Add taken data
Function AddTakenData(TakenData: String; var ThisItem: TThisItem): Integer;
{
 TakenData - user's taken data
 ThisItem - current item
}
Var
  DataPartStr: String;
  Counter: 1..4;
  i: word;
  AllErrors, Error: Integer;
{
 DataPartStr - part of user's data
 Counter - counter
 i - index
 AllErrors, Error - code error
}
Begin
  // Initialisation
  Error := 0;
  AllErrors := 0;
  i := 1;

  // For each part of data (day, month, year)
  For Counter := 1 to 3 do
  Begin
    // Initialisation
    DataPartStr := '';

    // Read user's part of data
    While (i <= length(TakenData)) and (TakenData[i] <> '.') do
    Begin
      DataPartStr := DataPartStr + TakenData[i];
      Inc(i);
    End;

    // Day(1) or month(2) or year(3) ?
    Case Counter of
      1:
      Begin
        // Checking
        Val(DataPartStr, ThisItem.TakenData.Day, Error);
        If (ThisItem.TakenData.Day < 1) or (ThisItem.TakenData.Day > 31) then Error := 11;
        AllErrors := AllErrors + Error;
      End;
      2:
      Begin
        // Checking
        Val(DataPartStr, ThisItem.TakenData.Month, Error);
        If (ThisItem.TakenData.Month < 1) or (ThisItem.TakenData.Month > 12) then Error := 22;
        AllErrors := AllErrors + Error;
      End;
      3:
      Begin
        // Checking
        Val(DataPartStr, ThisItem.TakenData.Year, Error);
        If ThisItem.TakenData.Year < 0 then Error := 3333;
        AllErrors := AllErrors + Error;
      End;
    End;

    // Next char
    Inc(i);
  End;

  // Return code error
  Result := AllErrors;
End;

// Are these items same
Function IsTheSame(F, S: TThisItem): Boolean;
{
 F - first item
 S - second item
}
Begin
  Result := (F.Group = S.Group)
        and (F.Marka = S.Marka)
        and ( (F.TakenData.Day = S.TakenData.Day)
          and (F.TakenData.Month = S.TakenData.Month)
          and (F.TakenData.Year = S.TakenData.Year) )
        and ( (F.Deadline.Day = S.Deadline.Day)
          and (F.Deadline.Month = S.Deadline.Month)
          and (F.Deadline.Year = S.Deadline.Year) )
        and (F.ReadyOrNot = S.ReadyOrNot)
End;

// Finding item
Function FindingItem(EGroup, EMarka, ETakenData, EDeadline, EReadyOrNot: TEdit;
                      ItemSearch: PItem): boolean;
{
 EGroup - group's edit name
 EMarka - mark's edit name
 ETakenData - taken data's edit name
 EDeadline - deadline's edit name
 EReadyOrNot - ready's edit name
 ItemSearch - the list of items
}
Begin
  // Group
  If EGroup.Text <> 'Наименование группы изделий (телевизор и т. п.)' then
    Item.Group := ShortString(EGroup.Text)
  Else
    Item.Group := ItemSearch.ThisItem.Group;


  // Mark
  If EMarka.Text <> 'Марка изделия (LG, Samsung и т. д.)' then
    Item.Marka := ShortString(EMarka.Text)
  Else
    Item.Marka := ItemSearch.ThisItem.Marka;

  // Taken data
  if ETakenData.Text <> 'Дата приёмки в ремонт (ДД.ММ.ГГГГ)' then
    AddTakenData(ETakenData.Text, Item)
  else
  begin
    Item.TakenData.Day := ItemSearch.ThisItem.TakenData.Day;
    Item.TakenData.Month := ItemSearch.ThisItem.TakenData.Month;
    Item.TakenData.Year := ItemSearch.ThisItem.TakenData.Year;
  end;

  // deadline
  if EDeadline.Text <> 'Дата исполнения заказа (ДД.ММ.ГГГГ)' then
    AddDeadline(EDeadline.Text, Item)
  else
  begin
    Item.Deadline.Day := ItemSearch.ThisItem.Deadline.Day;
    Item.Deadline.Month := ItemSearch.ThisItem.Deadline.Month;
    Item.Deadline.Year := ItemSearch.ThisItem.Deadline.Year;
  end;

  // Ready or not ready
  if EReadyOrNot.Text <> 'Состояние готовности заказа ((не) выполнен)' then
    Item.ReadyOrNot := ((AnsiLowerCase(Trim(EReadyOrNot.Text)) = 'выполнен')
      or (AnsiLowerCase(Trim(EReadyOrNot.Text)) = 'выполнено')
      or (AnsiLowerCase(Trim(EReadyOrNot.Text)) = 'завершён')
      or (AnsiLowerCase(Trim(EReadyOrNot.Text)) = 'завершено')
      or (AnsiLowerCase(Trim(EReadyOrNot.Text)) = 'сделано')
      or (AnsiLowerCase(Trim(EReadyOrNot.Text)) = 'сделан')
      or (AnsiLowerCase(Trim(EReadyOrNot.Text)) = 'закончено')
      or (AnsiLowerCase(Trim(EReadyOrNot.Text)) = 'готово')
      or (AnsiLowerCase(Trim(EReadyOrNot.Text)) = 'готов')
      or (AnsiLowerCase(Trim(EReadyOrNot.Text)) = 'ок'))
  else
    Item.ReadyOrNot := ItemSearch.ThisItem.ReadyOrNot;

  // If it's in
  Result := IsTheSame(ItemSearch.ThisItem, Item);
end;

// Add deadline
Function AddDeadline(Deadline: String; var ThisItem: TThisItem): Integer;
{
 Deadline - user's deadline
 ThisItem - current item
}
Var
  DataPartStr: String;
  Counter: 1..4;
  i: word;
  Error, AllErrors: Integer;
{
 DataPartStr - part of user's data
 Counter - counter
 i - index
 AllErrors, Error - code error
}
Begin
  // Initialisation
  Error := 0;
  AllErrors := 0;
  i := 1;

  // For each part of data (day, month, year)
  For Counter := 1 to 3 do
  Begin
    // Initialisation
    DataPartStr := '';

    // Read user's part of data
    While (i <= length(Deadline)) and (Deadline[i] <> '.') do
    Begin
      DataPartStr := DataPartStr + Deadline[i];
      Inc(i);
    End;

    // Day(1) or month(2) or year(3) ?
    Case Counter of
      1:
      Begin
        // Checking
        Val(DataPartStr, ThisItem.Deadline.Day, Error);
        If (ThisItem.Deadline.Day < 1) or (ThisItem.Deadline.Day > 31) then Error := 11;
        AllErrors := AllErrors + Error;
      End;
      2:
      Begin
        // Checking
        Val(DataPartStr, ThisItem.Deadline.Month, Error);
        If (ThisItem.Deadline.Month < 1) or (ThisItem.Deadline.Month > 12) then Error := 22;
        AllErrors := AllErrors + Error;
      End;
      3:
      Begin
        // Checking
        Val(DataPartStr, ThisItem.Deadline.Year, Error);
        If ThisItem.Deadline.Year < 0 then Error := 3333;
        AllErrors := AllErrors + Error;
      End;
    End;

    // Next char
    Inc(i);
  End;

  // Return code error
  Result := AllErrors;
End;

// Add item
Function AddItem(Group, Marka, TakenData, Deadline, ReadyOrNot: String;
                  Memo: TMemo): TAnswer;
{
 Group - user's item group
 Marka - user's item mark
 TakenData - user's item taken data
 Deadline - user's item deadline
 ReadyOrNot - user's item ready
 Memo - current memo
}
begin
  // Initialisation
  Result.CodeError := 0;
  Result.ThisItem.Group := ShortString(Group);
  Result.ThisItem.Marka := ShortString(Marka);

  If (Group = 'Наименование группы изделий (телевизор и т. п.)')
    or (Marka = 'Марка изделия (LG, Samsung и т. д.)') then
  Begin
    Result.CodeError := 404;
    ShowMessage('Введите "Наименование группы" и "Марку изделий"');
  End
  Else
  Begin

    // ETakenData.Text[] -> integer
    Result.CodeError := AddTakenData(TakenData, Result.ThisItem);

    If Result.CodeError > 0 then
      ShowMessage('В радиоаппаратуре ' + String(Result.ThisItem.Group) +
          ' - > ' + String(Result.ThisItem.Marka) + ' написана неправильно дата приёмки в ремонт. Должно быть, как ' +
          IntToStr(1 + Random(14)) + '.' + IntToStr(1 + Random(6)) + '.' + IntToStr(2000 + Random(50)))
    Else
    Begin

      // EDeadline.Text[] -> integer
      Result.CodeError := AddDeadline(Deadline, Result.ThisItem);

      If Result.CodeError > 0 then
        ShowMessage('В радиоаппаратуре ' + String(Result.ThisItem.Group) +
            ' - > ' + String(Result.ThisItem.Marka) + ' написана неправильно дата исполнения заказа. Должно быть, как ' +
            IntToStr(14 + Random(14)) + '.' + IntToStr(6 + Random(6)) + '.' + IntToStr(2050 + Random(50)))
      Else
      Begin

        // User's data is clear
        If (Result.ThisItem.TakenData.Year > Result.ThisItem.Deadline.Year)
          or ((Result.ThisItem.TakenData.Year = Result.ThisItem.Deadline.Year)
            and (Result.ThisItem.TakenData.Month > Result.ThisItem.Deadline.Month))
          or ((Result.ThisItem.TakenData.Year = Result.ThisItem.Deadline.Year)
            and (Result.ThisItem.TakenData.Month = Result.ThisItem.Deadline.Month)
            and (Result.ThisItem.TakenData.Day > Result.ThisItem.Deadline.Day)) then
          Result.CodeError := 404;

        If Result.CodeError > 0 then
          ShowMessage('Дата исполнения заказа не может быть раньше, чем дата приёмки в ремонт. Введите другие даты. Например, '
            + IntToStr(1 + Random(14)) + '.' + IntToStr(1 + Random(6)) + '.' + IntToStr(2000 + Random(20))
            + ' и '
            + IntToStr(14 + Random(14)) + '.' + IntToStr(6 + Random(6)) + '.' + IntToStr(2020 + Random(20)))
        Else
        Begin

          If ReadyOrNot = 'Состояние готовности заказа ((не) выполнен)' then
          Begin
            Result.CodeError := 404;
            ShowMessage('Введите "Состояние готовности заказа"');
          End
          Else
          Begin

            // Is the item ready
            ReadyOrNot := LowerCase(Trim(ReadyOrNot));

            // EReadyOrNot.Text -> boolean
            Result.ThisItem.ReadyOrNot := ((AnsiLowerCase(Trim(ReadyOrNot)) = 'выполнен')
              or (AnsiLowerCase(Trim(ReadyOrNot)) = 'выполнено')
              or (AnsiLowerCase(Trim(ReadyOrNot)) = 'завершён')
              or (AnsiLowerCase(Trim(ReadyOrNot)) = 'завершено')
              or (AnsiLowerCase(Trim(ReadyOrNot)) = 'сделано')
              or (AnsiLowerCase(Trim(ReadyOrNot)) = 'сделан')
              or (AnsiLowerCase(Trim(ReadyOrNot)) = 'закончено')
              or (AnsiLowerCase(Trim(ReadyOrNot)) = 'готово')
              or (AnsiLowerCase(Trim(ReadyOrNot)) = 'готов')
              or (AnsiLowerCase(Trim(ReadyOrNot)) = 'ок'));

            Memo.Clear;

            // Print current item
            PrintItem(Result.ThisItem, Memo);
          End;
        End;
      End;
    End;
  End;
end;

// Open window Others clear
Procedure OpenWinOthers;
Begin
  FSearchItem.BChange.Visible := True;
  FSearchItem.BSearch.Visible := True;
  FSearchItem.BDelete.Visible := True;
  FSearchItem.BChangeThisItem.Visible := False;
  FSearchItem.BBackOneStep.Visible := False;

  FSearchItem.BChange.Enabled := True;
  FSearchItem.BDelete.Enabled := True;
  FSearchItem.BSearch.Enabled := True;

  FSearchItem.MFoundItems.Clear;
  FSearchItem.EGroup.Text := '';
  ENameExit(FSearchItem.EGroup, 'Наименование группы изделий (телевизор и т. п.)');
  FSearchItem.EMarka.Text := '';
  ENameExit(FSearchItem.EMarka, 'Марка изделия (LG, Samsung и т. д.)');
  FSearchItem.ETakenData.Text := '';
  ENameExit(FSearchItem.ETakenData, 'Дата приёмки в ремонт (ДД.ММ.ГГГГ)');
  FSearchItem.EDeadline.Text := '';
  ENameExit(FSearchItem.EDeadline, 'Дата исполнения заказа (ДД.ММ.ГГГГ)');
  FSearchItem.EReadyOrNot.Text := '';
  ENameExit(FSearchItem.EReadyOrNot, 'Состояние готовности заказа ((не) выполнен)');

  FSearchItem.LTitle.Caption := 'Операции над радиоаппаратурой';
  FSearchItem.LFoundItems.Caption := 'Результаты';
End;

// Open window Main menu clear
Procedure OpenMainMenu;
Begin
  FMainWindow.MItemsDone.Clear;
  FMainWindow.MItemsNotDone.Clear;

  FMainWindow.EDay.Text := '';
  ENameExit(FMAinWindow.EDay, 'ДД');
  FMainWindow.EMonth.Text := '';
  ENameExit(FMAinWindow.EMonth, 'ММ');
  FMainWindow.EYear.Text := '';
  ENameExit(FMAinWindow.EYear, 'ГГГГ');

  FMainWindow.BSaveAsFile.Enabled := True;
  FMainWindow.BSortItems.Enabled := True;
  FMainWindow.BSearchItem.Enabled := True;
  FMainWindow.BCheck.Enabled := True;

  If ItemList = nil then
  Begin
    FMainWindow.BSaveAsFile.Enabled := False;
    FMainWindow.BSortItems.Enabled := False;
    FMainWindow.BSearchItem.Enabled := False;
    FMainWindow.BCheck.Enabled := False;
  End;
End;

End.
