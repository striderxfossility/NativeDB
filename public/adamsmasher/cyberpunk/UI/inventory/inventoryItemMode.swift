
public class InventoryItemModeLogicController extends inkLogicController {

  private edit let m_itemCategoryList: inkCompoundRef;

  private edit let m_itemCategoryHeader: inkTextRef;

  private edit let m_mainWrapper: inkCompoundRef;

  private edit let m_emptyInventoryText: inkTextRef;

  private edit let m_filterButtonsGrid: inkCompoundRef;

  private edit let m_itemGridContainer: inkWidgetRef;

  private edit let m_cyberwareGridContainer: inkWidgetRef;

  private edit let m_itemGridScrollControllerWidget: inkWidgetRef;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_TooltipsManager: wref<gameuiTooltipsManager>;

  private let m_InventoryManager: ref<InventoryDataManagerV2>;

  private let m_player: wref<PlayerPuppet>;

  private let m_equipmentSystem: wref<EquipmentSystem>;

  private let m_transactionSystem: wref<TransactionSystem>;

  private let m_uiScriptableSystem: wref<UIScriptableSystem>;

  private let itemChooser: wref<InventoryGenericItemChooser>;

  private let m_lastEquipmentAreas: array<gamedataEquipmentArea>;

  @default(InventoryItemModeLogicController, EHotkey.INVALID)
  private let m_currentHotkey: EHotkey;

  private let m_inventoryController: wref<gameuiInventoryGameController>;

  private let m_itemsPositionProvider: ref<ItemPositionProvider>;

  public let equipmentBlackboard: wref<IBlackboard>;

  public let itemModsBlackboard: wref<IBlackboard>;

  public let equipmentBlackboardCallback: ref<CallbackHandle>;

  public let itemModsBlackboardCallback: ref<CallbackHandle>;

  public let m_itemGridClassifier: ref<ItemModeGridClassifier>;

  public let m_itemGridDataView: ref<ItemModeGridView>;

  public let m_itemGridDataSource: ref<ScriptableDataSource>;

  private let m_activeFilter: wref<BackpackFilterButtonController>;

  private let m_filterManager: ref<ItemCategoryFliterManager>;

  private let m_savedFilter: ItemFilterCategory;

  private let m_lastSelectedDisplay: wref<InventoryItemDisplayController>;

  private let m_itemModeInventoryListenerCallback: ref<ItemModeInventoryListenerCallback>;

  private let m_itemModeInventoryListener: ref<InventoryScriptListener>;

  private let m_itemModeInventoryListenerRegistered: Bool;

  private let m_itemGridContainerController: wref<ItemModeGridContainer>;

  private let m_cyberwareGridContainerController: wref<ItemModeGridContainer>;

  private let m_comparisonResolver: ref<ItemPreferredComparisonResolver>;

  private let m_isE3Demo: Bool;

  public let m_isShown: Bool;

  public let m_itemDropQueue: array<ItemModParams>;

  private let m_lastItemHoverOverEvent: ref<ItemDisplayHoverOverEvent>;

  private let m_isComparisionDisabled: Bool;

  private let m_replaceModNotification: ref<inkGameNotificationToken>;

  private let m_installModData: ref<InstallModConfirmationData>;

  private let HACK_lastItemDisplayEvent: ref<ItemDisplayClickEvent>;

  protected cb func OnInitialize() -> Bool {
    let virtualGrid: ref<inkGridController>;
    this.m_itemModeInventoryListenerCallback = new ItemModeInventoryListenerCallback();
    this.m_itemModeInventoryListenerCallback.Setup(this);
    inkCompoundRef.RemoveAllChildren(this.m_itemCategoryList);
    this.m_itemGridContainerController = inkWidgetRef.GetController(this.m_itemGridContainer) as ItemModeGridContainer;
    this.m_cyberwareGridContainerController = inkWidgetRef.GetController(this.m_cyberwareGridContainer) as ItemModeGridContainer;
    this.m_itemGridClassifier = new ItemModeGridClassifier();
    this.m_itemGridDataView = new ItemModeGridView();
    this.m_itemGridDataSource = new ScriptableDataSource();
    this.m_itemsPositionProvider = new ItemPositionProvider();
    virtualGrid = this.m_itemGridContainerController.GetItemsWidget().GetController() as inkGridController;
    virtualGrid.SetClassifier(this.m_itemGridClassifier);
    virtualGrid.SetSource(this.m_itemGridDataView);
    this.m_itemGridDataView.SetSource(this.m_itemGridDataSource);
    virtualGrid.SetProvider(this.m_itemsPositionProvider);
    this.m_itemGridDataView.EnableSorting();
    inkWidgetRef.SetVisible(this.m_itemGridContainer, false);
    inkWidgetRef.SetVisible(this.m_cyberwareGridContainer, false);
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnPostOnRelease");
  }

  protected cb func OnUninitialize() -> Bool {
    let virtualGrid: ref<inkGridController>;
    this.UnregisterBlackboard();
    this.m_itemGridDataView.SetSource(null);
    virtualGrid = this.m_itemGridContainerController.GetItemsWidget().GetController() as inkGridController;
    virtualGrid.SetSource(null);
    virtualGrid.SetClassifier(null);
    virtualGrid.SetProvider(null);
    this.m_itemGridClassifier = null;
    this.m_itemGridDataView = null;
    this.m_itemGridDataSource = null;
    GameInstance.GetTransactionSystem(this.m_player.GetGame()).UnregisterInventoryListener(this.m_player, this.m_itemModeInventoryListener);
    this.m_itemModeInventoryListener = null;
    this.m_itemModeInventoryListenerRegistered = false;
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnPostOnRelease");
  }

  protected final func RegisterBlackboard() -> Void {
    this.equipmentBlackboard = GameInstance.GetBlackboardSystem(this.m_player.GetGame()).Get(GetAllBlackboardDefs().UI_Equipment);
    this.itemModsBlackboard = GameInstance.GetBlackboardSystem(this.m_player.GetGame()).Get(GetAllBlackboardDefs().UI_ItemModSystem);
    if IsDefined(this.equipmentBlackboard) {
      this.equipmentBlackboardCallback = this.equipmentBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_Equipment.itemEquipped, this, n"OnItemEquiped");
    };
    if IsDefined(this.itemModsBlackboard) {
      this.itemModsBlackboardCallback = this.itemModsBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_ItemModSystem.ItemModSystemUpdated, this, n"OnItemModUpdatedEquiped");
    };
  }

  protected final func UnregisterBlackboard() -> Void {
    if IsDefined(this.equipmentBlackboard) {
      this.equipmentBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_Equipment.itemEquipped, this.equipmentBlackboardCallback);
    };
  }

  public final func SetSortMode(identifier: ItemSortMode) -> Void {
    this.m_itemGridDataView.SetSortMode(identifier);
  }

  protected cb func OnItemEquiped(value: Variant) -> Bool {
    this.itemChooser.RefreshItems();
    this.RefreshAvailableItems();
  }

  protected cb func OnPostOnRelease(evt: ref<inkPointerEvent>) -> Bool {
    let setComparisionDisabledRequest: ref<UIScriptableSystemSetComparisionTooltipDisabled>;
    if evt.IsAction(n"toggle_comparison_tooltip") {
      this.m_isComparisionDisabled = !this.m_isComparisionDisabled;
      this.m_buttonHintsController.AddButtonHint(n"toggle_comparison_tooltip", GetLocalizedText(this.m_isComparisionDisabled ? "UI-UserActions-EnableComparison" : "UI-UserActions-DisableComparison"));
      setComparisionDisabledRequest = new UIScriptableSystemSetComparisionTooltipDisabled();
      setComparisionDisabledRequest.value = this.m_isComparisionDisabled;
      this.m_uiScriptableSystem.QueueRequest(setComparisionDisabledRequest);
      this.InvalidateItemTooltipEvent();
    };
  }

  protected cb func OnItemModUpdatedEquiped(value: Variant) -> Bool {
    let isMainItemSelected: Bool = this.itemChooser.GetSelectedItem() == this.itemChooser.GetModifiedItem();
    this.itemChooser.RefreshSelectedItem();
    this.itemChooser.RefreshItems();
    this.RefreshAvailableItems(isMainItemSelected ? ItemViewModes.Item : ItemViewModes.Mod);
    this.NotifyItemUpdate();
  }

  protected cb func OnItemChooserItemChanged(e: ref<ItemChooserItemChanged>) -> Bool {
    let itemsToSkip: array<ItemID>;
    let itemViewMode: ItemViewModes = ItemViewModes.Mod;
    if !TDBID.IsValid(e.slotID) || e.slotID == TDBID.undefined() {
      itemViewMode = ItemViewModes.Item;
    };
    if Equals(e.itemEquipmentArea, gamedataEquipmentArea.Consumable) || Equals(e.itemEquipmentArea, gamedataEquipmentArea.QuickSlot) {
      if Equals(e.itemEquipmentArea, gamedataEquipmentArea.Consumable) {
        this.m_currentHotkey = EHotkey.DPAD_UP;
      } else {
        if Equals(e.itemEquipmentArea, gamedataEquipmentArea.QuickSlot) {
          this.m_currentHotkey = EHotkey.RB;
        };
      };
      ArrayPush(itemsToSkip, this.itemChooser.GetSelectedItem().GetItemID());
      this.UpdateAvailableHotykeyItems(this.m_currentHotkey, itemsToSkip);
    } else {
      this.m_currentHotkey = EHotkey.INVALID;
      this.SetEquipmentArea(e.itemEquipmentArea);
      this.RefreshAvailableItems(itemViewMode);
    };
    (inkWidgetRef.GetController(this.m_itemGridScrollControllerWidget) as inkScrollController).SetScrollPosition(0.00);
  }

  private final func SetEquipmentArea(equipmentArea: gamedataEquipmentArea) -> Void {
    let equipmentAreas: array<gamedataEquipmentArea> = this.m_inventoryController.GetEquipementAreaDisplays(equipmentArea).equipmentAreas;
    this.SetupFiltersToCheck(ArraySize(equipmentAreas) > 0 ? equipmentAreas[0] : gamedataEquipmentArea.Invalid);
    this.m_lastEquipmentAreas = equipmentAreas;
  }

  public final func SetupData(buttonHints: wref<ButtonHints>, tooltipsManager: wref<gameuiTooltipsManager>, inventoryManager: ref<InventoryDataManagerV2>, player: wref<PlayerPuppet>) -> Void {
    this.m_TooltipsManager = tooltipsManager;
    this.m_buttonHintsController = buttonHints;
    this.m_InventoryManager = inventoryManager;
    this.m_player = player;
    this.m_isE3Demo = GameInstance.GetQuestsSystem(this.m_player.GetGame()).GetFact(n"e3_2020") > 0;
    this.m_comparisonResolver = ItemPreferredComparisonResolver.Make(this.m_InventoryManager);
    this.m_equipmentSystem = GameInstance.GetScriptableSystemsContainer(this.m_player.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    this.m_transactionSystem = GameInstance.GetTransactionSystem(this.m_player.GetGame());
    this.m_uiScriptableSystem = UIScriptableSystem.GetInstance(this.m_player.GetGame());
    this.m_itemGridDataView.BindUIScriptableSystem(this.m_uiScriptableSystem);
    this.m_isComparisionDisabled = this.m_uiScriptableSystem.IsComparisionTooltipDisabled();
    this.m_buttonHintsController.AddButtonHint(n"toggle_comparison_tooltip", GetLocalizedText(this.m_isComparisionDisabled ? "UI-UserActions-EnableComparison" : "UI-UserActions-DisableComparison"));
    this.RegisterBlackboard();
    if IsDefined(this.m_itemModeInventoryListener) && this.m_itemModeInventoryListenerRegistered {
      GameInstance.GetTransactionSystem(this.m_player.GetGame()).UnregisterInventoryListener(this.m_player, this.m_itemModeInventoryListener);
      this.m_itemModeInventoryListenerRegistered = false;
      this.m_itemModeInventoryListener = null;
    };
    this.m_itemModeInventoryListener = GameInstance.GetTransactionSystem(this.m_player.GetGame()).RegisterInventoryListener(this.m_player, this.m_itemModeInventoryListenerCallback);
    this.m_itemModeInventoryListenerRegistered = true;
    this.m_filterManager = ItemCategoryFliterManager.Make(true);
  }

  public final func SetupMode(displayData: InventoryItemDisplayData, dataSource: ref<InventoryDataManagerV2>, opt inventoryController: wref<gameuiInventoryGameController>) -> Void {
    this.itemChooser = this.CreateItemChooser(displayData, dataSource);
    this.m_inventoryController = inventoryController;
    inkTextRef.SetText(this.m_itemCategoryHeader, this.m_inventoryController.GetCategoryHeader(displayData));
    if IsDefined(this.m_activeFilter) {
      this.m_activeFilter.SetActive(false);
      this.m_activeFilter = null;
    };
    this.m_itemGridDataView.SetFilterType(ItemFilterCategory.AllItems);
    (inkWidgetRef.GetController(this.m_itemGridScrollControllerWidget) as inkScrollController).SetScrollPosition(0.00);
  }

  public final func RequestClose() -> Bool {
    let result: Bool = true;
    if IsDefined(this.itemChooser) {
      result = this.itemChooser.RequestClose();
    };
    if result {
      inkCompoundRef.RemoveAllChildren(this.m_itemCategoryList);
    };
    return result;
  }

  public final func SetTranslation(translation: Vector2) -> Void {
    inkWidgetRef.SetTranslation(this.m_mainWrapper, translation);
  }

  public final func CreateItemChooser(displayData: InventoryItemDisplayData, dataSource: ref<InventoryDataManagerV2>) -> ref<InventoryGenericItemChooser> {
    let itemChooserRet: ref<InventoryGenericItemChooser>;
    let itemChooserToCreate: CName = n"genericItemChooser";
    switch displayData.m_equipmentArea {
      case gamedataEquipmentArea.Weapon:
        itemChooserToCreate = n"weaponItemChooser";
        break;
      case gamedataEquipmentArea.EyesCW:
      case gamedataEquipmentArea.HandsCW:
      case gamedataEquipmentArea.ArmsCW:
      case gamedataEquipmentArea.SystemReplacementCW:
        itemChooserToCreate = n"cyberwareModsChooser";
    };
    inkCompoundRef.RemoveAllChildren(this.m_itemCategoryList);
    itemChooserRet = this.SpawnFromLocal(inkWidgetRef.Get(this.m_itemCategoryList), itemChooserToCreate).GetController() as InventoryGenericItemChooser;
    itemChooserRet.Bind(this.m_player, dataSource, displayData.m_equipmentArea, displayData.m_slotIndex, this.m_TooltipsManager);
    return itemChooserRet;
  }

  private final func SetupFiltersToCheck(equipmentArea: gamedataEquipmentArea) -> Void {
    this.m_filterManager.Clear(true);
    if Equals(equipmentArea, gamedataEquipmentArea.Weapon) {
      this.m_filterManager.AddFilterToCheck(ItemFilterCategory.RangedWeapons);
      this.m_filterManager.AddFilterToCheck(ItemFilterCategory.MeleeWeapons);
      this.m_filterManager.AddFilterToCheck(ItemFilterCategory.SoftwareMods);
      this.m_filterManager.AddFilterToCheck(ItemFilterCategory.Attachments);
    } else {
      if this.IsEquipmentAreaClothing(equipmentArea) {
        this.m_filterManager.AddFilterToCheck(ItemFilterCategory.Clothes);
        this.m_filterManager.AddFilterToCheck(ItemFilterCategory.SoftwareMods);
        this.m_filterManager.AddFilterToCheck(ItemFilterCategory.Attachments);
      };
    };
  }

  private final func CreateFilterButtons(targetWidget: inkCompoundRef, opt equipmentArea: gamedataEquipmentArea) -> Void {
    let filterButton: ref<BackpackFilterButtonController>;
    let filters: array<ItemFilterCategory>;
    let i: Int32;
    if !ArrayContains(this.m_lastEquipmentAreas, equipmentArea) {
      filters = this.m_filterManager.GetSortedFiltersList();
      inkCompoundRef.RemoveAllChildren(this.m_filterButtonsGrid);
      i = 0;
      while i < ArraySize(filters) {
        filterButton = this.SpawnFromLocal(inkWidgetRef.Get(targetWidget) as inkCompoundWidget, n"filterButtonItem").GetController() as BackpackFilterButtonController;
        filterButton.RegisterToCallback(n"OnRelease", this, n"OnItemFilterClick");
        filterButton.RegisterToCallback(n"OnHoverOver", this, n"OnItemFilterHoverOver");
        filterButton.RegisterToCallback(n"OnHoverOut", this, n"OnItemFilterHoverOut");
        filterButton.Setup(filters[i]);
        if Equals(filters[i], this.m_savedFilter) {
          filterButton.SetActive(true);
          this.m_activeFilter = filterButton;
        };
        i += 1;
      };
    };
  }

  private final func SelectFilterButton(targetFilter: ItemFilterCategory) -> Void {
    let controller: ref<BackpackFilterButtonController>;
    let i: Int32 = 0;
    while i < inkCompoundRef.GetNumChildren(this.m_filterButtonsGrid) {
      controller = inkCompoundRef.GetWidgetByIndex(this.m_filterButtonsGrid, i).GetController() as BackpackFilterButtonController;
      if Equals(controller.GetFilterType(), targetFilter) {
        this.SetActiveFilterController(controller);
      };
      i += 1;
    };
  }

  private final func GetFilterButtonIndex(targetFilter: ItemFilterCategory) -> Int32 {
    let controller: ref<BackpackFilterButtonController>;
    let i: Int32 = 0;
    while i < inkCompoundRef.GetNumChildren(this.m_filterButtonsGrid) {
      controller = inkCompoundRef.GetWidgetByIndex(this.m_filterButtonsGrid, i).GetController() as BackpackFilterButtonController;
      if Equals(controller.GetFilterType(), targetFilter) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final func SelectFilterButtonByIndex(index: Int32) -> Void {
    let controller: ref<BackpackFilterButtonController>;
    if index >= 0 && index < inkCompoundRef.GetNumChildren(this.m_filterButtonsGrid) {
      controller = inkCompoundRef.GetWidgetByIndex(this.m_filterButtonsGrid, index).GetController() as BackpackFilterButtonController;
      this.SetActiveFilterController(controller);
    };
  }

  protected cb func OnItemFilterClick(evt: ref<inkPointerEvent>) -> Bool {
    let controller: ref<BackpackFilterButtonController>;
    let widget: ref<inkWidget>;
    if evt.IsAction(n"click") {
      widget = evt.GetCurrentTarget();
      controller = widget.GetController() as BackpackFilterButtonController;
      this.SetActiveFilterController(controller);
      this.PlayLibraryAnimation(n"inventory_grid_filter_change");
      this.PlaySound(n"Button", n"OnPress");
    };
  }

  private final func SetActiveFilterController(controller: ref<BackpackFilterButtonController>) -> Void {
    if IsDefined(this.m_activeFilter) {
      this.m_activeFilter.SetActive(false);
    };
    this.m_activeFilter = controller;
    this.m_activeFilter.SetActive(true);
    this.m_savedFilter = controller.GetFilterType();
    this.m_itemGridDataView.SetFilterType(controller.GetFilterType());
    this.m_itemGridDataView.SetSortMode(this.m_itemGridDataView.GetSortMode());
  }

  protected cb func OnItemFilterHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let widget: ref<inkWidget> = evt.GetCurrentTarget();
    let controller: ref<BackpackFilterButtonController> = widget.GetController() as BackpackFilterButtonController;
    let tooltipData: ref<MessageTooltipData> = new MessageTooltipData();
    tooltipData.Title = NameToString(controller.GetLabelKey());
    this.m_TooltipsManager.ShowTooltipAtWidget(0, evt.GetTarget(), tooltipData, gameuiETooltipPlacement.RightTop, true);
  }

  protected cb func OnItemFilterHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_TooltipsManager.HideTooltips();
  }

  private final func IsEquipmentAreaWeapon(equipmentAreas: array<gamedataEquipmentArea>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(equipmentAreas) {
      if this.IsEquipmentAreaWeapon(equipmentAreas[i]) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func IsEquipmentAreaWeapon(equipmentArea: gamedataEquipmentArea) -> Bool {
    return Equals(equipmentArea, gamedataEquipmentArea.Weapon);
  }

  private final func IsEquipmentAreaClothing(equipmentAreas: array<gamedataEquipmentArea>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(equipmentAreas) {
      if this.IsEquipmentAreaClothing(equipmentAreas[i]) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func IsEquipmentAreaClothing(equipmentArea: gamedataEquipmentArea) -> Bool {
    return Equals(equipmentArea, gamedataEquipmentArea.Head) || Equals(equipmentArea, gamedataEquipmentArea.Face) || Equals(equipmentArea, gamedataEquipmentArea.OuterChest) || Equals(equipmentArea, gamedataEquipmentArea.InnerChest) || Equals(equipmentArea, gamedataEquipmentArea.Legs) || Equals(equipmentArea, gamedataEquipmentArea.Feet);
  }

  public final func UpdateDisplayedItems(itemID: ItemID) -> Void {
    let doRefresh: Bool;
    let i: Int32;
    let itemEquipArea: gamedataEquipmentArea;
    let itemViewMode: ItemViewModes;
    let scopes: array<gamedataItemType>;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    let selectedSlot: TweakDBID = this.itemChooser.GetSelectedSlotID();
    if IsDefined(itemRecord) {
      itemViewMode = ItemViewModes.Mod;
      if !TDBID.IsValid(selectedSlot) || selectedSlot == TDBID.undefined() {
        itemViewMode = ItemViewModes.Item;
      };
      if Equals(this.m_currentHotkey, EHotkey.INVALID) {
        if TDBID.IsValid(this.itemChooser.GetSelectedSlotID()) {
          if itemRecord.TagsContains(n"itemPart") || itemRecord.TagsContains(n"Fragment") || itemRecord.TagsContains(n"SoftwareShard") {
            doRefresh = true;
          };
        };
        itemEquipArea = itemRecord.EquipArea().Type();
        i = 0;
        while i < ArraySize(this.m_lastEquipmentAreas) {
          if Equals(this.m_lastEquipmentAreas[i], itemEquipArea) {
            doRefresh = true;
          };
          i += 1;
        };
      } else {
        scopes = Hotkey.GetScope(this.m_currentHotkey);
        if ArrayContains(scopes, itemRecord.ItemType().Type()) {
          doRefresh = true;
        };
      };
    };
    if doRefresh {
      this.m_InventoryManager.MarkToRebuild();
      this.RefreshAvailableItems(itemViewMode);
    };
  }

  private final func RefreshAvailableItems(opt viewMode: ItemViewModes) -> Void {
    let itemsToSkip: array<ItemID>;
    if Equals(this.m_currentHotkey, EHotkey.INVALID) {
      this.UpdateAvailableItems(viewMode, this.m_lastEquipmentAreas);
    } else {
      ArrayPush(itemsToSkip, this.m_equipmentSystem.GetPlayerData(this.m_player).GetItemIDFromHotkey(this.m_currentHotkey));
      this.UpdateAvailableHotykeyItems(this.m_currentHotkey, itemsToSkip);
    };
  }

  private final func UpdateAvailableHotykeyItems(hotkey: EHotkey, opt itemsToSkip: array<ItemID>) -> Void {
    let currentItemID: ItemID;
    let freshItems: array<InventoryItemData>;
    let itemType: gamedataItemType;
    let k: Int32;
    let totalItems: array<InventoryItemData>;
    let slotTypes: array<gamedataItemType> = Hotkey.GetScope(hotkey);
    let i: Int32 = 0;
    while i < ArraySize(slotTypes) {
      freshItems = this.m_InventoryManager.GetPlayerItemsByType(slotTypes[i], this.m_itemDropQueue);
      k = 0;
      while k < ArraySize(freshItems) {
        currentItemID = InventoryItemData.GetID(freshItems[k]);
        if !ItemID.IsValid(currentItemID) || ArrayContains(totalItems, freshItems[k]) {
        } else {
          if ArrayContains(itemsToSkip, currentItemID) {
          } else {
            itemType = this.m_transactionSystem.GetItemData(this.m_player, currentItemID).GetItemType();
            if Equals(itemType, gamedataItemType.Cyb_Ability) || Equals(itemType, gamedataItemType.Cyb_Launcher) {
              if !this.m_equipmentSystem.IsEquipped(this.m_player, currentItemID) {
              } else {
                ArrayPush(totalItems, freshItems[k]);
              };
            };
            ArrayPush(totalItems, freshItems[k]);
          };
        };
        k += 1;
      };
      i += 1;
    };
    this.UpdateAvailableItemsGrid(totalItems);
  }

  private final func UpdateAvailableItems(viewMode: ItemViewModes, equipmentAreas: array<gamedataEquipmentArea>) -> Void {
    let attachments: array<InventoryItemAttachments>;
    let attachmentsToCheck: array<TweakDBID>;
    let availableItems: array<InventoryItemData>;
    let i: Int32;
    let modifiedItemData: wref<gameItemData>;
    let targetFilter: Int32;
    let isWeapon: Bool = this.IsEquipmentAreaWeapon(equipmentAreas);
    let isClothing: Bool = this.IsEquipmentAreaClothing(equipmentAreas);
    if isWeapon || isClothing {
      this.m_InventoryManager.GetPlayerInventoryDataRef(equipmentAreas, true, this.m_itemDropQueue, availableItems);
      attachments = InventoryItemData.GetAttachments(this.itemChooser.GetModifiedItemData());
      if TDBID.IsValid(this.itemChooser.GetSelectedSlotID()) {
        ArrayPush(attachmentsToCheck, this.itemChooser.GetSelectedSlotID());
      } else {
        i = 0;
        while i < ArraySize(attachments) {
          if Equals(attachments[i].SlotType, InventoryItemAttachmentType.Generic) {
            ArrayPush(attachmentsToCheck, attachments[i].SlotID);
          };
          i += 1;
        };
      };
      this.m_InventoryManager.GetPlayerInventoryPartsForItemRef(this.itemChooser.GetModifiedItemID(), attachmentsToCheck, availableItems);
    } else {
      if Equals(viewMode, ItemViewModes.Mod) {
        availableItems = this.m_InventoryManager.GetPlayerInventoryPartsForItem((this.itemChooser as InventoryCyberwareItemChooser).GetModifiedItemID(), this.itemChooser.GetSelectedItem().GetSlotID());
      } else {
        this.m_InventoryManager.GetPlayerInventoryDataRef(equipmentAreas, true, this.m_itemDropQueue, availableItems);
      };
    };
    this.UpdateAvailableItemsGrid(availableItems);
    this.CreateFilterButtons(this.m_itemGridContainerController.GetFiltersGrid());
    if (isWeapon || isClothing) && this.m_lastSelectedDisplay != this.itemChooser.GetSelectedItem() {
      this.m_lastSelectedDisplay = this.itemChooser.GetSelectedItem();
      if Equals(viewMode, ItemViewModes.Mod) && this.GetFilterButtonIndex(ItemFilterCategory.Attachments) >= 0 {
        this.SelectFilterButton(ItemFilterCategory.Attachments);
      } else {
        targetFilter = 0;
        if isWeapon {
          modifiedItemData = InventoryItemData.GetGameItemData(this.itemChooser.GetModifiedItemData());
          if ItemCategoryFliter.IsOfCategoryType(ItemFilterCategory.RangedWeapons, modifiedItemData) {
            targetFilter = this.GetFilterButtonIndex(ItemFilterCategory.RangedWeapons);
          } else {
            if ItemCategoryFliter.IsOfCategoryType(ItemFilterCategory.MeleeWeapons, modifiedItemData) {
              targetFilter = this.GetFilterButtonIndex(ItemFilterCategory.MeleeWeapons);
            };
          };
        } else {
          if isClothing {
            targetFilter = this.GetFilterButtonIndex(ItemFilterCategory.Clothes);
          };
        };
        this.SelectFilterButtonByIndex(targetFilter);
      };
    };
  }

  private final func UpdateAvailableItemsGrid(availableItems: script_ref<array<InventoryItemData>>) -> Void {
    let data: ref<WrappedInventoryItemData>;
    let i: Int32;
    let itemChooserItem: InventoryItemData;
    let virtualWrappedData: array<ref<IScriptable>>;
    inkWidgetRef.SetVisible(this.m_emptyInventoryText, ArraySize(Deref(availableItems)) <= 0);
    this.m_cyberwareGridContainerController.GetItemsWidget() as inkCompoundWidget.RemoveAllChildren();
    inkWidgetRef.SetVisible(this.m_itemGridContainer, true);
    inkWidgetRef.SetVisible(this.m_cyberwareGridContainer, false);
    itemChooserItem = this.itemChooser.GetSelectedItem().GetItemData();
    if InventoryItemData.IsEmpty(itemChooserItem) {
      this.m_comparisonResolver.DisableForceComparedItem();
    } else {
      this.m_comparisonResolver.ForceComparedItem(itemChooserItem);
    };
    i = 0;
    while i < ArraySize(Deref(availableItems)) {
      data = new WrappedInventoryItemData();
      data.ItemData = Deref(availableItems)[i];
      data.ItemTemplate = Equals(InventoryItemData.GetEquipmentArea(data.ItemData), gamedataEquipmentArea.Weapon) ? 1u : 0u;
      data.ComparisonState = this.m_comparisonResolver.GetItemComparisonState(data.ItemData);
      data.IsNew = this.m_uiScriptableSystem.IsInventoryItemNew(InventoryItemData.GetID(Deref(availableItems)[i]));
      InventoryItemData.SetGameItemData(data.ItemData, this.m_InventoryManager.GetPlayerItemData(InventoryItemData.GetID(Deref(availableItems)[i])));
      if Equals(this.m_currentHotkey, EHotkey.INVALID) {
        data.DisplayContext = ItemDisplayContext.Backpack;
      };
      ArrayPush(virtualWrappedData, data);
      this.m_filterManager.AddItem(InventoryItemData.GetGameItemData(data.ItemData));
      i += 1;
    };
    this.m_itemGridDataSource.Reset(virtualWrappedData);
  }

  private final func UnequipItem(controller: ref<InventoryItemDisplayController>, itemData: InventoryItemData) -> Void {
    this.m_InventoryManager.UnequipItem(controller.GetEquipmentArea(), controller.GetSlotIndex());
  }

  private final func UninstallMod(itemID: ItemID, slotID: TweakDBID) -> Void {
    let removePartRequest: ref<RemoveItemPart> = new RemoveItemPart();
    removePartRequest.obj = this.m_player;
    removePartRequest.baseItem = itemID;
    removePartRequest.slotToEmpty = slotID;
    GameInstance.GetScriptableSystemsContainer(this.m_player.GetGame()).Get(n"ItemModificationSystem").QueueRequest(removePartRequest);
  }

  private final func EquipPart(itemData: InventoryItemData, slotID: TweakDBID) -> Void {
    let isPartEquipped: Bool;
    let isReplaceableType: Bool;
    let modItemType: gamedataItemType;
    let equippedItemData: InventoryItemData = this.itemChooser.GetModifiedItemData();
    let localEquippedData: wref<gameItemData> = InventoryItemData.GetGameItemData(equippedItemData);
    if this.m_InventoryManager.CanInstallPart(itemData) {
      modItemType = InventoryItemData.GetItemType(itemData);
      isPartEquipped = localEquippedData.HasPartInSlot(slotID);
      isReplaceableType = Equals(modItemType, gamedataItemType.Prt_FabricEnhancer) || Equals(modItemType, gamedataItemType.Prt_Mod);
      if isPartEquipped && isReplaceableType {
        this.m_installModData = new InstallModConfirmationData();
        this.m_installModData.itemId = InventoryItemData.GetID(equippedItemData);
        this.m_installModData.partId = InventoryItemData.GetID(itemData);
        this.m_installModData.slotID = slotID;
        this.m_installModData.telemetryItemData = ToTelemetryInventoryItem(equippedItemData);
        this.m_installModData.telemetryPartData = ToTelemetryInventoryItem(itemData);
        this.m_replaceModNotification = GenericMessageNotification.Show(this.m_inventoryController, "Gameplay-Scanning-NPC-Warning", "UI-Notifications-ReplaceMod", GenericMessageNotificationType.YesNo);
        this.m_replaceModNotification.RegisterListener(this, n"OnReplaceModNotificationClosed");
      } else {
        this.m_InventoryManager.InstallPart(InventoryItemData.GetID(equippedItemData), InventoryItemData.GetID(itemData), slotID);
        this.TelemetryLogPartInstalled(equippedItemData, itemData, slotID);
        this.SetPingTutorialFact(InventoryItemData.GetID(itemData), false);
      };
    };
  }

  private final func SetPingTutorialFact(itemID: ItemID, isUnequip: Bool) -> Void {
    let questSystem: ref<QuestsSystem>;
    let shard: CName = TweakDBInterface.GetCName(ItemID.GetTDBID(itemID) + t".shardType", n"");
    if Equals(shard, n"Ping") {
      questSystem = GameInstance.GetQuestsSystem(this.m_player.GetGame());
      if isUnequip && questSystem.GetFact(n"ping_installed") == 1 {
        questSystem.SetFact(n"ping_installed", 0);
      } else {
        if questSystem.GetFact(n"ping_installed") == 0 {
          questSystem.SetFact(n"ping_installed", 1);
        };
      };
    };
  }

  private final func TelemetryLogPartInstalled(modifiedItem: InventoryItemData, itemPart: InventoryItemData, slotID: TweakDBID) -> Void {
    this.TelemetryLogPartInstalled(ToTelemetryInventoryItem(modifiedItem), ToTelemetryInventoryItem(itemPart), slotID);
  }

  private final func TelemetryLogPartInstalled(modifiedItem: TelemetryInventoryItem, itemPart: TelemetryInventoryItem, slotID: TweakDBID) -> Void {
    let telemetrySystem: wref<TelemetrySystem> = GameInstance.GetTelemetrySystem(this.m_player.GetGame());
    if IsDefined(telemetrySystem) {
      telemetrySystem.LogPartInstalled(modifiedItem, itemPart, slotID);
    };
  }

  protected cb func OnReplaceModNotificationClosed(data: ref<inkGameNotificationData>) -> Bool {
    let closeData: ref<GenericMessageNotificationCloseData> = data as GenericMessageNotificationCloseData;
    this.m_replaceModNotification = null;
    if IsDefined(closeData) && Equals(closeData.result, GenericMessageNotificationResult.Yes) {
      this.m_InventoryManager.InstallPart(this.m_installModData.itemId, this.m_installModData.partId, this.m_installModData.slotID);
      this.TelemetryLogPartInstalled(this.m_installModData.telemetryItemData, this.m_installModData.telemetryPartData, this.m_installModData.slotID);
    };
    this.m_installModData = null;
  }

  private final func GetMatchingSlot(itemData: InventoryItemData, partItemData: InventoryItemData) -> TweakDBID {
    let availableSlots: array<TweakDBID>;
    let firstMatching: TweakDBID;
    let i: Int32;
    let j: Int32;
    let attachments: array<InventoryItemAttachments> = InventoryItemData.GetAttachments(itemData);
    let partType: gamedataItemType = InventoryItemData.GetItemType(partItemData);
    if Equals(partType, gamedataItemType.Prt_Scope) {
      i = 0;
      while i < ArraySize(attachments) {
        if attachments[i].SlotID == t"AttachmentSlots.Scope" {
          return t"AttachmentSlots.Scope";
        };
        i += 1;
      };
    } else {
      if Equals(partType, gamedataItemType.Prt_Muzzle) {
        i = 0;
        while i < ArraySize(attachments) {
          if attachments[i].SlotID == t"AttachmentSlots.PowerModule" {
            return t"AttachmentSlots.PowerModule";
          };
          i += 1;
        };
      } else {
        if Equals(partType, gamedataItemType.Prt_Mod) || Equals(partType, gamedataItemType.Prt_FabricEnhancer) {
          availableSlots = RPGManager.GetModsSlotIDs(InventoryItemData.GetItemType(itemData));
          firstMatching = TDBID.undefined();
          i = 0;
          while i < ArraySize(availableSlots) {
            j = 0;
            while j < ArraySize(attachments) {
              if attachments[j].SlotID == availableSlots[i] {
                if !TDBID.IsValid(firstMatching) {
                  firstMatching = attachments[j].SlotID;
                };
                if InventoryItemData.IsEmpty(attachments[j].ItemData) {
                  return attachments[j].SlotID;
                };
              };
              j += 1;
            };
            i += 1;
          };
          if TDBID.IsValid(firstMatching) {
            return firstMatching;
          };
        };
      };
    };
    return TDBID.undefined();
  }

  private final func IsMatchingSlot(itemData: InventoryItemData, partItemData: InventoryItemData, targetSlot: TweakDBID) -> Bool {
    let hasTargetSlot: Bool;
    let validSlots: array<TweakDBID>;
    let attachments: array<InventoryItemAttachments> = InventoryItemData.GetAttachments(itemData);
    let partType: gamedataItemType = InventoryItemData.GetItemType(partItemData);
    let i: Int32 = 0;
    while i < ArraySize(attachments) {
      if attachments[i].SlotID == targetSlot {
        hasTargetSlot = true;
      };
      i += 1;
    };
    if !hasTargetSlot {
      return false;
    };
    if Equals(partType, gamedataItemType.Prt_Scope) {
      if targetSlot != t"AttachmentSlots.Scope" {
        return false;
      };
    } else {
      if Equals(partType, gamedataItemType.Prt_Muzzle) {
        if targetSlot != t"AttachmentSlots.PowerModule" {
          return false;
        };
      } else {
        if Equals(partType, gamedataItemType.Prt_Mod) || Equals(partType, gamedataItemType.Prt_FabricEnhancer) {
          validSlots = RPGManager.GetModsSlotIDs(InventoryItemData.GetItemType(itemData));
          if !ArrayContains(validSlots, targetSlot) {
            return false;
          };
        };
      };
    };
    return true;
  }

  private final func EquipItem(itemData: InventoryItemData, slotIndex: Int32) -> Void {
    let hotkey: EHotkey;
    let slot: TweakDBID;
    if InventoryItemData.IsPart(itemData) {
      slot = this.itemChooser.GetSelectedSlotID();
      if TDBID.IsValid(slot) && !this.IsMatchingSlot(this.itemChooser.GetModifiedItemData(), itemData, slot) {
        slot = TDBID.undefined();
      };
      if !TDBID.IsValid(slot) {
        slot = this.GetMatchingSlot(this.itemChooser.GetModifiedItemData(), itemData);
      };
      this.EquipPart(itemData, slot);
      this.PlaySound(n"Item", n"OnBuy");
      return;
    };
    this.m_InventoryManager.GetHotkeyTypeForItemID(InventoryItemData.GetID(itemData), hotkey);
    if InventoryItemData.IsEquipped(itemData) && Equals(hotkey, EHotkey.INVALID) {
      return;
    };
    if NotEquals(hotkey, EHotkey.INVALID) {
      this.m_equipmentSystem.GetPlayerData(this.m_player).AssignItemToHotkey(InventoryItemData.GetID(itemData), hotkey);
      this.RefreshAvailableItems();
      this.NotifyItemUpdate();
      return;
    };
    if !InventoryItemData.IsEmpty(itemData) {
      this.m_InventoryManager.EquipItem(InventoryItemData.GetID(itemData), slotIndex);
      this.PlaySound(n"Item", n"OnBuy");
    };
  }

  private final func NotifyItemUpdate() -> Void {
    let itemChangedEvent: ref<ItemModeItemChanged> = new ItemModeItemChanged();
    let equipmentArea: gamedataEquipmentArea = this.itemChooser.GetEquipmentArea();
    if Equals(this.m_currentHotkey, EHotkey.DPAD_UP) {
      equipmentArea = gamedataEquipmentArea.Consumable;
    } else {
      if Equals(this.m_currentHotkey, EHotkey.RB) {
        equipmentArea = gamedataEquipmentArea.QuickSlot;
      };
    };
    itemChangedEvent.equipmentArea = equipmentArea;
    itemChangedEvent.slotIndex = this.itemChooser.GetSlotIndex();
    itemChangedEvent.hotkey = this.m_currentHotkey;
    this.QueueEvent(itemChangedEvent);
  }

  protected cb func OnItemChooserUnequipMod(ev: ref<ItemChooserUnequipMod>) -> Bool {
    let modifiedItem: InventoryItemData = this.itemChooser.GetModifiedItemData();
    if !InventoryItemData.IsEmpty(modifiedItem) && (RPGManager.CanPartBeUnequipped(InventoryItemData.GetID(this.itemChooser.GetSelectedItem().GetItemData())) || Equals(InventoryItemData.GetEquipmentArea(modifiedItem), gamedataEquipmentArea.SystemReplacementCW)) {
      this.UninstallMod(InventoryItemData.GetID(modifiedItem), ev.slotID);
    };
  }

  private final func IsUnequipBlocked(itemID: ItemID) -> Bool {
    let itemData: wref<gameItemData> = RPGManager.GetItemData(this.m_player.GetGame(), this.m_player, itemID);
    return IsDefined(itemData) && itemData.HasTag(n"UnequipBlocked");
  }

  protected cb func OnItemChooserUnequipItem(evt: ref<ItemChooserUnequipItem>) -> Bool {
    let equipedItem: InventoryItemData = this.itemChooser.GetModifiedItemData();
    if !InventoryGPRestrictionHelper.CanEquip(equipedItem, this.m_player) || this.IsUnequipBlocked(InventoryItemData.GetID(equipedItem)) {
      this.ShowNotification(this.m_player.GetGame(), UIMenuNotificationType.InventoryActionBlocked);
      return false;
    };
    if NotEquals(this.m_currentHotkey, EHotkey.INVALID) {
      this.m_equipmentSystem.GetPlayerData(this.m_player).ClearItemFromHotkey(this.m_currentHotkey);
      this.RefreshAvailableItems();
      this.NotifyItemUpdate();
      this.itemChooser.RefreshItems();
    } else {
      this.UnequipItem(this.itemChooser.GetModifiedItem(), equipedItem);
    };
  }

  protected cb func OnItemChooserItemHoverOver(evt: ref<ItemChooserItemHoverOver>) -> Bool {
    let slotName: String;
    let itemData: InventoryItemData = evt.targetItem.GetItemData();
    if !InventoryItemData.IsEmpty(itemData) {
      this.SetInventoryItemButtonHintsHoverOver(itemData);
    } else {
      slotName = GetLocalizedText(evt.targetItem.GetSlotName());
      if Equals(evt.targetItem.GetDisplayContext(), ItemDisplayContext.Attachment) && evt.targetItem.GetNewItems() == 0 {
        slotName = GetLocalizedText(slotName);
        slotName += "\\n";
        slotName += GetLocalizedText("UI-Tooltips-NoModsAvailable");
      };
      this.m_TooltipsManager.ShowTooltipAtWidget(0, evt.sourceEvent.GetTarget(), this.m_InventoryManager.GetTooltipForEmptySlot(slotName), gameuiETooltipPlacement.RightTop, true);
    };
  }

  protected cb func OnItemChooserItemHoverOut(evt: ref<ItemChooserItemHoverOut>) -> Bool {
    this.SetInventoryItemButtonHintsHoverOut();
  }

  private final func InvalidateItemTooltipEvent() -> Void {
    if this.m_lastItemHoverOverEvent != null {
      this.OnItemDisplayHoverOver(this.m_lastItemHoverOverEvent);
    };
  }

  protected cb func OnItemDisplayHoverOver(evt: ref<ItemDisplayHoverOverEvent>) -> Bool {
    this.m_lastItemHoverOverEvent = evt;
    let skipCompare: Bool = !this.m_isShown || Equals(evt.display.GetDisplayContext(), ItemDisplayContext.Attachment) || this.m_isComparisionDisabled;
    this.HandleItemHoverOver(evt.itemData, evt.widget, evt.display.DEBUG_GetIconErrorInfo(), skipCompare, evt.display);
    if InventoryItemData.IsEmpty(evt.itemData) && TDBID.IsValid(evt.display.GetSlotID()) {
      this.m_buttonHintsController.AddButtonHint(n"select", GetLocalizedText("UI-UserActions-Select"));
    };
  }

  protected cb func OnItemDisplayHoverOut(evt: ref<ItemDisplayHoverOutEvent>) -> Bool {
    this.HandleItemHoverOut();
    this.m_lastItemHoverOverEvent = null;
  }

  protected cb func OnInventoryItemHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let controller: ref<InventoryItemDisplayController> = this.GetInventoryItemDisplayControllerFromTarget(evt);
    this.HandleItemHoverOver(controller.GetItemData(), evt.GetTarget(), controller.DEBUG_GetIconErrorInfo());
  }

  private final func RequestItemInspected(itemID: ItemID) -> Void {
    let request: ref<UIScriptableSystemInventoryInspectItem> = new UIScriptableSystemInventoryInspectItem();
    request.itemID = itemID;
    this.m_uiScriptableSystem.QueueRequest(request);
  }

  protected cb func OnInventoryItemHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.HandleItemHoverOut();
  }

  private final func HandleItemHoverOver(itemData: InventoryItemData, target: wref<inkWidget>, iconErrorInfo: ref<DEBUG_IconErrorInfo>, opt skipCompare: Bool, opt display: ref<InventoryItemDisplayController>) -> Void {
    this.SetInventoryItemTooltipHoverOver(itemData, target, skipCompare, iconErrorInfo, display);
    this.SetInventoryItemButtonHintsHoverOver(itemData, display);
    if !InventoryItemData.IsEmpty(itemData) {
      this.RequestItemInspected(InventoryItemData.GetID(itemData));
    };
  }

  private final func HandleItemHoverOut() -> Void {
    this.HideTooltips();
    this.SetInventoryItemButtonHintsHoverOut();
  }

  protected cb func OnItemDisplayClick(evt: ref<ItemDisplayClickEvent>) -> Bool {
    if this.HACK_lastItemDisplayEvent != evt {
      this.HandleItemClick(evt.itemData, evt.actionName, evt.displayContext);
    };
    this.HACK_lastItemDisplayEvent = evt;
  }

  private final func ShowNotification(gameInstance: GameInstance, type: UIMenuNotificationType) -> Void {
    let inventoryNotification: ref<UIMenuNotificationEvent> = new UIMenuNotificationEvent();
    inventoryNotification.m_notificationType = type;
    GameInstance.GetUISystem(gameInstance).QueueEvent(inventoryNotification);
  }

  private final func HandleItemClick(itemData: InventoryItemData, actionName: ref<inkActionName>, opt displayContext: ItemDisplayContext) -> Void {
    let isEquippedItemBlocked: Bool;
    let item: ItemModParams;
    if actionName.IsAction(n"drop_item") {
      if !InventoryItemData.IsEquipped(itemData) && RPGManager.CanItemBeDropped(this.m_player, InventoryItemData.GetGameItemData(itemData)) {
        if InventoryItemData.GetQuantity(itemData) > 1 {
          this.OpenQuantityPicker(itemData, QuantityPickerActionType.Drop);
        } else {
          item.itemID = InventoryItemData.GetID(itemData);
          item.quantity = 1;
          this.AddToDropQueue(item);
          this.RefreshAvailableItems();
          this.PlaySound(n"Item", n"OnDrop");
        };
      };
    } else {
      if NotEquals(displayContext, ItemDisplayContext.Attachment) && (actionName.IsAction(n"equip_item") || actionName.IsAction(n"click")) && !(InventoryItemData.IsEquipped(itemData) && Equals(this.m_currentHotkey, EHotkey.INVALID)) {
        isEquippedItemBlocked = InventoryItemData.GetGameItemData(this.itemChooser.GetModifiedItemData()).HasTag(n"UnequipBlocked");
        if !InventoryGPRestrictionHelper.CanEquip(itemData, this.m_player) || isEquippedItemBlocked {
          this.ShowNotification(this.m_player.GetGame(), this.DetermineUIMenuNotificationType());
          return;
        };
        this.EquipItem(itemData, this.itemChooser.GetSlotIndex());
        this.itemChooser.RefreshItems();
        this.RefreshAvailableItems();
        this.NotifyItemUpdate();
      };
    };
  }

  public final func OpenQuantityPicker(itemData: InventoryItemData, action: QuantityPickerActionType) -> Void {
    let request: ref<OpenInventoryQuantityPickerRequest> = new OpenInventoryQuantityPickerRequest();
    request.itemData = itemData;
    request.actionType = action;
    this.QueueEvent(request);
  }

  public final func OnQuantityPickerPopupClosed(data: ref<QuantityPickerPopupCloseData>) -> Void {
    if data.choosenQuantity != -1 {
      switch data.actionType {
        case QuantityPickerActionType.Drop:
          this.OnQuantityPickerDrop(data);
          break;
        case QuantityPickerActionType.Disassembly:
          this.OnQuantityPickerDisassembly(data);
      };
    };
  }

  public final func OnQuantityPickerDrop(data: ref<QuantityPickerPopupCloseData>) -> Void {
    let item: ItemModParams;
    item.itemID = InventoryItemData.GetID(data.itemData);
    item.quantity = data.choosenQuantity;
    this.AddToDropQueue(item);
    this.RefreshAvailableItems();
    this.PlaySound(n"Item", n"OnDrop");
  }

  public final func OnQuantityPickerDisassembly(data: ref<QuantityPickerPopupCloseData>) -> Void {
    ItemActionsHelper.DisassembleItem(this.m_player, InventoryItemData.GetID(data.itemData), data.choosenQuantity);
    this.PlaySound(n"Item", n"OnDisassemble");
  }

  protected final func AddToDropQueue(item: ItemModParams) -> Void {
    let evt: ref<DropQueueUpdatedEvent>;
    let merged: Bool;
    let i: Int32 = 0;
    while i < ArraySize(this.m_itemDropQueue) {
      if this.m_itemDropQueue[i].itemID == item.itemID {
        this.m_itemDropQueue[i].quantity += item.quantity;
        merged = true;
      } else {
        i += 1;
      };
    };
    if !merged {
      ArrayPush(this.m_itemDropQueue, item);
    };
    evt = new DropQueueUpdatedEvent();
    evt.m_dropQueue = this.m_itemDropQueue;
    this.QueueEvent(evt);
  }

  protected cb func OnItemDisplayHold(evt: ref<ItemDisplayHoldEvent>) -> Bool {
    this.HandleItemHold(evt.itemData, evt.actionName);
  }

  protected cb func OnItemInventoryHold(evt: ref<inkPointerEvent>) -> Bool {
    let controller: wref<InventoryItemDisplayController> = this.GetInventoryItemDisplayControllerFromTarget(evt);
    let progress: Float = evt.GetHoldProgress();
    if progress >= 1.00 {
      this.HandleItemHold(controller.GetItemData(), evt.GetActionName());
    };
  }

  private final func HandleItemHold(itemData: InventoryItemData, actionName: ref<inkActionName>) -> Void {
    if actionName.IsAction(n"disassemble_item") && !this.m_isE3Demo && RPGManager.CanItemBeDisassembled(this.m_player.GetGame(), InventoryItemData.GetGameItemData(itemData)) {
      if InventoryItemData.GetQuantity(itemData) > 1 {
        this.OpenQuantityPicker(itemData, QuantityPickerActionType.Disassembly);
      } else {
        ItemActionsHelper.DisassembleItem(this.m_player, InventoryItemData.GetID(itemData));
        this.PlaySound(n"Item", n"OnDisassemble");
      };
    } else {
      if actionName.IsAction(n"use_item") {
        if !InventoryGPRestrictionHelper.CanUse(itemData, this.m_player) {
          this.ShowNotification(this.m_player.GetGame(), this.DetermineUIMenuNotificationType());
          return;
        };
        ItemActionsHelper.PerformItemAction(this.m_player, InventoryItemData.GetID(itemData));
        this.m_InventoryManager.MarkToRebuild();
      };
    };
  }

  private final func DetermineUIMenuNotificationType() -> UIMenuNotificationType {
    let inCombat: Bool = false;
    let psmBlackboard: ref<IBlackboard> = this.m_player.GetPlayerStateMachineBlackboard();
    inCombat = psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat);
    if inCombat {
      return UIMenuNotificationType.InCombat;
    };
    return UIMenuNotificationType.InventoryActionBlocked;
  }

  private final func SetInventoryItemTooltipHoverOver(itemData: InventoryItemData, target: wref<inkWidget>, skipCompare: Bool, iconErrorInfo: ref<DEBUG_IconErrorInfo>, opt display: ref<InventoryItemDisplayController>) -> Void {
    let equippedItem: InventoryItemData;
    if !InventoryItemData.IsEmpty(itemData) {
      equippedItem = this.itemChooser.GetSelectedItem().GetItemData();
      this.ShowTooltipsForItemData(equippedItem, target, itemData, skipCompare, iconErrorInfo, display);
    };
  }

  private final func ShowTooltipsForItemData(equippedItem: InventoryItemData, target: wref<inkWidget>, inspectedItemData: InventoryItemData, skipCompare: Bool, iconErrorInfo: ref<DEBUG_IconErrorInfo>, opt display: ref<InventoryItemDisplayController>) -> Void {
    let canCompareItems: Bool;
    let comparableProgram: InventoryItemAttachments;
    let equippedData: ref<InventoryTooltipData>;
    let identifiedTooltip: ref<IdentifiedWrappedTooltipData>;
    let inspectedShardType: CName;
    let tooltipData: ref<InventoryTooltipData>;
    let tooltipsData: array<ref<ATooltipData>>;
    this.HideTooltips();
    canCompareItems = this.m_comparisonResolver.IsTypeComparable(equippedItem, InventoryItemData.GetItemType(inspectedItemData));
    if InventoryItemData.IsEmpty(equippedItem) && !skipCompare {
      equippedItem = this.m_comparisonResolver.GetPreferredComparisonItem(inspectedItemData);
      if !InventoryItemData.IsEmpty(equippedItem) {
        this.m_InventoryManager.PushIdentifiedComparisonTooltipsData(tooltipsData, n"itemTooltip", n"itemTooltipComparision", equippedItem, inspectedItemData, iconErrorInfo);
        this.m_TooltipsManager.ShowTooltipsAtWidget(tooltipsData, target);
      } else {
        if Equals(InventoryItemData.GetItemType(inspectedItemData), gamedataItemType.Prt_Program) {
          inspectedShardType = TweakDBInterface.GetCName(ItemID.GetTDBID(InventoryItemData.GetID(inspectedItemData)) + t".shardType", n"");
          comparableProgram = this.GetProgramByShardType(InventoryItemData.GetAttachments(this.itemChooser.GetModifiedItemData()), inspectedShardType);
          if TDBID.IsValid(comparableProgram.SlotID) {
            this.m_InventoryManager.PushIdentifiedProgramComparisionTooltipsData(tooltipsData, comparableProgram.ItemData, inspectedItemData, iconErrorInfo, false);
            this.m_TooltipsManager.ShowTooltipsAtWidget(tooltipsData, target);
          } else {
            this.m_TooltipsManager.ShowTooltipAtWidget(n"programTooltip", target, this.m_InventoryManager.GetTooltipDataForInventoryItem(inspectedItemData, false, iconErrorInfo, true), gameuiETooltipPlacement.RightTop, true);
          };
        } else {
          if InventoryItemData.GetGameItemData(inspectedItemData).HasTag(n"Cyberdeck") {
            this.m_TooltipsManager.ShowTooltipAtWidget(n"cyberdeckTooltip", target, this.m_InventoryManager.GetTooltipDataForInventoryItem(inspectedItemData, false, iconErrorInfo, true), gameuiETooltipPlacement.RightTop, true);
          } else {
            this.m_TooltipsManager.ShowTooltipAtWidget(n"itemTooltip", target, this.m_InventoryManager.GetTooltipDataForInventoryItem(inspectedItemData, false, iconErrorInfo, true), gameuiETooltipPlacement.RightTop, true);
          };
        };
      };
    } else {
      if !InventoryItemData.IsEmpty(equippedItem) && InventoryItemData.GetID(equippedItem) != InventoryItemData.GetID(inspectedItemData) && canCompareItems && !skipCompare {
        identifiedTooltip = new IdentifiedWrappedTooltipData();
        identifiedTooltip.m_identifier = n"itemTooltip";
        identifiedTooltip.m_data = this.m_InventoryManager.GetComparisonTooltipsData(equippedItem, inspectedItemData, false, iconErrorInfo, true);
        ArrayPush(tooltipsData, identifiedTooltip);
        equippedData = this.m_InventoryManager.GetComparisonTooltipsData(inspectedItemData, equippedItem, true, true);
        if InventoryDataManagerV2.IsAttachmentType(InventoryItemData.GetItemType(equippedItem)) {
          equippedData.displayContext = InventoryTooltipDisplayContext.Attachment;
          equippedData.parentItemData = InventoryItemData.GetGameItemData(this.itemChooser.GetModifiedItemData());
          equippedData.slotID = InventoryDataManagerV2.GetAttachmentSlotByItemID(this.itemChooser.GetModifiedItemData(), InventoryItemData.GetID(equippedItem));
        };
        identifiedTooltip = new IdentifiedWrappedTooltipData();
        identifiedTooltip.m_identifier = n"itemTooltipComparision";
        identifiedTooltip.m_data = equippedData;
        ArrayPush(tooltipsData, identifiedTooltip);
        this.m_TooltipsManager.ShowTooltipsAtWidget(tooltipsData, target);
      } else {
        if Equals(InventoryItemData.GetItemType(inspectedItemData), gamedataItemType.Prt_Program) {
          tooltipData = this.m_InventoryManager.GetTooltipDataForInventoryItem(inspectedItemData, false, iconErrorInfo, true);
          if IsDefined(display) && Equals(display.GetDisplayContext(), ItemDisplayContext.Attachment) {
            tooltipData.displayContext = InventoryTooltipDisplayContext.Attachment;
            tooltipData.parentItemData = display.GetParentItemData();
            tooltipData.slotID = display.GetSlotID();
          };
          this.m_TooltipsManager.ShowTooltipAtWidget(n"programTooltip", target, tooltipData, gameuiETooltipPlacement.RightTop, true);
        } else {
          if Equals(InventoryItemData.GetEquipmentArea(inspectedItemData), gamedataEquipmentArea.SystemReplacementCW) {
            this.m_TooltipsManager.ShowTooltipAtWidget(n"cyberdeckTooltip", target, this.m_InventoryManager.GetTooltipDataForInventoryItem(inspectedItemData, false, iconErrorInfo, true), gameuiETooltipPlacement.RightTop, true);
          } else {
            tooltipData = this.m_InventoryManager.GetTooltipDataForInventoryItem(inspectedItemData, false, iconErrorInfo, true);
            if IsDefined(display) && Equals(display.GetDisplayContext(), ItemDisplayContext.Attachment) {
              tooltipData.displayContext = InventoryTooltipDisplayContext.Attachment;
              tooltipData.parentItemData = display.GetParentItemData();
              tooltipData.slotID = display.GetSlotID();
            };
            this.m_TooltipsManager.ShowTooltipAtWidget(n"itemTooltip", target, tooltipData, gameuiETooltipPlacement.RightTop, true);
          };
        };
      };
    };
  }

  private final func OnEquipRequestTooltip(itemData: InventoryItemData, target: wref<inkWidget>, slotName: String) -> Void {
    if !InventoryItemData.IsEmpty(itemData) {
      this.m_TooltipsManager.ShowTooltipAtWidget(n"itemTooltip", target, this.m_InventoryManager.GetTooltipDataForInventoryItem(itemData, true), gameuiETooltipPlacement.RightTop, true);
    } else {
      this.m_TooltipsManager.ShowTooltipAtWidget(0, target, this.m_InventoryManager.GetTooltipForEmptySlot(slotName), gameuiETooltipPlacement.RightTop, true);
    };
  }

  private final func HideTooltips() -> Void {
    this.m_TooltipsManager.HideTooltips();
  }

  private final func SetInventoryItemButtonHintsHoverOver(displayingData: InventoryItemData, opt display: ref<InventoryItemDisplayController>) -> Void {
    let cursorData: ref<MenuCursorUserData> = new MenuCursorUserData();
    let isEquipped: Bool = InventoryItemData.IsEquipped(displayingData) || this.itemChooser.IsAttachmentItem(displayingData);
    if IsDefined(display) {
      if !InventoryItemData.IsEmpty(displayingData) {
        if !isEquipped {
          if NotEquals(InventoryItemData.GetItemType(displayingData), gamedataItemType.Prt_Program) {
            this.m_buttonHintsController.AddButtonHint(n"drop_item", GetLocalizedText("UI-ScriptExports-Drop0"));
          };
          if !InventoryItemData.IsPart(displayingData) {
            if NotEquals(InventoryItemData.GetEquipmentArea(displayingData), gamedataEquipmentArea.Invalid) {
              this.m_buttonHintsController.AddButtonHint(n"equip_item", GetLocalizedText("UI-UserActions-Equip"));
            };
          } else {
            this.m_buttonHintsController.AddButtonHint(n"equip_item", GetLocalizedText("UI-UserActions-Equip"));
          };
          if Equals(display.GetDisplayContext(), ItemDisplayContext.Attachment) {
            this.m_buttonHintsController.RemoveButtonHint(n"drop_item");
            this.m_buttonHintsController.RemoveButtonHint(n"equip_item");
            if RPGManager.CanPartBeUnequipped(InventoryItemData.GetID(displayingData)) {
              this.m_buttonHintsController.AddButtonHint(n"unequip_item", GetLocalizedText("UI-UserActions-Unequip"));
            } else {
              this.m_buttonHintsController.RemoveButtonHint(n"unequip_item");
            };
          };
        } else {
          if !InventoryItemData.IsPart(displayingData) || RPGManager.CanPartBeUnequipped(InventoryItemData.GetID(displayingData)) || Equals(InventoryItemData.GetEquipmentArea(this.itemChooser.GetModifiedItemData()), gamedataEquipmentArea.SystemReplacementCW) {
            this.m_buttonHintsController.AddButtonHint(n"unequip_item", GetLocalizedText("UI-UserActions-Unequip"));
          };
        };
        if !this.m_isE3Demo {
          if RPGManager.CanItemBeDisassembled(this.m_player.GetGame(), InventoryItemData.GetID(displayingData)) && !isEquipped {
            this.m_buttonHintsController.AddButtonHint(n"disassemble_item", "[" + GetLocalizedText("Gameplay-Devices-Interactions-Helpers-Hold") + "] " + GetLocalizedText("UI-ScriptExports-Disassemble0"));
            cursorData.AddAction(n"disassemble_item");
          };
        };
        if Equals(InventoryItemData.GetEquipmentArea(displayingData), gamedataEquipmentArea.Consumable) {
          this.m_buttonHintsController.AddButtonHint(n"use_item", "[" + GetLocalizedText("Gameplay-Devices-Interactions-Helpers-Hold") + "] " + GetLocalizedText("UI-UserActions-Use"));
          cursorData.AddAction(n"use_item");
        };
      };
      if cursorData.GetActionsListSize() >= 0 {
        this.SetCursorContext(n"HoldToComplete", cursorData);
      } else {
        this.SetCursorContext(n"Hover");
      };
    } else {
      this.SetCursorContext(n"Default");
    };
  }

  private final func SetInventoryItemButtonHintsHoverOut() -> Void {
    this.m_buttonHintsController.RemoveButtonHint(n"equip_item");
    this.m_buttonHintsController.RemoveButtonHint(n"unequip_item");
    this.m_buttonHintsController.RemoveButtonHint(n"disassemble_item");
    this.m_buttonHintsController.RemoveButtonHint(n"use_item");
    this.m_buttonHintsController.RemoveButtonHint(n"select");
    this.m_buttonHintsController.RemoveButtonHint(n"drop_item");
  }

  private final func SetEquipmentSlotButtonHintsHoverOver(controller: ref<InventoryItemDisplayController>) -> Void {
    let itemData: InventoryItemData = controller.GetItemData();
    this.m_buttonHintsController.AddButtonHint(n"select", GetLocalizedText("Common-Access-Select"));
    if !InventoryItemData.IsEmpty(itemData) {
      this.m_buttonHintsController.AddButtonHint(n"unequip_item", GetLocalizedText("UI-UserActions-Unequip"));
    } else {
      this.m_buttonHintsController.RemoveButtonHint(n"unequip_item");
    };
  }

  private final func SetEquipmentSlotButtonHintsHoverOut() -> Void {
    this.m_buttonHintsController.RemoveButtonHint(n"select");
    this.m_buttonHintsController.RemoveButtonHint(n"unequip_item");
  }

  private final func GetInventoryItemDisplayControllerFromTarget(evt: ref<inkPointerEvent>) -> ref<InventoryItemDisplayController> {
    let widget: ref<inkWidget> = evt.GetCurrentTarget();
    let controller: wref<InventoryItemDisplayController> = widget.GetController() as InventoryItemDisplayController;
    return controller;
  }

  private final func GetProgramByShardType(programs: array<InventoryItemAttachments>, targetShardType: CName) -> InventoryItemAttachments {
    let dummyResult: InventoryItemAttachments;
    let shardType: CName;
    let i: Int32 = 0;
    while i < ArraySize(programs) {
      if InventoryItemData.IsEmpty(programs[i].ItemData) {
      } else {
        shardType = TweakDBInterface.GetCName(ItemID.GetTDBID(InventoryItemData.GetID(programs[i].ItemData)) + t".shardType", n"");
        if Equals(shardType, targetShardType) {
          return programs[i];
        };
      };
      i += 1;
    };
    return dummyResult;
  }
}

public class ItemModeGridContainer extends inkLogicController {

  protected edit let m_scrollControllerWidget: inkCompoundRef;

  protected edit let m_sliderWidget: inkWidgetRef;

  protected edit let m_itemsGridWidget: inkWidgetRef;

  protected edit let m_filterGridWidget: inkCompoundRef;

  private edit let m_F_eyesTexture: inkWidgetRef;

  private edit let m_F_systemReplacementTexture: inkWidgetRef;

  private edit let m_F_handsTexture: inkWidgetRef;

  private edit let m_M_eyesTexture: inkWidgetRef;

  private edit let m_M_systemReplacementTexture: inkWidgetRef;

  private edit let m_M_handsTexture: inkWidgetRef;

  private let m_outroAnimation: ref<inkAnimProxy>;

  public final func GetItemsGrid() -> inkWidgetRef {
    return this.m_itemsGridWidget;
  }

  public final func GetItemsWidget() -> wref<inkWidget> {
    return inkWidgetRef.Get(this.m_itemsGridWidget);
  }

  public final func GetFiltersGrid() -> inkCompoundRef {
    return this.m_filterGridWidget;
  }

  public final func SetPaperdollImage(area: gamedataEquipmentArea, female: Bool) -> Void {
    inkWidgetRef.SetVisible(this.m_F_eyesTexture, false);
    inkWidgetRef.SetVisible(this.m_F_systemReplacementTexture, false);
    inkWidgetRef.SetVisible(this.m_F_handsTexture, false);
    inkWidgetRef.SetVisible(this.m_M_eyesTexture, false);
    inkWidgetRef.SetVisible(this.m_M_systemReplacementTexture, false);
    inkWidgetRef.SetVisible(this.m_M_handsTexture, false);
    if this.m_outroAnimation.IsPlaying() {
      this.m_outroAnimation.Stop();
    };
    switch area {
      case gamedataEquipmentArea.EyesCW:
        inkWidgetRef.SetVisible(this.m_F_eyesTexture, female);
        inkWidgetRef.SetVisible(this.m_M_eyesTexture, !female);
        this.m_outroAnimation = this.PlayLibraryAnimation(n"paperdoll_ocular_intro");
        break;
      case gamedataEquipmentArea.SystemReplacementCW:
        inkWidgetRef.SetVisible(this.m_F_systemReplacementTexture, female);
        inkWidgetRef.SetVisible(this.m_M_systemReplacementTexture, !female);
        this.m_outroAnimation = this.PlayLibraryAnimation(n"paperdoll_operating_intro");
        break;
      case gamedataEquipmentArea.ArmsCW:
        inkWidgetRef.SetVisible(this.m_F_handsTexture, female);
        inkWidgetRef.SetVisible(this.m_M_handsTexture, !female);
        this.m_outroAnimation = this.PlayLibraryAnimation(n"paperdoll_arms_intro");
    };
  }
}

public class ItemModeGridClassifier extends inkVirtualItemTemplateClassifier {

  public func ClassifyItem(data: Variant) -> Uint32 {
    let listData: ref<WrappedInventoryItemData> = FromVariant(data) as WrappedInventoryItemData;
    if !IsDefined(listData) {
      return 0u;
    };
    return listData.ItemTemplate;
  }
}

public class ItemModeGridView extends ScriptableDataView {

  private let m_itemFilterType: ItemFilterCategory;

  private let m_itemSortMode: ItemSortMode;

  private let m_uiScriptableSystem: wref<UIScriptableSystem>;

  public final func BindUIScriptableSystem(uiScriptableSystem: wref<UIScriptableSystem>) -> Void {
    this.m_uiScriptableSystem = uiScriptableSystem;
  }

  public final func SetFilterType(type: ItemFilterCategory) -> Void {
    this.m_itemFilterType = type;
    this.Filter();
  }

  public final func GetFilterType() -> ItemFilterCategory {
    return this.m_itemFilterType;
  }

  public final func SetSortMode(mode: ItemSortMode) -> Void {
    let wasSortingEnabled: Bool = this.IsSortingEnabled();
    this.m_itemSortMode = mode;
    if !wasSortingEnabled {
      this.EnableSorting();
      this.Sort();
      this.DisableSorting();
    } else {
      this.Sort();
    };
  }

  public final func GetSortMode() -> ItemSortMode {
    return this.m_itemSortMode;
  }

  public func SortItem(left: ref<IScriptable>, right: ref<IScriptable>) -> Bool {
    let leftItemData: InventoryItemData;
    let rightItemData: InventoryItemData;
    let leftItem: InventoryItemSortData = InventoryItemData.GetSortData(left as WrappedInventoryItemData.ItemData);
    let rightItem: InventoryItemSortData = InventoryItemData.GetSortData(right as WrappedInventoryItemData.ItemData);
    if Equals(leftItem.Name, "") {
      leftItemData = left as WrappedInventoryItemData.ItemData;
      leftItem = ItemCompareBuilder.BuildInventoryItemSortData(leftItemData, this.m_uiScriptableSystem);
    };
    if Equals(rightItem.Name, "") {
      rightItemData = right as WrappedInventoryItemData.ItemData;
      rightItem = ItemCompareBuilder.BuildInventoryItemSortData(rightItemData, this.m_uiScriptableSystem);
    };
    switch this.m_itemSortMode {
      case ItemSortMode.NewItems:
        return ItemCompareBuilder.Make(leftItem, rightItem).NewItem(this.m_uiScriptableSystem).DPSDesc().QualityDesc().ItemType().NameAsc().GetBool();
      case ItemSortMode.NameAsc:
        return ItemCompareBuilder.Make(leftItem, rightItem).NameAsc().QualityDesc().GetBool();
      case ItemSortMode.NameDesc:
        return ItemCompareBuilder.Make(leftItem, rightItem).NameDesc().QualityDesc().GetBool();
      case ItemSortMode.DpsAsc:
        return ItemCompareBuilder.Make(leftItem, rightItem).DPSAsc().QualityDesc().NameAsc().GetBool();
      case ItemSortMode.DpsDesc:
        return ItemCompareBuilder.Make(leftItem, rightItem).DPSDesc().QualityDesc().NameAsc().GetBool();
      case ItemSortMode.QualityAsc:
        return ItemCompareBuilder.Make(leftItem, rightItem).QualityDesc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.QualityDesc:
        return ItemCompareBuilder.Make(leftItem, rightItem).QualityAsc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.WeightAsc:
        return ItemCompareBuilder.Make(leftItem, rightItem).WeightAsc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.WeightDesc:
        return ItemCompareBuilder.Make(leftItem, rightItem).WeightDesc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.PriceAsc:
        return ItemCompareBuilder.Make(leftItem, rightItem).PriceAsc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.PriceDesc:
        return ItemCompareBuilder.Make(leftItem, rightItem).PriceDesc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.ItemType:
        return ItemCompareBuilder.Make(leftItem, rightItem).ItemType().NameAsc().QualityDesc().GetBool();
    };
    return ItemCompareBuilder.Make(leftItem, rightItem).DPSDesc().QualityDesc().ItemType().NameAsc().GetBool();
  }

  public func FilterItem(data: ref<IScriptable>) -> Bool {
    let m_wrappedData: ref<WrappedInventoryItemData> = data as WrappedInventoryItemData;
    return ItemCategoryFliter.FilterItem(this.m_itemFilterType, m_wrappedData);
  }
}

public class ItemModeInventoryListenerCallback extends InventoryScriptCallback {

  private let m_itemModeInstance: wref<InventoryItemModeLogicController>;

  public final func Setup(itemModeInstance: wref<InventoryItemModeLogicController>) -> Void {
    this.m_itemModeInstance = itemModeInstance;
  }

  public func OnItemRemoved(itemIDArg: ItemID, difference: Int32, currentQuantity: Int32) -> Void {
    this.m_itemModeInstance.UpdateDisplayedItems(itemIDArg);
  }

  public func OnItemQuantityChanged(itemIDArg: ItemID, diff: Int32, total: Uint32, flaggedAsSilent: Bool) -> Void {
    this.m_itemModeInstance.UpdateDisplayedItems(itemIDArg);
  }
}
