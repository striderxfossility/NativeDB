
public class MinimalItemTooltipData extends ATooltipData {

  public let itemID: ItemID;

  public let itemTweakID: TweakDBID;

  public let itemData: wref<gameItemData>;

  public let itemName: String;

  public let quality: gamedataQuality;

  public let quantity: Int32;

  public let description: CName;

  public let weight: Float;

  public let price: Float;

  public let dpsValue: Float;

  public let dpsDiff: Float;

  public let armorValue: Float;

  public let armorDiff: Float;

  public let compareDPS: Bool;

  public let compareArmor: Bool;

  public let attackSpeed: Float;

  public let projectilesPerShot: Float;

  public let grenadeData: ref<InventoryTooltiData_GrenadeData>;

  public let ammoCount: Int32;

  public let hasSilencer: Bool;

  public let hasScope: Bool;

  public let isSilencerInstalled: Bool;

  public let isScopeInstalled: Bool;

  public let requirements: ref<MinimalItemTooltipDataRequirements>;

  public let recipeData: ref<MinimalItemTooltipRecipeData>;

  public let stats: array<ref<MinimalItemTooltipStatData>>;

  public let mods: array<ref<MinimalItemTooltipModData>>;

  public let dedicatedMods: array<ref<MinimalItemTooltipModAttachmentData>>;

  @default(MinimalItemTooltipData, gamedataItemType.Invalid)
  public let itemType: gamedataItemType;

  public let itemCategory: gamedataItemCategory;

  @default(MinimalItemTooltipData, gamedataEquipmentArea.Invalid)
  public let equipmentArea: gamedataEquipmentArea;

  @default(MinimalItemTooltipData, gamedataWeaponEvolution.Invalid)
  public let itemEvolution: gamedataWeaponEvolution;

  public let lootItemType: LootItemType;

  public let iconPath: String;

  public let useMaleIcon: Bool;

  public let isIconic: Bool;

  public let isCrafted: Bool;

  public let isEquipped: Bool;

  public let displayContext: InventoryTooltipDisplayContext;

  public let DEBUG_iconErrorInfo: ref<DEBUG_IconErrorInfo>;

  public final static func FromInventoryItemData(itemData: script_ref<InventoryItemData>) -> ref<MinimalItemTooltipData> {
    return null;
  }

  public final static func FromInventoryTooltipData(tooltipData: ref<InventoryTooltipData>) -> ref<MinimalItemTooltipData> {
    let armorFound: Bool;
    let attachments: InventoryItemAttachments;
    let attachmentsSize: Int32;
    let i: Int32;
    let itemRecord: wref<Item_Record>;
    let result: ref<MinimalItemTooltipData>;
    let scopeAttachmentSlot: InventoryItemAttachments;
    let silencerAttachmentSlot: InventoryItemAttachments;
    if tooltipData == null || !ItemID.IsValid(tooltipData.itemID) {
      return null;
    };
    result = new MinimalItemTooltipData();
    result.itemID = tooltipData.itemID;
    result.itemTweakID = ItemID.GetTDBID(tooltipData.itemID);
    result.itemData = InventoryItemData.GetGameItemData(tooltipData.inventoryItemData);
    itemRecord = TweakDBInterface.GetItemRecord(result.itemTweakID);
    result.itemCategory = itemRecord.ItemCategory().Type();
    result.itemType = NotEquals(tooltipData.itemType, gamedataItemType.Invalid) ? tooltipData.itemType : InventoryItemData.GetItemType(tooltipData.inventoryItemData);
    result.equipmentArea = InventoryItemData.GetEquipmentArea(tooltipData.inventoryItemData);
    if Equals(result.equipmentArea, gamedataEquipmentArea.Weapon) {
      result.itemEvolution = RPGManager.GetWeaponEvolution(result.itemID);
    };
    result.lootItemType = InventoryItemData.GetLootItemType(tooltipData.inventoryItemData);
    result.itemName = UIItemsHelper.GetTooltipItemName(result.itemTweakID, result.itemData, tooltipData.itemName);
    result.isIconic = RPGManager.IsItemIconic(result.itemData);
    result.isCrafted = RPGManager.IsItemCrafted(result.itemData);
    if tooltipData.overrideRarity {
      result.quality = UIItemsHelper.QualityNameToEnum(StringToName(tooltipData.quality));
    } else {
      result.quality = RPGManager.GetItemDataQuality(result.itemData);
    };
    result.useMaleIcon = Equals(InventoryItemData.GetIconGender(tooltipData.inventoryItemData), ItemIconGender.Male);
    result.iconPath = InventoryItemData.GetIconPath(tooltipData.inventoryItemData);
    if Equals(result.equipmentArea, gamedataEquipmentArea.Weapon) {
      i = 0;
      while i < ArraySize(tooltipData.primaryStats) {
        if Equals(tooltipData.primaryStats[i].statType, gamedataStatType.EffectiveDPS) {
          result.dpsValue = tooltipData.primaryStats[i].currentValueF;
          result.dpsDiff = tooltipData.primaryStats[i].diffValueF;
        };
        i += 1;
      };
      result.attackSpeed = result.itemData.GetStatValueByType(gamedataStatType.AttacksPerSecond);
      result.projectilesPerShot = result.itemData.GetStatValueByType(gamedataStatType.ProjectilesPerShot);
      attachmentsSize = InventoryItemData.GetAttachmentsSize(tooltipData.inventoryItemData);
      i = 0;
      while i < attachmentsSize {
        attachments = InventoryItemData.GetAttachment(tooltipData.inventoryItemData, i);
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
        result.hasSilencer = true;
        result.isSilencerInstalled = !InventoryItemData.IsEmpty(silencerAttachmentSlot.ItemData);
      };
      if TDBID.IsValid(scopeAttachmentSlot.SlotID) {
        result.hasScope = true;
        result.isScopeInstalled = !InventoryItemData.IsEmpty(scopeAttachmentSlot.ItemData);
      };
      result.ammoCount = InventoryItemData.GetAmmo(tooltipData.inventoryItemData);
    } else {
      if Equals(result.itemCategory, gamedataItemCategory.Clothing) {
        i = 0;
        while i < ArraySize(tooltipData.comparedStats) {
          if Equals(tooltipData.comparedStats[i].statType, gamedataStatType.Armor) {
            result.armorValue = tooltipData.comparedStats[i].currentValueF;
            result.armorDiff = tooltipData.comparedStats[i].diffValueF;
            armorFound = true;
          } else {
            i += 1;
          };
        };
        if !armorFound {
          i = 0;
          while i < ArraySize(tooltipData.additionalStats) {
            if Equals(tooltipData.additionalStats[i].statType, gamedataStatType.Armor) {
              result.armorValue = tooltipData.additionalStats[i].currentValueF;
              result.armorDiff = tooltipData.additionalStats[i].diffValueF;
            } else {
              i += 1;
            };
          };
        };
      } else {
        if Equals(result.itemType, gamedataItemType.Gad_Grenade) {
          result.grenadeData = tooltipData.grenadeData;
        };
      };
    };
    result.displayContext = tooltipData.displayContext;
    result.description = StringToName(tooltipData.description);
    result.price = tooltipData.isVendorItem ? tooltipData.buyPrice : tooltipData.price;
    result.weight = result.itemData.GetStatValueByType(gamedataStatType.Weight);
    result.isEquipped = tooltipData.isEquipped;
    result.requirements = MinimalItemTooltipData.GetMinimalTooltipDataRequirements(result.itemData, tooltipData);
    if Equals(result.displayContext, InventoryTooltipDisplayContext.Crafting) && !result.isIconic || Equals(result.displayContext, InventoryTooltipDisplayContext.Upgrading) {
      result.recipeData = new MinimalItemTooltipRecipeData();
      result.recipeData.statsNumber = tooltipData.randomizedStatQuantity;
      result.recipeData.damageTypes = tooltipData.randomDamageTypes;
      result.recipeData.recipeStats = tooltipData.recipeAdditionalStats;
    } else {
      if Equals(result.displayContext, InventoryTooltipDisplayContext.Crafting) && result.isIconic {
        result.recipeData = new MinimalItemTooltipRecipeData();
        result.recipeData.statsNumber = tooltipData.randomizedStatQuantity;
        result.recipeData.recipeStats = tooltipData.recipeAdditionalStats;
        result.stats = MinimalItemTooltipData.GetSecondaryStatsFromTooltipData(tooltipData, result.itemCategory, true);
      } else {
        result.stats = MinimalItemTooltipData.GetSecondaryStatsFromTooltipData(tooltipData, result.itemCategory, true);
      };
    };
    MinimalItemTooltipData.FillModsFromTooltipData(tooltipData, result.mods, result.dedicatedMods);
    return result;
  }

  private final static func ShouldFilterOutGrenadeStat(stat: gamedataStatType) -> Bool {
    switch stat {
      case gamedataStatType.ThermalDamage:
      case gamedataStatType.ElectricDamage:
      case gamedataStatType.ChemicalDamage:
      case gamedataStatType.PhysicalDamage:
      case gamedataStatType.BaseDamage:
      case gamedataStatType.Range:
        return true;
      default:
        return false;
    };
    return false;
  }

  public final static func GetSecondaryStatsFromTooltipData(data: ref<InventoryTooltipData>, itemCategory: gamedataItemCategory, opt filterZero: Bool) -> array<ref<MinimalItemTooltipStatData>> {
    let currentValue: Float;
    let pushedStats: array<gamedataStatType>;
    let result: array<ref<MinimalItemTooltipStatData>>;
    let roundValue: Bool;
    let stat: ref<MinimalItemTooltipStatData>;
    let statsTweakID: TweakDBID;
    let i: Int32 = 0;
    while i < ArraySize(data.additionalStats) {
      if !ArrayContains(pushedStats, data.additionalStats[i].statType) {
        statsTweakID = TDBID.Create("BaseStats." + EnumValueToString("gamedataStatType", Cast(EnumInt(data.additionalStats[i].statType))));
        roundValue = TweakDBInterface.GetBool(statsTweakID + t".roundValue", false);
        currentValue = data.additionalStats[i].currentValueF;
        if filterZero && roundValue ? RoundF(currentValue) <= 0 : AbsF(currentValue) <= 0.01 {
        } else {
          if NotEquals(itemCategory, gamedataItemCategory.Part) && Equals(data.additionalStats[i].statType, gamedataStatType.Armor) {
          } else {
            if Equals(data.itemType, gamedataItemType.Gad_Grenade) {
              if MinimalItemTooltipData.ShouldFilterOutGrenadeStat(data.additionalStats[i].statType) {
              } else {
                stat = new MinimalItemTooltipStatData();
                stat.type = data.additionalStats[i].statType;
                stat.statName = data.additionalStats[i].statName;
                stat.value = currentValue;
                stat.diff = data.additionalStats[i].diffValueF;
                stat.isPercentage = TweakDBInterface.GetBool(statsTweakID + t".isPercentage", false);
                stat.roundValue = roundValue;
                stat.displayPlus = TweakDBInterface.GetBool(statsTweakID + t".displayPlus", false);
                stat.inMeters = TweakDBInterface.GetBool(statsTweakID + t".inMeters", false);
                stat.inSeconds = TweakDBInterface.GetBool(statsTweakID + t".inSeconds", false);
                ArrayPush(result, stat);
                ArrayPush(pushedStats, stat.type);
              };
            };
            stat = new MinimalItemTooltipStatData();
            stat.type = data.additionalStats[i].statType;
            stat.statName = data.additionalStats[i].statName;
            stat.value = currentValue;
            stat.diff = data.additionalStats[i].diffValueF;
            stat.isPercentage = TweakDBInterface.GetBool(statsTweakID + t".isPercentage", false);
            stat.roundValue = roundValue;
            stat.displayPlus = TweakDBInterface.GetBool(statsTweakID + t".displayPlus", false);
            stat.inMeters = TweakDBInterface.GetBool(statsTweakID + t".inMeters", false);
            stat.inSeconds = TweakDBInterface.GetBool(statsTweakID + t".inSeconds", false);
            ArrayPush(result, stat);
            ArrayPush(pushedStats, stat.type);
          };
        };
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(data.comparedStats) {
      if !ArrayContains(pushedStats, data.comparedStats[i].statType) {
        statsTweakID = TDBID.Create("BaseStats." + EnumValueToString("gamedataStatType", Cast(EnumInt(data.comparedStats[i].statType))));
        roundValue = TweakDBInterface.GetBool(statsTweakID + t".roundValue", false);
        currentValue = data.comparedStats[i].currentValueF;
        if NotEquals(itemCategory, gamedataItemCategory.Part) && Equals(data.comparedStats[i].statType, gamedataStatType.Armor) {
        } else {
          if Equals(data.itemType, gamedataItemType.Gad_Grenade) {
            if MinimalItemTooltipData.ShouldFilterOutGrenadeStat(data.comparedStats[i].statType) {
            } else {
              stat = new MinimalItemTooltipStatData();
              stat.type = data.comparedStats[i].statType;
              stat.statName = data.comparedStats[i].statName;
              stat.value = currentValue;
              stat.diff = data.comparedStats[i].diffValueF;
              statsTweakID = TDBID.Create("BaseStats." + EnumValueToString("gamedataStatType", Cast(EnumInt(stat.type))));
              stat.isPercentage = TweakDBInterface.GetBool(statsTweakID + t".isPercentage", false);
              stat.roundValue = roundValue;
              stat.displayPlus = TweakDBInterface.GetBool(statsTweakID + t".displayPlus", false);
              stat.inMeters = TweakDBInterface.GetBool(statsTweakID + t".inMeters", false);
              stat.inSeconds = TweakDBInterface.GetBool(statsTweakID + t".inSeconds", false);
              ArrayPush(result, stat);
              ArrayPush(pushedStats, stat.type);
            };
          };
          stat = new MinimalItemTooltipStatData();
          stat.type = data.comparedStats[i].statType;
          stat.statName = data.comparedStats[i].statName;
          stat.value = currentValue;
          stat.diff = data.comparedStats[i].diffValueF;
          statsTweakID = TDBID.Create("BaseStats." + EnumValueToString("gamedataStatType", Cast(EnumInt(stat.type))));
          stat.isPercentage = TweakDBInterface.GetBool(statsTweakID + t".isPercentage", false);
          stat.roundValue = roundValue;
          stat.displayPlus = TweakDBInterface.GetBool(statsTweakID + t".displayPlus", false);
          stat.inMeters = TweakDBInterface.GetBool(statsTweakID + t".inMeters", false);
          stat.inSeconds = TweakDBInterface.GetBool(statsTweakID + t".inSeconds", false);
          ArrayPush(result, stat);
          ArrayPush(pushedStats, stat.type);
        };
      };
      i += 1;
    };
    return result;
  }

  public final static func FillModsFromTooltipData(data: ref<InventoryTooltipData>, out mods: array<ref<MinimalItemTooltipModData>>, out dedicatedMods: array<ref<MinimalItemTooltipModAttachmentData>>) -> Void {
    let attachmentData: ref<MinimalItemTooltipModAttachmentData>;
    let i: Int32;
    let limit: Int32;
    let packages: array<ref<MinimalItemTooltipModData>>;
    let type: InventoryItemAttachmentType;
    MinimalItemTooltipData.GetModsDataPackages(InventoryItemData.GetGameItemData(data.inventoryItemData), TweakDBInterface.GetItemRecord(ItemID.GetTDBID(data.itemID)), data.displayContext, data.parentItemData, data.slotID, packages);
    i = 0;
    while i < ArraySize(packages) {
      ArrayPush(mods, packages[i]);
      i += 1;
    };
    limit = ArraySize(data.itemAttachments);
    i = 0;
    while i < limit {
      type = data.itemAttachments[i].SlotType;
      attachmentData = MinimalItemTooltipData.GetDefaultModAttachmentData(data, i, type);
      if Equals(type, InventoryItemAttachmentType.Dedicated) {
        if attachmentData != null {
          ArrayPush(dedicatedMods, attachmentData);
        };
      } else {
        ArrayPush(mods, attachmentData);
      };
      i += 1;
    };
  }

  public final static func GetModsDataPackages(itemData: wref<gameItemData>, itemRecord: wref<Item_Record>, displayContext: InventoryTooltipDisplayContext, opt parentItemData: wref<gameItemData>, opt slotID: TweakDBID, out mods: array<ref<MinimalItemTooltipModData>>) -> Void {
    let dataPackages: array<wref<GameplayLogicPackage_Record>>;
    let dataPackagesToDisplay: array<wref<GameplayLogicPackageUIData_Record>>;
    let i: Int32;
    let innerItemData: InnerItemData;
    let recordData: ref<MinimalItemTooltipModRecordData>;
    let uiDataPackage: wref<GameplayLogicPackageUIData_Record>;
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
    i = 0;
    while i < ArraySize(dataPackagesToDisplay) {
      recordData = new MinimalItemTooltipModRecordData();
      recordData.description = dataPackagesToDisplay[i].LocalizedDescription();
      if Equals(displayContext, InventoryTooltipDisplayContext.Attachment) {
        innerItemData = new InnerItemData();
        parentItemData.GetItemPart(innerItemData, slotID);
        recordData.dataPackage = UILocalizationDataPackage.FromLogicUIDataPackage(dataPackagesToDisplay[i], innerItemData);
      } else {
        recordData.dataPackage = UILocalizationDataPackage.FromLogicUIDataPackage(dataPackagesToDisplay[i], itemData);
      };
      ArrayPush(mods, recordData);
      i += 1;
    };
  }

  private final static func GetDefaultModAttachmentData(isEmpty: Bool, qualityName: CName, slotID: TweakDBID, itemName: String, abilities: script_ref<array<InventoryItemAbility>>, type: InventoryItemAttachmentType) -> ref<MinimalItemTooltipModAttachmentData> {
    let attachmentData: ref<MinimalItemTooltipModAttachmentData>;
    let emptySlotName: String;
    if isEmpty && Equals(type, InventoryItemAttachmentType.Dedicated) {
      return null;
    };
    attachmentData = new MinimalItemTooltipModAttachmentData();
    attachmentData.isEmpty = isEmpty;
    attachmentData.qualityName = qualityName;
    if !IsNameValid(attachmentData.qualityName) {
      attachmentData.qualityName = n"Empty";
    };
    if attachmentData.isEmpty {
      emptySlotName = UIItemsHelper.GetEmptySlotName(slotID);
      attachmentData.slotName = GetLocalizedText(emptySlotName);
      if !IsStringValid(attachmentData.slotName) {
        attachmentData.slotName = emptySlotName;
      };
    } else {
      attachmentData.abilitiesSize = ArraySize(Deref(abilities));
      if attachmentData.abilitiesSize == 0 {
        attachmentData.slotName = itemName;
      } else {
        attachmentData.abilities = Deref(abilities);
      };
    };
    return attachmentData;
  }

  private final static func GetDefaultModAttachmentData(data: ref<InventoryTooltipData>, index: Int32, type: InventoryItemAttachmentType) -> ref<MinimalItemTooltipModAttachmentData> {
    let attachmentData: ref<MinimalItemTooltipModAttachmentData>;
    let emptySlotName: String;
    let isEmpty: Bool = InventoryItemData.IsEmpty(data.itemAttachments[index].ItemData);
    if isEmpty && Equals(type, InventoryItemAttachmentType.Dedicated) {
      return null;
    };
    attachmentData = new MinimalItemTooltipModAttachmentData();
    attachmentData.isEmpty = isEmpty;
    attachmentData.qualityName = InventoryItemData.GetQuality(data.itemAttachments[index].ItemData);
    if !IsNameValid(attachmentData.qualityName) {
      attachmentData.qualityName = n"Empty";
    };
    if attachmentData.isEmpty {
      emptySlotName = UIItemsHelper.GetEmptySlotName(data.itemAttachments[index].SlotID);
      attachmentData.slotName = GetLocalizedText(emptySlotName);
      if !IsStringValid(attachmentData.slotName) {
        attachmentData.slotName = emptySlotName;
      };
    } else {
      attachmentData.abilitiesSize = InventoryItemData.GetAbilitiesSize(data.itemAttachments[index].ItemData);
      if attachmentData.abilitiesSize == 0 {
        attachmentData.slotName = InventoryItemData.GetName(data.itemAttachments[index].ItemData);
      } else {
        attachmentData.abilities = InventoryItemData.GetAbilities(data.itemAttachments[index].ItemData);
      };
    };
    return attachmentData;
  }

  public final static func GetMinimalTooltipDataRequirements(itemData: wref<gameItemData>, m_dataManager: ref<InventoryDataManagerV2>) -> ref<MinimalItemTooltipDataRequirements> {
    return MinimalItemTooltipData.GetMinimalTooltipDataRequirements(itemData, m_dataManager.HasPlayerSmartGunLink(), m_dataManager.GetPlayerStrength(), m_dataManager.GetPlayerReflex(), m_dataManager.GetPlayerLevel());
  }

  public final static func GetMinimalTooltipDataRequirements(itemData: wref<gameItemData>, hasSmartlink: Bool, playerStrength: Int32, playerReflex: Int32, playerLevel: Int32) -> ref<MinimalItemTooltipDataRequirements> {
    let result: ref<MinimalItemTooltipDataRequirements> = new MinimalItemTooltipDataRequirements();
    result.isSmartlinkRequirementNotMet = RPGManager.HasSmartLinkRequirement(itemData) && !hasSmartlink;
    let requiredStrength: Int32 = Cast(itemData.GetStatValueByType(gamedataStatType.Strength));
    let requiredReflex: Int32 = Cast(itemData.GetStatValueByType(gamedataStatType.Reflexes));
    let requiredLevel: Int32 = Cast(itemData.GetStatValueByType(gamedataStatType.Level));
    if requiredLevel > 0 && playerLevel < requiredLevel {
      result.isLevelRequirementNotMet = true;
      result.requiredLevel = requiredLevel;
    };
    if requiredStrength > 0 && playerStrength < requiredStrength {
      result.strengthOrReflexStatName = UILocalizationHelper.GetStatNameLockey(RPGManager.GetStatRecord(gamedataStatType.Strength));
      result.strengthOrReflexValue = requiredStrength;
      result.isStrengthRequirementNotMet = true;
    };
    if requiredReflex > 0 && playerReflex < requiredReflex {
      result.strengthOrReflexStatName = UILocalizationHelper.GetStatNameLockey(RPGManager.GetStatRecord(gamedataStatType.Reflexes));
      result.strengthOrReflexValue = requiredReflex;
      result.isReflexRequirementNotMet = true;
    };
    return result;
  }

  public final static func GetMinimalTooltipDataRequirements(itemData: wref<gameItemData>, tooltipData: ref<InventoryTooltipData>) -> ref<MinimalItemTooltipDataRequirements> {
    let requirement: SItemStackRequirementData;
    let statRecord: ref<Stat_Record>;
    let result: ref<MinimalItemTooltipDataRequirements> = new MinimalItemTooltipDataRequirements();
    result.isSmartlinkRequirementNotMet = RPGManager.HasSmartLinkRequirement(itemData) && !tooltipData.m_HasPlayerSmartGunLink;
    let requiredStrength: Int32 = Cast(itemData.GetStatValueByType(gamedataStatType.Strength));
    let requiredReflex: Int32 = Cast(itemData.GetStatValueByType(gamedataStatType.Reflexes));
    let requiredLevel: Int32 = Cast(itemData.GetStatValueByType(gamedataStatType.Level));
    if requiredLevel > 0 && tooltipData.m_PlayerLevel < requiredLevel {
      result.isLevelRequirementNotMet = true;
      result.requiredLevel = requiredLevel;
    };
    if requiredStrength > 0 && tooltipData.m_PlayerStrenght < requiredStrength {
      result.strengthOrReflexStatName = UILocalizationHelper.GetStatNameLockey(RPGManager.GetStatRecord(gamedataStatType.Strength));
      result.strengthOrReflexValue = requiredStrength;
      result.isStrengthRequirementNotMet = true;
    };
    if requiredReflex > 0 && tooltipData.m_PlayerReflexes < requiredReflex {
      result.strengthOrReflexStatName = UILocalizationHelper.GetStatNameLockey(RPGManager.GetStatRecord(gamedataStatType.Reflexes));
      result.strengthOrReflexValue = requiredReflex;
      result.isReflexRequirementNotMet = true;
    };
    if !InventoryItemData.IsEmpty(tooltipData.inventoryItemData) {
      requirement = InventoryItemData.GetRequirement(tooltipData.inventoryItemData);
      if NotEquals(requirement.statType, gamedataStatType.Invalid) && !InventoryItemData.IsRequirementMet(tooltipData.inventoryItemData) {
        result.isAnyStatRequirementNotMet = true;
        result.anyStatValue = RoundF(requirement.requiredValue);
        statRecord = RPGManager.GetStatRecord(requirement.statType);
        result.anyStatName = GetLocalizedText(UILocalizationHelper.GetStatNameLockey(statRecord));
        result.anyStatColor = "StatTypeColor." + EnumValueToString("gamedataStatType", Cast(EnumInt(requirement.statType)));
        result.anyStatLocKey = "LocKey#49215";
      };
    };
    if !InventoryItemData.IsEquippable(tooltipData.inventoryItemData) {
      result.isAnyStatRequirementNotMet = true;
      requirement = InventoryItemData.GetEquipRequirement(tooltipData.inventoryItemData);
      result.anyStatValue = RoundF(requirement.requiredValue);
      statRecord = RPGManager.GetStatRecord(requirement.statType);
      result.anyStatName = GetLocalizedText(UILocalizationHelper.GetStatNameLockey(statRecord));
      result.anyStatColor = "StatTypeColor." + EnumValueToString("gamedataStatType", Cast(EnumInt(requirement.statType)));
      result.anyStatLocKey = "LocKey#77652";
    };
    return result;
  }

  public final static func GetSecondaryStatsForStatMap(itemData: wref<gameItemData>, itemType: gamedataItemType, itemCategory: gamedataItemCategory) -> array<ref<MinimalItemTooltipStatData>> {
    let i: Int32;
    let limit: Int32;
    let result: array<ref<MinimalItemTooltipStatData>>;
    let secondaryStats: array<wref<Stat_Record>>;
    let statData: ref<MinimalItemTooltipStatData>;
    let statId: TweakDBID;
    let statType: gamedataStatType;
    let statValue: Float;
    let statsMap: wref<UIStatsMap_Record> = TweakDBInterface.GetUIStatsMapRecord(TDBID.Create("UIMaps." + EnumValueToString("gamedataItemType", Cast(EnumInt(itemType)))));
    if IsDefined(statsMap) {
      statsMap.SecondaryStats(secondaryStats);
      i = 0;
      limit = ArraySize(secondaryStats);
      while i < limit {
        statType = secondaryStats[i].StatType();
        if Equals(itemCategory, gamedataItemCategory.Clothing) && Equals(statType, gamedataStatType.Armor) {
        } else {
          if Equals(itemType, gamedataItemType.Gad_Grenade) {
            if MinimalItemTooltipData.ShouldFilterOutGrenadeStat(statType) {
            } else {
              statValue = itemData.GetStatValueByType(statType);
              statId = secondaryStats[i].GetID();
              statData.roundValue = TweakDBInterface.GetBool(statId + t".roundValue", false);
              if statData.roundValue ? RoundF(statValue) > 0 : AbsF(statValue) > 0.01 {
                statData = new MinimalItemTooltipStatData();
                statData.statName = secondaryStats[i].LocalizedName();
                statData.value = statValue;
                statData.type = statType;
                statData.isPercentage = TweakDBInterface.GetBool(statId + t".isPercentage", false);
                statData.displayPlus = TweakDBInterface.GetBool(statId + t".displayPlus", false);
                statData.inMeters = TweakDBInterface.GetBool(statId + t".inMeters", false);
                statData.inSeconds = TweakDBInterface.GetBool(statId + t".inSeconds", false);
                ArrayPush(result, statData);
              };
            };
          };
          statValue = itemData.GetStatValueByType(statType);
          statId = secondaryStats[i].GetID();
          statData.roundValue = TweakDBInterface.GetBool(statId + t".roundValue", false);
          if statData.roundValue ? RoundF(statValue) > 0 : AbsF(statValue) > 0.01 {
            statData = new MinimalItemTooltipStatData();
            statData.statName = secondaryStats[i].LocalizedName();
            statData.value = statValue;
            statData.type = statType;
            statData.isPercentage = TweakDBInterface.GetBool(statId + t".isPercentage", false);
            statData.displayPlus = TweakDBInterface.GetBool(statId + t".displayPlus", false);
            statData.inMeters = TweakDBInterface.GetBool(statId + t".inMeters", false);
            statData.inSeconds = TweakDBInterface.GetBool(statId + t".inSeconds", false);
            ArrayPush(result, statData);
          };
        };
        i += 1;
      };
    };
    return result;
  }
}
