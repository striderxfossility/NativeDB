
public class CraftingLogicController extends CraftingMainLogicController {

  private edit let m_ingredientsWeaponContainer: inkCompoundRef;

  private edit let m_itemPreviewContainer: inkWidgetRef;

  private edit let m_weaponPreviewContainer: inkWidgetRef;

  private edit let m_perkNotificationContainer: inkWidgetRef;

  private edit let m_perkNotificationText: inkTextRef;

  private edit let m_perkIcon: inkImageRef;

  private let m_itemTooltipController: wref<AGenericTooltipController>;

  private let m_quickHackTooltipController: wref<AGenericTooltipController>;

  private let m_tooltipData: ref<InventoryTooltipData>;

  private let m_ingredientWeaponController: wref<InventoryWeaponDisplayController>;

  private let m_ingredientClothingController: wref<InventoryWeaponDisplayController>;

  private let m_selectedItemGameData: ref<gameItemData>;

  private let m_quantityPickerPopupToken: ref<inkGameNotificationToken>;

  private let m_playerCraftBook: wref<CraftBook>;

  public func Init(craftingGameController: wref<CraftingMainGameController>) -> Void {
    this.Init(craftingGameController);
    this.m_playerCraftBook = this.m_craftingSystem.GetPlayerCraftBook();
    this.SetCraftingButton("UI-Crafting-CraftItem");
  }

  public func RefreshListViewContent(opt inventoryItemData: InventoryItemData) -> Void {
    this.m_dataSource.Clear();
    this.m_dataSource.Reset(this.GetRecipesList());
    this.UpdateRecipePreviewPanel(this.m_selectedRecipe);
  }

  protected func SetupIngredientWidgets() -> Void {
    this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_ingredientsWeaponContainer), n"ingredientWeapon", this, n"OnWeaponControllerSpawned");
    this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_ingredientsListContainer), n"ingredientClothes", this, n"OnClothingControllerSpawned");
    inkWidgetRef.SetVisible(this.m_ingredientsWeaponContainer, false);
    this.SetupIngredientWidgets();
  }

  protected cb func OnWeaponControllerSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_ingredientWeaponController = widget.GetControllerByType(n"InventoryWeaponDisplayController") as InventoryWeaponDisplayController;
    let buttonController: wref<inkButtonController> = this.m_ingredientWeaponController.GetRootWidget().GetControllerByType(n"inkButtonController") as inkButtonController;
    buttonController.SetEnabled(false);
  }

  protected cb func OnClothingControllerSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_ingredientClothingController = widget.GetControllerByType(n"InventoryWeaponDisplayController") as InventoryWeaponDisplayController;
  }

  protected func SetupFilters() -> Void {
    ArrayPush(this.m_filters, EnumInt(ItemFilterCategory.AllCount));
    ArrayPush(this.m_filters, EnumInt(ItemFilterCategory.RangedWeapons));
    ArrayPush(this.m_filters, EnumInt(ItemFilterCategory.MeleeWeapons));
    ArrayPush(this.m_filters, EnumInt(ItemFilterCategory.Clothes));
    ArrayPush(this.m_filters, EnumInt(ItemFilterCategory.Consumables));
    ArrayPush(this.m_filters, EnumInt(ItemFilterCategory.Grenades));
    ArrayPush(this.m_filters, EnumInt(ItemFilterCategory.Attachments));
    ArrayPush(this.m_filters, EnumInt(ItemFilterCategory.Cyberware));
    ArrayPush(this.m_filters, EnumInt(ItemFilterCategory.Programs));
    this.SetupFilters();
  }

  protected func UpdateItemPreview(craftableController: ref<CraftableItemLogicController>) -> Void {
    let selectedRecipe: ref<RecipeData>;
    this.SetItemButtonHintsHoverOut(null);
    selectedRecipe = FromVariant(craftableController.GetData()) as RecipeData;
    this.UpdateRecipePreviewPanel(selectedRecipe);
  }

  private final func UpdateRecipePreviewPanel(selectedRecipe: ref<RecipeData>) -> Void {
    let isQuickHack: Bool;
    let isWeapon: Bool;
    let previewEvent: ref<CraftingItemPreviewEvent>;
    this.m_selectedRecipe.isSelected = false;
    if selectedRecipe == null {
      inkWidgetRef.SetVisible(this.m_itemDetailsContainer, false);
      return;
    };
    inkWidgetRef.SetVisible(this.m_itemDetailsContainer, true);
    this.DryMakeItem(selectedRecipe);
    isWeapon = InventoryItemData.IsWeapon(this.m_selectedItemData);
    inkWidgetRef.SetVisible(this.m_weaponPreviewContainer, isWeapon);
    inkWidgetRef.SetVisible(this.m_itemPreviewContainer, !isWeapon);
    if isWeapon && this.m_selectedRecipe.id != selectedRecipe.id {
      previewEvent = new CraftingItemPreviewEvent();
      previewEvent.itemID = this.m_selectedItemGameData.GetID();
      this.QueueEvent(previewEvent);
    };
    this.m_selectedRecipe = selectedRecipe;
    this.m_selectedRecipe.isSelected = true;
    this.SetupIngredients(this.m_craftingSystem.GetItemCraftingCost(this.m_selectedItemGameData), 1);
    this.SetPerkNotification();
    this.UpdateTooltipData();
    this.SetQualityHeader();
    this.m_playerCraftBook.SetRecipeInspected(this.m_selectedRecipe.id.GetID());
    isQuickHack = this.IsProgramInInventory(this.m_selectedRecipe.id);
    this.m_isCraftable = this.m_craftingSystem.CanItemBeCrafted(this.m_selectedItemGameData) && !isQuickHack;
    inkWidgetRef.SetVisible(this.m_blockedText, !this.m_isCraftable);
    this.m_progressButtonController.SetAvaibility(this.m_isCraftable);
    if !this.m_isCraftable {
      if isQuickHack {
        inkTextRef.SetText(this.m_blockedText, "LocKey#78498");
        this.m_notificationType = UIMenuNotificationType.CraftingQuickhack;
      } else {
        if !this.m_craftingSystem.EnoughIngredientsForCrafting(InventoryItemData.GetGameItemData(this.m_selectedItemData)) {
          inkTextRef.SetText(this.m_blockedText, "LocKey#42797");
          this.m_notificationType = UIMenuNotificationType.CraftingNotEnoughMaterial;
        };
      };
    };
  }

  private final func DryMakeItem(selectedRecipe: ref<RecipeData>) -> Void {
    let item: InventoryItemData;
    let statMod: ref<gameStatModifierData>;
    let inventorySystem: ref<InventoryManager> = GameInstance.GetInventoryManager(this.m_craftingGameController.GetPlayer().GetGame());
    let player: wref<PlayerPuppet> = this.m_craftingGameController.GetPlayer();
    let craftedItemID: ItemID = ItemID.FromTDBID(selectedRecipe.id.GetID());
    let itemData: ref<gameItemData> = inventorySystem.CreateItemData(craftedItemID, player);
    CraftingSystem.SetItemLevel(player, itemData);
    CraftingSystem.MarkItemAsCrafted(player, itemData);
    itemData.SetDynamicTag(n"SkipActivityLog");
    if Equals(selectedRecipe.id.Quality().Type(), gamedataQuality.Random) {
      GameInstance.GetStatsSystem(player.GetGame()).RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.Quality);
      statMod = RPGManager.CreateStatModifier(gamedataStatType.Quality, gameStatModifierType.Additive, RPGManager.ItemQualityNameToValue(InventoryItemData.GetQuality(selectedRecipe.inventoryItem)));
      GameInstance.GetStatsSystem(player.GetGame()).AddModifier(itemData.GetStatsObjectID(), statMod);
    } else {
      if selectedRecipe.id.Quality().Value() == -1 {
        if itemData.HasStatData(gamedataStatType.Quality) {
          statMod = RPGManager.CreateStatModifier(gamedataStatType.Quality, gameStatModifierType.Additive, -itemData.GetStatValueByType(gamedataStatType.Quality));
          GameInstance.GetStatsSystem(player.GetGame()).AddModifier(itemData.GetStatsObjectID(), statMod);
        };
      };
    };
    item = this.m_craftingGameController.GetInventoryManager().GetInventoryItemDataForDryItem(itemData);
    this.m_selectedItemGameData = itemData;
    this.m_selectedItemData = item;
  }

  private final func UpdateTooltipData() -> Void {
    this.m_tooltipData = this.GetRecipeOutcomeTooltip(this.m_selectedRecipe, this.m_selectedItemData, this.m_selectedItemGameData);
    if Equals(InventoryItemData.GetItemType(this.m_selectedItemData), gamedataItemType.Prt_Program) {
      if this.m_quickHackTooltipController == null {
        this.AsyncSpawnFromExternal(inkWidgetRef.Get(this.m_tooltipContainer), r"base\\gameplay\\gui\\common\\tooltip\\programtooltip.inkwidget", n"programTooltip", this, n"OnQuickHackTooltipSpawned");
        return;
      };
      this.m_quickHackTooltipController.GetRootWidget().SetVisible(true);
      this.m_quickHackTooltipController.SetData(this.m_tooltipData);
      if this.m_itemTooltipController != null {
        this.m_itemTooltipController.GetRootWidget().SetVisible(false);
      };
    } else {
      if this.m_itemTooltipController == null {
        this.AsyncSpawnFromExternal(inkWidgetRef.Get(this.m_tooltipContainer), r"base\\gameplay\\gui\\common\\tooltip\\itemtooltip.inkwidget", n"itemTooltip", this, n"OnItemTooltipSpawned");
        return;
      };
      this.m_itemTooltipController.GetRootWidget().SetVisible(true);
      this.m_itemTooltipController.SetData(this.m_tooltipData);
      if this.m_quickHackTooltipController != null {
        this.m_quickHackTooltipController.GetRootWidget().SetVisible(false);
      };
    };
  }

  protected cb func OnQuickHackTooltipSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_quickHackTooltipController = widget.GetController() as AGenericTooltipController;
    this.m_quickHackTooltipController.SetData(this.m_tooltipData);
    if this.m_itemTooltipController != null {
      this.m_itemTooltipController.GetRootWidget().SetVisible(false);
    };
  }

  protected cb func OnItemTooltipSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_itemTooltipController = widget.GetController() as AGenericTooltipController;
    this.m_itemTooltipController.SetData(this.m_tooltipData);
    if this.m_quickHackTooltipController != null {
      this.m_quickHackTooltipController.GetRootWidget().SetVisible(false);
    };
  }

  private final func SetQualityHeader() -> Void {
    let iconicLabel: String = GetLocalizedText(UIItemsHelper.QualityToLocalizationKey(gamedataQuality.Iconic));
    let qualityName: CName = InventoryItemData.GetQuality(this.m_selectedItemData);
    let isIconic: Bool = RPGManager.IsItemIconic(InventoryItemData.GetGameItemData(this.m_selectedItemData));
    let quality: gamedataQuality = UIItemsHelper.QualityNameToEnum(qualityName);
    let rarityLabel: String = GetLocalizedText(UIItemsHelper.QualityToLocalizationKey(quality));
    inkTextRef.SetText(this.m_itemQuality, isIconic ? rarityLabel + " / " + iconicLabel : rarityLabel);
    inkWidgetRef.SetState(this.m_itemQuality, qualityName);
    inkTextRef.SetText(this.m_itemName, this.m_selectedRecipe.label);
    inkWidgetRef.SetState(this.m_itemName, qualityName);
  }

  private final func SetPerkNotification() -> Void {
    let perkIcon: String;
    let perkLocKey: String;
    let perkParams: ref<inkTextParams>;
    let quality: gamedataQuality;
    let canCraft: Bool = this.m_craftingSystem.CanCraftGivenQuality(InventoryItemData.GetGameItemData(this.m_selectedItemData), quality);
    if canCraft || Equals(InventoryItemData.GetGameItemData(this.m_selectedItemData).GetItemType(), gamedataItemType.Prt_Program) {
      inkWidgetRef.SetVisible(this.m_perkNotificationContainer, false);
      return;
    };
    inkWidgetRef.SetVisible(this.m_perkNotificationContainer, true);
    switch quality {
      case gamedataQuality.Rare:
        perkLocKey = "LocKey#6630";
        perkIcon = "Crafting_Area_02_Perk_2";
        break;
      case gamedataQuality.Epic:
        perkLocKey = "LocKey#40673";
        perkIcon = "Crafting_Area_06_Perk_3";
        break;
      case gamedataQuality.Legendary:
        perkLocKey = "LocKey#6640";
        perkIcon = "Crafting_Area_09_Perk_1";
    };
    perkParams = new inkTextParams();
    perkParams.AddLocalizedString("perkName", perkLocKey);
    inkTextRef.SetLocalizedTextScript(this.m_perkNotificationText, "LocKey#42796", perkParams);
    this.m_notificationType = UIMenuNotificationType.CraftingNoPerks;
    InkImageUtils.RequestSetImage(this, this.m_perkIcon, "UIIcon." + perkIcon);
  }

  private final func SetupIngredients(ingredient: array<IngredientData>, itemAmount: Int32) -> Void {
    let controller: wref<IngredientListItemLogicController>;
    let data: IngredientData;
    let i: Int32;
    let isInInventory: Bool;
    let itemData: InventoryItemData;
    let ingredientCount: Int32 = ArraySize(ingredient);
    inkWidgetRef.SetVisible(this.m_ingredientsWeaponContainer, false);
    this.m_ingredientClothingController.GetRootWidget().SetVisible(false);
    i = 0;
    while i < ingredientCount {
      data = ingredient[i];
      itemData = this.GetInventoryItemDataFromRecord(data.id);
      controller = this.m_ingredientsControllerList[i];
      if RPGManager.IsItemWeapon(InventoryItemData.GetID(itemData)) {
        inkWidgetRef.SetVisible(this.m_ingredientsWeaponContainer, true);
        this.m_ingredientWeaponController.Setup(itemData);
        controller.SetUnusedState();
        isInInventory = RPGManager.HasItem(this.m_craftingGameController.GetPlayer(), ItemID.GetTDBID(InventoryItemData.GetID(itemData)));
        this.m_ingredientWeaponController.GetRootWidget().SetState(isInInventory ? n"Default" : n"Unavailable");
      } else {
        if RPGManager.IsItemClothing(InventoryItemData.GetID(itemData)) {
          this.m_ingredientClothingController.GetRootWidget().SetVisible(true);
          this.m_ingredientClothingController.Setup(itemData);
          isInInventory = RPGManager.HasItem(this.m_craftingGameController.GetPlayer(), ItemID.GetTDBID(InventoryItemData.GetID(itemData)));
          this.m_ingredientClothingController.GetRootWidget().SetState(isInInventory ? n"Default" : n"Unavailable");
          controller.SetUnusedState();
        } else {
          controller.SetupData(ingredient[i], this.m_tooltipsManager, itemAmount);
        };
      };
      i += 1;
    };
    i = ingredientCount;
    while i < this.m_maxIngredientCount {
      controller = this.m_ingredientsControllerList[i];
      controller.SetUnusedState();
      i += 1;
    };
  }

  protected cb func OnDisplayHoverOver(hoverOverEvent: ref<ItemDisplayHoverOverEvent>) -> Bool {
    let tooltipData: ref<MaterialTooltipData> = new MaterialTooltipData();
    if Equals(hoverOverEvent.display.GetDisplayContext(), IntEnum(0l)) {
      tooltipData.Title = GetLocalizedText(InventoryItemData.GetName(hoverOverEvent.itemData));
      this.m_tooltipsManager.ShowTooltipAtWidget(n"materialTooltip", hoverOverEvent.widget, tooltipData, gameuiETooltipPlacement.RightTop, true);
    };
  }

  protected cb func OnDisplayHoverOut(hoverOutEvent: ref<ItemDisplayHoverOutEvent>) -> Bool {
    this.m_tooltipsManager.HideTooltips();
  }

  private final func OpenQuantityPicker(itemData: InventoryItemData, maxQuantity: Int32) -> Void {
    let data: ref<QuantityPickerPopupData> = new QuantityPickerPopupData();
    data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\item_quantity_picker.inkwidget";
    data.isBlocking = true;
    data.useCursor = true;
    data.queueName = n"modal_popup";
    data.maxValue = maxQuantity;
    data.gameItemData = itemData;
    data.actionType = QuantityPickerActionType.Craft;
    data.sendQuantityChangedEvent = true;
    this.m_quantityPickerPopupToken = this.m_craftingGameController.ShowGameNotification(data);
    this.m_quantityPickerPopupToken.RegisterListener(this, n"OnQuantityPickerEvent");
    this.m_buttonHintsController.Hide();
  }

  protected cb func OnQuantityPickerEvent(data: ref<inkGameNotificationData>) -> Bool {
    let closeData: ref<QuantityPickerPopupCloseData> = data as QuantityPickerPopupCloseData;
    let quantityData: ref<PickerChoosenQuantityChangedEvent> = data as PickerChoosenQuantityChangedEvent;
    if closeData != null {
      this.m_quantityPickerPopupToken = null;
      if closeData.choosenQuantity != -1 {
        this.CraftItem(this.m_selectedRecipe, closeData.choosenQuantity);
        this.m_buttonHintsController.Show();
      };
    };
    if quantityData != null {
      this.SetupIngredients(this.m_craftingSystem.GetItemCraftingCost(this.m_selectedItemGameData), quantityData.choosenQuantity);
    };
  }

  protected cb func OnHoldFinished(evt: ref<ProgressBarFinishedProccess>) -> Bool {
    let quantity: Int32;
    if !this.m_isPanelOpen {
      return false;
    };
    if this.m_selectedRecipe.id.TagsContains(n"Grenade") || this.m_selectedRecipe.id.TagsContains(n"Consumable") || this.m_selectedRecipe.id.TagsContains(n"Ammo") || Equals(InventoryItemData.GetItemType(this.m_selectedRecipe.inventoryItem), gamedataItemType.Gen_CraftingMaterial) {
      quantity = this.m_craftingSystem.GetMaxCraftingAmount(InventoryItemData.GetGameItemData(this.m_selectedItemData));
      if quantity > 1 {
        this.OpenQuantityPicker(this.m_selectedItemData, quantity);
        return true;
      };
    };
    if this.m_selectedRecipe.id.TagsContains(n"Ammo") {
      this.CraftItem(this.m_selectedRecipe, 1);
    } else {
      this.CraftItem(this.m_selectedRecipe, this.m_selectedRecipe.amount);
    };
  }

  protected func SetItemButtonHintsHoverOver(evt: ref<inkPointerEvent>) -> Void {
    if this.m_isCraftable {
      this.m_buttonHintsController.AddButtonHint(n"craft_item", GetLocalizedText("UI-Crafting-hold_to_craft"));
    };
  }

  private final func GetRecipesList() -> array<ref<IScriptable>> {
    let i: Int32;
    let randomQuality: Bool;
    let recipeData: ref<RecipeData>;
    let recipeDatas: array<ref<IScriptable>>;
    let tempItemRecord: wref<Item_Record>;
    let itemRecords: array<wref<Item_Record>> = this.m_playerCraftBook.GetCraftableItems();
    ArrayClear(recipeDatas);
    i = 0;
    while i < ArraySize(itemRecords) {
      tempItemRecord = itemRecords[i];
      if IsDefined(tempItemRecord) {
        recipeData = this.m_craftingSystem.GetRecipeData(tempItemRecord);
        recipeData.isNew = this.m_playerCraftBook.IsRecipeNew(recipeData.id.GetID());
        recipeData.isCraftable = this.m_craftingSystem.CanItemBeCrafted(tempItemRecord) && !this.IsProgramInInventory(tempItemRecord);
        recipeData.inventoryItem = this.m_inventoryManager.GetInventoryItemDataFromItemRecord(recipeData.id);
        randomQuality = Equals(InventoryItemData.GetQuality(recipeData.inventoryItem), n"Random") || Equals(InventoryItemData.GetQuality(recipeData.inventoryItem), n"");
        if randomQuality {
          InventoryItemData.SetQuality(recipeData.inventoryItem, RPGManager.SetQualityBasedOnCraftingSkill(this.m_craftingGameController.GetPlayer()));
        };
        this.m_inventoryManager.GetOrCreateInventoryItemSortData(recipeData.inventoryItem, this.m_craftingGameController.GetScriptableSystem(), randomQuality);
        ArrayPush(recipeDatas, recipeData);
      };
      i += 1;
    };
    return recipeDatas;
  }

  private final func GetInventoryItemDataFromRecord(itemRecord: ref<Item_Record>) -> InventoryItemData {
    let itemData: InventoryItemData = this.m_inventoryManager.GetInventoryItemDataFromItemRecord(itemRecord);
    this.m_inventoryManager.GetOrCreateInventoryItemSortData(itemData, this.m_craftingGameController.GetScriptableSystem());
    return itemData;
  }

  private final func GetRecipeOutcomeTooltip(recipeData: ref<RecipeData>, inventoryItemData: InventoryItemData, gameData: ref<gameItemData>) -> ref<InventoryTooltipData> {
    let tooltipData: ref<InventoryTooltipData>;
    InventoryItemData.SetItemLevel(inventoryItemData, InventoryItemData.GetItemLevel(inventoryItemData));
    tooltipData = InventoryTooltipData.FromRecipeAndItemData(this.m_craftingGameController.GetPlayer().GetGame(), recipeData, inventoryItemData, inventoryItemData, gameData);
    InventoryItemData.SetGameItemData(tooltipData.inventoryItemData, gameData);
    if Equals(InventoryItemData.GetItemType(inventoryItemData), gamedataItemType.Gad_Grenade) {
      tooltipData.grenadeData = this.m_inventoryManager.GetGrenadeTooltipData(inventoryItemData);
    };
    if Equals(InventoryItemData.GetItemType(inventoryItemData), gamedataItemType.Prt_Program) {
      tooltipData.quickhackData = this.m_inventoryManager.GetQuickhackTooltipData(ItemID.GetTDBID(InventoryItemData.GetID(inventoryItemData)));
    };
    return tooltipData;
  }

  private final func CraftItem(selectedRecipe: ref<RecipeData>, amount: Int32) -> Void {
    let craftItemRequest: ref<CraftItemRequest>;
    if NotEquals(selectedRecipe.label, "") {
      craftItemRequest = new CraftItemRequest();
      craftItemRequest.target = this.m_craftingGameController.GetPlayer();
      craftItemRequest.itemRecord = selectedRecipe.id;
      craftItemRequest.amount = amount;
      if selectedRecipe.id.TagsContains(n"Ammo") {
        craftItemRequest.bulletAmount = selectedRecipe.amount;
      };
      this.m_craftingSystem.QueueRequest(craftItemRequest);
    };
  }

  private final func IsProgramInInventory(itemRecord: ref<Item_Record>) -> Bool {
    if Equals(itemRecord.ItemType().Type(), gamedataItemType.Prt_Program) {
      return RPGManager.HasItem(this.m_craftingGameController.GetPlayer(), itemRecord.GetID());
    };
    return false;
  }

  protected cb func OnItemDisplayHoverOver(evt: ref<ItemDisplayHoverOverEvent>) -> Bool {
    if !InventoryItemData.IsEmpty(evt.itemData) {
      this.m_playerCraftBook.SetRecipeInspected(ItemID.GetTDBID(InventoryItemData.GetID(evt.itemData)));
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_selectedItemGameData) {
      this.m_selectedItemGameData = null;
    };
    super.OnUninitialize();
  }
}
