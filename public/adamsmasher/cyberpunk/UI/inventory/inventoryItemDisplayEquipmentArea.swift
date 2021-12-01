
public class InventoryItemDisplayCategoryArea extends inkLogicController {

  protected edit const let m_areasToHide: array<inkWidgetRef>;

  protected edit const let m_equipmentAreas: array<inkCompoundRef>;

  protected edit let m_newItemsWrapper: inkWidgetRef;

  protected edit let m_newItemsCounter: inkTextRef;

  protected let m_categoryAreas: array<wref<InventoryItemDisplayEquipmentArea>>;

  protected cb func OnInitialize() -> Bool {
    let equipmentAreaCategoryCreated: ref<EquipmentAreaCategoryCreated>;
    let i: Int32;
    inkWidgetRef.SetVisible(this.m_newItemsWrapper, false);
    ArrayClear(this.m_categoryAreas);
    i = 0;
    while i < ArraySize(this.m_equipmentAreas) {
      ArrayPush(this.m_categoryAreas, inkWidgetRef.GetController(this.m_equipmentAreas[i]) as InventoryItemDisplayEquipmentArea);
      i += 1;
    };
    equipmentAreaCategoryCreated = new EquipmentAreaCategoryCreated();
    equipmentAreaCategoryCreated.categoryController = this;
    equipmentAreaCategoryCreated.equipmentAreasControllers = this.m_categoryAreas;
    this.QueueEvent(equipmentAreaCategoryCreated);
  }

  public final func SetNewItemsCounter(value: Int32) -> Void {
    inkTextRef.SetText(this.m_newItemsCounter, IntToString(value));
    inkWidgetRef.SetVisible(this.m_newItemsWrapper, value > 0);
  }

  public final func GetAreasToHide() -> array<inkWidgetRef> {
    return this.m_areasToHide;
  }

  public final func GetCategoryAreas() -> array<wref<InventoryItemDisplayEquipmentArea>> {
    return this.m_categoryAreas;
  }
}

public class InventoryItemDisplayEquipmentArea extends inkLogicController {

  protected edit const let m_equipmentAreas: array<gamedataEquipmentArea>;

  protected edit let m_numberOfSlots: Int32;

  public final static func GetEquipmentAreaByName(categoryName: String) -> gamedataEquipmentArea {
    switch categoryName {
      case "Head":
        return gamedataEquipmentArea.Head;
      case "Face":
        return gamedataEquipmentArea.Face;
      case "OuterChest":
        return gamedataEquipmentArea.OuterChest;
      case "InnerChest":
        return gamedataEquipmentArea.InnerChest;
      case "Legs":
        return gamedataEquipmentArea.Legs;
      case "Feet":
        return gamedataEquipmentArea.Feet;
      case "Weapon":
        return gamedataEquipmentArea.Weapon;
      case "QuickSlot":
        return gamedataEquipmentArea.QuickSlot;
      case "Consumable":
        return gamedataEquipmentArea.Consumable;
      case "Consumable":
        return gamedataEquipmentArea.Consumable;
    };
    return gamedataEquipmentArea.Invalid;
  }

  public final func GetNumberOfSlots() -> Int32 {
    return this.m_numberOfSlots;
  }

  public final func GetEquipmentAreas() -> array<gamedataEquipmentArea> {
    return this.m_equipmentAreas;
  }
}
