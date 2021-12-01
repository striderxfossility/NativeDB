
public class ItemTooltipController extends AGenericTooltipController {

  protected edit let m_itemNameText: inkTextRef;

  protected edit let m_itemRarityText: inkTextRef;

  protected edit let m_progressBar: inkWidgetRef;

  protected edit let m_recipeStatsTitle: inkTextRef;

  protected edit let m_categoriesWrapper: inkCompoundRef;

  protected edit let m_backgroundContainer: inkCompoundRef;

  protected edit let m_topContainer: inkCompoundRef;

  protected edit let m_headerContainer: inkCompoundRef;

  protected edit let m_headerWeaponContainer: inkCompoundRef;

  protected edit let m_headerItemContainer: inkCompoundRef;

  protected edit let m_headerGrenadeContainer: inkCompoundRef;

  protected edit let m_headerArmorContainer: inkCompoundRef;

  protected edit let m_primmaryStatsContainer: inkCompoundRef;

  protected edit let m_secondaryStatsContainer: inkCompoundRef;

  protected edit let m_recipeStatsContainer: inkCompoundRef;

  protected edit let m_recipeDamageTypesContainer: inkCompoundRef;

  protected edit let m_modsContainer: inkCompoundRef;

  protected edit let m_dedicatedModsContainer: inkCompoundRef;

  protected edit let m_descriptionContainer: inkCompoundRef;

  protected edit let m_craftedItemContainer: inkCompoundRef;

  protected edit let m_bottomContainer: inkCompoundRef;

  protected edit let m_primmaryStatsList: inkCompoundRef;

  protected edit let m_secondaryStatsList: inkCompoundRef;

  protected edit let m_recipeStatsTypesList: inkCompoundRef;

  protected edit let m_recipeDamageTypesList: inkCompoundRef;

  protected edit let m_modsList: inkCompoundRef;

  protected edit let m_dedicatedModsList: inkCompoundRef;

  protected edit let m_requiredLevelContainer: inkCompoundRef;

  protected edit let m_priceContainer: inkCompoundRef;

  protected edit let m_descriptionText: inkTextRef;

  protected edit let m_requireLevelText: inkTextRef;

  protected edit let m_priceText: inkTextRef;

  protected edit let m_dpsWrapper: inkWidgetRef;

  protected edit let m_dpsArrow: inkImageRef;

  protected edit let m_dpsText: inkTextRef;

  protected edit let m_nonLethalText: inkTextRef;

  protected edit let m_damagePerHitValue: inkTextRef;

  protected edit let m_attacksPerSecondValue: inkTextRef;

  protected edit let m_silencerPartWrapper: inkWidgetRef;

  protected edit let m_scopePartWrapper: inkWidgetRef;

  protected edit let m_craftedItemIcon: inkWidgetRef;

  protected edit let m_grenadeDamageTypeWrapper: inkWidgetRef;

  protected edit let m_grenadeDamageTypeIcon: inkImageRef;

  protected edit let m_grenadeRangeValue: inkTextRef;

  protected edit let m_grenadeRangeText: inkTextRef;

  protected edit let m_grenadeDeliveryLabel: inkTextRef;

  protected edit let m_grenadeDeliveryIcon: inkImageRef;

  protected edit let m_grenadeDamageStatWrapper: inkWidgetRef;

  protected edit let m_grenadeDamageStatLabel: inkTextRef;

  protected edit let m_grenadeDamageStatValue: inkTextRef;

  protected edit let m_armorStatArrow: inkImageRef;

  protected edit let m_armorStatLabel: inkTextRef;

  protected edit let m_quickhackStatWrapper: inkWidgetRef;

  protected edit let m_quickhackCostValue: inkTextRef;

  protected edit let m_quickhackDuration: inkTextRef;

  protected edit let m_quickhackCooldown: inkTextRef;

  protected edit let m_quickhackUpload: inkTextRef;

  protected edit let m_damageTypeWrapper: inkWidgetRef;

  protected edit let m_damageTypeIcon: inkImageRef;

  protected edit let m_equipedWrapper: inkWidgetRef;

  protected edit let m_itemTypeText: inkTextRef;

  protected edit let m_itemPreviewWrapper: inkWidgetRef;

  protected edit let m_itemPreviewIcon: inkImageRef;

  protected edit let m_itemPreviewIconicLines: inkWidgetRef;

  protected edit let m_itemWeightWrapper: inkWidgetRef;

  protected edit let m_itemWeightText: inkTextRef;

  protected edit let m_itemAmmoWrapper: inkWidgetRef;

  protected edit let m_itemAmmoText: inkTextRef;

  protected edit let m_itemRequirements: inkWidgetRef;

  protected edit let m_itemLevelRequirements: inkWidgetRef;

  protected edit let m_itemStrenghtRequirements: inkWidgetRef;

  protected edit let m_itemAttributeRequirements: inkWidgetRef;

  protected edit let m_itemSmartGunLinkRequirements: inkWidgetRef;

  protected edit let m_itemLevelRequirementsValue: inkTextRef;

  protected edit let m_itemStrenghtRequirementsValue: inkTextRef;

  protected edit let m_itemAttributeRequirementsText: inkTextRef;

  protected edit let m_weaponEvolutionWrapper: inkWidgetRef;

  protected edit let m_weaponEvolutionIcon: inkImageRef;

  protected edit let m_weaponEvolutionName: inkTextRef;

  protected edit let m_weaponEvolutionDescription: inkTextRef;

  protected edit let DEBUG_iconErrorWrapper: inkWidgetRef;

  protected edit let DEBUG_iconErrorText: inkTextRef;

  protected let DEBUG_showAdditionalInfo: Bool;

  protected let m_data: ref<InventoryTooltipData>;

  private let m_animProxy: ref<inkAnimProxy>;

  private let m_playAnimation: Bool;

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
    if evt.IsShiftDown() {
      this.DEBUG_showAdditionalInfo = true;
    } else {
      this.DEBUG_showAdditionalInfo = false;
    };
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
    this.m_data = tooltipData as InventoryTooltipData;
    this.UpdateLayout();
  }

  public final func ForceNoEquipped() -> Void {
    this.m_data.isEquipped = false;
    this.UpdateLayout();
  }

  public func Show() -> Void {
    this.Show();
    if IsDefined(this.m_animProxy) {
      this.m_animProxy.Stop();
      this.m_animProxy = null;
    };
    if this.m_playAnimation {
      this.m_animProxy = this.PlayLibraryAnimationOnAutoSelectedTargets(n"show_item_tooltip", this.GetRootWidget());
      this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnShowAnimationFinished");
    };
  }

  protected final func UpdateLayout() -> Void {
    this.UpdateName();
    this.UpdateItemType();
    this.UpdateDamageType();
    this.UpdateRarity();
    this.UpdateHeader();
    this.UpdateParts();
    this.UpdateDPS();
    this.UpdateArmor();
    this.UpdateEvolutionDescription();
    this.UpdateSecondaryStats();
    this.UpdatemRecipeProperties();
    this.UpdatemRecipeDamageTypes();
    this.UpdateAttachments();
    this.UpdateRequirements();
    this.UpdateDescription();
    this.UpdateCraftedIcon();
    this.UpdatePrice();
    this.UpdateWeight();
    this.UpdateAmmo();
    this.UpdateQuickhackState();
    this.DEBUG_UpdateIconErrorInfo();
    this.UpdateIcon();
    this.UpdateEquipped();
    this.UpdateGrenadeStats();
    this.FixLines();
    inkWidgetRef.SetVisible(this.m_progressBar, false);
    inkWidgetRef.SetVisible(this.m_backgroundContainer, NotEquals(this.m_data.displayContext, InventoryTooltipDisplayContext.Crafting));
  }

  protected final func UpdateItemType() -> Void {
    let finalType: String;
    let evolution: gamedataWeaponEvolution = gamedataWeaponEvolution.Invalid;
    if Equals(InventoryItemData.GetEquipmentArea(this.m_data.inventoryItemData), gamedataEquipmentArea.Weapon) {
      evolution = RPGManager.GetWeaponEvolution(InventoryItemData.GetID(this.m_data.inventoryItemData));
    };
    finalType += GetLocalizedText(UIItemsHelper.GetItemTypeKey(this.GetItemType(), evolution));
    inkTextRef.SetText(this.m_itemTypeText, finalType);
  }

  protected final func UpdateName() -> Void {
    let finalItemName: String;
    let id: TweakDBID;
    let itemData: wref<gameItemData>;
    let quantity: Int32;
    if Equals(this.m_data.displayContext, InventoryTooltipDisplayContext.Crafting) || Equals(this.m_data.displayContext, InventoryTooltipDisplayContext.Upgrading) {
      inkWidgetRef.SetVisible(this.m_itemNameText, false);
      return;
    };
    inkWidgetRef.SetVisible(this.m_itemNameText, true);
    id = ItemID.GetTDBID(InventoryItemData.GetID(this.m_data.inventoryItemData));
    if !TDBID.IsValid(id) {
      id = ItemID.GetTDBID(this.m_data.itemID);
    };
    itemData = InventoryItemData.GetGameItemData(this.m_data.inventoryItemData);
    quantity = InventoryItemData.GetQuantity(this.m_data.inventoryItemData);
    finalItemName = UIItemsHelper.GetTooltipItemName(id, itemData, this.m_data.itemName);
    if quantity > 1 {
      finalItemName += " [" + IntToString(quantity) + "]";
    };
    inkTextRef.SetText(this.m_itemNameText, finalItemName);
  }

  protected func UpdateIcon() -> Void {
    let emptyIcon: CName;
    let iconName: String;
    let iconsNameResolver: ref<IconsNameResolver> = IconsNameResolver.GetIconsNameResolver();
    let localData: ref<gameItemData> = InventoryItemData.GetGameItemData(this.m_data.inventoryItemData);
    if IsDefined(localData) && localData.HasTag(n"Recipe") {
      this.UpdateRecipeIcon();
      return;
    };
    if this.m_data.isCraftable || Equals(this.m_data.displayContext, InventoryTooltipDisplayContext.Upgrading) {
      inkWidgetRef.SetVisible(this.m_itemPreviewWrapper, false);
      return;
    };
    inkWidgetRef.SetVisible(this.m_itemPreviewWrapper, true);
    if IsStringValid(InventoryItemData.GetIconPath(this.m_data.inventoryItemData)) {
      iconName = InventoryItemData.GetIconPath(this.m_data.inventoryItemData);
    } else {
      iconName = NameToString(iconsNameResolver.TranslateItemToIconName(ItemID.GetTDBID(InventoryItemData.GetID(this.m_data.inventoryItemData)), Equals(InventoryItemData.GetIconGender(this.m_data.inventoryItemData), ItemIconGender.Male)));
    };
    if NotEquals(iconName, "None") && NotEquals(iconName, "") {
      inkWidgetRef.SetScale(this.m_itemPreviewIcon, Equals(InventoryItemData.GetEquipmentArea(this.m_data.inventoryItemData), gamedataEquipmentArea.Outfit) ? new Vector2(0.50, 0.50) : new Vector2(1.00, 1.00));
      InkImageUtils.RequestSetImage(this, this.m_itemPreviewIcon, "UIIcon." + iconName, n"OnIconCallback");
    } else {
      emptyIcon = UIItemsHelper.GetSlotShadowIcon(TDBID.undefined(), this.GetItemType(), InventoryItemData.GetEquipmentArea(this.m_data.inventoryItemData));
      InkImageUtils.RequestSetImage(this, this.m_itemPreviewIcon, emptyIcon);
    };
  }

  protected func UpdateRecipeIcon() -> Void {
    let emptyIcon: CName;
    let iconName: String;
    let itemRecord: wref<Item_Record>;
    let itemScale: Vector2;
    let iconsNameResolver: ref<IconsNameResolver> = IconsNameResolver.GetIconsNameResolver();
    let recipeRecord: wref<ItemRecipe_Record> = TweakDBInterface.GetItemRecipeRecord(ItemID.GetTDBID(this.m_data.itemID));
    let craftingResult: wref<CraftingResult_Record> = recipeRecord.CraftingResult();
    if IsDefined(craftingResult) {
      itemRecord = craftingResult.Item();
    };
    if IsStringValid(itemRecord.IconPath()) {
      iconName = itemRecord.IconPath();
    } else {
      iconName = NameToString(iconsNameResolver.TranslateItemToIconName(itemRecord.GetID(), Equals(InventoryItemData.GetIconGender(this.m_data.inventoryItemData), ItemIconGender.Male)));
    };
    if NotEquals(iconName, "None") && NotEquals(iconName, "") {
      if Equals(itemRecord.EquipArea().Type(), gamedataEquipmentArea.Outfit) {
        itemScale = new Vector2(0.50, 0.50);
      } else {
        if Equals(itemRecord.EquipArea().Type(), gamedataEquipmentArea.Weapon) {
          itemScale = new Vector2(0.33, 0.33);
        } else {
          itemScale = new Vector2(1.00, 1.00);
        };
      };
      inkWidgetRef.SetScale(this.m_itemPreviewIcon, itemScale);
      InkImageUtils.RequestSetImage(this, this.m_itemPreviewIcon, "UIIcon." + iconName, n"OnIconCallback");
    } else {
      emptyIcon = UIItemsHelper.GetSlotShadowIcon(TDBID.undefined(), this.GetItemType(), InventoryItemData.GetEquipmentArea(this.m_data.inventoryItemData));
      InkImageUtils.RequestSetImage(this, this.m_itemPreviewIcon, emptyIcon);
    };
  }

  protected cb func OnIconCallback(e: ref<iconAtlasCallbackData>) -> Bool {
    if NotEquals(e.loadResult, inkIconResult.Success) {
      inkWidgetRef.SetVisible(this.m_itemPreviewWrapper, false);
    };
  }

  protected final func DEBUG_UpdateIconErrorInfo() -> Void {
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
      resultText += TDBID.ToStringDEBUG(ItemID.GetTDBID(InventoryItemData.GetID(this.m_data.inventoryItemData)));
      if InventoryItemData.GetGameItemData(this.m_data.inventoryItemData).HasTag(n"Recipe") {
        recipeRecord = TweakDBInterface.GetRecipeItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(this.m_data.inventoryItemData)));
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

  protected final func UpdateEquipped() -> Void {
    inkWidgetRef.SetVisible(this.m_equipedWrapper, this.m_data.isEquipped || Equals(this.m_data.displayContext, InventoryTooltipDisplayContext.Attachment));
  }

  protected final func UpdateProgressBar() -> Void;

  protected final func UpdateQuickhackState() -> Void {
    let cooldownParams: ref<inkTextParams>;
    let costParams: ref<inkTextParams>;
    let durationParams: ref<inkTextParams>;
    let uploadParams: ref<inkTextParams>;
    if Equals(this.GetItemType(), gamedataItemType.Prt_Program) {
      inkWidgetRef.SetVisible(this.m_quickhackStatWrapper, true);
      costParams = new inkTextParams();
      costParams.AddLocalizedString("SEC", "LocKey#40730");
      costParams.AddNumber("VALUE", this.m_data.quickhackData.baseCost);
      (inkWidgetRef.Get(this.m_quickhackCostValue) as inkText).SetLocalizedTextScript("LocKey#40804", costParams);
      durationParams = new inkTextParams();
      durationParams.AddLocalizedString("SEC", "LocKey#40730");
      durationParams.AddNumber("VALUE", this.m_data.quickhackData.duration);
      (inkWidgetRef.Get(this.m_quickhackDuration) as inkText).SetLocalizedTextScript("LocKey#40736", durationParams);
      cooldownParams = new inkTextParams();
      cooldownParams.AddLocalizedString("SEC", "LocKey#40730");
      cooldownParams.AddNumber("VALUE", this.m_data.quickhackData.cooldown);
      (inkWidgetRef.Get(this.m_quickhackCooldown) as inkText).SetLocalizedTextScript("LocKey#40729", cooldownParams);
      uploadParams = new inkTextParams();
      uploadParams.AddLocalizedString("SEC", "LocKey#40730");
      uploadParams.AddNumber("VALUE", this.m_data.quickhackData.uploadTime);
      (inkWidgetRef.Get(this.m_quickhackUpload) as inkText).SetLocalizedTextScript("LocKey#40737", uploadParams);
    } else {
      inkWidgetRef.SetVisible(this.m_quickhackStatWrapper, false);
    };
  }

  protected final func UpdateGrenadeStats() -> Void {
    let tweakRecord: ref<Grenade_Record>;
    if Equals(this.GetItemType(), gamedataItemType.Gad_Grenade) {
      inkWidgetRef.SetVisible(this.m_grenadeDamageStatWrapper, true);
      tweakRecord = TweakDBInterface.GetGrenadeRecord(ItemID.GetTDBID(InventoryItemData.GetID(this.m_data.inventoryItemData)));
      this.UpdateGrenadeRange(tweakRecord);
      this.UpdateGrenadeDelivery(tweakRecord);
      this.UpdateGrenadeDamage(tweakRecord);
    } else {
      inkWidgetRef.SetVisible(this.m_grenadeDamageStatWrapper, false);
    };
  }

  protected final func GetGranadeDamageFromStats() -> InventoryTooltipData_StatData {
    let result: InventoryTooltipData_StatData;
    let stats: array<InventoryTooltipData_StatData> = this.GetDamageStatsFromSecondayStats();
    if ArraySize(stats) > 0 {
      result = stats[0];
    } else {
      result.statType = gamedataStatType.Invalid;
    };
    return result;
  }

  protected final func GetArmorStatFromSecondaryStats() -> InventoryTooltipData_StatData {
    let emptyResult: InventoryTooltipData_StatData;
    let stats: array<InventoryTooltipData_StatData> = this.GetSecondaryStatsData(this.m_data);
    let i: Int32 = 0;
    while i < ArraySize(stats) {
      if Equals(stats[i].statType, gamedataStatType.Armor) {
        return stats[i];
      };
      i += 1;
    };
    return emptyResult;
  }

  protected final func GetDamageStatsFromSecondayStats() -> array<InventoryTooltipData_StatData> {
    let result: array<InventoryTooltipData_StatData>;
    let stats: array<InventoryTooltipData_StatData> = this.GetSecondaryStatsData(this.m_data);
    stats = this.FilterStatsWithValue(stats);
    let i: Int32 = 0;
    while i < ArraySize(stats) {
      if this.IsDamageStat(stats[i].statType) {
        stats[i].minStatValueF = stats[i].currentValueF * 0.90;
        stats[i].maxStatValueF = stats[i].currentValueF * 1.10;
        ArrayPush(result, stats[i]);
      };
      i += 1;
    };
    return result;
  }

  public final func ProcessDoTEffects(effects: wref<StatusEffect_Record>) -> array<ref<DamageEffectUIEntry>> {
    let attackRecord: wref<Attack_Record>;
    let attackRecordStatModifier: wref<StatModifier_Record>;
    let attackRecordStatModifiers: array<wref<StatModifier_Record>>;
    let combinedMod: wref<CombinedStatModifier_Record>;
    let constantMod: wref<ConstantStatModifier_Record>;
    let continousDelayTime: Float;
    let durationConstantStat: wref<ConstantStatModifier_Record>;
    let durationRecord: wref<StatModifierGroup_Record>;
    let durationRecordStatModifiers: array<wref<StatModifier_Record>>;
    let durationStatModifier: wref<StatModifier_Record>;
    let effector: wref<Effector_Record>;
    let effectorAsContinousAttack: wref<ContinuousAttackEffector_Record>;
    let effectorAsTriggerAttack: wref<TriggerAttackEffector_Record>;
    let effectors: array<wref<Effector_Record>>;
    let i: Int32;
    let isContinuous: Bool;
    let j: Int32;
    let k: Int32;
    let l: Int32;
    let package: wref<GameplayLogicPackage_Record>;
    let result: array<ref<DamageEffectUIEntry>>;
    let resultEntry: ref<DamageEffectUIEntry>;
    let statusPackages: array<wref<GameplayLogicPackage_Record>>;
    let durationStatToSkip: ref<StatModifierGroup_Record> = TweakDBInterface.GetStatModifierGroupRecord(t"BaseStatusEffect.BaseQuickHackDuration");
    effects.Packages(statusPackages);
    durationRecord = effects.Duration();
    if durationRecord != durationStatToSkip {
      durationRecord.StatModifiers(durationRecordStatModifiers);
    };
    i = 0;
    while i < ArraySize(statusPackages) {
      package = statusPackages[i];
      package.Effectors(effectors);
      j = 0;
      while j < ArraySize(effectors) {
        effector = effectors[j];
        effectorAsTriggerAttack = effector as TriggerAttackEffector_Record;
        attackRecord = null;
        if IsDefined(effectorAsTriggerAttack) {
          attackRecord = effectorAsTriggerAttack.AttackRecord();
        };
        effectorAsContinousAttack = effector as ContinuousAttackEffector_Record;
        if IsDefined(effectorAsContinousAttack) {
          attackRecord = effectorAsContinousAttack.AttackRecord();
          continousDelayTime = effectorAsContinousAttack.DelayTime();
          isContinuous = true;
        };
        if IsDefined(attackRecord) {
          l = 0;
          while l < ArraySize(durationRecordStatModifiers) {
            durationStatModifier = durationRecordStatModifiers[l];
            if durationStatModifier != durationStatToSkip {
              if Equals(durationStatModifier.StatType().StatType(), gamedataStatType.MaxDuration) {
                if IsDefined(durationStatModifier as ConstantStatModifier_Record) {
                  durationConstantStat = durationStatModifier as ConstantStatModifier_Record;
                };
              };
            };
            l += 1;
          };
          attackRecord.StatModifiers(attackRecordStatModifiers);
          k = 0;
          while k < ArraySize(attackRecordStatModifiers) {
            attackRecordStatModifier = attackRecordStatModifiers[k];
            constantMod = attackRecordStatModifier as ConstantStatModifier_Record;
            combinedMod = attackRecordStatModifier as CombinedStatModifier_Record;
            if IsDefined(constantMod) {
              resultEntry = new DamageEffectUIEntry();
              resultEntry.valueStat = constantMod.StatType().StatType();
              resultEntry.targetStat = gamedataStatType.Invalid;
              resultEntry.displayType = DamageEffectDisplayType.Flat;
              resultEntry.valueToDisplay = constantMod.Value();
              resultEntry.effectorDuration = durationConstantStat.Value();
              resultEntry.effectorDelay = continousDelayTime;
              resultEntry.isContinuous = isContinuous;
              ArrayPush(result, resultEntry);
            };
            if IsDefined(combinedMod) {
              resultEntry = new DamageEffectUIEntry();
              resultEntry.valueStat = combinedMod.StatType().StatType();
              resultEntry.targetStat = combinedMod.RefStat().StatType();
              resultEntry.displayType = DamageEffectDisplayType.Invalid;
              resultEntry.valueToDisplay = combinedMod.Value();
              resultEntry.effectorDuration = durationConstantStat.Value();
              resultEntry.effectorDelay = continousDelayTime;
              resultEntry.isContinuous = isContinuous;
              if Equals(combinedMod.OpSymbol(), n"*") && Equals(resultEntry.targetStat, gamedataStatType.Health) {
                resultEntry.displayType = DamageEffectDisplayType.TargetHealth;
                resultEntry.valueToDisplay = resultEntry.valueToDisplay * 100.00;
              };
              ArrayPush(result, resultEntry);
            };
            k += 1;
          };
        };
        j += 1;
      };
      i += 1;
    };
    return result;
  }

  protected final func GetDoTEffects(attackRecord: wref<Attack_Record>) -> array<ref<DamageEffectUIEntry>> {
    let i: Int32;
    let j: Int32;
    let processedDoTEffects: array<ref<DamageEffectUIEntry>>;
    let result: array<ref<DamageEffectUIEntry>>;
    let statusEffects: array<wref<StatusEffectAttackData_Record>>;
    attackRecord.StatusEffects(statusEffects);
    i = 0;
    while i < ArraySize(statusEffects) {
      processedDoTEffects = this.ProcessDoTEffects(statusEffects[i].StatusEffect());
      j = 0;
      while j < ArraySize(processedDoTEffects) {
        ArrayPush(result, processedDoTEffects[j]);
        j += 1;
      };
      i += 1;
    };
    return result;
  }

  protected final func UpdateGrenadeDamage(tweakRecord: ref<Grenade_Record>) -> Void {
    let dotResultText: String;
    let damageStat: InventoryTooltipData_StatData = this.GetGranadeDamageFromStats();
    inkWidgetRef.SetState(this.m_grenadeDamageTypeWrapper, UIItemsHelper.GetStateNameForStat(damageStat.statType));
    inkImageRef.SetTexturePart(this.m_grenadeDamageTypeIcon, UIItemsHelper.GetIconNameForStat(damageStat.statType));
    if Equals(this.m_data.grenadeData.type, GrenadeDamageType.DoT) {
      dotResultText += IntToString(RoundF(this.m_data.grenadeData.totalDamage));
      dotResultText += " / ";
      dotResultText += IntToString(RoundF(this.m_data.grenadeData.duration));
      dotResultText += " ";
      dotResultText += GetLocalizedText("UI-Quickhacks-Seconds");
      inkTextRef.SetText(this.m_grenadeDamageStatValue, dotResultText);
      inkTextRef.SetText(this.m_grenadeDamageStatLabel, "Gameplay-RPG-Damage-DoT");
      inkWidgetRef.SetVisible(this.m_grenadeDamageStatWrapper, true);
    } else {
      if NotEquals(damageStat.statType, gamedataStatType.Invalid) {
        inkTextRef.SetText(this.m_grenadeDamageStatValue, FloatToStringPrec(damageStat.minStatValueF, 0) + "-" + FloatToStringPrec(damageStat.maxStatValueF, 0));
        inkTextRef.SetText(this.m_grenadeDamageStatLabel, "Gameplay-Scanning-Devices-GameplayActions-Damage");
        inkWidgetRef.SetVisible(this.m_grenadeDamageStatWrapper, true);
      } else {
        inkWidgetRef.SetVisible(this.m_grenadeDamageStatWrapper, false);
      };
    };
  }

  protected final func UpdateGrenadeRange(tweakRecord: ref<Grenade_Record>) -> Void {
    let finalRangeDecimalPart: Int32;
    let i: Int32;
    let statModifier: array<wref<StatModifier_Record>>;
    let rangeTextParams: ref<inkTextParams> = new inkTextParams();
    let measurementUnit: EMeasurementUnit = UILocalizationHelper.GetSystemBaseUnit();
    let unitName: CName = MeasurementUtils.GetUnitLocalizationKey(measurementUnit);
    let finalRange: Float = tweakRecord.AttackRadius();
    tweakRecord.StatModifiers(statModifier);
    i = ArraySize(statModifier) - 1;
    while i > 0 {
      if Equals(statModifier[i].StatType().StatType(), gamedataStatType.Range) {
        if IsDefined(statModifier[i] as CombinedStatModifier_Record) {
          finalRange = (statModifier[i] as CombinedStatModifier_Record).Value();
        };
        if IsDefined(statModifier[i] as ConstantStatModifier_Record) {
          finalRange = (statModifier[i] as ConstantStatModifier_Record).Value();
        };
      };
      i -= 1;
    };
    finalRange = MeasurementUtils.ValueUnitToUnit(finalRange, EMeasurementUnit.Meter, measurementUnit);
    finalRangeDecimalPart = RoundF((finalRange - Cast(RoundF(finalRange))) * 10.00) % 10;
    rangeTextParams.AddNumber("value", FloorF(finalRange));
    rangeTextParams.AddNumber("valueDecimalPart", finalRangeDecimalPart);
    rangeTextParams.AddString("unit", GetLocalizedText(NameToString(unitName)));
    inkTextRef.SetText(this.m_grenadeRangeText, finalRangeDecimalPart != 0 ? "UI-Tooltips-GrenadeRangeWithDecimalTemplate" : "UI-Tooltips-GrenadeRangeTemplate");
    inkTextRef.SetTextParameters(this.m_grenadeRangeText, rangeTextParams);
  }

  protected final func UpdateGrenadeDelivery(tweakRecord: ref<Grenade_Record>) -> Void {
    let deliveryMethod: gamedataGrenadeDeliveryMethodType = tweakRecord.DeliveryMethod().Type().Type();
    switch deliveryMethod {
      case gamedataGrenadeDeliveryMethodType.Regular:
        InkImageUtils.RequestSetImage(this, this.m_grenadeDeliveryIcon, "UIIcon.");
        inkTextRef.SetText(this.m_grenadeDeliveryLabel, GetLocalizedText("Gameplay-Items-Stats-Delivery-Regular"));
        break;
      case gamedataGrenadeDeliveryMethodType.Sticky:
        InkImageUtils.RequestSetImage(this, this.m_grenadeDeliveryIcon, "UIIcon.");
        inkTextRef.SetText(this.m_grenadeDeliveryLabel, GetLocalizedText("Gameplay-Items-Stats-Delivery-Sticky"));
        break;
      case gamedataGrenadeDeliveryMethodType.Homing:
        InkImageUtils.RequestSetImage(this, this.m_grenadeDeliveryIcon, "UIIcon.");
        inkTextRef.SetText(this.m_grenadeDeliveryLabel, GetLocalizedText("Gameplay-Items-Stats-Delivery-Homing"));
    };
  }

  protected final func UpdateAmmo() -> Void {
    if Equals(this.m_data.equipArea, gamedataEquipmentArea.Weapon) || Equals(this.m_data.equipArea, gamedataEquipmentArea.WeaponHeavy) {
      if InventoryItemData.GetGameItemData(this.m_data.inventoryItemData).HasTag(WeaponObject.GetMeleeWeaponTag()) {
        inkWidgetRef.SetVisible(this.m_itemAmmoWrapper, false);
      } else {
        inkWidgetRef.SetVisible(this.m_itemAmmoWrapper, true);
        inkTextRef.SetText(this.m_itemAmmoText, IntToString(InventoryItemData.GetAmmo(this.m_data.inventoryItemData)));
      };
      if Equals(this.GetItemType(), gamedataItemType.Gad_Grenade) {
        inkWidgetRef.SetVisible(this.m_itemAmmoWrapper, false);
      };
    } else {
      inkWidgetRef.SetVisible(this.m_itemAmmoWrapper, false);
    };
  }

  protected final func UpdateDamageType() -> Void {
    inkWidgetRef.SetState(this.m_damageTypeWrapper, UIItemsHelper.GetStateNameForType(this.m_data.damageType));
    inkImageRef.SetTexturePart(this.m_damageTypeIcon, WeaponsUtils.GetDamageTypeIcon(this.m_data.damageType));
  }

  protected final func UpdateRarity() -> Void {
    let iconicLabel: String;
    let isIconic: Bool;
    let quality: gamedataQuality;
    let rarityLabel: String;
    if Equals(this.m_data.displayContext, InventoryTooltipDisplayContext.Crafting) || Equals(this.m_data.displayContext, InventoryTooltipDisplayContext.Upgrading) {
      inkWidgetRef.SetVisible(this.m_itemRarityText, false);
      return;
    };
    inkWidgetRef.SetVisible(this.m_itemRarityText, true);
    if this.m_data.overrideRarity {
      quality = UIItemsHelper.QualityNameToEnum(StringToName(this.m_data.quality));
    } else {
      quality = RPGManager.GetItemDataQuality(InventoryItemData.GetGameItemData(this.m_data.inventoryItemData));
    };
    isIconic = RPGManager.IsItemIconic(InventoryItemData.GetGameItemData(this.m_data.inventoryItemData));
    rarityLabel = GetLocalizedText(UIItemsHelper.QualityToLocalizationKey(quality));
    iconicLabel = GetLocalizedText(UIItemsHelper.QualityToLocalizationKey(gamedataQuality.Iconic));
    if isIconic {
      inkWidgetRef.SetState(this.m_itemNameText, n"Iconic");
    } else {
      inkWidgetRef.SetState(this.m_itemNameText, UIItemsHelper.QualityEnumToName(quality));
    };
    inkWidgetRef.SetState(this.m_itemRarityText, UIItemsHelper.QualityEnumToName(quality));
    inkTextRef.SetText(this.m_itemRarityText, isIconic ? rarityLabel + " / " + iconicLabel : rarityLabel);
    inkWidgetRef.SetState(this.m_craftedItemContainer, UIItemsHelper.QualityEnumToName(quality));
    inkWidgetRef.SetVisible(this.m_itemPreviewIconicLines, isIconic);
  }

  protected final func FixLines() -> Void {
    let container: wref<inkCompoundWidget>;
    let lineWidget: wref<inkWidget>;
    let firstHidden: Bool = false;
    let i: Int32 = 0;
    while i < inkCompoundRef.GetNumChildren(this.m_categoriesWrapper) {
      container = inkCompoundRef.GetWidgetByIndex(this.m_categoriesWrapper, i) as inkCompoundWidget;
      if IsDefined(container) {
        if container.IsVisible() {
          lineWidget = container.GetWidgetByPath(inkWidgetPath.Build(n"line"));
          if IsDefined(lineWidget) {
            lineWidget.SetVisible(firstHidden);
            firstHidden = true;
          };
        };
      };
      i += 1;
    };
  }

  protected final func UpdateHeader() -> Void {
    let armorStat: InventoryTooltipData_StatData;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(this.m_data.itemID));
    inkWidgetRef.SetVisible(this.m_headerContainer, true);
    inkWidgetRef.SetVisible(this.m_headerItemContainer, true);
    inkWidgetRef.SetVisible(this.m_headerWeaponContainer, false);
    inkWidgetRef.SetVisible(this.m_headerGrenadeContainer, false);
    inkWidgetRef.SetVisible(this.m_headerArmorContainer, false);
    if Equals(this.m_data.equipArea, gamedataEquipmentArea.Weapon) || Equals(this.m_data.equipArea, gamedataEquipmentArea.WeaponHeavy) {
      inkWidgetRef.SetVisible(this.m_headerWeaponContainer, true);
    } else {
      if Equals(itemRecord.ItemType().Type(), gamedataItemType.Gad_Grenade) {
        inkWidgetRef.SetVisible(this.m_headerGrenadeContainer, true);
      } else {
        if Equals(itemRecord.ItemCategory().Type(), gamedataItemCategory.Clothing) {
          armorStat = this.GetArmorStatFromSecondaryStats();
          if Equals(armorStat.statType, gamedataStatType.Armor) {
            inkWidgetRef.SetVisible(this.m_headerArmorContainer, true);
          };
        };
      };
    };
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

  protected final func UpdateParts() -> Void {
    let attachments: InventoryItemAttachments;
    let scopeAttachmentSlot: InventoryItemAttachments;
    let silencerAttachmentSlot: InventoryItemAttachments;
    let attachmentsSize: Int32 = InventoryItemData.GetAttachmentsSize(this.m_data.inventoryItemData);
    let i: Int32 = 0;
    while i < attachmentsSize {
      attachments = InventoryItemData.GetAttachment(this.m_data.inventoryItemData, i);
      if attachments.SlotID == t"AttachmentSlots.PowerModule" {
        silencerAttachmentSlot = attachments;
      } else {
        if attachments.SlotID == t"AttachmentSlots.Scope" {
          scopeAttachmentSlot = attachments;
        };
      };
      i += 1;
    };
    if TDBID.IsValid(silencerAttachmentSlot.SlotID) {
      inkWidgetRef.SetVisible(this.m_silencerPartWrapper, true);
      inkWidgetRef.SetState(this.m_silencerPartWrapper, InventoryItemData.IsEmpty(silencerAttachmentSlot.ItemData) ? n"Empty" : n"Default");
    } else {
      inkWidgetRef.SetVisible(this.m_silencerPartWrapper, false);
    };
    if TDBID.IsValid(scopeAttachmentSlot.SlotID) {
      inkWidgetRef.SetVisible(this.m_scopePartWrapper, true);
      inkWidgetRef.SetState(this.m_scopePartWrapper, InventoryItemData.IsEmpty(scopeAttachmentSlot.ItemData) ? n"Empty" : n"Default");
    } else {
      inkWidgetRef.SetVisible(this.m_scopePartWrapper, false);
    };
  }

  protected final func UpdateArmor() -> Void {
    let armor: Float;
    let armorDiffValue: Float;
    let armorParams: ref<inkTextParams>;
    let stats: array<InventoryTooltipData_StatData> = this.GetSecondaryStatsData(this.m_data);
    let i: Int32 = 0;
    while i < ArraySize(stats) {
      if Equals(stats[i].statType, gamedataStatType.Armor) {
        armor = stats[i].currentValueF;
        armorDiffValue = stats[i].diffValueF;
      };
      i += 1;
    };
    if armorDiffValue > 0.00 {
      inkImageRef.SetBrushMirrorType(this.m_armorStatArrow, inkBrushMirrorType.NoMirror);
    } else {
      if armorDiffValue < 0.00 {
        inkImageRef.SetBrushMirrorType(this.m_armorStatArrow, inkBrushMirrorType.Vertical);
      };
    };
    inkWidgetRef.SetState(this.m_armorStatArrow, this.GetArrowWrapperState(armorDiffValue));
    inkWidgetRef.SetVisible(this.m_armorStatArrow, armorDiffValue != 0.00);
    armorParams = new inkTextParams();
    armorParams.AddNumber("value", FloorF(armor));
    armorParams.AddNumber("valueDecimalPart", RoundF((armor - Cast(RoundF(armor))) * 10.00) % 10);
    inkTextRef.SetTextParameters(this.m_armorStatLabel, armorParams);
  }

  protected final func UpdateEvolutionDescription() -> Void {
    let evolution: gamedataWeaponEvolution = gamedataWeaponEvolution.Invalid;
    if Equals(InventoryItemData.GetEquipmentArea(this.m_data.inventoryItemData), gamedataEquipmentArea.Weapon) {
      evolution = RPGManager.GetWeaponEvolution(InventoryItemData.GetID(this.m_data.inventoryItemData));
    };
    inkWidgetRef.SetVisible(this.m_nonLethalText, Equals(evolution, gamedataWeaponEvolution.Blunt));
    inkWidgetRef.SetVisible(this.m_weaponEvolutionWrapper, NotEquals(evolution, gamedataWeaponEvolution.Invalid));
    switch evolution {
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

  protected final func UpdateDPS() -> Void {
    let attacksPerSecond: Float;
    let damagePerHit: Float;
    let damagePerHitMax: Float;
    let damagePerHitMin: Float;
    let divideAttacksByPellets: Bool;
    let dpsDiffValue: Float;
    let isShotgun: Bool;
    let projectilesPerShot: Float;
    let dps: Float = -1.00;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(this.m_data.itemID));
    let dpsParams: ref<inkTextParams> = new inkTextParams();
    let damageParams: ref<inkTextParams> = new inkTextParams();
    let attackPerSecondParams: ref<inkTextParams> = new inkTextParams();
    let i: Int32 = 0;
    while i < ArraySize(this.m_data.primaryStats) {
      if Equals(this.m_data.primaryStats[i].statType, gamedataStatType.EffectiveDPS) {
        dps = this.m_data.primaryStats[i].currentValueF;
        dpsDiffValue = this.m_data.primaryStats[i].diffValueF;
      };
      i += 1;
    };
    inkWidgetRef.SetState(this.m_dpsWrapper, this.GetArrowWrapperState(dpsDiffValue));
    inkWidgetRef.SetVisible(this.m_dpsWrapper, dps >= 0.00);
    inkWidgetRef.SetVisible(this.m_dpsArrow, dpsDiffValue != 0.00);
    if dpsDiffValue > 0.00 {
      inkImageRef.SetBrushMirrorType(this.m_dpsArrow, inkBrushMirrorType.NoMirror);
    } else {
      if dpsDiffValue < 0.00 {
        inkImageRef.SetBrushMirrorType(this.m_dpsArrow, inkBrushMirrorType.Vertical);
      };
    };
    dpsParams.AddNumber("value", FloorF(dps));
    dpsParams.AddNumber("valueDecimalPart", RoundF((dps - Cast(RoundF(dps))) * 10.00) % 10);
    inkTextRef.SetTextParameters(this.m_dpsText, dpsParams);
    projectilesPerShot = InventoryItemData.GetGameItemData(this.m_data.inventoryItemData).GetStatValueByType(gamedataStatType.ProjectilesPerShot);
    attacksPerSecond = InventoryItemData.GetGameItemData(this.m_data.inventoryItemData).GetStatValueByType(gamedataStatType.AttacksPerSecond);
    divideAttacksByPellets = TweakDBInterface.GetBool(ItemID.GetTDBID(this.m_data.itemID) + t".divideAttacksByPelletsOnUI", false) && projectilesPerShot > 0.00;
    attackPerSecondParams.AddString("value", FloatToStringPrec(divideAttacksByPellets ? attacksPerSecond / projectilesPerShot : attacksPerSecond, 2));
    inkTextRef.SetLocalizedTextScript(this.m_attacksPerSecondValue, "UI-Tooltips-AttacksPerSecond", attackPerSecondParams);
    damagePerHit = InventoryItemData.GetGameItemData(this.m_data.inventoryItemData).GetStatValueByType(gamedataStatType.EffectiveDamagePerHit);
    if InventoryItemData.GetGameItemData(this.m_data.inventoryItemData).HasTag(n"Melee") {
      inkTextRef.SetText(this.m_damagePerHitValue, "UI-Tooltips-DamagePerHitMeleeTemplate");
      damageParams.AddString("value", IntToString(RoundF(damagePerHit)));
      inkTextRef.SetTextParameters(this.m_damagePerHitValue, damageParams);
      return;
    };
    damagePerHitMin = InventoryItemData.GetGameItemData(this.m_data.inventoryItemData).GetStatValueByType(gamedataStatType.EffectiveDamagePerHitMin);
    damagePerHitMax = InventoryItemData.GetGameItemData(this.m_data.inventoryItemData).GetStatValueByType(gamedataStatType.EffectiveDamagePerHitMax);
    damageParams.AddString("value", IntToString(RoundF(damagePerHitMin)));
    damageParams.AddString("valueMax", IntToString(RoundF(damagePerHitMax)));
    isShotgun = Equals(itemRecord.ItemType().Type(), gamedataItemType.Wea_Shotgun) || Equals(itemRecord.ItemType().Type(), gamedataItemType.Wea_ShotgunDual);
    if isShotgun && projectilesPerShot > 0.00 {
      inkTextRef.SetText(this.m_damagePerHitValue, "UI-Tooltips-DamagePerHitWithMultiplierTemplate");
      damageParams.AddString("multiplier", IntToString(RoundF(projectilesPerShot)));
    } else {
      inkTextRef.SetText(this.m_damagePerHitValue, "UI-Tooltips-DamagePerHitTemplate");
    };
    inkTextRef.SetTextParameters(this.m_damagePerHitValue, damageParams);
  }

  protected final func UpdatePrimmaryStats() -> Void {
    let controller: ref<ItemTooltipStatController>;
    let i: Int32;
    let stat: InventoryTooltipData_StatData;
    if ArraySize(this.m_data.primaryStats) > 0 {
      while inkCompoundRef.GetNumChildren(this.m_primmaryStatsList) > ArraySize(this.m_data.primaryStats) {
        inkCompoundRef.RemoveChildByIndex(this.m_primmaryStatsList, 0);
      };
      while inkCompoundRef.GetNumChildren(this.m_primmaryStatsList) < ArraySize(this.m_data.primaryStats) {
        this.SpawnFromLocal(inkWidgetRef.Get(this.m_primmaryStatsList), n"itemTooltipPrimmaryStatTest");
      };
      i = 0;
      while i < ArraySize(this.m_data.primaryStats) {
        stat = this.m_data.primaryStats[i];
        controller = inkCompoundRef.GetWidgetByIndex(this.m_primmaryStatsList, i).GetController() as ItemTooltipStatController;
        controller.SetData(stat);
        i += 1;
      };
      inkWidgetRef.SetVisible(this.m_primmaryStatsContainer, true);
    } else {
      inkWidgetRef.SetVisible(this.m_primmaryStatsContainer, false);
    };
  }

  protected final func UpdatemRecipeDamageTypes() -> Void {
    let controller: ref<ItemTooltipStatController>;
    let i: Int32;
    let stat: InventoryTooltipData_StatData;
    if ArraySize(this.m_data.randomDamageTypes) > 0 {
      while inkCompoundRef.GetNumChildren(this.m_recipeDamageTypesList) > ArraySize(this.m_data.randomDamageTypes) {
        inkCompoundRef.RemoveChildByIndex(this.m_recipeDamageTypesList, 0);
      };
      while inkCompoundRef.GetNumChildren(this.m_recipeDamageTypesList) < ArraySize(this.m_data.randomDamageTypes) {
        this.SpawnFromLocal(inkWidgetRef.Get(this.m_recipeDamageTypesList), n"itemTooltipSecondaryStatTest");
      };
      i = 0;
      while i < ArraySize(this.m_data.randomDamageTypes) {
        stat = this.m_data.randomDamageTypes[i];
        controller = inkCompoundRef.GetWidgetByIndex(this.m_recipeDamageTypesList, i).GetController() as ItemTooltipStatController;
        controller.SetData(stat);
        i += 1;
      };
      inkWidgetRef.SetVisible(this.m_recipeDamageTypesContainer, true);
    } else {
      inkWidgetRef.SetVisible(this.m_recipeDamageTypesContainer, false);
    };
  }

  protected final func UpdatemRecipeProperties() -> Void {
    let controller: ref<ItemRandomizedStatsController>;
    let statsQuantityParams: ref<inkTextParams>;
    let widget: wref<inkWidget>;
    if ArraySize(this.m_data.recipeAdditionalStats) > 0 {
      statsQuantityParams = new inkTextParams();
      statsQuantityParams.AddString("value", IntToString(this.m_data.randomizedStatQuantity));
      inkTextRef.SetLocalizedText(this.m_recipeStatsTitle, n"UI-Tooltips-RandomStatsNumber", statsQuantityParams);
      if inkCompoundRef.GetNumChildren(this.m_recipeStatsTypesList) == 0 {
        widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_recipeStatsTypesList), n"itemTooltipRecipeStat");
      } else {
        widget = inkCompoundRef.GetWidgetByIndex(this.m_recipeStatsTypesList, 0);
      };
      controller = widget.GetController() as ItemRandomizedStatsController;
      controller.SetData(this.m_data.recipeAdditionalStats);
      inkWidgetRef.SetVisible(this.m_recipeStatsContainer, true);
    } else {
      inkWidgetRef.SetVisible(this.m_recipeStatsContainer, false);
    };
  }

  protected final func GetSecondaryStatsData(data: ref<InventoryTooltipData>) -> array<InventoryTooltipData_StatData> {
    let alreadyAdded: Bool;
    let j: Int32;
    let stats: array<InventoryTooltipData_StatData>;
    let i: Int32 = 0;
    while i < ArraySize(data.additionalStats) {
      alreadyAdded = false;
      j = 0;
      while j < ArraySize(stats) {
        if Equals(stats[j].statType, data.additionalStats[i].statType) {
          alreadyAdded = true;
        } else {
          j += 1;
        };
      };
      if !alreadyAdded {
        ArrayPush(stats, data.additionalStats[i]);
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(data.comparedStats) {
      alreadyAdded = false;
      j = 0;
      while j < ArraySize(stats) {
        if Equals(stats[j].statType, data.comparedStats[i].statType) {
          alreadyAdded = true;
        } else {
          j += 1;
        };
      };
      if !alreadyAdded {
        ArrayPush(stats, data.comparedStats[i]);
      };
      i += 1;
    };
    return stats;
  }

  private final func FilterStatsWithValue(stats: array<InventoryTooltipData_StatData>) -> array<InventoryTooltipData_StatData> {
    let result: array<InventoryTooltipData_StatData>;
    let statTweakID: TweakDBID;
    let i: Int32 = 0;
    while i < ArraySize(stats) {
      statTweakID = TDBID.Create("BaseStats." + EnumValueToString("gamedataStatType", Cast(EnumInt(stats[i].statType))));
      if TweakDBInterface.GetBool(statTweakID + t".roundValue", false) {
        if stats[i].currentValue != 0 {
          ArrayPush(result, stats[i]);
        };
      } else {
        if AbsF(stats[i].currentValueF) > 0.01 {
          ArrayPush(result, stats[i]);
        };
      };
      i += 1;
    };
    return result;
  }

  private final func IsDamageStat(stat: gamedataStatType) -> Bool {
    switch stat {
      case gamedataStatType.ThermalDamage:
      case gamedataStatType.ElectricDamage:
      case gamedataStatType.ChemicalDamage:
      case gamedataStatType.PhysicalDamage:
      case gamedataStatType.BaseDamage:
        return true;
      default:
        return false;
    };
    return false;
  }

  private final func ShouldDisplayGrenadeStat(stat: InventoryTooltipData_StatData) -> Bool {
    return NotEquals(stat.statType, gamedataStatType.Range) && !this.IsDamageStat(stat.statType);
  }

  private final func FilterGrenadeStats(stats: array<InventoryTooltipData_StatData>) -> array<InventoryTooltipData_StatData> {
    let i: Int32;
    let result: array<InventoryTooltipData_StatData>;
    if NotEquals(this.GetItemType(), gamedataItemType.Gad_Grenade) {
      return stats;
    };
    i = 0;
    while i < ArraySize(stats) {
      if this.ShouldDisplayGrenadeStat(stats[i]) {
        ArrayPush(result, stats[i]);
      };
      i += 1;
    };
    return result;
  }

  private final func FilterArmorStat(stats: array<InventoryTooltipData_StatData>) -> array<InventoryTooltipData_StatData> {
    let result: array<InventoryTooltipData_StatData>;
    let i: Int32 = 0;
    while i < ArraySize(stats) {
      if NotEquals(stats[i].statType, gamedataStatType.Armor) {
        ArrayPush(result, stats[i]);
      };
      i += 1;
    };
    return result;
  }

  protected final func UpdateSecondaryStats() -> Void {
    let controller: ref<ItemTooltipStatController>;
    let i: Int32;
    let itemRecord: wref<Item_Record>;
    let shouldDisplayStats: Bool;
    let stats: array<InventoryTooltipData_StatData>;
    let tempWidget: wref<inkWidget>;
    if Equals(this.m_data.displayContext, InventoryTooltipDisplayContext.HUD) && Equals(this.m_data.equipArea, gamedataEquipmentArea.Weapon) {
      inkWidgetRef.SetVisible(this.m_secondaryStatsContainer, false);
      return;
    };
    itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(this.m_data.itemID));
    stats = this.GetSecondaryStatsData(this.m_data);
    stats = this.FilterStatsWithValue(stats);
    shouldDisplayStats = ArraySize(stats) > 0;
    stats = this.FilterGrenadeStats(stats);
    if NotEquals(itemRecord.ItemCategory().Type(), gamedataItemCategory.Part) {
      stats = this.FilterArmorStat(stats);
    };
    inkCompoundRef.RemoveAllChildren(this.m_secondaryStatsList);
    if Equals(this.m_data.displayContext, InventoryTooltipDisplayContext.Crafting) && Equals(itemRecord.EquipArea().Type(), gamedataEquipmentArea.Weapon) {
      return;
    };
    if ArraySize(stats) > 0 {
      i = 0;
      while i < ArraySize(stats) {
        tempWidget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_secondaryStatsList), n"itemTooltipSecondaryStatTest");
        controller = tempWidget.GetController() as ItemTooltipStatController;
        controller.SetData(stats[i]);
        i += 1;
      };
      inkWidgetRef.SetVisible(this.m_secondaryStatsContainer, true);
    } else {
      inkWidgetRef.SetVisible(this.m_secondaryStatsContainer, shouldDisplayStats);
    };
  }

  protected final func UpdateAttachments() -> Void {
    let dedicatedMods: array<InventoryItemAttachments>;
    let genericMods: array<InventoryItemAttachments>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_data.itemAttachments) {
      switch this.m_data.itemAttachments[i].SlotType {
        case InventoryItemAttachmentType.Generic:
          ArrayPush(genericMods, this.m_data.itemAttachments[i]);
          break;
        case InventoryItemAttachmentType.Dedicated:
          ArrayPush(dedicatedMods, this.m_data.itemAttachments[i]);
      };
      i += 1;
    };
    if !(Equals(this.m_data.displayContext, InventoryTooltipDisplayContext.HUD) && Equals(this.m_data.equipArea, gamedataEquipmentArea.Weapon)) {
      this.UpdateMods(genericMods);
    } else {
      inkWidgetRef.SetVisible(this.m_modsContainer, false);
    };
    this.UpdateDedicatedMods(dedicatedMods);
  }

  protected final func UpdateMods(mods: array<InventoryItemAttachments>) -> Void {
    let attachmentsSize: Int32;
    let controller: ref<ItemTooltipModController>;
    let dataPackages: array<wref<GameplayLogicPackage_Record>>;
    let dataPackagesSize: Int32;
    let dataPackagesToDisplay: array<wref<GameplayLogicPackageUIData_Record>>;
    let i: Int32;
    let innerItemData: InnerItemData;
    let totalModsSize: Int32;
    let uiDataPackage: wref<GameplayLogicPackageUIData_Record>;
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(this.m_data.itemID));
    itemRecord.OnEquip(dataPackages);
    i = 0;
    while i < ArraySize(dataPackages) {
      uiDataPackage = dataPackages[i].UIData();
      if IsStringValid(uiDataPackage.LocalizedDescription()) {
        ArrayPush(dataPackagesToDisplay, uiDataPackage);
      };
      i += 1;
    };
    ArrayClear(dataPackages);
    itemRecord.OnAttach(dataPackages);
    i = 0;
    while i < ArraySize(dataPackages) {
      uiDataPackage = dataPackages[i].UIData();
      if IsStringValid(uiDataPackage.LocalizedDescription()) {
        ArrayPush(dataPackagesToDisplay, uiDataPackage);
      };
      i += 1;
    };
    dataPackagesSize = ArraySize(dataPackagesToDisplay);
    attachmentsSize = ArraySize(mods);
    totalModsSize = dataPackagesSize + attachmentsSize;
    if totalModsSize > 0 {
      while inkCompoundRef.GetNumChildren(this.m_modsList) > totalModsSize {
        inkCompoundRef.RemoveChildByIndex(this.m_modsList, 0);
      };
      while inkCompoundRef.GetNumChildren(this.m_modsList) < totalModsSize {
        this.SpawnFromLocal(inkWidgetRef.Get(this.m_modsList), n"itemTooltipMod");
      };
      i = 0;
      while i < dataPackagesSize {
        controller = inkCompoundRef.GetWidgetByIndex(this.m_modsList, i).GetController() as ItemTooltipModController;
        if Equals(this.m_data.displayContext, InventoryTooltipDisplayContext.Attachment) {
          innerItemData = new InnerItemData();
          this.m_data.parentItemData.GetItemPart(innerItemData, this.m_data.slotID);
          controller.SetData(dataPackagesToDisplay[i], innerItemData);
        } else {
          controller.SetData(dataPackagesToDisplay[i], InventoryItemData.GetGameItemData(this.m_data.inventoryItemData));
          controller.HideDotIndicator();
        };
        i += 1;
      };
      if attachmentsSize > 0 || dataPackagesSize > 0 {
        i = 0;
        while i < attachmentsSize {
          controller = inkCompoundRef.GetWidgetByIndex(this.m_modsList, i + dataPackagesSize).GetController() as ItemTooltipModController;
          controller.SetData(mods[i]);
          i += 1;
        };
      };
      inkWidgetRef.SetVisible(this.m_modsContainer, true);
    } else {
      inkWidgetRef.SetVisible(this.m_modsContainer, false);
    };
  }

  protected final func UpdateDedicatedMods(mods: array<InventoryItemAttachments>) -> Void {
    let controller: ref<ItemTooltipModController>;
    let modsToShow: array<InventoryItemAttachments>;
    let i: Int32 = 0;
    while i < ArraySize(mods) {
      if !InventoryItemData.IsEmpty(mods[i].ItemData) {
        ArrayPush(modsToShow, mods[i]);
      };
      i += 1;
    };
    inkWidgetRef.SetVisible(this.m_dedicatedModsContainer, ArraySize(modsToShow) > 0);
    while inkCompoundRef.GetNumChildren(this.m_dedicatedModsList) > ArraySize(modsToShow) {
      inkCompoundRef.RemoveChildByIndex(this.m_dedicatedModsList, 0);
    };
    while inkCompoundRef.GetNumChildren(this.m_dedicatedModsList) < ArraySize(modsToShow) {
      this.SpawnFromLocal(inkWidgetRef.Get(this.m_dedicatedModsList), n"itemTooltipMod");
    };
    i = 0;
    while i < ArraySize(modsToShow) {
      controller = inkCompoundRef.GetWidgetByIndex(this.m_dedicatedModsList, i).GetController() as ItemTooltipModController;
      controller.SetData(modsToShow[i]);
      controller.HideDotIndicator();
      i += 1;
    };
  }

  protected final func UpdateRequirements() -> Void {
    let requirement: SItemStackRequirementData;
    let statRecord: ref<Stat_Record>;
    let statsValue: Float;
    let strenghtValue: Int32;
    let textParams: ref<inkTextParams>;
    inkWidgetRef.SetVisible(this.m_itemRequirements, false);
    inkWidgetRef.SetVisible(this.m_itemLevelRequirements, false);
    inkWidgetRef.SetVisible(this.m_itemStrenghtRequirements, false);
    inkWidgetRef.SetVisible(this.m_itemSmartGunLinkRequirements, false);
    inkWidgetRef.SetVisible(this.m_itemAttributeRequirements, false);
    if RPGManager.HasSmartLinkRequirement(InventoryItemData.GetGameItemData(this.m_data.inventoryItemData)) && !this.m_data.m_HasPlayerSmartGunLink {
      inkWidgetRef.SetVisible(this.m_itemRequirements, true);
      inkWidgetRef.SetVisible(this.m_itemSmartGunLinkRequirements, true);
    };
    statsValue = InventoryItemData.GetGameItemData(this.m_data.inventoryItemData).GetStatValueByType(gamedataStatType.Strength);
    if statsValue > 0.00 && this.m_data.m_PlayerStrenght < RoundF(statsValue) {
      inkWidgetRef.SetVisible(this.m_itemRequirements, true);
      inkWidgetRef.SetVisible(this.m_itemStrenghtRequirements, true);
      textParams = new inkTextParams();
      statRecord = RPGManager.GetStatRecord(gamedataStatType.Strength);
      textParams.AddString("statName", GetLocalizedText(UILocalizationHelper.GetStatNameLockey(statRecord)));
      strenghtValue = RoundF(statsValue);
      textParams.AddNumber("statValue", strenghtValue);
      inkTextRef.SetLocalizedText(this.m_itemStrenghtRequirementsValue, StringToName(GetLocalizedText("LocKey#78420")), textParams);
    };
    statsValue = InventoryItemData.GetGameItemData(this.m_data.inventoryItemData).GetStatValueByType(gamedataStatType.Reflexes);
    if statsValue > 0.00 && this.m_data.m_PlayerReflexes < RoundF(statsValue) {
      inkWidgetRef.SetVisible(this.m_itemRequirements, true);
      inkWidgetRef.SetVisible(this.m_itemStrenghtRequirements, true);
      textParams = new inkTextParams();
      statRecord = RPGManager.GetStatRecord(gamedataStatType.Reflexes);
      textParams.AddString("statName", GetLocalizedText(UILocalizationHelper.GetStatNameLockey(statRecord)));
      strenghtValue = RoundF(statsValue);
      textParams.AddNumber("statValue", strenghtValue);
      inkTextRef.SetLocalizedText(this.m_itemStrenghtRequirementsValue, StringToName(GetLocalizedText("LocKey#78420")), textParams);
    };
    if this.m_data.levelRequired > 0 && this.m_data.m_PlayerLevel < this.m_data.levelRequired {
      inkWidgetRef.SetVisible(this.m_itemRequirements, true);
      inkWidgetRef.SetVisible(this.m_itemLevelRequirements, true);
      inkTextRef.SetText(this.m_itemLevelRequirementsValue, IntToString(this.m_data.levelRequired));
    };
    if !InventoryItemData.IsEmpty(this.m_data.inventoryItemData) {
      requirement = InventoryItemData.GetRequirement(this.m_data.inventoryItemData);
      if NotEquals(requirement.statType, gamedataStatType.Invalid) && !InventoryItemData.IsRequirementMet(this.m_data.inventoryItemData) {
        inkWidgetRef.SetVisible(this.m_itemRequirements, true);
        inkWidgetRef.SetVisible(this.m_itemAttributeRequirements, true);
        textParams = new inkTextParams();
        textParams.AddNumber("value", RoundF(requirement.requiredValue));
        statRecord = RPGManager.GetStatRecord(requirement.statType);
        textParams.AddString("statName", GetLocalizedText(UILocalizationHelper.GetStatNameLockey(statRecord)));
        textParams.AddString("statColor", "StatTypeColor." + EnumValueToString("gamedataStatType", Cast(EnumInt(requirement.statType))));
        inkTextRef.SetLocalizedTextScript(this.m_itemAttributeRequirementsText, "LocKey#49215", textParams);
      };
    };
    if !InventoryItemData.IsEquippable(this.m_data.inventoryItemData) {
      inkWidgetRef.SetVisible(this.m_itemRequirements, true);
      inkWidgetRef.SetVisible(this.m_itemAttributeRequirements, true);
      requirement = InventoryItemData.GetEquipRequirement(this.m_data.inventoryItemData);
      textParams = new inkTextParams();
      textParams.AddNumber("value", RoundF(requirement.requiredValue));
      statRecord = RPGManager.GetStatRecord(requirement.statType);
      textParams.AddString("statName", GetLocalizedText(UILocalizationHelper.GetStatNameLockey(statRecord)));
      textParams.AddString("statColor", "StatTypeColor." + EnumValueToString("gamedataStatType", Cast(EnumInt(requirement.statType))));
      inkTextRef.SetLocalizedTextScript(this.m_itemAttributeRequirementsText, "LocKey#77652", textParams);
    };
  }

  protected final func UpdateDescription() -> Void {
    if IsStringValid(this.m_data.description) {
      inkTextRef.SetLocalizedTextScript(this.m_descriptionText, this.m_data.description);
      inkWidgetRef.SetVisible(this.m_descriptionContainer, true);
    } else {
      inkWidgetRef.SetVisible(this.m_descriptionContainer, false);
    };
  }

  protected final func UpdateWeight() -> Void {
    let weight: Float = InventoryItemData.GetGameItemData(this.m_data.inventoryItemData).GetStatValueByType(gamedataStatType.Weight);
    inkTextRef.SetText(this.m_requireLevelText, FloatToStringPrec(weight, 2));
  }

  protected final func UpdateRequiredLevel() -> Void;

  protected final func UpdatePrice() -> Void {
    if Equals(this.m_data.itemType, gamedataItemType.Wea_Fists) {
      inkTextRef.SetText(this.m_priceText, "N/A");
    } else {
      if this.m_data.isVendorItem {
        inkTextRef.SetText(this.m_priceText, FloatToStringPrec(this.m_data.buyPrice, 0));
      } else {
        inkTextRef.SetText(this.m_priceText, FloatToStringPrec(this.m_data.price, 0));
      };
    };
    inkWidgetRef.SetVisible(this.m_priceContainer, true);
  }

  protected final func UpdateCraftedIcon() -> Void {
    let isCrafted: Bool = RPGManager.IsItemCrafted(InventoryItemData.GetGameItemData(this.m_data.inventoryItemData)) && NotEquals(this.m_data.displayContext, InventoryTooltipDisplayContext.Crafting);
    inkWidgetRef.SetVisible(this.m_craftedItemIcon, isCrafted);
    inkWidgetRef.SetVisible(this.m_craftedItemContainer, isCrafted);
  }

  protected final func GetItemType() -> gamedataItemType {
    if NotEquals(this.m_data.itemType, gamedataItemType.Invalid) {
      return this.m_data.itemType;
    };
    return InventoryItemData.GetItemType(this.m_data.inventoryItemData);
  }
}
