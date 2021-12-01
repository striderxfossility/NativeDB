
public native class BackpackMainGameController extends gameuiMenuGameController {

  private edit let m_commonCraftingMaterialsGrid: inkCompoundRef;

  private edit let m_hackingCraftingMaterialsGrid: inkCompoundRef;

  private edit let m_filterButtonsGrid: inkCompoundRef;

  private edit let m_virtualItemsGrid: inkVirtualCompoundRef;

  private edit let m_TooltipsManagerRef: inkWidgetRef;

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_sortingButton: inkWidgetRef;

  private edit let m_sortingDropdown: inkWidgetRef;

  private edit let m_itemsListScrollAreaContainer: inkWidgetRef;

  private edit let m_itemNotificationRoot: inkWidgetRef;

  private let m_virtualBackpackItemsListController: wref<inkGridController>;

  private let m_TooltipsManager: wref<gameuiTooltipsManager>;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_itemTypeSorting: array<gamedataItemType>;

  private let m_InventoryManager: ref<InventoryDataManagerV2>;

  private let m_player: wref<PlayerPuppet>;

  private let m_itemDropQueue: array<ItemModParams>;

  private let m_craftingMaterialsListItems: array<wref<CrafringMaterialItemController>>;

  private let m_DisassembleCallback: ref<UI_CraftingDef>;

  private let m_DisassembleBlackboard: wref<IBlackboard>;

  private let m_DisassembleBBID: ref<CallbackHandle>;

  private let m_EquippedCallback: ref<UI_EquipmentDef>;

  private let m_EquippedBlackboard: wref<IBlackboard>;

  private let m_EquippedBBID: ref<CallbackHandle>;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_activeFilter: wref<BackpackFilterButtonController>;

  private let m_backpackItemsDataSource: ref<ScriptableDataSource>;

  private let m_backpackItemsDataView: ref<BackpackDataView>;

  private let m_comparisonResolver: ref<ItemPreferredComparisonResolver>;

  private let m_backpackInventoryListenerCallback: ref<BackpackInventoryListenerCallback>;

  private let m_backpackInventoryListener: ref<InventoryScriptListener>;

  private let m_backpackItemsClassifier: ref<ItemDisplayTemplateClassifier>;

  private let m_backpackItemsPositionProvider: ref<ItemPositionProvider>;

  private let m_equipSlotChooserPopupToken: ref<inkGameNotificationToken>;

  private let m_quantityPickerPopupToken: ref<inkGameNotificationToken>;

  private let m_isE3Demo: Bool;

  private let m_equipRequested: Bool;

  private let m_psmBlackboard: wref<IBlackboard>;

  private let playerState: gamePSMVehicle;

  private let m_uiScriptableSystem: wref<UIScriptableSystem>;

  private let m_confirmationPopupToken: ref<inkGameNotificationToken>;

  private let m_lastItemHoverOverEvent: ref<ItemDisplayHoverOverEvent>;

  private let m_isComparisionDisabled: Bool;

  protected let m_itemPreviewPopupToken: ref<inkGameNotificationToken>;

  protected let m_afterCloseRequest: Bool;

  protected cb func OnInitialize() -> Bool {
    let playerPuppet: wref<GameObject>;
    this.m_backpackInventoryListenerCallback = new BackpackInventoryListenerCallback();
    this.m_backpackInventoryListenerCallback.Setup(this);
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    this.m_buttonHintsController.AddButtonHint(n"back", "Common-Access-Close");
    this.m_buttonHintsController.AddButtonHint(n"toggle_comparison_tooltip", GetLocalizedText("UI-UserActions-DisableComparison"));
    this.m_itemTypeSorting = InventoryDataManagerV2.GetItemTypesForSorting();
    this.m_TooltipsManager = inkWidgetRef.GetControllerByType(this.m_TooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_TooltipsManager.Setup(ETooltipsStyle.Menus);
    this.RegisterToBB();
    this.AsyncSpawnFromExternal(inkWidgetRef.Get(this.m_itemNotificationRoot), r"base\\gameplay\\gui\\widgets\\activity_log\\activity_log_panels.inkwidget", n"RootVert");
    this.PlayLibraryAnimation(n"backpack_intro");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnPostOnRelease");
    playerPuppet = this.GetOwnerEntity() as PlayerPuppet;
    this.m_psmBlackboard = this.GetPSMBlackboard(playerPuppet);
    this.playerState = IntEnum(this.m_psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle));
    super.OnInitialize();
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnCloseMenu", this, n"OnCloseMenu");
    this.m_InventoryManager.UnInitialize();
    this.UnregisterFromBB();
    GameInstance.GetTransactionSystem(this.m_player.GetGame()).UnregisterInventoryListener(this.m_player, this.m_backpackInventoryListener);
    this.m_backpackInventoryListener = null;
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnPostOnRelease");
    super.OnUninitialize();
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    if this.m_player != null {
      GameInstance.GetTransactionSystem(this.m_player.GetGame()).UnregisterInventoryListener(this.m_player, this.m_backpackInventoryListener);
    };
    this.m_player = playerPuppet as PlayerPuppet;
    this.m_isE3Demo = GameInstance.GetQuestsSystem(this.m_player.GetGame()).GetFact(n"e3_2020") > 0;
    this.m_InventoryManager = new InventoryDataManagerV2();
    this.m_InventoryManager.Initialize(this.m_player);
    this.m_comparisonResolver = ItemPreferredComparisonResolver.Make(this.m_InventoryManager);
    this.m_backpackInventoryListener = GameInstance.GetTransactionSystem(this.m_player.GetGame()).RegisterInventoryListener(this.m_player, this.m_backpackInventoryListenerCallback);
    this.m_uiScriptableSystem = UIScriptableSystem.GetInstance(this.m_player.GetGame());
    this.m_isComparisionDisabled = this.m_uiScriptableSystem.IsComparisionTooltipDisabled();
    this.m_buttonHintsController.AddButtonHint(n"toggle_comparison_tooltip", GetLocalizedText(this.m_isComparisionDisabled ? "UI-UserActions-EnableComparison" : "UI-UserActions-DisableComparison"));
    this.SetupVirtualGrid();
    this.SetupDropdown();
    this.PopulateCraftingMaterials();
    this.RefreshUI();
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.ResetVirtualGrid();
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

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    super.OnSetMenuEventDispatcher(menuEventDispatcher);
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
    this.m_menuEventDispatcher.RegisterToEvent(n"OnCloseMenu", this, n"OnCloseMenu");
  }

  protected cb func OnCloseMenu(userData: ref<IScriptable>) -> Bool {
    if ArraySize(this.m_itemDropQueue) == 1 && this.m_itemDropQueue[0].quantity == 1 {
      ItemActionsHelper.DropItem(this.m_player, this.m_itemDropQueue[0].itemID);
      ArrayClear(this.m_itemDropQueue);
    } else {
      if ArraySize(this.m_itemDropQueue) > 0 {
        RPGManager.DropManyItems(this.m_player.GetGame(), this.m_player, this.m_itemDropQueue);
        ArrayClear(this.m_itemDropQueue);
      };
    };
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    if !this.m_afterCloseRequest {
      super.OnBack(userData);
    } else {
      this.m_afterCloseRequest = false;
    };
  }

  private final func RegisterToBB() -> Void {
    this.m_DisassembleCallback = GetAllBlackboardDefs().UI_Crafting;
    this.m_EquippedCallback = GetAllBlackboardDefs().UI_Equipment;
    this.m_DisassembleBlackboard = this.GetBlackboardSystem().Get(this.m_DisassembleCallback);
    this.m_EquippedBlackboard = this.GetBlackboardSystem().Get(this.m_EquippedCallback);
    if IsDefined(this.m_DisassembleBlackboard) {
      this.m_DisassembleBBID = this.m_DisassembleBlackboard.RegisterDelayedListenerVariant(this.m_DisassembleCallback.lastIngredients, this, n"OnDisassembleComplete", true);
    };
    if IsDefined(this.m_EquippedBlackboard) {
      this.m_EquippedBBID = this.m_EquippedBlackboard.RegisterDelayedListenerVariant(this.m_EquippedCallback.itemEquipped, this, n"OnItemEquipped", true);
    };
  }

  private final func UnregisterFromBB() -> Void {
    if IsDefined(this.m_DisassembleBlackboard) {
      this.m_DisassembleBlackboard.UnregisterDelayedListener(this.m_DisassembleCallback.lastIngredients, this.m_DisassembleBBID);
    };
    if IsDefined(this.m_EquippedBlackboard) {
      this.m_EquippedBlackboard.UnregisterDelayedListener(this.m_EquippedCallback.itemEquipped, this.m_EquippedBBID);
    };
  }

  protected final func SetupVirtualGrid() -> Void {
    this.m_virtualBackpackItemsListController = inkWidgetRef.GetControllerByType(this.m_virtualItemsGrid, n"inkGridController") as inkGridController;
    this.m_backpackItemsClassifier = new ItemDisplayTemplateClassifier();
    this.m_backpackItemsPositionProvider = new ItemPositionProvider();
    this.m_backpackItemsDataSource = new ScriptableDataSource();
    this.m_backpackItemsDataView = new BackpackDataView();
    this.m_backpackItemsDataView.BindUIScriptableSystem(this.m_uiScriptableSystem);
    this.m_backpackItemsDataView.SetSource(this.m_backpackItemsDataSource);
    this.m_backpackItemsDataView.EnableSorting();
    this.m_virtualBackpackItemsListController.SetClassifier(this.m_backpackItemsClassifier);
    this.m_virtualBackpackItemsListController.SetProvider(this.m_backpackItemsPositionProvider);
    this.m_virtualBackpackItemsListController.SetSource(this.m_backpackItemsDataView);
  }

  protected final func ResetVirtualGrid() -> Void {
    this.m_virtualBackpackItemsListController.SetSource(null);
    this.m_virtualBackpackItemsListController.SetClassifier(null);
    this.m_virtualBackpackItemsListController.SetProvider(null);
    this.m_backpackItemsDataView.SetSource(null);
    this.m_backpackItemsDataView = null;
    this.m_backpackItemsDataSource = null;
    this.m_backpackItemsPositionProvider = null;
    this.m_backpackItemsClassifier = null;
  }

  private final func SetupDropdown() -> Void {
    let controller: ref<DropdownListController>;
    let data: ref<DropdownItemData>;
    let sorting: Int32;
    let sortingButtonController: ref<DropdownButtonController>;
    inkWidgetRef.RegisterToCallback(this.m_sortingButton, n"OnRelease", this, n"OnSortingButtonClicked");
    controller = inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController;
    sortingButtonController = inkWidgetRef.GetController(this.m_sortingButton) as DropdownButtonController;
    controller.Setup(this, SortingDropdownData.GetDefaultDropdownOptions(), sortingButtonController);
    sorting = this.m_uiScriptableSystem.GetBackpackActiveSorting(EnumInt(ItemSortMode.Default));
    data = SortingDropdownData.GetDropdownOption(controller.GetData(), IntEnum(sorting));
    sortingButtonController.SetData(data);
    this.m_backpackItemsDataView.SetSortMode(FromVariant(data.identifier));
  }

  protected cb func OnDropdownItemClickedEvent(evt: ref<DropdownItemClickedEvent>) -> Bool {
    let setSortingRequest: ref<UIScriptableSystemSetBackpackSorting>;
    let sortingButtonController: ref<DropdownButtonController>;
    let identifier: ItemSortMode = FromVariant(evt.identifier);
    let data: ref<DropdownItemData> = SortingDropdownData.GetDropdownOption((inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController).GetData(), identifier);
    if IsDefined(data) {
      sortingButtonController = inkWidgetRef.GetController(this.m_sortingButton) as DropdownButtonController;
      sortingButtonController.SetData(data);
      this.m_backpackItemsDataView.SetSortMode(identifier);
      setSortingRequest = new UIScriptableSystemSetBackpackSorting();
      setSortingRequest.sortMode = EnumInt(identifier);
      this.m_uiScriptableSystem.QueueRequest(setSortingRequest);
    };
  }

  protected cb func OnDisassembleComplete(value: Variant) -> Bool {
    this.UpdateQuantites();
    this.UpdateCraftingMaterials();
  }

  protected cb func OnItemEquipped(value: Variant) -> Bool {
    if this.m_equipRequested {
      this.m_InventoryManager.MarkToRebuild();
      this.RefreshUI();
      this.m_equipRequested = false;
    };
  }

  public final func UpdateQuantites() -> Void {
    this.m_InventoryManager.MarkToRebuild();
    this.RefreshUI();
  }

  private final func RefreshUI() -> Void {
    this.PopulateInventory();
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

  private final func PopulateInventory() -> Void {
    let areaItems: array<InventoryItemData>;
    let currentItemArea: gamedataItemType;
    let i: Int32;
    let items: array<InventoryItemData>;
    let j: Int32;
    let tagsFilter: array<CName>;
    let wrappedItem: ref<WrappedInventoryItemData>;
    let wrappedItems: array<ref<IScriptable>>;
    let filterManager: ref<ItemCategoryFliterManager> = ItemCategoryFliterManager.Make();
    filterManager.AddFilterToCheck(ItemFilterCategory.Quest);
    ArrayPush(tagsFilter, n"HideInBackpackUI");
    ArrayPush(tagsFilter, n"SoftwareShard");
    i = 0;
    while i < ArraySize(this.m_itemTypeSorting) {
      currentItemArea = this.m_itemTypeSorting[i];
      areaItems = this.m_InventoryManager.GetPlayerItemsByType(currentItemArea, tagsFilter, this.m_itemDropQueue);
      j = 0;
      while j < ArraySize(areaItems) {
        ArrayPush(items, areaItems[j]);
        filterManager.AddItem(InventoryItemData.GetGameItemData(areaItems[j]));
        j += 1;
      };
      i += 1;
    };
    filterManager.SortFiltersList();
    filterManager.AddFilter(ItemFilterCategory.AllItems);
    this.RefreshFilterButtons(filterManager.GetFiltersList());
    i = 0;
    while i < ArraySize(items) {
      wrappedItem = new WrappedInventoryItemData();
      wrappedItem.ItemData = items[i];
      this.m_InventoryManager.GetOrCreateInventoryItemSortData(wrappedItem.ItemData, this.m_uiScriptableSystem);
      wrappedItem.DisplayContext = ItemDisplayContext.Backpack;
      wrappedItem.IsNew = this.m_uiScriptableSystem.IsInventoryItemNew(InventoryItemData.GetID(items[i]));
      ArrayPush(wrappedItems, wrappedItem);
      i += 1;
    };
    this.m_backpackItemsDataSource.Reset(wrappedItems);
  }

  private final func ClearCraftingMaterials() -> Void {
    ArrayClear(this.m_craftingMaterialsListItems);
    inkCompoundRef.RemoveAllChildren(this.m_commonCraftingMaterialsGrid);
    inkCompoundRef.RemoveAllChildren(this.m_hackingCraftingMaterialsGrid);
  }

  private final func PopulateCraftingMaterials() -> Void {
    let commonCraftingMaterials: array<InventoryItemData>;
    let hackingCraftingMaterials: array<InventoryItemData>;
    let i: Int32;
    this.ClearCraftingMaterials();
    commonCraftingMaterials = this.m_InventoryManager.GetCommonsCraftingMaterialTypes();
    hackingCraftingMaterials = this.m_InventoryManager.GetHackingCraftingMaterialTypes();
    i = 0;
    while i < ArraySize(commonCraftingMaterials) {
      this.CreateCraftingMaterialItem(commonCraftingMaterials[i], this.m_commonCraftingMaterialsGrid);
      i += 1;
    };
    i = 0;
    while i < ArraySize(hackingCraftingMaterials) {
      this.CreateCraftingMaterialItem(hackingCraftingMaterials[i], this.m_hackingCraftingMaterialsGrid);
      i += 1;
    };
  }

  private final func CreateCraftingMaterialItem(data: InventoryItemData, gridList: inkCompoundRef) -> Void {
    let callbackData: ref<BackpackCraftingMaterialItemCallbackData> = new BackpackCraftingMaterialItemCallbackData();
    callbackData.itemData = data;
    this.AsyncSpawnFromLocal(inkWidgetRef.Get(gridList), n"craftingMaterialItem", this, n"OnCraftingMaterialItemSpawned", callbackData);
  }

  protected cb func OnCraftingMaterialItemSpawned(widget: ref<inkWidget>, callbackData: ref<BackpackCraftingMaterialItemCallbackData>) -> Bool {
    let controller: ref<CrafringMaterialItemController>;
    widget.SetVAlign(inkEVerticalAlign.Top);
    widget.SetHAlign(inkEHorizontalAlign.Left);
    controller = widget.GetController() as CrafringMaterialItemController;
    ArrayPush(this.m_craftingMaterialsListItems, controller);
    controller.Setup(callbackData.itemData);
    controller.RegisterToCallback(n"OnHoverOver", this, n"OnCraftingMaterialHoverOver");
    controller.RegisterToCallback(n"OnHoverOut", this, n"OnCraftingMaterialHoverOut");
  }

  private final func UpdateCraftingMaterials(opt skipAnim: Bool) -> Void {
    let newData: InventoryItemData;
    let oldQuantity: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_craftingMaterialsListItems) {
      oldQuantity = this.m_craftingMaterialsListItems[i].GetQuantity();
      newData = this.m_InventoryManager.GetItemFromRecord(ItemID.GetTDBID(this.m_craftingMaterialsListItems[i].GetItemID()));
      this.m_craftingMaterialsListItems[i].Setup(newData);
      if !skipAnim && InventoryItemData.GetQuantity(newData) > oldQuantity {
        this.m_craftingMaterialsListItems[i].PlayAnimation();
      };
      i += 1;
    };
  }

  private final func RefreshFilterButtons(filters: array<ItemFilterCategory>) -> Void {
    let callbackData: ref<BackpackFilterButtonSpawnedCallbackData>;
    let i: Int32;
    let savedFilter: Int32 = this.m_uiScriptableSystem.GetBackpackActiveFilter(0);
    inkCompoundRef.RemoveAllChildren(this.m_filterButtonsGrid);
    i = 0;
    while i < ArraySize(filters) {
      callbackData = new BackpackFilterButtonSpawnedCallbackData();
      callbackData.category = filters[i];
      callbackData.savedFilter = savedFilter;
      this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_filterButtonsGrid), n"backpackFilterButtonItem", this, n"OnFilterButtonSpawned", callbackData);
      i += 1;
    };
  }

  protected cb func OnFilterButtonSpawned(widget: ref<inkWidget>, callbackData: ref<BackpackFilterButtonSpawnedCallbackData>) -> Bool {
    let filterButton: ref<BackpackFilterButtonController> = widget.GetController() as BackpackFilterButtonController;
    filterButton.RegisterToCallback(n"OnRelease", this, n"OnItemFilterClick");
    filterButton.RegisterToCallback(n"OnHoverOver", this, n"OnItemFilterHoverOver");
    filterButton.RegisterToCallback(n"OnHoverOut", this, n"OnItemFilterHoverOut");
    filterButton.Setup(callbackData.category);
    if EnumInt(filterButton.GetFilterType()) == callbackData.savedFilter {
      filterButton.SetActive(true);
      this.m_activeFilter = filterButton;
      this.m_backpackItemsDataView.SetFilterType(this.m_activeFilter.GetFilterType());
    };
  }

  private final func InvalidateItemTooltipEvent() -> Void {
    if this.m_lastItemHoverOverEvent != null {
      this.OnItemDisplayHoverOver(this.m_lastItemHoverOverEvent);
    };
  }

  protected cb func OnItemDisplayHoverOver(evt: ref<ItemDisplayHoverOverEvent>) -> Bool {
    let controller: ref<DropdownListController> = inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController;
    this.m_lastItemHoverOverEvent = evt;
    if !controller.IsOpened() {
      if !InventoryItemData.IsEmpty(evt.itemData) {
        this.RequestItemInspected(InventoryItemData.GetID(evt.itemData));
      };
      this.OnInventoryRequestTooltip(evt.itemData, evt.widget, evt.display.DEBUG_GetIconErrorInfo());
      this.SetInventoryItemButtonHintsHoverOver(evt.itemData);
      if !this.m_isE3Demo {
        this.HighlightDisassemblyResults(evt.itemData);
      };
    };
  }

  private final func RequestItemInspected(itemID: ItemID) -> Void {
    let request: ref<UIScriptableSystemInventoryInspectItem> = new UIScriptableSystemInventoryInspectItem();
    request.itemID = itemID;
    this.m_uiScriptableSystem.QueueRequest(request);
  }

  protected cb func OnItemDisplayHoverOut(evt: ref<ItemDisplayHoverOutEvent>) -> Bool {
    this.m_TooltipsManager.HideTooltips();
    this.SetInventoryItemButtonHintsHoverOut();
    this.HideDisassemblyHighlight();
    this.m_lastItemHoverOverEvent = null;
  }

  private final func HighlightDisassemblyResults(item: InventoryItemData) -> Void {
    let disassemblyResults: array<IngredientData>;
    let highlighted: Bool;
    let i: Int32;
    let itemId: ItemID;
    let j: Int32;
    if RPGManager.CanItemBeDisassembled(this.m_player.GetGame(), InventoryItemData.GetID(item)) {
      disassemblyResults = this.GetDisassemblyResult(item);
      i = 0;
      while i < ArraySize(this.m_craftingMaterialsListItems) {
        itemId = this.m_craftingMaterialsListItems[i].GetItemID();
        highlighted = false;
        j = 0;
        while j < ArraySize(disassemblyResults) {
          if disassemblyResults[j].id.GetID() == ItemID.GetTDBID(itemId) {
            this.m_craftingMaterialsListItems[i].SetHighlighted(CrafringMaterialItemHighlight.Add, disassemblyResults[j].quantity);
            highlighted = true;
          } else {
            j += 1;
          };
        };
        if !highlighted {
          this.m_craftingMaterialsListItems[i].SetHighlighted(IntEnum(0l));
        };
        i += 1;
      };
    };
  }

  private final func HideDisassemblyHighlight() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_craftingMaterialsListItems) {
      this.m_craftingMaterialsListItems[i].SetHighlighted(IntEnum(0l));
      i += 1;
    };
  }

  private final func GetDisassemblyResult(itemData: InventoryItemData) -> array<IngredientData> {
    let restoredAttachments: array<ItemAttachments>;
    let craftingSystem: ref<CraftingSystem> = CraftingSystem.GetInstance(this.m_player.GetGame());
    let result: array<IngredientData> = craftingSystem.GetDisassemblyResultItems(this.m_player, InventoryItemData.GetID(itemData), 1, restoredAttachments, true);
    return result;
  }

  protected cb func OnSortingButtonClicked(evt: ref<inkPointerEvent>) -> Bool {
    let controller: ref<DropdownListController>;
    if evt.IsAction(n"click") {
      controller = inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController;
      controller.Toggle();
      this.OnItemDisplayHoverOut(null);
    };
  }

  protected cb func OnItemDisplayClick(evt: ref<ItemDisplayClickEvent>) -> Bool {
    let item: ItemModParams;
    let isUsable: Bool = IsDefined(ItemActionsHelper.GetConsumeAction(InventoryItemData.GetGameItemData(evt.itemData).GetID())) || IsDefined(ItemActionsHelper.GetEatAction(InventoryItemData.GetGameItemData(evt.itemData).GetID())) || IsDefined(ItemActionsHelper.GetDrinkAction(InventoryItemData.GetGameItemData(evt.itemData).GetID())) || IsDefined(ItemActionsHelper.GetLearnAction(InventoryItemData.GetGameItemData(evt.itemData).GetID())) || IsDefined(ItemActionsHelper.GetDownloadFunds(InventoryItemData.GetGameItemData(evt.itemData).GetID()));
    if evt.actionName.IsAction(n"drop_item") {
      if Equals(this.playerState, gamePSMVehicle.Default) && RPGManager.CanItemBeDropped(this.m_player, InventoryItemData.GetGameItemData(evt.itemData)) && InventoryGPRestrictionHelper.CanDrop(evt.itemData, this.m_player) {
        if InventoryItemData.GetQuantity(evt.itemData) > 1 {
          this.OpenQuantityPicker(evt.itemData, QuantityPickerActionType.Drop);
        } else {
          this.PlaySound(n"ItemGeneric", n"OnDrop");
          item.itemID = InventoryItemData.GetID(evt.itemData);
          item.quantity = 1;
          this.AddToDropQueue(item);
          this.RefreshUI();
        };
      } else {
        this.ShowNotification(this.m_player.GetGame(), this.DetermineUIMenuNotificationType());
      };
    } else {
      if evt.actionName.IsAction(n"equip_item") {
        this.EquipItem(evt.itemData);
      } else {
        if evt.actionName.IsAction(n"use_item") && isUsable {
          if !InventoryGPRestrictionHelper.CanUse(evt.itemData, this.m_player) {
            this.ShowNotification(this.m_player.GetGame(), this.DetermineUIMenuNotificationType());
            return false;
          };
          this.PlaySound(n"ItemConsumableFood", n"OnUse");
          if Equals(InventoryItemData.GetItemType(evt.itemData), gamedataItemType.Con_Skillbook) {
            this.SetWarningMessage(GetLocalizedText("LocKey#46534") + "\\n" + GetLocalizedText(InventoryItemData.GetDescription(evt.itemData)));
          };
          ItemActionsHelper.PerformItemAction(this.m_player, InventoryItemData.GetID(evt.itemData));
          this.m_InventoryManager.MarkToRebuild();
          this.RefreshUI();
        };
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

  private final func OpenConfirmationPopupOpenConfirmationPopup(itemData: InventoryItemData) -> Void {
    let data: ref<VendorConfirmationPopupData> = new VendorConfirmationPopupData();
    data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\vendor_confirmation.inkwidget";
    data.isBlocking = true;
    data.useCursor = true;
    data.queueName = n"modal_popup";
    data.itemData = itemData;
    data.quantity = InventoryItemData.GetQuantity(itemData);
    data.type = VendorConfirmationPopupType.DisassembeIconic;
    this.m_confirmationPopupToken = this.ShowGameNotification(data);
    this.m_confirmationPopupToken.RegisterListener(this, n"OnConfirmationPopupClosed");
    this.m_buttonHintsController.Hide();
  }

  protected cb func OnConfirmationPopupClosed(data: ref<inkGameNotificationData>) -> Bool {
    this.m_confirmationPopupToken = null;
    let resultData: ref<VendorConfirmationPopupCloseData> = data as VendorConfirmationPopupCloseData;
    if resultData.confirm {
      ItemActionsHelper.DisassembleItem(this.m_player, InventoryItemData.GetID(resultData.itemData));
      this.PlaySound(n"Item", n"OnDisassemble");
    };
    this.m_buttonHintsController.Show();
  }

  private final func OpenQuantityPicker(itemData: InventoryItemData, actionType: QuantityPickerActionType) -> Void {
    let data: ref<QuantityPickerPopupData> = new QuantityPickerPopupData();
    data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\item_quantity_picker.inkwidget";
    data.isBlocking = true;
    data.useCursor = true;
    data.queueName = n"modal_popup";
    data.maxValue = InventoryItemData.GetQuantity(itemData);
    data.gameItemData = itemData;
    data.actionType = actionType;
    this.m_quantityPickerPopupToken = this.ShowGameNotification(data);
    this.m_quantityPickerPopupToken.RegisterListener(this, n"OnQuantityPickerPopupClosed");
    this.m_buttonHintsController.Hide();
  }

  protected cb func OnQuantityPickerPopupClosed(data: ref<inkGameNotificationData>) -> Bool {
    this.m_quantityPickerPopupToken = null;
    let quantityData: ref<QuantityPickerPopupCloseData> = data as QuantityPickerPopupCloseData;
    if quantityData.choosenQuantity != -1 {
      switch quantityData.actionType {
        case QuantityPickerActionType.Drop:
          this.OnQuantityPickerDrop(quantityData);
          break;
        case QuantityPickerActionType.Disassembly:
          this.OnQuantityPickerDisassembly(quantityData);
      };
    };
    this.m_buttonHintsController.Show();
  }

  public final func OnQuantityPickerDrop(data: ref<QuantityPickerPopupCloseData>) -> Void {
    let item: ItemModParams;
    this.PlaySound(n"ItemGeneric", n"OnDrop");
    item.itemID = InventoryItemData.GetID(data.itemData);
    item.quantity = data.choosenQuantity;
    this.AddToDropQueue(item);
    this.RefreshUI();
  }

  public final func OnQuantityPickerDisassembly(data: ref<QuantityPickerPopupCloseData>) -> Void {
    ItemActionsHelper.DisassembleItem(this.m_player, InventoryItemData.GetID(data.itemData), data.choosenQuantity);
    this.PlaySound(n"Item", n"OnDisassemble");
    this.m_TooltipsManager.HideTooltips();
  }

  public final func IsEquippable(itemData: ref<gameItemData>) -> Bool {
    return EquipmentSystem.GetInstance(this.m_player).GetPlayerData(this.m_player).IsEquippable(itemData);
  }

  public final func EquipItem(itemData: InventoryItemData) -> Void {
    if this.IsEquippable(InventoryItemData.GetGameItemData(itemData)) {
      if !InventoryGPRestrictionHelper.CanUse(itemData, this.m_player) {
        this.ShowNotification(this.m_player.GetGame(), UIMenuNotificationType.InventoryActionBlocked);
        return;
      };
      if Equals(InventoryItemData.GetEquipmentArea(itemData), gamedataEquipmentArea.Weapon) {
        this.OpenBackpackEquipSlotChooser(itemData);
        return;
      };
      this.m_equipRequested = true;
      this.m_InventoryManager.EquipItem(InventoryItemData.GetID(itemData), 0);
    };
  }

  private final func ShowNotification(gameInstance: GameInstance, type: UIMenuNotificationType) -> Void {
    let inventoryNotification: ref<UIMenuNotificationEvent> = new UIMenuNotificationEvent();
    inventoryNotification.m_notificationType = type;
    GameInstance.GetUISystem(gameInstance).QueueEvent(inventoryNotification);
  }

  public final func OpenBackpackEquipSlotChooser(itemData: InventoryItemData) -> Void {
    let data: ref<BackpackEquipSlotChooserData> = new BackpackEquipSlotChooserData();
    data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\backpack_equip_notification.inkwidget";
    data.isBlocking = true;
    data.useCursor = true;
    data.queueName = n"modal_popup";
    data.item = itemData;
    data.inventoryManager = this.m_InventoryManager;
    this.m_equipSlotChooserPopupToken = this.ShowGameNotification(data);
    this.m_equipSlotChooserPopupToken.RegisterListener(this, n"OnBackpacEquipSlotChooserClosed");
    this.m_buttonHintsController.Hide();
  }

  protected cb func OnBackpacEquipSlotChooserClosed(data: ref<inkGameNotificationData>) -> Bool {
    let i: Int32;
    this.m_equipSlotChooserPopupToken = null;
    let slotChooserData: ref<BackpackEquipSlotChooserCloseData> = data as BackpackEquipSlotChooserCloseData;
    if slotChooserData.confirm {
      this.m_equipRequested = true;
      if Equals(InventoryItemData.GetEquipmentArea(slotChooserData.itemData), gamedataEquipmentArea.Weapon) {
        i = 0;
        while i < this.m_InventoryManager.GetNumberOfSlots(gamedataEquipmentArea.Weapon) {
          if InventoryItemData.GetID(slotChooserData.itemData) == this.m_InventoryManager.GetEquippedItemIdInArea(gamedataEquipmentArea.Weapon, i) {
            this.m_InventoryManager.UnequipItem(gamedataEquipmentArea.Weapon, i);
          };
          i += 1;
        };
      };
      this.m_InventoryManager.EquipItem(InventoryItemData.GetID(slotChooserData.itemData), slotChooserData.slotIndex);
      this.PlaySound(n"Button", n"OnPress");
    };
    this.m_buttonHintsController.Show();
  }

  protected cb func OnItemPreviewPopup(data: ref<inkGameNotificationData>) -> Bool {
    this.m_itemPreviewPopupToken = null;
  }

  protected cb func OnItemFilterClick(evt: ref<inkPointerEvent>) -> Bool {
    let controller: ref<BackpackFilterButtonController>;
    let setFilterRequest: ref<UIScriptableSystemSetBackpackFilter>;
    let widget: ref<inkWidget>;
    if evt.IsAction(n"click") {
      this.PlaySound(n"Button", n"OnPress");
      widget = evt.GetCurrentTarget();
      controller = widget.GetController() as BackpackFilterButtonController;
      if IsDefined(this.m_activeFilter) {
        this.m_activeFilter.SetActive(false);
      };
      this.m_activeFilter = controller;
      this.m_activeFilter.SetActive(true);
      this.m_backpackItemsDataView.SetFilterType(controller.GetFilterType());
      setFilterRequest = new UIScriptableSystemSetBackpackFilter();
      setFilterRequest.filterMode = EnumInt(controller.GetFilterType());
      this.m_uiScriptableSystem.QueueRequest(setFilterRequest);
      (inkWidgetRef.GetController(this.m_itemsListScrollAreaContainer) as inkScrollController).SetScrollPosition(0.00);
      this.PlayLibraryAnimation(n"filter_change");
    };
  }

  protected cb func OnItemFilterHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let widget: ref<inkWidget> = evt.GetCurrentTarget();
    let controller: ref<BackpackFilterButtonController> = widget.GetController() as BackpackFilterButtonController;
    let tooltipData: ref<MessageTooltipData> = new MessageTooltipData();
    tooltipData.Title = NameToString(controller.GetLabelKey());
    this.m_TooltipsManager.ShowTooltipAtWidget(0, widget, tooltipData, gameuiETooltipPlacement.RightTop);
  }

  protected cb func OnItemFilterHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_TooltipsManager.HideTooltips();
  }

  protected cb func OnCraftingMaterialHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let widget: wref<inkWidget> = evt.GetCurrentTarget();
    let controller: ref<CrafringMaterialItemController> = widget.GetController() as CrafringMaterialItemController;
    let tooltipData: ref<MessageTooltipData> = new MessageTooltipData();
    tooltipData.Title = controller.GetMateialDisplayName();
    this.m_TooltipsManager.ShowTooltipAtWidget(0, widget, tooltipData, gameuiETooltipPlacement.RightTop);
  }

  protected cb func OnCraftingMaterialHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_TooltipsManager.HideTooltips();
  }

  protected cb func OnItemDisplayHold(evt: ref<ItemDisplayHoldEvent>) -> Bool {
    if evt.actionName.IsAction(n"disassemble_item") && !this.m_isE3Demo {
      if RPGManager.CanItemBeDisassembled(this.m_player.GetGame(), InventoryItemData.GetGameItemData(evt.itemData)) {
        if InventoryItemData.GetQuantity(evt.itemData) > 1 {
          this.OpenQuantityPicker(evt.itemData, QuantityPickerActionType.Disassembly);
        } else {
          if RPGManager.IsItemIconic(InventoryItemData.GetGameItemData(evt.itemData)) {
            this.OpenConfirmationPopupOpenConfirmationPopup(evt.itemData);
          } else {
            ItemActionsHelper.DisassembleItem(this.m_player, InventoryItemData.GetID(evt.itemData));
            this.PlaySound(n"Item", n"OnDisassemble");
            this.m_TooltipsManager.HideTooltips();
          };
        };
      };
    };
  }

  private final func OnInventoryRequestTooltip(displayingData: InventoryItemData, widget: wref<inkWidget>, iconErrorInfo: ref<DEBUG_IconErrorInfo>) -> Void {
    let itemToCompare: InventoryItemData;
    let tooltipData: ref<InventoryTooltipData>;
    let tooltipsData: array<ref<ATooltipData>>;
    if !InventoryItemData.IsEmpty(displayingData) {
      if Equals(InventoryItemData.GetItemType(displayingData), gamedataItemType.Prt_Program) {
        this.m_TooltipsManager.ShowTooltipAtWidget(n"programTooltip", widget, this.m_InventoryManager.GetTooltipDataForInventoryItem(displayingData, true, iconErrorInfo), gameuiETooltipPlacement.RightTop, true);
      } else {
        if !InventoryItemData.IsEquipped(displayingData) && !this.m_isComparisionDisabled {
          itemToCompare = this.m_comparisonResolver.GetPreferredComparisonItem(displayingData);
        };
        if !InventoryItemData.IsEmpty(itemToCompare) {
          this.m_InventoryManager.PushIdentifiedComparisonTooltipsData(tooltipsData, n"itemTooltip", n"itemTooltipComparision", itemToCompare, displayingData, iconErrorInfo);
          this.m_TooltipsManager.ShowTooltipsAtWidget(tooltipsData, widget);
        } else {
          tooltipData = this.m_InventoryManager.GetTooltipDataForInventoryItem(displayingData, false, iconErrorInfo);
          this.m_TooltipsManager.ShowTooltipAtWidget(n"itemTooltip", widget, tooltipData, gameuiETooltipPlacement.RightTop, true);
        };
      };
    };
  }

  private final func SetInventoryItemButtonHintsHoverOver(displayingData: InventoryItemData) -> Void {
    let isLearnble: Bool;
    let isUsable: Bool;
    let cursorData: ref<MenuCursorUserData> = new MenuCursorUserData();
    cursorData.SetAnimationOverride(n"hoverOnHoldToComplete");
    if !InventoryItemData.IsEmpty(displayingData) {
      isUsable = IsDefined(ItemActionsHelper.GetConsumeAction(InventoryItemData.GetGameItemData(displayingData).GetID())) || IsDefined(ItemActionsHelper.GetEatAction(InventoryItemData.GetGameItemData(displayingData).GetID())) || IsDefined(ItemActionsHelper.GetDrinkAction(InventoryItemData.GetGameItemData(displayingData).GetID()));
      isLearnble = IsDefined(ItemActionsHelper.GetLearnAction(InventoryItemData.GetGameItemData(displayingData).GetID()));
      if !this.m_isE3Demo && RPGManager.CanItemBeDisassembled(this.m_player.GetGame(), InventoryItemData.GetID(displayingData)) && !InventoryItemData.IsEquipped(displayingData) && !InventoryItemData.GetGameItemData(displayingData).HasTag(n"UnequipBlocked") {
        this.m_buttonHintsController.AddButtonHint(n"disassemble_item", "[" + GetLocalizedText("Gameplay-Devices-Interactions-Helpers-Hold") + "] " + GetLocalizedText("Gameplay-Devices-DisplayNames-DisassemblableItem"));
        cursorData.AddAction(n"disassemble_item");
      } else {
        this.m_buttonHintsController.RemoveButtonHint(n"disassemble_item");
      };
      if !InventoryItemData.IsEquipped(displayingData) && IsDefined(ItemActionsHelper.GetDropAction(InventoryItemData.GetGameItemData(displayingData).GetID())) && !InventoryItemData.GetGameItemData(displayingData).HasTag(n"UnequipBlocked") && !InventoryItemData.GetGameItemData(displayingData).HasTag(n"Quest") {
        if Equals(this.playerState, gamePSMVehicle.Default) {
          this.m_buttonHintsController.AddButtonHint(n"drop_item", GetLocalizedText("UI-ScriptExports-Drop0"));
        } else {
          this.m_buttonHintsController.RemoveButtonHint(n"drop_item");
        };
      };
      if isUsable {
        this.m_buttonHintsController.AddButtonHint(n"use_item", GetLocalizedText("UI-UserActions-Use"));
      } else {
        if isLearnble {
          this.m_buttonHintsController.AddButtonHint(n"use_item", GetLocalizedText("Gameplay-Devices-Interactions-Learn"));
        } else {
          if RPGManager.HasDownloadFundsAction(InventoryItemData.GetID(displayingData)) && RPGManager.CanDownloadFunds(this.m_player.GetGame(), InventoryItemData.GetID(displayingData)) {
            this.m_buttonHintsController.AddButtonHint(n"use_item", GetLocalizedText("LocKey#23401"));
          } else {
            this.m_buttonHintsController.RemoveButtonHint(n"use_item");
          };
        };
      };
      if cursorData.GetActionsListSize() >= 0 {
        this.SetCursorContext(n"Hover", cursorData);
      } else {
        this.SetCursorContext(n"Hover");
      };
    } else {
      this.SetCursorContext(n"Default");
    };
  }

  private final func SetInventoryItemButtonHintsHoverOut() -> Void {
    this.m_buttonHintsController.RemoveButtonHint(n"disassemble_item");
    this.m_buttonHintsController.RemoveButtonHint(n"use_item");
    this.m_buttonHintsController.RemoveButtonHint(n"drop_item");
    this.m_buttonHintsController.RemoveButtonHint(n"preview_item");
    this.SetCursorContext(n"Default");
  }

  private final func SetWarningMessage(message: String) -> Void {
    let warningMsg: SimpleScreenMessage;
    warningMsg.isShown = true;
    warningMsg.duration = 5.00;
    warningMsg.message = message;
    GameInstance.GetBlackboardSystem(this.m_player.GetGame()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(warningMsg), true);
  }
}

public class BackgroundDisplayVirtualController extends inkVirtualCompoundBackgroundController {

  protected cb func OnInitialize() -> Bool {
    this.GetRootWidget().SetAnchor(inkEAnchor.Fill);
  }
}

public class ItemDisplayVirtualController extends inkVirtualCompoundItemController {

  protected edit let m_itemDisplayWidget: inkWidgetRef;

  protected edit let m_widgetToSpawn: CName;

  protected let m_wrappedData: ref<WrappedInventoryItemData>;

  protected let m_data: InventoryItemData;

  protected let m_spawnedWidget: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.GetRootWidget().SetVAlign(inkEVerticalAlign.Top);
    this.GetRootWidget().SetHAlign(inkEHorizontalAlign.Left);
    this.AsyncSpawnFromLocal(this.GetRootCompoundWidget(), this.m_widgetToSpawn, this, n"OnWidgetSpawned");
    this.RegisterToCallback(n"OnSelected", this, n"OnSelected");
  }

  protected cb func OnWidgetSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_spawnedWidget = widget;
    this.SetupData();
  }

  protected cb func OnSelected(itemController: wref<inkVirtualCompoundItemController>, discreteNav: Bool) -> Bool {
    let widget: wref<inkWidget>;
    if discreteNav {
      widget = this.GetRootWidget();
      this.SetCursorOverWidget(widget);
    };
  }

  protected cb func OnDataChanged(value: Variant) -> Bool {
    this.m_wrappedData = FromVariant(value) as WrappedInventoryItemData;
    this.SetupData();
  }

  private final func SetupData() -> Void {
    let itemView: wref<InventoryItemDisplayController>;
    if !IsDefined(this.m_wrappedData) || !IsDefined(this.m_spawnedWidget) {
      return;
    };
    this.m_data = this.m_wrappedData.ItemData;
    itemView = this.m_spawnedWidget.GetController() as InventoryItemDisplayController;
    itemView.Setup(this.m_data, this.m_wrappedData.DisplayContext);
    itemView.SetComparisonState(this.m_wrappedData.ComparisonState);
    itemView.SetIsNew(this.m_wrappedData.IsNew, this.m_wrappedData);
  }
}

public class ItemDisplayTemplateClassifier extends inkVirtualItemTemplateClassifier {

  public func ClassifyItem(data: Variant) -> Uint32 {
    let m_wrappedData: ref<WrappedInventoryItemData> = FromVariant(data) as WrappedInventoryItemData;
    if !IsDefined(m_wrappedData) {
      return 0u;
    };
    if Equals(InventoryItemData.GetEquipmentArea(m_wrappedData.ItemData), gamedataEquipmentArea.Weapon) {
      return 1u;
    };
    return 0u;
  }
}

public class ItemPositionProvider extends inkItemPositionProvider {

  public func GetItemPosition(data: Variant) -> Uint32 {
    let m_wrappedData: ref<WrappedInventoryItemData> = FromVariant(data) as WrappedInventoryItemData;
    if !IsDefined(m_wrappedData) {
      return 4294967295u;
    };
    return InventoryItemData.GetPositionInBackpack(m_wrappedData.ItemData);
  }

  public func SaveItemPosition(data: Variant, position: Uint32) -> Void {
    let m_wrappedData: ref<WrappedInventoryItemData> = FromVariant(data) as WrappedInventoryItemData;
    if IsDefined(m_wrappedData) {
      InventoryItemData.SetPositionInBackpack(m_wrappedData.ItemData, position);
    };
  }
}

public class BackpackDataView extends ScriptableDataView {

  private let m_itemSortMode: ItemSortMode;

  private let m_attachmentsList: array<gamedataItemType>;

  private let m_uiScriptableSystem: wref<UIScriptableSystem>;

  protected let m_itemFilterType: ItemFilterCategory;

  public final func BindUIScriptableSystem(uiScriptableSystem: wref<UIScriptableSystem>) -> Void {
    this.m_uiScriptableSystem = uiScriptableSystem;
  }

  public final func SetFilterType(type: ItemFilterCategory) -> Void {
    if NotEquals(this.m_itemFilterType, type) {
      this.m_itemFilterType = type;
      this.Filter();
    };
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

  protected func PreSortingInjection(builder: ref<ItemCompareBuilder>) -> ref<ItemCompareBuilder> {
    return builder;
  }

  protected func PreFilterInjection(itemData: InventoryItemData) -> Bool {
    return true;
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
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).NewItem(this.m_uiScriptableSystem).QualityDesc().ItemType().NameAsc().GetBool();
      case ItemSortMode.NameAsc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).NameAsc().QualityDesc().GetBool();
      case ItemSortMode.NameDesc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).NameDesc().QualityDesc().GetBool();
      case ItemSortMode.DpsAsc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).DPSAsc().QualityDesc().NameAsc().GetBool();
      case ItemSortMode.DpsDesc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).DPSDesc().QualityDesc().NameDesc().GetBool();
      case ItemSortMode.QualityAsc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).QualityDesc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.QualityDesc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).QualityAsc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.WeightAsc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).WeightAsc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.WeightDesc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).WeightDesc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.PriceAsc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).PriceAsc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.PriceDesc:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).PriceDesc().NameAsc().QualityDesc().GetBool();
      case ItemSortMode.ItemType:
        return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).ItemType().NameAsc().QualityDesc().GetBool();
    };
    return this.PreSortingInjection(ItemCompareBuilder.Make(leftItem, rightItem)).QualityDesc().ItemType().NameAsc().GetBool();
  }

  public func FilterItem(data: ref<IScriptable>) -> Bool {
    let derivedFilterResult: DerivedFilterResult;
    let m_wrappedData: ref<WrappedInventoryItemData> = data as WrappedInventoryItemData;
    if !this.PreFilterInjection(m_wrappedData.ItemData) {
      return false;
    };
    derivedFilterResult = this.DerivedFilterItem(data);
    if NotEquals(derivedFilterResult, DerivedFilterResult.Pass) {
      return Equals(derivedFilterResult, DerivedFilterResult.True);
    };
    return ItemCategoryFliter.FilterItem(this.m_itemFilterType, m_wrappedData);
  }

  public func DerivedFilterItem(data: ref<IScriptable>) -> DerivedFilterResult {
    return DerivedFilterResult.Pass;
  }

  private final func FilterWeapons(itemData: InventoryItemData) -> Bool {
    return Equals(InventoryItemData.GetEquipmentArea(itemData), gamedataEquipmentArea.Weapon);
  }

  private final func FilterClothes(itemData: InventoryItemData) -> Bool {
    switch InventoryItemData.GetEquipmentArea(itemData) {
      case gamedataEquipmentArea.Outfit:
      case gamedataEquipmentArea.Feet:
      case gamedataEquipmentArea.Legs:
      case gamedataEquipmentArea.InnerChest:
      case gamedataEquipmentArea.OuterChest:
      case gamedataEquipmentArea.Face:
      case gamedataEquipmentArea.Head:
        return true;
      default:
        return false;
    };
  }

  private final func FilterConsumable(itemData: InventoryItemData) -> Bool {
    return Equals(InventoryItemData.GetEquipmentArea(itemData), gamedataEquipmentArea.Consumable);
  }

  private final func FilterCyberwareByItemType(itemType: gamedataItemType) -> Bool {
    switch itemType {
      case gamedataItemType.Cyb_StrongArms:
      case gamedataItemType.Cyb_NanoWires:
      case gamedataItemType.Cyb_MantisBlades:
      case gamedataItemType.Cyb_Launcher:
      case gamedataItemType.Cyb_Ability:
        return true;
      default:
        return false;
    };
    return false;
  }

  private final func FilterCyberwareByEquipmentArea(equipmentArea: gamedataEquipmentArea) -> Bool {
    switch equipmentArea {
      case gamedataEquipmentArea.SystemReplacementCW:
      case gamedataEquipmentArea.PersonalLink:
      case gamedataEquipmentArea.NervousSystemCW:
      case gamedataEquipmentArea.MusculoskeletalSystemCW:
      case gamedataEquipmentArea.LegsCW:
      case gamedataEquipmentArea.IntegumentarySystemCW:
      case gamedataEquipmentArea.ImmuneSystemCW:
      case gamedataEquipmentArea.HandsCW:
      case gamedataEquipmentArea.FrontalCortexCW:
      case gamedataEquipmentArea.EyesCW:
      case gamedataEquipmentArea.CardiovascularSystemCW:
      case gamedataEquipmentArea.ArmsCW:
      case gamedataEquipmentArea.AbilityCW:
        return true;
      default:
        return false;
    };
    return false;
  }

  private final func FilterCyberware(itemData: InventoryItemData) -> Bool {
    return this.FilterCyberwareByEquipmentArea(InventoryItemData.GetEquipmentArea(itemData)) || this.FilterCyberwareByItemType(InventoryItemData.GetItemType(itemData));
  }

  private final func FilterAttachments(itemData: InventoryItemData) -> Bool {
    if ArraySize(this.m_attachmentsList) == 0 {
      this.m_attachmentsList = InventoryDataManagerV2.GetAttachmentsTypes();
    };
    return ArrayContains(this.m_attachmentsList, InventoryItemData.GetItemType(itemData));
  }

  private final func FilterQuestItems(itemData: InventoryItemData) -> Bool {
    return InventoryItemData.GetGameItemData(itemData).HasTag(n"Quest");
  }
}

public class BackpackInventoryListenerCallback extends InventoryScriptCallback {

  private let m_backpackInstance: wref<BackpackMainGameController>;

  public final func Setup(backpackInstance: wref<BackpackMainGameController>) -> Void {
    this.m_backpackInstance = backpackInstance;
  }
}
