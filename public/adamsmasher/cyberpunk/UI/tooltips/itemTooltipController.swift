
public class ItemTooltipCommonController extends AGenericTooltipController {

  private edit let m_backgroundContainer: inkWidgetRef;

  private edit let m_itemEquippedContainer: inkWidgetRef;

  private edit let m_itemHeaderContainer: inkWidgetRef;

  private edit let m_itemIconContainer: inkWidgetRef;

  private edit let m_itemWeaponInfoContainer: inkWidgetRef;

  private edit let m_itemClothingInfoContainer: inkWidgetRef;

  private edit let m_itemGrenadeInfoContainer: inkWidgetRef;

  private edit let m_itemRequirementsContainer: inkWidgetRef;

  private edit let m_itemDetailsContainer: inkWidgetRef;

  private edit let m_itemRecipeDataContainer: inkWidgetRef;

  private edit let m_itemEvolutionContainer: inkWidgetRef;

  private edit let m_itemCraftedContainer: inkWidgetRef;

  private edit let m_itemBottomContainer: inkWidgetRef;

  private edit let m_descriptionWrapper: inkWidgetRef;

  private edit let m_descriptionText: inkTextRef;

  private edit let DEBUG_iconErrorWrapper: inkWidgetRef;

  private edit let DEBUG_iconErrorText: inkTextRef;

  private let m_itemEquippedController: wref<ItemTooltipEquippedModule>;

  private let m_itemHeaderController: wref<ItemTooltipHeaderController>;

  private let m_itemIconController: wref<ItemTooltipIconModule>;

  private let m_itemWeaponInfoController: wref<ItemTooltipWeaponInfoModule>;

  private let m_itemClothingInfoController: wref<ItemTooltipClothingInfoModule>;

  private let m_itemGrenadeInfoController: wref<ItemTooltipGrenadeInfoModule>;

  private let m_itemRequirementsController: wref<ItemTooltipRequirementsModule>;

  private let m_itemDetailsController: wref<ItemTooltipDetailsModule>;

  private let m_itemRecipeDataController: wref<ItemTooltipRecipeDataModule>;

  private let m_itemEvolutionController: wref<ItemTooltipEvolutionModule>;

  private let m_itemCraftedController: wref<ItemTooltipCraftedModule>;

  private let m_itemBottomController: wref<ItemTooltipBottomModule>;

  private let DEBUG_showAdditionalInfo: Bool;

  private let m_data: ref<MinimalItemTooltipData>;

  private let m_requestedModules: array<CName>;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.RegisterToGlobalInputCallback(n"OnPostOnPress", this, n"OnGlobalPress");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnPress", this, n"OnGlobalPress");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnGlobalRelease");
  }

  protected cb func OnGlobalPress(evt: ref<inkPointerEvent>) -> Bool {
    this.DEBUG_showAdditionalInfo = evt.IsShiftDown();
    this.DEBUG_UpdateIconErrorInfo();
  }

  protected cb func OnGlobalRelease(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsShiftDown() {
      this.DEBUG_showAdditionalInfo = false;
    };
    this.DEBUG_UpdateIconErrorInfo();
  }

  public final func SetData(data: ItemViewData) -> Void {
    this.SetData(InventoryTooltipData.FromItemViewData(data));
  }

  public func SetData(tooltipData: ref<ATooltipData>) -> Void {
    if IsDefined(tooltipData as InventoryTooltipData) {
      this.UpdateData(tooltipData as InventoryTooltipData);
    } else {
      this.m_data = tooltipData as MinimalItemTooltipData;
      this.UpdateLayout();
    };
    this.DEBUG_UpdateIconErrorInfo();
  }

  public final func UpdateData(tooltipData: ref<InventoryTooltipData>) -> Void {
    this.m_data = MinimalItemTooltipData.FromInventoryTooltipData(tooltipData);
    this.UpdateLayout();
  }

  private final func RequestModule(container: inkWidgetRef, moduleName: CName, callback: CName, opt data: ref<ItemTooltipModuleSpawnedCallbackData>) -> Bool {
    if ArrayContains(this.m_requestedModules, moduleName) {
      return false;
    };
    ArrayPush(this.m_requestedModules, moduleName);
    this.AsyncSpawnFromLocal(inkWidgetRef.Get(container), moduleName, this, callback, data);
    return true;
  }

  private final func HandleModuleSpawned(widget: wref<inkWidget>, data: ref<ItemTooltipModuleSpawnedCallbackData>) -> Void {
    ArrayRemove(this.m_requestedModules, data.moduleName);
    widget.SetVAlign(inkEVerticalAlign.Top);
  }

  private final func UpdateLayout() -> Void {
    this.UpdateEquippedModule();
    this.UpdateHeaderModule();
    this.UpdateIconModule();
    this.UpdateWeaponInfoModule();
    this.UpdateClothingInfoModule();
    this.UpdateGrenadeInfoModule();
    this.UpdateRequirementsModule();
    this.UpdateDetailsModule();
    this.UpdateRecipeDataModule();
    this.UpdateEvolutionModule();
    this.UpdateCraftedModule();
    this.UpdateBottomModule();
    if IsNameValid(this.m_data.description) && this.m_data.itemTweakID != t"Items.money" {
      inkWidgetRef.SetVisible(this.m_descriptionWrapper, true);
      inkTextRef.SetText(this.m_descriptionText, GetLocalizedText(NameToString(this.m_data.description)));
    } else {
      inkWidgetRef.SetVisible(this.m_descriptionWrapper, false);
    };
    inkWidgetRef.SetVisible(this.m_backgroundContainer, NotEquals(this.m_data.displayContext, InventoryTooltipDisplayContext.Crafting));
  }

  private final func UpdateEquippedModule() -> Void {
    if this.m_data.isEquipped && NotEquals(this.m_data.displayContext, InventoryTooltipDisplayContext.Crafting) && NotEquals(this.m_data.displayContext, InventoryTooltipDisplayContext.Upgrading) {
      if !IsDefined(this.m_itemEquippedController) {
        this.RequestModule(this.m_itemEquippedContainer, n"itemEquipped", n"OnEquippedModuleSpawned");
        return;
      };
      inkWidgetRef.SetVisible(this.m_itemEquippedContainer, true);
      this.m_itemEquippedController.Update(this.m_data);
    } else {
      inkWidgetRef.SetVisible(this.m_itemEquippedContainer, false);
    };
  }

  protected cb func OnEquippedModuleSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_itemEquippedController = widget.GetController() as ItemTooltipEquippedModule;
    this.HandleModuleSpawned(widget, userData as ItemTooltipModuleSpawnedCallbackData);
    this.UpdateEquippedModule();
  }

  private final func UpdateHeaderModule() -> Void {
    if !IsDefined(this.m_itemHeaderController) {
      this.RequestModule(this.m_itemHeaderContainer, n"itemHeader", n"OnHeaderModuleSpawned");
      return;
    };
    this.m_itemHeaderController.Update(this.m_data);
  }

  protected cb func OnHeaderModuleSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_itemHeaderController = widget.GetController() as ItemTooltipHeaderController;
    this.HandleModuleSpawned(widget, userData as ItemTooltipModuleSpawnedCallbackData);
    this.UpdateHeaderModule();
  }

  private final func UpdateIconModule() -> Void {
    let isCrafting: Bool = Equals(this.m_data.displayContext, InventoryTooltipDisplayContext.Crafting) || Equals(this.m_data.displayContext, InventoryTooltipDisplayContext.Upgrading);
    let isShard: Bool = Equals(this.m_data.itemType, gamedataItemType.Gen_Readable);
    if !isCrafting && !isShard {
      if !IsDefined(this.m_itemIconController) {
        this.RequestModule(this.m_itemIconContainer, n"itemIcon", n"OnIconModuleSpawned");
        return;
      };
      inkWidgetRef.SetVisible(this.m_itemIconContainer, true);
      this.m_itemIconController.Update(this.m_data);
    } else {
      inkWidgetRef.SetVisible(this.m_itemIconContainer, false);
    };
  }

  protected cb func OnIconModuleSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_itemIconController = widget.GetController() as ItemTooltipIconModule;
    this.HandleModuleSpawned(widget, userData as ItemTooltipModuleSpawnedCallbackData);
    this.UpdateIconModule();
  }

  protected cb func OnHideIconModuleEvent(evt: ref<HideIconModuleEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_itemIconContainer, false);
  }

  private final func UpdateWeaponInfoModule() -> Void {
    if Equals(this.m_data.equipmentArea, gamedataEquipmentArea.Weapon) || Equals(this.m_data.equipmentArea, gamedataEquipmentArea.WeaponHeavy) {
      if !IsDefined(this.m_itemWeaponInfoController) {
        this.RequestModule(this.m_itemWeaponInfoContainer, n"itemWeaponInfo", n"OnWeaponInfoModuleSpawned");
        return;
      };
      inkWidgetRef.SetVisible(this.m_itemWeaponInfoContainer, true);
      this.m_itemWeaponInfoController.Update(this.m_data);
    } else {
      inkWidgetRef.SetVisible(this.m_itemWeaponInfoContainer, false);
    };
  }

  protected cb func OnWeaponInfoModuleSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_itemWeaponInfoController = widget.GetController() as ItemTooltipWeaponInfoModule;
    this.HandleModuleSpawned(widget, userData as ItemTooltipModuleSpawnedCallbackData);
    this.UpdateWeaponInfoModule();
  }

  private final func UpdateClothingInfoModule() -> Void {
    if Equals(this.m_data.itemCategory, gamedataItemCategory.Clothing) && this.m_data.armorValue > 0.00 {
      if !IsDefined(this.m_itemClothingInfoController) {
        this.RequestModule(this.m_itemClothingInfoContainer, n"itemClothingInfo", n"OnClothingInfoModuleSpawned");
        return;
      };
      inkWidgetRef.SetVisible(this.m_itemClothingInfoContainer, true);
      this.m_itemClothingInfoController.Update(this.m_data);
    } else {
      inkWidgetRef.SetVisible(this.m_itemClothingInfoContainer, false);
    };
  }

  protected cb func OnClothingInfoModuleSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_itemClothingInfoController = widget.GetController() as ItemTooltipClothingInfoModule;
    this.HandleModuleSpawned(widget, userData as ItemTooltipModuleSpawnedCallbackData);
    this.UpdateClothingInfoModule();
  }

  private final func UpdateGrenadeInfoModule() -> Void {
    if Equals(this.m_data.itemType, gamedataItemType.Gad_Grenade) {
      if !IsDefined(this.m_itemGrenadeInfoController) {
        this.RequestModule(this.m_itemGrenadeInfoContainer, n"itemGrenadeInfo", n"OnGrenadeInfoModuleSpawned");
        return;
      };
      inkWidgetRef.SetVisible(this.m_itemGrenadeInfoContainer, true);
      this.m_itemGrenadeInfoController.Update(this.m_data);
    } else {
      inkWidgetRef.SetVisible(this.m_itemGrenadeInfoContainer, false);
    };
  }

  protected cb func OnGrenadeInfoModuleSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_itemGrenadeInfoController = widget.GetController() as ItemTooltipGrenadeInfoModule;
    this.HandleModuleSpawned(widget, userData as ItemTooltipModuleSpawnedCallbackData);
    this.UpdateGrenadeInfoModule();
  }

  private final func UpdateRequirementsModule() -> Void {
    let anyRequirementNotMet: Bool = this.m_data.requirements.isLevelRequirementNotMet || this.m_data.requirements.isSmartlinkRequirementNotMet || this.m_data.requirements.isStrengthRequirementNotMet || this.m_data.requirements.isReflexRequirementNotMet || this.m_data.requirements.isAnyStatRequirementNotMet;
    if anyRequirementNotMet {
      if !IsDefined(this.m_itemRequirementsController) {
        this.RequestModule(this.m_itemRequirementsContainer, n"itemRequirements", n"OnRequirementsModuleSpawned");
        return;
      };
      inkWidgetRef.SetVisible(this.m_itemRequirementsContainer, true);
      this.m_itemRequirementsController.Update(this.m_data);
    } else {
      inkWidgetRef.SetVisible(this.m_itemRequirementsContainer, false);
    };
  }

  protected cb func OnRequirementsModuleSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_itemRequirementsController = widget.GetController() as ItemTooltipRequirementsModule;
    this.HandleModuleSpawned(widget, userData as ItemTooltipModuleSpawnedCallbackData);
    this.UpdateRequirementsModule();
  }

  private final func UpdateDetailsModule() -> Void {
    let hasStats: Bool = ArraySize(this.m_data.stats) > 0;
    let hasDedicatedMods: Bool = ArraySize(this.m_data.dedicatedMods) > 0;
    let hasMods: Bool = ArraySize(this.m_data.mods) > 0;
    let isWeaponOnHud: Bool = Equals(this.m_data.displayContext, InventoryTooltipDisplayContext.HUD) && Equals(this.m_data.equipmentArea, gamedataEquipmentArea.Weapon);
    let isWeaponInCrafting: Bool = Equals(this.m_data.displayContext, InventoryTooltipDisplayContext.Crafting) && Equals(this.m_data.equipmentArea, gamedataEquipmentArea.Weapon);
    let showInCrafting: Bool = isWeaponInCrafting && (hasDedicatedMods || hasMods);
    let showOutsideCraftingAndHud: Bool = !isWeaponInCrafting && !isWeaponOnHud && (hasStats || hasDedicatedMods || hasMods);
    let showInHud: Bool = isWeaponOnHud && (hasDedicatedMods || hasMods);
    if showOutsideCraftingAndHud || showInCrafting || showInHud {
      if !IsDefined(this.m_itemDetailsController) {
        this.RequestModule(this.m_itemDetailsContainer, n"itemDetails", n"OnDetailsModuleSpawned");
        return;
      };
      inkWidgetRef.SetVisible(this.m_itemDetailsContainer, true);
      this.m_itemDetailsController.Update(this.m_data, hasStats, hasDedicatedMods, hasMods);
    } else {
      inkWidgetRef.SetVisible(this.m_itemDetailsContainer, false);
    };
  }

  protected cb func OnDetailsModuleSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_itemDetailsController = widget.GetController() as ItemTooltipDetailsModule;
    this.HandleModuleSpawned(widget, userData as ItemTooltipModuleSpawnedCallbackData);
    this.UpdateDetailsModule();
  }

  private final func UpdateRecipeDataModule() -> Void {
    if this.m_data.recipeData != null {
      if !IsDefined(this.m_itemRecipeDataController) {
        this.RequestModule(this.m_itemRecipeDataContainer, n"itemRecipeData", n"OnRecipeDataModuleSpawned");
        return;
      };
      inkWidgetRef.SetVisible(this.m_itemRecipeDataContainer, true);
      this.m_itemRecipeDataController.Update(this.m_data);
    } else {
      inkWidgetRef.SetVisible(this.m_itemRecipeDataContainer, false);
    };
  }

  protected cb func OnRecipeDataModuleSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_itemRecipeDataController = widget.GetController() as ItemTooltipRecipeDataModule;
    this.HandleModuleSpawned(widget, userData as ItemTooltipModuleSpawnedCallbackData);
    this.UpdateRecipeDataModule();
  }

  private final func UpdateEvolutionModule() -> Void {
    if NotEquals(this.m_data.itemEvolution, gamedataWeaponEvolution.Invalid) {
      if !IsDefined(this.m_itemEvolutionController) {
        this.RequestModule(this.m_itemEvolutionContainer, n"itemEvolution", n"OnEvolutionModuleSpawned");
        return;
      };
      inkWidgetRef.SetVisible(this.m_itemEvolutionContainer, true);
      this.m_itemEvolutionController.Update(this.m_data);
    } else {
      inkWidgetRef.SetVisible(this.m_itemEvolutionContainer, false);
    };
  }

  protected cb func OnEvolutionModuleSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_itemEvolutionController = widget.GetController() as ItemTooltipEvolutionModule;
    this.HandleModuleSpawned(widget, userData as ItemTooltipModuleSpawnedCallbackData);
    this.UpdateEvolutionModule();
  }

  private final func UpdateCraftedModule() -> Void {
    if NotEquals(this.m_data.displayContext, InventoryTooltipDisplayContext.Crafting) && this.m_data.isCrafted {
      if !IsDefined(this.m_itemCraftedController) {
        this.RequestModule(this.m_itemCraftedContainer, n"itemCrafted", n"OnCraftedModuleSpawned");
        return;
      };
      inkWidgetRef.SetVisible(this.m_itemCraftedContainer, true);
      this.m_itemCraftedController.Update(this.m_data);
    } else {
      inkWidgetRef.SetVisible(this.m_itemCraftedContainer, false);
    };
  }

  protected cb func OnCraftedModuleSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_itemCraftedController = widget.GetController() as ItemTooltipCraftedModule;
    this.HandleModuleSpawned(widget, userData as ItemTooltipModuleSpawnedCallbackData);
    this.UpdateCraftedModule();
  }

  private final func UpdateBottomModule() -> Void {
    if !IsDefined(this.m_itemBottomController) {
      this.RequestModule(this.m_itemBottomContainer, n"itemBottom", n"OnBottomModuleSpawned");
      return;
    };
    inkWidgetRef.SetVisible(this.m_itemBottomContainer, true);
    this.m_itemBottomController.Update(this.m_data);
  }

  protected cb func OnBottomModuleSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_itemBottomController = widget.GetController() as ItemTooltipBottomModule;
    this.HandleModuleSpawned(widget, userData as ItemTooltipModuleSpawnedCallbackData);
    this.UpdateBottomModule();
  }

  private final func DEBUG_UpdateIconErrorInfo() -> Void {
    let craftableItems: array<wref<Item_Record>>;
    let errorData: ref<DEBUG_IconErrorInfo>;
    let recipeRecord: ref<RecipeItem_Record>;
    let resultText: String;
    let iconsNameResolver: ref<IconsNameResolver> = IconsNameResolver.GetIconsNameResolver();
    if !iconsNameResolver.IsInDebugMode() {
      inkWidgetRef.SetVisible(this.DEBUG_iconErrorWrapper, false);
      return;
    };
    errorData = this.m_data.DEBUG_iconErrorInfo;
    inkWidgetRef.SetVisible(this.DEBUG_iconErrorWrapper, errorData != null || this.DEBUG_showAdditionalInfo);
    if this.DEBUG_showAdditionalInfo {
      resultText += " - itemID:\\n";
      resultText += TDBID.ToStringDEBUG(this.m_data.itemTweakID);
      if this.m_data.itemData.HasTag(n"Recipe") {
        recipeRecord = TweakDBInterface.GetRecipeItemRecord(this.m_data.itemTweakID);
        if IsDefined(recipeRecord) {
          recipeRecord.CraftableItems(craftableItems);
          if ArraySize(craftableItems) > 0 {
            resultText += "\\n - inner itemID:\\n";
            resultText += TDBID.ToStringDEBUG(craftableItems[0].GetID());
          };
        };
      };
      inkTextRef.SetText(this.DEBUG_iconErrorText, resultText);
    } else {
      if errorData != null {
        resultText += "   ErrorType: " + EnumValueToString("inkIconResult", Cast(EnumInt(errorData.errorType))) + "\\n\\n";
        resultText += " - itemID:\\n";
        resultText += errorData.itemName;
        if IsStringValid(errorData.innerItemName) {
          resultText += "\\n - inner itemID:\\n";
          resultText += errorData.innerItemName;
        };
        if errorData.isManuallySet {
          resultText += "\\n - resolved icon name (manually set):\\n";
        } else {
          resultText += "\\n - resolved icon name (auto generated):\\n";
        };
        resultText += errorData.resolvedIconName;
        resultText += "\\n - error message:\\n";
        resultText += errorData.errorMessage;
        inkTextRef.SetText(this.DEBUG_iconErrorText, resultText);
      };
    };
  }
}

public class ItemTooltipModuleController extends inkLogicController {

  protected edit let m_lineWidget: inkWidgetRef;

  public func Update(data: ref<MinimalItemTooltipData>) -> Void;

  protected final func UseCraftingLayout(data: ref<MinimalItemTooltipData>) -> Bool {
    return Equals(data.displayContext, InventoryTooltipDisplayContext.Crafting) || Equals(data.displayContext, InventoryTooltipDisplayContext.Upgrading);
  }

  protected final func GetArrowWrapperState(diffValue: Float) -> CName {
    if diffValue < 0.00 {
      return n"Worse";
    };
    if diffValue > 0.00 {
      return n"Better";
    };
    return n"Default";
  }
}

public class ItemTooltipHeaderController extends ItemTooltipModuleController {

  private edit let m_itemNameText: inkTextRef;

  private edit let m_itemRarityText: inkTextRef;

  private edit let m_itemTypeText: inkTextRef;

  public func Update(data: ref<MinimalItemTooltipData>) -> Void {
    inkTextRef.SetText(this.m_itemTypeText, UIItemsHelper.GetItemTypeKey(data.itemData, data.equipmentArea, data.itemTweakID, data.itemType, data.itemEvolution));
    if this.UseCraftingLayout(data) {
      inkWidgetRef.SetVisible(this.m_itemNameText, false);
      inkWidgetRef.SetVisible(this.m_itemRarityText, false);
    } else {
      this.UpdateName(data);
      this.UpdateRarity(data);
    };
  }

  private final func UpdateName(data: ref<MinimalItemTooltipData>) -> Void {
    let finalItemName: String;
    inkWidgetRef.SetVisible(this.m_itemNameText, true);
    finalItemName = UIItemsHelper.GetTooltipItemName(data.itemTweakID, data.itemData, data.itemName);
    if data.quantity > 1 {
      finalItemName += " [" + IntToString(data.quantity) + "]";
    };
    inkTextRef.SetText(this.m_itemNameText, finalItemName);
  }

  private final func UpdateRarity(data: ref<MinimalItemTooltipData>) -> Void {
    let iconicLabel: String;
    let qualityName: CName;
    let rarityLabel: String;
    inkWidgetRef.SetVisible(this.m_itemRarityText, true);
    qualityName = UIItemsHelper.QualityEnumToName(data.quality);
    rarityLabel = GetLocalizedText(UIItemsHelper.QualityToLocalizationKey(data.quality));
    iconicLabel = GetLocalizedText(UIItemsHelper.QualityToLocalizationKey(gamedataQuality.Iconic));
    inkWidgetRef.SetState(this.m_itemNameText, qualityName);
    inkWidgetRef.SetState(this.m_itemRarityText, qualityName);
    inkTextRef.SetText(this.m_itemRarityText, data.isIconic ? rarityLabel + " / " + iconicLabel : rarityLabel);
  }
}

public class ItemTooltipIconModule extends ItemTooltipModuleController {

  private edit let m_container: inkImageRef;

  private edit let m_icon: inkImageRef;

  private edit let m_iconicLines: inkImageRef;

  private let iconsNameResolver: ref<IconsNameResolver>;

  protected cb func OnInitialize() -> Bool {
    this.iconsNameResolver = IconsNameResolver.GetIconsNameResolver();
  }

  public func Update(data: ref<MinimalItemTooltipData>) -> Void {
    let craftingResult: wref<CraftingResult_Record>;
    let itemRecord: wref<Item_Record>;
    let recipeRecord: wref<ItemRecipe_Record>;
    inkWidgetRef.SetVisible(this.m_iconicLines, data.isIconic);
    if IsDefined(data.itemData) && data.itemData.HasTag(n"Recipe") {
      recipeRecord = TweakDBInterface.GetItemRecipeRecord(data.itemTweakID);
      craftingResult = recipeRecord.CraftingResult();
      if IsDefined(craftingResult) {
        itemRecord = craftingResult.Item();
      };
    };
    inkWidgetRef.SetScale(this.m_icon, this.GetIconScale(data, itemRecord.EquipArea().Type()));
    inkWidgetRef.SetOpacity(this.m_icon, 0.00);
    InkImageUtils.RequestSetImage(this, this.m_icon, this.GetIconPath(data, itemRecord), n"OnIconCallback");
  }

  protected cb func OnIconCallback(e: ref<iconAtlasCallbackData>) -> Bool {
    if Equals(e.loadResult, inkIconResult.Success) {
      inkWidgetRef.SetOpacity(this.m_icon, 1.00);
    } else {
      this.QueueEvent(new HideIconModuleEvent());
    };
  }

  private final func GetIconPath(data: ref<MinimalItemTooltipData>, opt itemRecord: wref<Item_Record>) -> CName {
    let craftingIconName: String;
    let resolvedIcon: CName;
    if IsDefined(itemRecord) {
      craftingIconName = itemRecord.IconPath();
      if IsStringValid(craftingIconName) {
        return StringToName("UIIcon." + craftingIconName);
      };
      resolvedIcon = this.iconsNameResolver.TranslateItemToIconName(itemRecord.GetID(), data.useMaleIcon);
    } else {
      if IsStringValid(data.iconPath) {
        return StringToName("UIIcon." + data.iconPath);
      };
      resolvedIcon = this.iconsNameResolver.TranslateItemToIconName(data.itemTweakID, data.useMaleIcon);
    };
    if IsNameValid(resolvedIcon) {
      return StringToName("UIIcon." + NameToString(resolvedIcon));
    };
    return UIItemsHelper.GetSlotShadowIcon(TDBID.undefined(), data.itemType, data.equipmentArea);
  }

  private final func GetIconScale(data: ref<MinimalItemTooltipData>, equipmentArea: gamedataEquipmentArea) -> Vector2 {
    let areaToCheck: gamedataEquipmentArea = Equals(equipmentArea, gamedataEquipmentArea.AbilityCW) ? data.equipmentArea : equipmentArea;
    return Equals(areaToCheck, gamedataEquipmentArea.Outfit) ? new Vector2(0.50, 0.50) : new Vector2(1.00, 1.00);
  }
}

public class ItemTooltipWeaponInfoModule extends ItemTooltipModuleController {

  private edit let m_wrapper: inkWidgetRef;

  private edit let m_arrow: inkImageRef;

  private edit let m_dpsText: inkTextRef;

  private edit let m_perHitText: inkTextRef;

  private edit let m_attacksPerSecondText: inkTextRef;

  private edit let m_nonLethal: inkTextRef;

  private edit let m_scopeIndicator: inkWidgetRef;

  private edit let m_silencerIndicator: inkWidgetRef;

  private edit let m_ammoText: inkTextRef;

  private edit let m_ammoWrapper: inkWidgetRef;

  public func Update(data: ref<MinimalItemTooltipData>) -> Void {
    let attacksPerSecond: Float;
    let damagePerHit: Float;
    let damagePerHitMax: Float;
    let damagePerHitMin: Float;
    let divideAttacksByPellets: Bool;
    let projectilesPerShot: Float;
    let dpsParams: ref<inkTextParams> = new inkTextParams();
    let attackPerSecondParams: ref<inkTextParams> = new inkTextParams();
    let damageParams: ref<inkTextParams> = new inkTextParams();
    inkWidgetRef.SetState(this.m_wrapper, this.GetArrowWrapperState(data.dpsDiff));
    inkWidgetRef.SetVisible(this.m_wrapper, data.dpsValue >= 0.00);
    inkWidgetRef.SetVisible(this.m_arrow, data.dpsDiff != 0.00);
    inkWidgetRef.SetVisible(this.m_nonLethal, Equals(data.itemEvolution, gamedataWeaponEvolution.Blunt));
    if !data.itemData.HasTag(WeaponObject.GetMeleeWeaponTag()) {
      inkWidgetRef.SetVisible(this.m_ammoWrapper, true);
      inkTextRef.SetText(this.m_ammoText, IntToString(data.ammoCount));
    } else {
      inkWidgetRef.SetVisible(this.m_ammoWrapper, false);
    };
    if data.hasScope {
      inkWidgetRef.SetVisible(this.m_scopeIndicator, true);
      inkWidgetRef.SetState(this.m_scopeIndicator, data.isScopeInstalled ? n"Default" : n"Empty");
    } else {
      inkWidgetRef.SetVisible(this.m_scopeIndicator, false);
    };
    if data.hasSilencer {
      inkWidgetRef.SetVisible(this.m_silencerIndicator, true);
      inkWidgetRef.SetState(this.m_silencerIndicator, data.isSilencerInstalled ? n"Default" : n"Empty");
    } else {
      inkWidgetRef.SetVisible(this.m_silencerIndicator, false);
    };
    if data.dpsDiff > 0.00 {
      inkImageRef.SetBrushMirrorType(this.m_arrow, inkBrushMirrorType.NoMirror);
    } else {
      if data.dpsDiff < 0.00 {
        inkImageRef.SetBrushMirrorType(this.m_arrow, inkBrushMirrorType.Vertical);
      };
    };
    dpsParams.AddNumber("value", FloorF(data.dpsValue));
    dpsParams.AddNumber("valueDecimalPart", RoundF((data.dpsValue - Cast(RoundF(data.dpsValue))) * 10.00) % 10);
    if Equals(data.displayContext, InventoryTooltipDisplayContext.Upgrading) {
      projectilesPerShot = data.projectilesPerShot;
      attacksPerSecond = data.attackSpeed;
    } else {
      projectilesPerShot = data.itemData.GetStatValueByType(gamedataStatType.ProjectilesPerShot);
      attacksPerSecond = data.itemData.GetStatValueByType(gamedataStatType.AttacksPerSecond);
    };
    divideAttacksByPellets = TweakDBInterface.GetBool(data.itemTweakID + t".divideAttacksByPelletsOnUI", false) && projectilesPerShot > 0.00;
    attackPerSecondParams.AddString("value", FloatToStringPrec(divideAttacksByPellets ? attacksPerSecond / projectilesPerShot : attacksPerSecond, 2));
    inkTextRef.SetLocalizedTextScript(this.m_attacksPerSecondText, "UI-Tooltips-AttacksPerSecond", attackPerSecondParams);
    inkTextRef.SetTextParameters(this.m_dpsText, dpsParams);
    if data.itemData.HasTag(n"Melee") {
      damagePerHit = data.itemData.GetStatValueByType(gamedataStatType.EffectiveDamagePerHit);
      inkTextRef.SetText(this.m_perHitText, "UI-Tooltips-DamagePerHitMeleeTemplate");
      damageParams.AddString("value", IntToString(RoundF(damagePerHit)));
      inkTextRef.SetTextParameters(this.m_perHitText, damageParams);
    } else {
      if Equals(data.displayContext, InventoryTooltipDisplayContext.Upgrading) {
        damagePerHitMin = data.dpsValue / data.attackSpeed * 0.90;
        damagePerHitMax = data.dpsValue / data.attackSpeed * 1.10;
      } else {
        damagePerHitMin = data.itemData.GetStatValueByType(gamedataStatType.EffectiveDamagePerHitMin);
        damagePerHitMax = data.itemData.GetStatValueByType(gamedataStatType.EffectiveDamagePerHitMax);
      };
      damageParams.AddString("value", IntToString(RoundF(damagePerHitMin)));
      damageParams.AddString("valueMax", IntToString(RoundF(damagePerHitMax)));
      if (Equals(data.itemType, gamedataItemType.Wea_Shotgun) || Equals(data.itemType, gamedataItemType.Wea_ShotgunDual)) && projectilesPerShot > 0.00 {
        inkTextRef.SetText(this.m_perHitText, "UI-Tooltips-DamagePerHitWithMultiplierTemplate");
        damageParams.AddString("multiplier", IntToString(RoundF(projectilesPerShot)));
      } else {
        inkTextRef.SetText(this.m_perHitText, "UI-Tooltips-DamagePerHitTemplate");
      };
      inkTextRef.SetTextParameters(this.m_perHitText, damageParams);
    };
  }
}

public class ItemTooltipClothingInfoModule extends ItemTooltipModuleController {

  private edit let m_value: inkTextRef;

  private edit let m_arrow: inkImageRef;

  public func Update(data: ref<MinimalItemTooltipData>) -> Void {
    let armorParams: ref<inkTextParams> = new inkTextParams();
    if data.armorDiff > 0.00 {
      inkImageRef.SetBrushMirrorType(this.m_arrow, inkBrushMirrorType.NoMirror);
    } else {
      if data.armorDiff < 0.00 {
        inkImageRef.SetBrushMirrorType(this.m_arrow, inkBrushMirrorType.Vertical);
      };
    };
    inkWidgetRef.SetState(this.m_arrow, this.GetArrowWrapperState(data.armorDiff));
    inkWidgetRef.SetVisible(this.m_arrow, data.armorDiff != 0.00);
    armorParams.AddNumber("value", FloorF(data.armorValue));
    armorParams.AddNumber("valueDecimalPart", RoundF((data.armorValue - Cast(RoundF(data.armorValue))) * 10.00) % 10);
    inkTextRef.SetTextParameters(this.m_value, armorParams);
  }
}

public class ItemTooltipGrenadeInfoModule extends ItemTooltipModuleController {

  private edit let m_headerText: inkTextRef;

  private edit let m_totalDamageText: inkTextRef;

  private edit let m_durationText: inkTextRef;

  private edit let m_rangeText: inkTextRef;

  private edit let m_deliveryIcon: inkImageRef;

  private edit let m_deliveryText: inkTextRef;

  public func Update(data: ref<MinimalItemTooltipData>) -> Void {
    let damageParams: ref<inkTextParams>;
    let dpsParams: ref<inkTextParams>;
    let dpsValue: Float;
    let durationParams: ref<inkTextParams>;
    let hasDamage: Bool;
    let measurementUnit: EMeasurementUnit;
    let rangeParams: ref<inkTextParams>;
    let localizedSeconds: String = GetLocalizedText("UI-Quickhacks-Seconds");
    if Equals(data.grenadeData.type, GrenadeDamageType.DoT) {
      dpsParams = new inkTextParams();
      damageParams = new inkTextParams();
      durationParams = new inkTextParams();
      inkWidgetRef.SetVisible(this.m_headerText, true);
      inkWidgetRef.SetVisible(this.m_totalDamageText, true);
      inkWidgetRef.SetVisible(this.m_durationText, true);
      dpsValue = data.grenadeData.damagePerTick * 1.00 / data.grenadeData.delay;
      dpsParams.AddNumber("value", FloorF(dpsValue));
      dpsParams.AddNumber("valueDecimalPart", RoundF((dpsValue - Cast(RoundF(dpsValue))) * 10.00) % 10);
      damageParams.AddNumber("value", FloorF(data.grenadeData.totalDamage));
      durationParams.AddString("value", FloatToStringPrec(data.grenadeData.duration, 2));
      durationParams.AddString("unit", localizedSeconds);
      inkTextRef.SetText(this.m_headerText, GetLocalizedText("LocKey#77445"));
      inkTextRef.SetTextParameters(this.m_headerText, dpsParams);
      inkTextRef.SetTextParameters(this.m_durationText, durationParams);
      inkTextRef.SetTextParameters(this.m_totalDamageText, damageParams);
    } else {
      if Equals(data.grenadeData.type, GrenadeDamageType.Normal) {
        hasDamage = data.grenadeData.totalDamage > 0.00;
        inkWidgetRef.SetVisible(this.m_headerText, hasDamage);
        inkWidgetRef.SetVisible(this.m_totalDamageText, false);
        inkWidgetRef.SetVisible(this.m_durationText, false);
        if hasDamage {
          damageParams = new inkTextParams();
          damageParams.AddNumber("value", FloorF(data.grenadeData.totalDamage));
          inkTextRef.SetText(this.m_headerText, GetLocalizedText("LocKey#78473"));
          inkTextRef.SetTextParameters(this.m_headerText, damageParams);
        };
      };
    };
    rangeParams = new inkTextParams();
    measurementUnit = UILocalizationHelper.GetSystemBaseUnit();
    rangeParams.AddNumber("value", FloorF(MeasurementUtils.ValueUnitToUnit(data.grenadeData.range, EMeasurementUnit.Meter, measurementUnit)));
    rangeParams.AddString("unit", GetLocalizedText(NameToString(MeasurementUtils.GetUnitLocalizationKey(measurementUnit))));
    inkTextRef.SetTextParameters(this.m_rangeText, rangeParams);
    this.UpdateGrenadeDeliveryMethod(data.grenadeData.deliveryMethod);
  }

  private final func UpdateGrenadeDeliveryMethod(deliveryMethod: gamedataGrenadeDeliveryMethodType) -> Void {
    switch deliveryMethod {
      case gamedataGrenadeDeliveryMethodType.Regular:
        inkTextRef.SetText(this.m_deliveryText, GetLocalizedText("Gameplay-Items-Stats-Delivery-Regular"));
        break;
      case gamedataGrenadeDeliveryMethodType.Sticky:
        inkTextRef.SetText(this.m_deliveryText, GetLocalizedText("Gameplay-Items-Stats-Delivery-Sticky"));
        break;
      case gamedataGrenadeDeliveryMethodType.Homing:
        inkTextRef.SetText(this.m_deliveryText, GetLocalizedText("Gameplay-Items-Stats-Delivery-Homing"));
    };
  }
}

public class ItemTooltipRequirementsModule extends ItemTooltipModuleController {

  private edit let m_levelRequirementsWrapper: inkWidgetRef;

  private edit let m_strenghtOrReflexWrapper: inkWidgetRef;

  private edit let m_smartlinkGunWrapper: inkWidgetRef;

  private edit let m_anyAttributeWrapper: inkWidgetRef;

  private edit let m_levelRequirementsText: inkTextRef;

  private edit let m_strenghtOrReflexText: inkTextRef;

  private edit let m_anyAttributeText: inkTextRef;

  public func Update(data: ref<MinimalItemTooltipData>) -> Void {
    let textParams: ref<inkTextParams>;
    inkWidgetRef.SetVisible(this.m_levelRequirementsWrapper, false);
    inkWidgetRef.SetVisible(this.m_strenghtOrReflexWrapper, false);
    inkWidgetRef.SetVisible(this.m_smartlinkGunWrapper, false);
    inkWidgetRef.SetVisible(this.m_anyAttributeWrapper, false);
    if data.requirements.isSmartlinkRequirementNotMet {
      inkWidgetRef.SetVisible(this.m_smartlinkGunWrapper, true);
    };
    if data.requirements.isLevelRequirementNotMet {
      inkWidgetRef.SetVisible(this.m_levelRequirementsWrapper, true);
      inkTextRef.SetText(this.m_levelRequirementsText, IntToString(data.requirements.requiredLevel));
    };
    if data.requirements.isStrengthRequirementNotMet || data.requirements.isReflexRequirementNotMet {
      inkWidgetRef.SetVisible(this.m_strenghtOrReflexWrapper, true);
      textParams = new inkTextParams();
      textParams.AddString("statName", GetLocalizedText(data.requirements.strengthOrReflexStatName));
      textParams.AddNumber("statValue", data.requirements.strengthOrReflexValue);
      inkTextRef.SetText(this.m_strenghtOrReflexText, GetLocalizedText("LocKey#78420"));
      inkTextRef.SetTextParameters(this.m_strenghtOrReflexText, textParams);
    };
    if data.requirements.isAnyStatRequirementNotMet {
      inkWidgetRef.SetVisible(this.m_anyAttributeWrapper, true);
      textParams = new inkTextParams();
      textParams.AddNumber("value", data.requirements.anyStatValue);
      textParams.AddString("statName", GetLocalizedText(data.requirements.anyStatName));
      textParams.AddString("statColor", data.requirements.anyStatColor);
      inkTextRef.SetText(this.m_anyAttributeText, GetLocalizedText(data.requirements.anyStatLocKey));
      inkTextRef.SetTextParameters(this.m_anyAttributeText, textParams);
    };
  }
}

public class ItemTooltipDetailsModule extends ItemTooltipModuleController {

  private edit let m_statsLine: inkWidgetRef;

  private edit let m_statsWrapper: inkWidgetRef;

  private edit let m_statsContainer: inkCompoundRef;

  private edit let m_dedicatedModsLine: inkWidgetRef;

  private edit let m_dedicatedModsWrapper: inkWidgetRef;

  private edit let m_dedicatedModsContainer: inkCompoundRef;

  private edit let m_modsLine: inkWidgetRef;

  private edit let m_modsWrapper: inkWidgetRef;

  private edit let m_modsContainer: inkCompoundRef;

  public final func Update(data: ref<MinimalItemTooltipData>, hasStats: Bool, hasDedicatedMods: Bool, hasMods: Bool) -> Void {
    if hasStats && (NotEquals(data.displayContext, InventoryTooltipDisplayContext.Crafting) || data.isIconic) {
      inkWidgetRef.SetVisible(this.m_statsLine, true);
      inkWidgetRef.SetVisible(this.m_statsWrapper, true);
      this.UpdateStats(data);
    } else {
      inkWidgetRef.SetVisible(this.m_statsLine, false);
      inkWidgetRef.SetVisible(this.m_statsWrapper, false);
    };
    if hasDedicatedMods {
      inkWidgetRef.SetVisible(this.m_dedicatedModsLine, true);
      inkWidgetRef.SetVisible(this.m_dedicatedModsWrapper, true);
      this.UpdateDedicatedMods(data);
    } else {
      inkWidgetRef.SetVisible(this.m_dedicatedModsLine, false);
      inkWidgetRef.SetVisible(this.m_dedicatedModsWrapper, false);
    };
    if hasMods {
      inkWidgetRef.SetVisible(this.m_modsLine, true);
      inkWidgetRef.SetVisible(this.m_modsWrapper, true);
      this.UpdateMods(data);
    } else {
      inkWidgetRef.SetVisible(this.m_modsLine, false);
      inkWidgetRef.SetVisible(this.m_modsWrapper, false);
    };
  }

  private final func UpdateStats(data: ref<MinimalItemTooltipData>) -> Void {
    let controller: ref<ItemTooltipStatController>;
    let i: Int32;
    let widget: wref<inkWidget>;
    inkCompoundRef.RemoveAllChildren(this.m_statsContainer);
    i = 0;
    while i < ArraySize(data.stats) {
      widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_statsContainer), n"itemDetailsStat");
      controller = widget.GetController() as ItemTooltipStatController;
      controller.SetData(data.stats[i]);
      i += 1;
    };
  }

  private final func UpdateMods(data: ref<MinimalItemTooltipData>) -> Void {
    let controller: ref<ItemTooltipModController>;
    let i: Int32;
    let modsSize: Int32 = ArraySize(data.mods);
    while inkCompoundRef.GetNumChildren(this.m_modsContainer) > modsSize {
      inkCompoundRef.RemoveChildByIndex(this.m_modsContainer, 0);
    };
    while inkCompoundRef.GetNumChildren(this.m_modsContainer) < modsSize {
      this.SpawnFromLocal(inkWidgetRef.Get(this.m_modsContainer), n"itemTooltipMod");
    };
    i = 0;
    while i < modsSize {
      controller = inkCompoundRef.GetWidgetByIndex(this.m_modsContainer, i).GetController() as ItemTooltipModController;
      controller.SetData(data.mods[i]);
      i += 1;
    };
  }

  private final func UpdateDedicatedMods(data: ref<MinimalItemTooltipData>) -> Void {
    let controller: ref<ItemTooltipModController>;
    let i: Int32;
    let dedicatedModsSize: Int32 = ArraySize(data.dedicatedMods);
    while inkCompoundRef.GetNumChildren(this.m_dedicatedModsContainer) > dedicatedModsSize {
      inkCompoundRef.RemoveChildByIndex(this.m_dedicatedModsContainer, 0);
    };
    while inkCompoundRef.GetNumChildren(this.m_dedicatedModsContainer) < dedicatedModsSize {
      this.SpawnFromLocal(inkWidgetRef.Get(this.m_dedicatedModsContainer), n"itemTooltipMod");
    };
    i = 0;
    while i < dedicatedModsSize {
      controller = inkCompoundRef.GetWidgetByIndex(this.m_dedicatedModsContainer, i).GetController() as ItemTooltipModController;
      controller.SetData(data.dedicatedMods[i]);
      controller.HideDotIndicator();
      i += 1;
    };
  }
}

public class ItemTooltipRecipeDataModule extends ItemTooltipModuleController {

  private edit let m_statsLabel: inkTextRef;

  private edit let m_statsWrapper: inkWidgetRef;

  private edit let m_statsContainer: inkCompoundRef;

  private edit let m_damageTypesLabel: inkTextRef;

  private edit let m_damageTypesWrapper: inkWidgetRef;

  private edit let m_damageTypesContainer: inkCompoundRef;

  public func Update(data: ref<MinimalItemTooltipData>) -> Void {
    this.UpdatemRecipeDamageTypes(data);
    this.UpdatemRecipeProperties(data);
  }

  private final func UpdatemRecipeDamageTypes(data: ref<MinimalItemTooltipData>) -> Void {
    let controller: ref<ItemTooltipStatController>;
    let i: Int32;
    let stat: InventoryTooltipData_StatData;
    let damagesTypesSize: Int32 = ArraySize(data.recipeData.damageTypes);
    if damagesTypesSize > 0 {
      while inkCompoundRef.GetNumChildren(this.m_damageTypesContainer) > damagesTypesSize {
        inkCompoundRef.RemoveChildByIndex(this.m_damageTypesContainer, 0);
      };
      while inkCompoundRef.GetNumChildren(this.m_damageTypesContainer) < damagesTypesSize {
        this.SpawnFromLocal(inkWidgetRef.Get(this.m_damageTypesContainer), n"itemDetailsStat");
      };
      i = 0;
      while i < damagesTypesSize {
        stat = data.recipeData.damageTypes[i];
        controller = inkCompoundRef.GetWidgetByIndex(this.m_damageTypesContainer, i).GetController() as ItemTooltipStatController;
        controller.SetData(stat);
        i += 1;
      };
      inkWidgetRef.SetVisible(this.m_damageTypesWrapper, true);
    } else {
      inkWidgetRef.SetVisible(this.m_damageTypesWrapper, false);
    };
  }

  private final func UpdatemRecipeProperties(data: ref<MinimalItemTooltipData>) -> Void {
    let controller: ref<ItemRandomizedStatsController>;
    let statsQuantityParams: ref<inkTextParams>;
    let widget: wref<inkWidget>;
    if ArraySize(data.recipeData.recipeStats) > 0 {
      statsQuantityParams = new inkTextParams();
      statsQuantityParams.AddString("value", IntToString(data.recipeData.statsNumber));
      inkTextRef.SetLocalizedText(this.m_statsLabel, n"UI-Tooltips-RandomStatsNumber", statsQuantityParams);
      if inkCompoundRef.GetNumChildren(this.m_statsContainer) == 0 {
        widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_statsContainer), n"itemTooltipRecipeStat");
      } else {
        widget = inkCompoundRef.GetWidgetByIndex(this.m_statsContainer, 0);
      };
      controller = widget.GetController() as ItemRandomizedStatsController;
      controller.SetData(data.recipeData.recipeStats);
      inkWidgetRef.SetVisible(this.m_statsWrapper, true);
    } else {
      inkWidgetRef.SetVisible(this.m_statsWrapper, false);
    };
  }
}

public class ItemTooltipEvolutionModule extends ItemTooltipModuleController {

  private edit let m_weaponEvolutionIcon: inkImageRef;

  private edit let m_weaponEvolutionName: inkTextRef;

  private edit let m_weaponEvolutionDescription: inkTextRef;

  public func Update(data: ref<MinimalItemTooltipData>) -> Void {
    switch data.itemEvolution {
      case gamedataWeaponEvolution.Power:
        inkImageRef.SetTexturePart(this.m_weaponEvolutionIcon, n"ico_power");
        inkTextRef.SetText(this.m_weaponEvolutionName, "LocKey#54118");
        inkTextRef.SetText(this.m_weaponEvolutionDescription, "LocKey#54117");
        break;
      case gamedataWeaponEvolution.Smart:
        inkImageRef.SetTexturePart(this.m_weaponEvolutionIcon, n"ico_smart");
        inkTextRef.SetText(this.m_weaponEvolutionName, "LocKey#54119");
        inkTextRef.SetText(this.m_weaponEvolutionDescription, "LocKey#54120");
        break;
      case gamedataWeaponEvolution.Tech:
        inkImageRef.SetTexturePart(this.m_weaponEvolutionIcon, n"ico_tech");
        inkTextRef.SetText(this.m_weaponEvolutionName, "LocKey#54121");
        inkTextRef.SetText(this.m_weaponEvolutionDescription, "LocKey#54122");
        break;
      case gamedataWeaponEvolution.Blunt:
        inkImageRef.SetTexturePart(this.m_weaponEvolutionIcon, n"ico_blunt");
        inkTextRef.SetText(this.m_weaponEvolutionName, "LocKey#77968");
        inkTextRef.SetText(this.m_weaponEvolutionDescription, "LocKey#77969 ");
        break;
      case gamedataWeaponEvolution.Blade:
        inkImageRef.SetTexturePart(this.m_weaponEvolutionIcon, n"ico_blades");
        inkTextRef.SetText(this.m_weaponEvolutionName, "LocKey#77957");
        inkTextRef.SetText(this.m_weaponEvolutionDescription, "LocKey#77960");
    };
  }
}

public class ItemTooltipCraftedModule extends ItemTooltipModuleController {

  public func Update(data: ref<MinimalItemTooltipData>) -> Void {
    this.GetRootWidget().SetState(UIItemsHelper.QualityEnumToName(data.quality));
  }
}

public class ItemTooltipBottomModule extends ItemTooltipModuleController {

  private edit let m_weightWrapper: inkWidgetRef;

  private edit let m_priceWrapper: inkWidgetRef;

  private edit let m_weightText: inkTextRef;

  private edit let m_priceText: inkTextRef;

  public func Update(data: ref<MinimalItemTooltipData>) -> Void {
    inkTextRef.SetText(this.m_weightText, FloatToStringPrec(data.weight, 1));
    if NotEquals(data.displayContext, InventoryTooltipDisplayContext.Vendor) && (data.itemData.HasTag(n"Shard") || data.itemData.HasTag(n"Recipe") || Equals(data.itemType, gamedataItemType.Con_Ammo) || Equals(data.itemType, gamedataItemType.Wea_Fists) || Equals(data.lootItemType, LootItemType.Quest)) {
      inkTextRef.SetText(this.m_priceText, "N/A");
    } else {
      inkTextRef.SetText(this.m_priceText, IntToString(RoundF(data.price) * data.itemData.GetQuantity()));
    };
  }
}
