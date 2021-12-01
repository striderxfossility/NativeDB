
public class InventoryItemDisplayController extends BaseButtonView {

  protected edit let m_widgetWrapper: inkWidgetRef;

  protected edit let m_itemName: inkTextRef;

  protected edit let m_itemPrice: inkTextRef;

  protected edit let m_itemRarity: inkWidgetRef;

  protected edit let m_commonModsRoot: inkCompoundRef;

  protected edit let m_itemImage: inkImageRef;

  protected edit let m_itemFallbackImage: inkImageRef;

  protected edit let m_itemEmptyImage: inkImageRef;

  protected edit let m_itemSelectedArrow: inkWidgetRef;

  protected edit let m_quantintyAmmoIcon: inkWidgetRef;

  protected edit let m_quantityWrapper: inkCompoundRef;

  protected edit let m_quantityText: inkTextRef;

  protected edit let m_weaponType: inkTextRef;

  protected edit const let m_highlightFrames: array<inkWidgetRef>;

  protected edit const let m_equippedWidgets: array<inkWidgetRef>;

  protected edit const let m_hideWhenEquippedWidgets: array<inkWidgetRef>;

  protected edit const let m_showInEmptyWidgets: array<inkWidgetRef>;

  protected edit const let m_hideInEmptyWidgets: array<inkWidgetRef>;

  protected edit const let m_backgroundFrames: array<inkWidgetRef>;

  protected edit let m_requirementsWrapper: inkWidgetRef;

  protected edit let m_iconicTint: inkWidgetRef;

  protected edit let m_rarityWrapper: inkWidgetRef;

  protected edit let m_rarityCommonWrapper: inkWidgetRef;

  protected edit let m_weaponTypeImage: inkImageRef;

  protected edit let m_questItemMaker: inkWidgetRef;

  protected edit let m_equippedMarker: inkWidgetRef;

  protected edit let m_labelsContainer: inkCompoundRef;

  protected edit let m_backgroundBlueprint: inkWidgetRef;

  protected edit let m_iconBlueprint: inkWidgetRef;

  protected edit let m_fluffBlueprint: inkImageRef;

  protected edit let m_lootitemflufficon: inkWidgetRef;

  protected edit let m_lootitemtypeicon: inkImageRef;

  protected edit let m_slotItemsCountWrapper: inkWidgetRef;

  protected edit let m_slotItemsCount: inkTextRef;

  protected edit let m_iconErrorIndicator: inkWidgetRef;

  protected edit let m_newItemsWrapper: inkWidgetRef;

  protected edit let m_newItemsCounter: inkTextRef;

  protected edit let m_lockIcon: inkWidgetRef;

  protected edit let m_comparisionArrow: inkWidgetRef;

  protected let m_inventoryDataManager: ref<InventoryDataManagerV2>;

  protected let m_uiScriptableSystem: wref<UIScriptableSystem>;

  protected let m_itemID: ItemID;

  protected let m_itemData: InventoryItemData;

  protected let m_recipeData: ref<RecipeData>;

  @default(InventoryItemDisplayController, gamedataEquipmentArea.Invalid)
  protected let m_equipmentArea: gamedataEquipmentArea;

  @default(InventoryItemDisplayController, gamedataItemType.Invalid)
  protected let m_itemType: gamedataItemType;

  protected let m_emptySlotImage: CName;

  protected let m_slotName: String;

  protected let m_slotIndex: Int32;

  protected let m_attachmentsDisplay: array<wref<InventoryItemModSlotDisplay>>;

  protected let m_slotID: TweakDBID;

  private let m_itemDisplayContext: ItemDisplayContext;

  protected let m_labelsContainerController: wref<ItemLabelContainerController>;

  @default(InventoryItemDisplayController, undefined)
  protected let m_defaultFallbackImage: CName;

  @default(InventoryItemDisplayController, icon_add)
  protected let m_defaultEmptyImage: CName;

  @default(InventoryItemDisplayController, base\gameplay\gui\fullscreen\inventory\inventory4_atlas.inkatlas)
  protected let m_defaultEmptyImageAtlas: String;

  protected let m_emptyImage: CName;

  protected let m_emptyImageAtlas: String;

  protected let m_enoughMoney: Bool;

  protected let m_owned: Bool;

  protected let m_requirementsMet: Bool;

  protected let m_tooltipData: ref<InventoryTooltipData>;

  protected let m_isNew: Bool;

  protected let m_newItemsIDs: array<ItemID>;

  protected let m_newItemsFetched: Bool;

  protected let m_isBuybackStack: Bool;

  protected let m_parentItemData: wref<gameItemData>;

  protected let m_isLocked: Bool;

  protected let m_isUpgradable: Bool;

  @default(InventoryItemDisplayController, true)
  protected let m_hasAvailableItems: Bool;

  protected let DEBUG_isIconError: Bool;

  protected let DEBUG_iconErrorInfo: ref<DEBUG_IconErrorInfo>;

  protected let DEBUG_resolvedIconName: String;

  protected let DEBUG_recordItemName: String;

  protected let DEBUG_innerItemName: String;

  protected let DEBUG_isIconManuallySet: Bool;

  protected let DEBUG_iconsNameResolverIsDebug: Bool;

  private let m_parrentWrappedDataObject: wref<WrappedInventoryItemData>;

  public final func DEBUG_GetIconErrorInfo() -> ref<DEBUG_IconErrorInfo> {
    return this.DEBUG_iconErrorInfo;
  }

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    if IsDefined(this.m_ButtonController) {
      this.m_ButtonController.RegisterToCallback(n"OnButtonClick", this, n"OnButtonClick");
    };
    this.RegisterToCallback(n"OnHoverOver", this, n"OnDisplayHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnDisplayHoverOut");
    this.RegisterToCallback(n"OnRelease", this, n"OnDisplayClicked");
    this.RegisterToCallback(n"OnHold", this, n"OnDisplayHold");
    this.m_labelsContainerController = inkWidgetRef.GetController(this.m_labelsContainer) as ItemLabelContainerController;
    inkWidgetRef.SetVisible(this.m_newItemsWrapper, false);
    this.RefreshUI();
    this.m_emptyImage = this.m_defaultEmptyImage;
    this.m_emptyImageAtlas = this.m_defaultEmptyImageAtlas;
  }

  protected cb func OnUninitialize() -> Bool {
    let evt: ref<inkPointerEvent>;
    this.OnDisplayHoverOut(evt);
  }

  protected cb func OnDisplayHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let hoverOverEvent: ref<ItemDisplayHoverOverEvent>;
    if evt.GetCurrentTarget() == this.GetRootWidget() {
      hoverOverEvent = new ItemDisplayHoverOverEvent();
      hoverOverEvent.itemData = this.GetItemData();
      hoverOverEvent.display = this;
      hoverOverEvent.widget = evt.GetTarget();
      hoverOverEvent.isBuybackStack = this.m_isBuybackStack;
      this.QueueEvent(hoverOverEvent);
      if this.m_isNew {
        this.SetIsNew(false);
      };
    };
  }

  protected cb func OnDisplayHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    let hoverOutEvent: ref<ItemDisplayHoverOutEvent> = new ItemDisplayHoverOutEvent();
    this.QueueEvent(hoverOutEvent);
  }

  protected cb func OnDisplayClicked(evt: ref<inkPointerEvent>) -> Bool {
    let clickEvent: ref<ItemDisplayClickEvent> = new ItemDisplayClickEvent();
    clickEvent.itemData = this.GetItemData();
    clickEvent.actionName = evt.GetActionName();
    clickEvent.displayContext = this.m_itemDisplayContext;
    clickEvent.isBuybackStack = this.m_isBuybackStack;
    clickEvent.evt = evt;
    this.HandleLocalClick(evt);
    this.QueueEvent(clickEvent);
  }

  protected final func HandleLocalClick(evt: ref<inkPointerEvent>) -> Void {
    if Equals(this.m_itemDisplayContext, ItemDisplayContext.Vendor) && !this.m_requirementsMet {
      this.PlayLibraryAnimationOnTargets(n"itemDisplayRequirements_OnClick", SelectWidgets(this.GetRootWidget()));
    };
  }

  protected cb func OnDisplayHold(evt: ref<inkPointerEvent>) -> Bool {
    let holdEvent: ref<ItemDisplayHoldEvent>;
    if evt.GetHoldProgress() >= 1.00 {
      holdEvent = new ItemDisplayHoldEvent();
      holdEvent.itemData = this.GetItemData();
      holdEvent.actionName = evt.GetActionName();
      this.QueueEvent(holdEvent);
    };
  }

  public func Setup(itemData: InventoryItemData, slotID: TweakDBID, opt displayContext: ItemDisplayContext) -> Void {
    let hasItemsCounter: Bool;
    this.SetDisplayContext(displayContext, null);
    if TDBID.IsValid(slotID) {
      this.m_slotID = slotID;
    };
    this.m_itemData = itemData;
    if Equals(this.m_itemDisplayContext, ItemDisplayContext.Attachment) {
      hasItemsCounter = this.UpdateItemsCounter(this.m_itemData, this.m_slotID, this.m_itemType, this.m_equipmentArea);
      this.UpdateNewItemsIndicator(this.m_itemData, this.m_slotID, this.m_itemType, this.m_equipmentArea);
      this.m_hasAvailableItems = ArraySize(this.m_newItemsIDs) > 0;
      inkWidgetRef.SetVisible(this.m_slotItemsCountWrapper, true);
      inkWidgetRef.SetState(this.m_slotItemsCountWrapper, hasItemsCounter ? n"Default" : n"NoItems");
    };
    this.Setup(itemData);
  }

  public func Setup(inventoryDataManager: ref<InventoryDataManagerV2>, itemData: InventoryItemData, slotID: TweakDBID, opt displayContext: ItemDisplayContext, opt forceUpdateCounter: Bool) -> Void {
    let hasItemsCounter: Bool;
    this.m_inventoryDataManager = inventoryDataManager;
    this.SetDisplayContext(displayContext, null);
    if TDBID.IsValid(slotID) {
      this.m_slotID = slotID;
    };
    this.m_itemData = itemData;
    if Equals(this.m_itemDisplayContext, ItemDisplayContext.Attachment) {
      hasItemsCounter = this.UpdateItemsCounter(this.m_itemData, this.m_slotID, this.m_itemType, this.m_equipmentArea, forceUpdateCounter);
      this.UpdateNewItemsIndicator(this.m_itemData, this.m_slotID, this.m_itemType, this.m_equipmentArea, forceUpdateCounter);
      this.m_hasAvailableItems = ArraySize(this.m_newItemsIDs) > 0;
      inkWidgetRef.SetVisible(this.m_slotItemsCountWrapper, true);
      if InventoryItemData.IsEmpty(this.m_itemData) {
        inkWidgetRef.SetState(this.m_slotItemsCountWrapper, hasItemsCounter ? n"Default" : n"NoItems");
        inkWidgetRef.SetVisible(this.m_slotItemsCountWrapper, true);
      } else {
        inkWidgetRef.SetVisible(this.m_slotItemsCountWrapper, false);
      };
    };
    this.Setup(itemData);
  }

  public func Setup(tooltipData: ref<InventoryTooltipData>) -> Void {
    if this.m_tooltipData != tooltipData {
      this.m_tooltipData = tooltipData;
    };
    if NotEquals(this.m_itemData, tooltipData.inventoryItemData) {
      this.m_itemData = tooltipData.inventoryItemData;
    };
    this.RefreshUI();
  }

  public func Setup(itemData: InventoryItemData, opt slotIndex: Int32) -> Void {
    this.m_itemData = itemData;
    this.m_slotIndex = slotIndex;
    this.RefreshUI();
  }

  public func Setup(recipeData: ref<RecipeData>, opt displayContext: ItemDisplayContext) -> Void {
    this.SetDisplayContext(displayContext, recipeData);
    this.m_isUpgradable = this.m_recipeData.isCraftable;
    this.RefreshUI();
  }

  public func Setup(itemData: InventoryItemData, displayContext: ItemDisplayContext, opt enoughMoney: Bool, opt owned: Bool, opt isUpgradable: Bool) -> Void {
    this.SetDisplayContext(displayContext, null);
    this.m_enoughMoney = enoughMoney;
    this.m_owned = owned;
    this.m_isUpgradable = isUpgradable;
    this.Setup(itemData);
  }

  public func Setup(itemData: InventoryItemData, equipmentArea: gamedataEquipmentArea, opt slotName: String, opt slotIndex: Int32, opt displayContext: ItemDisplayContext) -> Void {
    this.m_equipmentArea = equipmentArea;
    this.m_slotName = slotName;
    this.m_slotIndex = slotIndex;
    this.SetDisplayContext(displayContext, null);
    this.Setup(itemData, slotIndex);
  }

  public func Bind(inventoryDataManager: ref<InventoryDataManagerV2>, equipmentArea: gamedataEquipmentArea, opt slotIndex: Int32, opt displayContext: ItemDisplayContext) -> Void {
    this.m_equipmentArea = equipmentArea;
    this.m_slotIndex = slotIndex;
    this.m_inventoryDataManager = inventoryDataManager;
    this.SetDisplayContext(displayContext, null);
    this.OnItemUpdate(inventoryDataManager.GetEquippedItemIdInArea(this.m_equipmentArea, this.m_slotIndex));
  }

  public func SetParentItem(parentItemData: wref<gameItemData>) -> Void {
    this.m_parentItemData = parentItemData;
  }

  public func BindComparisonAndScriptableSystem(uiScriptableSystem: wref<UIScriptableSystem>, comparisonResolver: wref<ItemPreferredComparisonResolver>) -> Void {
    let hasNewItems: Bool;
    this.m_uiScriptableSystem = uiScriptableSystem;
    this.UpdateItemsCounter(this.m_itemData, this.m_slotID, this.m_itemType, this.m_equipmentArea);
    hasNewItems = this.UpdateNewItemsIndicator(this.m_itemData, this.m_slotID, this.m_itemType, this.m_equipmentArea);
    if hasNewItems {
      inkWidgetRef.SetVisible(this.m_slotItemsCountWrapper, false);
    };
  }

  public final func SetLocked(value: Bool) -> Void {
    this.m_isLocked = value;
    this.UpdateLocked();
  }

  public final func IsLocked() -> Bool {
    return this.m_isLocked;
  }

  public final func SetHUDMode(inHUD: Bool) -> Void {
    this.GetRootWidget().SetState(inHUD ? n"HUD" : n"Default");
  }

  protected final func SetDisplayContext(context: ItemDisplayContext, recipeData: ref<RecipeData>) -> Void {
    let itemInventory: InventoryItemData;
    this.m_itemDisplayContext = context;
    this.m_recipeData = recipeData;
    if Equals(this.m_itemDisplayContext, ItemDisplayContext.Crafting) && IsDefined(this.m_recipeData) {
      InventoryItemData.SetEmpty(itemInventory, false);
      InventoryItemData.SetID(itemInventory, ItemID.CreateQuery(this.m_recipeData.id.GetID()));
    };
  }

  public final func GetDisplayContext() -> ItemDisplayContext {
    return this.m_itemDisplayContext;
  }

  public func InvalidateContent() -> Void {
    this.OnItemUpdate(this.m_inventoryDataManager.GetEquippedItemIdInArea(this.m_equipmentArea, this.m_slotIndex));
  }

  public func OnItemUpdate(itemID: ItemID) -> Void {
    let hasNewItems: Bool;
    this.m_itemID = itemID;
    this.m_itemData = this.m_inventoryDataManager.GetItemDataFromIDInLoadout(itemID);
    this.UpdateItemsCounter(this.m_itemData, this.m_slotID, this.m_itemType, this.m_equipmentArea);
    hasNewItems = this.UpdateNewItemsIndicator(this.m_itemData, this.m_slotID, this.m_itemType, this.m_equipmentArea);
    if hasNewItems {
      inkWidgetRef.SetVisible(this.m_slotItemsCountWrapper, false);
    };
    this.RefreshUI();
  }

  public func UpdateThisSlotItems(opt item: InventoryItemData, opt slotID: TweakDBID, opt itemType: gamedataItemType, opt equipmentArea: gamedataEquipmentArea, opt force: Bool) -> Void {
    if !this.m_newItemsFetched || force {
      ArrayClear(this.m_newItemsIDs);
      if slotID == t"AttachmentSlots.Scope" || slotID == t"AttachmentSlots.PowerModule" {
        this.m_inventoryDataManager.GetPlayerItemsIDsFast(this.m_parentItemData.GetID(), slotID, itemType, equipmentArea, true, this.m_newItemsIDs);
      } else {
        this.m_inventoryDataManager.GetPlayerItemsIDs(item, slotID, itemType, equipmentArea, true, this.m_newItemsIDs);
      };
      if Equals(equipmentArea, gamedataEquipmentArea.Consumable) {
        this.m_newItemsIDs = this.m_inventoryDataManager.FilterHotkeyConsumables(this.m_newItemsIDs);
      };
      if InventoryDataManagerV2.IsProgramSlot(slotID) {
        this.m_newItemsIDs = this.m_inventoryDataManager.FilterOutWorsePrograms(this.m_newItemsIDs);
        this.m_newItemsIDs = this.m_inventoryDataManager.DistinctPrograms(this.m_newItemsIDs);
      };
      this.m_newItemsFetched = true;
    };
  }

  public func UpdateItemsCounter(opt item: InventoryItemData, opt slotID: TweakDBID, opt itemType: gamedataItemType, opt equipmentArea: gamedataEquipmentArea, opt force: Bool) -> Bool {
    let itemsCount: Int32;
    if !ItemID.IsValid(this.m_itemID) && InventoryItemData.IsEmpty(this.m_itemData) {
      this.UpdateThisSlotItems(item, slotID, itemType, equipmentArea, force);
      itemsCount = ArraySize(this.m_newItemsIDs);
      inkTextRef.SetText(this.m_slotItemsCount, IntToString(itemsCount));
      inkWidgetRef.SetVisible(this.m_slotItemsCountWrapper, itemsCount > 0);
      return itemsCount > 0;
    };
    inkTextRef.SetText(this.m_slotItemsCount, IntToString(0));
    inkWidgetRef.SetVisible(this.m_slotItemsCountWrapper, false);
    return false;
  }

  private final func IsInRestrictedNewArea(equipmentArea: gamedataEquipmentArea) -> Bool {
    return Equals(equipmentArea, gamedataEquipmentArea.AbilityCW) || Equals(equipmentArea, gamedataEquipmentArea.Gadget) || Equals(equipmentArea, gamedataEquipmentArea.QuickSlot) || Equals(equipmentArea, gamedataEquipmentArea.Consumable);
  }

  protected func UpdateNewItemsIndicator(opt item: InventoryItemData, opt slotID: TweakDBID, opt itemType: gamedataItemType, opt equipmentArea: gamedataEquipmentArea, opt force: Bool) -> Bool {
    let i: Int32;
    let itemsCount: Int32;
    if Equals(equipmentArea, gamedataEquipmentArea.Weapon) && this.m_slotIndex != 0 || this.IsInRestrictedNewArea(equipmentArea) {
      inkWidgetRef.SetVisible(this.m_newItemsWrapper, false);
      return false;
    };
    if this.m_uiScriptableSystem != null {
      this.UpdateThisSlotItems(item, slotID, itemType, equipmentArea, force);
      i = 0;
      while i < ArraySize(this.m_newItemsIDs) {
        if this.m_uiScriptableSystem.IsInventoryItemNew(this.m_newItemsIDs[i]) {
          itemsCount += 1;
        };
        i += 1;
      };
      inkTextRef.SetText(this.m_newItemsCounter, IntToString(itemsCount));
      inkWidgetRef.SetVisible(this.m_newItemsWrapper, itemsCount > 0);
      return itemsCount > 0;
    };
    inkWidgetRef.SetVisible(this.m_newItemsWrapper, false);
    return false;
  }

  public func SetDefaultShadowIcon(textureAtlasPart: CName, opt textureAtlas: String) -> Void {
    this.m_emptyImage = textureAtlasPart;
    if IsStringValid(textureAtlas) {
      this.m_emptyImageAtlas = textureAtlas;
    } else {
      this.m_emptyImageAtlas = this.m_defaultEmptyImageAtlas;
    };
  }

  protected func RefreshUI() -> Void {
    let equipmentArea: gamedataEquipmentArea;
    this.UpdateIcon();
    this.UpdateRarity();
    this.UpdateMods();
    this.UpdateQuantity();
    this.UpdateEquipped();
    this.UpdateItemName();
    this.UpdatePrice();
    this.UpdateIndicators();
    this.UpdateIsNewIndicator();
    this.UpdateRequirements();
    this.UpdateBlueprint();
    this.UpdateLoot();
    this.UpdateEmptyWidgets();
    this.UpdateLocked();
    equipmentArea = InventoryItemData.GetEquipmentArea(this.m_itemData);
    if Equals(equipmentArea, gamedataEquipmentArea.Weapon) {
      inkTextRef.SetLocalizedTextScript(this.m_weaponType, InventoryItemData.GetLocalizedItemType(this.m_itemData));
      inkWidgetRef.SetVisible(this.m_weaponType, true);
      InkImageUtils.RequestSetImage(this, this.m_weaponTypeImage, UIItemsHelper.GetWeaponTypeIcon(InventoryItemData.GetItemType(this.m_itemData)));
      inkWidgetRef.SetVisible(this.m_weaponTypeImage, true);
    } else {
      inkTextRef.SetLocalizedTextScript(this.m_weaponType, InventoryItemData.GetLocalizedItemType(this.m_itemData));
      inkWidgetRef.SetVisible(this.m_weaponType, false);
      inkWidgetRef.SetVisible(this.m_weaponTypeImage, false);
    };
    if InventoryItemData.IsEmpty(this.m_itemData) {
      inkWidgetRef.SetVisible(this.m_comparisionArrow, false);
    } else {
      inkWidgetRef.SetVisible(this.m_comparisionArrow, InventoryDataManagerV2.IsEquipmentAreaComparable(equipmentArea));
    };
  }

  protected func UpdateEmptyWidgets() -> Void {
    let isEmpty: Bool = Equals(this.m_itemDisplayContext, ItemDisplayContext.Crafting) && IsDefined(this.m_recipeData) ? false : InventoryItemData.IsEmpty(this.m_itemData);
    let i: Int32 = 0;
    while i < ArraySize(this.m_showInEmptyWidgets) {
      inkWidgetRef.SetVisible(this.m_showInEmptyWidgets[i], isEmpty);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_hideInEmptyWidgets) {
      inkWidgetRef.SetVisible(this.m_hideInEmptyWidgets[i], !isEmpty);
      i += 1;
    };
  }

  protected func UpdateLocked() -> Void {
    let i: Int32;
    let hasNoItems: Bool = InventoryItemData.IsEmpty(this.m_itemData) && !this.m_hasAvailableItems;
    let shouldBeGray: Bool = this.m_isLocked || hasNoItems;
    inkWidgetRef.SetState(this.m_widgetWrapper, shouldBeGray ? n"Locked" : n"Default");
    inkWidgetRef.SetVisible(this.m_lockIcon, this.m_isLocked);
    i = 0;
    while i < ArraySize(this.m_backgroundFrames) {
      inkWidgetRef.SetState(this.m_backgroundFrames[i], shouldBeGray ? n"Locked" : n"Default");
      inkWidgetRef.SetVisible(this.m_backgroundFrames[i], !hasNoItems);
      i += 1;
    };
  }

  protected func UpdateLoot() -> Void {
    if Equals(InventoryItemData.GetLootItemType(this.m_itemData), LootItemType.Default) {
      inkWidgetRef.SetVisible(this.m_lootitemflufficon, true);
      inkWidgetRef.SetVisible(this.m_lootitemtypeicon, false);
    } else {
      if Equals(InventoryItemData.GetLootItemType(this.m_itemData), LootItemType.Quest) {
        inkWidgetRef.SetVisible(this.m_lootitemflufficon, false);
        inkImageRef.SetTexturePart(this.m_lootitemtypeicon, n"quest");
        inkWidgetRef.SetVisible(this.m_lootitemtypeicon, true);
      } else {
        if Equals(InventoryItemData.GetLootItemType(this.m_itemData), LootItemType.Shard) {
          inkWidgetRef.SetVisible(this.m_lootitemflufficon, false);
          inkImageRef.SetTexturePart(this.m_lootitemtypeicon, n"shard");
          inkWidgetRef.SetVisible(this.m_lootitemtypeicon, true);
        };
      };
    };
  }

  protected func UpdateBlueprint() -> Void {
    let quality: CName;
    let localItemData: ref<gameItemData> = InventoryItemData.GetGameItemData(this.m_itemData);
    let showBlueprint: Bool = Equals(this.m_itemDisplayContext, ItemDisplayContext.Crafting) && IsDefined(this.m_recipeData) || IsDefined(localItemData) && localItemData.HasTag(n"Recipe");
    inkWidgetRef.SetVisible(this.m_backgroundBlueprint, showBlueprint);
    inkWidgetRef.SetVisible(this.m_iconBlueprint, showBlueprint);
    if showBlueprint {
      if Equals(this.m_itemDisplayContext, ItemDisplayContext.Crafting) && IsDefined(this.m_recipeData) {
        quality = UIItemsHelper.QualityEnumToName(this.m_recipeData.id.Quality().Type());
      } else {
        quality = InventoryItemData.GetQuality(this.m_itemData);
      };
      inkWidgetRef.SetState(this.m_backgroundBlueprint, quality);
      inkWidgetRef.SetState(this.m_fluffBlueprint, quality);
      inkWidgetRef.SetState(this.m_itemImage, quality);
      inkWidgetRef.Get(this.m_itemImage).DisableAllEffectsByType(inkEffectType.ColorFill);
      inkWidgetRef.Get(this.m_itemImage).SetEffectEnabled(inkEffectType.ColorFill, quality, true);
    } else {
      inkWidgetRef.SetState(this.m_itemImage, n"Default");
      inkWidgetRef.Get(this.m_itemImage).DisableAllEffectsByType(inkEffectType.ColorFill);
    };
  }

  protected func UpdateRequirements() -> Void {
    let localItemData: ref<gameItemData>;
    let requirementData: SItemStackRequirementData;
    let requirement: Bool = true;
    let moneyRequirementFail: Bool = Equals(this.m_itemDisplayContext, ItemDisplayContext.Vendor) && !this.m_enoughMoney;
    let streetCredRequirementMet: Bool = true;
    this.m_requirementsMet = true;
    inkWidgetRef.SetState(this.m_requirementsWrapper, n"Default");
    if moneyRequirementFail && !this.m_isBuybackStack {
      this.m_labelsContainerController.Add(ItemLabelType.Money);
    };
    localItemData = InventoryItemData.GetGameItemData(this.m_itemData);
    if IsDefined(localItemData) && localItemData.GetStatValueByType(gamedataStatType.Strength) > 0.00 && InventoryItemData.GetPlayerStrenght(this.m_itemData) < RoundF(localItemData.GetStatValueByType(gamedataStatType.Strength)) {
      requirement = false;
    } else {
      if InventoryItemData.GetRequiredLevel(this.m_itemData) > 0 && InventoryItemData.GetPlayerLevel(this.m_itemData) < InventoryItemData.GetRequiredLevel(this.m_itemData) {
        requirement = false;
      };
    };
    if !InventoryItemData.IsRequirementMet(this.m_itemData) {
      requirementData = InventoryItemData.GetRequirement(this.m_itemData);
      if Equals(requirementData.statType, gamedataStatType.StreetCred) && InventoryItemData.GetPlayerStreetCred(this.m_itemData) < RoundF(requirementData.requiredValue) {
        streetCredRequirementMet = false;
      };
      requirement = false;
    } else {
      if !InventoryItemData.IsEquippable(this.m_itemData) {
        requirement = false;
      };
    };
    if !streetCredRequirementMet {
      inkWidgetRef.SetState(this.m_requirementsWrapper, n"StreetCred");
      this.m_requirementsMet = false;
    } else {
      if moneyRequirementFail {
        inkWidgetRef.SetState(this.m_requirementsWrapper, n"Money");
        this.m_requirementsMet = false;
      } else {
        if !requirement {
          inkWidgetRef.SetState(this.m_requirementsWrapper, n"Requirements");
          this.m_requirementsMet = false;
        };
      };
    };
    if Equals(this.m_itemDisplayContext, ItemDisplayContext.Crafting) {
      inkWidgetRef.SetState(this.m_requirementsWrapper, !this.m_isUpgradable ? n"NoCraftable" : n"Default");
    };
  }

  protected func UpdateIndicators() -> Void {
    let localData: ref<gameItemData>;
    if IsDefined(this.m_labelsContainerController) {
      this.m_labelsContainerController.Clear();
    };
    if this.m_owned && Equals(this.m_itemDisplayContext, ItemDisplayContext.VendorPlayer) {
      if IsDefined(this.m_labelsContainerController) {
        this.m_labelsContainerController.Add(ItemLabelType.Owned);
      };
    };
    if this.m_isBuybackStack {
      this.m_labelsContainerController.Add(ItemLabelType.Buyback);
    };
    localData = InventoryItemData.GetGameItemData(this.m_itemData);
    if IsDefined(localData) {
      inkWidgetRef.SetVisible(this.m_questItemMaker, localData.HasTag(n"Quest") || localData.HasTag(n"UnequipBlocked"));
    } else {
      inkWidgetRef.SetVisible(this.m_questItemMaker, false);
    };
  }

  protected func UpdateIsNewIndicator() -> Void {
    if this.m_isNew {
      this.m_labelsContainerController.Add(ItemLabelType.New);
    } else {
      this.m_labelsContainerController.Remove(ItemLabelType.New);
    };
  }

  protected func IsEquippedContext(context: ItemDisplayContext) -> Bool {
    return Equals(context, ItemDisplayContext.VendorPlayer) || Equals(context, ItemDisplayContext.Backpack) || Equals(context, ItemDisplayContext.GearPanel) || Equals(context, ItemDisplayContext.Ripperdoc) || Equals(context, ItemDisplayContext.Crafting);
  }

  protected func ShouldShowEquipped() -> Bool {
    if Equals(this.m_itemDisplayContext, ItemDisplayContext.Attachment) {
      return !InventoryItemData.IsEmpty(this.m_itemData);
    };
    return InventoryItemData.IsEquipped(this.m_itemData) && this.IsEquippedContext(this.m_itemDisplayContext);
  }

  protected func UpdateEquipped() -> Void {
    let showEquipped: Bool = this.ShouldShowEquipped();
    let i: Int32 = 0;
    while i < ArraySize(this.m_equippedWidgets) {
      inkWidgetRef.SetVisible(this.m_equippedWidgets[i], showEquipped);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_hideWhenEquippedWidgets) {
      inkWidgetRef.SetVisible(this.m_hideWhenEquippedWidgets[i], !showEquipped);
      i += 1;
    };
    inkWidgetRef.SetVisible(this.m_equippedMarker, showEquipped);
  }

  protected func UpdateQuantity() -> Void {
    let countTreshold: Int32;
    let quantityText: String;
    let displayQuantityText: Bool = false;
    let itemInventory: InventoryItemData = this.GetItemData();
    inkWidgetRef.SetVisible(this.m_quantintyAmmoIcon, false);
    countTreshold = Equals(this.m_itemDisplayContext, ItemDisplayContext.DPAD_RADIAL) ? 0 : 1;
    if !InventoryItemData.IsEmpty(itemInventory) {
      if InventoryItemData.GetQuantity(itemInventory) > countTreshold || Equals(InventoryItemData.GetItemType(itemInventory), gamedataItemType.Con_Ammo) {
        quantityText = InventoryItemData.GetQuantity(itemInventory) > 9999 ? "9999+" : IntToString(InventoryItemData.GetQuantity(itemInventory));
        inkTextRef.SetText(this.m_quantityText, quantityText);
        displayQuantityText = true;
      } else {
        if Equals(InventoryItemData.GetEquipmentArea(itemInventory), gamedataEquipmentArea.Weapon) {
          if InventoryItemData.GetGameItemData(itemInventory).HasTag(WeaponObject.GetMeleeWeaponTag()) {
            displayQuantityText = false;
          } else {
            quantityText = InventoryItemData.GetAmmo(itemInventory) > 999 ? "999+" : IntToString(InventoryItemData.GetAmmo(itemInventory));
            inkWidgetRef.SetVisible(this.m_quantintyAmmoIcon, true);
            inkTextRef.SetText(this.m_quantityText, quantityText);
            displayQuantityText = true;
          };
        };
      };
    };
    if Equals(this.m_itemDisplayContext, ItemDisplayContext.Crafting) && IsDefined(this.m_recipeData) && Equals(InventoryItemData.GetItemType(this.m_recipeData.inventoryItem), gamedataItemType.Con_Ammo) {
      quantityText = IntToString(CraftingSystem.GetAmmoBulletAmount(ItemID.GetTDBID(InventoryItemData.GetID(this.m_recipeData.inventoryItem))));
      inkTextRef.SetText(this.m_quantityText, quantityText);
      inkWidgetRef.SetVisible(this.m_quantintyAmmoIcon, true);
      displayQuantityText = true;
    };
    if Equals(this.m_itemDisplayContext, ItemDisplayContext.DPAD_RADIAL) {
      inkWidgetRef.SetVisible(this.m_quantityText, displayQuantityText);
    };
    inkWidgetRef.SetVisible(this.m_quantityWrapper, displayQuantityText);
  }

  protected func UpdateItemName() -> Void {
    let itemInventory: InventoryItemData;
    if IsDefined(inkWidgetRef.Get(this.m_itemName)) {
      if ItemID.IsValid(this.m_tooltipData.itemID) {
        inkTextRef.SetText(this.m_itemName, this.m_tooltipData.itemName);
      } else {
        itemInventory = this.GetItemData();
        inkTextRef.SetText(this.m_itemName, InventoryItemData.GetName(itemInventory));
      };
    };
  }

  protected func GetPriceText() -> String {
    let price: String;
    let stackPrice: String;
    let vendorPrice: String;
    let vendorStackPrice: String;
    let euroDolarText: String = GetLocalizedText("Common-Characters-EuroDollar");
    if !InventoryItemData.IsEmpty(this.m_itemData) {
      if InventoryItemData.IsVendorItem(this.m_itemData) {
        vendorPrice = RoundF(InventoryItemData.GetBuyPrice(this.m_itemData)) + " " + euroDolarText;
        if InventoryItemData.GetQuantity(this.m_itemData) > 1 {
          vendorStackPrice = RoundF(InventoryItemData.GetBuyPrice(this.m_itemData)) * InventoryItemData.GetQuantity(this.m_itemData) + " " + euroDolarText;
          return vendorStackPrice + " (" + vendorPrice + ")";
        };
        return vendorPrice;
      };
      price = RoundF(InventoryItemData.GetPrice(this.m_itemData)) + " " + euroDolarText;
      if InventoryItemData.GetQuantity(this.m_itemData) > 1 {
        stackPrice = RoundF(InventoryItemData.GetPrice(this.m_itemData)) * InventoryItemData.GetQuantity(this.m_itemData) + " " + euroDolarText;
        return stackPrice + " (" + price + ")";
      };
      return price;
    };
    return "";
  }

  protected func UpdatePrice() -> Void {
    if IsDefined(inkWidgetRef.Get(this.m_itemPrice)) {
      if Equals(this.m_itemDisplayContext, ItemDisplayContext.Vendor) {
        inkTextRef.SetText(this.m_itemPrice, this.GetPriceText());
      } else {
        inkTextRef.SetText(this.m_itemPrice, "");
      };
    };
  }

  protected func UpdateIcon() -> Void {
    let emptyIcon: CName;
    let iconName: String;
    let localData: ref<gameItemData>;
    let localItemRecord: ref<Item_Record>;
    let tweakId: TweakDBID;
    let iconsNameResolver: ref<IconsNameResolver> = IconsNameResolver.GetIconsNameResolver();
    let isCrafting: Bool = Equals(this.m_itemDisplayContext, ItemDisplayContext.Crafting) && IsDefined(this.m_recipeData);
    this.DEBUG_iconsNameResolverIsDebug = iconsNameResolver.IsInDebugMode();
    inkWidgetRef.SetVisible(this.m_itemFallbackImage, false);
    localData = InventoryItemData.GetGameItemData(this.m_itemData);
    if IsDefined(localData) && localData.HasTag(n"Recipe") {
      this.UpdateRecipeIcon();
      return;
    };
    this.DEBUG_innerItemName = "";
    this.DEBUG_recordItemName = "";
    if isCrafting {
      this.DEBUG_recordItemName = TDBID.ToStringDEBUG(this.m_recipeData.id.GetID());
    } else {
      localItemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(this.m_itemData)));
      if IsDefined(localItemRecord) {
        this.DEBUG_recordItemName = TDBID.ToStringDEBUG(localItemRecord.GetID());
      } else {
        this.DEBUG_recordItemName = "";
      };
    };
    if !IsStringValid(this.DEBUG_recordItemName) {
      this.DEBUG_recordItemName = "Cannot get valid record ID";
    };
    iconName = isCrafting ? this.m_recipeData.id.IconPath() : InventoryItemData.GetIconPath(this.m_itemData);
    if IsStringValid(iconName) {
      this.DEBUG_isIconManuallySet = true;
    } else {
      tweakId = isCrafting ? this.m_recipeData.id.GetID() : ItemID.GetTDBID(InventoryItemData.GetID(this.m_itemData));
      iconName = NameToString(iconsNameResolver.TranslateItemToIconName(tweakId, Equals(InventoryItemData.GetIconGender(this.m_itemData), ItemIconGender.Male)));
      this.DEBUG_isIconManuallySet = false;
    };
    if NotEquals(iconName, "None") && NotEquals(iconName, "") {
      this.DEBUG_resolvedIconName = iconName;
      inkWidgetRef.SetVisible(this.m_itemImage, false);
      inkWidgetRef.SetVisible(this.m_itemEmptyImage, false);
      if Equals(this.m_equipmentArea, gamedataEquipmentArea.Outfit) {
        inkWidgetRef.SetScale(this.m_itemImage, new Vector2(1.00, 1.00));
      } else {
        inkWidgetRef.SetScale(this.m_itemImage, Equals(InventoryItemData.GetEquipmentArea(this.m_itemData), gamedataEquipmentArea.Outfit) ? new Vector2(0.50, 0.50) : new Vector2(1.00, 1.00));
      };
      InkImageUtils.RequestSetImage(this, this.m_itemImage, "UIIcon." + iconName, n"OnIconCallback");
    } else {
      inkWidgetRef.SetVisible(this.m_itemImage, false);
      inkWidgetRef.SetVisible(this.m_itemEmptyImage, true);
      emptyIcon = UIItemsHelper.GetSlotShadowIcon(this.GetSlotID(), this.GetItemType(), this.GetEquipmentArea());
      InkImageUtils.RequestSetImage(this, this.m_itemEmptyImage, emptyIcon);
    };
  }

  protected func UpdateRecipeIcon() -> Void {
    let emptyIcon: CName;
    let iconName: String;
    let itemRecord: wref<Item_Record>;
    let itemScale: Vector2;
    let iconsNameResolver: ref<IconsNameResolver> = IconsNameResolver.GetIconsNameResolver();
    let recipeRecord: wref<ItemRecipe_Record> = TweakDBInterface.GetItemRecipeRecord(ItemID.GetTDBID(InventoryItemData.GetID(this.m_itemData)));
    let craftingResult: wref<CraftingResult_Record> = recipeRecord.CraftingResult();
    if IsDefined(craftingResult) {
      itemRecord = craftingResult.Item();
    };
    this.DEBUG_recordItemName = TDBID.ToStringDEBUG(ItemID.GetTDBID(InventoryItemData.GetID(this.m_itemData)));
    if !IsStringValid(this.DEBUG_recordItemName) {
      this.DEBUG_recordItemName = "Cannot get valid record ID";
    };
    this.DEBUG_innerItemName = TDBID.ToStringDEBUG(itemRecord.GetID());
    if !IsStringValid(this.DEBUG_innerItemName) {
      this.DEBUG_innerItemName = "Cannot get valid record ID";
    };
    if IsStringValid(itemRecord.IconPath()) {
      iconName = itemRecord.IconPath();
      this.DEBUG_isIconManuallySet = true;
    } else {
      iconName = NameToString(iconsNameResolver.TranslateItemToIconName(itemRecord.GetID(), Equals(InventoryItemData.GetIconGender(this.m_itemData), ItemIconGender.Male)));
      this.DEBUG_isIconManuallySet = false;
    };
    if NotEquals(iconName, "None") && NotEquals(iconName, "") {
      this.DEBUG_resolvedIconName = iconName;
      inkWidgetRef.SetVisible(this.m_itemImage, false);
      inkWidgetRef.SetVisible(this.m_itemEmptyImage, false);
      if Equals(itemRecord.EquipArea().Type(), gamedataEquipmentArea.Outfit) {
        itemScale = new Vector2(0.50, 0.50);
      } else {
        if Equals(itemRecord.EquipArea().Type(), gamedataEquipmentArea.Weapon) {
          itemScale = new Vector2(0.33, 0.33);
        } else {
          itemScale = new Vector2(1.00, 1.00);
        };
      };
      inkWidgetRef.SetScale(this.m_itemImage, itemScale);
      InkImageUtils.RequestSetImage(this, this.m_itemImage, "UIIcon." + iconName, n"OnIconCallback");
    } else {
      inkWidgetRef.SetVisible(this.m_itemImage, false);
      inkWidgetRef.SetVisible(this.m_itemEmptyImage, true);
      emptyIcon = UIItemsHelper.GetSlotShadowIcon(this.GetSlotID(), this.GetItemType(), this.GetEquipmentArea());
      InkImageUtils.RequestSetImage(this, this.m_itemEmptyImage, emptyIcon);
    };
  }

  protected cb func OnIconCallback(e: ref<iconAtlasCallbackData>) -> Bool {
    inkWidgetRef.SetVisible(this.m_itemImage, Equals(e.loadResult, inkIconResult.Success));
    if this.DEBUG_iconsNameResolverIsDebug {
      switch e.loadResult {
        case inkIconResult.Success:
          inkWidgetRef.SetVisible(this.m_iconErrorIndicator, false);
          this.DEBUG_iconErrorInfo = null;
          return false;
        case inkIconResult.AtlasResourceNotFound:
          inkWidgetRef.SetTintColor(this.m_iconErrorIndicator, new Color(255u, 0u, 0u, 255u));
          inkWidgetRef.SetVisible(this.m_iconErrorIndicator, true);
          break;
        case inkIconResult.UnknownIconTweak:
          inkWidgetRef.SetTintColor(this.m_iconErrorIndicator, new Color(0u, 255u, 0u, 255u));
          inkWidgetRef.SetVisible(this.m_iconErrorIndicator, true);
          break;
        case inkIconResult.PartNotFoundInAtlas:
          inkWidgetRef.SetTintColor(this.m_iconErrorIndicator, new Color(0u, 0u, 255u, 255u));
          inkWidgetRef.SetVisible(this.m_iconErrorIndicator, true);
      };
    } else {
      inkWidgetRef.SetVisible(this.m_iconErrorIndicator, false);
    };
    this.DEBUG_iconErrorInfo = new DEBUG_IconErrorInfo();
    this.DEBUG_iconErrorInfo.itemName = this.DEBUG_recordItemName;
    this.DEBUG_iconErrorInfo.innerItemName = this.DEBUG_innerItemName;
    this.DEBUG_iconErrorInfo.resolvedIconName = this.DEBUG_resolvedIconName;
    this.DEBUG_iconErrorInfo.errorMessage = e.errorMsg;
    this.DEBUG_iconErrorInfo.errorType = e.loadResult;
    this.DEBUG_iconErrorInfo.isManuallySet = this.DEBUG_isIconManuallySet;
  }

  protected func UpdateRarity() -> Void {
    let quality: CName;
    let visible: Bool;
    inkWidgetRef.SetVisible(this.m_rarityWrapper, true);
    if Equals(this.m_itemDisplayContext, ItemDisplayContext.Crafting) && IsDefined(this.m_recipeData) {
      quality = InventoryItemData.GetQuality(this.m_recipeData.inventoryItem);
    } else {
      if IsDefined(InventoryItemData.GetGameItemData(this.m_itemData)) && !InventoryItemData.IsPart(this.m_itemData) {
        quality = UIItemsHelper.QualityEnumToName(RPGManager.GetItemDataQuality(InventoryItemData.GetGameItemData(this.m_itemData)));
      } else {
        quality = InventoryItemData.GetQuality(this.m_itemData);
      };
    };
    visible = NotEquals(quality, n"");
    inkWidgetRef.SetVisible(this.m_itemRarity, visible);
    inkWidgetRef.SetVisible(this.m_rarityCommonWrapper, !visible);
    inkWidgetRef.SetState(this.m_itemRarity, quality);
    inkWidgetRef.SetVisible(this.m_iconicTint, RPGManager.IsItemIconic(InventoryItemData.GetGameItemData(this.m_itemData)));
  }

  public func SetComparisonState(comparisonState: ItemComparisonState) -> Void {
    inkWidgetRef.SetVisible(this.m_comparisionArrow, true);
    switch comparisonState {
      case ItemComparisonState.Better:
        inkWidgetRef.SetState(this.m_comparisionArrow, n"Better");
        inkWidgetRef.SetRotation(this.m_comparisionArrow, 0.00);
        break;
      case ItemComparisonState.Worse:
        inkWidgetRef.SetState(this.m_comparisionArrow, n"Worse");
        inkWidgetRef.SetRotation(this.m_comparisionArrow, 180.00);
        break;
      default:
        inkWidgetRef.SetState(this.m_comparisionArrow, n"Default");
    };
  }

  public func SetBuybackStack(value: Bool) -> Void {
    this.m_isBuybackStack = value;
    this.UpdateIndicators();
  }

  public func SetIsNew(value: Bool, opt parrentWrappedDataObject: wref<WrappedInventoryItemData>) -> Void {
    this.m_isNew = value;
    if IsDefined(parrentWrappedDataObject) {
      this.m_parrentWrappedDataObject = parrentWrappedDataObject;
    };
    this.m_parrentWrappedDataObject.IsNew = this.m_isNew;
    this.UpdateIsNewIndicator();
  }

  protected func GetShadowIconFromEquipmentArea(equipmentArea: gamedataEquipmentArea) -> CName {
    return this.m_emptyImage;
  }

  protected func GetShadowIconAtlas(equipmentArea: gamedataEquipmentArea) -> String {
    return this.m_emptyImageAtlas;
  }

  protected func GetMods(onlyGeneric: Bool) -> array<InventoryItemAttachments> {
    let attachments: InventoryItemAttachments;
    let result: array<InventoryItemAttachments>;
    let itemData: InventoryItemData = this.GetItemData();
    let attachmentsSize: Int32 = InventoryItemData.GetAttachmentsSize(itemData);
    let i: Int32 = 0;
    while i < attachmentsSize {
      attachments = InventoryItemData.GetAttachment(itemData, i);
      if onlyGeneric {
        if NotEquals(attachments.SlotType, InventoryItemAttachmentType.Generic) {
        } else {
          ArrayPush(result, attachments);
        };
      };
      ArrayPush(result, attachments);
      i += 1;
    };
    return result;
  }

  protected func UpdateMods() -> Void {
    let attachments: array<InventoryItemAttachments>;
    let i: Int32;
    let item: wref<InventoryItemModSlotDisplay>;
    let targetSize: Int32;
    if !IsDefined(inkWidgetRef.Get(this.m_commonModsRoot)) {
      return;
    };
    attachments = this.GetMods(true);
    targetSize = ArraySize(attachments);
    while ArraySize(this.m_attachmentsDisplay) > targetSize {
      inkCompoundRef.RemoveChild(this.m_commonModsRoot, ArrayPop(this.m_attachmentsDisplay).GetRootWidget());
    };
    i = 0;
    while i < targetSize {
      if ArraySize(this.m_attachmentsDisplay) <= i {
        item = this.SpawnFromLocal(inkWidgetRef.Get(this.m_commonModsRoot), n"itemModSlot").GetController() as InventoryItemModSlotDisplay;
        ArrayPush(this.m_attachmentsDisplay, item);
      };
      this.m_attachmentsDisplay[i].Setup(attachments[i].ItemData);
      i += 1;
    };
  }

  public func Unselect() -> Void;

  public func Select() -> Void;

  public final func GetItemDisplayData() -> InventoryItemDisplayData {
    let data: InventoryItemDisplayData;
    data.m_itemID = this.GetItemID();
    data.m_equipmentArea = this.GetEquipmentArea();
    data.m_slotIndex = this.GetSlotIndex();
    return data;
  }

  public final func GetItemData() -> InventoryItemData {
    return this.m_itemData;
  }

  public final func GetItemID() -> ItemID {
    return InventoryItemData.GetID(this.m_itemData);
  }

  public final func GetItemCategory() -> String {
    return InventoryItemData.GetCategoryName(this.m_itemData);
  }

  public final func GetItemType() -> gamedataItemType {
    return InventoryItemData.GetItemType(this.m_itemData);
  }

  public final func GetEquipmentArea() -> gamedataEquipmentArea {
    return this.m_equipmentArea;
  }

  public final func GetSlotName() -> String {
    if IsStringValid(this.m_slotName) {
      return this.m_slotName;
    };
    return UIItemsHelper.GetSlotName(this.GetSlotID(), this.GetItemType(), this.GetEquipmentArea());
  }

  public final func GetSlotIndex() -> Int32 {
    return this.m_slotIndex;
  }

  public final func SelectItem() -> Void;

  public final func UnselectItem() -> Void;

  public func SetHighlighted(value: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_highlightFrames) {
      inkWidgetRef.SetVisible(this.m_highlightFrames[i], value);
      i += 1;
    };
  }

  public func ShowSelectionArrow() -> Void {
    inkWidgetRef.SetVisible(this.m_itemSelectedArrow, true);
  }

  public func HideSelectionArrow() -> Void {
    inkWidgetRef.SetVisible(this.m_itemSelectedArrow, false);
  }

  public func GetSlotID() -> TweakDBID {
    if TDBID.IsValid(this.m_slotID) {
      return this.m_slotID;
    };
    return TDBID.undefined();
  }

  public func SetInteractive(value: Bool) -> Void {
    inkWidgetRef.SetInteractive(this.m_widgetWrapper, value);
  }

  public func GetDisplayType() -> ItemDisplayType {
    return ItemDisplayType.Item;
  }

  public func GetAttachmentsSize() -> Int32 {
    return InventoryItemData.GetAttachmentsSize(this.m_itemData);
  }

  public func GetParentItemData() -> wref<gameItemData> {
    return this.m_parentItemData;
  }

  public func GetNewItems() -> Int32 {
    return ArraySize(this.m_newItemsIDs);
  }

  public func IsEmpty() -> Bool {
    return InventoryItemData.IsEmpty(this.m_itemData);
  }
}
