
public class InventoryCyberwareItemChooser extends InventoryGenericItemChooser {

  protected edit let m_leftSlotsContainer: inkCompoundRef;

  protected edit let m_rightSlotsContainer: inkCompoundRef;

  private let itemData: InventoryItemData;

  private let itemDatas: array<InventoryItemData>;

  protected func GetDisplayToSpawn() -> CName {
    return n"itemDisplay";
  }

  protected func GetIntroAnimation() -> CName {
    return n"cyberwareItemChoser_intro";
  }

  protected func GetSlots() -> array<InventoryItemAttachments> {
    return InventoryItemData.GetAttachments(this.itemData);
  }

  public func RefreshSelectedItem() -> Void {
    this.ChangeSelectedItem(null);
  }

  public func RequestClose() -> Bool {
    return true;
  }

  protected func RebuildSlots() -> Void {
    let emptyIndex: Int32;
    let i: Int32;
    let slot: ref<InventoryItemDisplayController>;
    let slots: array<InventoryItemAttachments> = this.GetSlots();
    let numberOfSlots: Int32 = ArraySize(slots);
    while inkCompoundRef.GetNumChildren(this.m_leftSlotsContainer) > numberOfSlots {
      inkCompoundRef.RemoveChildByIndex(this.m_leftSlotsContainer, inkCompoundRef.GetNumChildren(this.m_leftSlotsContainer) - 1);
    };
    while inkCompoundRef.GetNumChildren(this.m_leftSlotsContainer) < numberOfSlots {
      slot = ItemDisplayUtils.SpawnCommonSlotController(this, this.m_leftSlotsContainer, n"itemDisplay") as InventoryItemDisplayController;
      if IsDefined(slot) {
        slot.GetRootWidget().RegisterToCallback(n"OnRelease", this, n"OnItemInventoryClick");
        slot.GetRootWidget().RegisterToCallback(n"OnHoverOver", this, n"OnInventoryItemHoverOver");
        slot.GetRootWidget().RegisterToCallback(n"OnHoverOut", this, n"OnInventoryItemHoverOut");
      } else {
        goto 509;
      };
    };
    i = 0;
    while i < numberOfSlots {
      slot = inkCompoundRef.GetWidgetByIndex(this.m_leftSlotsContainer, i).GetController() as InventoryItemDisplayController;
      if TDBID.IsValid(slots[i].SlotID) {
        if !InventoryItemData.IsEmpty(slots[i].ItemData) {
          InventoryItemData.SetIsEquipped(slots[i].ItemData, true);
        };
        slot.SetParentItem(InventoryItemData.GetGameItemData(this.itemData));
        slot.Setup(this.inventoryDataManager, slots[i].ItemData, slots[i].SlotID, ItemDisplayContext.Attachment);
      };
      i += 1;
    };
    if this.selectedItem == null {
      emptyIndex = this.GetFirstEmptySlotIndex(slots);
      if inkCompoundRef.GetNumChildren(this.m_leftSlotsContainer) > 0 && emptyIndex != -1 {
        this.ChangeSelectedItem(inkCompoundRef.GetWidgetByIndex(this.m_leftSlotsContainer, emptyIndex).GetController() as InventoryItemDisplayController);
      } else {
        this.ChangeSelectedItem(null);
      };
    };
  }

  private final func GetFirstEmptySlotIndex(slots: array<InventoryItemAttachments>) -> Int32 {
    let slot: ref<InventoryItemDisplayController>;
    let slotData: InventoryItemData;
    let i: Int32 = 0;
    while i < ArraySize(slots) {
      slot = inkCompoundRef.GetWidgetByIndex(this.m_leftSlotsContainer, i).GetController() as InventoryItemDisplayController;
      slotData = slot.GetItemData();
      if InventoryItemData.IsEmpty(slotData) {
        return i;
      };
      i += 1;
    };
    return 0;
  }

  protected func RefreshMainItem() -> Void {
    let itemID: ItemID;
    let slot: ref<InventoryItemDisplayController>;
    let numSlots: Int32 = this.inventoryDataManager.GetNumberOfSlots(this.equipmentArea);
    let i: Int32 = 0;
    while i < numSlots {
      itemID = this.inventoryDataManager.GetEquippedItemIdInArea(this.equipmentArea, this.slotIndex);
      this.itemData = this.inventoryDataManager.GetItemDataFromIDInLoadout(itemID);
      ArrayPush(this.itemDatas, this.itemData);
      i += 1;
    };
    inkCompoundRef.RemoveAllChildren(this.m_itemContainer);
    i = 0;
    while i < numSlots {
      slot = ItemDisplayUtils.SpawnCommonSlotController(this, this.m_itemContainer, n"itemDisplay") as InventoryItemDisplayController;
      slot.GetRootWidget().RegisterToCallback(n"OnRelease", this, n"OnItemInventoryClick");
      slot.GetRootWidget().RegisterToCallback(n"OnHoverOver", this, n"OnInventoryItemHoverOver");
      slot.GetRootWidget().RegisterToCallback(n"OnHoverOut", this, n"OnInventoryItemHoverOut");
      slot.Bind(this.inventoryDataManager, this.equipmentArea, this.slotIndex, ItemDisplayContext.Ripperdoc);
      i += 1;
    };
  }

  public func GetModifiedItemData() -> InventoryItemData {
    return this.itemData;
  }

  public func GetModifiedItemID() -> ItemID {
    return InventoryItemData.GetID(this.itemData);
  }
}
