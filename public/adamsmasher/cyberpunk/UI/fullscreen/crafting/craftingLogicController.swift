
public class CraftingMainLogicController extends inkLogicController {

  protected edit let m_root: inkWidgetRef;

  protected edit let m_itemDetailsContainer: inkWidgetRef;

  protected edit let m_leftListScrollHolder: inkWidgetRef;

  protected edit let m_virtualListContainer: inkVirtualCompoundRef;

  protected edit let m_filterGroup: inkWidgetRef;

  protected edit let m_sortingButton: inkWidgetRef;

  protected edit let m_sortingDropdown: inkWidgetRef;

  protected edit let m_tooltipContainer: inkWidgetRef;

  protected edit let m_itemName: inkTextRef;

  protected edit let m_itemQuality: inkTextRef;

  protected edit let m_progressBarContainer: inkCompoundRef;

  protected edit let m_progressButtonContainer: inkCompoundRef;

  protected edit let m_blockedText: inkTextRef;

  protected edit let m_ingredientsListContainer: inkCompoundRef;

  protected let m_notificationType: UIMenuNotificationType;

  protected let m_classifier: ref<CraftingItemTemplateClassifier>;

  protected let m_dataView: ref<CraftingDataView>;

  protected let m_dataSource: ref<ScriptableDataSource>;

  protected let m_virtualListController: wref<inkVirtualGridController>;

  protected let m_leftListScrollController: wref<inkScrollController>;

  protected let m_ingredientsControllerList: array<wref<IngredientListItemLogicController>>;

  @default(CraftingLogicController, 5)
  @default(UpgradingScreenController, 8)
  protected let m_maxIngredientCount: Int32;

  protected let m_selectedRecipe: ref<RecipeData>;

  protected let m_selectedItemData: InventoryItemData;

  protected let m_isCraftable: Bool;

  protected let m_filters: array<Int32>;

  protected let m_progressButtonController: wref<ProgressBarButton>;

  protected let m_itemWeaponController: wref<InventoryItemDisplayController>;

  protected let m_itemIngredientController: wref<InventoryItemDisplayController>;

  protected let m_doPlayFilterSounds: Bool;

  protected let m_craftingGameController: wref<CraftingMainGameController>;

  protected let m_craftingSystem: wref<CraftingSystem>;

  protected let m_tooltipsManager: wref<gameuiTooltipsManager>;

  protected let m_buttonHintsController: wref<ButtonHints>;

  protected let m_inventoryManager: wref<InventoryDataManagerV2>;

  protected let m_sortingController: wref<DropdownListController>;

  protected let m_sortingButtonController: wref<DropdownButtonController>;

  protected let m_isPanelOpen: Bool;

  public func Init(craftingGameController: wref<CraftingMainGameController>) -> Void {
    this.m_craftingGameController = craftingGameController;
    this.m_craftingSystem = craftingGameController.GetCraftingSystem();
    this.m_tooltipsManager = craftingGameController.GetTooltipManager();
    this.m_buttonHintsController = craftingGameController.GetButtonHintsController();
    this.m_inventoryManager = craftingGameController.GetInventoryManager();
    this.InitVirtualList();
    this.SetupIngredientWidgets();
    this.SetupFilters();
    this.SetupSortingDropdown();
    inkWidgetRef.SetVisible(this.m_itemDetailsContainer, false);
    this.m_leftListScrollController = inkWidgetRef.GetController(this.m_leftListScrollHolder) as inkScrollController;
  }

  protected final func InitVirtualList() -> Void {
    this.m_virtualListController = inkWidgetRef.GetControllerByType(this.m_virtualListContainer, n"inkVirtualGridController") as inkVirtualGridController;
    this.m_classifier = new CraftingItemTemplateClassifier();
    this.m_virtualListController.SetClassifier(this.m_classifier);
    this.m_dataSource = new ScriptableDataSource();
    this.m_dataView = new CraftingDataView();
    this.m_dataView.SetSource(this.m_dataSource);
    this.m_dataView.EnableSorting();
    this.m_dataView.BindUIScriptableSystem(this.m_craftingGameController.GetScriptableSystem());
    this.m_virtualListController.SetSource(this.m_dataView);
    this.m_virtualListController.RegisterToCallback(n"OnItemActivated", this, n"OnItemSelect");
  }

  public final func OpenPanel() -> Void {
    inkWidgetRef.SetVisible(this.m_root, true);
    this.RefreshListViewContent();
    this.m_isPanelOpen = true;
  }

  public func RefreshListViewContent(opt inventoryItemData: InventoryItemData) -> Void;

  public final func ClosePanel() -> Void {
    inkWidgetRef.SetVisible(this.m_root, false);
    this.m_dataSource.Clear();
    this.m_isPanelOpen = false;
  }

  protected func SetupIngredientWidgets() -> Void {
    let i: Int32;
    if ArraySize(this.m_ingredientsControllerList) < this.m_maxIngredientCount {
      i = 0;
      while i < this.m_maxIngredientCount {
        this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_ingredientsListContainer), n"ingredientsListItem", this, n"OnIngedientControllerSpawned");
        i += 1;
      };
    };
  }

  protected cb func OnIngedientControllerSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let controller: wref<IngredientListItemLogicController> = widget.GetController() as IngredientListItemLogicController;
    controller.SetUnusedState();
    ArrayPush(this.m_ingredientsControllerList, controller);
  }

  protected func SetupFilters() -> Void {
    let radioGroup: ref<FilterRadioGroup> = inkWidgetRef.GetControllerByType(this.m_filterGroup, n"FilterRadioGroup") as FilterRadioGroup;
    radioGroup.SetData(this.m_filters, this.m_tooltipsManager, 0);
    radioGroup.RegisterToCallback(n"OnValueChanged", this, n"OnFilterChange");
    radioGroup.Toggle(0);
    this.OnFilterChange(null, 0);
  }

  protected cb func OnFilterChange(controller: wref<inkRadioGroupController>, selectedIndex: Int32) -> Bool {
    let filter: ItemFilterCategory = IntEnum(this.m_filters[selectedIndex]);
    this.m_dataView.SetFilterType(filter);
    this.PlayLibraryAnimation(n"player_grid_show");
    this.m_leftListScrollController.SetScrollPosition(0.00);
    if this.m_doPlayFilterSounds {
      this.PlaySound(n"Button", n"OnPress");
    };
    inkWidgetRef.SetVisible(this.m_itemDetailsContainer, false);
  }

  protected final func SetupSortingDropdown() -> Void {
    inkWidgetRef.RegisterToCallback(this.m_sortingButton, n"OnRelease", this, n"OnSortingButtonClicked");
    this.m_sortingController = inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController;
    this.m_sortingButtonController = inkWidgetRef.GetController(this.m_sortingButton) as DropdownButtonController;
    this.m_sortingController.Setup(this, SortingDropdownData.GetDefaultDropdownOptions(), this.m_sortingButtonController);
    this.m_sortingButtonController.SetData(CraftingMainLogicController.GetDropdownOption(ItemSortMode.Default));
  }

  protected cb func OnSortingButtonClicked(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      this.m_sortingController.Toggle();
      this.PlaySound(n"Button", n"OnPress");
    };
  }

  protected cb func OnDropdownItemClickedEvent(evt: ref<DropdownItemClickedEvent>) -> Bool {
    let identifier: ItemSortMode = FromVariant(evt.identifier);
    let data: ref<DropdownItemData> = CraftingMainLogicController.GetDropdownOption(identifier);
    if IsDefined(data) {
      this.m_sortingButtonController.SetData(data);
      this.m_dataView.SetSortMode(identifier);
      this.PlaySound(n"Button", n"OnPress");
    };
  }

  protected final func SetCraftingButton(label: String) -> Void {
    this.m_progressButtonController = inkWidgetRef.GetControllerByType(this.m_progressButtonContainer, n"ProgressBarButton") as ProgressBarButton;
    this.m_progressButtonController.SetupProgressButton(label, inkWidgetRef.GetControllerByType(this.m_progressBarContainer, n"ProgressBarsController") as ProgressBarsController);
    this.m_progressButtonController.ButtonController.RegisterToCallback(n"OnPress", this, n"OnButtonClick");
    this.m_progressButtonController.ButtonController.RegisterToCallback(n"OnHoverOver", this, n"SetItemButtonHintsHoverOver");
    this.m_progressButtonController.ButtonController.RegisterToCallback(n"OnHoverOut", this, n"SetItemButtonHintsHoverOut");
  }

  protected cb func OnButtonClick(evt: ref<inkPointerEvent>) -> Bool {
    let craftingNotification: ref<UIMenuNotificationEvent>;
    if evt.IsAction(n"click") {
      if !this.m_isCraftable {
        if NotEquals(this.m_notificationType, UIMenuNotificationType.CraftingNoPerks) {
          craftingNotification = new UIMenuNotificationEvent();
          craftingNotification.m_notificationType = this.m_notificationType;
          this.QueueEvent(craftingNotification);
        };
        this.PlaySound(n"Item", n"OnCraftFailed");
      } else {
        this.PlaySound(n"Item", n"OnCraftStarted");
      };
    };
  }

  protected cb func OnItemSelect(previous: ref<inkVirtualCompoundItemController>, next: ref<inkVirtualCompoundItemController>) -> Bool {
    this.UpdateItemPreview(next as CraftableItemLogicController);
    this.PlaySound(n"Button", n"OnPress");
  }

  protected func UpdateItemPreview(craftableController: ref<CraftableItemLogicController>) -> Void;

  protected cb func OnUninitialize() -> Bool {
    this.m_virtualListController.SetSource(null);
    this.m_virtualListController.SetClassifier(null);
    this.m_dataView.SetSource(null);
    this.m_dataView = null;
    this.m_dataSource = null;
    this.m_classifier = null;
    this.m_virtualListController.UnregisterFromCallback(n"OnItemSelected", this, n"OnItemSelect");
    this.m_progressButtonController.ButtonController.UnregisterFromCallback(n"OnPress", this, n"OnButtonClick");
    this.m_progressButtonController.ButtonController.UnregisterFromCallback(n"OnHoverOver", this, n"SetItemButtonHintsHoverOver");
    this.m_progressButtonController.ButtonController.UnregisterFromCallback(n"OnHoverOut", this, n"SetItemButtonHintsHoverOut");
    this.m_doPlayFilterSounds = false;
  }

  protected func SetItemButtonHintsHoverOver(evt: ref<inkPointerEvent>) -> Void;

  protected final func SetItemButtonHintsHoverOut(evt: ref<inkPointerEvent>) -> Void {
    this.m_buttonHintsController.RemoveButtonHint(n"craft_item");
  }

  public final static func IsWeapon(type: gamedataEquipmentArea) -> Bool {
    return Equals(type, gamedataEquipmentArea.Weapon) || Equals(type, gamedataEquipmentArea.WeaponHeavy) || Equals(type, gamedataEquipmentArea.WeaponWheel) || Equals(type, gamedataEquipmentArea.WeaponLeft);
  }

  public final static func GetDropdownOption(identifier: ItemSortMode) -> ref<DropdownItemData> {
    let options: array<ref<DropdownItemData>> = SortingDropdownData.GetDefaultDropdownOptions();
    let i: Int32 = 0;
    while i < ArraySize(options) {
      if Equals(FromVariant(options[i].identifier), identifier) {
        return options[i];
      };
      i += 1;
    };
    return null;
  }
}
