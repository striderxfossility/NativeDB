
public class UIScriptableSystem extends ScriptableSystem {

  private persistent let m_backpackActiveSorting: Int32;

  private persistent let m_backpackActiveFilter: Int32;

  private persistent let m_isBackpackActiveFilterSaved: Bool;

  private persistent let m_vendorPanelPlayerActiveSorting: Int32;

  private persistent let m_vendorPanelVendorActiveSorting: Int32;

  private persistent let m_newItems: array<ItemID>;

  private persistent let m_comparisionTooltipDisabled: Bool;

  private let m_attachedPlayer: wref<PlayerPuppet>;

  private let m_inventoryListenerCallback: ref<UIScriptableInventoryListenerCallback>;

  private let m_inventoryListener: ref<InventoryScriptListener>;

  private func OnAttach() -> Void {
    this.SetupInstance();
  }

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    this.SetupInstance();
  }

  private func OnDetach() -> Void {
    GameInstance.GetTransactionSystem(this.m_attachedPlayer.GetGame()).UnregisterInventoryListener(this.m_attachedPlayer, this.m_inventoryListener);
    this.m_inventoryListener = null;
  }

  private final func SetupInstance() -> Void {
    this.m_inventoryListenerCallback = new UIScriptableInventoryListenerCallback();
  }

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    if this.m_attachedPlayer != null {
      GameInstance.GetTransactionSystem(this.m_attachedPlayer.GetGame()).UnregisterInventoryListener(this.m_attachedPlayer, this.m_inventoryListener);
    };
    this.m_attachedPlayer = request.owner as PlayerPuppet;
    this.m_inventoryListener = GameInstance.GetTransactionSystem(this.m_attachedPlayer.GetGame()).RegisterInventoryListener(this.m_attachedPlayer, this.m_inventoryListenerCallback);
    this.m_inventoryListenerCallback.AttachScriptableSystem(this.m_attachedPlayer.GetGame());
  }

  public final static func GetInstance(gameInstance: GameInstance) -> ref<UIScriptableSystem> {
    let system: ref<UIScriptableSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"UIScriptableSystem") as UIScriptableSystem;
    return system;
  }

  private final func OnSetBackpackSorting(request: ref<UIScriptableSystemSetBackpackSorting>) -> Void {
    this.m_backpackActiveSorting = request.sortMode;
  }

  private final func OnSetBackpackFilter(request: ref<UIScriptableSystemSetBackpackFilter>) -> Void {
    this.m_backpackActiveFilter = request.filterMode;
    this.m_isBackpackActiveFilterSaved = true;
  }

  private final func OnSetVendorPanelVendorSorting(request: ref<UIScriptableSystemSetVendorPanelVendorSorting>) -> Void {
    this.m_vendorPanelVendorActiveSorting = request.sortMode;
  }

  private final func OnSetVendorPanelPlayerSorting(request: ref<UIScriptableSystemSetVendorPanelPlayerSorting>) -> Void {
    this.m_vendorPanelPlayerActiveSorting = request.sortMode;
  }

  private final func OnComparisionTooltipDisabled(request: ref<UIScriptableSystemSetComparisionTooltipDisabled>) -> Void {
    this.m_comparisionTooltipDisabled = request.value;
  }

  private final func OnInventoryItemAdded(request: ref<UIScriptableSystemInventoryAddItem>) -> Void {
    if !ArrayContains(this.m_newItems, request.itemID) {
      ArrayPush(this.m_newItems, request.itemID);
    };
  }

  private final func OnInventoryItemRemoved(request: ref<UIScriptableSystemInventoryRemoveItem>) -> Void {
    if ArrayContains(this.m_newItems, request.itemID) {
      ArrayRemove(this.m_newItems, request.itemID);
    };
  }

  private final func OnInventoryItemInspected(request: ref<UIScriptableSystemInventoryInspectItem>) -> Void {
    if ArrayContains(this.m_newItems, request.itemID) {
      ArrayRemove(this.m_newItems, request.itemID);
    };
  }

  public final const func GetBackpackActiveSorting(opt defaultValue: Int32) -> Int32 {
    if this.m_backpackActiveSorting == 0 {
      return defaultValue;
    };
    return this.m_backpackActiveSorting;
  }

  public final const func GetBackpackActiveFilter(opt defaultValue: Int32) -> Int32 {
    if !this.m_isBackpackActiveFilterSaved {
      return defaultValue;
    };
    return this.m_backpackActiveFilter;
  }

  public final const func GetVendorPanelVendorActiveSorting(opt defaultValue: Int32) -> Int32 {
    if this.m_vendorPanelVendorActiveSorting == 0 {
      return defaultValue;
    };
    return this.m_vendorPanelVendorActiveSorting;
  }

  public final const func GetVendorPanelPlayerActiveSorting(opt defaultValue: Int32) -> Int32 {
    if this.m_vendorPanelPlayerActiveSorting == 0 {
      return defaultValue;
    };
    return this.m_vendorPanelPlayerActiveSorting;
  }

  public final const func IsInventoryItemNew(itemID: ItemID) -> Bool {
    return ArrayContains(this.m_newItems, itemID);
  }

  public final const func IsComparisionTooltipDisabled() -> Bool {
    return this.m_comparisionTooltipDisabled;
  }
}

public class UIScriptableInventoryListenerCallback extends InventoryScriptCallback {

  private let m_uiScriptableSystem: wref<UIScriptableSystem>;

  public final func AttachScriptableSystem(gameInstance: GameInstance) -> Void {
    this.m_uiScriptableSystem = UIScriptableSystem.GetInstance(gameInstance);
  }

  public func OnItemAdded(item: ItemID, itemData: wref<gameItemData>, flaggedAsSilent: Bool) -> Void {
    let request: ref<UIScriptableSystemInventoryAddItem> = new UIScriptableSystemInventoryAddItem();
    request.itemID = item;
    this.m_uiScriptableSystem.QueueRequest(request);
  }

  public func OnItemRemoved(item: ItemID, difference: Int32, currentQuantity: Int32) -> Void {
    let request: ref<UIScriptableSystemInventoryRemoveItem> = new UIScriptableSystemInventoryRemoveItem();
    request.itemID = item;
    this.m_uiScriptableSystem.QueueRequest(request);
  }

  public func OnItemQuantityChanged(item: ItemID, diff: Int32, total: Uint32, flaggedAsSilent: Bool) -> Void;
}
