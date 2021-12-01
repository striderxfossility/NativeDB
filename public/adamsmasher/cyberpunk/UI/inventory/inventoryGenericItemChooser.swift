
public class InventoryGenericItemChooser extends inkLogicController {

  protected edit let m_itemContainer: inkCompoundRef;

  protected edit let m_slotsCategory: inkWidgetRef;

  protected edit let m_slotsRootContainer: inkWidgetRef;

  protected edit let m_slotsRootLabel: inkTextRef;

  protected edit let m_slotsContainer: inkCompoundRef;

  protected let player: wref<PlayerPuppet>;

  protected let inventoryDataManager: ref<InventoryDataManagerV2>;

  protected let equipmentArea: gamedataEquipmentArea;

  protected let itemDisplay: wref<InventoryItemDisplayController>;

  protected let slotIndex: Int32;

  protected let selectedItem: wref<InventoryItemDisplayController>;

  protected let tooltipsManager: wref<gameuiTooltipsManager>;

  public final func Bind(playerArg: wref<PlayerPuppet>, inventoryDataManagerArg: ref<InventoryDataManagerV2>, equipmentAreaArg: gamedataEquipmentArea, opt slotIndexArg: Int32, opt tooltipsManagerArg: wref<gameuiTooltipsManager>) -> Void {
    this.player = playerArg;
    this.inventoryDataManager = inventoryDataManagerArg;
    this.equipmentArea = equipmentAreaArg;
    this.slotIndex = slotIndexArg;
    this.tooltipsManager = tooltipsManagerArg;
    this.RefreshItems();
    this.PlayLibraryAnimationOnAutoSelectedTargets(this.GetIntroAnimation(), this.GetRootWidget());
  }

  protected func GetDisplayToSpawn() -> CName {
    return Equals(this.equipmentArea, gamedataEquipmentArea.Outfit) ? n"outfitDisplay" : n"itemDisplay";
  }

  protected func GetSlotDisplayToSpawn() -> CName {
    return n"itemDisplay";
  }

  protected func GetIntroAnimation() -> CName {
    return n"genericItemChoser_intro";
  }

  public func RequestClose() -> Bool {
    if this.selectedItem != this.itemDisplay {
      this.ChangeSelectedItem(this.itemDisplay);
      return false;
    };
    return true;
  }

  public func RefreshItems() -> Void {
    this.RefreshMainItem();
    this.RebuildSlots();
  }

  public func RefreshSelectedItem() -> Void;

  protected func RefreshMainItem() -> Void {
    if !IsDefined(this.itemDisplay) {
      inkCompoundRef.RemoveAllChildren(this.m_itemContainer);
      this.itemDisplay = ItemDisplayUtils.SpawnCommonSlotController(this, this.m_itemContainer, this.GetDisplayToSpawn()) as InventoryItemDisplayController;
      this.itemDisplay.Bind(this.inventoryDataManager, this.equipmentArea, this.slotIndex, ItemDisplayContext.GearPanel);
      this.itemDisplay.GetRootWidget().RegisterToCallback(n"OnRelease", this, n"OnItemInventoryClick");
      this.itemDisplay.GetRootWidget().RegisterToCallback(n"OnHoverOver", this, n"OnInventoryItemHoverOver");
      this.itemDisplay.GetRootWidget().RegisterToCallback(n"OnHoverOut", this, n"OnInventoryItemHoverOut");
      this.ChangeSelectedItem(this.itemDisplay);
    } else {
      this.itemDisplay.InvalidateContent();
    };
  }

  protected func GetSlots() -> array<InventoryItemAttachments> {
    let itemData: InventoryItemData = this.itemDisplay.GetItemData();
    return InventoryItemData.GetAttachments(itemData);
  }

  protected func ForceDisplayLabel() -> Bool {
    return false;
  }

  protected func RebuildSlots() -> Void {
    let allItemSlots: array<SPartSlots>;
    let i: Int32;
    let itemSlot: SPartSlots;
    let j: Int32;
    let quality: gamedataQuality;
    let slot: ref<InventoryItemDisplayController>;
    let slots: array<InventoryItemAttachments> = this.GetSlots();
    let numberOfSlots: Int32 = ArraySize(slots);
    let itemData: InventoryItemData = this.itemDisplay.GetItemData();
    if !InventoryItemData.IsEmpty(itemData) && InventoryDataManagerV2.IsEquipmentAreaCyberware(InventoryItemData.GetEquipmentArea(itemData)) {
      numberOfSlots = 0;
    };
    inkWidgetRef.SetVisible(this.m_slotsRootLabel, numberOfSlots > 0 || this.ForceDisplayLabel());
    while inkCompoundRef.GetNumChildren(this.m_slotsContainer) > numberOfSlots {
      inkCompoundRef.RemoveChildByIndex(this.m_slotsContainer, inkCompoundRef.GetNumChildren(this.m_slotsContainer) - 1);
    };
    while inkCompoundRef.GetNumChildren(this.m_slotsContainer) < numberOfSlots {
      slot = ItemDisplayUtils.SpawnCommonSlotController(this, this.m_slotsContainer, this.GetSlotDisplayToSpawn()) as InventoryItemDisplayController;
      if IsDefined(slot) {
        slot.GetRootWidget().RegisterToCallback(n"OnRelease", this, n"OnItemInventoryClick");
        slot.GetRootWidget().RegisterToCallback(n"OnHoverOver", this, n"OnInventoryItemHoverOver");
        slot.GetRootWidget().RegisterToCallback(n"OnHoverOut", this, n"OnInventoryItemHoverOut");
      } else {
        goto 756;
      };
    };
    allItemSlots = ItemModificationSystem.GetAllSlots(this.player, InventoryItemData.GetID(itemData));
    i = 0;
    while i < numberOfSlots {
      slot = inkCompoundRef.GetWidgetByIndex(this.m_slotsContainer, i).GetController() as InventoryItemDisplayController;
      slot.SetDefaultShadowIcon(n"mod_software");
      if TDBID.IsValid(slots[i].SlotID) {
        j = 0;
        while j < ArraySize(allItemSlots) {
          itemSlot = allItemSlots[j];
          if itemSlot.slotID == InventoryItemData.GetSlotID(slots[i].ItemData) {
            if InnerItemData.HasStatData(itemSlot.innerItemData, gamedataStatType.Quality) {
              quality = RPGManager.GetInnerItemDataQuality(itemSlot.innerItemData);
              InventoryItemData.SetQuality(slots[i].ItemData, UIItemsHelper.QualityEnumToName(quality));
            };
          };
          j += 1;
        };
        slot.SetParentItem(InventoryItemData.GetGameItemData(itemData));
        slot.Setup(this.inventoryDataManager, slots[i].ItemData, slots[i].SlotID, ItemDisplayContext.Attachment, true);
      };
      i += 1;
    };
  }

  protected cb func OnItemInventoryClick(e: ref<inkPointerEvent>) -> Bool {
    let widget: ref<inkWidget> = e.GetCurrentTarget();
    let controller: ref<InventoryItemDisplayController> = widget.GetController() as InventoryItemDisplayController;
    if InventoryGPRestrictionHelper.CanUse(controller.GetItemData(), GameInstance.GetPlayerSystem(this.inventoryDataManager.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet) {
      if e.IsAction(n"select") {
        if Equals(controller.GetDisplayContext(), ItemDisplayContext.Attachment) && controller.GetNewItems() == 0 && controller.IsEmpty() {
          return false;
        };
        this.ChangeSelectedItem(controller);
      } else {
        if e.IsAction(n"unequip_item") {
          if controller == this.itemDisplay {
            this.UnequipItem(controller);
          } else {
            this.UnequipItemMods(controller);
            this.ChangeSelectedItem(controller);
          };
        };
      };
    } else {
      this.ShowNotification(this.inventoryDataManager.GetGame(), this.DetermineUIMenuNotificationType());
    };
  }

  protected final func ChangeSelectedItem(controller: ref<InventoryItemDisplayController>) -> Void {
    let ev: ref<ItemChooserItemChanged>;
    if IsDefined(this.selectedItem) {
      this.selectedItem.SetHighlighted(false);
    };
    this.selectedItem = controller;
    controller.SetHighlighted(true);
    if IsDefined(controller) {
      controller.ShowSelectionArrow();
      ev = new ItemChooserItemChanged();
      ev.itemData = controller.GetItemData();
      ev.slotIndex = this.slotIndex;
      ev.slotID = controller.GetSlotID();
      ev.itemEquipmentArea = this.equipmentArea;
      this.QueueEvent(ev);
    };
  }

  protected final func UnequipItem(controller: ref<InventoryItemDisplayController>) -> Void {
    let ev: ref<ItemChooserUnequipItem> = new ItemChooserUnequipItem();
    ev.itemData = this.itemDisplay.GetItemData();
    this.QueueEvent(ev);
  }

  protected final func UnequipItemMods(controller: ref<InventoryItemDisplayController>) -> Void {
    let ev: ref<ItemChooserUnequipMod>;
    let notification: ref<UIMenuNotificationEvent>;
    if this.inventoryDataManager.CanUninstallMod(controller.GetItemType(), controller.GetSlotID()) {
      ev = new ItemChooserUnequipMod();
      ev.itemData = this.itemDisplay.GetItemData();
      ev.slotID = controller.GetSlotID();
      this.QueueEvent(ev);
    } else {
      notification = new UIMenuNotificationEvent();
      notification.m_notificationType = UIMenuNotificationType.InventoryActionBlocked;
      GameInstance.GetUISystem(this.inventoryDataManager.GetGame()).QueueEvent(notification);
    };
  }

  public final func GetSlotIndex() -> Int32 {
    return this.slotIndex;
  }

  public final func GetSelectedItem() -> ref<InventoryItemDisplayController> {
    return this.selectedItem;
  }

  public func GetModifiedItem() -> ref<InventoryItemDisplayController> {
    return this.itemDisplay;
  }

  public func GetModifiedItemData() -> InventoryItemData {
    return this.itemDisplay.GetItemData();
  }

  public func GetModifiedItemID() -> ItemID {
    return InventoryItemData.GetID(this.GetModifiedItemData());
  }

  public func GetSelectedSlotID() -> TweakDBID {
    return this.selectedItem.GetSlotID();
  }

  protected cb func OnInventoryItemHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let controller: ref<InventoryItemDisplayController>;
    let itemChooserItemHoverOverEvent: ref<ItemChooserItemHoverOver>;
    if IsDefined(this.tooltipsManager) {
      controller = this.GetInventoryItemDisplayControllerFromTarget(evt);
      this.SetInventoryItemTooltipHoverOver(controller.GetItemData(), controller);
      itemChooserItemHoverOverEvent = new ItemChooserItemHoverOver();
      itemChooserItemHoverOverEvent.sourceEvent = evt;
      itemChooserItemHoverOverEvent.targetItem = controller;
      this.QueueEvent(itemChooserItemHoverOverEvent);
    };
  }

  protected cb func OnInventoryItemHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    let itemChooserItemHoverOutEvent: ref<ItemChooserItemHoverOut>;
    this.HideTooltips();
    itemChooserItemHoverOutEvent = new ItemChooserItemHoverOut();
    itemChooserItemHoverOutEvent.sourceEvent = evt;
    this.QueueEvent(itemChooserItemHoverOutEvent);
  }

  private final func SetInventoryItemTooltipHoverOver(itemData: InventoryItemData, opt controller: ref<InventoryItemDisplayController>) -> Void {
    if !InventoryItemData.IsEmpty(itemData) {
      this.ShowTooltipForItemData(itemData, controller);
    };
  }

  private final func ShowTooltipForItemData(inspectedItemData: InventoryItemData, opt controller: ref<InventoryItemDisplayController>) -> Void {
    let tooltipData: ref<InventoryTooltipData> = this.inventoryDataManager.GetTooltipDataForInventoryItem(inspectedItemData, false);
    if Equals(controller.GetDisplayContext(), ItemDisplayContext.Attachment) {
      tooltipData.displayContext = InventoryTooltipDisplayContext.Attachment;
      tooltipData.parentItemData = controller.GetParentItemData();
      tooltipData.slotID = controller.GetSlotID();
    };
    this.tooltipsManager.ShowTooltip(n"itemTooltip", tooltipData);
  }

  private final func GetInventoryItemDisplayControllerFromTarget(evt: ref<inkPointerEvent>) -> ref<InventoryItemDisplayController> {
    let widget: ref<inkWidget> = evt.GetCurrentTarget();
    let controller: wref<InventoryItemDisplayController> = widget.GetController() as InventoryItemDisplayController;
    return controller;
  }

  private final func HideTooltips() -> Void {
    if IsDefined(this.tooltipsManager) {
      this.tooltipsManager.HideTooltips();
    };
  }

  public final func GetEquipmentArea() -> gamedataEquipmentArea {
    let modifiedItem: InventoryItemData = this.GetModifiedItemData();
    return InventoryItemData.GetEquipmentArea(modifiedItem);
  }

  public func IsAttachmentItem(itemData: InventoryItemData) -> Bool {
    let slots: array<InventoryItemAttachments> = this.GetSlots();
    let i: Int32 = 0;
    while i < ArraySize(slots) {
      if Equals(slots[i].ItemData, itemData) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func ShowNotification(gameInstance: GameInstance, type: UIMenuNotificationType) -> Void {
    let inventoryNotification: ref<UIMenuNotificationEvent> = new UIMenuNotificationEvent();
    inventoryNotification.m_notificationType = type;
    GameInstance.GetUISystem(gameInstance).QueueEvent(inventoryNotification);
  }

  private final func DetermineUIMenuNotificationType() -> UIMenuNotificationType {
    let inCombat: Bool = false;
    let psmBlackboard: ref<IBlackboard> = (GameInstance.GetPlayerSystem(this.inventoryDataManager.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet).GetPlayerStateMachineBlackboard();
    inCombat = psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat);
    if inCombat {
      return UIMenuNotificationType.InCombat;
    };
    return UIMenuNotificationType.InventoryActionBlocked;
  }
}
