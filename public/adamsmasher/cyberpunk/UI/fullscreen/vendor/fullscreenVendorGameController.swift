
public class FullscreenVendorGameController extends gameuiMenuGameController {

  private edit let m_TooltipsManagerRef: inkWidgetRef;

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_playerFiltersContainer: inkWidgetRef;

  private edit let m_vendorFiltersContainer: inkWidgetRef;

  private edit let m_inventoryGridList: inkVirtualCompoundRef;

  private edit let m_vendorSpecialOffersInventoryGridList: inkCompoundRef;

  private edit let m_vendorInventoryGridList: inkVirtualCompoundRef;

  private edit let m_specialOffersWrapper: inkWidgetRef;

  private edit let m_playerInventoryGridScroll: inkWidgetRef;

  private edit let m_vendorInventoryGridScroll: inkWidgetRef;

  private edit let m_notificationRoot: inkWidgetRef;

  private edit let m_emptyStock: inkWidgetRef;

  private edit let m_buyWrapper: inkWidgetRef;

  private edit let m_vendorMoney: inkTextRef;

  private edit let m_vendorName: inkTextRef;

  private edit let m_playerMoney: inkTextRef;

  private edit let m_quantityPicker: inkWidgetRef;

  private edit let m_playerSortingButton: inkWidgetRef;

  private edit let m_vendorSortingButton: inkWidgetRef;

  private edit let m_sortingDropdown: inkWidgetRef;

  private edit let m_playerBalance: inkWidgetRef;

  private edit let m_vendorBalance: inkWidgetRef;

  private let m_TooltipsManager: wref<gameuiTooltipsManager>;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_VendorDataManager: ref<VendorDataManager>;

  private let m_player: wref<PlayerPuppet>;

  private let m_itemTypeSorting: array<gamedataItemType>;

  private let m_InventoryManager: ref<InventoryDataManagerV2>;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_playerInventoryitemControllers: array<wref<InventoryItemDisplayController>>;

  private let m_vendorInventoryitemControllers: array<wref<InventoryItemDisplayController>>;

  private let m_vendorSpecialOfferInventoryitemControllers: array<wref<InventoryItemDisplayController>>;

  private let m_playerDataSource: ref<ScriptableDataSource>;

  private let m_virtualPlayerListController: wref<inkVirtualGridController>;

  private let m_vendorDataSource: ref<ScriptableDataSource>;

  private let m_virtualVendorListController: wref<inkVirtualGridController>;

  private let m_playerItemsDataView: ref<VendorDataView>;

  private let m_vendorItemsDataView: ref<VendorDataView>;

  private let m_itemsClassifier: ref<ItemDisplayTemplateClassifier>;

  private let m_totalBuyCost: Float;

  private let m_totalSellCost: Float;

  private let m_root: wref<inkWidget>;

  private let m_vendorUserData: ref<VendorUserData>;

  private let m_storageUserData: ref<StorageUserData>;

  private let m_comparisonResolver: ref<ItemPreferredComparisonResolver>;

  private let m_sellJunkPopupToken: ref<inkGameNotificationToken>;

  private let m_quantityPickerPopupToken: ref<inkGameNotificationToken>;

  private let m_confirmationPopupToken: ref<inkGameNotificationToken>;

  private let m_itemPreviewPopupToken: ref<inkGameNotificationToken>;

  private let m_VendorBlackboard: wref<IBlackboard>;

  private let m_VendorBlackboardDef: ref<UI_VendorDef>;

  private let m_VendorUpdatedCallbackID: ref<CallbackHandle>;

  private let m_craftingBlackboard: wref<IBlackboard>;

  private let m_craftingBlackboardDef: ref<UI_CraftingDef>;

  private let m_craftingCallbackID: ref<CallbackHandle>;

  private let m_playerFilterManager: ref<ItemCategoryFliterManager>;

  private let m_vendorFilterManager: ref<ItemCategoryFliterManager>;

  private let m_lastPlayerFilter: ItemFilterCategory;

  private let m_lastVendorFilter: ItemFilterCategory;

  private let m_uiScriptableSystem: wref<UIScriptableSystem>;

  private let m_uiSystem: ref<UISystem>;

  private let m_storageDef: ref<StorageBlackboardDef>;

  private let m_storageBlackboard: wref<IBlackboard>;

  private let m_itemDropQueue: array<ItemModParams>;

  private let m_soldItems: ref<SoldItemsCache>;

  private let m_isActivePanel: Bool;

  private let m_lastItemHoverOverEvent: ref<ItemDisplayHoverOverEvent>;

  private let m_isComparisionDisabled: Bool;

  private let m_lastRequestId: Int32;

  private let sellQueue: array<ref<VenodrRequestQueueEntry>>;

  private let buyQueue: array<ref<VenodrRequestQueueEntry>>;

  private final func InitializeVirtualLists() -> Void {
    this.m_itemsClassifier = new ItemDisplayTemplateClassifier();
    this.m_playerItemsDataView = new VendorDataView();
    this.m_playerDataSource = new ScriptableDataSource();
    this.m_playerItemsDataView.SetSource(this.m_playerDataSource);
    this.m_playerItemsDataView.EnableSorting();
    this.m_playerItemsDataView.SetOpenTime(this.m_VendorDataManager.GetOpenTime());
    this.m_virtualPlayerListController = inkWidgetRef.GetControllerByType(this.m_inventoryGridList, n"inkVirtualGridController") as inkVirtualGridController;
    this.m_virtualPlayerListController.SetClassifier(this.m_itemsClassifier);
    this.m_virtualPlayerListController.SetSource(this.m_playerItemsDataView);
    this.m_vendorItemsDataView = new VendorDataView();
    this.m_vendorDataSource = new ScriptableDataSource();
    this.m_vendorItemsDataView.SetSource(this.m_vendorDataSource);
    this.m_vendorItemsDataView.EnableSorting();
    this.m_vendorItemsDataView.SetVendorGrid(true);
    this.m_virtualVendorListController = inkWidgetRef.GetControllerByType(this.m_vendorInventoryGridList, n"inkVirtualGridController") as inkVirtualGridController;
    this.m_virtualVendorListController.SetClassifier(this.m_itemsClassifier);
    this.m_virtualVendorListController.SetSource(this.m_vendorItemsDataView);
  }

  protected cb func OnInitialize() -> Bool {
    this.SetTimeDilatation(true);
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnHandleGlobalInput");
  }

  protected cb func OnUninitialize() -> Bool {
    this.SetTimeDilatation(false);
    this.PlaySound(n"GameMenu", n"OnClose");
    this.m_InventoryManager.ClearInventoryItemDataCache();
    this.m_InventoryManager.UnInitialize();
    this.RemoveBB();
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnPostOnRelease");
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
    GameInstance.GetTelemetrySystem(this.m_player.GetGame()).LogVendorMenuState(this.m_VendorDataManager.GetVendorID(), false);
    this.m_playerItemsDataView.SetSource(null);
    this.m_virtualPlayerListController.SetClassifier(null);
    this.m_virtualPlayerListController.SetSource(null);
    this.m_vendorItemsDataView.SetSource(null);
    this.m_virtualVendorListController.SetSource(null);
    this.m_virtualVendorListController.SetClassifier(null);
    this.m_itemsClassifier = null;
    this.m_playerItemsDataView = null;
    this.m_playerDataSource = null;
    this.m_vendorItemsDataView = null;
    this.m_vendorDataSource = null;
    GameInstance.GetAutoSaveSystem(this.GetPlayerControlledObject().GetGame()).RequestCheckpoint();
  }

  public final func SetTimeDilatation(enable: Bool) -> Void {
    let timeDilationReason: CName = n"VendorStash";
    let timeSystem: ref<TimeSystem> = GameInstance.GetTimeSystem(this.m_player.GetGame());
    if enable {
      timeSystem.SetTimeDilation(timeDilationReason, 0.01, n"Linear", n"Linear");
      timeSystem.SetTimeDilationOnLocalPlayerZero(timeDilationReason, 0.01, n"Linear", n"Linear");
    } else {
      timeSystem.UnsetTimeDilation(timeDilationReason);
      timeSystem.UnsetTimeDilationOnLocalPlayerZero();
    };
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
      this.m_menuEventDispatcher.SpawnEvent(n"OnVendorClose");
    };
  }

  protected cb func OnVendorHubMenuChanged(evt: ref<VendorHubMenuChanged>) -> Bool {
    this.m_isActivePanel = Equals(evt.item, HubVendorMenuItems.Trade);
  }

  protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    let vendorData: VendorData;
    let vendorName: String;
    let vendorPanelData: ref<VendorPanelData>;
    this.m_storageDef = GetAllBlackboardDefs().StorageBlackboard;
    this.m_storageBlackboard = this.GetBlackboardSystem().Get(this.m_storageDef);
    let storageUserData: ref<StorageUserData> = FromVariant(this.m_storageBlackboard.GetVariant(this.m_storageDef.StorageData));
    if userData == null && storageUserData == null {
      return false;
    };
    inkWidgetRef.SetVisible(this.m_quantityPicker, false);
    this.m_vendorUserData = userData as VendorUserData;
    this.m_storageUserData = storageUserData;
    if IsDefined(this.m_vendorUserData) || IsDefined(this.m_storageUserData) {
      vendorPanelData = this.m_vendorUserData.vendorData;
      vendorData = vendorPanelData.data;
      this.m_VendorDataManager = new VendorDataManager();
      if IsDefined(this.m_vendorUserData) {
        this.m_VendorDataManager.Initialize(this.GetPlayerControlledObject(), vendorData.entityID);
        vendorName = this.m_VendorDataManager.GetVendorName();
        if !IsStringValid(vendorName) {
          vendorName = "MISSING VENDOR NAME";
        };
        inkTextRef.SetText(this.m_vendorName, vendorName);
      } else {
        if IsDefined(this.m_storageUserData) {
          this.m_VendorDataManager.Initialize(this.GetPlayerControlledObject(), storageUserData.storageObject.GetEntityID());
          inkWidgetRef.SetVisible(this.m_playerBalance, false);
          inkWidgetRef.SetVisible(this.m_vendorBalance, false);
          inkTextRef.SetText(this.m_vendorName, "Gameplay-Scanning-Devices-GameplayRoles-Storage");
        };
      };
      this.m_lastVendorFilter = ItemFilterCategory.AllItems;
      this.Init();
      this.UpdateVendorMoney();
      this.UpdatePlayerMoney();
      this.m_vendorItemsDataView.DisableSorting();
      this.PopulateVendorInventory();
      this.ShowHideVendorStock();
      this.m_playerItemsDataView.DisableSorting();
      this.PopulatePlayerInventory();
      this.SetupDropdown();
      this.PlayLibraryAnimation(n"vendor_intro");
    };
  }

  private final func SetupDropdown() -> Void {
    let controller: ref<DropdownListController>;
    let data: ref<DropdownItemData>;
    let playerSortingButtonController: ref<DropdownButtonController>;
    let sorting: Int32;
    let vendorSortingButtonController: ref<DropdownButtonController>;
    inkWidgetRef.RegisterToCallback(this.m_playerSortingButton, n"OnRelease", this, n"OnPlayerSortingButtonClicked");
    inkWidgetRef.RegisterToCallback(this.m_vendorSortingButton, n"OnRelease", this, n"OnVendorSortingButtonClicked");
    controller = inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController;
    playerSortingButtonController = inkWidgetRef.GetController(this.m_playerSortingButton) as DropdownButtonController;
    vendorSortingButtonController = inkWidgetRef.GetController(this.m_vendorSortingButton) as DropdownButtonController;
    controller.Setup(this, SortingDropdownData.GetDefaultDropdownOptions());
    sorting = this.m_uiScriptableSystem.GetVendorPanelPlayerActiveSorting(EnumInt(ItemSortMode.Default));
    data = SortingDropdownData.GetDropdownOption(controller.GetData(), IntEnum(sorting));
    playerSortingButtonController.SetData(data);
    this.m_playerItemsDataView.SetSortMode(FromVariant(data.identifier));
    sorting = this.m_uiScriptableSystem.GetVendorPanelVendorActiveSorting(EnumInt(ItemSortMode.Default));
    data = SortingDropdownData.GetDropdownOption(controller.GetData(), IntEnum(sorting));
    vendorSortingButtonController.SetData(data);
    this.m_vendorItemsDataView.SetSortMode(FromVariant(data.identifier));
  }

  protected cb func OnDropdownItemClickedEvent(evt: ref<DropdownItemClickedEvent>) -> Bool {
    let setPlayerSortingRequest: ref<UIScriptableSystemSetVendorPanelPlayerSorting>;
    let setVendorSortingRequest: ref<UIScriptableSystemSetVendorPanelVendorSorting>;
    let identifier: ItemSortMode = FromVariant(evt.identifier);
    let data: ref<DropdownItemData> = SortingDropdownData.GetDropdownOption((inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController).GetData(), identifier);
    if IsDefined(data) {
      if evt.triggerButton.GetRootWidget() == inkWidgetRef.Get(this.m_playerSortingButton) {
        evt.triggerButton.SetData(data);
        this.m_playerItemsDataView.SetSortMode(identifier);
        setPlayerSortingRequest = new UIScriptableSystemSetVendorPanelPlayerSorting();
        setPlayerSortingRequest.sortMode = EnumInt(identifier);
        this.m_uiScriptableSystem.QueueRequest(setPlayerSortingRequest);
      } else {
        if evt.triggerButton.GetRootWidget() == inkWidgetRef.Get(this.m_vendorSortingButton) {
          evt.triggerButton.SetData(data);
          this.m_vendorItemsDataView.SetSortMode(identifier);
          setVendorSortingRequest = new UIScriptableSystemSetVendorPanelVendorSorting();
          setVendorSortingRequest.sortMode = EnumInt(identifier);
          this.m_uiScriptableSystem.QueueRequest(setVendorSortingRequest);
        };
      };
    };
  }

  protected cb func OnPlayerSortingButtonClicked(evt: ref<inkPointerEvent>) -> Bool {
    let controller: ref<DropdownListController>;
    if evt.IsAction(n"click") {
      this.PlaySound(n"Button", n"OnPress");
      inkWidgetRef.SetTranslation(this.m_sortingDropdown, new Vector2(1119.00, 268.00));
      controller = inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController;
      controller.SetTriggerButton(inkWidgetRef.GetController(this.m_playerSortingButton) as DropdownButtonController);
      controller.Toggle();
      this.OnInventoryItemHoverOut(null);
    };
  }

  protected cb func OnVendorSortingButtonClicked(evt: ref<inkPointerEvent>) -> Bool {
    let controller: ref<DropdownListController>;
    if evt.IsAction(n"click") {
      this.PlaySound(n"Button", n"OnPress");
      inkWidgetRef.SetTranslation(this.m_sortingDropdown, new Vector2(2650.00, 270.00));
      controller = inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController;
      controller.SetTriggerButton(inkWidgetRef.GetController(this.m_vendorSortingButton) as DropdownButtonController);
      controller.Toggle();
      this.OnInventoryItemHoverOut(null);
    };
  }

  private final func SetFilters(root: inkWidgetRef, data: array<Int32>, callback: CName) -> Void {
    let radioGroup: ref<FilterRadioGroup> = inkWidgetRef.GetControllerByType(root, n"FilterRadioGroup") as FilterRadioGroup;
    radioGroup.SetData(data);
    radioGroup.RegisterToCallback(n"OnValueChanged", this, callback);
    if ArraySize(data) == 1 {
      radioGroup.Toggle(data[0]);
    };
  }

  private final func ToggleFilter(root: inkWidgetRef, data: Int32) -> Void {
    let radioGroup: ref<FilterRadioGroup> = inkWidgetRef.GetControllerByType(root, n"FilterRadioGroup") as FilterRadioGroup;
    radioGroup.ToggleData(data);
  }

  protected cb func OnPlayerFilterChange(controller: wref<inkRadioGroupController>, selectedIndex: Int32) -> Bool {
    let category: ItemFilterCategory = this.m_playerFilterManager.GetAt(selectedIndex);
    this.m_playerItemsDataView.SetFilterType(category);
    this.m_lastPlayerFilter = category;
    this.m_playerItemsDataView.SetSortMode(this.m_playerItemsDataView.GetSortMode());
    this.PlayLibraryAnimation(n"player_grid_show");
    (inkWidgetRef.GetController(this.m_playerInventoryGridScroll) as inkScrollController).SetScrollPosition(0.00);
  }

  protected cb func OnVendorFilterChange(controller: wref<inkRadioGroupController>, selectedIndex: Int32) -> Bool {
    let category: ItemFilterCategory = this.m_vendorFilterManager.GetAt(selectedIndex);
    this.m_vendorItemsDataView.SetFilterType(category);
    this.m_lastVendorFilter = category;
    this.m_vendorItemsDataView.SetSortMode(this.m_vendorItemsDataView.GetSortMode());
    this.PlayLibraryAnimation(n"vendor_grid_show");
    (inkWidgetRef.GetController(this.m_vendorInventoryGridScroll) as inkScrollController).SetScrollPosition(0.00);
  }

  private final func Init() -> Void {
    this.m_player = this.GetPlayerControlledObject() as PlayerPuppet;
    this.m_TooltipsManager = inkWidgetRef.GetControllerByType(this.m_TooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_TooltipsManager.Setup(ETooltipsStyle.Menus);
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
      this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    };
    this.m_InventoryManager = new InventoryDataManagerV2();
    this.m_InventoryManager.Initialize(this.m_player);
    this.m_itemTypeSorting = InventoryDataManagerV2.GetItemTypesForSorting();
    this.m_VendorDataManager.UpdateOpenTime(this.m_player.GetGame());
    this.m_comparisonResolver = ItemPreferredComparisonResolver.Make(this.m_InventoryManager);
    inkCompoundRef.RemoveAllChildren(this.m_vendorSpecialOffersInventoryGridList);
    inkCompoundRef.RemoveAllChildren(this.m_vendorInventoryGridList);
    inkCompoundRef.RemoveAllChildren(this.m_inventoryGridList);
    this.SetupBB();
    this.InitializeVirtualLists();
    this.m_uiScriptableSystem = UIScriptableSystem.GetInstance(this.m_player.GetGame());
    this.m_isComparisionDisabled = this.m_uiScriptableSystem.IsComparisionTooltipDisabled();
    this.m_buttonHintsController.AddButtonHint(n"toggle_comparison_tooltip", GetLocalizedText(this.m_isComparisionDisabled ? "UI-UserActions-EnableComparison" : "UI-UserActions-DisableComparison"));
    this.m_playerFilterManager = ItemCategoryFliterManager.Make();
    this.m_vendorFilterManager = ItemCategoryFliterManager.Make();
    this.m_soldItems = new SoldItemsCache();
    this.PlaySound(n"GameMenu", n"OnOpen");
    this.SpawnFromExternal(inkWidgetRef.Get(this.m_notificationRoot), r"base\\gameplay\\gui\\widgets\\activity_log\\activity_log_panels.inkwidget", n"RootVert");
    GameInstance.GetTelemetrySystem(this.m_player.GetGame()).LogVendorMenuState(this.m_VendorDataManager.GetVendorID(), true);
  }

  protected cb func OnUIVendorItemSoldEvent(evt: ref<UIVendorItemsSoldEvent>) -> Bool {
    let limit: Int32;
    let i: Int32 = ArraySize(this.sellQueue) - 1;
    while i >= 0 {
      if this.sellQueue[i].requestID == evt.requestID {
        ArrayRemove(this.sellQueue, this.sellQueue[i]);
      };
      i -= 1;
    };
    this.m_lastVendorFilter = ItemFilterCategory.Buyback;
    i = 0;
    limit = ArraySize(evt.itemsID);
    while i < limit {
      this.m_soldItems.AddItem(evt.itemsID[i], evt.quantity[i], evt.piecesPrice[i]);
      i += 1;
    };
    this.m_InventoryManager.MarkToRebuild();
    this.UpdateVendorMoney();
    this.UpdatePlayerMoney();
    this.PopulateVendorInventory();
    this.ShowHideVendorStock();
    this.PopulatePlayerInventory();
  }

  protected cb func OnUIVendorItemBoughtEvent(evt: ref<UIVendorItemsBoughtEvent>) -> Bool {
    let category: ItemFilterCategory;
    let limit: Int32;
    let i: Int32 = ArraySize(this.buyQueue) - 1;
    while i >= 0 {
      if this.buyQueue[i].requestID == evt.requestID {
        ArrayRemove(this.buyQueue, this.buyQueue[i]);
      };
      i -= 1;
    };
    i = 0;
    limit = ArraySize(evt.itemsID);
    while i < limit {
      this.m_soldItems.RemoveItem(evt.itemsID[i], evt.quantity[i]);
      category = ItemCategoryFliter.GetItemCategoryType(this.m_InventoryManager.GetPlayerItemData(evt.itemsID[i]));
      if NotEquals(category, ItemFilterCategory.Invalid) {
        this.m_lastPlayerFilter = category;
      };
      i += 1;
    };
    this.m_InventoryManager.MarkToRebuild();
    this.UpdateVendorMoney();
    this.UpdatePlayerMoney();
    this.PopulateVendorInventory();
    this.ShowHideVendorStock();
    this.PopulatePlayerInventory();
  }

  protected cb func OnCraftingComplete(value: Variant) -> Bool {
    let command: CraftingCommands = FromVariant(this.m_craftingBlackboard.GetVariant(GetAllBlackboardDefs().UI_Crafting.lastCommand));
    if Equals(command, CraftingCommands.DisassemblingFinished) {
      this.m_InventoryManager.MarkToRebuild();
      this.UpdateVendorMoney();
      this.UpdatePlayerMoney();
      this.PopulateVendorInventory();
      this.ShowHideVendorStock();
      this.PopulatePlayerInventory();
    };
  }

  private final func SetupBB() -> Void {
    this.m_VendorBlackboardDef = GetAllBlackboardDefs().UI_Vendor;
    this.m_VendorBlackboard = this.GetBlackboardSystem().Get(this.m_VendorBlackboardDef);
    if IsDefined(this.m_VendorBlackboard) {
      this.m_VendorUpdatedCallbackID = this.m_VendorBlackboard.RegisterDelayedListenerVariant(this.m_VendorBlackboardDef.VendorData, this, n"OnVendorUpdated");
    };
    this.m_craftingBlackboardDef = GetAllBlackboardDefs().UI_Crafting;
    this.m_craftingBlackboard = this.GetBlackboardSystem().Get(this.m_craftingBlackboardDef);
    if IsDefined(this.m_craftingBlackboard) {
      this.m_craftingCallbackID = this.m_craftingBlackboard.RegisterDelayedListenerVariant(this.m_craftingBlackboardDef.lastItem, this, n"OnCraftingComplete", true);
    };
  }

  private final func RemoveBB() -> Void {
    if IsDefined(this.m_VendorBlackboard) {
      this.m_VendorBlackboard.UnregisterDelayedListener(this.m_VendorBlackboardDef.VendorData, this.m_VendorUpdatedCallbackID);
    };
    if IsDefined(this.m_craftingBlackboard) {
      this.m_craftingBlackboard.UnregisterDelayedListener(this.m_craftingBlackboardDef.lastItem, this.m_craftingCallbackID);
    };
    this.m_VendorBlackboard = null;
    this.m_storageBlackboard = null;
    this.m_storageUserData = null;
  }

  private final func Update() -> Void {
    this.m_InventoryManager.MarkToRebuild();
    this.UpdateVendorMoney();
    this.UpdatePlayerMoney();
    this.PopulateVendorInventory();
    this.ShowHideVendorStock();
    this.PopulatePlayerInventory();
  }

  private final func UpdateVendorMoney() -> Void {
    let vendorMoney: Int32 = MarketSystem.GetVendorMoney(this.m_VendorDataManager.GetVendorInstance());
    inkTextRef.SetText(this.m_vendorMoney, IntToString(vendorMoney));
  }

  private final func UpdatePlayerMoney() -> Void {
    inkTextRef.SetText(this.m_playerMoney, IntToString(this.m_VendorDataManager.GetLocalPlayerCurrencyAmount()));
  }

  private final func ShowHideVendorStock() -> Void {
    if inkCompoundRef.GetNumChildren(this.m_vendorSpecialOffersInventoryGridList) == 0 && inkCompoundRef.GetNumChildren(this.m_vendorInventoryGridList) == 0 {
    };
  }

  protected cb func OnInventoryClick(evt: ref<ItemDisplayClickEvent>) -> Bool {
    let itemData: InventoryItemData = evt.itemData;
    if IsDefined(this.m_vendorUserData) {
      this.HandleVendorSlotInput(evt, itemData);
    } else {
      if IsDefined(this.m_storageUserData) {
        this.HandleStorageSlotInput(evt, itemData);
      };
    };
  }

  protected cb func OnHandleGlobalInput(evt: ref<inkPointerEvent>) -> Bool {
    let setComparisionDisabledRequest: ref<UIScriptableSystemSetComparisionTooltipDisabled>;
    if evt.IsAction(n"sell_junk") {
      this.OpenSellJunkConfirmation();
    } else {
      if evt.IsAction(n"toggle_comparison_tooltip") {
        this.m_isComparisionDisabled = !this.m_isComparisionDisabled;
        this.m_buttonHintsController.AddButtonHint(n"toggle_comparison_tooltip", GetLocalizedText(this.m_isComparisionDisabled ? "UI-UserActions-EnableComparison" : "UI-UserActions-DisableComparison"));
        setComparisionDisabledRequest = new UIScriptableSystemSetComparisionTooltipDisabled();
        setComparisionDisabledRequest.value = this.m_isComparisionDisabled;
        this.m_uiScriptableSystem.QueueRequest(setComparisionDisabledRequest);
        this.InvalidateItemTooltipEvent();
      };
    };
  }

  private final func HandleVendorSlotInput(evt: ref<ItemDisplayClickEvent>, itemData: InventoryItemData) -> Void {
    let additionalInfo: ref<VendorRequirementsNotMetNotificationData>;
    let isIconic: Bool;
    let isLegendary: Bool;
    let localGameItemData: wref<gameItemData>;
    let requirement: SItemStackRequirementData;
    let vendorNotification: ref<UIMenuNotificationEvent>;
    if evt.actionName.IsAction(n"click") && !InventoryItemData.IsEmpty(itemData) {
      if !InventoryItemData.IsVendorItem(itemData) {
        if InventoryItemData.GetQuantity(itemData) == 1 {
          if InventoryItemData.IsEquipped(itemData) {
            this.OpenConfirmationPopup(itemData, InventoryItemData.GetQuantity(itemData), QuantityPickerActionType.Sell, VendorConfirmationPopupType.EquippedItem);
          } else {
            isLegendary = UIItemsHelper.QualityNameToInt(UIItemsHelper.QualityStringToStateName(NameToString(InventoryItemData.GetQuality(itemData)))) >= UIItemsHelper.QualityEnumToInt(gamedataQuality.Legendary);
            isIconic = RPGManager.IsItemIconic(InventoryItemData.GetGameItemData(itemData));
            if isLegendary || isIconic {
              this.OpenConfirmationPopup(itemData, InventoryItemData.GetQuantity(itemData), QuantityPickerActionType.Sell, VendorConfirmationPopupType.Default);
            } else {
              this.SellItem(InventoryItemData.GetGameItemData(itemData), InventoryItemData.GetQuantity(itemData));
            };
          };
        } else {
          this.OpenQuantityPicker(itemData, QuantityPickerActionType.Sell);
        };
      } else {
        if !InventoryItemData.IsRequirementMet(itemData) {
          requirement = InventoryItemData.GetRequirement(itemData);
          if Equals(requirement.statType, gamedataStatType.StreetCred) && InventoryItemData.GetPlayerStreetCred(itemData) < RoundF(requirement.requiredValue) {
            vendorNotification = new UIMenuNotificationEvent();
            vendorNotification.m_notificationType = UIMenuNotificationType.VendorRequirementsNotMet;
            additionalInfo = new VendorRequirementsNotMetNotificationData();
            additionalInfo.m_data = requirement;
            vendorNotification.m_additionalInfo = ToVariant(additionalInfo);
            GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(vendorNotification);
            this.PlaySound(n"MapPin", n"OnDelete");
            return;
          };
        };
        localGameItemData = InventoryItemData.GetGameItemData(itemData);
        if InventoryItemData.GetQuantity(itemData) == 1 {
          if evt.isBuybackStack {
            this.BuyItem(localGameItemData, InventoryItemData.GetQuantity(itemData), true);
          } else {
            this.BuyItem(localGameItemData, InventoryItemData.GetQuantity(itemData));
          };
          this.PlaySound(n"Item", n"OnBuy");
          this.m_TooltipsManager.HideTooltips();
        } else {
          if this.GetPrice(localGameItemData, QuantityPickerActionType.Buy, 1) <= this.m_VendorDataManager.GetLocalPlayerCurrencyAmount() {
            this.OpenQuantityPicker(itemData, QuantityPickerActionType.Buy, evt.isBuybackStack);
          };
        };
      };
    };
  }

  private final func HandleStorageSlotInput(evt: ref<ItemDisplayClickEvent>, itemData: InventoryItemData) -> Void {
    if evt.actionName.IsAction(n"click") && !InventoryItemData.IsEmpty(itemData) {
      if !InventoryItemData.IsVendorItem(itemData) {
        if InventoryItemData.GetQuantity(itemData) == 1 {
          this.m_VendorDataManager.TransferItem(this.m_player, this.m_VendorDataManager.GetVendorInstance(), InventoryItemData.GetGameItemData(itemData), InventoryItemData.GetQuantity(itemData));
          this.PlaySound(n"Item", n"OnBuy");
          this.m_TooltipsManager.HideTooltips();
        } else {
          this.OpenQuantityPicker(itemData, QuantityPickerActionType.TransferToStorage);
        };
      } else {
        if InventoryItemData.GetQuantity(itemData) == 1 {
          this.m_VendorDataManager.TransferItem(this.m_VendorDataManager.GetVendorInstance(), this.m_player, InventoryItemData.GetGameItemData(itemData), InventoryItemData.GetQuantity(itemData));
          this.PlaySound(n"Item", n"OnSell");
        } else {
          this.OpenQuantityPicker(itemData, QuantityPickerActionType.TransferToPlayer);
        };
      };
      this.Update();
    };
  }

  private final func OpenSellJunkConfirmation() -> Void {
    let data: ref<VendorSellJunkPopupData>;
    let resultPrice: Float;
    let vendorLimitResultPrice: Float;
    let vendorLimitSellabelItems: array<ref<VendorJunkSellItem>>;
    let vendorMoney: Int32;
    let sellableItems: array<wref<gameItemData>> = this.GetSellableJunk();
    if Cast(ArraySize(sellableItems)) {
      vendorMoney = MarketSystem.GetVendorMoney(this.m_VendorDataManager.GetVendorInstance());
      vendorLimitSellabelItems = this.GetLimitedSellableItems(sellableItems, vendorMoney);
      resultPrice = this.GetBulkSellPrice(sellableItems);
      vendorLimitResultPrice = this.GetBulkSellPrice(vendorLimitSellabelItems);
      data = new VendorSellJunkPopupData();
      data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\vendor_sell_junk_confirmation.inkwidget";
      data.isBlocking = true;
      data.useCursor = true;
      data.queueName = n"modal_popup";
      data.items = sellableItems;
      data.itemsQuantity = ArraySize(sellableItems);
      data.totalPrice = resultPrice;
      data.limitedTotalPrice = Cast(vendorLimitResultPrice);
      data.limitedItems = vendorLimitSellabelItems;
      data.limitedItemsQuantity = ArraySize(vendorLimitSellabelItems);
      this.m_sellJunkPopupToken = this.ShowGameNotification(data);
      this.m_sellJunkPopupToken.RegisterListener(this, n"OnSellJunkPopupClosed");
      this.m_buttonHintsController.Hide();
    };
  }

  protected cb func OnSellJunkPopupClosed(data: ref<inkGameNotificationData>) -> Bool {
    let amounts: array<Int32>;
    let i: Int32;
    let itemsData: array<wref<gameItemData>>;
    let limit: Int32;
    this.m_sellJunkPopupToken = null;
    let sellJunkData: ref<VendorSellJunkPopupCloseData> = data as VendorSellJunkPopupCloseData;
    if sellJunkData.confirm {
      i = 0;
      limit = ArraySize(sellJunkData.limitedItems);
      while i < limit {
        ArrayPush(itemsData, sellJunkData.limitedItems[i].item);
        ArrayPush(amounts, sellJunkData.limitedItems[i].quantity);
        i += 1;
      };
      this.m_VendorDataManager.SellItemsToVendor(itemsData, amounts);
      this.PlaySound(n"Item", n"OnSell");
      this.m_TooltipsManager.HideTooltips();
    } else {
      this.PlaySound(n"Button", n"OnPress");
    };
    this.m_buttonHintsController.Show();
  }

  protected cb func OnItemPreviewPopup(data: ref<inkGameNotificationData>) -> Bool {
    this.m_itemPreviewPopupToken = null;
  }

  private final func OpenQuantityPicker(itemData: InventoryItemData, actionType: QuantityPickerActionType, opt isBuyback: Bool) -> Void {
    let data: ref<QuantityPickerPopupData> = new QuantityPickerPopupData();
    data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\item_quantity_picker.inkwidget";
    data.isBlocking = true;
    data.useCursor = true;
    data.queueName = n"modal_popup";
    data.maxValue = InventoryItemData.GetQuantity(itemData);
    data.gameItemData = itemData;
    data.actionType = actionType;
    data.vendor = this.m_VendorDataManager.GetVendorInstance();
    data.isBuyback = isBuyback;
    this.m_quantityPickerPopupToken = this.ShowGameNotification(data);
    this.m_quantityPickerPopupToken.RegisterListener(this, n"OnQuantityPickerPopupClosed");
    this.m_buttonHintsController.Hide();
  }

  protected cb func OnQuantityPickerPopupClosed(data: ref<inkGameNotificationData>) -> Bool {
    let isIconic: Bool;
    let isLegendary: Bool;
    let localGameItemData: wref<gameItemData>;
    this.m_quantityPickerPopupToken = null;
    let quantityData: ref<QuantityPickerPopupCloseData> = data as QuantityPickerPopupCloseData;
    if quantityData.choosenQuantity != -1 {
      switch quantityData.actionType {
        case QuantityPickerActionType.TransferToStorage:
          this.m_VendorDataManager.TransferItem(this.m_player, this.m_VendorDataManager.GetVendorInstance(), InventoryItemData.GetGameItemData(quantityData.itemData), quantityData.choosenQuantity);
          this.PlaySound(n"Item", n"OnSell");
          this.m_TooltipsManager.HideTooltips();
          this.Update();
          break;
        case QuantityPickerActionType.TransferToPlayer:
          this.m_VendorDataManager.TransferItem(this.m_VendorDataManager.GetVendorInstance(), this.m_player, InventoryItemData.GetGameItemData(quantityData.itemData), quantityData.choosenQuantity);
          this.PlaySound(n"Item", n"OnSell");
          this.m_TooltipsManager.HideTooltips();
          this.Update();
          break;
        case QuantityPickerActionType.Buy:
          localGameItemData = InventoryItemData.GetGameItemData(quantityData.itemData);
          if quantityData.isBuyback {
            this.BuyItem(localGameItemData, quantityData.choosenQuantity, true);
          } else {
            this.BuyItem(localGameItemData, quantityData.choosenQuantity);
          };
          this.PlaySound(n"Item", n"OnBuy");
          this.m_TooltipsManager.HideTooltips();
          break;
        case QuantityPickerActionType.Sell:
          isLegendary = UIItemsHelper.QualityNameToInt(UIItemsHelper.QualityStringToStateName(NameToString(InventoryItemData.GetQuality(quantityData.itemData)))) >= UIItemsHelper.QualityEnumToInt(gamedataQuality.Legendary);
          isIconic = RPGManager.IsItemIconic(InventoryItemData.GetGameItemData(quantityData.itemData));
          if isLegendary || isIconic {
            this.OpenConfirmationPopup(quantityData.itemData, quantityData.choosenQuantity, quantityData.actionType);
          } else {
            this.SellItem(InventoryItemData.GetGameItemData(quantityData.itemData), quantityData.choosenQuantity);
            this.PlaySound(n"Item", n"OnSell");
            this.m_TooltipsManager.HideTooltips();
          };
      };
    };
    this.m_buttonHintsController.Show();
    this.PlaySound(n"Button", n"OnPress");
  }

  private final func GetPrice(item: ref<gameItemData>, actionType: QuantityPickerActionType, quantity: Int32) -> Int32 {
    if Equals(actionType, QuantityPickerActionType.Buy) {
      return MarketSystem.GetBuyPrice(this.m_VendorDataManager.GetVendorInstance(), item.GetID()) * quantity;
    };
    return RPGManager.CalculateSellPrice(this.m_VendorDataManager.GetVendorInstance().GetGame(), this.m_VendorDataManager.GetVendorInstance(), item.GetID()) * quantity;
  }

  private final func OpenConfirmationPopup(itemData: InventoryItemData, quantity: Int32, actionType: QuantityPickerActionType, opt type: VendorConfirmationPopupType) -> Void {
    let data: ref<VendorConfirmationPopupData> = new VendorConfirmationPopupData();
    data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\vendor_confirmation.inkwidget";
    data.isBlocking = true;
    data.useCursor = true;
    data.queueName = n"modal_popup";
    data.itemData = itemData;
    data.quantity = quantity;
    data.type = type;
    data.price = this.GetPrice(InventoryItemData.GetGameItemData(itemData), actionType, quantity);
    this.m_confirmationPopupToken = this.ShowGameNotification(data);
    this.m_confirmationPopupToken.RegisterListener(this, n"OnConfirmationPopupClosed");
    this.m_buttonHintsController.Hide();
  }

  protected cb func OnConfirmationPopupClosed(data: ref<inkGameNotificationData>) -> Bool {
    this.m_confirmationPopupToken = null;
    let resultData: ref<VendorConfirmationPopupCloseData> = data as VendorConfirmationPopupCloseData;
    if resultData.confirm {
      this.SellItem(InventoryItemData.GetGameItemData(resultData.itemData), resultData.quantity);
    };
    this.m_buttonHintsController.Show();
    this.PlaySound(n"Button", n"OnPress");
  }

  private final func SellItem(itemData: ref<gameItemData>, quantity: Int32) -> Void {
    let queueEntry: ref<VenodrRequestQueueEntry>;
    let itemID: ItemID = itemData.GetID();
    if !this.IsSellRequestInQueue(itemID) && this.m_VendorDataManager.CanPlayerSellItem(itemID) {
      this.m_lastRequestId += 1;
      queueEntry = new VenodrRequestQueueEntry();
      queueEntry.requestID = this.m_lastRequestId;
      queueEntry.itemID = itemID;
      ArrayPush(this.sellQueue, queueEntry);
      this.m_VendorDataManager.SellItemToVendor(itemData, quantity, queueEntry.requestID);
      this.PlaySound(n"Item", n"OnSell");
      this.m_TooltipsManager.HideTooltips();
    };
  }

  private final func IsBuyRequestInQueue(itemID: ItemID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.buyQueue) {
      if this.buyQueue[i].itemID == itemID {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func IsSellRequestInQueue(itemID: ItemID) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.sellQueue) {
      if this.sellQueue[i].itemID == itemID {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func BuyItem(itemData: ref<gameItemData>, quantity: Int32, opt buyback: Bool) -> Void {
    let queueEntry: ref<VenodrRequestQueueEntry>;
    let itemID: ItemID = itemData.GetID();
    if !this.IsBuyRequestInQueue(itemID) {
      this.m_lastRequestId += 1;
      queueEntry = new VenodrRequestQueueEntry();
      queueEntry.requestID = this.m_lastRequestId;
      queueEntry.itemID = itemID;
      ArrayPush(this.buyQueue, queueEntry);
      if buyback {
        this.m_VendorDataManager.BuybackItemFromVendor(itemData, quantity, queueEntry.requestID);
      } else {
        this.m_VendorDataManager.BuyItemFromVendor(itemData, quantity, queueEntry.requestID);
      };
    };
  }

  private final func PopulateVendorInventory() -> Void {
    let BuybackVendorInventoryData: ref<VendorInventoryItemData>;
    let cacheItem: ref<SoldItem>;
    let i: Int32;
    let items: array<ref<IScriptable>>;
    let j: Int32;
    let localQuantity: Int32;
    let playerMoney: Int32;
    let specialOffers: array<InventoryItemData>;
    let storageItems: array<ref<gameItemData>>;
    let vendorInventory: array<InventoryItemData>;
    let vendorInventoryData: ref<VendorInventoryItemData>;
    let vendorInventorySize: Int32;
    this.m_vendorFilterManager.Clear();
    this.m_vendorFilterManager.AddFilter(ItemFilterCategory.AllItems);
    if IsDefined(this.m_vendorUserData) {
      specialOffers = this.ConvertGameDataIntoInventoryData(this.m_VendorDataManager.GetVendorSpecialOffers(), this.m_VendorDataManager.GetVendorInstance(), true);
      vendorInventory = this.ConvertGameDataIntoInventoryData(this.m_VendorDataManager.GetVendorInventoryItems(), this.m_VendorDataManager.GetVendorInstance(), true);
      vendorInventorySize = ArraySize(vendorInventory);
      if ArraySize(specialOffers) <= 0 {
        inkWidgetRef.SetVisible(this.m_specialOffersWrapper, false);
      } else {
        inkWidgetRef.SetVisible(this.m_specialOffersWrapper, true);
      };
      playerMoney = this.m_VendorDataManager.GetLocalPlayerCurrencyAmount();
      i = 0;
      while i < vendorInventorySize {
        cacheItem = this.m_soldItems.GetItem(InventoryItemData.GetID(vendorInventory[i]));
        vendorInventoryData = new VendorInventoryItemData();
        vendorInventoryData.ItemData = vendorInventory[i];
        this.m_InventoryManager.GetOrCreateInventoryItemSortData(vendorInventoryData.ItemData, this.m_uiScriptableSystem);
        vendorInventoryData.IsVendorItem = true;
        vendorInventoryData.IsEnoughMoney = playerMoney >= Cast(InventoryItemData.GetBuyPrice(vendorInventory[i]));
        vendorInventoryData.ComparisonState = this.GetComparisonState(vendorInventoryData.ItemData);
        if cacheItem != null {
          localQuantity = InventoryItemData.GetQuantity(vendorInventory[i]);
          if cacheItem.quantity == localQuantity {
            vendorInventoryData.IsBuybackStack = true;
          } else {
            if localQuantity > cacheItem.quantity {
              InventoryItemData.SetQuantity(vendorInventoryData.ItemData, localQuantity - cacheItem.quantity);
              BuybackVendorInventoryData = new VendorInventoryItemData();
              BuybackVendorInventoryData.ItemData = vendorInventory[i];
              this.m_InventoryManager.GetOrCreateInventoryItemSortData(BuybackVendorInventoryData.ItemData, this.m_uiScriptableSystem);
              BuybackVendorInventoryData.IsVendorItem = true;
              BuybackVendorInventoryData.IsEnoughMoney = playerMoney >= Cast(InventoryItemData.GetBuyPrice(vendorInventory[i]));
              BuybackVendorInventoryData.ComparisonState = this.GetComparisonState(vendorInventoryData.ItemData);
              BuybackVendorInventoryData.IsBuybackStack = true;
              InventoryItemData.SetQuantity(BuybackVendorInventoryData.ItemData, cacheItem.quantity);
              ArrayPush(items, BuybackVendorInventoryData);
            } else {
              cacheItem;
            };
          };
        };
        if vendorInventoryData.IsBuybackStack {
          this.m_vendorFilterManager.AddFilter(ItemFilterCategory.Buyback);
        } else {
          this.m_vendorFilterManager.AddItem(InventoryItemData.GetGameItemData(vendorInventoryData.ItemData));
        };
        ArrayPush(items, vendorInventoryData);
        i += 1;
      };
    } else {
      if IsDefined(this.m_storageUserData) {
        storageItems = this.m_VendorDataManager.GetStorageItems();
        j = 0;
        while j < ArraySize(storageItems) {
          vendorInventoryData = new VendorInventoryItemData();
          this.m_InventoryManager.GetCachedInventoryItemData(storageItems[j], vendorInventoryData.ItemData);
          this.m_InventoryManager.GetOrCreateInventoryItemSortData(vendorInventoryData.ItemData, this.m_uiScriptableSystem);
          InventoryItemData.SetIsVendorItem(vendorInventoryData.ItemData, true);
          vendorInventoryData.IsVendorItem = true;
          vendorInventoryData.IsEnoughMoney = true;
          vendorInventoryData.ComparisonState = this.GetComparisonState(vendorInventoryData.ItemData);
          ArrayPush(items, vendorInventoryData);
          j += 1;
        };
      };
    };
    this.m_vendorDataSource.Reset(items);
    this.m_vendorFilterManager.SortFiltersList();
    this.m_vendorFilterManager.InsertFilter(0, ItemFilterCategory.AllItems);
    this.SetFilters(this.m_vendorFiltersContainer, this.m_vendorFilterManager.GetIntFiltersList(), n"OnVendorFilterChange");
    this.m_vendorItemsDataView.EnableSorting();
    this.m_vendorItemsDataView.SetFilterType(this.m_lastVendorFilter);
    this.m_vendorItemsDataView.SetSortMode(this.m_vendorItemsDataView.GetSortMode());
    this.m_vendorItemsDataView.DisableSorting();
    this.ToggleFilter(this.m_vendorFiltersContainer, EnumInt(this.m_lastVendorFilter));
    inkWidgetRef.SetVisible(this.m_vendorFiltersContainer, ArraySize(items) > 0);
    this.PlayLibraryAnimation(n"vendor_grid_show");
  }

  private final func GetAllSellable() -> Void;

  private final func GetSellableJunk() -> array<wref<gameItemData>> {
    let result: array<wref<gameItemData>>;
    let sellableItems: array<ref<gameItemData>> = this.m_VendorDataManager.GetItemsPlayerCanSell();
    let i: Int32 = 0;
    while i < ArraySize(sellableItems) {
      if Equals(RPGManager.GetItemRecord(sellableItems[i].GetID()).ItemType().Type(), gamedataItemType.Gen_Junk) {
        ArrayPush(result, sellableItems[i]);
      };
      i += 1;
    };
    return result;
  }

  private final func GetLimitedSellableItems(items: array<wref<gameItemData>>, moneyLimit: Int32) -> array<ref<VendorJunkSellItem>> {
    let currentResultItem: ref<VendorJunkSellItem>;
    let itemId: ItemID;
    let itemPrice: Int32;
    let j: Int32;
    let quantityLeft: Int32;
    let result: array<ref<VendorJunkSellItem>>;
    let moneyLeft: Int32 = moneyLimit;
    let i: Int32 = 0;
    while i < ArraySize(items) {
      quantityLeft = items[i].GetQuantity();
      itemId = items[i].GetID();
      if !this.m_VendorDataManager.CanPlayerSellItem(itemId) {
      } else {
        itemPrice = this.m_VendorDataManager.GetSellingPrice(itemId);
        while moneyLeft >= itemPrice && quantityLeft > 0 {
          j = 0;
          while j < ArraySize(result) {
            if result[j].item.GetID() == itemId {
              currentResultItem = result[j];
            };
            j += 1;
          };
          if currentResultItem == null {
            currentResultItem = new VendorJunkSellItem();
            currentResultItem.item = items[i];
            ArrayPush(result, currentResultItem);
          };
          currentResultItem.quantity += 1;
          moneyLeft -= itemPrice;
          quantityLeft -= 1;
          currentResultItem = null;
        };
      };
      i += 1;
    };
    return result;
  }

  private final func GetBulkSellPrice(items: array<wref<gameItemData>>) -> Float {
    let sum: Float;
    let unitPrice: Float;
    let i: Int32 = 0;
    while i < ArraySize(items) {
      unitPrice = Cast(this.m_VendorDataManager.GetSellingPrice(items[i].GetID()));
      sum += unitPrice * Cast(items[i].GetQuantity());
      i += 1;
    };
    return sum;
  }

  private final func GetBulkSellPrice(items: array<ref<VendorJunkSellItem>>) -> Float {
    let sum: Float;
    let unitPrice: Float;
    let i: Int32 = 0;
    while i < ArraySize(items) {
      unitPrice = Cast(this.m_VendorDataManager.GetSellingPrice(items[i].item.GetID()));
      sum += unitPrice * Cast(items[i].quantity);
      i += 1;
    };
    return sum;
  }

  private final func PopulatePlayerInventory() -> Void {
    let hasJunkItems: Bool;
    let i: Int32;
    let items: array<ref<IScriptable>>;
    let j: Int32;
    let playerItems: array<wref<gameItemData>>;
    let sellableItems: array<ref<gameItemData>>;
    let tagsFilter: array<CName>;
    let vendorInventoryData: ref<VendorInventoryItemData>;
    this.m_playerFilterManager.Clear();
    this.m_playerFilterManager.AddFilter(ItemFilterCategory.AllItems);
    if IsDefined(this.m_vendorUserData) {
      sellableItems = this.m_VendorDataManager.GetItemsPlayerCanSell();
      i = 0;
      while i < ArraySize(sellableItems) {
        vendorInventoryData = new VendorInventoryItemData();
        vendorInventoryData.IsVendorItem = false;
        this.m_InventoryManager.GetCachedInventoryItemData(sellableItems[i], vendorInventoryData.ItemData);
        this.m_InventoryManager.GetOrCreateInventoryItemSortData(vendorInventoryData.ItemData, this.m_uiScriptableSystem);
        if !hasJunkItems && Equals(InventoryItemData.GetItemType(vendorInventoryData.ItemData), gamedataItemType.Gen_Junk) {
          hasJunkItems = true;
        };
        InventoryItemData.SetPrice(vendorInventoryData.ItemData, Cast(this.m_VendorDataManager.GetSellingPrice(InventoryItemData.GetID(vendorInventoryData.ItemData))));
        InventoryItemData.SetIsVendorItem(vendorInventoryData.ItemData, false);
        vendorInventoryData.ComparisonState = this.GetComparisonState(vendorInventoryData.ItemData);
        ArrayPush(items, vendorInventoryData);
        this.m_playerFilterManager.AddItem(InventoryItemData.GetGameItemData(vendorInventoryData.ItemData));
        i += 1;
      };
      if hasJunkItems {
        this.m_buttonHintsController.AddButtonHint(n"sell_junk", GetLocalizedText("UI-UserActions-SellJunk"));
      } else {
        this.m_buttonHintsController.RemoveButtonHint(n"sell_junk");
      };
    } else {
      if IsDefined(this.m_storageUserData) {
        ArrayPush(tagsFilter, n"HideInBackpackUI");
        ArrayPush(tagsFilter, n"SoftwareShard");
        playerItems = this.m_InventoryManager.GetPlayerInventory(tagsFilter);
        j = 0;
        while j < ArraySize(playerItems) {
          vendorInventoryData = new VendorInventoryItemData();
          vendorInventoryData.IsVendorItem = false;
          this.m_InventoryManager.GetCachedInventoryItemData(playerItems[j], vendorInventoryData.ItemData);
          this.m_InventoryManager.GetOrCreateInventoryItemSortData(vendorInventoryData.ItemData, this.m_uiScriptableSystem);
          InventoryItemData.SetPrice(vendorInventoryData.ItemData, Cast(this.m_VendorDataManager.GetSellingPrice(InventoryItemData.GetID(vendorInventoryData.ItemData))));
          InventoryItemData.SetIsVendorItem(vendorInventoryData.ItemData, false);
          vendorInventoryData.ComparisonState = this.GetComparisonState(vendorInventoryData.ItemData);
          ArrayPush(items, vendorInventoryData);
          this.m_playerFilterManager.AddItem(InventoryItemData.GetGameItemData(vendorInventoryData.ItemData));
          j += 1;
        };
      };
    };
    this.m_playerDataSource.Reset(items);
    this.SetFilters(this.m_playerFiltersContainer, this.m_playerFilterManager.GetSortedIntFiltersList(), n"OnPlayerFilterChange");
    this.m_playerItemsDataView.EnableSorting();
    this.m_playerItemsDataView.SetFilterType(this.m_lastPlayerFilter);
    this.m_playerItemsDataView.SetSortMode(this.m_playerItemsDataView.GetSortMode());
    this.m_playerItemsDataView.DisableSorting();
    this.ToggleFilter(this.m_playerFiltersContainer, EnumInt(this.m_lastPlayerFilter));
    this.PlayLibraryAnimation(n"player_grid_show");
  }

  private final func GetComparisonState(item: InventoryItemData) -> ItemComparisonState {
    if this.m_comparisonResolver.IsComparable(item) {
      return this.m_comparisonResolver.GetItemComparisonState(item);
    };
    return ItemComparisonState.Default;
  }

  private final func PrepareTooltips() -> Void {
    this.m_TooltipsManager = inkWidgetRef.GetControllerByType(this.m_TooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_TooltipsManager.Setup(ETooltipsStyle.Menus);
  }

  private final func InvalidateItemTooltipEvent() -> Void {
    if this.m_lastItemHoverOverEvent != null {
      this.OnInventoryItemHoverOver(this.m_lastItemHoverOverEvent);
    };
  }

  protected cb func OnInventoryItemHoverOver(evt: ref<ItemDisplayHoverOverEvent>) -> Bool {
    let itemToComapre: InventoryItemData;
    let localizedHint: String;
    let itemData: InventoryItemData = evt.itemData;
    let controller: ref<DropdownListController> = inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController;
    this.m_lastItemHoverOverEvent = evt;
    if !controller.IsOpened() {
      if !InventoryItemData.IsEmpty(itemData) {
        if !this.m_isComparisionDisabled {
          itemToComapre = this.m_comparisonResolver.GetPreferredComparisonItem(itemData);
        };
        this.ShowTooltipsForItemController(evt.widget, itemToComapre, itemData, evt.display.DEBUG_GetIconErrorInfo(), evt.isBuybackStack);
      };
      if InventoryItemData.IsVendorItem(itemData) && !IsDefined(this.m_storageUserData) && IsDefined(this.m_vendorUserData) {
        localizedHint = GetLocalizedText("LocKey#17847");
      } else {
        if this.m_VendorDataManager.CanPlayerSellItem(InventoryItemData.GetID(itemData)) && !IsDefined(this.m_storageUserData) && IsDefined(this.m_vendorUserData) {
          localizedHint = GetLocalizedText("LocKey#17848");
        };
        if IsDefined(this.m_storageUserData) && !IsDefined(this.m_vendorUserData) {
          localizedHint = LocKeyToString(n"UI-UserActions-TransferItem");
        };
      };
      this.m_buttonHintsController.AddButtonHint(n"select", localizedHint);
    };
  }

  private final func ShowTooltipsForItemController(targetWidget: wref<inkWidget>, equippedItem: InventoryItemData, inspectedItemData: InventoryItemData, iconErrorInfo: ref<DEBUG_IconErrorInfo>, isBuybackStack: Bool) -> Void {
    let data: ref<InventoryTooltipData>;
    let isComparable: Bool;
    let tooltipData: ref<IdentifiedWrappedTooltipData>;
    let tooltipsData: array<ref<ATooltipData>>;
    let isPlayerItem: Bool = !InventoryItemData.IsVendorItem(inspectedItemData);
    let placement: gameuiETooltipPlacement = isPlayerItem ? gameuiETooltipPlacement.RightTop : gameuiETooltipPlacement.LeftTop;
    this.m_TooltipsManager.HideTooltips();
    if !InventoryItemData.IsEmpty(inspectedItemData) {
      isComparable = NotEquals(InventoryItemData.GetItemType(inspectedItemData), gamedataItemType.Prt_Program) && NotEquals(InventoryItemData.GetEquipmentArea(inspectedItemData), gamedataEquipmentArea.SystemReplacementCW);
      if !InventoryItemData.IsEmpty(equippedItem) && isComparable {
        if isPlayerItem {
          tooltipData = new IdentifiedWrappedTooltipData();
          tooltipData.m_identifier = n"itemTooltip";
          tooltipData.m_data = this.m_InventoryManager.GetComparisonTooltipsData(equippedItem, inspectedItemData, false, iconErrorInfo);
          ArrayPush(tooltipsData, tooltipData);
          tooltipData = new IdentifiedWrappedTooltipData();
          tooltipData.m_identifier = n"itemTooltipComparision";
          tooltipData.m_data = this.m_InventoryManager.GetComparisonTooltipsData(inspectedItemData, equippedItem, true);
          ArrayPush(tooltipsData, tooltipData);
        } else {
          tooltipData = new IdentifiedWrappedTooltipData();
          tooltipData.m_identifier = n"itemTooltip";
          data = this.m_InventoryManager.GetComparisonTooltipsData(inspectedItemData, equippedItem, true);
          data.displayContext = InventoryTooltipDisplayContext.Vendor;
          tooltipData.m_data = data;
          ArrayPush(tooltipsData, tooltipData);
          tooltipData = new IdentifiedWrappedTooltipData();
          tooltipData.m_identifier = n"itemTooltipComparision";
          data = this.m_InventoryManager.GetComparisonTooltipsData(equippedItem, inspectedItemData, false, iconErrorInfo);
          data.displayContext = InventoryTooltipDisplayContext.Vendor;
          if isBuybackStack {
            data.buyPrice = Cast(RPGManager.CalculateSellPrice(this.m_VendorDataManager.GetVendorInstance().GetGame(), this.m_VendorDataManager.GetVendorInstance(), InventoryItemData.GetID(inspectedItemData)));
          };
          tooltipData.m_data = data;
          ArrayPush(tooltipsData, tooltipData);
        };
        this.m_TooltipsManager.ShowTooltipsAtWidget(tooltipsData, targetWidget, placement);
      } else {
        data = this.m_InventoryManager.GetTooltipDataForInventoryItem(inspectedItemData, InventoryItemData.IsEquipped(inspectedItemData), iconErrorInfo, InventoryItemData.IsVendorItem(inspectedItemData));
        data.displayContext = InventoryTooltipDisplayContext.Vendor;
        if isBuybackStack {
          data.buyPrice = Cast(RPGManager.CalculateSellPrice(this.m_VendorDataManager.GetVendorInstance().GetGame(), this.m_VendorDataManager.GetVendorInstance(), InventoryItemData.GetID(inspectedItemData)));
        };
        if Equals(InventoryItemData.GetItemType(inspectedItemData), gamedataItemType.Prt_Program) {
          this.m_TooltipsManager.ShowTooltipAtWidget(n"programTooltip", targetWidget, data, placement);
        } else {
          if Equals(InventoryItemData.GetEquipmentArea(inspectedItemData), gamedataEquipmentArea.SystemReplacementCW) {
            this.m_TooltipsManager.ShowTooltipAtWidget(n"cyberdeckTooltip", targetWidget, data, placement);
          } else {
            this.m_TooltipsManager.ShowTooltipAtWidget(n"itemTooltip", targetWidget, data, placement);
          };
        };
      };
    };
  }

  protected cb func OnInventoryItemHoverOut(evt: ref<ItemDisplayHoverOutEvent>) -> Bool {
    this.m_TooltipsManager.HideTooltips();
    this.m_buttonHintsController.RemoveButtonHint(n"select");
    this.m_buttonHintsController.RemoveButtonHint(n"preview_item");
    this.m_lastItemHoverOverEvent = null;
  }

  private final func ConvertGameDataIntoInventoryData(data: array<ref<VendorGameItemData>>, opt owner: wref<GameObject>, opt isVendorItem: Bool) -> array<InventoryItemData> {
    let itemData: InventoryItemData;
    let itemDataArray: array<InventoryItemData>;
    let i: Int32 = 0;
    while i < ArraySize(data) {
      itemData = this.m_InventoryManager.GetInventoryItemData(owner, data[i].gameItemData, true);
      InventoryItemData.SetIsVendorItem(itemData, isVendorItem);
      InventoryItemData.SetIsRequirementMet(itemData, data[i].itemStack.isAvailable);
      InventoryItemData.SetRequirement(itemData, data[i].itemStack.requirement);
      ArrayPush(itemDataArray, itemData);
      i += 1;
    };
    return itemDataArray;
  }

  private final func ConvertGameDataIntoInventoryData(data: array<ref<gameItemData>>, opt owner: wref<GameObject>, opt isVendorItem: Bool) -> array<InventoryItemData> {
    let itemData: InventoryItemData;
    let itemDataArray: array<InventoryItemData>;
    let i: Int32 = 0;
    while i < ArraySize(data) {
      itemData = this.m_InventoryManager.GetInventoryItemData(owner, data[i]);
      if !InventoryDataManagerV2.IsItemBlacklisted(InventoryItemData.GetGameItemData(itemData)) {
        InventoryItemData.SetIsVendorItem(itemData, isVendorItem);
        ArrayPush(itemDataArray, itemData);
      };
      i += 1;
    };
    return itemDataArray;
  }
}

public class VendorDataView extends BackpackDataView {

  protected let m_isVendorGrid: Bool;

  protected let m_openTime: GameTime;

  public final func SetVendorGrid(value: Bool) -> Void {
    this.m_isVendorGrid = value;
  }

  public final func SetOpenTime(time: GameTime) -> Void {
    this.m_openTime = time;
  }

  protected func PreSortingInjection(builder: ref<ItemCompareBuilder>) -> ref<ItemCompareBuilder> {
    return builder.QuestItem();
  }

  protected func PreFilterInjection(itemData: InventoryItemData) -> Bool {
    if InventoryItemData.GetGameItemData(itemData).HasTag(n"Quest") {
      return InventoryItemData.GetGameItemData(itemData).GetTimestamp() > this.m_openTime;
    };
    return true;
  }

  public func DerivedFilterItem(data: ref<IScriptable>) -> DerivedFilterResult {
    let m_wrappedData: ref<VendorInventoryItemData> = data as VendorInventoryItemData;
    if !IsDefined(m_wrappedData) {
      return DerivedFilterResult.Pass;
    };
    if Equals(this.m_itemFilterType, ItemFilterCategory.Buyback) {
      return m_wrappedData.IsBuybackStack ? DerivedFilterResult.True : DerivedFilterResult.False;
    };
    return m_wrappedData.IsBuybackStack ? DerivedFilterResult.False : DerivedFilterResult.Pass;
  }
}

public class VendorItemVirtualController extends inkVirtualCompoundItemController {

  public let m_data: ref<VendorInventoryItemData>;

  public let m_itemViewController: wref<InventoryItemDisplayController>;

  public let m_isSpawnInProgress: Bool;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnSelected", this, n"OnSelected");
  }

  public final func OnDataChanged(value: Variant) -> Void {
    this.m_data = FromVariant(value) as VendorInventoryItemData;
    let displayToCreate: CName = n"itemDisplay";
    if Equals(InventoryItemData.GetEquipmentArea(this.m_data.ItemData), gamedataEquipmentArea.Weapon) {
      displayToCreate = n"weaponDisplay";
    };
    if !this.m_isSpawnInProgress {
      if !IsDefined(this.m_itemViewController) {
        this.m_isSpawnInProgress = true;
        ItemDisplayUtils.AsyncSpawnCommonSlotController(this, this.GetRootWidget(), displayToCreate, n"OnSpawned");
      } else {
        this.UpdateControllerData();
      };
    };
  }

  protected cb func OnSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_isSpawnInProgress = false;
    this.m_itemViewController = widget.GetController() as InventoryItemDisplayController;
    this.UpdateControllerData();
  }

  private final func UpdateControllerData() -> Void {
    if this.m_data.IsVendorItem {
      this.m_itemViewController.Setup(this.m_data.ItemData, ItemDisplayContext.Vendor, this.m_data.IsEnoughMoney);
    } else {
      this.m_itemViewController.Setup(this.m_data.ItemData, ItemDisplayContext.VendorPlayer);
    };
    this.m_itemViewController.SetComparisonState(this.m_data.ComparisonState);
    this.m_itemViewController.SetBuybackStack(this.m_data.IsBuybackStack);
  }

  protected cb func OnSelected(itemController: wref<inkVirtualCompoundItemController>, discreteNav: Bool) -> Bool {
    let widget: wref<inkWidget>;
    if discreteNav {
      widget = this.GetRootWidget();
      this.SetCursorOverWidget(widget);
    };
  }
}

public class SoldItemsCache extends IScriptable {

  private let m_cache: array<ref<SoldItem>>;

  public final func AddItem(itemID: ItemID, quantity: Int32, piecePrice: Int32) -> Void {
    let item: ref<SoldItem> = new SoldItem();
    item.itemID = itemID;
    item.quantity = quantity;
    item.piecePrice = piecePrice;
    this.AddItem(item);
  }

  public final func AddItem(item: ref<SoldItem>) -> Void {
    ArrayPush(this.m_cache, item);
  }

  public final func AddItems(items: array<ref<SoldItem>>) -> Void {
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(items);
    while i < limit {
      ArrayPush(this.m_cache, items[i]);
      i += 1;
    };
  }

  public final func RemoveItem(itemID: ItemID, quantity: Int32) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_cache) {
      if this.m_cache[i].itemID == itemID {
        if this.m_cache[i].quantity > quantity {
          this.m_cache[i].quantity -= quantity;
        } else {
          ArrayRemove(this.m_cache, this.m_cache[i]);
        };
      } else {
        i += 1;
      };
    };
  }

  public final func GetItem(itemID: ItemID) -> ref<SoldItem> {
    let i: Int32 = 0;
    while i < ArraySize(this.m_cache) {
      if this.m_cache[i].itemID == itemID {
        return this.m_cache[i];
      };
      i += 1;
    };
    return null;
  }

  public final func GetItemPrice(itemID: ItemID) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_cache) {
      if this.m_cache[i].itemID == itemID {
        return this.m_cache[i].piecePrice;
      };
      i += 1;
    };
    return 0;
  }
}
