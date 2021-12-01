
public class InventoryTooltipData extends ATooltipData {

  public let itemID: ItemID;

  public let isEquipped: Bool;

  public let isLocked: Bool;

  public let isVendorItem: Bool;

  public let isCraftable: Bool;

  public let qualityStateName: CName;

  public let description: String;

  public let additionalDescription: String;

  public let category: String;

  public let quality: String;

  public let itemName: String;

  public let price: Float;

  public let buyPrice: Float;

  public let unlockProgress: Float;

  public let primaryStats: array<InventoryTooltipData_StatData>;

  public let comparedStats: array<InventoryTooltipData_StatData>;

  public let additionalStats: array<InventoryTooltipData_StatData>;

  public let randomDamageTypes: array<InventoryTooltipData_StatData>;

  public let recipeAdditionalStats: array<InventoryTooltipData_StatData>;

  public let damageType: gamedataDamageType;

  public let isBroken: Bool;

  public let levelRequired: Int32;

  public let attachments: array<CName>;

  public let specialAbilities: array<InventoryItemAbility>;

  public let equipArea: gamedataEquipmentArea;

  public let showCyclingDots: Bool;

  public let numberOfCyclingDots: Int32;

  public let selectedCyclingDot: Int32;

  public let comparedQuality: gamedataQuality;

  public let showIcon: Bool;

  public let randomizedStatQuantity: Int32;

  @default(InventoryTooltipData, gamedataItemType.Invalid)
  public let itemType: gamedataItemType;

  public let m_HasPlayerSmartGunLink: Bool;

  public let m_PlayerLevel: Int32;

  public let m_PlayerStrenght: Int32;

  public let m_PlayerReflexes: Int32;

  public let m_PlayerStreetCred: Int32;

  public let itemAttachments: array<InventoryItemAttachments>;

  public let inventoryItemData: InventoryItemData;

  public let overrideRarity: Bool;

  public let quickhackData: InventoryTooltipData_QuickhackData;

  public let grenadeData: ref<InventoryTooltiData_GrenadeData>;

  public let displayContext: InventoryTooltipDisplayContext;

  public let parentItemData: wref<gameItemData>;

  public let slotID: TweakDBID;

  public let DEBUG_iconErrorInfo: ref<DEBUG_IconErrorInfo>;

  public final static func FromItemViewData(itemViewData: ItemViewData) -> ref<InventoryTooltipData> {
    let outObject: ref<InventoryTooltipData> = new InventoryTooltipData();
    outObject.isCraftable = false;
    outObject.qualityStateName = UIItemsHelper.QualityStringToStateName(itemViewData.quality);
    outObject.description = itemViewData.description;
    outObject.category = itemViewData.categoryName;
    outObject.quality = itemViewData.quality;
    outObject.itemName = itemViewData.itemName;
    outObject.price = itemViewData.price;
    outObject.isBroken = itemViewData.isBroken;
    outObject.FillPrimaryStats(itemViewData.primaryStats);
    outObject.FillDetailedStats(itemViewData.secondaryStats);
    outObject.comparedQuality = itemViewData.comparedQuality;
    return outObject;
  }

  public final func FillPrimaryStats(rawStats: array<StatViewData>) -> Void {
    let currStatViewData: StatViewData;
    let maxStat: Int32;
    let maxStatF: Float;
    let parsedStat: InventoryTooltipData_StatData;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(rawStats);
    while i < limit {
      currStatViewData = rawStats[i];
      maxStat = 100;
      maxStatF = 100.00;
      parsedStat = new InventoryTooltipData_StatData(currStatViewData.type, currStatViewData.statName, Min(Max(currStatViewData.statMinValue, 0), currStatViewData.value), Max(Min(currStatViewData.statMaxValue, maxStat), currStatViewData.value), currStatViewData.value, currStatViewData.diffValue, MinF(MaxF(currStatViewData.statMinValueF, 0.00), currStatViewData.valueF), MaxF(MinF(currStatViewData.statMaxValueF, maxStatF), currStatViewData.valueF), currStatViewData.valueF, currStatViewData.diffValueF, EInventoryDataStatDisplayType.Value);
      ArrayPush(this.primaryStats, parsedStat);
      i += 1;
    };
  }

  public final func FillRecipeDamageTypeData(gi: GameInstance, itemData: wref<gameItemData>) -> Void {
    let localizedName: String;
    let parsedStat: InventoryTooltipData_StatData;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(gi);
    let damage: gamedataDamageType = RPGManager.GetDominatingDamageType(gi, itemData);
    let baseDamage: Float = itemData.GetStatValueByType(statsSystem.GetStatType(damage));
    let i: Int32 = 0;
    while i < EnumInt(gamedataDamageType.Count) {
      damage = IntEnum(i);
      localizedName = statsSystem.GetDamageRecordFromType(damage).AssociatedStat().LocalizedName();
      parsedStat = new InventoryTooltipData_StatData(statsSystem.GetStatType(damage), localizedName, 0, 0, 0, 0, baseDamage, baseDamage, baseDamage, baseDamage, EInventoryDataStatDisplayType.Value);
      ArrayPush(this.randomDamageTypes, parsedStat);
      i += 1;
    };
  }

  public final func FillRecipeStatsData(rawStats: array<wref<Stat_Record>>) -> Void {
    let currStat: ref<Stat_Record>;
    let parsedStat: InventoryTooltipData_StatData;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(rawStats);
    while i < limit {
      currStat = rawStats[i];
      parsedStat = new InventoryTooltipData_StatData(currStat.StatType(), currStat.LocalizedName(), 0, 0, 0, 0, 0.00, 0.00, 0.00, 0.00, EInventoryDataStatDisplayType.Value);
      ArrayPush(this.recipeAdditionalStats, parsedStat);
      i += 1;
    };
  }

  public final func FillDetailedStats(rawStats: array<StatViewData>, opt isIconicRecipe: Bool) -> Void {
    let currStatViewData: StatViewData;
    let maxStat: Int32;
    let maxStatF: Float;
    let parsedStat: InventoryTooltipData_StatData;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(rawStats);
    while i < limit {
      currStatViewData = rawStats[i];
      maxStat = 100;
      maxStatF = 100.00;
      if currStatViewData.isCompared {
        if currStatViewData.diffValue < 0 {
          maxStat = Max(maxStat, currStatViewData.value - currStatViewData.diffValue);
          maxStatF = MaxF(maxStatF, currStatViewData.valueF - currStatViewData.diffValueF);
        };
        parsedStat = new InventoryTooltipData_StatData(currStatViewData.type, currStatViewData.statName, Min(Max(currStatViewData.statMinValue, 0), currStatViewData.value), Max(Min(currStatViewData.statMaxValue, maxStat), currStatViewData.value), currStatViewData.value, currStatViewData.diffValue, MinF(MaxF(currStatViewData.statMinValueF, 0.00), currStatViewData.valueF), MaxF(MinF(currStatViewData.statMaxValueF, maxStatF), currStatViewData.valueF), currStatViewData.valueF, currStatViewData.diffValueF, currStatViewData.canBeCompared ? EInventoryDataStatDisplayType.CompareBar : EInventoryDataStatDisplayType.Value);
      } else {
        parsedStat = new InventoryTooltipData_StatData(currStatViewData.type, currStatViewData.statName, Min(Max(currStatViewData.statMinValue, 0), currStatViewData.value), Max(Min(currStatViewData.statMaxValue, maxStat), currStatViewData.value), currStatViewData.value, 0, MinF(MaxF(currStatViewData.statMinValueF, 0.00), currStatViewData.valueF), MaxF(MinF(currStatViewData.statMaxValueF, maxStatF), currStatViewData.valueF), currStatViewData.valueF, 0.00, currStatViewData.canBeCompared ? EInventoryDataStatDisplayType.DisplayBar : EInventoryDataStatDisplayType.Value);
      };
      if isIconicRecipe && !this.IsElementalDamageType(parsedStat.statType) {
      } else {
        if currStatViewData.canBeCompared {
          ArrayPush(this.comparedStats, parsedStat);
        } else {
          ArrayPush(this.additionalStats, parsedStat);
        };
      };
      i += 1;
    };
  }

  private final func IsElementalDamageType(statType: gamedataStatType) -> Bool {
    switch statType {
      case gamedataStatType.PhysicalDamage:
      case gamedataStatType.ElectricDamage:
      case gamedataStatType.ThermalDamage:
      case gamedataStatType.ChemicalDamage:
        return true;
    };
    return false;
  }

  public final static func FromInventoryItemData(itemData: InventoryItemData) -> ref<InventoryTooltipData> {
    let attachmentName: CName;
    let attachments: InventoryItemAttachments;
    let attachmentsSize: Int32;
    let i: Int32;
    let limit: Int32;
    let outObject: ref<InventoryTooltipData> = new InventoryTooltipData();
    outObject.itemID = InventoryItemData.GetID(itemData);
    outObject.isCraftable = false;
    outObject.qualityStateName = InventoryItemData.GetQuality(itemData);
    outObject.description = InventoryItemData.GetDescription(itemData);
    outObject.additionalDescription = InventoryItemData.GetAdditionalDescription(itemData);
    outObject.isBroken = InventoryItemData.IsBroken(itemData);
    outObject.isVendorItem = InventoryItemData.IsVendorItem(itemData);
    outObject.category = InventoryItemData.GetCategoryName(itemData);
    outObject.quality = NameToString(InventoryItemData.GetQuality(itemData));
    outObject.levelRequired = InventoryItemData.GetRequiredLevel(itemData);
    outObject.itemName = InventoryItemData.GetName(itemData);
    outObject.price = InventoryItemData.GetPrice(itemData);
    outObject.buyPrice = InventoryItemData.GetBuyPrice(itemData);
    outObject.FillPrimaryStats(InventoryItemData.GetPrimaryStats(itemData));
    outObject.FillDetailedStats(InventoryItemData.GetSecondaryStats(itemData));
    outObject.comparedQuality = InventoryItemData.GetComparedQuality(itemData);
    outObject.damageType = InventoryItemData.GetDamageType(itemData);
    outObject.equipArea = InventoryItemData.GetEquipmentArea(itemData);
    outObject.itemType = InventoryItemData.GetItemType(itemData);
    outObject.m_HasPlayerSmartGunLink = InventoryItemData.HasPlayerSmartGunLink(itemData);
    outObject.m_PlayerLevel = InventoryItemData.GetPlayerLevel(itemData);
    outObject.m_PlayerStrenght = InventoryItemData.GetPlayerStrenght(itemData);
    outObject.m_PlayerReflexes = InventoryItemData.GetPlayerReflexes(itemData);
    outObject.m_PlayerStreetCred = InventoryItemData.GetPlayerStreetCred(itemData);
    outObject.isEquipped = InventoryItemData.IsEquipped(itemData);
    attachmentsSize = InventoryItemData.GetAttachmentsSize(itemData);
    i = 0;
    limit = attachmentsSize;
    while i < limit {
      attachmentName = n"";
      attachments = InventoryItemData.GetAttachment(itemData, i);
      if !InventoryItemData.IsEmpty(attachments.ItemData) {
        attachmentName = InventoryItemData.GetQuality(attachments.ItemData);
      };
      ArrayPush(outObject.attachments, attachmentName);
      i += 1;
    };
    outObject.specialAbilities = InventoryItemData.GetAbilities(itemData);
    outObject.itemAttachments = InventoryItemData.GetAttachments(itemData);
    outObject.inventoryItemData = itemData;
    return outObject;
  }

  public final static func FromRecipeAndItemData(context: GameInstance, recipe: ref<RecipeData>, itemData: InventoryItemData, recipeOutcome: InventoryItemData, recipeGameItemData: wref<gameItemData>) -> ref<InventoryTooltipData> {
    let attachmentName: CName;
    let attachments: InventoryItemAttachments;
    let attachmentsSize: Int32;
    let i: Int32;
    let limit: Int32;
    let stats: array<wref<Stat_Record>>;
    let weaponEvolution: gamedataWeaponEvolution;
    let itemRecord: wref<Item_Record> = recipe.id;
    let outObject: ref<InventoryTooltipData> = InventoryTooltipData.FromInventoryItemData(recipeOutcome);
    if Equals(InventoryItemData.GetEquipmentArea(itemData), gamedataEquipmentArea.Weapon) {
      weaponEvolution = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(itemData))).Evolution().Type();
      stats = RPGManager.GetListOfRandomStatsFromEvolutionType(weaponEvolution);
      outObject.FillRecipeStatsData(stats);
      if !RPGManager.IsItemIconic(recipeGameItemData) {
        outObject.FillRecipeDamageTypeData(context, recipeGameItemData);
      };
      outObject.randomizedStatQuantity = 1;
    };
    if !IsStringValid(outObject.itemName) {
      outObject.itemName = LocKeyToString(itemRecord.DisplayName());
    };
    outObject.itemID = InventoryItemData.GetID(itemData);
    outObject.isCraftable = true;
    if !InventoryItemData.IsEmpty(recipeOutcome) {
      outObject.qualityStateName = InventoryItemData.GetQuality(recipeOutcome);
    } else {
      outObject.qualityStateName = InventoryItemData.GetQuality(itemData);
    };
    outObject.quality = NameToString(outObject.qualityStateName);
    outObject.category = InventoryItemData.GetCategoryName(itemData);
    outObject.equipArea = InventoryItemData.GetEquipmentArea(itemData);
    outObject.itemType = InventoryItemData.GetItemType(itemData);
    outObject.description = InventoryItemData.GetDescription(itemData);
    outObject.additionalDescription = InventoryItemData.GetAdditionalDescription(itemData);
    outObject.isBroken = InventoryItemData.IsBroken(itemData);
    outObject.isVendorItem = InventoryItemData.IsVendorItem(itemData);
    outObject.levelRequired = InventoryItemData.GetRequiredLevel(itemData);
    outObject.price = InventoryItemData.GetPrice(recipeOutcome);
    outObject.buyPrice = InventoryItemData.GetBuyPrice(recipeOutcome);
    outObject.FillPrimaryStats(InventoryItemData.GetPrimaryStats(recipeOutcome));
    if Equals(InventoryItemData.GetEquipmentArea(itemData), gamedataEquipmentArea.Weapon) && RPGManager.IsItemIconic(recipeGameItemData) {
      ArrayClear(outObject.additionalStats);
      outObject.FillDetailedStats(InventoryItemData.GetSecondaryStats(recipeOutcome), true);
    } else {
      outObject.FillDetailedStats(InventoryItemData.GetSecondaryStats(recipeOutcome));
    };
    outObject.comparedQuality = InventoryItemData.GetComparedQuality(itemData);
    outObject.damageType = InventoryItemData.GetDamageType(itemData);
    outObject.m_HasPlayerSmartGunLink = InventoryItemData.HasPlayerSmartGunLink(itemData);
    outObject.m_PlayerLevel = InventoryItemData.GetPlayerLevel(itemData);
    outObject.m_PlayerStrenght = InventoryItemData.GetPlayerStrenght(itemData);
    outObject.m_PlayerStreetCred = InventoryItemData.GetPlayerStreetCred(itemData);
    outObject.inventoryItemData = itemData;
    attachmentsSize = InventoryItemData.GetAttachmentsSize(recipeOutcome);
    i = 0;
    limit = attachmentsSize;
    while i < limit {
      attachmentName = n"";
      attachments = InventoryItemData.GetAttachment(recipeOutcome, i);
      if !InventoryItemData.IsEmpty(attachments.ItemData) {
        attachmentName = InventoryItemData.GetQuality(attachments.ItemData);
      };
      ArrayPush(outObject.attachments, attachmentName);
      i += 1;
    };
    outObject.specialAbilities = InventoryItemData.GetAbilities(recipeOutcome);
    outObject.itemAttachments = InventoryItemData.GetAttachments(recipeOutcome);
    outObject.displayContext = InventoryTooltipDisplayContext.Crafting;
    outObject.inventoryItemData = recipeOutcome;
    outObject.overrideRarity = true;
    return outObject;
  }

  public final func ToCollapsedVersion() -> Void {
    if Equals(this.equipArea, gamedataEquipmentArea.Weapon) {
      this.description = "";
      this.additionalDescription = "";
    };
  }

  public final func SetCyclingDots(selectedDot: Int32, numberOfDots: Int32) -> Void {
    if numberOfDots > 1 {
      this.showCyclingDots = true;
      this.selectedCyclingDot = selectedDot;
      this.numberOfCyclingDots = numberOfDots;
    } else {
      this.showCyclingDots = false;
      this.selectedCyclingDot = 0;
      this.numberOfCyclingDots = 0;
    };
  }
}
