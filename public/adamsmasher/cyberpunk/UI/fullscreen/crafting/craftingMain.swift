
public class CraftingMainGameController extends gameuiMenuGameController {

  private edit let m_tooltipsManagerRef: inkWidgetRef;

  private edit let m_tabRootRef: inkWidgetRef;

  private edit let m_buttonHintsManagerRef: inkWidgetRef;

  private edit let m_skillWidgetRoot: inkCompoundRef;

  private edit let m_craftingLogicControllerContainer: inkWidgetRef;

  private edit let m_upgradingLogicControllerContainer: inkWidgetRef;

  private let m_buttonHintsController: wref<ButtonHints>;

  private let m_player: wref<PlayerPuppet>;

  private let m_menuEventDispatcher: wref<inkMenuEventDispatcher>;

  private let m_craftingSystem: ref<CraftingSystem>;

  private let m_playerCraftBook: ref<CraftBook>;

  private let m_VendorDataManager: ref<VendorDataManager>;

  private let m_InventoryManager: ref<InventoryDataManagerV2>;

  private let m_uiScriptableSystem: wref<UIScriptableSystem>;

  private let m_tooltipsManager: wref<gameuiTooltipsManager>;

  private let m_craftingDef: ref<UI_CraftingDef>;

  private let m_craftingBlackboard: wref<IBlackboard>;

  private let m_craftingBBID: ref<CallbackHandle>;

  private let m_levelUpBlackboard: wref<IBlackboard>;

  private let m_playerLevelUpListener: ref<CallbackHandle>;

  private let m_mode: CraftingMode;

  private let m_isInitializeOver: Bool;

  private let m_craftingLogicController: wref<CraftingLogicController>;

  private let m_upgradingLogicController: wref<UpgradingScreenController>;

  protected cb func OnInitialize() -> Bool {
    this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_skillWidgetRoot), n"skillBarHolder");
    this.AsyncSpawnFromExternal(inkWidgetRef.Get(this.m_buttonHintsManagerRef), r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root", this, n"OnHintsControllerSpawned");
    this.m_player = this.GetPlayerControlledObject() as PlayerPuppet;
    this.m_craftingSystem = GameInstance.GetScriptableSystemsContainer(this.m_player.GetGame()).Get(n"CraftingSystem") as CraftingSystem;
    this.m_playerCraftBook = this.m_craftingSystem.GetPlayerCraftBook();
    this.m_InventoryManager = new InventoryDataManagerV2();
    this.m_InventoryManager.Initialize(this.m_player);
    this.m_uiScriptableSystem = UIScriptableSystem.GetInstance(this.m_player.GetGame());
    this.m_tooltipsManager = inkWidgetRef.GetControllerByType(this.m_tooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_tooltipsManager.Setup(ETooltipsStyle.Menus);
    this.SetupBB();
    this.PlayLibraryAnimation(n"crafting_intro");
    this.m_isInitializeOver = true;
  }

  protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    let craftingMenuData: ref<CraftingUserData>;
    let vendorData: VendorData;
    let vendorUserData: ref<VendorUserData>;
    if userData == null {
      return false;
    };
    vendorUserData = userData as VendorUserData;
    if IsDefined(vendorUserData) {
      vendorData = vendorUserData.vendorData.data;
      this.m_VendorDataManager = new VendorDataManager();
      this.m_VendorDataManager.Initialize(this.GetPlayerControlledObject(), vendorData.entityID);
      this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
    };
    craftingMenuData = userData as CraftingUserData;
    if IsDefined(craftingMenuData) {
      this.m_mode = craftingMenuData.Mode;
    };
  }

  protected cb func OnHintsControllerSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_buttonHintsController = widget.GetController() as ButtonHints;
    this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
    this.m_craftingLogicController = inkWidgetRef.GetControllerByType(this.m_craftingLogicControllerContainer, n"CraftingLogicController") as CraftingLogicController;
    this.m_craftingLogicController.Init(this);
    this.m_upgradingLogicController = inkWidgetRef.GetControllerByType(this.m_upgradingLogicControllerContainer, n"UpgradingScreenController") as UpgradingScreenController;
    this.m_upgradingLogicController.Init(this);
    this.RegisterTabButtons();
  }

  public final func GetScriptableSystem() -> wref<UIScriptableSystem> {
    return this.m_uiScriptableSystem;
  }

  public final func GetPlayer() -> wref<PlayerPuppet> {
    return this.m_player;
  }

  public final func GetInventoryManager() -> wref<InventoryDataManagerV2> {
    return this.m_InventoryManager;
  }

  public final func GetCraftingSystem() -> wref<CraftingSystem> {
    return this.m_craftingSystem;
  }

  public final func GetTooltipManager() -> wref<gameuiTooltipsManager> {
    return this.m_tooltipsManager;
  }

  public final func GetButtonHintsController() -> wref<ButtonHints> {
    return this.m_buttonHintsController;
  }

  protected final func RegisterTabButtons() -> Void {
    let labels: array<String>;
    let tabRoot: ref<TabRadioGroup> = inkWidgetRef.GetController(this.m_tabRootRef) as TabRadioGroup;
    tabRoot.RegisterToCallback(n"OnValueChanged", this, n"OnValueChanged");
    ArrayPush(labels, "UI-ResourceExports-Crafting");
    ArrayPush(labels, "UI-PanelNames-UPGRADING");
    tabRoot.SetData(2, null, labels);
  }

  private final func SetupBB() -> Void {
    this.m_craftingDef = GetAllBlackboardDefs().UI_Crafting;
    this.m_craftingBlackboard = this.GetBlackboardSystem().Get(this.m_craftingDef);
    if IsDefined(this.m_craftingBlackboard) {
      this.m_craftingBBID = this.m_craftingBlackboard.RegisterDelayedListenerVariant(this.m_craftingDef.lastItem, this, n"OnCraftingComplete", true);
    };
    this.m_levelUpBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_LevelUp);
    if IsDefined(this.m_levelUpBlackboard) {
      this.m_playerLevelUpListener = this.m_levelUpBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_LevelUp.level, this, n"OnCharacterLevelUpdated");
    };
  }

  private final func RemoveBB() -> Void {
    if IsDefined(this.m_craftingBlackboard) {
      this.m_craftingBlackboard.UnregisterDelayedListener(this.m_craftingDef.lastItem, this.m_craftingBBID);
    };
    if IsDefined(this.m_levelUpBlackboard) {
      this.m_levelUpBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_LevelUp.level, this.m_playerLevelUpListener);
    };
    this.m_craftingBlackboard = null;
    this.m_levelUpBlackboard = null;
  }

  protected cb func OnSetMenuEventDispatcher(menuEventDispatcher: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_menuEventDispatcher = menuEventDispatcher;
    this.m_menuEventDispatcher.RegisterToEvent(n"OnBack", this, n"OnBack");
  }

  protected cb func OnValueChanged(controller: wref<inkRadioGroupController>, selectedIndex: Int32) -> Bool {
    switch selectedIndex {
      case 0:
        this.OpenCraftingMode();
        break;
      case 1:
        this.OpenUpgradeMode();
    };
  }

  private final func RefreshUI(opt inventoryItemData: InventoryItemData) -> Void {
    switch this.m_mode {
      case CraftingMode.craft:
        this.m_craftingLogicController.RefreshListViewContent(inventoryItemData);
        break;
      case CraftingMode.upgrade:
        this.m_upgradingLogicController.RefreshListViewContent(inventoryItemData);
    };
  }

  private final func OpenCraftingMode() -> Void {
    this.m_mode = CraftingMode.craft;
    this.m_craftingLogicController.OpenPanel();
    this.m_upgradingLogicController.ClosePanel();
  }

  private final func OpenUpgradeMode() -> Void {
    this.m_mode = CraftingMode.upgrade;
    this.m_upgradingLogicController.OpenPanel();
    this.m_craftingLogicController.ClosePanel();
  }

  protected cb func OnBack(userData: ref<IScriptable>) -> Bool {
    this.PlayLibraryAnimation(n"crafting_outro");
    if !StatusEffectSystem.ObjectHasStatusEffectWithTag(this.GetPlayerControlledObject(), n"LockInHubMenu") {
      this.m_menuEventDispatcher.SpawnEvent(n"OnCloseHubMenu");
    };
  }

  protected cb func OnTransferToPerkSreen(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"upgrade_attribute") {
      this.m_menuEventDispatcher.SpawnEvent(n"OnSwitchToPerk");
    };
  }

  protected cb func OnCraftingComplete(value: Variant) -> Bool {
    let command: CraftingCommands;
    let inventoryItemData: InventoryItemData;
    let itemData: wref<gameItemData>;
    let itemID: ItemID = FromVariant(value);
    if this.m_isInitializeOver {
      this.m_InventoryManager.MarkToRebuild();
      this.m_InventoryManager.ClearInventoryItemDataCache();
      command = FromVariant(this.m_craftingBlackboard.GetVariant(GetAllBlackboardDefs().UI_Crafting.lastCommand));
      itemData = GameInstance.GetTransactionSystem(this.m_player.GetGame()).GetItemData(this.m_player, itemID);
      inventoryItemData = this.m_InventoryManager.GetInventoryItemData(itemData);
      GameInstance.GetTelemetrySystem(this.m_player.GetGame()).LogItemCrafting(ToTelemetryInventoryItem(inventoryItemData), EnumValueToName(n"CraftingCommands", EnumInt(command)));
      if Equals(command, CraftingCommands.UpgradingFinished) && !RPGManager.IsItemMaxLevel(itemData) {
        this.RefreshUI(inventoryItemData);
      } else {
        this.RefreshUI();
      };
    };
  }

  protected cb func OnCharacterLevelUpdated(value: Variant) -> Bool {
    let levelUpData: LevelUpData = FromVariant(value);
    if Equals(levelUpData.type, gamedataProficiencyType.Crafting) {
      this.RefreshUI();
    };
  }

  protected cb func OnUninitialize() -> Bool {
    this.RemoveBB();
    this.m_menuEventDispatcher.UnregisterFromEvent(n"OnBack", this, n"OnBack");
  }
}

public class IngredientListItemLogicController extends inkButtonController {

  private edit let m_itemName: inkTextRef;

  private edit let m_inventoryQuantity: inkTextRef;

  private edit let m_ingredientQuantity: inkTextRef;

  private edit let m_availability: inkTextRef;

  private edit let m_icon: inkImageRef;

  private edit let m_emptyIcon: inkImageRef;

  private edit const let m_availableBgElements: array<inkWidgetRef>;

  private edit const let m_unavailableBgElements: array<inkWidgetRef>;

  private edit let m_buyButton: inkWidgetRef;

  private edit let m_countWrapper: inkWidgetRef;

  private edit let m_itemRarity: inkWidgetRef;

  private let m_data: IngredientData;

  private let m_root: wref<inkWidget>;

  private let m_TooltipsManager: wref<gameuiTooltipsManager>;

  private let m_itemAmount: Int32;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget();
    this.RegisterToCallback(n"OnHoverOver", this, n"OnDisplayHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnDisplayHoverOut");
  }

  public final func SetupData(data: IngredientData, tooltipsManager: wref<gameuiTooltipsManager>, itemAmount: Int32) -> Void {
    let quality: CName;
    this.m_data = data;
    this.m_TooltipsManager = tooltipsManager;
    this.m_root.SetVisible(true);
    this.m_itemAmount = itemAmount;
    if this.m_data.quantity > this.m_data.inventoryQuantity {
      this.m_root.SetState(n"Unavailable");
      this.m_data.hasEnoughQuantity = false;
    } else {
      this.m_root.SetState(n"Default");
      this.m_data.hasEnoughQuantity = true;
    };
    inkWidgetRef.SetVisible(this.m_countWrapper, true);
    inkTextRef.SetLocalizedTextScript(this.m_itemName, this.m_data.id.DisplayName());
    inkTextRef.SetText(this.m_inventoryQuantity, ToString(this.m_data.inventoryQuantity));
    inkTextRef.SetText(this.m_ingredientQuantity, ToString(this.m_data.quantity * this.m_itemAmount));
    inkTextRef.SetText(this.m_availability, this.m_data.hasEnoughQuantity ? "available" : "missing");
    inkWidgetRef.SetVisible(this.m_emptyIcon, false);
    inkWidgetRef.SetVisible(this.m_icon, true);
    InkImageUtils.RequestSetImage(this, this.m_icon, "UIIcon." + this.m_data.id.IconPath());
    inkWidgetRef.SetVisible(this.m_emptyIcon, false);
    inkWidgetRef.SetVisible(this.m_itemRarity, true);
    quality = StringToName(this.m_data.id.Quality().Name());
    inkWidgetRef.SetState(this.m_itemRarity, quality);
  }

  public final func SetUnusedState() -> Void {
    this.m_root.SetVisible(false);
  }

  protected cb func OnDisplayHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let tooltipData: ref<MaterialTooltipData> = new MaterialTooltipData();
    tooltipData.Title = GetLocalizedText(LocKeyToString(this.m_data.id.DisplayName()));
    tooltipData.BaseMaterialQuantity = this.m_data.baseQuantity * this.m_itemAmount;
    tooltipData.MaterialQuantity = this.m_data.quantity * this.m_itemAmount;
    this.m_TooltipsManager.ShowTooltipAtWidget(n"materialTooltip", evt.GetTarget(), tooltipData, gameuiETooltipPlacement.RightTop, true);
  }

  protected cb func OnDisplayHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_TooltipsManager.HideTooltips();
  }

  public final func GetData() -> IngredientData {
    return this.m_data;
  }
}

public class CraftableItemLogicController extends inkVirtualCompoundItemController {

  protected edit let m_normalAppearence: inkCompoundRef;

  private let m_controller: wref<InventoryItemDisplayController>;

  public let m_itemData: ref<ItemCraftingData>;

  public let m_recipeData: ref<RecipeData>;

  private let m_isSpawnInProgress: Bool;

  private let m_displayToCreate: CName;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnSelected", this, n"OnSelected");
    this.RegisterToCallback(n"OnToggledOn", this, n"OnToggledOn");
    this.RegisterToCallback(n"OnToggledOff", this, n"OnToggledOff");
  }

  public final func OnDataChanged(value: Variant) -> Void {
    this.m_itemData = FromVariant(value) as ItemCraftingData;
    this.m_recipeData = FromVariant(value) as RecipeData;
    let displayToCreate: CName = n"itemDisplay";
    if IsDefined(this.m_itemData) && CraftingMainLogicController.IsWeapon(InventoryItemData.GetEquipmentArea(this.m_itemData.inventoryItem)) {
      displayToCreate = n"weaponDisplay";
    };
    if IsDefined(this.m_recipeData) && CraftingMainLogicController.IsWeapon(this.m_recipeData.id.EquipArea().Type()) {
      displayToCreate = n"weaponDisplay";
    };
    if !this.m_isSpawnInProgress {
      if NotEquals(this.m_displayToCreate, displayToCreate) || !IsDefined(this.m_controller) {
        this.m_isSpawnInProgress = true;
        inkCompoundRef.RemoveAllChildren(this.m_normalAppearence);
        ItemDisplayUtils.SpawnCommonSlotAsync(this, this.m_normalAppearence, displayToCreate, n"OnSlotSpawned");
        this.m_displayToCreate = displayToCreate;
      } else {
        this.UpdateControllerData();
      };
    };
  }

  protected cb func OnSlotSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_isSpawnInProgress = false;
    this.m_controller = widget.GetController() as InventoryItemDisplayController;
    this.m_controller.RegisterToCallback(n"OnHoverOver", this, n"OnDisplayHoverOver");
    this.UpdateControllerData();
  }

  private final func UpdateControllerData() -> Void {
    if IsDefined(this.m_itemData) {
      this.m_controller.Setup(this.m_itemData.inventoryItem, ItemDisplayContext.Crafting, this.m_itemData.isUpgradable);
      this.SelectSlot(this.m_itemData.isSelected);
    };
    if IsDefined(this.m_recipeData) {
      this.m_controller.Setup(this.m_recipeData, ItemDisplayContext.Crafting);
      this.m_controller.SetIsNew(this.m_recipeData.isNew);
      this.SelectSlot(this.m_recipeData.isSelected);
    };
    inkWidgetRef.SetVisible(this.m_normalAppearence, true);
  }

  private final func SelectSlot(select: Bool) -> Void {
    if IsDefined(this.m_controller) {
      this.SetSelected(select);
      this.m_controller.SetHighlighted(select);
      if IsDefined(this.m_itemData) {
        this.m_itemData.isSelected = select;
      };
      if IsDefined(this.m_recipeData) {
        this.m_recipeData.isSelected = select;
      };
    };
  }

  protected cb func OnToggledOn(itemController: wref<inkVirtualCompoundItemController>) -> Bool {
    this.SelectSlot(true);
  }

  protected cb func OnToggledOff(itemController: wref<inkVirtualCompoundItemController>) -> Bool {
    this.SelectSlot(false);
  }

  protected cb func OnSelected(itemController: wref<inkVirtualCompoundItemController>, discreteNav: Bool) -> Bool {
    if IsDefined(this.m_recipeData) {
      this.m_recipeData.isNew = false;
    };
  }
}

public class CraftingUserData extends IScriptable {

  public let Mode: CraftingMode;

  public final static func Make(mode: CraftingMode) -> ref<CraftingUserData> {
    let instance: ref<CraftingUserData> = new CraftingUserData();
    instance.Mode = mode;
    return instance;
  }
}
