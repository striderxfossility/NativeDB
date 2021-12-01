
public class gameuiInventoryGameController extends gameuiMenuGameController {

  private edit let m_TooltipsManagerRef: inkWidgetRef;

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_itemModeControllerRef: inkWidgetRef;

  private edit let m_defaultWrapper: inkWidgetRef;

  private edit let m_itemWrapper: inkWidgetRef;

  private edit let m_CyberwareSlotRootRefs: inkCompoundRef;

  private edit let m_paperDollWidget: inkWidgetRef;

  private edit let m_sortingButton: inkWidgetRef;

  private edit let m_sortingDropdown: inkWidgetRef;

  private edit let m_notificationRoot: inkWidgetRef;

  private edit let m_playerStatsWidget: inkWidgetRef;

  private edit let m_btnBackpack: inkWidgetRef;

  private edit let m_btnCyberware: inkWidgetRef;

  private edit let m_btnStats: inkWidgetRef;

  private edit let m_cyberdeckLinkContainer: inkWidgetRef;

  private edit let m_cyberdeckLinkItem: inkWidgetRef;

  private edit let m_itemNotificationRoot: inkWidgetRef;

  private let m_TooltipsManager: wref<gameuiTooltipsManager>;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_player: wref<PlayerPuppet>;

  private let m_mode: InventoryModes;

  private let m_itemViewMode: ItemViewModes;

  private let m_itemModeLogicController: wref<InventoryItemModeLogicController>;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_animDef: ref<inkAnimDef>;

  private let m_InventoryList: array<wref<InventoryItemDisplay>>;

  private let m_WeaponsList: array<wref<InventoryItemDisplayController>>;

  private let m_EquipmentList: array<wref<InventoryItemDisplayController>>;

  private let m_CyberwareList: array<wref<InventoryItemDisplayController>>;

  private let m_PocketList: array<wref<InventoryItemDisplayController>>;

  private let m_ConsumablesList: array<wref<InventoryItemDisplayController>>;

  private let m_animationList: array<wref<InventoryItemDisplayController>>;

  private let m_InventoryManager: ref<InventoryDataManagerV2>;

  private let m_uiScriptableSystem: wref<UIScriptableSystem>;

  private let m_comparisonResolver: ref<ItemPreferredComparisonResolver>;

  private let m_equipmentSystem: wref<EquipmentSystem>;

  private let m_EquipAreas: array<gamedataEquipmentArea>;

  private let m_CyberwareAreas: array<gamedataEquipmentArea>;

  private let m_WeaponAreas: array<gamedataItemType>;

  private let m_PocketAreas: array<gamedataEquipmentArea>;

  private let m_ConsumablesAreas: array<gamedataEquipmentArea>;

  protected let m_UIBBEquipment: ref<UI_EquipmentDef>;

  protected let m_UIBBItemMod: ref<UI_ItemModSystemDef>;

  private let m_DisassembleCallback: ref<UI_CraftingDef>;

  protected let m_UIBBEquipmentBlackboard: wref<IBlackboard>;

  protected let m_UIBBItemModBlackbord: wref<IBlackboard>;

  private let m_DisassembleBlackboard: wref<IBlackboard>;

  private let m_InventoryBBID: ref<CallbackHandle>;

  private let m_EquipmentBBID: ref<CallbackHandle>;

  private let m_SubEquipmentBBID: ref<CallbackHandle>;

  private let m_ItemModBBID: ref<CallbackHandle>;

  private let m_DisassembleBBID: ref<CallbackHandle>;

  private let m_openItemMode: Bool;

  private let m_isE3Demo: Bool;

  private let m_inventoryStatsListener: ref<InventoryStatsListener>;

  private let m_quantityPickerPopupToken: ref<inkGameNotificationToken>;

  private let m_psmBlackboard: wref<IBlackboard>;

  private let m_equipmentAreaCategoryEventQueue: array<ref<EquipmentAreaCategoryCreated>>;

  private let m_equipmentAreaCategories: array<ref<EquipmentAreaCategory>>;

  private let telemetrySystem: wref<TelemetrySystem>;

  protected cb func OnInitialize() -> Bool {
    let playerPuppet: wref<GameObject>;
    this.SpawnFromLocal(inkWidgetRef.Get(this.m_notificationRoot), n"notification_layer");
    this.PlayLibraryAnimation(n"menu_intro");
    this.SpawnFromExternal(inkWidgetRef.Get(this.m_itemNotificationRoot), r"base\\gameplay\\gui\\widgets\\activity_log\\activity_log_panels.inkwidget", n"RootVert");
    playerPuppet = this.GetOwnerEntity() as PlayerPuppet;
    this.m_psmBlackboard = this.GetPSMBlackboard(playerPuppet);
    AT_AddATID(this.GetRootWidget(), "InventoryScreen_MainScreen");
    super.OnInitialize();
  }

  protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    let data: ref<CyberwareDisplayWrapper> = userData as CyberwareDisplayWrapper;
    this.m_player = GameInstance.GetPlayerSystem(this.GetPlayerControlledObject().GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    this.m_isE3Demo = GameInstance.GetQuestsSystem(this.m_player.GetGame()).GetFact(n"e3_2020") > 0;
    this.m_InventoryManager = new InventoryDataManagerV2();
    this.m_InventoryManager.Initialize(this.m_player);
    this.m_comparisonResolver = ItemPreferredComparisonResolver.Make(this.m_InventoryManager);
    this.m_uiScriptableSystem = UIScriptableSystem.GetInstance(this.m_player.GetGame());
    this.m_equipmentSystem = GameInstance.GetScriptableSystemsContainer(this.m_player.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    this.m_EquipAreas = InventoryDataManagerV2.GetInventoryEquipmentAreas();
    this.m_CyberwareAreas = InventoryDataManagerV2.GetInventoryCyberwareAreas();
    this.m_WeaponAreas = InventoryDataManagerV2.GetInventoryWeaponTypes();
    this.m_PocketAreas = InventoryDataManagerV2.GetInventoryPocketAreas();
    this.m_TooltipsManager = inkWidgetRef.GetControllerByType(this.m_TooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_TooltipsManager.Setup(ETooltipsStyle.Menus);
    this.m_buttonHintsController = this.SpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root").GetController() as ButtonHints;
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    this.m_buttonHintsController.AddCharacterRoatateButtonHint();
    this.m_itemModeLogicController = inkWidgetRef.GetController(this.m_itemModeControllerRef) as InventoryItemModeLogicController;
    this.m_itemModeLogicController.SetupData(this.m_buttonHintsController, this.m_TooltipsManager, this.m_InventoryManager, this.m_player);
    inkCompoundRef.RemoveAllChildren(this.m_CyberwareSlotRootRefs);
    this.RegisterToBB();
    inkWidgetRef.SetOpacity(this.m_itemWrapper, 0.00);
    this.OpenDefaultMode(true);
    this.RefreshUI();
    this.HandlePostInitializeQueue();
    inkWidgetRef.RegisterToCallback(this.m_sortingButton, n"OnRelease", this, n"OnSortingButtonClicked");
    this.UpdateDropdownContext(DropdownDisplayContext.Default);
    this.SetupPlayerStats(this.m_player, this.GetPlayerControlledObject().GetGame());
    if IsDefined(data) {
      this.m_openItemMode = true;
      this.OpenItemMode(data.displayData);
      inkWidgetRef.SetOpacity(this.m_itemWrapper, 1.00);
      inkWidgetRef.SetVisible(this.m_defaultWrapper, false);
    };
    HubMenuUtils.SetMenuHyperlinkData(this.m_btnStats, HubMenuItems.Stats, HubMenuItems.Inventory, n"temp_stats", n"ico_stats_hub", n"UI-PanelNames-STATS");
    HubMenuUtils.SetMenuHyperlinkData(this.m_btnCyberware, HubMenuItems.Cyberware, HubMenuItems.Inventory, n"cyberware_equip", n"ico_deck_hub", n"UI-PanelNames-CYBERWARE");
    HubMenuUtils.SetMenuHyperlinkData(this.m_btnBackpack, HubMenuItems.Backpack, HubMenuItems.Inventory, n"backpack", n"ico_backpack", n"UI-PanelNames-BACKPACK");
    this.SetDeckData();
    if IsDefined(this.m_player) {
      this.telemetrySystem = GameInstance.GetTelemetrySystem(this.m_player.GetGame());
    };
  }

  private final func SetDeckData() -> Void {
    let deckItemData: InventoryItemData;
    let deckSlotController: wref<InventoryWeaponDisplayController>;
    let itemTags: array<CName>;
    let systemReplacementID: ItemID = EquipmentSystem.GetData(this.GetPlayerControlledObject()).GetActiveItem(gamedataEquipmentArea.SystemReplacementCW);
    let itemRecord: wref<Item_Record> = RPGManager.GetItemRecord(systemReplacementID);
    if IsDefined(itemRecord) {
      itemTags = itemRecord.Tags();
    };
    if ArrayContains(itemTags, n"Cyberdeck") {
      inkWidgetRef.SetVisible(this.m_cyberdeckLinkContainer, true);
      deckSlotController = inkWidgetRef.GetControllerByType(this.m_cyberdeckLinkItem, n"InventoryWeaponDisplayController") as InventoryWeaponDisplayController;
      deckItemData = this.m_InventoryManager.GetItemDataFromIDInLoadout(systemReplacementID);
      deckSlotController.Setup(deckItemData, gamedataEquipmentArea.SystemReplacementCW);
      deckSlotController.RegisterToCallback(n"OnRelease", this, n"OnCyberdeckClick");
    } else {
      inkWidgetRef.SetVisible(this.m_cyberdeckLinkContainer, false);
    };
  }

  protected cb func OnCyberdeckClick(evt: ref<inkPointerEvent>) -> Bool {
    let controller: wref<InventoryItemDisplayController>;
    if evt.IsAction(n"click") {
      controller = this.GetEquipmentSlotControllerFromTarget(evt);
      this.OpenItemMode(controller.GetItemDisplayData());
    };
  }

  protected cb func OnItemChooserItemChanged(e: ref<ItemChooserItemChanged>) -> Bool {
    if Equals(InventoryItemData.GetEquipmentArea(e.itemData), gamedataEquipmentArea.Weapon) {
      this.UpdateDropdownContext(DropdownDisplayContext.ItemChooserWeapon);
    } else {
      this.UpdateDropdownContext(DropdownDisplayContext.Default);
    };
  }

  protected final func HandlePostInitializeQueue() -> Void {
    while ArraySize(this.m_equipmentAreaCategoryEventQueue) > 0 {
      this.OnEquipmentAreaCategoryCreated(ArrayPop(this.m_equipmentAreaCategoryEventQueue));
    };
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnCloseMenu", this, n"OnCloseMenu");
    this.m_InventoryManager.UnInitialize();
    this.UnregisterFromBB();
    if IsDefined(this.m_inventoryStatsListener) {
      GameInstance.GetStatsSystem(this.m_player.GetGame()).UnregisterListener(Cast(this.m_player.GetEntityID()), this.m_inventoryStatsListener);
      this.m_inventoryStatsListener = null;
    };
    super.OnUninitialize();
  }

  private final func RegisterToBB() -> Void {
    this.m_UIBBEquipment = GetAllBlackboardDefs().UI_Equipment;
    this.m_UIBBEquipmentBlackboard = this.GetBlackboardSystem().Get(this.m_UIBBEquipment);
    this.m_UIBBItemMod = GetAllBlackboardDefs().UI_ItemModSystem;
    this.m_UIBBItemModBlackbord = this.GetBlackboardSystem().Get(this.m_UIBBItemMod);
    this.m_DisassembleCallback = GetAllBlackboardDefs().UI_Crafting;
    this.m_DisassembleBlackboard = this.GetBlackboardSystem().Get(this.m_DisassembleCallback);
    if IsDefined(this.m_UIBBEquipmentBlackboard) {
      this.m_EquipmentBBID = this.m_UIBBEquipmentBlackboard.RegisterDelayedListenerVariant(this.m_UIBBEquipment.itemEquipped, this, n"OnRefreshUI");
    };
    if IsDefined(this.m_UIBBItemModBlackbord) {
      this.m_ItemModBBID = this.m_UIBBItemModBlackbord.RegisterDelayedListenerVariant(this.m_UIBBItemMod.ItemModSystemUpdated, this, n"OnRefreshUI");
    };
    if IsDefined(this.m_DisassembleBlackboard) {
      this.m_DisassembleBBID = this.m_DisassembleBlackboard.RegisterDelayedListenerVariant(this.m_DisassembleCallback.lastIngredients, this, n"OnDisassembleComplete", true);
    };
  }

  private final func UnregisterFromBB() -> Void {
    if IsDefined(this.m_UIBBEquipmentBlackboard) {
      this.m_UIBBEquipmentBlackboard.UnregisterDelayedListener(this.m_UIBBEquipment.itemEquipped, this.m_EquipmentBBID);
    };
    if IsDefined(this.m_UIBBItemModBlackbord) {
      this.m_UIBBItemModBlackbord.UnregisterDelayedListener(this.m_UIBBItemMod.ItemModSystemUpdated, this.m_ItemModBBID);
    };
    if IsDefined(this.m_DisassembleBlackboard) {
      this.m_DisassembleBlackboard.UnregisterDelayedListener(this.m_DisassembleCallback.lastIngredients, this.m_DisassembleBBID);
    };
  }

  private final func SetupPlayerStats(player: wref<PlayerPuppet>, game: GameInstance) -> Void {
    let controller: ref<InventoryStatsController> = inkWidgetRef.GetController(this.m_playerStatsWidget) as InventoryStatsController;
    if IsDefined(this.m_inventoryStatsListener) {
      GameInstance.GetStatsSystem(game).UnregisterListener(Cast(player.GetEntityID()), this.m_inventoryStatsListener);
      this.m_inventoryStatsListener = null;
    };
    this.m_inventoryStatsListener = new InventoryStatsListener();
    this.m_inventoryStatsListener.m_owner = player;
    this.m_inventoryStatsListener.m_controller = controller;
    GameInstance.GetStatsSystem(game).RegisterListener(Cast(player.GetEntityID()), this.m_inventoryStatsListener);
    controller.Setup(player);
  }

  private final func UpdateDropdownContext(context: DropdownDisplayContext) -> Void {
    let controller: ref<DropdownListController> = inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController;
    let sortingButtonController: ref<DropdownButtonController> = inkWidgetRef.GetController(this.m_sortingButton) as DropdownButtonController;
    if NotEquals(context, controller.GetDisplayContext()) {
      controller.Setup(this, context, sortingButtonController);
      sortingButtonController.SetData(SortingDropdownData.GetDropdownOption(controller.GetData(), ItemSortMode.Default));
    };
  }

  protected cb func OnDropdownItemClickedEvent(evt: ref<DropdownItemClickedEvent>) -> Bool {
    let sortingButtonController: ref<DropdownButtonController>;
    let identifier: ItemSortMode = FromVariant(evt.identifier);
    let data: ref<DropdownItemData> = SortingDropdownData.GetDropdownOption((inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController).GetData(), identifier);
    if IsDefined(data) {
      sortingButtonController = inkWidgetRef.GetController(this.m_sortingButton) as DropdownButtonController;
      sortingButtonController.SetData(data);
      this.m_itemModeLogicController.SetSortMode(identifier);
    };
  }

  protected cb func OnSortingButtonClicked(evt: ref<inkPointerEvent>) -> Bool {
    let controller: ref<DropdownListController>;
    if evt.IsAction(n"click") {
      this.PlaySound(n"Button", n"OnPress");
      controller = inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController;
      controller.Toggle();
      this.OnEquipmentSlotHoverOut(null);
    };
  }

  protected final func GetEquipmentAreas(iw: wref<inkCompoundWidget>, levels: Int32) -> array<wref<inkCompoundWidget>> {
    let child: wref<inkCompoundWidget>;
    let innerResult: array<wref<inkCompoundWidget>>;
    let j: Int32;
    let result: array<wref<inkCompoundWidget>>;
    let i: Int32 = 0;
    while i < iw.GetNumChildren() {
      child = iw.GetWidgetByIndex(i) as inkCompoundWidget;
      if IsDefined(child) {
        if levels > 1 {
          innerResult = this.GetEquipmentAreas(child, levels - 1);
          j = 0;
          while j < ArraySize(innerResult) {
            if IsDefined(innerResult[j].GetController() as InventoryItemDisplayEquipmentArea) {
              ArrayPush(result, innerResult[j]);
            };
            j += 1;
          };
        };
      };
      if IsDefined(child.GetController() as InventoryItemDisplayEquipmentArea) {
        ArrayPush(result, child);
      };
      i += 1;
    };
    return result;
  }

  protected cb func OnRefreshUI(value: Variant) -> Bool {
    this.m_InventoryManager.MarkToRebuild();
    this.RefreshUI();
  }

  private final func RefreshUI() -> Void {
    let categoryAreas: array<wref<InventoryItemDisplayEquipmentArea>>;
    let displays: array<ref<InventoryItemDisplayController>>;
    let equipmentAreas: array<gamedataEquipmentArea>;
    let i: Int32;
    let isLockedArea: Bool;
    let j: Int32;
    let k: Int32;
    let outfit: ItemID = this.m_InventoryManager.GetEquippedItemIdInArea(gamedataEquipmentArea.Outfit);
    let isOutfitEquipped: Bool = ItemID.IsValid(outfit);
    this.HideTooltips();
    i = 0;
    while i < ArraySize(this.m_equipmentAreaCategories) {
      isLockedArea = false;
      displays = this.m_equipmentAreaCategories[i].GetDisplays();
      categoryAreas = this.m_equipmentAreaCategories[i].parentCategory.GetCategoryAreas();
      j = 0;
      while j < ArraySize(categoryAreas) {
        equipmentAreas = categoryAreas[j].GetEquipmentAreas();
        k = 0;
        while k < ArraySize(equipmentAreas) {
          if this.IsAreaLockedByOutfit(equipmentAreas[k]) {
            isLockedArea = true;
          };
          k += 1;
        };
        j += 1;
      };
      j = 0;
      while j < ArraySize(displays) {
        displays[j].InvalidateContent();
        displays[j].SetLocked(isOutfitEquipped && isLockedArea);
        j += 1;
      };
      i += 1;
    };
  }

  private final func RefreshedEquippedItemData(equippedItem: InventoryItemData) -> Void {
    equippedItem = this.m_InventoryManager.GetInventoryItemData(this.m_InventoryManager.GetExternalGameItemData(this.m_player.GetEntityID(), InventoryItemData.GetID(equippedItem)));
  }

  protected cb func OnDisassembleComplete(value: Variant) -> Bool {
    let disassembledIngredientData: array<IngredientData> = FromVariant(value);
    if ArraySize(disassembledIngredientData) > 0 {
      this.m_InventoryManager.MarkToRebuild();
      this.RefreshUI();
    };
  }

  private final func SwapMode(mode: InventoryModes) -> Void {
    let isComparisionDisabled: Bool;
    this.m_mode = mode;
    this.m_buttonHintsController.ClearButtonHints();
    if Equals(this.m_mode, InventoryModes.Item) {
      this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("UI-UserActions-NavigateBack"));
      isComparisionDisabled = this.m_uiScriptableSystem.IsComparisionTooltipDisabled();
      this.m_buttonHintsController.AddButtonHint(n"toggle_comparison_tooltip", GetLocalizedText(isComparisionDisabled ? "UI-UserActions-EnableComparison" : "UI-UserActions-DisableComparison"));
    } else {
      this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    };
  }

  private final func OpenDefaultMode(opt openingMenu: Bool) -> Void {
    let controller: ref<DropdownListController>;
    this.SwapMode(InventoryModes.Default);
    this.m_itemModeLogicController.m_isShown = false;
    this.StartModeTransitionAnimation();
    controller = inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController;
    controller.Close();
  }

  public final func GetEquipementAreaDisplays(equipmentArea: gamedataEquipmentArea) -> ref<EquipmentAreaDisplays> {
    let equipmentAreas: array<ref<EquipmentAreaDisplays>>;
    let j: Int32;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipmentAreaCategories) {
      equipmentAreas = this.m_equipmentAreaCategories[i].areaDisplays;
      j = 0;
      while j < ArraySize(equipmentAreas) {
        k = 0;
        while k < ArraySize(equipmentAreas[j].equipmentAreas) {
          if Equals(equipmentAreas[j].equipmentAreas[k], equipmentArea) {
            return equipmentAreas[j];
          };
          k += 1;
        };
        j += 1;
      };
      i += 1;
    };
    return null;
  }

  private final func GetEquipmentCategory(equipmentCategory: ref<InventoryItemDisplayCategoryArea>) -> ref<EquipmentAreaCategory> {
    let areaDisplays: array<ref<EquipmentAreaDisplays>>;
    let areaDisplaysEquipmnetAreas: array<gamedataEquipmentArea>;
    let equipmentAreas: array<gamedataEquipmentArea>;
    let j: Int32;
    let k: Int32;
    let passed: Bool;
    let targetCategoryAreas: array<wref<InventoryItemDisplayEquipmentArea>>;
    let targetCategoryEquipmentAreas: array<gamedataEquipmentArea>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipmentAreaCategories) {
      areaDisplays = this.m_equipmentAreaCategories[i].areaDisplays;
      targetCategoryAreas = equipmentCategory.GetCategoryAreas();
      if ArraySize(areaDisplays) == ArraySize(targetCategoryAreas) && ArraySize(areaDisplays) > 0 {
        passed = true;
        ArrayClear(areaDisplaysEquipmnetAreas);
        ArrayClear(targetCategoryEquipmentAreas);
        j = 0;
        while j < ArraySize(areaDisplays) {
          k = 0;
          while k < ArraySize(areaDisplays[j].equipmentAreas) {
            ArrayPush(areaDisplaysEquipmnetAreas, areaDisplays[j].equipmentAreas[k]);
            k += 1;
          };
          ArrayClear(equipmentAreas);
          equipmentAreas = targetCategoryAreas[j].GetEquipmentAreas();
          k = 0;
          while k < ArraySize(equipmentAreas) {
            ArrayPush(targetCategoryEquipmentAreas, equipmentAreas[k]);
            k += 1;
          };
          j += 1;
        };
        j = 0;
        while j < ArraySize(areaDisplaysEquipmnetAreas) {
          if !ArrayContains(targetCategoryEquipmentAreas, areaDisplaysEquipmnetAreas[j]) {
            passed = false;
          } else {
            j += 1;
          };
        };
        if !passed {
        } else {
          return this.m_equipmentAreaCategories[i];
        };
      };
      i += 1;
    };
    return null;
  }

  private final func GetEquipmentCategoryByArea(equipmentArea: gamedataEquipmentArea) -> ref<EquipmentAreaCategory> {
    let equipmentAreas: array<ref<EquipmentAreaDisplays>>;
    let j: Int32;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipmentAreaCategories) {
      equipmentAreas = this.m_equipmentAreaCategories[i].areaDisplays;
      j = 0;
      while j < ArraySize(equipmentAreas) {
        k = 0;
        while j < ArraySize(equipmentAreas[j].equipmentAreas) {
          if Equals(equipmentAreas[j].equipmentAreas[k], equipmentArea) {
            return this.m_equipmentAreaCategories[i];
          };
          k += 1;
        };
        j += 1;
      };
      i += 1;
    };
    return null;
  }

  private final func GetEquipmentAreaDisplaysFromCategory(equipmentAreas: array<gamedataEquipmentArea>, categoryArea: ref<EquipmentAreaCategory>) -> ref<EquipmentAreaDisplays> {
    let j: Int32;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(categoryArea.areaDisplays) {
      j = 0;
      while j < ArraySize(categoryArea.areaDisplays[i].equipmentAreas) {
        k = 0;
        while k < ArraySize(equipmentAreas) {
          if Equals(categoryArea.areaDisplays[i].equipmentAreas[j], equipmentAreas[k]) {
            return categoryArea.areaDisplays[i];
          };
          k += 1;
        };
        j += 1;
      };
      i += 1;
    };
    return null;
  }

  private final func GetSlotType(areaTypes: array<gamedataEquipmentArea>) -> CName {
    let i: Int32 = 0;
    while i < ArraySize(areaTypes) {
      switch areaTypes[i] {
        case gamedataEquipmentArea.Weapon:
          return n"weaponDisplay";
        case gamedataEquipmentArea.ArmsCW:
        case gamedataEquipmentArea.HandsCW:
        case gamedataEquipmentArea.SystemReplacementCW:
          return n"itemDisplay";
        case gamedataEquipmentArea.Outfit:
          return n"outfitDisplay";
      };
      i += 1;
    };
    return n"itemDisplay";
  }

  private final func IsEquipmentAreaCyberware(itemData: InventoryItemData) -> Bool {
    let itemRecord: wref<Item_Record>;
    if IsDefined(this.m_player) {
      itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(itemData)));
      if IsDefined(itemRecord) && Equals(itemRecord.ItemCategory().Type(), gamedataItemCategory.Cyberware) {
        return true;
      };
    };
    return InventoryDataManagerV2.IsEquipmentAreaCyberware(InventoryItemData.GetEquipmentArea(itemData));
  }

  protected cb func OnEquipmentAreaCategoryCreated(e: ref<EquipmentAreaCategoryCreated>) -> Bool {
    let equipmentAreaCategory: ref<EquipmentAreaCategory>;
    let equipmentAreaController: ref<InventoryItemDisplayEquipmentArea>;
    let equipmentAreaDisplays: ref<EquipmentAreaDisplays>;
    let equipmentAreas: array<gamedataEquipmentArea>;
    let i: Int32;
    let j: Int32;
    let numberOfSlots: Int32;
    if IsDefined(this.m_InventoryManager) {
      equipmentAreaCategory = this.GetEquipmentCategory(e.categoryController);
      if equipmentAreaCategory == null {
        equipmentAreaCategory = new EquipmentAreaCategory();
        equipmentAreaCategory.parentCategory = e.categoryController;
        ArrayPush(this.m_equipmentAreaCategories, equipmentAreaCategory);
      };
      i = 0;
      while i < ArraySize(e.equipmentAreasControllers) {
        equipmentAreaController = e.equipmentAreasControllers[i];
        equipmentAreaDisplays = this.GetEquipmentAreaDisplaysFromCategory(equipmentAreaController.GetEquipmentAreas(), equipmentAreaCategory);
        if equipmentAreaDisplays == null {
          equipmentAreaDisplays = new EquipmentAreaDisplays();
          equipmentAreas = equipmentAreaController.GetEquipmentAreas();
          j = 0;
          while j < ArraySize(equipmentAreas) {
            ArrayPush(equipmentAreaDisplays.equipmentAreas, equipmentAreas[j]);
            j += 1;
          };
          equipmentAreaDisplays.displaysRoot = equipmentAreaController.GetRootWidget();
          ArrayPush(equipmentAreaCategory.areaDisplays, equipmentAreaDisplays);
          numberOfSlots = equipmentAreaController.GetNumberOfSlots();
          this.PopulateArea(equipmentAreaDisplays.displaysRoot as inkCompoundWidget, equipmentAreaDisplays, numberOfSlots, equipmentAreas);
        };
        i += 1;
      };
    } else {
      ArrayPush(this.m_equipmentAreaCategoryEventQueue, e);
    };
  }

  private final func CountNewItems(items: script_ref<array<ItemID>>) -> Int32 {
    let result: Int32;
    let i: Int32 = 0;
    while i < ArraySize(Deref(items)) {
      if this.m_uiScriptableSystem.IsInventoryItemNew(Deref(items)[i]) {
        result += 1;
      };
      i += 1;
    };
    return result;
  }

  private final func IsAreaLockedByOutfit(equipmentArea: gamedataEquipmentArea) -> Bool {
    return Equals(equipmentArea, gamedataEquipmentArea.Head) || Equals(equipmentArea, gamedataEquipmentArea.Face) || Equals(equipmentArea, gamedataEquipmentArea.OuterChest) || Equals(equipmentArea, gamedataEquipmentArea.InnerChest) || Equals(equipmentArea, gamedataEquipmentArea.Legs) || Equals(equipmentArea, gamedataEquipmentArea.Feet);
  }

  private final func PopulateArea(targetRoot: wref<inkCompoundWidget>, container: ref<EquipmentAreaDisplays>, numberOfSlots: Int32, equipmentAreas: array<gamedataEquipmentArea>) -> Void {
    let currentEquipmentArea: gamedataEquipmentArea;
    let equipedCyberwares: array<InventoryItemData>;
    let i: Int32;
    let slot: wref<InventoryItemDisplayController>;
    let outfit: ItemID = this.m_InventoryManager.GetEquippedItemIdInArea(gamedataEquipmentArea.Outfit);
    let isOutfitEquipped: Bool = ItemID.IsValid(outfit);
    while ArraySize(container.displayControllers) > numberOfSlots {
      slot = ArrayPop(container.displayControllers);
      slot.UnregisterFromCallback(n"OnHoverOver", this, n"OnEquipmentSlotHoverOver");
      slot.UnregisterFromCallback(n"OnHoverOut", this, n"OnEquipmentSlotHoverOut");
      slot.UnregisterFromCallback(n"OnRelease", this, n"OnEquipmentClick");
      targetRoot.RemoveChild(slot.GetRootWidget());
    };
    while ArraySize(container.displayControllers) < numberOfSlots {
      slot = ItemDisplayUtils.SpawnCommonSlotController(this, targetRoot, this.GetSlotType(equipmentAreas)) as InventoryItemDisplayController;
      slot.RegisterToCallback(n"OnHoverOver", this, n"OnEquipmentSlotHoverOver");
      slot.RegisterToCallback(n"OnHoverOut", this, n"OnEquipmentSlotHoverOut");
      slot.RegisterToCallback(n"OnRelease", this, n"OnEquipmentClick");
      ArrayPush(container.displayControllers, slot);
    };
    i = 0;
    while i < numberOfSlots {
      currentEquipmentArea = gamedataEquipmentArea.Invalid;
      if IsDefined(container.displayControllers[i]) {
        if InventoryDataManagerV2.IsEquipmentAreaCyberware(equipmentAreas) {
          equipedCyberwares = this.m_InventoryManager.GetInventoryCyberware();
          currentEquipmentArea = InventoryItemData.GetEquipmentArea(equipedCyberwares[i]);
          container.displayControllers[i].Bind(this.m_InventoryManager, currentEquipmentArea, ItemDisplayContext.GearPanel);
        } else {
          currentEquipmentArea = equipmentAreas[0];
          container.displayControllers[i].Bind(this.m_InventoryManager, currentEquipmentArea, i, ItemDisplayContext.GearPanel);
        };
        container.displayControllers[i].BindComparisonAndScriptableSystem(this.m_uiScriptableSystem, this.m_comparisonResolver);
        container.displayControllers[i].SetLocked(isOutfitEquipped && this.IsAreaLockedByOutfit(currentEquipmentArea));
      };
      i += 1;
    };
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    let canClose: Bool;
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
      return false;
    };
    if this.m_openItemMode {
      super.OnBack(userData);
    } else {
      if NotEquals(this.m_mode, InventoryModes.Default) || this.m_openItemMode {
        canClose = this.m_itemModeLogicController.RequestClose();
        if canClose {
          this.OpenDefaultMode();
          this.UpdateNewItemsIndicators();
          if GameInstance.GetQuestsSystem(this.m_player.GetGame()).GetFact(n"close_inventory_mode_tutorial") == 0 && GameInstance.GetQuestsSystem(this.m_player.GetGame()).GetFact(n"disable_tutorials") == 0 {
            GameInstance.GetQuestsSystem(this.m_player.GetGame()).SetFact(n"close_inventory_mode_tutorial", 1);
          };
        };
      } else {
        this.m_menuEventDispatcher.SpawnEvent(n"OnCloseHubMenu");
      };
    };
  }

  private final func UpdateNewItemsIndicators() -> Void {
    let j: Int32;
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipmentAreaCategories) {
      j = 0;
      while j < ArraySize(this.m_equipmentAreaCategories[i].areaDisplays) {
        k = 0;
        while k < ArraySize(this.m_equipmentAreaCategories[i].areaDisplays[j].displayControllers) {
          this.m_equipmentAreaCategories[i].areaDisplays[j].displayControllers[k].BindComparisonAndScriptableSystem(this.m_uiScriptableSystem, this.m_comparisonResolver);
          k += 1;
        };
        j += 1;
      };
      i += 1;
    };
  }

  protected cb func OnCloseMenu(userData: ref<IScriptable>) -> Bool {
    if ArraySize(this.m_itemModeLogicController.m_itemDropQueue) == 1 && this.m_itemModeLogicController.m_itemDropQueue[0].quantity == 1 {
      ItemActionsHelper.DropItem(this.m_player, this.m_itemModeLogicController.m_itemDropQueue[0].itemID);
      ArrayClear(this.m_itemModeLogicController.m_itemDropQueue);
    } else {
      if ArraySize(this.m_itemModeLogicController.m_itemDropQueue) > 0 {
        RPGManager.DropManyItems(this.m_player.GetGame(), this.m_player, this.m_itemModeLogicController.m_itemDropQueue);
        ArrayClear(this.m_itemModeLogicController.m_itemDropQueue);
      };
    };
    if IsDefined(this.telemetrySystem) {
      this.telemetrySystem.LogInventoryMenuClosed();
    };
  }

  private final func IsUnequipBlocked(itemID: ItemID) -> Bool {
    let itemData: wref<gameItemData> = RPGManager.GetItemData(this.m_player.GetGame(), this.m_player, itemID);
    return IsDefined(itemData) && itemData.HasTag(n"UnequipBlocked");
  }

  protected cb func OnEquipmentClick(evt: ref<inkPointerEvent>) -> Bool {
    let hotkey: EHotkey;
    let itemData: InventoryItemData;
    let controller: wref<InventoryItemDisplayController> = this.GetEquipmentSlotControllerFromTarget(evt);
    if evt.IsAction(n"unequip_item") {
      itemData = controller.GetItemData();
      if !InventoryItemData.IsEmpty(itemData) {
        this.m_InventoryManager.GetHotkeyTypeForItemID(InventoryItemData.GetID(itemData), hotkey);
        if NotEquals(hotkey, EHotkey.INVALID) {
          this.m_equipmentSystem.GetPlayerData(this.m_player).ClearItemFromHotkey(hotkey);
          this.NotifyItemUpdate(hotkey);
        } else {
          if this.IsEquipmentAreaCyberware(itemData) {
            return false;
          };
          if !InventoryGPRestrictionHelper.CanUse(itemData, this.m_player) || this.IsUnequipBlocked(InventoryItemData.GetID(itemData)) {
            this.ShowNotification(this.m_player.GetGame(), UIMenuNotificationType.InventoryActionBlocked);
            return false;
          };
          if controller.IsLocked() {
            this.ShowNotification(this.m_player.GetGame(), UIMenuNotificationType.InventoryActionBlocked);
            return false;
          };
          this.UnequipItem(controller, itemData);
        };
        this.PlaySound(n"ItemAdditional", n"OnUnequip");
      };
    } else {
      if evt.IsAction(n"select") || evt.IsAction(n"click") {
        this.PlaySound(n"Button", n"OnPress");
        if Equals(controller.GetEquipmentArea(), gamedataEquipmentArea.Invalid) {
          return false;
        };
        if controller.IsLocked() {
          this.ShowNotification(this.m_player.GetGame(), UIMenuNotificationType.InventoryActionBlocked);
          return false;
        };
        itemData = controller.GetItemData();
        if InventoryDataManagerV2.IsEquipmentAreaCyberware(controller.GetEquipmentArea()) && (InventoryItemData.IsEmpty(itemData) || controller.GetAttachmentsSize() <= 0) {
          return false;
        };
        this.OpenItemMode(controller.GetItemDisplayData());
      };
    };
  }

  private final func NotifyItemUpdate(opt equipmentArea: gamedataEquipmentArea, opt slotIndex: Int32, opt hotkey: EHotkey) -> Void {
    let itemChangedEvent: ref<ItemModeItemChanged> = new ItemModeItemChanged();
    if Equals(hotkey, EHotkey.DPAD_UP) {
      equipmentArea = gamedataEquipmentArea.Consumable;
    } else {
      if Equals(hotkey, EHotkey.RB) {
        equipmentArea = gamedataEquipmentArea.QuickSlot;
      };
    };
    itemChangedEvent.equipmentArea = equipmentArea;
    itemChangedEvent.slotIndex = slotIndex;
    itemChangedEvent.hotkey = hotkey;
    this.QueueEvent(itemChangedEvent);
  }

  private final func ShowNotification(gameInstance: GameInstance, type: UIMenuNotificationType) -> Void {
    let inventoryNotification: ref<UIMenuNotificationEvent> = new UIMenuNotificationEvent();
    inventoryNotification.m_notificationType = type;
    GameInstance.GetUISystem(gameInstance).QueueEvent(inventoryNotification);
  }

  protected cb func OnInventoryClick(evt: ref<inkPointerEvent>) -> Bool {
    let playerState: gamePSMVehicle = IntEnum(this.m_psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle));
    let controller: wref<InventoryItemDisplay> = this.GetInventoryItemControllerFromTarget(evt);
    let itemData: InventoryItemData = controller.GetItemData();
    if evt.IsAction(n"drop_item") && NotEquals(playerState, gamePSMVehicle.Default) {
      this.PlaySound(n"ItemGeneric", n"OnDrop");
      ItemActionsHelper.DropItem(this.m_player, InventoryItemData.GetID(itemData));
    } else {
      if evt.IsAction(n"equip_item") {
        if !InventoryGPRestrictionHelper.CanUse(itemData, this.m_player) {
          this.ShowNotification(this.m_player.GetGame(), UIMenuNotificationType.InventoryActionBlocked);
          return false;
        };
        this.PlaySound(n"ItemAdditional", n"OnEquip");
        this.EquipItem(itemData);
      };
    };
  }

  protected cb func OnInventoryHold(evt: ref<inkPointerEvent>) -> Bool {
    let controller: wref<InventoryItemDisplay> = this.GetInventoryItemControllerFromTarget(evt);
    let itemData: InventoryItemData = controller.GetItemData();
    let progress: Float = evt.GetHoldProgress();
    if progress >= 1.00 {
      if evt.IsAction(n"disassemble_item") && !this.m_isE3Demo {
        if InventoryItemData.GetQuantity(itemData) > 1 {
          this.OpenQuantityPicker(itemData, QuantityPickerActionType.Disassembly);
        } else {
          this.PlaySound(n"ItemGeneric", n"OnDisassemble");
          ItemActionsHelper.DisassembleItem(this.m_player, InventoryItemData.GetID(itemData));
        };
      } else {
        if evt.IsAction(n"use_item") {
          if !InventoryGPRestrictionHelper.CanUse(itemData, this.m_player) {
            this.ShowNotification(this.m_player.GetGame(), UIMenuNotificationType.InventoryActionBlocked);
            return false;
          };
          this.PlaySound(n"ItemConsumableFood", n"OnUse");
          ItemActionsHelper.PerformItemAction(this.m_player, InventoryItemData.GetID(itemData));
          this.m_InventoryManager.MarkToRebuild();
        };
      };
    };
  }

  protected cb func OnOpenInventoryQuantityPickerRequest(request: ref<OpenInventoryQuantityPickerRequest>) -> Bool {
    this.OpenQuantityPicker(request.itemData, request.actionType);
  }

  private final func OpenQuantityPicker(itemData: InventoryItemData, actionType: QuantityPickerActionType, opt local: Bool) -> Void {
    let data: ref<QuantityPickerPopupData> = new QuantityPickerPopupData();
    data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\item_quantity_picker.inkwidget";
    data.isBlocking = true;
    data.useCursor = true;
    data.queueName = n"modal_popup";
    data.maxValue = InventoryItemData.GetQuantity(itemData);
    data.gameItemData = itemData;
    data.actionType = actionType;
    this.m_quantityPickerPopupToken = this.ShowGameNotification(data);
    this.m_quantityPickerPopupToken.RegisterListener(this, local ? n"OnLocalQuantityPickerPopupClosed" : n"OnQuantityPickerPopupClosed");
    this.m_buttonHintsController.Hide();
  }

  protected cb func OnLocalQuantityPickerPopupClosed(data: ref<inkGameNotificationData>) -> Bool {
    this.m_quantityPickerPopupToken = null;
    let quantityData: ref<QuantityPickerPopupCloseData> = data as QuantityPickerPopupCloseData;
    if quantityData.choosenQuantity != -1 {
      switch quantityData.actionType {
        case QuantityPickerActionType.Disassembly:
          this.OnQuantityPickerDisassembly(quantityData);
      };
    };
  }

  public final func OnQuantityPickerDisassembly(data: ref<QuantityPickerPopupCloseData>) -> Void {
    this.PlaySound(n"ItemGeneric", n"OnDisassemble");
    ItemActionsHelper.DisassembleItem(this.m_player, InventoryItemData.GetID(data.itemData), data.choosenQuantity);
  }

  protected cb func OnQuantityPickerPopupClosed(data: ref<inkGameNotificationData>) -> Bool {
    this.m_quantityPickerPopupToken = null;
    let quantityData: ref<QuantityPickerPopupCloseData> = data as QuantityPickerPopupCloseData;
    this.m_itemModeLogicController.OnQuantityPickerPopupClosed(quantityData);
  }

  public final func OpenItemMode(displayData: InventoryItemDisplayData) -> Void {
    let paperdollTargetPosition: PaperdollPositionAnimation;
    this.SwapMode(InventoryModes.Item);
    this.m_itemModeLogicController.SetupMode(displayData, this.m_InventoryManager, this);
    this.m_itemModeLogicController.m_isShown = true;
    paperdollTargetPosition = this.GetEquipmentAreaPaperdollLocation(displayData.m_equipmentArea);
    if Equals(paperdollTargetPosition, PaperdollPositionAnimation.Right) {
      this.m_itemModeLogicController.SetTranslation(new Vector2(0.00, 0.00));
      inkWidgetRef.SetTranslation(this.m_sortingDropdown, new Vector2(1936.00, 196.00));
    } else {
      if Equals(paperdollTargetPosition, PaperdollPositionAnimation.Left) || Equals(paperdollTargetPosition, PaperdollPositionAnimation.LeftFullBody) {
        this.m_itemModeLogicController.SetTranslation(new Vector2(1400.00, 0.00));
        inkWidgetRef.SetTranslation(this.m_sortingDropdown, new Vector2(2888.00, 196.00));
      };
    };
    if this.IsItemACyberdeck(displayData) && GameInstance.GetQuestsSystem(this.m_player.GetGame()).GetFact(n"cyberdeck_inventory_tutorial") == 0 && GameInstance.GetQuestsSystem(this.m_player.GetGame()).GetFact(n"disable_tutorials") == 0 {
      GameInstance.GetQuestsSystem(this.m_player.GetGame()).SetFact(n"cyberdeck_inventory_tutorial", 1);
    };
    this.StartModeTransitionAnimation(displayData);
  }

  private final func IsItemACyberdeck(displayData: InventoryItemDisplayData) -> Bool {
    return Equals(TweakDBInterface.GetCName(ItemID.GetTDBID(displayData.m_itemID) + t".cyberwareType", n""), n"Cyberdeck");
  }

  protected cb func OnInventoryItemHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let controller: ref<InventoryItemDisplay> = this.GetInventoryItemControllerFromTarget(evt);
    let delayEvt: ref<EventInventorySlotSelectDelayedInventoryEvent> = new EventInventorySlotSelectDelayedInventoryEvent();
    delayEvt.controller = controller.GetItemData();
    delayEvt.target = evt.GetCurrentTarget();
    GameInstance.GetDelaySystem(this.GetPlayerControlledObject().GetGame()).DelayEvent(this.GetOwnerEntity(), delayEvt, 0.05, false);
  }

  protected cb func OnSelectedItemDelayedEvent(evt: ref<EventInventorySlotSelectDelayedInventoryEvent>) -> Bool {
    this.OnInventoryItemHoverOver(evt.controller, evt.target);
    this.SetInventoryItemButtonHintsHoverOver(evt.controller);
  }

  protected cb func OnInventoryItemHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.HideTooltips();
    this.SetInventoryItemButtonHintsHoverOut();
  }

  protected cb func OnEquipmentSlotHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let delayEvt: ref<EventEquipSlotSelectDelayedInventoryEvent>;
    let inventoryTooltipData: ref<InventoryTooltipData>;
    let msgTooltipData: ref<MessageTooltipData>;
    let target: wref<inkWidget> = evt.GetTarget();
    let controller: ref<InventoryItemDisplayController> = this.GetEquipmentSlotControllerFromTarget(evt);
    let itemData: InventoryItemData = controller.GetItemData();
    let tooltipPlacement: gameuiETooltipPlacement = this.GetTooltipPlacement(controller);
    if !InventoryItemData.IsEmpty(itemData) {
      inventoryTooltipData = this.m_InventoryManager.GetTooltipDataForInventoryItem(itemData, true);
      this.m_TooltipsManager.ShowTooltipAtWidget(n"itemTooltip", target, inventoryTooltipData, tooltipPlacement, true);
    } else {
      msgTooltipData = this.m_InventoryManager.GetTooltipForEmptySlot(controller.GetSlotName());
      this.m_TooltipsManager.ShowTooltipAtWidget(0, target, msgTooltipData, tooltipPlacement, true);
    };
    delayEvt = new EventEquipSlotSelectDelayedInventoryEvent();
    delayEvt.controller = controller;
    GameInstance.GetDelaySystem(this.GetPlayerControlledObject().GetGame()).DelayEvent(this.GetOwnerEntity(), delayEvt, 0.05, false);
  }

  protected cb func OnSelectedSlotDelayedEvent(evt: ref<EventEquipSlotSelectDelayedInventoryEvent>) -> Bool {
    this.SetEquipmentSlotButtonHintsHoverOver(evt.controller);
  }

  protected cb func OnEquipmentSlotHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.HideTooltips();
    this.SetEquipmentSlotButtonHintsHoverOut();
  }

  private final func UnequipItem(controller: ref<InventoryItemDisplayController>, itemData: InventoryItemData) -> Void {
    this.m_InventoryManager.UnequipItem(controller.GetEquipmentArea(), controller.GetSlotIndex());
  }

  private final func EquipItem(itemData: InventoryItemData) -> Void {
    if !InventoryItemData.IsEmpty(itemData) && !InventoryItemData.IsEquipped(itemData) {
      if InventoryItemData.IsPart(itemData) || Equals(InventoryItemData.GetEquipmentArea(itemData), gamedataEquipmentArea.Invalid) {
        return;
      };
      if Equals(InventoryItemData.GetEquipmentArea(itemData), gamedataEquipmentArea.Weapon) {
        this.m_InventoryManager.EquipItem(InventoryItemData.GetID(itemData), this.GetFirstAvailableWeaponSlot());
      } else {
        this.m_InventoryManager.EquipItem(InventoryItemData.GetID(itemData), 0);
      };
    };
  }

  private final func OnInventoryItemHoverOver(itemData: InventoryItemData, target: wref<inkWidget>) -> Void {
    let equippedItem: InventoryItemData;
    if !InventoryItemData.IsEmpty(itemData) {
      if Equals(this.m_mode, InventoryModes.Default) {
        equippedItem = this.m_InventoryManager.GetEquippedCounterpartForInventroyItem(itemData);
      };
      this.ShowTooltipsForItemData(equippedItem, itemData, target);
    };
  }

  private final func ShowTooltipsForItemData(equippedItem: InventoryItemData, inspectedItemData: InventoryItemData, target: wref<inkWidget>) -> Void {
    let tooltipsData: array<ref<ATooltipData>>;
    this.HideTooltips();
    if !InventoryItemData.IsEmpty(inspectedItemData) {
      if !InventoryItemData.IsEmpty(equippedItem) && NotEquals(equippedItem, inspectedItemData) {
        this.m_InventoryManager.PushIdentifiedComparisonTooltipsData(tooltipsData, n"itemTooltip", n"itemTooltipComparision", equippedItem, inspectedItemData);
        this.m_TooltipsManager.ShowTooltipsAtWidget(tooltipsData, target);
      } else {
        this.m_TooltipsManager.ShowTooltipAtWidget(n"itemTooltip", target, this.m_InventoryManager.GetTooltipDataForInventoryItem(inspectedItemData, false), gameuiETooltipPlacement.RightTop, true);
      };
    };
  }

  private final func HideTooltips() -> Void {
    this.m_TooltipsManager.HideTooltips();
  }

  private final func SetInventoryItemButtonHintsHoverOver(displayingData: InventoryItemData) -> Void {
    let cursorData: ref<MenuCursorUserData> = new MenuCursorUserData();
    let playerState: gamePSMVehicle = IntEnum(this.m_psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle));
    if !InventoryItemData.IsEmpty(displayingData) {
      if !InventoryItemData.IsPart(displayingData) && NotEquals(InventoryItemData.GetEquipmentArea(displayingData), gamedataEquipmentArea.Invalid) {
        this.m_buttonHintsController.AddButtonHint(n"equip_item", GetLocalizedText("UI-UserActions-Equip"));
      };
      if !this.m_isE3Demo {
        if RPGManager.CanItemBeDisassembled(this.m_player.GetGame(), InventoryItemData.GetID(displayingData)) && !InventoryItemData.IsEquipped(displayingData) {
          this.m_buttonHintsController.AddButtonHint(n"disassemble_item", "[" + GetLocalizedText("Gameplay-Devices-Interactions-Helpers-Hold") + "] " + GetLocalizedText("UI-ScriptExports-Disassemble0"));
          cursorData.AddAction(n"disassemble_item");
        };
      };
      if !InventoryItemData.IsEquipped(displayingData) {
        if NotEquals(playerState, gamePSMVehicle.Default) {
          this.m_buttonHintsController.AddButtonHint(n"drop_item", GetLocalizedText("UI-ScriptExports-Drop0"));
        } else {
          this.m_buttonHintsController.RemoveButtonHint(n"drop_item");
        };
      };
      if Equals(InventoryItemData.GetEquipmentArea(displayingData), gamedataEquipmentArea.Consumable) {
        this.m_buttonHintsController.AddButtonHint(n"UseConsumable", "[" + GetLocalizedText("Gameplay-Devices-Interactions-Helpers-Hold") + "] " + GetLocalizedText("UI-UserActions-Use"));
        cursorData.AddAction(n"use_item");
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
    this.m_buttonHintsController.RemoveButtonHint(n"disassemble_item");
    this.m_buttonHintsController.RemoveButtonHint(n"drop_item");
    this.m_buttonHintsController.RemoveButtonHint(n"UseConsumable");
  }

  private final func SetEquipmentSlotButtonHintsHoverOver(controller: ref<InventoryItemDisplayController>) -> Void {
    let itemData: InventoryItemData = controller.GetItemData();
    this.m_buttonHintsController.AddButtonHint(n"select", GetLocalizedText("UI-ScriptExports-Select0"));
    if !InventoryItemData.IsEmpty(itemData) && !this.IsEquipmentAreaCyberware(itemData) {
      this.m_buttonHintsController.AddButtonHint(n"unequip_item", GetLocalizedText("UI-UserActions-Unequip"));
    } else {
      this.m_buttonHintsController.RemoveButtonHint(n"unequip_item");
    };
  }

  private final func SetEquipmentSlotButtonHintsHoverOut() -> Void {
    this.m_buttonHintsController.RemoveButtonHint(n"select");
    this.m_buttonHintsController.RemoveButtonHint(n"unequip_item");
  }

  private final func StartModeTransitionAnimation(opt displayData: InventoryItemDisplayData) -> Void {
    let isCyberware: Bool = InventoryDataManagerV2.IsEquipmentAreaCyberware(displayData.m_equipmentArea);
    let hidePaperdoll: Bool = isCyberware || Equals(displayData.m_equipmentArea, gamedataEquipmentArea.Weapon);
    switch this.m_mode {
      case InventoryModes.Default:
        this.PlayShowHideItemChooserAnimation(false);
        this.ZoomCamera(EnumInt(InventoryPaperdollZoomArea.Default));
        this.PlaySlidePaperdollAnimation(PaperdollPositionAnimation.Center);
        this.PlayLibraryAnimation(n"default_wrapper_Intro");
        break;
      case InventoryModes.Item:
        this.PlayShowHideItemChooserAnimation(true);
        this.ZoomCamera(EnumInt(this.GetZoomArea(displayData.m_equipmentArea)));
        this.PlaySlidePaperdollAnimation(this.GetEquipmentAreaPaperdollLocation(displayData.m_equipmentArea), hidePaperdoll);
        this.PlayLibraryAnimation(n"default_wrapper_outro");
        this.PlayLibraryAnimation(isCyberware ? n"cyberware_grid_intro" : n"inventory_grid_intro");
    };
  }

  private final func ZoomCamera(target: Int32) -> Void {
    let setCameraSetupEvent: ref<gameuiPuppetPreview_SetCameraSetupEvent> = new gameuiPuppetPreview_SetCameraSetupEvent();
    setCameraSetupEvent.setupIndex = Cast(target);
    this.QueueEvent(setCameraSetupEvent);
  }

  private final func GetVisibleSlots(opt slotToSkip: ref<InventoryItemDisplayController>) -> array<ref<InventoryItemDisplayController>> {
    let displays: array<ref<InventoryItemDisplayController>>;
    let j: Int32;
    let result: array<ref<InventoryItemDisplayController>>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipmentAreaCategories) {
      displays = this.m_equipmentAreaCategories[i].GetDisplays();
      j = 0;
      while j < ArraySize(displays) {
        if displays[j] != slotToSkip {
          ArrayPush(result, displays[j]);
        };
        j += 1;
      };
      i += 1;
    };
    return result;
  }

  private final func GetVisibleAdditionalWidgets() -> array<wref<inkWidget>> {
    let areasToHide: array<inkWidgetRef>;
    let j: Int32;
    let result: array<wref<inkWidget>>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_equipmentAreaCategories) {
      areasToHide = this.m_equipmentAreaCategories[i].parentCategory.GetAreasToHide();
      j = 0;
      while j < ArraySize(areasToHide) {
        if IsDefined(inkWidgetRef.Get(areasToHide[j])) {
          ArrayPush(result, inkWidgetRef.Get(areasToHide[j]));
        };
        j += 1;
      };
      i += 1;
    };
    return result;
  }

  private final func PlayGearToItemModeAnimation(moveAnimation: CName, hideAnimation: CName, target: ref<InventoryItemDisplayController>, itemToHide: array<ref<InventoryItemDisplayController>>) -> Void;

  private final func PlayMoveAnimation(target: ref<InventoryItemDisplayController>) -> Void;

  private final func GetZoomArea(equipmentArea: gamedataEquipmentArea) -> InventoryPaperdollZoomArea {
    switch equipmentArea {
      case gamedataEquipmentArea.Weapon:
        return InventoryPaperdollZoomArea.Weapon;
      case gamedataEquipmentArea.Legs:
        return InventoryPaperdollZoomArea.Legs;
      case gamedataEquipmentArea.Feet:
        return InventoryPaperdollZoomArea.Feet;
      case gamedataEquipmentArea.ArmsCW:
      case gamedataEquipmentArea.HandsCW:
      case gamedataEquipmentArea.SystemReplacementCW:
        return InventoryPaperdollZoomArea.Cyberware;
      case gamedataEquipmentArea.QuickSlot:
        return InventoryPaperdollZoomArea.QuickSlot;
      case gamedataEquipmentArea.Consumable:
        return InventoryPaperdollZoomArea.Consumable;
      case gamedataEquipmentArea.Outfit:
        return InventoryPaperdollZoomArea.Outfit;
      case gamedataEquipmentArea.Head:
        return InventoryPaperdollZoomArea.Head;
      case gamedataEquipmentArea.Face:
        return InventoryPaperdollZoomArea.Face;
      case gamedataEquipmentArea.InnerChest:
        return InventoryPaperdollZoomArea.InnerChest;
      case gamedataEquipmentArea.OuterChest:
        return InventoryPaperdollZoomArea.OuterChest;
    };
    return InventoryPaperdollZoomArea.Default;
  }

  private final func GetEquipmentAreaPaperdollLocation(equipmentArea: gamedataEquipmentArea) -> PaperdollPositionAnimation {
    switch equipmentArea {
      case gamedataEquipmentArea.Weapon:
      case gamedataEquipmentArea.ArmsCW:
      case gamedataEquipmentArea.HandsCW:
      case gamedataEquipmentArea.SystemReplacementCW:
        return PaperdollPositionAnimation.Right;
      case gamedataEquipmentArea.OuterChest:
      case gamedataEquipmentArea.InnerChest:
      case gamedataEquipmentArea.Face:
      case gamedataEquipmentArea.Head:
        return PaperdollPositionAnimation.Left;
      case gamedataEquipmentArea.Outfit:
      case gamedataEquipmentArea.Feet:
      case gamedataEquipmentArea.Legs:
      case gamedataEquipmentArea.Consumable:
      case gamedataEquipmentArea.Gadget:
      case gamedataEquipmentArea.QuickSlot:
        return PaperdollPositionAnimation.LeftFullBody;
    };
    return PaperdollPositionAnimation.Center;
  }

  private final func PlayShowHideAnimation(visible: Bool, opt slotToShow: ref<InventoryItemDisplayController>) -> Void {
    let i: Int32;
    let slotToShowTransparencyAnimation: ref<inkAnimDef>;
    let slotToShowTransparencyAnimationProxy: ref<inkAnimProxy>;
    let slotToShowTransparencyInterpolator: ref<inkAnimTransparency>;
    let slotsToHide: array<ref<InventoryItemDisplayController>> = this.GetVisibleSlots(slotToShow);
    let additionalWidgetsToHide: array<wref<inkWidget>> = this.GetVisibleAdditionalWidgets();
    let transparencyAnimation: ref<inkAnimDef> = new inkAnimDef();
    let transparencyInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    transparencyInterpolator.SetDuration(0.20);
    transparencyInterpolator.SetDirection(inkanimInterpolationDirection.FromTo);
    transparencyInterpolator.SetType(inkanimInterpolationType.Linear);
    transparencyInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    transparencyInterpolator.SetStartTransparency(visible ? 0.00 : 1.00);
    transparencyInterpolator.SetEndTransparency(visible ? 1.00 : 0.00);
    transparencyAnimation.AddInterpolator(transparencyInterpolator);
    slotToShowTransparencyAnimation = new inkAnimDef();
    slotToShowTransparencyInterpolator = new inkAnimTransparency();
    slotToShowTransparencyInterpolator.SetDuration(0.20);
    slotToShowTransparencyInterpolator.SetDirection(inkanimInterpolationDirection.FromTo);
    slotToShowTransparencyInterpolator.SetType(inkanimInterpolationType.Linear);
    slotToShowTransparencyInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    slotToShowTransparencyInterpolator.SetStartTransparency(visible ? 0.00 : 1.00);
    slotToShowTransparencyInterpolator.SetEndTransparency(visible ? 1.00 : 0.00);
    slotToShowTransparencyAnimation.AddInterpolator(slotToShowTransparencyInterpolator);
    i = 0;
    while i < ArraySize(slotsToHide) {
      slotsToHide[i].GetRootWidget().PlayAnimation(transparencyAnimation);
      slotsToHide[i].SetInteractive(visible);
      i += 1;
    };
    i = 0;
    while i < ArraySize(additionalWidgetsToHide) {
      additionalWidgetsToHide[i].PlayAnimation(transparencyAnimation);
      i += 1;
    };
    slotToShow.SetInteractive(visible);
    slotToShowTransparencyAnimationProxy = slotToShow.GetRootWidget().PlayAnimation(slotToShowTransparencyAnimation);
    if !visible {
      slotToShowTransparencyAnimationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnInventoryHideAnimationComplete");
    };
    this.HideTooltips();
  }

  private final func PlayShowHideItemChooserAnimation(visible: Bool) -> Void {
    let transparencyAnimationProxy: ref<inkAnimProxy>;
    let transparencyAnimation: ref<inkAnimDef> = new inkAnimDef();
    let transparencyInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    transparencyInterpolator.SetDuration(0.15);
    transparencyInterpolator.SetDirection(inkanimInterpolationDirection.FromTo);
    transparencyInterpolator.SetType(inkanimInterpolationType.Linear);
    transparencyInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    transparencyInterpolator.SetStartTransparency(visible ? 0.00 : 1.00);
    transparencyInterpolator.SetEndTransparency(visible ? 1.00 : 0.00);
    transparencyAnimation.AddInterpolator(transparencyInterpolator);
    transparencyAnimationProxy = inkWidgetRef.PlayAnimation(this.m_itemWrapper, transparencyAnimation);
    if !visible {
      transparencyAnimationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnItemChooserHideAnimationComplete");
    };
  }

  private final func PlaySlidePaperdollAnimation(position: PaperdollPositionAnimation, opt hide: Bool) -> Void {
    let transparencyInterpolator: ref<inkAnimTransparency>;
    let translationAnimation: ref<inkAnimDef> = new inkAnimDef();
    let translationInterpolator: ref<inkAnimTranslation> = new inkAnimTranslation();
    translationInterpolator.SetDuration(0.20);
    translationInterpolator.SetDirection(inkanimInterpolationDirection.FromTo);
    translationInterpolator.SetType(inkanimInterpolationType.Linear);
    translationInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    if hide || inkWidgetRef.GetOpacity(this.m_paperDollWidget) < 0.90 {
      transparencyInterpolator = new inkAnimTransparency();
      transparencyInterpolator.SetDuration(0.20);
      transparencyInterpolator.SetDirection(inkanimInterpolationDirection.FromTo);
      transparencyInterpolator.SetType(inkanimInterpolationType.Linear);
      transparencyInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
      transparencyInterpolator.SetStartTransparency(inkWidgetRef.GetOpacity(this.m_paperDollWidget) > 0.90 ? 1.00 : 0.00);
      transparencyInterpolator.SetEndTransparency(inkWidgetRef.GetOpacity(this.m_paperDollWidget) < 0.10 ? 1.00 : 0.00);
    };
    translationInterpolator.SetStartTranslation(inkWidgetRef.GetTranslation(this.m_paperDollWidget));
    switch position {
      case PaperdollPositionAnimation.Center:
        translationInterpolator.SetEndTranslation(new Vector2(0.00, 0.00));
        break;
      case PaperdollPositionAnimation.Left:
        translationInterpolator.SetEndTranslation(new Vector2(-1000.00, 0.00));
        break;
      case PaperdollPositionAnimation.LeftFullBody:
        translationInterpolator.SetEndTranslation(new Vector2(-1200.00, 0.00));
        break;
      case PaperdollPositionAnimation.Right:
        translationInterpolator.SetEndTranslation(new Vector2(1200.00, 0.00));
    };
    translationAnimation.AddInterpolator(translationInterpolator);
    translationAnimation.AddInterpolator(transparencyInterpolator);
    inkWidgetRef.PlayAnimation(this.m_paperDollWidget, translationAnimation);
  }

  protected cb func OnItemModeItemChanged(e: ref<ItemModeItemChanged>) -> Bool {
    let equipmentAreaDisplays: ref<EquipmentAreaDisplays>;
    let i: Int32;
    let equipmentAreaToUpdate: gamedataEquipmentArea = e.equipmentArea;
    if Equals(equipmentAreaToUpdate, gamedataEquipmentArea.Outfit) {
      this.InvlidateAllClothes();
      return false;
    };
    if Equals(e.hotkey, EHotkey.INVALID) {
      if InventoryDataManagerV2.IsEquipmentAreaCyberware(equipmentAreaToUpdate) {
        equipmentAreaToUpdate = gamedataEquipmentArea.SystemReplacementCW;
      };
    };
    equipmentAreaDisplays = this.GetEquipementAreaDisplays(equipmentAreaToUpdate);
    i = 0;
    while i < ArraySize(equipmentAreaDisplays.equipmentAreas) {
      if Equals(equipmentAreaDisplays.equipmentAreas[i], gamedataEquipmentArea.Invalid) {
        return false;
      };
      i += 1;
    };
    if ArraySize(equipmentAreaDisplays.displayControllers) >= e.slotIndex {
      equipmentAreaDisplays.displayControllers[e.slotIndex].InvalidateContent();
    };
  }

  private final func InvlidateAllClothes() -> Void {
    let areasToInvalidate: array<gamedataEquipmentArea>;
    let equipmentAreaDisplays: ref<EquipmentAreaDisplays>;
    let i: Int32;
    let j: Int32;
    let outfit: ItemID = this.m_InventoryManager.GetEquippedItemIdInArea(gamedataEquipmentArea.Outfit);
    let isOutfitEquipped: Bool = ItemID.IsValid(outfit);
    ArrayPush(areasToInvalidate, gamedataEquipmentArea.Head);
    ArrayPush(areasToInvalidate, gamedataEquipmentArea.Face);
    ArrayPush(areasToInvalidate, gamedataEquipmentArea.OuterChest);
    ArrayPush(areasToInvalidate, gamedataEquipmentArea.InnerChest);
    ArrayPush(areasToInvalidate, gamedataEquipmentArea.Legs);
    ArrayPush(areasToInvalidate, gamedataEquipmentArea.Feet);
    ArrayPush(areasToInvalidate, gamedataEquipmentArea.Outfit);
    i = 0;
    while i < ArraySize(areasToInvalidate) {
      equipmentAreaDisplays = this.GetEquipementAreaDisplays(areasToInvalidate[i]);
      j = 0;
      while j < ArraySize(equipmentAreaDisplays.equipmentAreas) {
        if Equals(equipmentAreaDisplays.equipmentAreas[j], gamedataEquipmentArea.Invalid) {
        };
        j += 1;
      };
      j = 0;
      while j < ArraySize(equipmentAreaDisplays.displayControllers) {
        equipmentAreaDisplays.displayControllers[j].InvalidateContent();
        equipmentAreaDisplays.displayControllers[j].SetLocked(isOutfitEquipped && this.IsAreaLockedByOutfit(areasToInvalidate[i]));
        j += 1;
      };
      i += 1;
    };
  }

  private final func PlayAnim(anim: CName, callbackFunction: CName) -> Void {
    this.m_animationProxy = this.PlayLibraryAnimation(anim);
    this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callbackFunction);
  }

  protected cb func OnDefaultToItemModeComplete(anim: ref<inkAnimProxy>) -> Bool;

  protected cb func OnItemtoDefaultModeComplete(anim: ref<inkAnimProxy>) -> Bool;

  protected cb func OnItemModeFadeInComplete(anim: ref<inkAnimProxy>) -> Bool;

  protected cb func OnItemModeFadeOutComplete(anim: ref<inkAnimProxy>) -> Bool;

  protected cb func OnDefaultModeFadeInComplete(anim: ref<inkAnimProxy>) -> Bool;

  protected cb func OnDefaultModeFadeOutComplete(anim: ref<inkAnimProxy>) -> Bool;

  private final func GetAttachmentDataForInventoryItem(itemData: InventoryItemData, out boxData: array<InventoryComboBoxData>, allowUnequip: Bool) -> Void {
    let attachments: InventoryItemAttachments;
    let currItemData: InventoryItemData;
    let dataToDisplay: array<InventoryItemData>;
    let message: String;
    let showcaseItemData: InventoryItemData;
    let attachmentsSize: Int32 = InventoryItemData.GetAttachmentsSize(itemData);
    let i: Int32 = 0;
    let limit: Int32 = attachmentsSize;
    while i < limit {
      attachments = InventoryItemData.GetAttachment(itemData, i);
      currItemData = attachments.ItemData;
      ArrayClear(dataToDisplay);
      if InventoryItemData.IsEmpty(currItemData) {
        message = "No " + GetLocalizedText(attachments.SlotName) + " attached";
      } else {
        message = "Attached " + GetLocalizedText(attachments.SlotName);
        ArrayPush(dataToDisplay, currItemData);
      };
      ArrayPush(boxData, new InventoryComboBoxData(message, dataToDisplay, allowUnequip, showcaseItemData, false, false));
      i += 1;
    };
  }

  private final func GetAttachmentDataForCustomizeFromInventory(inspectedItemData: InventoryItemData, equipmentData: array<InventoryItemData>, out boxData: array<InventoryComboBoxData>) -> Void {
    let attachments: InventoryItemAttachments;
    let attachmentsSize: Int32;
    let currentEquipment: InventoryItemData;
    let itemsToDisplay: array<InventoryItemData>;
    let j: Int32;
    let limitJ: Int32;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(equipmentData);
    while i < limit {
      currentEquipment = equipmentData[i];
      ArrayClear(itemsToDisplay);
      attachmentsSize = InventoryItemData.GetAttachmentsSize(currentEquipment);
      j = 0;
      limitJ = attachmentsSize;
      while j < limitJ {
        attachments = InventoryItemData.GetAttachment(currentEquipment, i);
        if !InventoryItemData.IsEmpty(currentEquipment) && InventoryItemData.PlacementSlotsContains(inspectedItemData, attachments.SlotID) {
          ArrayPush(itemsToDisplay, attachments.ItemData);
        };
        j += 1;
      };
      if ArraySize(itemsToDisplay) > 0 {
        ArrayPush(boxData, new InventoryComboBoxData("Attatch to " + GetLocalizedText(InventoryItemData.GetName(currentEquipment)), itemsToDisplay, false, currentEquipment, true, false));
      };
      i += 1;
    };
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    super.OnSetMenuEventDispatcher(menuEventDispatcher);
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
    this.m_menuEventDispatcher.RegisterToEvent(n"OnCloseMenu", this, n"OnCloseMenu");
  }

  private final func GetSlotNameFromEqArea(area: gamedataEquipmentArea) -> String {
    return EnumValueToString("gamedataEquipmentArea", Cast(EnumInt(area)));
  }

  private final func GetInventoryItemControllerFromTarget(evt: ref<inkPointerEvent>) -> ref<InventoryItemDisplay> {
    let widget: ref<inkWidget> = evt.GetCurrentTarget();
    let controller: wref<InventoryItemDisplay> = widget.GetController() as InventoryItemDisplay;
    return controller;
  }

  private final func GetEquipmentSlotControllerFromTarget(evt: ref<inkPointerEvent>) -> ref<InventoryItemDisplayController> {
    let widget: ref<inkWidget> = evt.GetCurrentTarget();
    let controller: wref<InventoryItemDisplayController> = widget.GetController() as InventoryItemDisplayController;
    return controller;
  }

  private final func IsAnEquipmentArea(equipmentArea: gamedataEquipmentArea) -> Bool {
    let isEquipmentArea: Bool;
    let i: Int32 = 0;
    while i < ArraySize(this.m_EquipAreas) {
      if Equals(this.m_EquipAreas[i], equipmentArea) {
        return true;
      };
      i += 1;
    };
    return isEquipmentArea;
  }

  private final func GetFirstAvailableWeaponSlot() -> Int32 {
    let tempItemData: InventoryItemData;
    let tempWeaponEquipmentSlot: wref<InventoryItemDisplayController>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_WeaponsList) {
      tempWeaponEquipmentSlot = this.m_WeaponsList[i];
      tempItemData = tempWeaponEquipmentSlot.GetItemData();
      if InventoryItemData.IsEmpty(tempItemData) {
        return i;
      };
      i += 1;
    };
    return 0;
  }

  private final func GetAssociatedCategory(controller: ref<InventoryItemDisplayController>) -> array<wref<InventoryItemDisplayController>> {
    let controllerList: array<wref<InventoryItemDisplayController>>;
    switch controller.GetEquipmentArea() {
      case gamedataEquipmentArea.SystemReplacementCW:
        controllerList = this.m_CyberwareList;
        break;
      case gamedataEquipmentArea.Weapon:
        controllerList = this.m_WeaponsList;
        break;
      case gamedataEquipmentArea.Quest:
      case gamedataEquipmentArea.Gadget:
      case gamedataEquipmentArea.QuickSlot:
        controllerList = this.m_PocketList;
        break;
      case gamedataEquipmentArea.Consumable:
        controllerList = this.m_ConsumablesList;
        break;
      case gamedataEquipmentArea.Feet:
      case gamedataEquipmentArea.Legs:
      case gamedataEquipmentArea.OuterChest:
      case gamedataEquipmentArea.InnerChest:
      case gamedataEquipmentArea.Face:
      case gamedataEquipmentArea.Head:
        controllerList = this.m_EquipmentList;
    };
    return controllerList;
  }

  private final func GetSide(controller: ref<InventoryItemDisplayController>) -> Bool {
    let isLeft: Bool;
    switch controller.GetEquipmentArea() {
      case gamedataEquipmentArea.Weapon:
      case gamedataEquipmentArea.SystemReplacementCW:
        isLeft = true;
        break;
      case gamedataEquipmentArea.Outfit:
      case gamedataEquipmentArea.Feet:
      case gamedataEquipmentArea.Legs:
      case gamedataEquipmentArea.OuterChest:
      case gamedataEquipmentArea.InnerChest:
      case gamedataEquipmentArea.Face:
      case gamedataEquipmentArea.Head:
      case gamedataEquipmentArea.Consumable:
      case gamedataEquipmentArea.Quest:
      case gamedataEquipmentArea.Gadget:
        isLeft = false;
    };
    return isLeft;
  }

  private final func GetTooltipPlacement(controller: ref<InventoryItemDisplayController>) -> gameuiETooltipPlacement {
    switch controller.GetEquipmentArea() {
      case gamedataEquipmentArea.Consumable:
      case gamedataEquipmentArea.Outfit:
      case gamedataEquipmentArea.OuterChest:
      case gamedataEquipmentArea.InnerChest:
      case gamedataEquipmentArea.SystemReplacementCW:
      case gamedataEquipmentArea.Weapon:
        return gameuiETooltipPlacement.RightTop;
      case gamedataEquipmentArea.Feet:
      case gamedataEquipmentArea.Legs:
      case gamedataEquipmentArea.Face:
      case gamedataEquipmentArea.Head:
      case gamedataEquipmentArea.QuickSlot:
      case gamedataEquipmentArea.Gadget:
        return gameuiETooltipPlacement.LeftTop;
      default:
        return gameuiETooltipPlacement.RightTop;
    };
    return gameuiETooltipPlacement.RightTop;
  }

  public final func GetCategoryHeader(displayData: InventoryItemDisplayData) -> String {
    let controllerLabel: String;
    switch displayData.m_equipmentArea {
      case gamedataEquipmentArea.SystemReplacementCW:
        controllerLabel = "Gameplay-RPG-Items-Categories-Cyberware";
        break;
      case gamedataEquipmentArea.Weapon:
        controllerLabel = "Gameplay-RPG-Items-Categories-Weapon";
        break;
      case gamedataEquipmentArea.Quest:
      case gamedataEquipmentArea.Gadget:
      case gamedataEquipmentArea.QuickSlot:
        controllerLabel = "Gameplay-RPG-Items-Categories-Gadget";
        break;
      case gamedataEquipmentArea.Consumable:
        controllerLabel = "Gameplay-RPG-Items-Categories-Consumable";
        break;
      case gamedataEquipmentArea.Feet:
      case gamedataEquipmentArea.Legs:
      case gamedataEquipmentArea.OuterChest:
      case gamedataEquipmentArea.InnerChest:
      case gamedataEquipmentArea.Face:
      case gamedataEquipmentArea.Head:
        controllerLabel = "Gameplay-RPG-Items-Categories-Clothing";
    };
    return controllerLabel;
  }
}

public class ItemDisplayInventoryMiniGrid extends inkLogicController {

  private edit let m_gridList: inkCompoundRef;

  private edit let m_label: inkTextRef;

  private let m_gridWidth: Int32;

  private let m_gridData: array<wref<InventoryItemDisplayController>>;

  protected cb func OnInitialize() -> Bool {
    this.m_gridWidth = 4;
    inkWidgetRef.SetVisible(this.m_label, false);
  }

  protected cb func OnUninitialize() -> Bool {
    let gridListItem: wref<InventoryItemDisplayController>;
    while ArraySize(this.m_gridData) > 0 {
      gridListItem = ArrayPop(this.m_gridData);
      gridListItem.UnregisterFromCallback(n"OnHoverOver", this, n"OnInventoryItemHoverOver");
      gridListItem.UnregisterFromCallback(n"OnHoverOut", this, n"OnInventoryItemHoverOut");
      gridListItem.UnregisterFromCallback(n"OnRelease", this, n"OnInventoryClick");
      gridListItem.RegisterToCallback(n"OnHold", this, n"OnItemInventoryHold");
      inkCompoundRef.RemoveChild(this.m_gridList, gridListItem.GetRootWidget());
    };
  }

  public final func SetupData(label: String, playerEquipAreaInventory: array<InventoryItemData>, opt equipArea: gamedataEquipmentArea, opt displayContext: ItemDisplayContext) -> Void {
    let displayToUse: CName;
    let emptyItemData: InventoryItemData;
    let gridListItem: wref<InventoryItemDisplayController>;
    let gridSize: Int32;
    let i: Int32;
    let limit: Int32;
    let numOfRows: Int32;
    if Equals(equipArea, gamedataEquipmentArea.Weapon) || Equals(equipArea, gamedataEquipmentArea.SystemReplacementCW) {
      InventoryItemData.SetItemShape(emptyItemData, EInventoryItemShape.DoubleSlot);
    };
    if ArraySize(playerEquipAreaInventory) % this.m_gridWidth > 0 {
      numOfRows = CeilF(Cast(ArraySize(playerEquipAreaInventory)) / Cast(this.m_gridWidth) + 0.50);
      gridSize = this.m_gridWidth * numOfRows;
    } else {
      if ArraySize(playerEquipAreaInventory) == 0 {
        gridSize = this.m_gridWidth;
      } else {
        gridSize = ArraySize(playerEquipAreaInventory);
      };
    };
    limit = gridSize;
    while ArraySize(this.m_gridData) > 0 {
      gridListItem = ArrayPop(this.m_gridData);
      gridListItem.UnregisterFromCallback(n"OnHoverOver", this, n"OnInventoryItemHoverOver");
      gridListItem.UnregisterFromCallback(n"OnHoverOut", this, n"OnInventoryItemHoverOut");
      gridListItem.UnregisterFromCallback(n"OnRelease", this, n"OnInventoryClick");
      gridListItem.RegisterToCallback(n"OnHold", this, n"OnItemInventoryHold");
      inkCompoundRef.RemoveChild(this.m_gridList, gridListItem.GetRootWidget());
    };
    i = 0;
    while i < limit {
      displayToUse = n"gridItemDisplay";
      if Equals(InventoryItemData.GetEquipmentArea(playerEquipAreaInventory[i]), gamedataEquipmentArea.Weapon) {
        displayToUse = n"gridWeaponDisplay";
      };
      gridListItem = ItemDisplayUtils.SpawnCommonSlotController(this, this.m_gridList, displayToUse) as InventoryItemDisplayController;
      ArrayPush(this.m_gridData, gridListItem);
      if ArraySize(playerEquipAreaInventory) > i {
        gridListItem.Setup(playerEquipAreaInventory[i], displayContext);
      } else {
        gridListItem.Setup(emptyItemData);
      };
      i += 1;
    };
    inkWidgetRef.SetVisible(this.m_label, true);
    inkTextRef.SetText(this.m_label, label);
  }

  public final func GetInventoryItemDisplays() -> array<wref<InventoryItemDisplayController>> {
    return this.m_gridData;
  }

  public final func RemoveElement() -> Void {
    let gridListItem: wref<InventoryItemDisplayController>;
    while ArraySize(this.m_gridData) > 0 {
      gridListItem = ArrayPop(this.m_gridData);
      gridListItem.UnregisterFromCallback(n"OnHoverOver", this, n"OnInventoryItemHoverOver");
      gridListItem.UnregisterFromCallback(n"OnHoverOut", this, n"OnInventoryItemHoverOut");
      gridListItem.UnregisterFromCallback(n"OnRelease", this, n"OnInventoryClick");
      gridListItem.RegisterToCallback(n"OnHold", this, n"OnItemInventoryHold");
      inkCompoundRef.RemoveChild(this.m_gridList, gridListItem.GetRootWidget());
    };
    inkWidgetRef.SetVisible(this.m_label, false);
  }
}

public class ItemInventoryMiniGrid extends inkLogicController {

  private edit let m_gridList: inkCompoundRef;

  private edit let m_label: inkTextRef;

  private let m_gridWidth: Int32;

  private let m_gridData: array<wref<InventoryItemDisplay>>;

  protected cb func OnInitialize() -> Bool {
    this.m_gridWidth = 4;
    inkWidgetRef.SetVisible(this.m_label, false);
  }

  protected cb func OnUninitialize() -> Bool {
    let gridListItem: wref<InventoryItemDisplay>;
    while ArraySize(this.m_gridData) > 0 {
      gridListItem = ArrayPop(this.m_gridData);
      gridListItem.UnregisterFromCallback(n"OnHoverOver", this, n"OnInventoryItemHoverOver");
      gridListItem.UnregisterFromCallback(n"OnHoverOut", this, n"OnInventoryItemHoverOut");
      gridListItem.UnregisterFromCallback(n"OnRelease", this, n"OnInventoryClick");
      gridListItem.RegisterToCallback(n"OnHold", this, n"OnItemInventoryHold");
      inkCompoundRef.RemoveChild(this.m_gridList, gridListItem.GetRootWidget());
    };
  }

  public final func SetupData(label: String, playerEquipAreaInventory: array<InventoryItemData>, opt equipArea: gamedataEquipmentArea) -> Void {
    let emptyItemData: InventoryItemData;
    let gridListItem: wref<InventoryItemDisplay>;
    let gridSize: Int32;
    let i: Int32;
    let limit: Int32;
    let numOfRows: Int32;
    if Equals(equipArea, gamedataEquipmentArea.Weapon) || Equals(equipArea, gamedataEquipmentArea.SystemReplacementCW) {
      InventoryItemData.SetItemShape(emptyItemData, EInventoryItemShape.DoubleSlot);
    };
    if ArraySize(playerEquipAreaInventory) % this.m_gridWidth > 0 {
      numOfRows = CeilF(Cast(ArraySize(playerEquipAreaInventory)) / Cast(this.m_gridWidth) + 0.50);
      gridSize = this.m_gridWidth * numOfRows;
    } else {
      if ArraySize(playerEquipAreaInventory) == 0 {
        gridSize = this.m_gridWidth;
      } else {
        gridSize = ArraySize(playerEquipAreaInventory);
      };
    };
    limit = gridSize;
    while ArraySize(this.m_gridData) > limit {
      gridListItem = ArrayPop(this.m_gridData);
      gridListItem.UnregisterFromCallback(n"OnHoverOver", this, n"OnInventoryItemHoverOver");
      gridListItem.UnregisterFromCallback(n"OnHoverOut", this, n"OnInventoryItemHoverOut");
      gridListItem.UnregisterFromCallback(n"OnRelease", this, n"OnInventoryClick");
      gridListItem.RegisterToCallback(n"OnHold", this, n"OnItemInventoryHold");
      inkCompoundRef.RemoveChild(this.m_gridList, gridListItem.GetRootWidget());
    };
    while ArraySize(this.m_gridData) < limit {
      gridListItem = ItemDisplayUtils.SpawnCommonSlotController(this, this.m_gridList, n"inventoryHudItem") as InventoryItemDisplay;
      ArrayPush(this.m_gridData, gridListItem);
    };
    i = 0;
    while i < ArraySize(this.m_gridData) {
      gridListItem = this.m_gridData[i];
      if ArraySize(playerEquipAreaInventory) > i {
        gridListItem.Setup(playerEquipAreaInventory[i]);
      } else {
        gridListItem.Setup(emptyItemData);
      };
      i += 1;
    };
    inkWidgetRef.SetVisible(this.m_label, true);
    inkTextRef.SetText(this.m_label, label);
  }

  public final func SetGridWith(gridWidth: Int32) -> Void {
    this.m_gridWidth = gridWidth;
  }

  public final func GetInventoryItemDisplays() -> array<wref<InventoryItemDisplay>> {
    return this.m_gridData;
  }

  public final func RemoveElement() -> Void {
    let gridListItem: wref<InventoryItemDisplay>;
    while ArraySize(this.m_gridData) > 0 {
      gridListItem = ArrayPop(this.m_gridData);
      gridListItem.UnregisterFromCallback(n"OnHoverOver", this, n"OnInventoryItemHoverOver");
      gridListItem.UnregisterFromCallback(n"OnHoverOut", this, n"OnInventoryItemHoverOut");
      gridListItem.UnregisterFromCallback(n"OnRelease", this, n"OnInventoryClick");
      gridListItem.RegisterToCallback(n"OnHold", this, n"OnItemInventoryHold");
      inkCompoundRef.RemoveChild(this.m_gridList, gridListItem.GetRootWidget());
    };
    inkWidgetRef.SetVisible(this.m_label, false);
  }
}

public class EquipmentAreaCategory extends IScriptable {

  public let parentCategory: wref<InventoryItemDisplayCategoryArea>;

  public let areaDisplays: array<ref<EquipmentAreaDisplays>>;

  public final func GetDisplays() -> array<ref<InventoryItemDisplayController>> {
    let j: Int32;
    let result: array<ref<InventoryItemDisplayController>>;
    let i: Int32 = 0;
    while i < ArraySize(this.areaDisplays) {
      j = 0;
      while j < ArraySize(this.areaDisplays[i].displayControllers) {
        ArrayPush(result, this.areaDisplays[i].displayControllers[j]);
        j += 1;
      };
      i += 1;
    };
    return result;
  }
}

public class InventoryStatsListener extends ScriptStatsListener {

  public let m_owner: wref<GameObject>;

  public let m_controller: wref<InventoryStatsController>;

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void {
    if IsDefined(this.m_owner as PlayerPuppet) {
      if Equals(statType, gamedataStatType.Armor) || Equals(statType, gamedataStatType.Health) || Equals(statType, gamedataStatType.Stamina) {
        this.m_controller.NotifyStatUpdate(statType, total);
      };
    };
  }
}

public class InventoryStatsController extends inkLogicController {

  protected edit let m_detailsButton: inkWidgetRef;

  protected edit let m_entryContainer: inkCompoundRef;

  protected let m_healthEntryController: wref<InventoryStatsEntryController>;

  protected let m_armorEntryController: wref<InventoryStatsEntryController>;

  protected let m_staminaEntryController: wref<InventoryStatsEntryController>;

  protected cb func OnInitialize() -> Bool;

  public final func Setup(player: wref<PlayerPuppet>) -> Void {
    inkCompoundRef.RemoveAllChildren(this.m_entryContainer);
    this.m_armorEntryController = this.SetupEntry(player, gamedataStatType.Armor, n"Gameplay-RPG-Stats-Armor", n"inventory_stat_armor");
    this.m_healthEntryController = this.SetupEntry(player, gamedataStatType.Health, n"Gameplay-RPG-Stats-Health", n"inventory_stat_health");
    this.m_staminaEntryController = this.SetupEntry(player, gamedataStatType.Stamina, n"Gameplay-RPG-Stats-Stamina", n"inventory_stat_stamina");
    this.m_armorEntryController.AT_SetATID("InventoryStats_ArmorStat");
    this.m_healthEntryController.AT_SetATID("InventoryStats_HealthStat");
    this.m_staminaEntryController.AT_SetATID("InventoryStats_StaminaStat");
  }

  public final func NotifyStatUpdate(statType: gamedataStatType, value: Float) -> Void {
    switch statType {
      case gamedataStatType.Armor:
        this.m_armorEntryController.SetValue(value);
        break;
      case gamedataStatType.Health:
        this.m_armorEntryController.SetValue(value);
        break;
      case gamedataStatType.Stamina:
        this.m_armorEntryController.SetValue(value);
    };
  }

  public final func SetupEntry(player: wref<PlayerPuppet>, stat: gamedataStatType, localizationKey: CName, icon: CName) -> wref<InventoryStatsEntryController> {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(player.GetGame());
    let widget: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_entryContainer), n"statContainer");
    let value: Float = statsSystem.GetStatValue(Cast(player.GetEntityID()), stat);
    let controller: wref<InventoryStatsEntryController> = widget.GetController() as InventoryStatsEntryController;
    controller.Setup(icon, GetLocalizedText(ToString(localizationKey)), value);
    return controller;
  }

  protected cb func OnStatsButtonClicked(e: ref<inkPointerEvent>) -> Bool {
    let evt: ref<OpenMenuRequest>;
    let menuData: ref<PreviousMenuData>;
    let prevEvt: ref<OpenMenuRequest>;
    if e.IsAction(n"click") {
      evt = new OpenMenuRequest();
      evt.m_menuName = n"perks_main";
      evt.m_submenuName = n"temp_stats";
      evt.m_isMainMenu = true;
      evt.m_eventData.m_overrideSubMenuUserData = true;
      evt.m_eventData.m_overrideDefaultUserData = true;
      evt.m_jumpBack = true;
      menuData = new PreviousMenuData();
      prevEvt = new OpenMenuRequest();
      prevEvt.m_menuName = n"inventory_screen";
      prevEvt.m_isMainMenu = true;
      menuData.openMenuRequest = prevEvt;
      evt.m_eventData.userData = menuData;
      this.QueueBroadcastEvent(evt);
    };
  }
}

public class InventoryStatsEntryController extends inkLogicController {

  protected edit let m_iconWidget: inkImageRef;

  protected edit let m_labelWidget: inkTextRef;

  protected edit let m_valueWidget: inkTextRef;

  public final func Setup(icon: CName, label: String, value: Float) -> Void {
    inkTextRef.SetText(this.m_labelWidget, label);
    InkImageUtils.RequestSetImage(this, this.m_iconWidget, n"UIIcon." + icon);
    this.SetValue(value);
  }

  public final func SetValue(value: Float) -> Void {
    inkTextRef.SetText(this.m_valueWidget, IntToString(RoundMath(value)));
  }

  public final func AT_SetATID(ATID: String) -> Void {
    AT_AddATID(inkWidgetRef.Get(this.m_valueWidget), ATID);
  }
}
