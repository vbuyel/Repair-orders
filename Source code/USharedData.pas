Unit USharedData;

Interface

// Used item's type
Type
  // Pointer initialization
  PItem = ^TItem;

  // Data type
  TData = packed record
    Day: integer;
    Month: integer;
    Year: integer;
  end;

  // Item's type
  TThisItem = packed record
    Group: string[255];
    Marka: string[255];
    TakenData: TData;
    Deadline: TData;
    ReadyOrNot: boolean;
  end;

  // List type
  TItem = record
    ItemPrev: PItem;
    ThisItem: TThisItem;
    ItemNext: PItem;
  end;

  // Function's return type
  TAnswer = record
    ThisItem: TThisItem;
    CodeError: Integer;
  end;

Var
  ItemList: PItem;
  Item, ItemChange: TThisItem;
{
 ItemList - the main list of items
 Item - item' parameters throught windows
 ItemChange - item to change
}

Implementation

End.
