
public class CyberwareInventoryMiniGrid extends inkLogicController {

  private edit let m_gridContainer: inkUniformGridRef;

  private edit let m_label: inkTextRef;

  private edit let m_sublabel: inkTextRef;

  private edit let m_number: inkTextRef;

  private edit let m_numberPanel: inkWidgetRef;

  private let m_gridWidth: Int32;

  private let m_selectedSlotIndex: Int32;

  private let m_equipArea: gamedataEquipmentArea;

  private let m_parentObject: ref<IScriptable>;

  private let m_onRealeaseCallbackName: CName;

  private let m_gridData: array<wref<InventoryItemDisplayController>>;

  protected cb func OnInitialize() -> Bool {
    this.m_gridWidth = 0;
    inkWidgetRef.SetVisible(this.m_label, false);
    this.RegisterToCallback(n"OnStateChanged", this, n"OnStateChanged");
  }

  protected cb func OnUninitialize() -> Bool {
    this.RemoveElements(0);
  }

  public final func SetOrientation(orientation: inkEOrientation) -> Void {
    inkUniformGridRef.SetOrientation(this.m_gridContainer, orientation);
  }

  public final func SetupData(equipArea: gamedataEquipmentArea, playerEquipAreaInventory: array<InventoryItemData>, count: Int32, parent: ref<IScriptable>, onRealeaseCallbackName: CName, screen: CyberwareScreenType, hasMods: Bool) -> Void {
    let gridListItem: wref<InventoryItemDisplayController>;
    let i: Int32;
    let slotUserData: ref<SlotUserData>;
    this.m_parentObject = parent;
    this.m_equipArea = equipArea;
    this.m_onRealeaseCallbackName = onRealeaseCallbackName;
    let limit: Int32 = ArraySize(playerEquipAreaInventory);
    inkUniformGridRef.SetWrappingWidgetCount(this.m_gridContainer, Cast(limit));
    while ArraySize(this.m_gridData) > 0 {
      gridListItem = ArrayPop(this.m_gridData);
      inkCompoundRef.RemoveChild(this.m_gridContainer, gridListItem.GetRootWidget());
    };
    i = 0;
    while i < limit {
      slotUserData = new SlotUserData();
      slotUserData.itemData = playerEquipAreaInventory[i];
      slotUserData.index = i;
      slotUserData.area = equipArea;
      ItemDisplayUtils.SpawnCommonSlotAsync(this, this.m_gridContainer, n"itemDisplay", n"OnSlotSpawned", slotUserData);
      i += 1;
    };
    this.UnselectSlot();
    this.UpdateTitles(count, screen, hasMods);
  }

  protected cb func OnStateChanged(widget: wref<inkWidget>, oldState: CName, newState: CName) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_gridData) {
      this.m_gridData[i].GetRootWidget().SetState(newState);
      i += 1;
    };
  }

  public final func SelectSlot(index: Int32) -> Void {
    this.UnselectSlot();
    if index < ArraySize(this.m_gridData) {
      this.m_selectedSlotIndex = index;
      this.m_gridData[this.m_selectedSlotIndex].SetHighlighted(true);
    };
  }

  private final func UnselectSlot() -> Void {
    if this.m_selectedSlotIndex < ArraySize(this.m_gridData) {
      this.m_gridData[this.m_selectedSlotIndex].SetHighlighted(false);
    };
    this.m_selectedSlotIndex = -1;
  }

  public final func GetSelectedSlotData() -> InventoryItemData {
    return this.m_gridData[this.m_selectedSlotIndex].GetItemData();
  }

  public final func GetSlotToEquipe(itemID: ItemID) -> Int32 {
    let emptySlot: Int32 = -1;
    let cyberwareType: CName = TweakDBInterface.GetCName(ItemID.GetTDBID(itemID) + t".cyberwareType", n"");
    let i: Int32 = ArraySize(this.m_gridData) - 1;
    while i >= 0 {
      if InventoryItemData.IsEmpty(this.m_gridData[i].GetItemData()) {
        emptySlot = this.m_gridData[i].GetSlotIndex();
      } else {
        if Equals(cyberwareType, TweakDBInterface.GetCName(ItemID.GetTDBID(InventoryItemData.GetID(this.m_gridData[i].GetItemData())) + t".cyberwareType", n"")) {
          return this.m_gridData[i].GetSlotIndex();
        };
      };
      i -= 1;
    };
    return emptySlot != -1 ? emptySlot : this.m_selectedSlotIndex;
  }

  public final func GetEquipementArea() -> gamedataEquipmentArea {
    return this.m_equipArea;
  }

  public final func UpdateData(equipArea: gamedataEquipmentArea, playerEquipAreaInventory: array<InventoryItemData>, opt count: Int32, opt screen: CyberwareScreenType) -> Void {
    let gridListItem: ref<InventoryItemDisplayController>;
    let i: Int32;
    let limit: Int32 = ArraySize(playerEquipAreaInventory);
    this.m_equipArea = equipArea;
    inkUniformGridRef.SetWrappingWidgetCount(this.m_gridContainer, Cast(limit));
    this.RemoveElements(limit);
    while ArraySize(this.m_gridData) < limit {
      gridListItem = ItemDisplayUtils.SpawnCommonSlotController(this, inkWidgetRef.Get(this.m_gridContainer), n"itemDisplay") as InventoryItemDisplayController;
      gridListItem.RegisterToCallback(n"OnRelease", this.m_parentObject, this.m_onRealeaseCallbackName);
      ArrayPush(this.m_gridData, gridListItem);
    };
    i = 0;
    while i < limit {
      gridListItem = this.m_gridData[i];
      gridListItem.Setup(playerEquipAreaInventory[i], this.m_equipArea, "", i);
      i += 1;
    };
    this.UpdateTitles(count, screen);
    this.UnselectSlot();
  }

  protected cb func OnSlotSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let slotUserData: ref<SlotUserData> = userData as SlotUserData;
    let gridListItem: ref<InventoryItemDisplayController> = widget.GetController() as InventoryItemDisplayController;
    gridListItem.Setup(slotUserData.itemData, slotUserData.area, "", slotUserData.index, ItemDisplayContext.Ripperdoc);
    gridListItem.RegisterToCallback(n"OnRelease", this.m_parentObject, this.m_onRealeaseCallbackName);
    ArrayPush(this.m_gridData, gridListItem);
  }

  public final func UpdateTitles(count: Int32, screen: CyberwareScreenType, opt hasMods: Bool) -> Void {
    let sublabelText: String;
    inkWidgetRef.SetVisible(this.m_label, true);
    inkWidgetRef.SetVisible(this.m_sublabel, true);
    inkTextRef.SetText(this.m_label, this.GetAreaHeader(this.m_equipArea));
    if count > 0 || hasMods {
      sublabelText = Equals(screen, CyberwareScreenType.Ripperdoc) ? "UI-Ripperdoc-AvailableItems" : "UI-Ripperdoc-AvailableMods";
      inkTextRef.SetText(this.m_sublabel, sublabelText);
      inkWidgetRef.SetOpacity(this.m_sublabel, 1.00);
      inkWidgetRef.SetVisible(this.m_numberPanel, true);
      inkTextRef.SetText(this.m_number, IntToString(count));
    } else {
      if Equals(screen, CyberwareScreenType.Ripperdoc) {
        inkTextRef.SetText(this.m_sublabel, "UI-Ripperdoc-NoItems");
        inkWidgetRef.SetOpacity(this.m_sublabel, 0.20);
        inkWidgetRef.SetVisible(this.m_numberPanel, false);
      } else {
        inkWidgetRef.SetVisible(this.m_sublabel, false);
      };
    };
  }

  public final func UpdateTitle(label: String) -> Void {
    inkTextRef.SetText(this.m_label, label);
  }

  public final func GetInventoryItemDisplays() -> array<wref<InventoryItemDisplayController>> {
    return this.m_gridData;
  }

  private final func RemoveElements(limit: Int32) -> Void {
    let gridListItem: wref<InventoryItemDisplayController>;
    while ArraySize(this.m_gridData) > limit {
      gridListItem = ArrayPop(this.m_gridData);
      gridListItem.UnregisterFromCallback(n"OnRelease", this.m_parentObject, this.m_onRealeaseCallbackName);
      inkCompoundRef.RemoveChild(this.m_gridContainer, gridListItem.GetRootWidget());
    };
  }

  private final func GetAreaHeader(area: gamedataEquipmentArea) -> String {
    let record: ref<EquipmentArea_Record> = TweakDBInterface.GetEquipmentAreaRecord(TDBID.Create("EquipmentArea." + EnumValueToString("gamedataEquipmentArea", Cast(EnumInt(area)))));
    let label: String = record.LocalizedName();
    if Equals(label, "") {
      label = EnumValueToString("gamedataEquipmentArea", Cast(EnumInt(area)));
    };
    return label;
  }
}
