
public class InventoryItemsList extends inkLogicController {

  protected edit let m_InventoryItemName: CName;

  protected edit let m_ItemsLayoutRef: inkCompoundRef;

  protected let m_TooltipsData: array<ref<ATooltipData>>;

  protected let m_ItemsOwner: wref<GameObject>;

  protected let m_ItemsLayout: wref<inkCompoundWidget>;

  protected let m_InventoryItems: array<wref<inkWidget>>;

  @default(InventoryItemsList, false)
  protected let m_IsDevice: Bool;

  protected let m_InventoryManager: ref<InventoryDataManagerV2>;

  protected cb func OnInitialize() -> Bool {
    this.m_ItemsLayout = inkWidgetRef.Get(this.m_ItemsLayoutRef) as inkCompoundWidget;
  }

  protected cb func OnUninitialize() -> Bool {
    while ArraySize(this.m_InventoryItems) > 0 {
      this.DeleteItemDisplay(ArrayPop(this.m_InventoryItems));
    };
    ArrayClear(this.m_InventoryItems);
    if !IsDefined(this.m_InventoryManager) {
      this.m_InventoryManager.UnInitialize();
    };
  }

  public final func PrepareInventory(player: ref<PlayerPuppet>) -> Void {
    if !IsDefined(this.m_InventoryManager) {
      this.m_InventoryManager = new InventoryDataManagerV2();
      this.m_InventoryManager.Initialize(player);
    };
    this.m_ItemsOwner = player;
  }

  public final func PrepareInventory(player: ref<PlayerPuppet>, owner: ref<GameObject>) -> Void {
    if !IsDefined(this.m_InventoryManager) {
      this.m_InventoryManager = new InventoryDataManagerV2();
      this.m_InventoryManager.Initialize(player);
    };
    this.m_ItemsOwner = owner;
  }

  public final func ShowInventory(items: array<wref<gameItemData>>) -> Void {
    let currObject: wref<inkWidget>;
    let i: Int32 = 0;
    let sizeItems: Int32 = ArraySize(items);
    let sizeWidgets: Int32 = ArraySize(this.m_InventoryItems);
    let limit: Int32 = Max(sizeItems, sizeWidgets);
    while i < limit {
      if i < sizeItems {
        if i < sizeWidgets {
          currObject = this.m_InventoryItems[i];
        } else {
          currObject = this.CreateInventoryDisplay();
        };
        this.SetupItemDisplay(currObject, items[i]);
      } else {
        this.DeleteItemDisplay(ArrayPop(this.m_InventoryItems));
      };
      i += 1;
    };
  }

  protected func CreateInventoryDisplay() -> wref<inkWidget> {
    let newObject: wref<inkWidget> = this.SpawnFromLocal(this.m_ItemsLayout, this.m_InventoryItemName);
    let button: wref<inkButtonController> = newObject.GetControllerByType(n"inkButtonController") as inkButtonController;
    if IsDefined(button) {
      button.RegisterToCallback(n"OnButtonClick", this, n"OnButtonClick");
    };
    newObject.RegisterToCallback(n"OnRequestTooltip", this, n"OnInventoryItemEnter");
    newObject.RegisterToCallback(n"OnDismissTooltip", this, n"OnInventoryItemExit");
    ArrayPush(this.m_InventoryItems, newObject);
    return newObject;
  }

  protected func SetupItemDisplay(itemDisplay: wref<inkWidget>, itemData: wref<gameItemData>) -> Void {
    let currLogic: wref<InventoryItemDisplay> = itemDisplay.GetController() as InventoryItemDisplay;
    if IsDefined(currLogic) {
      currLogic.Setup(this.m_InventoryManager.GetInventoryItemData(this.m_ItemsOwner, itemData));
    };
  }

  protected func DeleteItemDisplay(itemDisplay: wref<inkWidget>) -> Void {
    let button: wref<inkButtonController> = itemDisplay.GetControllerByType(n"inkButtonController") as inkButtonController;
    if IsDefined(button) {
      button.RegisterToCallback(n"OnButtonClick", this, n"OnButtonClick");
    };
    itemDisplay.UnregisterFromCallback(n"OnRequestTooltip", this, n"OnInventoryItemEnter");
    itemDisplay.UnregisterFromCallback(n"OnDismissTooltip", this, n"OnInventoryItemExit");
    this.m_ItemsLayout.RemoveChild(itemDisplay);
  }

  protected cb func OnButtonClick(controller: wref<inkButtonController>) -> Bool {
    this.OnItemClicked(controller.GetRootWidget());
  }

  protected func OnItemClicked(e: wref<inkWidget>) -> Void;

  public final func GetTooltipsData() -> array<ref<ATooltipData>> {
    return this.m_TooltipsData;
  }

  protected cb func OnInventoryItemEnter(e: wref<inkWidget>) -> Bool {
    let equippedData: InventoryItemData;
    let inspectedData: InventoryItemData;
    let controller: wref<InventoryItemDisplay> = e.GetController() as InventoryItemDisplay;
    if IsDefined(controller) {
      inspectedData = controller.GetItemData();
      equippedData = this.m_InventoryManager.GetEquippedCounterpartForInventroyItem(inspectedData);
      this.RefreshTooltips(inspectedData, equippedData);
    };
  }

  private final func RefreshTooltips(tooltipItemData: InventoryItemData, equippedItemData: InventoryItemData) -> Void {
    let inspectedTooltip: ref<InventoryTooltipData>;
    ArrayClear(this.m_TooltipsData);
    if !InventoryItemData.IsEmpty(tooltipItemData) {
      inspectedTooltip = this.m_InventoryManager.GetComparisonTooltipsData(equippedItemData, tooltipItemData);
      ArrayPush(this.m_TooltipsData, inspectedTooltip);
      if !InventoryItemData.IsEmpty(equippedItemData) {
        ArrayPush(this.m_TooltipsData, this.m_InventoryManager.GetTooltipDataForInventoryItem(equippedItemData, true));
      };
    };
    this.TooltipDataPostProcess();
    this.CallCustomCallback(n"OnRequestTooltip");
  }

  protected func TooltipDataPostProcess() -> Void;

  protected cb func OnInventoryItemExit(e: wref<inkWidget>) -> Bool {
    this.CallCustomCallback(n"OnDismissTooltip");
  }
}
