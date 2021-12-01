
public class UpgradingScreenController extends CraftingMainLogicController {

  private let m_itemTooltipControllers: array<wref<AGenericTooltipController>>;

  private let m_tooltipDatas: array<ref<InventoryTooltipData>>;

  private let m_WeaponAreas: array<gamedataItemType>;

  private let m_EquipAreas: array<gamedataEquipmentArea>;

  private let m_newItem: ref<gameItemData>;

  private let m_statMod: ref<gameStatModifierData>;

  private let m_levelMod: ref<gameStatModifierData>;

  public func Init(craftingGameController: wref<CraftingMainGameController>) -> Void {
    this.Init(craftingGameController);
    this.SetCraftingButton("UI-Crafting-Upgrade");
    this.m_EquipAreas = InventoryDataManagerV2.GetInventoryEquipmentAreas();
    this.m_WeaponAreas = InventoryDataManagerV2.GetInventoryWeaponTypes();
  }

  public func RefreshListViewContent(opt inventoryItemData: InventoryItemData) -> Void {
    this.m_dataSource.Clear();
    this.m_dataSource.Reset(this.GetUpgradableList());
    if !InventoryItemData.IsEmpty(inventoryItemData) {
      this.UpdateItemPreviewPanel(inventoryItemData);
    } else {
      this.UpdateItemPreviewPanel(this.m_selectedItemData);
    };
  }

  protected func SetupFilters() -> Void {
    ArrayPush(this.m_filters, EnumInt(ItemFilterCategory.AllCount));
    ArrayPush(this.m_filters, EnumInt(ItemFilterCategory.RangedWeapons));
    ArrayPush(this.m_filters, EnumInt(ItemFilterCategory.MeleeWeapons));
    ArrayPush(this.m_filters, EnumInt(ItemFilterCategory.Clothes));
    this.SetupFilters();
  }

  protected func UpdateItemPreview(craftableController: ref<CraftableItemLogicController>) -> Void {
    let selectedItem: InventoryItemData;
    this.SetItemButtonHintsHoverOut(null);
    selectedItem = FromVariant(craftableController.GetData()) as ItemCraftingData.inventoryItem;
    this.UpdateItemPreviewPanel(selectedItem);
  }

  private final func UpdateItemPreviewPanel(selectedItem: InventoryItemData) -> Void {
    if InventoryItemData.IsEmpty(selectedItem) {
      inkWidgetRef.SetVisible(this.m_itemDetailsContainer, false);
      return;
    };
    inkWidgetRef.SetVisible(this.m_itemDetailsContainer, true);
    this.m_selectedItemData = selectedItem;
    this.m_selectedRecipe = this.m_craftingSystem.GetUpgradeRecipeData(InventoryItemData.GetID(this.m_selectedItemData));
    this.SetupIngredients(this.m_selectedRecipe.ingredients);
    this.UpdateTooltipData();
    this.SetQualityHeader();
    this.m_isCraftable = this.IsUpgradable(this.m_selectedItemData, true);
    inkWidgetRef.SetVisible(this.m_blockedText, !this.m_isCraftable);
    this.m_progressButtonController.SetAvaibility(this.m_isCraftable);
  }

  private final func SetupIngredients(ingredient: array<IngredientData>) -> Void {
    let controller: wref<IngredientListItemLogicController>;
    let ingredientCount: Int32 = ArraySize(ingredient);
    let i: Int32 = 0;
    while i < ingredientCount {
      controller = this.m_ingredientsControllerList[i];
      controller.SetupData(ingredient[i], this.m_tooltipsManager, 1);
      i += 1;
    };
    i = ingredientCount;
    while i < this.m_maxIngredientCount {
      controller = this.m_ingredientsControllerList[i];
      controller.SetUnusedState();
      i += 1;
    };
  }

  private final func UpdateTooltipData() -> Void {
    this.GetItemTooltips(this.m_selectedItemData);
    if ArraySize(this.m_itemTooltipControllers) <= 0 {
      this.AsyncSpawnFromExternal(inkWidgetRef.Get(this.m_tooltipContainer), r"base\\gameplay\\gui\\common\\tooltip\\itemtooltip.inkwidget", n"itemTooltip", this, n"OnItemTooltipSpawned");
      this.AsyncSpawnFromExternal(inkWidgetRef.Get(this.m_tooltipContainer), r"base\\gameplay\\gui\\common\\tooltip\\itemtooltip.inkwidget", n"itemTooltip", this, n"OnUpgradedItemTooltipSpawned");
      return;
    };
    this.m_itemTooltipControllers[0].SetData(this.m_tooltipDatas[0]);
    this.ApplyStatsModification();
    this.m_itemTooltipControllers[1].SetData(this.m_tooltipDatas[1]);
    this.RemoveStatsModification();
  }

  protected cb func OnItemTooltipSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let tooltipController: ref<AGenericTooltipController> = widget.GetController() as AGenericTooltipController;
    tooltipController.SetData(this.m_tooltipDatas[0]);
    ArrayPush(this.m_itemTooltipControllers, tooltipController);
  }

  protected cb func OnUpgradedItemTooltipSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let tooltipController: ref<AGenericTooltipController> = widget.GetController() as AGenericTooltipController;
    ArrayPush(this.m_itemTooltipControllers, tooltipController);
    this.ApplyStatsModification();
    tooltipController.SetData(this.m_tooltipDatas[1]);
    this.RemoveStatsModification();
  }

  private final func SetQualityHeader() -> Void {
    let iconicLabel: String = GetLocalizedText(UIItemsHelper.QualityToLocalizationKey(gamedataQuality.Iconic));
    let stateName: CName = InventoryItemData.GetQuality(this.m_selectedItemData);
    let isIconic: Bool = RPGManager.IsItemIconic(InventoryItemData.GetGameItemData(this.m_selectedItemData));
    let quality: gamedataQuality = UIItemsHelper.QualityNameToEnum(InventoryItemData.GetQuality(this.m_selectedItemData));
    let rarityLabel: String = GetLocalizedText(UIItemsHelper.QualityToLocalizationKey(quality));
    inkTextRef.SetText(this.m_itemQuality, isIconic ? rarityLabel + " / " + iconicLabel : rarityLabel);
    inkWidgetRef.SetState(this.m_itemQuality, stateName);
    inkTextRef.SetText(this.m_itemName, this.m_selectedRecipe.label);
    inkWidgetRef.SetState(this.m_itemName, stateName);
  }

  protected cb func OnHoldFinished(evt: ref<ProgressBarFinishedProccess>) -> Bool {
    if !this.m_isPanelOpen {
      return false;
    };
    this.UpgradeItem(this.m_selectedItemData);
  }

  protected func SetItemButtonHintsHoverOver(evt: ref<inkPointerEvent>) -> Void {
    if this.m_isCraftable {
      this.m_buttonHintsController.AddButtonHint(n"craft_item", GetLocalizedText("UI-Crafting-hold_to_upgrade"));
    };
  }

  private final func GetUpgradableList() -> array<ref<IScriptable>> {
    let i: Int32;
    let itemArrayHolder: array<ref<IScriptable>>;
    this.m_inventoryManager.MarkToRebuild();
    i = 0;
    while i < ArraySize(this.m_EquipAreas) {
      this.FillInventoryData(this.m_inventoryManager.GetPlayerInventoryData(this.m_EquipAreas[i]), itemArrayHolder);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_WeaponAreas) {
      this.FillInventoryData(this.m_inventoryManager.GetPlayerItemsByType(this.m_WeaponAreas[i]), itemArrayHolder);
      i += 1;
    };
    return itemArrayHolder;
  }

  private final func GetItemTooltips(oldData: InventoryItemData) -> Void {
    let newData: InventoryItemData;
    ArrayClear(this.m_tooltipDatas);
    this.m_newItem = GameInstance.GetInventoryManager(this.m_craftingGameController.GetPlayer().GetGame()).CreateItemData(InventoryItemData.GetID(oldData), this.m_craftingGameController.GetPlayer());
    this.ApplyStatsModification();
    newData = this.m_inventoryManager.GetInventoryItemData(this.m_craftingGameController.GetPlayer(), this.m_newItem, false, false);
    ArrayPush(this.m_tooltipDatas, this.m_inventoryManager.GetComparisonTooltipsData(newData, oldData, false));
    ArrayPush(this.m_tooltipDatas, this.m_inventoryManager.GetComparisonTooltipsData(oldData, newData, false));
    this.m_tooltipDatas[0].displayContext = InventoryTooltipDisplayContext.Upgrading;
    this.m_tooltipDatas[1].displayContext = InventoryTooltipDisplayContext.Upgrading;
    this.RemoveStatsModification();
  }

  private final func ApplyStatsModification() -> Void {
    this.m_statMod = RPGManager.CreateStatModifier(gamedataStatType.ItemLevel, gameStatModifierType.Additive, 10.00);
    GameInstance.GetStatsSystem(this.m_craftingGameController.GetPlayer().GetGame()).AddModifier(this.m_newItem.GetStatsObjectID(), this.m_statMod);
    if TweakDBInterface.GetItemRecord(ItemID.GetTDBID(this.m_newItem.GetID())).TagsContains(WeaponObject.GetRangedWeaponTag()) {
      this.m_levelMod = RPGManager.CreateStatModifier(gamedataStatType.Level, gameStatModifierType.Additive, 1.00);
      GameInstance.GetStatsSystem(this.m_craftingGameController.GetPlayer().GetGame()).AddModifier(this.m_newItem.GetStatsObjectID(), this.m_levelMod);
    };
  }

  private final func RemoveStatsModification() -> Void {
    GameInstance.GetStatsSystem(this.m_craftingGameController.GetPlayer().GetGame()).RemoveModifier(this.m_newItem.GetStatsObjectID(), this.m_statMod);
    if IsDefined(this.m_levelMod) {
      GameInstance.GetStatsSystem(this.m_craftingGameController.GetPlayer().GetGame()).RemoveModifier(this.m_newItem.GetStatsObjectID(), this.m_levelMod);
    };
  }

  private final func UpgradeItem(selectedItemData: InventoryItemData) -> Void {
    let upgradeItemRequest: ref<UpgradeItemRequest> = new UpgradeItemRequest();
    upgradeItemRequest.owner = this.m_craftingGameController.GetPlayer();
    upgradeItemRequest.itemID = InventoryItemData.GetID(selectedItemData);
    this.m_craftingSystem.QueueRequest(upgradeItemRequest);
  }

  private final func FillInventoryData(itemDataHolder: array<InventoryItemData>, out itemArrayHolder: array<ref<IScriptable>>) -> Void {
    let itemData: ref<gameItemData>;
    let itemWrapper: ref<ItemCraftingData>;
    let i: Int32 = 0;
    while i < ArraySize(itemDataHolder) {
      itemWrapper = new ItemCraftingData();
      itemWrapper.inventoryItem = itemDataHolder[i];
      itemData = InventoryItemData.GetGameItemData(itemDataHolder[i]);
      itemWrapper.isUpgradable = this.IsUpgradable(itemDataHolder[i], false);
      itemWrapper.isNew = this.m_craftingGameController.GetScriptableSystem().IsInventoryItemNew(InventoryItemData.GetID(itemDataHolder[i]));
      if !RPGManager.IsItemMaxLevel(itemData) {
        ArrayPush(itemArrayHolder, itemWrapper);
      };
      this.m_inventoryManager.GetOrCreateInventoryItemSortData(itemWrapper.inventoryItem, this.m_craftingGameController.GetScriptableSystem());
      i += 1;
    };
  }

  private final func IsUpgradable(item: InventoryItemData, sendNotification: Bool) -> Bool {
    let levelParams: ref<inkTextParams>;
    let playerDevelopmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_craftingGameController.GetPlayer());
    let pl_level: Int32 = playerDevelopmentData.GetProficiencyLevel(gamedataProficiencyType.Level);
    let it_level: Int32 = InventoryItemData.GetRequiredLevel(item) + 1;
    let canUpgrade: Bool = this.m_craftingSystem.CanItemBeUpgraded(InventoryItemData.GetGameItemData(item)) && pl_level >= it_level;
    if sendNotification && !canUpgrade {
      if pl_level < it_level {
        levelParams = new inkTextParams();
        levelParams.AddNumber("int_0", it_level);
        inkTextRef.SetText(this.m_blockedText, "LocKey#78455", levelParams);
        this.m_notificationType = UIMenuNotificationType.UpgradingLevelToLow;
      } else {
        if !this.m_craftingSystem.EnoughIngredientsForUpgrading(InventoryItemData.GetGameItemData(item)) {
          inkTextRef.SetText(this.m_blockedText, "LocKey#42797");
          this.m_notificationType = UIMenuNotificationType.CraftingNotEnoughMaterial;
        };
      };
    };
    return canUpgrade;
  }
}
