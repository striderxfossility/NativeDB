
public native class RPGManager extends IScriptable {

  public final static native func GetItemData(gi: GameInstance, owner: ref<GameObject>, itemID: ItemID) -> wref<gameItemData>;

  public final static native func GetInnerItemDataQuality(itemData: InnerItemData) -> gamedataQuality;

  public final static native func GetItemDataQuality(itemData: wref<gameItemData>) -> gamedataQuality;

  public final static native func GetFloatItemQuality(qualityStat: Float) -> gamedataQuality;

  public final static native func IsInnerItemDataIconic(itemData: InnerItemData) -> Bool;

  public final static native func IsItemDataIconic(itemData: wref<gameItemData>) -> Bool;

  public final static native func IsItemBroken(itemData: ref<gameItemData>) -> Bool;

  public final static native func IsPercentageStat(stat: gamedataStatType) -> Bool;

  public final static native func ApplyAbilityArray(owner: wref<GameObject>, abilities: array<wref<GameplayAbility_Record>>) -> Void;

  public final static native func ShouldFlipNegativeValue(record: wref<Stat_Record>) -> Bool;

  public final static native func ShouldSlotBeAvailable(owner: wref<GameObject>, item: ItemID, attachmentSlotRecord: wref<AttachmentSlot_Record>) -> Bool;

  public final static native func CalculateStatModifiers(modifiers: array<wref<StatModifier_Record>>, context: GameInstance, root: wref<GameObject>, targetID: StatsObjectID, opt instigator: StatsObjectID, opt itemStatsID: StatsObjectID) -> Float;

  public final static native func CalculateAdditiveModifiers(modifiers: array<wref<StatModifier_Record>>, context: GameInstance, root: wref<GameObject>, targetID: StatsObjectID, opt instigator: StatsObjectID, opt itemStatsID: StatsObjectID) -> Float;

  public final static native func CalculateMultiplierModifiers(modifiers: array<wref<StatModifier_Record>>, context: GameInstance, root: wref<GameObject>, targetID: StatsObjectID, opt instigator: StatsObjectID, opt itemStatsID: StatsObjectID) -> Float;

  public final static native func CalculateAdditiveMultiplierModifiers(modifiers: array<wref<StatModifier_Record>>, context: GameInstance, root: wref<GameObject>, targetID: StatsObjectID, opt instigator: StatsObjectID, opt itemStatsID: StatsObjectID) -> Float;

  public final static native func CalculateStatModifier(modifier: wref<StatModifier_Record>, context: GameInstance, root: wref<GameObject>, targetID: StatsObjectID, opt instigator: StatsObjectID, opt itemStatsID: StatsObjectID) -> Float;

  public final static native func CalculateConstantModifier(modifier: wref<ConstantStatModifier_Record>) -> Float;

  public final static native func CalculateRandomModifier(modifier: wref<RandomStatModifier_Record>) -> Float;

  public final static native func CalculateCurveModifier(modifier: wref<CurveStatModifier_Record>, context: GameInstance, root: wref<GameObject>, targetID: StatsObjectID, opt instigator: StatsObjectID, opt itemStatsID: StatsObjectID) -> Float;

  public final static native func CalculateCombinedModifier(modifier: wref<CombinedStatModifier_Record>, context: GameInstance, root: wref<GameObject>, targetID: StatsObjectID, opt instigator: StatsObjectID, opt itemStatsID: StatsObjectID) -> Float;

  public final static native func GetRefObjectID(refObjectName: CName, context: GameInstance, root: wref<GameObject>, targetID: StatsObjectID, opt instigator: StatsObjectID, opt itemStatsID: StatsObjectID) -> StatsObjectID;

  public final static native func CalculateBuyPrice(context: GameInstance, vendor: wref<GameObject>, itemID: ItemID, multiplier: Float) -> Int32;

  public final static native func CalculateSellPrice(context: GameInstance, vendor: wref<GameObject>, itemID: ItemID) -> Int32;

  public final static native func CalculateSellPriceItemData(context: GameInstance, vendor: wref<GameObject>, itemData: ref<gameItemData>) -> Int32;

  public final static func CalculateStatModifiers(addValue: Float, multValue: Float, addMultValue: Float, modifiers: array<wref<StatModifier_Record>>, context: GameInstance, root: wref<GameObject>, targetID: StatsObjectID, opt instigator: StatsObjectID, opt itemStatsID: StatsObjectID) -> Float {
    let addMultMods: array<wref<StatModifier_Record>>;
    let additiveMods: array<wref<StatModifier_Record>>;
    let modType: CName;
    let multiplierMods: array<wref<StatModifier_Record>>;
    let i: Int32 = 0;
    while i < ArraySize(modifiers) {
      modType = modifiers[i].ModifierType();
      switch modType {
        case n"Additive":
          ArrayPush(additiveMods, modifiers[i]);
          break;
        case n"Multiplier":
          ArrayPush(multiplierMods, modifiers[i]);
          break;
        case n"AdditiveMultiplier":
          ArrayPush(addMultMods, modifiers[i]);
          break;
        default:
      };
      i += 1;
    };
    addValue += RPGManager.CalculateAdditiveModifiers(additiveMods, context, root, targetID, instigator, itemStatsID);
    multValue *= RPGManager.CalculateMultiplierModifiers(multiplierMods, context, root, targetID, instigator, itemStatsID);
    addMultValue += RPGManager.CalculateAdditiveMultiplierModifiers(addMultMods, context, root, targetID, instigator, itemStatsID);
    return addValue * multValue * addMultValue;
  }

  public final static func InjectStatModifier(gi: GameInstance, obj: ref<GameObject>, modifier: ref<gameStatModifierData>) -> Void {
    GameInstance.GetStatsSystem(gi).AddModifier(Cast(obj.GetEntityID()), modifier);
  }

  public final static func InjectStatModifierToItem(gi: GameInstance, itemData: ref<gameItemData>, modifier: ref<gameStatModifierData>) -> Void {
    GameInstance.GetStatsSystem(gi).AddModifier(itemData.GetStatsObjectID(), modifier);
  }

  public final static func IsDamageStat(stat: gamedataStatType) -> Bool {
    return Equals(stat, gamedataStatType.PhysicalDamage) || Equals(stat, gamedataStatType.ThermalDamage) || Equals(stat, gamedataStatType.ChemicalDamage) || Equals(stat, gamedataStatType.ElectricDamage) || Equals(stat, gamedataStatType.DamagePerHit) || Equals(stat, gamedataStatType.EffectiveDamagePerHit);
  }

  public final static func GetStatValueFromObject(gi: GameInstance, object: wref<GameObject>, stat: gamedataStatType) -> Float {
    return GameInstance.GetStatsSystem(gi).GetStatValue(Cast(object.GetEntityID()), stat);
  }

  public final static func CheckPrereqs(prereqs: array<wref<IPrereq_Record>>, target: wref<GameObject>) -> Bool {
    let prereq: ref<IPrereq>;
    let i: Int32 = 0;
    while i < ArraySize(prereqs) {
      prereq = IPrereq.CreatePrereq(prereqs[i].GetID());
      if !prereq.IsFulfilled(target.GetGame(), target) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func CheckPrereq(prereqRecord: wref<IPrereq_Record>, target: wref<GameObject>) -> Bool {
    let prereq: ref<IPrereq> = IPrereq.CreatePrereq(prereqRecord.GetID());
    if !prereq.IsFulfilled(target.GetGame(), target) {
      return false;
    };
    return true;
  }

  public final static func GetRarityMultiplier(puppet: wref<NPCPuppet>, curveName: CName) -> Float {
    let multiplier: Float = 1.00;
    let rarity: gamedataNPCRarity = puppet.GetPuppetRarity().Type();
    let statsDataSystem: ref<StatsDataSystem> = GameInstance.GetStatsDataSystem(puppet.GetGame());
    let powerLevel: Float = GameInstance.GetStatsSystem(puppet.GetGame()).GetStatValue(Cast(puppet.GetEntityID()), gamedataStatType.PowerLevel);
    switch rarity {
      case gamedataNPCRarity.Trash:
        multiplier = statsDataSystem.GetValueFromCurve(n"puppet_preset_trash_mods", powerLevel, curveName);
        break;
      case gamedataNPCRarity.Weak:
        multiplier = statsDataSystem.GetValueFromCurve(n"puppet_preset_weak_mods", powerLevel, curveName);
        break;
      case gamedataNPCRarity.Rare:
        multiplier = statsDataSystem.GetValueFromCurve(n"puppet_preset_rare_mods", powerLevel, curveName);
        break;
      case gamedataNPCRarity.Elite:
        multiplier = statsDataSystem.GetValueFromCurve(n"puppet_preset_elite_mods", powerLevel, curveName);
        break;
      case gamedataNPCRarity.Officer:
        multiplier = statsDataSystem.GetValueFromCurve(n"puppet_preset_officer_mods", powerLevel, curveName);
        break;
      case gamedataNPCRarity.Normal:
        multiplier = statsDataSystem.GetValueFromCurve(n"puppet_preset_normal_mods", powerLevel, curveName);
        break;
      case gamedataNPCRarity.Boss:
        multiplier = statsDataSystem.GetValueFromCurve(n"puppet_preset_boss_mods", powerLevel, curveName);
        break;
      default:
        multiplier = 1.00;
    };
    return multiplier;
  }

  public final static func ResistancesList() -> array<gamedataStatType> {
    let resistances: array<gamedataStatType>;
    ArrayPush(resistances, gamedataStatType.PhysicalResistance);
    ArrayPush(resistances, gamedataStatType.ChemicalResistance);
    ArrayPush(resistances, gamedataStatType.ThermalResistance);
    ArrayPush(resistances, gamedataStatType.ElectricResistance);
    return resistances;
  }

  public final static func ApplyAbility(owner: wref<GameObject>, ability: wref<GameplayAbility_Record>) -> Void {
    let GLP: ref<GameplayLogicPackageSystem> = GameInstance.GetGameplayLogicPackageSystem(owner.GetGame());
    GLP.RemovePackage(owner, ability.AbilityPackage().GetID());
    GLP.ApplyPackage(owner, owner, ability.AbilityPackage().GetID());
  }

  public final static func RemoveAbility(owner: wref<GameObject>, ability: wref<GameplayAbility_Record>) -> Void {
    let GLP: ref<GameplayLogicPackageSystem> = GameInstance.GetGameplayLogicPackageSystem(owner.GetGame());
    GLP.RemovePackage(owner, ability.AbilityPackage().GetID());
  }

  public final static func ApplyAbilityGroup(owner: wref<GameObject>, group: wref<GameplayAbilityGroup_Record>) -> Void {
    let abilities: array<wref<GameplayAbility_Record>>;
    if group.GetAbilitiesCount() > 0 {
      group.Abilities(abilities);
      RPGManager.ApplyAbilityArray(owner, abilities);
    };
  }

  public final static func RemoveAbilityGroup(owner: wref<GameObject>, group: wref<GameplayAbilityGroup_Record>) -> Void {
    let abilities: array<wref<GameplayAbility_Record>>;
    let i: Int32;
    group.Abilities(abilities);
    i = 0;
    while i < ArraySize(abilities) {
      RPGManager.RemoveAbility(owner, abilities[i]);
      i += 1;
    };
  }

  public final static func ApplyGLP(owner: wref<GameObject>, package: wref<GameplayLogicPackage_Record>) -> Void {
    let appliedPackages: array<TweakDBID>;
    let glpSys: ref<GameplayLogicPackageSystem> = GameInstance.GetGameplayLogicPackageSystem(owner.GetGame());
    glpSys.GetAppliedPackages(owner, appliedPackages);
    if !ArrayContains(appliedPackages, package.GetID()) || package.Stackable() {
      glpSys.ApplyPackage(owner, owner, package.GetID());
    };
  }

  public final static func RemoveGLP(owner: wref<GameObject>, package: wref<GameplayLogicPackage_Record>) -> Void {
    let appliedPackages: array<TweakDBID>;
    let glpSys: ref<GameplayLogicPackageSystem> = GameInstance.GetGameplayLogicPackageSystem(owner.GetGame());
    glpSys.GetAppliedPackages(owner, appliedPackages);
    if ArrayContains(appliedPackages, package.GetID()) {
      glpSys.RemovePackage(owner, package.GetID());
    };
  }

  public final static func ApplyGLPArray(owner: wref<GameObject>, arr: array<wref<GameplayLogicPackage_Record>>, opt ignoreAppliedPackages: Bool) -> Void {
    let appliedPackages: array<TweakDBID>;
    let i: Int32;
    let glpSys: ref<GameplayLogicPackageSystem> = GameInstance.GetGameplayLogicPackageSystem(owner.GetGame());
    if ignoreAppliedPackages {
      i = 0;
      while i < ArraySize(arr) {
        glpSys.ApplyPackage(owner, owner, arr[i].GetID());
        i += 1;
      };
    } else {
      glpSys.GetAppliedPackages(owner, appliedPackages);
      i = 0;
      while i < ArraySize(arr) {
        if arr[i].Stackable() || !ArrayContains(appliedPackages, arr[i].GetID()) {
          glpSys.ApplyPackage(owner, owner, arr[i].GetID());
        };
        i += 1;
      };
    };
  }

  public final static func ApplyEffectorsArray(owner: wref<GameObject>, arr: array<wref<Effector_Record>>) -> Void {
    let ES: ref<EffectorSystem> = GameInstance.GetEffectorSystem(owner.GetGame());
    let i: Int32 = 0;
    while i < ArraySize(arr) {
      ES.ApplyEffector(owner.GetEntityID(), owner, arr[i].GetID());
      i += 1;
    };
  }

  public final static func RemoveEffectorsArray(owner: wref<GameObject>, arr: array<wref<Effector_Record>>) -> Void {
    let ES: ref<EffectorSystem> = GameInstance.GetEffectorSystem(owner.GetGame());
    let i: Int32 = 0;
    while i < ArraySize(arr) {
      ES.RemoveEffector(owner.GetEntityID(), arr[i].GetID());
      i += 1;
    };
  }

  public final static func ApplyStatModifierGroups(owner: wref<GameObject>, arr: array<wref<StatModifierGroup_Record>>) -> Void {
    let modGroupID: Uint64;
    let SS: ref<StatsSystem> = GameInstance.GetStatsSystem(owner.GetGame());
    let i: Int32 = 0;
    while i < ArraySize(arr) {
      modGroupID = TDBID.ToNumber(arr[i].GetID());
      SS.DefineModifierGroupFromRecord(modGroupID, arr[i].GetID());
      SS.ApplyModifierGroup(Cast(owner.GetEntityID()), modGroupID);
      i += 1;
    };
  }

  public final static func RemoveStatModifierGroups(owner: wref<GameObject>, arr: array<wref<StatModifierGroup_Record>>) -> Void {
    let modGroupID: Uint64;
    let SS: ref<StatsSystem> = GameInstance.GetStatsSystem(owner.GetGame());
    let i: Int32 = 0;
    while i < ArraySize(arr) {
      modGroupID = TDBID.ToNumber(arr[i].GetID());
      SS.RemoveModifierGroup(Cast(owner.GetEntityID()), modGroupID);
      i += 1;
    };
  }

  public final static func GetLevelPercentage(obj: ref<GameObject>) -> Int32 {
    let exp: Int32 = PlayerDevelopmentSystem.GetData(obj).GetExperiencePercentage();
    return exp;
  }

  public final static func GetItemQualityFromRecord(itemRecord: ref<Item_Record>) -> gamedataQuality {
    let quality: gamedataQuality = itemRecord.Quality().Type();
    if NotEquals(quality, gamedataQuality.Random) {
      return quality;
    };
    return gamedataQuality.Invalid;
  }

  public final static func GetBumpedQuality(quality: gamedataQuality) -> gamedataQuality {
    switch quality {
      case gamedataQuality.Common:
        return gamedataQuality.Uncommon;
      case gamedataQuality.Uncommon:
        return gamedataQuality.Rare;
      case gamedataQuality.Rare:
        return gamedataQuality.Epic;
      case gamedataQuality.Epic:
        return gamedataQuality.Legendary;
      default:
        return quality;
    };
  }

  public final static func GetItemQuality(itemData: InnerItemData) -> gamedataQuality {
    return RPGManager.GetItemQuality(InnerItemData.GetStatValueByType(itemData, gamedataStatType.Quality));
  }

  public final static func ItemQualityNameToValue(q: CName) -> Float {
    let val: Float;
    switch q {
      case n"Common":
        val = 0.00;
        break;
      case n"Uncommon":
        val = 1.00;
        break;
      case n"Rare":
        val = 2.00;
        break;
      case n"Epic":
        val = 3.00;
        break;
      case n"Legendary":
        val = 4.00;
        break;
      default:
        val = 0.00;
    };
    return val;
  }

  public final static func SetQualityBasedOnCraftingSkill(object: wref<GameObject>) -> CName {
    let quality: CName;
    let craftingValue: Float = GameInstance.GetStatsSystem(object.GetGame()).GetStatValue(Cast(object.GetEntityID()), gamedataStatType.Crafting);
    let scalingValue: Float = GameInstance.GetStatsDataSystem(object.GetGame()).GetValueFromCurve(n"random_distributions", craftingValue, n"crafting_to_random_quality_items");
    switch scalingValue {
      case 0.00:
        quality = n"Common";
        break;
      case 1.00:
        quality = n"Uncommon";
        break;
      case 2.00:
        quality = n"Rare";
        break;
      case 3.00:
        quality = n"Epic";
        break;
      case 4.00:
        quality = n"Legendary";
        break;
      default:
        quality = n"Common";
    };
    return quality;
  }

  public final static func GetItemQuality(itemData: wref<gameItemData>) -> gamedataQuality {
    if IsDefined(itemData) {
      return RPGManager.GetItemQuality(itemData.GetStatValueByType(gamedataStatType.Quality));
    };
    return gamedataQuality.Invalid;
  }

  public final static func IsItemIconic(itemData: wref<gameItemData>) -> Bool {
    return itemData.GetStatValueByType(gamedataStatType.IsItemIconic) > 0.00;
  }

  public final static func IsItemIconic(itemData: InnerItemData) -> Bool {
    return InnerItemData.GetStatValueByType(itemData, gamedataStatType.IsItemIconic) > 0.00;
  }

  public final static func IsItemMaxLevel(itemData: wref<gameItemData>) -> Bool {
    let tempStat: Float = itemData.GetStatValueByType(gamedataStatType.ItemLevel);
    return tempStat >= 500.00;
  }

  public final static func IsItemWeapon(itemID: ItemID) -> Bool {
    return Equals(RPGManager.GetItemCategory(itemID), gamedataItemCategory.Weapon);
  }

  public final static func IsItemClothing(itemID: ItemID) -> Bool {
    return Equals(RPGManager.GetItemCategory(itemID), gamedataItemCategory.Clothing);
  }

  public final static func GetItemQuality(qualityStat: Float) -> gamedataQuality {
    let qualityInt: Int32 = RoundF(qualityStat);
    switch qualityInt {
      case 0:
        return gamedataQuality.Common;
      case 1:
        return gamedataQuality.Uncommon;
      case 2:
        return gamedataQuality.Rare;
      case 3:
        return gamedataQuality.Epic;
      case 4:
        return gamedataQuality.Legendary;
      default:
        return gamedataQuality.Common;
    };
  }

  public final static func GetCraftingMaterialRecord(quality: gamedataQuality, opt alternateVariant: Bool) -> ref<Item_Record> {
    let record: ref<Item_Record>;
    switch quality {
      case gamedataQuality.Common:
        record = TweakDBInterface.GetItemRecord(t"Items.CommonMaterial1");
        break;
      case gamedataQuality.Uncommon:
        record = TweakDBInterface.GetItemRecord(t"Items.UncommonMaterial1");
        break;
      case gamedataQuality.Rare:
        if alternateVariant {
          record = TweakDBInterface.GetItemRecord(t"Items.RareMaterial1");
        } else {
          record = TweakDBInterface.GetItemRecord(t"Items.RareMaterial2");
        };
        break;
      case gamedataQuality.Epic:
        if alternateVariant {
          record = TweakDBInterface.GetItemRecord(t"Items.EpicMaterial1");
        } else {
          record = TweakDBInterface.GetItemRecord(t"Items.EpicMaterial2");
        };
        break;
      case gamedataQuality.Legendary:
        if alternateVariant {
          record = TweakDBInterface.GetItemRecord(t"Items.LegendaryMaterial1");
        } else {
          record = TweakDBInterface.GetItemRecord(t"Items.LegendaryMaterial2");
        };
        break;
      default:
        return record;
    };
    return record;
  }

  public final static func GetAvailableSlotsForQuality(itemData: wref<gameItemData>, quality: gamedataQuality) -> Float {
    switch quality {
      case gamedataQuality.Common:
        return 0.00;
      case gamedataQuality.Uncommon:
        return 0.00;
      case gamedataQuality.Rare:
        return 1.00;
      case gamedataQuality.Epic:
        return 2.00;
      case gamedataQuality.Legendary:
        return 3.00;
      default:
        return 0.00;
    };
    return -1.00;
  }

  public final static func GetListOfRandomStatsFromEvolutionType(evolution: gamedataWeaponEvolution) -> array<wref<Stat_Record>> {
    let record: wref<UIStatsMap_Record>;
    let statMap: array<wref<Stat_Record>>;
    let tempStr: String;
    if Equals(evolution, gamedataWeaponEvolution.Invalid) {
      record = TweakDBInterface.GetUIStatsMapRecord(t"UIMaps.WeaponGeneral");
    } else {
      tempStr = "UIMaps.";
      tempStr += EnumValueToString("gamedataWeaponEvolution", Cast(EnumInt(evolution)));
      record = TweakDBInterface.GetUIStatsMapRecord(TDBID.Create(tempStr));
    };
    record.PrimaryStats(statMap);
    return statMap;
  }

  public final static func GetDominatingDamageType(gi: GameInstance, itemData: wref<gameItemData>) -> gamedataDamageType {
    let dmgIndex: Int32;
    let tempStat: Float;
    let highestValue: Float = 0.00;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(gi);
    let i: Int32 = 0;
    while i < EnumInt(gamedataDamageType.Count) {
      tempStat = statsSystem.GetStatValueFromDamageType(itemData.GetStatsObjectID(), IntEnum(i));
      if tempStat > highestValue {
        highestValue = tempStat;
        dmgIndex = i;
      };
      i += 1;
    };
    return IntEnum(dmgIndex);
  }

  public final static func SetDroppedWeaponQuality(npc: wref<ScriptedPuppet>, itemData: wref<gameItemData>) -> Void {
    let SS: ref<StatsSystem>;
    let mod: ref<gameStatModifierData>;
    let quality: Float;
    if !IsDefined(npc) {
      return;
    };
    SS = GameInstance.GetStatsSystem(npc.GetGame());
    if RandF() < 0.90 {
      quality = 0.00;
    } else {
      quality = 1.00;
    };
    SS.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.Quality, true);
    mod = RPGManager.CreateStatModifier(gamedataStatType.Quality, gameStatModifierType.Additive, quality);
    SS.AddSavedModifier(itemData.GetStatsObjectID(), mod);
    ScriptedPuppet.EvaluateLootQualityByTask(npc);
  }

  public final static func ForceItemQuality(obj: wref<GameObject>, itemData: wref<gameItemData>, forcedQuality: CName) -> Void {
    let SS: ref<StatsSystem>;
    let mod: ref<gameStatModifierData>;
    let value: Float;
    if !IsDefined(obj) {
      return;
    };
    SS = GameInstance.GetStatsSystem(obj.GetGame());
    value = RPGManager.GetItemQualityFromName(forcedQuality);
    if itemData.GetStatValueByType(gamedataStatType.Quality) == value {
      return;
    };
    mod = RPGManager.CreateStatModifier(gamedataStatType.Quality, gameStatModifierType.Additive, value);
    SS.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.Quality, true);
    SS.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.RandomCurveInput, true);
    SS.AddSavedModifier(itemData.GetStatsObjectID(), mod);
    mod = RPGManager.CreateStatModifier(gamedataStatType.RandomCurveInput, gameStatModifierType.Multiplier, 0.00);
    SS.AddSavedModifier(itemData.GetStatsObjectID(), mod);
  }

  public final static func ProcessOnLootedPackages(owner: wref<GameObject>, itemID: ItemID) -> Void {
    let glp: ref<GameplayLogicPackageSystem>;
    let i: Int32;
    let packages: array<wref<GameplayLogicPackage_Record>>;
    RPGManager.GetItemRecord(itemID).OnLooted(packages);
    glp = GameInstance.GetGameplayLogicPackageSystem(owner.GetGame());
    i = 0;
    while i < ArraySize(packages) {
      glp.ApplyPackage(owner, owner, packages[i].GetID());
      i += 1;
    };
  }

  public final static func GetItemQualityFromName(qualityName: CName) -> Float {
    switch qualityName {
      case n"Common":
        return 0.00;
      case n"Uncommon":
        return 1.00;
      case n"Rare":
        return 2.00;
      case n"Epic":
        return 3.00;
      case n"Legendary":
        return 4.00;
      default:
        return 0.00;
    };
  }

  public final static func HasItem(obj: wref<GameObject>, id: TweakDBID) -> Bool {
    let itemID: ItemID = ItemID.CreateQuery(id);
    return GameInstance.GetTransactionSystem(obj.GetGame()).HasItem(obj, itemID);
  }

  public final static func HasItem(obj: wref<GameObject>, id: ItemID) -> Bool {
    return GameInstance.GetTransactionSystem(obj.GetGame()).HasItem(obj, id);
  }

  public final static func GetItemType(itemID: ItemID) -> gamedataItemType {
    if ItemID.IsValid(itemID) {
      return TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).ItemType().Type();
    };
    return gamedataItemType.Invalid;
  }

  public final static func GetItemCategory(itemID: ItemID) -> gamedataItemCategory {
    let itemCategory: wref<ItemCategory_Record>;
    let itemRecord: ref<Item_Record>;
    if ItemID.IsValid(itemID) {
      itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
      if IsDefined(itemRecord) {
        itemCategory = itemRecord.ItemCategory();
        if IsDefined(itemCategory) {
          return itemCategory.Type();
        };
      };
    };
    return gamedataItemCategory.Invalid;
  }

  public final static func GetWeaponEvolution(itemID: ItemID) -> gamedataWeaponEvolution {
    let itemRecord: ref<WeaponItem_Record>;
    let weaponEvolution: wref<WeaponEvolution_Record>;
    if ItemID.IsValid(itemID) {
      itemRecord = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(itemID));
      if IsDefined(itemRecord) {
        weaponEvolution = itemRecord.Evolution();
        if IsDefined(weaponEvolution) {
          return weaponEvolution.Type();
        };
      };
    };
    return gamedataWeaponEvolution.Invalid;
  }

  public final static func GetItemWeight(itemData: ref<gameItemData>) -> Float {
    if IsDefined(itemData) {
      return itemData.GetStatValueByType(gamedataStatType.Weight);
    };
    return 0.00;
  }

  public final static func GetItemStackWeight(owner: wref<GameObject>, itemData: wref<gameItemData>) -> Float {
    let quantity: Float = Cast(GameInstance.GetTransactionSystem(owner.GetGame()).GetItemQuantity(owner, itemData.GetID()));
    let weight: Float = RPGManager.GetItemWeight(itemData);
    return quantity * weight;
  }

  public final static func IsItemSingleInstance(itemData: wref<gameItemData>) -> Bool {
    return RPGManager.GetItemRecord(itemData.GetID()).IsSingleInstance();
  }

  public final static func GetItemFromInventory(object: ref<GameObject>, item: TweakDBID) -> ItemID {
    let i: Int32;
    let items: array<wref<gameItemData>>;
    let TS: ref<TransactionSystem> = GameInstance.GetTransactionSystem(object.GetGame());
    TS.GetItemList(object, items);
    i = i;
    while i < ArraySize(items) {
      if ItemID.GetTDBID(items[i].GetID()) == item {
        return items[i].GetID();
      };
      i += 1;
    };
    return ItemID.undefined();
  }

  public final static func GetAttachmentSlotIDs() -> array<TweakDBID> {
    let arr: array<TweakDBID>;
    ArrayPush(arr, t"AttachmentSlots.Scope");
    ArrayPush(arr, t"AttachmentSlots.ScopeRail");
    ArrayPush(arr, t"AttachmentSlots.PowerModule");
    return arr;
  }

  public final static func GetModsSlotIDs(type: gamedataItemType) -> array<TweakDBID> {
    let arr: array<TweakDBID>;
    switch type {
      case gamedataItemType.Clo_Head:
        ArrayPush(arr, t"AttachmentSlots.HeadFabricEnhancer1");
        ArrayPush(arr, t"AttachmentSlots.HeadFabricEnhancer2");
        ArrayPush(arr, t"AttachmentSlots.HeadFabricEnhancer3");
        ArrayPush(arr, t"AttachmentSlots.HeadFabricEnhancer4");
        break;
      case gamedataItemType.Clo_Feet:
        ArrayPush(arr, t"AttachmentSlots.FootFabricEnhancer1");
        ArrayPush(arr, t"AttachmentSlots.FootFabricEnhancer2");
        ArrayPush(arr, t"AttachmentSlots.FootFabricEnhancer3");
        ArrayPush(arr, t"AttachmentSlots.FootFabricEnhancer4");
        break;
      case gamedataItemType.Clo_Face:
        ArrayPush(arr, t"AttachmentSlots.FaceFabricEnhancer1");
        ArrayPush(arr, t"AttachmentSlots.FaceFabricEnhancer2");
        ArrayPush(arr, t"AttachmentSlots.FaceFabricEnhancer3");
        ArrayPush(arr, t"AttachmentSlots.FaceFabricEnhancer4");
        break;
      case gamedataItemType.Clo_InnerChest:
        ArrayPush(arr, t"AttachmentSlots.InnerChestFabricEnhancer1");
        ArrayPush(arr, t"AttachmentSlots.InnerChestFabricEnhancer2");
        ArrayPush(arr, t"AttachmentSlots.InnerChestFabricEnhancer3");
        ArrayPush(arr, t"AttachmentSlots.InnerChestFabricEnhancer4");
        break;
      case gamedataItemType.Clo_Legs:
        ArrayPush(arr, t"AttachmentSlots.LegsFabricEnhancer1");
        ArrayPush(arr, t"AttachmentSlots.LegsFabricEnhancer2");
        ArrayPush(arr, t"AttachmentSlots.LegsFabricEnhancer3");
        ArrayPush(arr, t"AttachmentSlots.LegsFabricEnhancer4");
        break;
      case gamedataItemType.Clo_OuterChest:
        ArrayPush(arr, t"AttachmentSlots.OuterChestFabricEnhancer1");
        ArrayPush(arr, t"AttachmentSlots.OuterChestFabricEnhancer2");
        ArrayPush(arr, t"AttachmentSlots.OuterChestFabricEnhancer3");
        ArrayPush(arr, t"AttachmentSlots.OuterChestFabricEnhancer4");
        break;
      case gamedataItemType.Wea_ShotgunDual:
      case gamedataItemType.Wea_Shotgun:
      case gamedataItemType.Wea_SubmachineGun:
      case gamedataItemType.Wea_SniperRifle:
      case gamedataItemType.Wea_Rifle:
      case gamedataItemType.Wea_Revolver:
      case gamedataItemType.Wea_PrecisionRifle:
      case gamedataItemType.Wea_Handgun:
      case gamedataItemType.Wea_AssaultRifle:
        ArrayPush(arr, t"AttachmentSlots.GenericWeaponMod1");
        ArrayPush(arr, t"AttachmentSlots.GenericWeaponMod2");
        ArrayPush(arr, t"AttachmentSlots.GenericWeaponMod3");
        ArrayPush(arr, t"AttachmentSlots.GenericWeaponMod4");
        return arr;
      case gamedataItemType.Wea_ShortBlade:
      case gamedataItemType.Wea_TwoHandedClub:
      case gamedataItemType.Wea_OneHandedClub:
      case gamedataItemType.Wea_LongBlade:
      case gamedataItemType.Wea_Knife:
      case gamedataItemType.Wea_Hammer:
      case gamedataItemType.Wea_Katana:
        ArrayPush(arr, t"AttachmentSlots.MeleeWeaponMod1");
        ArrayPush(arr, t"AttachmentSlots.MeleeWeaponMod2");
        ArrayPush(arr, t"AttachmentSlots.MeleeWeaponMod3");
        return arr;
    };
    return arr;
  }

  public final static func IsInventoryEmpty(object: wref<GameObject>) -> Bool {
    let items: array<wref<gameItemData>>;
    GameInstance.GetTransactionSystem(object.GetGame()).GetItemList(object, items);
    return ArraySize(items) <= 0;
  }

  public final static func ProcessReadAction(choice: ref<InteractionChoiceEvent>) -> Void {
    let lootActionWrapper: LootChoiceActionWrapper = LootChoiceActionWrapper.Unwrap(choice);
    if LootChoiceActionWrapper.IsValid(lootActionWrapper) {
      if Equals(lootActionWrapper.action, n"Read") {
        ItemActionsHelper.ReadItem(choice.activator, lootActionWrapper.itemId);
      };
    };
  }

  public final static func ToggleLootHighlight(obj: wref<GameObject>, enable: Bool) -> Void {
    let recordID: TweakDBID = t"Effectors.LootHighlightEffector";
    if enable {
      GameInstance.GetEffectorSystem(obj.GetGame()).ApplyEffector(obj.GetEntityID(), obj, recordID);
    } else {
      GameInstance.GetEffectorSystem(obj.GetGame()).RemoveEffector(obj.GetEntityID(), recordID);
    };
  }

  public final static func CreateStatModifier(statType: gamedataStatType, modType: gameStatModifierType, value: Float) -> ref<gameStatModifierData> {
    let newMod: ref<gameConstantStatModifierData> = new gameConstantStatModifierData();
    newMod.statType = statType;
    newMod.modifierType = modType;
    newMod.value = value;
    return newMod;
  }

  public final static func CreateStatModifierUsingCurve(statType: gamedataStatType, modType: gameStatModifierType, refStat: gamedataStatType, curveName: CName, columnName: CName) -> ref<gameStatModifierData> {
    let newMod: ref<gameCurveStatModifierData> = new gameCurveStatModifierData();
    newMod.statType = statType;
    newMod.curveStat = refStat;
    newMod.modifierType = modType;
    newMod.curveName = curveName;
    newMod.columnName = columnName;
    return newMod;
  }

  public final static func CreateCombinedStatModifier(statType: gamedataStatType, modType: gameStatModifierType, refStat: gamedataStatType, opSymbol: gameCombinedStatOperation, value: Float, refObject: gameStatObjectsRelation) -> ref<gameStatModifierData> {
    let newMod: ref<gameCombinedStatModifierData> = new gameCombinedStatModifierData();
    newMod.statType = statType;
    newMod.modifierType = modType;
    newMod.value = value;
    newMod.refStatType = refStat;
    newMod.operation = opSymbol;
    newMod.refObject = refObject;
    return newMod;
  }

  public final static func CreateCurveModifier(statRecord: ref<CurveStatModifier_Record>) -> ref<gameStatModifierData> {
    let newMod: ref<gameCurveStatModifierData> = new gameCurveStatModifierData();
    newMod.statType = statRecord.StatType().StatType();
    newMod.modifierType = IntEnum(Cast(EnumValueFromName(n"gameStatModifierType", statRecord.ModifierType())));
    newMod.curveName = StringToName(statRecord.Id());
    newMod.columnName = StringToName(statRecord.Column());
    newMod.curveStat = statRecord.RefStat().StatType();
    return newMod;
  }

  public final static func StatRecordToModifier(statRecord: ref<StatModifier_Record>) -> ref<gameStatModifierData> {
    let modType: gameStatModifierType;
    let statType: gamedataStatType;
    let value: Float;
    let constMod: ref<ConstantStatModifier_Record> = statRecord as ConstantStatModifier_Record;
    let curveMod: ref<CurveStatModifier_Record> = statRecord as CurveStatModifier_Record;
    if IsDefined(constMod) {
      statType = constMod.StatType().StatType();
      modType = IntEnum(Cast(EnumValueFromName(n"gameStatModifierType", constMod.ModifierType())));
      value = constMod.Value();
      return RPGManager.CreateStatModifier(statType, modType, value);
    };
    if IsDefined(curveMod) {
      return RPGManager.CreateCurveModifier(curveMod);
    };
    return RPGManager.CreateStatModifier(gamedataStatType.Quantity, gameStatModifierType.Additive, 0.00);
  }

  public final static func GetPowerLevelFromContentAssignment(gi: GameInstance, contentAssignmentID: TweakDBID) -> Float {
    let constantModRecord: wref<ConstantStatModifier_Record>;
    let curveModRecord: wref<CurveStatModifier_Record>;
    let contentAssignment: wref<ContentAssignment_Record> = TweakDBInterface.GetContentAssignmentRecord(contentAssignmentID);
    if IsDefined(contentAssignment) {
      constantModRecord = contentAssignment.PowerLevelMod() as ConstantStatModifier_Record;
      curveModRecord = contentAssignment.PowerLevelMod() as CurveStatModifier_Record;
      if IsDefined(constantModRecord) {
        return constantModRecord.Value();
      };
      if IsDefined(curveModRecord) {
        return GameInstance.GetStatsDataSystem(gi).GetMinValueFromCurve(StringToName(curveModRecord.Id()), StringToName(curveModRecord.Column()));
      };
      return Cast(GameInstance.GetLevelAssignmentSystem(gi).GetLevelAssignment(contentAssignment.GetID()));
    };
    return 0.00;
  }

  public final static func CheckDifficultyToStatValue(gi: GameInstance, skill: gamedataStatType, difficulty: EGameplayChallengeLevel, id: EntityID) -> Int32 {
    let checkPowerLevel: Float;
    let entity: wref<Entity> = GameInstance.FindEntityByID(gi, id);
    let device: wref<Device> = entity as Device;
    let vehicle: wref<VehicleObject> = entity as VehicleObject;
    if IsDefined(device) {
      checkPowerLevel = RPGManager.GetPowerLevelFromContentAssignment(gi, device.GetContentScale());
    };
    if IsDefined(vehicle) {
      checkPowerLevel = RPGManager.GetStatValueFromObject(gi, vehicle, gamedataStatType.PowerLevel);
    };
    return RPGManager.GetCheckValue(gi, checkPowerLevel, difficulty);
  }

  public final static func GetCheckValue(gi: GameInstance, powerLevel: Float, difficulty: EGameplayChallengeLevel) -> Int32 {
    let curveName: CName;
    switch difficulty {
      case EGameplayChallengeLevel.NONE:
        curveName = n"none_difficulty";
        break;
      case EGameplayChallengeLevel.EASY:
        curveName = n"easy_difficulty";
        break;
      case EGameplayChallengeLevel.MEDIUM:
        curveName = n"medium_difficulty";
        break;
      case EGameplayChallengeLevel.HARD:
        curveName = n"hard_difficulty";
        break;
      case EGameplayChallengeLevel.IMPOSSIBLE:
        curveName = n"impossible_difficulty";
    };
    return RoundMath(GameInstance.GetStatsDataSystem(gi).GetValueFromCurve(n"attribute_checks", powerLevel, curveName));
  }

  public final static func CheckDifficultyToPerkLevel(perk: gamedataPerkType, difficulty: EGameplayChallengeLevel, id: EntityID) -> Int32 {
    return EnumInt(difficulty);
  }

  public final static func GetBuildScore(player: ref<GameObject>, buildToCheck: ref<PlayerBuild_Record>) -> Int32 {
    let attribute: gamedataStatType;
    let buildType: gamedataPlayerBuild = buildToCheck.Type();
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(player.GetGame());
    switch buildType {
      case gamedataPlayerBuild.Netrunner:
        attribute = gamedataStatType.Intelligence;
        break;
      case gamedataPlayerBuild.Solo:
        attribute = gamedataStatType.Strength;
        break;
      case gamedataPlayerBuild.Techie:
        attribute = gamedataStatType.TechnicalAbility;
        break;
      case gamedataPlayerBuild.Reflexes:
        attribute = gamedataStatType.Reflexes;
        break;
      case gamedataPlayerBuild.Cool:
        attribute = gamedataStatType.Cool;
    };
    return Cast(statsSystem.GetStatValue(Cast(player.GetEntityID()), attribute));
  }

  public final static func GetBluelineBuildCheckValue(player: ref<GameObject>, contentAssignment: ref<ContentAssignment_Record>, difficulty: EGameplayChallengeLevel) -> Int32 {
    let checkPowerLevel: Float = RPGManager.GetPowerLevelFromContentAssignment(player.GetGame(), contentAssignment.GetID());
    return RPGManager.GetCheckValue(player.GetGame(), checkPowerLevel, difficulty);
  }

  public final static func GetBluelinePaymentValue(player: ref<GameObject>, contentAssignment: ref<ContentAssignment_Record>, difficulty: EGameplayChallengeLevel) -> Int32 {
    let base: Float;
    let digitCount: Int32;
    let overrideValue: Int32;
    let playerMoney: Int32;
    let quotient: Float;
    let upToAmountCheck: Bool;
    let paymentPowerLevel: Float = RPGManager.GetPowerLevelFromContentAssignment(player.GetGame(), contentAssignment.GetID());
    let scaledPaymentValue: Float = GameInstance.GetStatsDataSystem(player.GetGame()).GetValueFromCurve(n"price_curves", paymentPowerLevel, n"power_level_to_payment_check");
    switch difficulty {
      case EGameplayChallengeLevel.NONE:
        scaledPaymentValue = 1.00;
        break;
      case EGameplayChallengeLevel.EASY:
        scaledPaymentValue *= 0.25;
        break;
      case EGameplayChallengeLevel.HARD:
        scaledPaymentValue *= 2.00;
        break;
      case EGameplayChallengeLevel.IMPOSSIBLE:
        scaledPaymentValue *= 10.00;
        break;
      default:
    };
    quotient = scaledPaymentValue;
    while quotient > 1.00 && digitCount < 10 {
      digitCount += 1;
      base = PowF(10.00, Cast(digitCount));
      quotient = scaledPaymentValue / base;
    };
    base = PowF(10.00, Cast(CeilF(Cast(digitCount) / 2.00)));
    scaledPaymentValue /= base;
    scaledPaymentValue = Cast(RoundMath(scaledPaymentValue));
    scaledPaymentValue *= base;
    overrideValue = TweakDBInterface.GetInt(contentAssignment.GetID() + t".overrideValue", 0);
    if overrideValue > 0 {
      scaledPaymentValue = Cast(overrideValue);
    };
    upToAmountCheck = TweakDBInterface.GetBool(contentAssignment.GetID() + t".upToCheck", false);
    if upToAmountCheck {
      playerMoney = GameInstance.GetTransactionSystem(player.GetGame()).GetItemQuantity(player, MarketSystem.Money());
      if playerMoney < Cast(scaledPaymentValue) {
        scaledPaymentValue = Cast(playerMoney);
      };
    };
    return RoundF(scaledPaymentValue);
  }

  public final static func GetStatRecord(type: gamedataStatType) -> ref<Stat_Record> {
    return TweakDBInterface.GetStatRecord(TDBID.Create("BaseStats." + EnumValueToString("gamedataStatType", Cast(EnumInt(type)))));
  }

  public final static func GetProficiencyRecord(type: gamedataProficiencyType) -> ref<Proficiency_Record> {
    return TweakDBInterface.GetProficiencyRecord(TDBID.Create("Proficiencies." + EnumValueToString("gamedataProficiencyType", Cast(EnumInt(type)))));
  }

  public final static func GetTraitRecord(type: gamedataTraitType) -> ref<Trait_Record> {
    return TweakDBInterface.GetTraitRecord(TDBID.Create("Traits." + EnumValueToString("gamedataTraitType", Cast(EnumInt(type)))));
  }

  public final static func GetResistanceTypeFromDamageType(damageType: gamedataDamageType) -> gamedataStatType {
    switch damageType {
      case gamedataDamageType.Physical:
        return gamedataStatType.PhysicalResistance;
      case gamedataDamageType.Thermal:
        return gamedataStatType.ThermalResistance;
      case gamedataDamageType.Chemical:
        return gamedataStatType.ChemicalResistance;
      case gamedataDamageType.Electric:
        return gamedataStatType.ElectricResistance;
      default:
        return gamedataStatType.Invalid;
    };
  }

  public final static func CalculatePowerDifferential(target: ref<GameObject>) -> EPowerDifferential {
    let statSys: ref<StatsSystem> = GameInstance.GetStatsSystem(target.GetGame());
    let player: wref<GameObject> = GameInstance.GetPlayerSystem(target.GetGame()).GetLocalPlayerControlledGameObject();
    let playerLevel: Float = statSys.GetStatValue(Cast(player.GetEntityID()), gamedataStatType.Level);
    let targetLevel: Float = statSys.GetStatValue(Cast(target.GetEntityID()), gamedataStatType.Level);
    let levelDifferential: Int32 = RoundMath(playerLevel - targetLevel);
    if levelDifferential <= EnumInt(EPowerDifferential.IMPOSSIBLE) {
      if Equals(GameObject.GetAttitudeBetween(player, target), EAIAttitude.AIA_Friendly) {
        return EPowerDifferential.HARD;
      };
      return EPowerDifferential.IMPOSSIBLE;
    };
    if levelDifferential > EnumInt(EPowerDifferential.IMPOSSIBLE) && levelDifferential <= EnumInt(EPowerDifferential.HARD) {
      return EPowerDifferential.HARD;
    };
    if levelDifferential > EnumInt(EPowerDifferential.HARD) && levelDifferential <= EnumInt(EPowerDifferential.NORMAL) {
      return EPowerDifferential.NORMAL;
    };
    if levelDifferential > EnumInt(EPowerDifferential.NORMAL) && levelDifferential <= EnumInt(EPowerDifferential.EASY) {
      return EPowerDifferential.EASY;
    };
    return EPowerDifferential.TRASH;
  }

  public final static func CalculatePowerDifferential(level: Int32) -> EPowerDifferential {
    if level <= EnumInt(EPowerDifferential.IMPOSSIBLE) {
      return EPowerDifferential.IMPOSSIBLE;
    };
    if level > EnumInt(EPowerDifferential.IMPOSSIBLE) && level <= EnumInt(EPowerDifferential.HARD) {
      return EPowerDifferential.HARD;
    };
    if level > EnumInt(EPowerDifferential.HARD) && level <= EnumInt(EPowerDifferential.NORMAL) {
      return EPowerDifferential.NORMAL;
    };
    if level > EnumInt(EPowerDifferential.NORMAL) && level <= EnumInt(EPowerDifferential.EASY) {
      return EPowerDifferential.EASY;
    };
    return EPowerDifferential.TRASH;
  }

  public final static func CalculateThreatValue(obj: ref<GameObject>) -> Float {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(obj.GetGame());
    let player: StatsObjectID = Cast(GetPlayer(obj.GetGame()).GetEntityID());
    let npc: StatsObjectID = Cast(obj.GetEntityID());
    let threatVal: Float = 0.00;
    let maxPowerLevel: Float = 60.00;
    let minPowerLevel: Float = 0.00;
    let npcPowerLevel: Float = statsSystem.GetStatValue(npc, gamedataStatType.PowerLevel);
    let playerPowerLevel: Float = statsSystem.GetStatValue(player, gamedataStatType.PowerLevel);
    let normPowerLevelDiff: Float = MathHelper.NormalizeF(npcPowerLevel - playerPowerLevel, maxPowerLevel - minPowerLevel, minPowerLevel - maxPowerLevel);
    threatVal = normPowerLevelDiff;
    return threatVal;
  }

  public final static func GetScannerResistanceDetails(obj: ref<GameObject>, statType: gamedataStatType, opt player: ref<GameObject>) -> ScannerStatDetails {
    let executorLevel: Float;
    let extraCost: Float;
    let powerLevelDiff: Float;
    let scanStatDetails: ScannerStatDetails;
    let targetLevel: Float;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(obj.GetGame());
    let currentResist: Float = statsSystem.GetStatValue(Cast(obj.GetEntityID()), statType);
    if Equals(statType, gamedataStatType.HackingResistance) && IsDefined(player) {
      scanStatDetails.baseValue = currentResist;
      executorLevel = statsSystem.GetStatValue(Cast(player.GetEntityID()), gamedataStatType.PowerLevel);
      targetLevel = statsSystem.GetStatValue(Cast(obj.GetEntityID()), gamedataStatType.PowerLevel);
      powerLevelDiff = Cast(RoundMath(executorLevel) - RoundF(targetLevel));
      extraCost = GameInstance.GetStatsDataSystem(player.GetGame()).GetValueFromCurve(n"puppet_dynamic_scaling", powerLevelDiff, n"pl_diff_to_memory_cost_modifier");
      currentResist += extraCost;
    };
    scanStatDetails.statType = statType;
    scanStatDetails.value = currentResist;
    return scanStatDetails;
  }

  public final static func GetCharacterWeakspotCount(puppet: ref<gamePuppet>) -> Int32 {
    let weakspots: array<wref<Weakspot_Record>>;
    TweakDBInterface.GetCharacterRecord(puppet.GetRecordID()).Weakspots(weakspots);
    return ArraySize(weakspots);
  }

  public final static func GetStatValues(obj: ref<GameObject>, stats: array<gamedataStatType>) -> array<gameStatTotalValue> {
    let statInfo: gameStatTotalValue;
    let statInfos: array<gameStatTotalValue>;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(obj.GetGame());
    let i: Int32 = 0;
    while i < ArraySize(stats) {
      statInfo.value = statsSystem.GetStatValue(Cast(obj.GetEntityID()), stats[i]);
      statInfo.statType = stats[i];
      ArrayPush(statInfos, statInfo);
      i += 1;
    };
    return statInfos;
  }

  public final static func GetMinStats(obj: ref<GameObject>, stats: array<gamedataStatType>) -> array<gameStatTotalValue> {
    let minStats: array<gameStatTotalValue>;
    let statInfos: array<gameStatTotalValue> = RPGManager.GetStatValues(obj, stats);
    let minValue: Float = MathHelper.PositiveInfinity();
    let i: Int32 = 0;
    while i < ArraySize(statInfos) {
      if statInfos[i].value < minValue {
        minValue = statInfos[i].value;
        ArrayClear(minStats);
        ArrayPush(minStats, statInfos[i]);
      } else {
        if statInfos[i].value == minValue {
          ArrayPush(minStats, statInfos[i]);
        };
      };
      i += 1;
    };
    return minStats;
  }

  public final static func GetMaxStats(obj: ref<GameObject>, stats: array<gamedataStatType>) -> array<gameStatTotalValue> {
    let maxStats: array<gameStatTotalValue>;
    let statInfos: array<gameStatTotalValue> = RPGManager.GetStatValues(obj, stats);
    let maxValue: Float = MathHelper.NegativeInfinity();
    let i: Int32 = 0;
    while i < ArraySize(statInfos) {
      if statInfos[i].value > maxValue {
        maxValue = statInfos[i].value;
        ArrayClear(maxStats);
        ArrayPush(maxStats, statInfos[i]);
      } else {
        if statInfos[i].value == maxValue {
          ArrayPush(maxStats, statInfos[i]);
        };
      };
      i += 1;
    };
    return maxStats;
  }

  public final static func GetLowestResistances(obj: ref<GameObject>) -> array<gameStatTotalValue> {
    return RPGManager.GetMinStats(obj, RPGManager.ResistancesList());
  }

  public final static func GetHighestResistances(obj: ref<GameObject>) -> array<gameStatTotalValue> {
    return RPGManager.GetMaxStats(obj, RPGManager.ResistancesList());
  }

  public final static func CanPlayerCraftFromInventory(obj: wref<GameObject>) -> Bool {
    let val: Float = GameInstance.GetStatsSystem(obj.GetGame()).GetStatValue(Cast(obj.GetEntityID()), gamedataStatType.CanCraftFromInventory);
    return val > 0.00;
  }

  public final static func CanPlayerUpgradeFromInventory(obj: wref<GameObject>) -> Bool {
    let val: Float = GameInstance.GetStatsSystem(obj.GetGame()).GetStatValue(Cast(obj.GetEntityID()), gamedataStatType.CanUpgradeFromInventory);
    return val > 0.00;
  }

  public final static func AwardExperienceFromDamage(hitEvent: ref<gameHitEvent>, damagePercentage: Float) -> Void {
    let attackSource: wref<ItemObject>;
    let i: Int32;
    let queueExpRequest: ref<QueueCombatExperience>;
    let queueExpRequests: array<ref<QueueCombatExperience>>;
    let targetPowerLevel: Float;
    let weaponRecord: wref<Item_Record>;
    let attackData: ref<AttackData> = hitEvent.attackData;
    let curveSetName: CName = n"activity_to_proficiency_xp";
    let inst: GameInstance = hitEvent.target.GetGame();
    let playerDevSystem: ref<PlayerDevelopmentSystem> = GameInstance.GetScriptableSystemsContainer(inst).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
    let expAwarded: Bool = true;
    let targetPuppet: wref<ScriptedPuppet> = hitEvent.target as ScriptedPuppet;
    if !IsDefined(targetPuppet) {
      return;
    };
    if targetPuppet.IsActive() && targetPuppet.AwardsExperience() {
      targetPowerLevel = GameInstance.GetStatsSystem(inst).GetStatValue(Cast(targetPuppet.GetEntityID()), gamedataStatType.PowerLevel);
      queueExpRequest = new QueueCombatExperience();
      queueExpRequest.owner = GameInstance.GetPlayerSystem(inst).GetLocalPlayerControlledGameObject();
      if attackData.GetInstigator().IsPlayer() && !hitEvent.target.IsPlayer() {
        weaponRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(attackData.GetWeapon().GetItemID()));
        switch weaponRecord.ItemType().Type() {
          case gamedataItemType.Cyb_MantisBlades:
          case gamedataItemType.Wea_Knife:
          case gamedataItemType.Wea_ShortBlade:
          case gamedataItemType.Wea_LongBlade:
          case gamedataItemType.Wea_Katana:
            queueExpRequest.m_experienceType = gamedataProficiencyType.Kenjutsu;
            queueExpRequest.m_amount = GameInstance.GetStatsDataSystem(inst).GetValueFromCurve(curveSetName, targetPowerLevel, n"kenjutsu_damage_to_xp");
            break;
          case gamedataItemType.Cyb_StrongArms:
          case gamedataItemType.Wea_Fists:
          case gamedataItemType.Wea_Melee:
          case gamedataItemType.Cyb_NanoWires:
          case gamedataItemType.Wea_OneHandedClub:
          case gamedataItemType.Wea_Hammer:
          case gamedataItemType.Wea_TwoHandedClub:
            queueExpRequest.m_experienceType = gamedataProficiencyType.Brawling;
            queueExpRequest.m_amount = GameInstance.GetStatsDataSystem(inst).GetValueFromCurve(curveSetName, targetPowerLevel, n"brawling_damage_to_xp");
            break;
          case gamedataItemType.Wea_Revolver:
          case gamedataItemType.Wea_Handgun:
            queueExpRequest.m_experienceType = gamedataProficiencyType.Gunslinger;
            queueExpRequest.m_amount = GameInstance.GetStatsDataSystem(inst).GetValueFromCurve(curveSetName, targetPowerLevel, n"gunslinger_damage_to_xp");
            break;
          case gamedataItemType.Wea_SubmachineGun:
          case gamedataItemType.Wea_AssaultRifle:
          case gamedataItemType.Wea_PrecisionRifle:
          case gamedataItemType.Wea_SniperRifle:
          case gamedataItemType.Wea_Rifle:
            queueExpRequest.m_experienceType = gamedataProficiencyType.Assault;
            queueExpRequest.m_amount = GameInstance.GetStatsDataSystem(inst).GetValueFromCurve(curveSetName, targetPowerLevel, n"assault_damage_to_xp");
            break;
          case gamedataItemType.Cyb_Launcher:
          case gamedataItemType.Wea_LightMachineGun:
          case gamedataItemType.Wea_HeavyMachineGun:
          case gamedataItemType.Wea_ShotgunDual:
          case gamedataItemType.Wea_Shotgun:
            queueExpRequest.m_experienceType = gamedataProficiencyType.Demolition;
            queueExpRequest.m_amount = GameInstance.GetStatsDataSystem(inst).GetValueFromCurve(curveSetName, targetPowerLevel, n"demolition_damage_to_xp");
            break;
          default:
            expAwarded = false;
        };
        if attackData.HasFlag(hitFlag.WeakspotHit) || attackData.HasFlag(hitFlag.Headshot) {
          queueExpRequest.m_amount *= 1.20;
        };
        if expAwarded {
          if StatusEffectSystem.ObjectHasStatusEffectWithTag(attackData.GetInstigator(), n"TrainingGuns") && attackData.GetWeapon().IsRanged() {
            queueExpRequest.m_amount *= 2.00;
          };
          if StatusEffectSystem.ObjectHasStatusEffectWithTag(attackData.GetInstigator(), n"TrainingMelee") && attackData.GetWeapon().IsMelee() {
            queueExpRequest.m_amount *= 2.00;
          };
          ArrayPush(queueExpRequests, queueExpRequest);
        };
        attackSource = attackData.GetSource() as ItemObject;
        if IsDefined(attackSource) && Equals(RPGManager.GetItemRecord(attackSource.GetItemID()).ItemType().Type(), gamedataItemType.Gad_Grenade) {
          queueExpRequest = new QueueCombatExperience();
          queueExpRequest.owner = GetPlayer(inst);
          queueExpRequest.m_experienceType = gamedataProficiencyType.Engineering;
          queueExpRequest.m_amount = GameInstance.GetStatsDataSystem(inst).GetValueFromCurve(curveSetName, targetPowerLevel, n"engineering_damage_to_xp");
          ArrayPush(queueExpRequests, queueExpRequest);
        };
        if hitEvent.hasPiercedTechSurface {
          queueExpRequest = new QueueCombatExperience();
          queueExpRequest.owner = GetPlayer(inst);
          queueExpRequest.m_experienceType = gamedataProficiencyType.Engineering;
          queueExpRequest.m_amount = GameInstance.GetStatsDataSystem(inst).GetValueFromCurve(curveSetName, targetPowerLevel, n"engineering_damage_to_xp");
          ArrayPush(queueExpRequests, queueExpRequest);
        };
        if hitEvent.attackData.GetAttackDefinition().GetRecord().GetID() == t"Attacks.SuperheroLanding" {
          queueExpRequest = new QueueCombatExperience();
          queueExpRequest.owner = GetPlayer(inst);
          queueExpRequest.m_experienceType = gamedataProficiencyType.Brawling;
          queueExpRequest.m_amount = GameInstance.GetStatsDataSystem(inst).GetValueFromCurve(curveSetName, targetPowerLevel, n"assassination_damage_to_xp");
          ArrayPush(queueExpRequests, queueExpRequest);
        };
        if hitEvent.attackData.HasFlag(hitFlag.StealthHit) {
          queueExpRequest = new QueueCombatExperience();
          queueExpRequest.owner = GetPlayer(inst);
          queueExpRequest.m_experienceType = gamedataProficiencyType.Stealth;
          queueExpRequest.m_amount = GameInstance.GetStatsDataSystem(inst).GetValueFromCurve(curveSetName, targetPowerLevel, n"assassination_damage_to_xp");
          ArrayPush(queueExpRequests, queueExpRequest);
        };
      };
      i = 0;
      while i < ArraySize(queueExpRequests) {
        queueExpRequest = queueExpRequests[i];
        queueExpRequest.m_amount *= RPGManager.GetRarityMultiplier(hitEvent.target as NPCPuppet, n"power_level_to_dmg_xp_mult");
        queueExpRequest.m_amount *= damagePercentage;
        queueExpRequest.m_entity = targetPuppet.GetEntityID();
        playerDevSystem.QueueRequest(queueExpRequest);
        i += 1;
      };
    };
  }

  public final static func GiveReward(gi: GameInstance, rewardID: TweakDBID, opt target: StatsObjectID, opt moneyMultiplier: Float) -> Void {
    let NCPDJobDone: ref<NCPDJobDoneEvent>;
    let achievementsArr: array<wref<Achievement_Record>>;
    let addRecipeRequest: ref<AddRecipeRequest>;
    let contentAssignment: TweakDBID;
    let contentLevel: Int32;
    let currencyArr: array<wref<CurrencyReward_Record>>;
    let currencyItemID: ItemID;
    let expArr: array<wref<XPPoints_Record>>;
    let expEvt: ref<ExperiencePointsEvent>;
    let expType: gamedataProficiencyType;
    let experienceValue: Float;
    let i: Int32;
    let itemArr: array<wref<InventoryItem_Record>>;
    let itemID: ItemID;
    let levelDiff: Int32;
    let moneyQuantity: Int32;
    let photoModeItmsArr: array<wref<PhotoModeItem_Record>>;
    let player: ref<PlayerPuppet>;
    let playerLevel: Float;
    let powerDiff: EPowerDifferential;
    let quantity: Int32;
    let quantityMods: array<wref<StatModifier_Record>>;
    let recipesArr: array<wref<Item_Record>>;
    let rewardName: String;
    let craftingSystem: ref<CraftingSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"CraftingSystem") as CraftingSystem;
    let transSys: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gi);
    let visualizer: ref<DebugVisualizerSystem> = GameInstance.GetDebugVisualizerSystem(gi);
    let rewardRecord: ref<RewardBase_Record> = TweakDBInterface.GetRewardBaseRecord(rewardID);
    if !IsDefined(rewardRecord) {
      Log("GiveReward(): No reward def record passed!");
      return;
    };
    player = GameInstance.GetPlayerSystem(gi).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    NCPDJobDone = new NCPDJobDoneEvent();
    rewardName = rewardRecord.Name();
    if NotEquals(rewardName, "") {
      visualizer.DrawText(new Vector4(5.00, 350.00, 0.00, 0.00), rewardName, gameDebugViewETextAlignment.Left, new Color(255u, 128u, 0u, 255u), 1.50);
    } else {
      rewardName = "GiveReward(): No reward name found";
      visualizer.DrawText(new Vector4(5.00, 350.00, 0.00, 0.00), rewardName, gameDebugViewETextAlignment.Left, new Color(255u, 128u, 0u, 255u), 1.50);
    };
    rewardRecord.Items(itemArr);
    i = 0;
    while i < ArraySize(itemArr) {
      quantity = itemArr[i].Quantity();
      itemID = ItemID.FromTDBID(itemArr[i].Item().GetID());
      transSys.GiveItem(player, ItemID.FromTDBID(itemArr[i].Item().GetID()), quantity);
      GameInstance.GetTelemetrySystem(player.GetGame()).LogItemReward(player, itemID);
      i += 1;
    };
    rewardRecord.Recipes(recipesArr);
    i = 0;
    while i < ArraySize(recipesArr) {
      addRecipeRequest = new AddRecipeRequest();
      addRecipeRequest.owner = player;
      addRecipeRequest.amount = 1;
      addRecipeRequest.recipe = recipesArr[i].GetID();
      craftingSystem.QueueRequest(addRecipeRequest);
      GameInstance.GetTelemetrySystem(player.GetGame()).LogItemReward(player, ItemID.FromTDBID(recipesArr[i].GetID()));
      i += 1;
    };
    rewardRecord.Experience(expArr);
    i = 0;
    while i < ArraySize(expArr) {
      expEvt = new ExperiencePointsEvent();
      ArrayClear(quantityMods);
      expArr[i].QuantityModifiers(quantityMods);
      experienceValue = RPGManager.CalculateStatModifiers(quantityMods, player.GetGame(), player, target);
      expType = expArr[i].Type().Type();
      expEvt.type = expType;
      expEvt.isDebug = false;
      contentAssignment = TDBID.Create(NameToString(TweakDBInterface.GetCName(rewardID + t".contentAssignment", n"")));
      if TDBID.IsValid(contentAssignment) {
        playerLevel = GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.PowerLevel);
        contentLevel = GameInstance.GetLevelAssignmentSystem(player.GetGame()).GetLevelAssignment(contentAssignment);
        levelDiff = RoundMath(playerLevel - Cast(contentLevel));
        powerDiff = RPGManager.CalculatePowerDifferential(levelDiff);
        switch powerDiff {
          case EPowerDifferential.TRASH:
            experienceValue *= 0.80;
            break;
          case EPowerDifferential.EASY:
            experienceValue *= 0.90;
            break;
          case EPowerDifferential.HARD:
            experienceValue *= 1.10;
            break;
          case EPowerDifferential.IMPOSSIBLE:
            experienceValue *= 1.20;
            break;
          default:
        };
      };
      expEvt.amount = Cast(experienceValue);
      GameInstance.GetTelemetrySystem(gi).LogXPReward(expArr[i].GetID(), expEvt.amount, expEvt.type);
      player.QueueEvent(expEvt);
      if Equals(expType, gamedataProficiencyType.Level) {
        NCPDJobDone.levelXPAwarded = expEvt.amount;
      } else {
        if Equals(expType, gamedataProficiencyType.StreetCred) {
          NCPDJobDone.streetCredXPAwarded = expEvt.amount;
        };
      };
      i += 1;
    };
    moneyQuantity = 0;
    rewardRecord.CurrencyPackage(currencyArr);
    i = 0;
    while i < ArraySize(currencyArr) {
      ArrayClear(quantityMods);
      currencyArr[i].QuantityModifiers(quantityMods);
      quantity = Cast(RPGManager.CalculateStatModifiers(quantityMods, player.GetGame(), player, target));
      if quantity > 0 {
        quantity = moneyMultiplier > 0.00 ? Cast(Cast(quantity) * moneyMultiplier) : quantity;
        currencyItemID = ItemID.FromTDBID(currencyArr[i].Currency().GetID());
        transSys.GiveItem(player, currencyItemID, quantity);
        if currencyItemID == MarketSystem.Money() {
          moneyQuantity += quantity;
        };
      };
      i += 1;
    };
    rewardRecord.Achievement(achievementsArr);
    i = 0;
    while i < ArraySize(achievementsArr) {
      RPGManager.SendAddAchievementRequest(gi, achievementsArr[i].Type(), achievementsArr[i]);
      i += 1;
    };
    rewardRecord.PhotoModeItem(photoModeItmsArr);
    i = 0;
    while i < ArraySize(photoModeItmsArr) {
      RPGManager.SendPhotoModeItemUnlockRequest(gi, photoModeItmsArr[i]);
      i += 1;
    };
    if StrBeginsWith(rewardName, "ma_") {
      GameInstance.GetUISystem(gi).QueueEvent(NCPDJobDone);
    };
    GameInstance.GetTelemetrySystem(gi).LogRewardGiven(StringToName(rewardName), rewardID, moneyQuantity);
  }

  private final static func SendAddAchievementRequest(gi: GameInstance, achievement: gamedataAchievement, achievementRecord: wref<Achievement_Record>) -> Void {
    let request: ref<AddAchievementRequest> = new AddAchievementRequest();
    request.achievement = achievement;
    request.achievementRecord = achievementRecord;
    GameInstance.GetScriptableSystemsContainer(gi).Get(n"DataTrackingSystem").QueueRequest(request);
  }

  private final static func SendPhotoModeItemUnlockRequest(gi: GameInstance, photoModeItm: wref<PhotoModeItem_Record>) -> Void {
    let tweakID: TweakDBID = photoModeItm.GetID();
    GameInstance.GetPhotoModeSystem(gi).UnlockPhotoModeItem(tweakID);
  }

  public final static func GiveScavengeReward(gi: GameInstance, rewardID: TweakDBID, scavengeTargetEntityID: EntityID) -> Void {
    RPGManager.GiveReward(gi, rewardID);
  }

  public final static func PrepareGameEffectAttack(gi: GameInstance, instigator: ref<GameObject>, source: ref<GameObject>, attackName: TweakDBID, opt position: Vector4, opt hitFlags: array<SHitFlag>, opt target: ref<GameObject>, opt tickRateOverride: Float) -> ref<Attack_GameEffect> {
    let attack: ref<Attack_GameEffect>;
    let attackContext: AttackInitContext;
    let attackEffect: ref<EffectInstance>;
    let effectDef: ref<EffectSharedDataDef>;
    let sharedData: EffectData;
    let statMods: array<ref<gameStatModifierData>>;
    let attackRecord: ref<Attack_GameEffect_Record> = TweakDBInterface.GetAttackRecord(attackName) as Attack_GameEffect_Record;
    if IsDefined(attackRecord) {
      attackContext.record = attackRecord;
      attackContext.instigator = instigator;
      attackContext.source = source;
      attack = IAttack.Create(attackContext) as Attack_GameEffect;
      attackEffect = attack.PrepareAttack(instigator);
      attack.GetStatModList(statMods);
      if Equals(position, Vector4.EmptyVector()) {
        position = source.GetWorldPosition();
      };
      sharedData = attackEffect.GetSharedData();
      effectDef = GetAllBlackboardDefs().EffectSharedData;
      EffectData.SetFloat(sharedData, effectDef.radius, attackRecord.Range());
      EffectData.SetVector(sharedData, effectDef.position, position);
      EffectData.SetVariant(sharedData, effectDef.attack, ToVariant(attack));
      EffectData.SetVariant(sharedData, effectDef.attackStatModList, ToVariant(statMods));
      EffectData.SetVariant(sharedData, effectDef.flags, ToVariant(hitFlags));
      EffectData.SetEntity(sharedData, effectDef.entity, target);
      if tickRateOverride > 0.00 {
        EffectData.SetFloat(sharedData, effectDef.tickRateOverride, tickRateOverride);
      };
      EffectData.SetName(sharedData, effectDef.slotName, n"Head");
      return attack;
    };
    return attack;
  }

  public final static func ExtractItemsOfEquipArea(type: gamedataEquipmentArea, input: array<wref<gameItemData>>, out output: array<wref<gameItemData>>) -> Bool {
    let itemsFound: Bool;
    let i: Int32 = 0;
    while i < ArraySize(input) {
      if Equals(TweakDBInterface.GetItemRecord(ItemID.GetTDBID(input[i].GetID())).EquipArea().Type(), type) {
        ArrayPush(output, input[i]);
        itemsFound = true;
      };
      i += 1;
    };
    return itemsFound;
  }

  public final static func GetAmmoCount(owner: ref<GameObject>, itemID: ItemID) -> String {
    let ammoCount: Int32;
    let ammoQuery: ItemID;
    let weaponRecord: ref<WeaponItem_Record>;
    let transSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(owner.GetGame());
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    let category: gamedataItemCategory = itemRecord.ItemCategory().Type();
    if Equals(category, gamedataItemCategory.Gadget) || Equals(category, gamedataItemCategory.Consumable) {
      ammoQuery = ItemID.CreateQuery(ItemID.GetTDBID(itemID));
      ammoCount = transSystem.GetItemQuantity(owner, ammoQuery);
      return ToString(ammoCount);
    };
    if Equals(category, gamedataItemCategory.Weapon) {
      weaponRecord = itemRecord as WeaponItem_Record;
      ammoQuery = ItemID.CreateQuery(weaponRecord.Ammo().GetID());
      ammoCount = transSystem.GetItemQuantity(owner, ammoQuery);
    };
    if ammoCount > 0 {
      return ToString(ammoCount);
    };
    return "";
  }

  public final static func GetAmmoCountValue(owner: ref<GameObject>, itemID: ItemID) -> Int32 {
    let ammoCount: Int32;
    let ammoQuery: ItemID;
    let category: gamedataItemCategory;
    let weaponRecord: ref<WeaponItem_Record>;
    let transSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(owner.GetGame());
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    if IsDefined(itemRecord) {
      category = itemRecord.ItemCategory().Type();
    };
    if Equals(category, gamedataItemCategory.Gadget) || Equals(category, gamedataItemCategory.Consumable) {
      ammoQuery = ItemID.CreateQuery(ItemID.GetTDBID(itemID));
      ammoCount = transSystem.GetItemQuantity(owner, ammoQuery);
      return ammoCount;
    };
    if Equals(category, gamedataItemCategory.Weapon) && IsDefined(itemRecord) {
      weaponRecord = itemRecord as WeaponItem_Record;
      ammoQuery = ItemID.CreateQuery(weaponRecord.Ammo().GetID());
      ammoCount = transSystem.GetItemQuantity(owner, ammoQuery);
    };
    return ammoCount;
  }

  public final static func GetWeaponAmmoTDBID(weaponID: ItemID) -> TweakDBID {
    return TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weaponID)).Ammo().GetID();
  }

  public final static func GetItemRecord(itemID: ItemID) -> ref<Item_Record> {
    return TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
  }

  public final static func GetAttachmentSlotID(slot: String) -> TweakDBID {
    return TDBID.Create("AttachmentSlots." + slot);
  }

  public final static func ForceEquipItemOnPlayer(puppet: ref<GameObject>, itemTDBID: TweakDBID, addToInv: Bool) -> Void {
    let equipRequest: ref<EquipRequest>;
    let itemID: ItemID;
    if puppet == null || !IsDefined(puppet as PlayerPuppet) {
      return;
    };
    itemID = ItemID.FromTDBID(itemTDBID);
    equipRequest = new EquipRequest();
    equipRequest.itemID = itemID;
    equipRequest.owner = puppet;
    equipRequest.addToInventory = addToInv;
    GameInstance.GetScriptableSystemsContainer(puppet.GetGame()).Get(n"EquipmentSystem").QueueRequest(equipRequest);
  }

  public final static func GetItemActions(itemID: ItemID) -> array<wref<ObjectAction_Record>> {
    let actions: array<wref<ObjectAction_Record>>;
    TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)).ObjectActions(actions);
    return actions;
  }

  public final static func IsTechPierceEnabled(gi: GameInstance, owner: ref<GameObject>, itemID: ItemID) -> Bool {
    return GameInstance.GetTransactionSystem(gi).GetItemData(owner, itemID).GetStatValueByType(gamedataStatType.TechPierceEnabled) > 0.00;
  }

  public final static func IsRicochetChanceEnabled(gi: GameInstance, owner: ref<GameObject>, itemID: ItemID) -> Bool {
    let itemData: ref<gameItemData> = GameInstance.GetTransactionSystem(gi).GetItemData(owner, itemID);
    if IsDefined(itemData) {
      return itemData.GetStatValueByType(gamedataStatType.RicochetChance) > 0.00;
    };
    return false;
  }

  public final static func HasSmartLinkRequirement(itemData: ref<gameItemData>) -> Bool {
    if IsDefined(itemData) {
      return itemData.GetStatValueByType(gamedataStatType.ItemRequiresSmartLink) > 0.00;
    };
    return false;
  }

  public final static func CanPartBeUnequipped(itemID: ItemID) -> Bool {
    let type: gamedataItemType = RPGManager.GetItemType(itemID);
    return NotEquals(type, gamedataItemType.Prt_Mod) && NotEquals(type, gamedataItemType.Prt_FabricEnhancer) && NotEquals(type, gamedataItemType.Prt_Fragment);
  }

  public final static func CanItemBeDropped(puppet: ref<GameObject>, itemData: ref<gameItemData>) -> Bool {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(puppet.GetGame()).Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    let consumableBeingUsed: ItemID = FromVariant(blackboard.GetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.consumableBeingUsed));
    if IsDefined(itemData) {
      if ItemID.IsValid(consumableBeingUsed) && TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(itemData.GetID())) == TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(consumableBeingUsed)) {
        return false;
      };
      return !itemData.HasTag(n"Quest") && !itemData.HasTag(n"UnequipBlocked") && IsDefined(ItemActionsHelper.GetDropAction(itemData.GetID()));
    };
    return false;
  }

  public final static func CanItemBeDisassembled(gameInstance: GameInstance, itemID: ItemID) -> Bool {
    let CS: ref<CraftingSystem> = CraftingSystem.GetInstance(gameInstance);
    return CS.CanItemBeDisassembled(GetPlayer(gameInstance), itemID);
  }

  public final static func HasDownloadFundsAction(itemID: ItemID) -> Bool {
    let actions: array<wref<ObjectAction_Record>> = RPGManager.GetItemActions(itemID);
    let i: Int32 = 0;
    while i < ArraySize(actions) {
      if Equals(actions[i].ActionName(), n"DownloadFunds") {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final static func CanDownloadFunds(gi: GameInstance, itemID: ItemID) -> Bool {
    let fact: CName;
    let actions: array<wref<ObjectAction_Record>> = RPGManager.GetItemActions(itemID);
    let i: Int32 = 0;
    while i < ArraySize(actions) {
      if Equals(actions[i].ActionName(), n"DownloadFunds") {
        fact = TweakDBInterface.GetCName(actions[i].GetID() + t".factToCheck", n"");
        if IsNameValid(fact) && GetFact(gi, fact) <= 0 {
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  public final static func CanItemBeDisassembled(gameInstance: GameInstance, itemData: wref<gameItemData>) -> Bool {
    let CS: ref<CraftingSystem>;
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(gameInstance).Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    let consumableBeingUsed: ItemID = FromVariant(blackboard.GetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.consumableBeingUsed));
    if IsDefined(itemData) {
      if ItemID.IsValid(consumableBeingUsed) && TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(itemData.GetID())) == TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(consumableBeingUsed)) {
        return false;
      };
      CS = CraftingSystem.GetInstance(gameInstance);
      return CS.CanItemBeDisassembled(itemData);
    };
    return false;
  }

  public final static func IsItemEquipped(owner: wref<GameObject>, itemID: ItemID) -> Bool {
    let ES: ref<EquipmentSystem> = EquipmentSystem.GetInstance(owner);
    let result: Bool = ES.IsEquipped(owner, itemID);
    return result;
  }

  public final static func IsItemCrafted(itemData: wref<gameItemData>) -> Bool {
    let value: Float = itemData.GetStatValueByType(gamedataStatType.IsItemCrafted);
    return value > 0.00;
  }

  public final static func ConsumeItem(obj: wref<GameObject>, evt: ref<InteractionChoiceEvent>) -> Bool {
    let blackboard: ref<IBlackboard>;
    let eqs: ref<EquipmentSystem>;
    let itemQuantity: Int32;
    let itemType: gamedataItemType;
    let request: ref<EquipmentSystemWeaponManipulationRequest>;
    let lootActionWrapper: LootChoiceActionWrapper = LootChoiceActionWrapper.Unwrap(evt);
    let gameInstance: GameInstance = obj.GetGame();
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gameInstance);
    if Equals(lootActionWrapper.action, n"Consume") {
      itemQuantity = GameInstance.GetTransactionSystem(gameInstance).GetItemQuantity(obj, lootActionWrapper.itemId);
      transactionSystem.TransferItem(obj, evt.activator, lootActionWrapper.itemId, itemQuantity);
      itemType = RPGManager.GetItemType(lootActionWrapper.itemId);
      if Equals(itemType, gamedataItemType.Con_Inhaler) || Equals(itemType, gamedataItemType.Con_Injector) {
        blackboard = GameInstance.GetBlackboardSystem(gameInstance).Get(GetAllBlackboardDefs().UI_QuickSlotsData);
        blackboard.SetVariant(GetAllBlackboardDefs().UI_QuickSlotsData.containerConsumable, ToVariant(lootActionWrapper.itemId));
        eqs = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"EquipmentSystem") as EquipmentSystem;
        request = new EquipmentSystemWeaponManipulationRequest();
        request.owner = evt.activator;
        request.requestType = EquipmentManipulationAction.RequestConsumable;
        eqs.QueueRequest(request);
      } else {
        ItemActionsHelper.ConsumeItem(evt.activator, lootActionWrapper.itemId, true);
        return true;
      };
    } else {
      if Equals(lootActionWrapper.action, n"Eat") {
        itemQuantity = GameInstance.GetTransactionSystem(gameInstance).GetItemQuantity(obj, lootActionWrapper.itemId);
        transactionSystem.TransferItem(obj, evt.activator, lootActionWrapper.itemId, itemQuantity);
        ItemActionsHelper.EatItem(evt.activator, lootActionWrapper.itemId, true);
        return true;
      };
      if Equals(lootActionWrapper.action, n"Drink") {
        itemQuantity = GameInstance.GetTransactionSystem(gameInstance).GetItemQuantity(obj, lootActionWrapper.itemId);
        transactionSystem.TransferItem(obj, evt.activator, lootActionWrapper.itemId, itemQuantity);
        ItemActionsHelper.DrinkItem(evt.activator, lootActionWrapper.itemId, true);
        return true;
      };
    };
    return false;
  }

  public final static func IsWeaponMelee(type: gamedataItemType) -> Bool {
    return Equals(type, gamedataItemType.Wea_Fists) || Equals(type, gamedataItemType.Wea_Knife) || Equals(type, gamedataItemType.Wea_Katana) || Equals(type, gamedataItemType.Wea_OneHandedClub) || Equals(type, gamedataItemType.Wea_LongBlade) || Equals(type, gamedataItemType.Wea_ShortBlade) || Equals(type, gamedataItemType.Wea_Melee) || Equals(type, gamedataItemType.Wea_Hammer);
  }

  public final static func BreakItem(gi: GameInstance, owner: ref<GameObject>, itemID: ItemID) -> Bool {
    let chance: Float;
    let rand: Float;
    let itemData: wref<gameItemData> = GameInstance.GetTransactionSystem(gi).GetItemData(owner, itemID);
    if !IsDefined(itemData) {
      return false;
    };
    if Equals(RPGManager.GetItemDataQuality(itemData), gamedataQuality.Common) {
      chance = TweakDBInterface.GetFloat(t"GlobalStats.ChanceForItemToBeBroken.value", 1.00);
      rand = RandF();
      if rand < chance {
        return true;
      };
    };
    return false;
  }

  public final static func DropManyItems(gameInstance: GameInstance, obj: wref<GameObject>, items: array<ItemModParams>) -> Void {
    let LM: ref<LootManager>;
    let dropList: array<DropInstruction>;
    let i: Int32 = 0;
    while i < ArraySize(items) {
      ArrayPush(dropList, DropInstruction.Create(items[i].itemID, items[i].quantity));
      i += 1;
    };
    LM = GameInstance.GetLootManager(gameInstance);
    LM.SpawnItemDropOfManyItems(obj, dropList, n"playerDropBag", obj.GetWorldPosition());
  }

  public final static func GetRandomizedHealingConsumable(puppet: wref<ScriptedPuppet>) -> TweakDBID {
    let list: array<TweakDBID>;
    let rand: Int32;
    ArrayPush(list, t"Items.FirstAidWhiffV0");
    ArrayPush(list, t"Items.BonesMcCoy70V0");
    rand = RandRange(0, ArraySize(list) + 1);
    return list[rand];
  }

  public final static func GetRandomizedGadget(puppet: wref<ScriptedPuppet>) -> TweakDBID {
    let list: array<TweakDBID>;
    let rand: Int32 = RandRange(0, ArraySize(list) + 1);
    return list[rand];
  }

  public final static func ForceUnequipItemFromPlayer(puppet: ref<GameObject>, slotTDBID: TweakDBID, removeItem: Bool) -> Void {
    let itemID: ItemID;
    let transactionSys: ref<TransactionSystem>;
    if puppet == null && !IsDefined(puppet as PlayerPuppet) {
      return;
    };
    if !TDBID.IsValid(slotTDBID) {
      return;
    };
    transactionSys = GameInstance.GetTransactionSystem(puppet.GetGame());
    itemID = transactionSys.GetItemInSlot(puppet, slotTDBID).GetItemID();
    transactionSys.RemoveItemFromSlot(puppet, slotTDBID, true);
    if removeItem {
      transactionSys.RemoveItem(puppet, itemID, 1);
    };
  }

  public final static func ToggleHolsteredArmAppearance(puppet: ref<GameObject>, setHoleInArm: Bool) -> Void {
    let itemObj: ref<ItemObject>;
    let switchEvent: ref<gameuiPersonalLinkSwitcherEvent>;
    let player: ref<PlayerPuppet> = puppet as PlayerPuppet;
    if !IsDefined(player) {
      return;
    };
    switchEvent = new gameuiPersonalLinkSwitcherEvent();
    switchEvent.isAdvanced = setHoleInArm;
    itemObj = GameInstance.GetTransactionSystem(player.GetGame()).GetItemInSlot(player, RPGManager.GetAttachmentSlotID("RightArm"));
    if IsDefined(itemObj) {
      itemObj.QueueEvent(switchEvent);
    };
  }

  public final static func TogglePersonalLinkAppearance(puppet: ref<GameObject>) -> Void {
    let itemObj: ref<ItemObject>;
    let meshEvent: ref<entAppearanceEvent>;
    let player: ref<PlayerPuppet> = puppet as PlayerPuppet;
    if !IsDefined(player) {
      return;
    };
    itemObj = GameInstance.GetTransactionSystem(player.GetGame()).GetItemInSlot(player, RPGManager.GetAttachmentSlotID("PersonalLink"));
    if ItemID.GetTDBID(EquipmentSystem.GetData(player).GetActiveItem(gamedataEquipmentArea.RightArm)) == t"Items.HolsteredStrongArms" {
      meshEvent = new entAppearanceEvent();
      meshEvent.appearanceName = n"only_plug";
      itemObj.QueueEvent(meshEvent);
      return;
    };
  }

  public final static func HasStatFlag(owner: wref<GameObject>, flag: gamedataStatType) -> Bool {
    if !IsDefined(owner) || !owner.IsAttached() {
      return false;
    };
    return GameInstance.GetStatsSystem(owner.GetGame()).GetStatBoolValue(Cast(owner.GetEntityID()), flag);
  }

  public final static func GetPlayerQuickHackList(player: wref<PlayerPuppet>) -> array<TweakDBID> {
    let actionIDs: array<TweakDBID>;
    let playerActions: array<PlayerQuickhackData> = RPGManager.GetPlayerQuickHackListWithQuality(player);
    let i: Int32 = 0;
    while i < ArraySize(playerActions) {
      ArrayPush(actionIDs, playerActions[i].actionRecord.GetID());
      i += 1;
    };
    return actionIDs;
  }

  public final static func GetPlayerQuickHackListWithQuality(player: wref<PlayerPuppet>) -> array<PlayerQuickhackData> {
    let actions: array<wref<ObjectAction_Record>>;
    let i: Int32;
    let i1: Int32;
    let itemRecord: wref<Item_Record>;
    let parts: array<SPartSlots>;
    let quickhackData: PlayerQuickhackData;
    let quickhackDataEmpty: PlayerQuickhackData;
    let systemReplacementID: ItemID;
    let quickhackDataArray: array<PlayerQuickhackData> = player.GetCachedQuickHackList();
    if ArraySize(quickhackDataArray) > 0 {
      return quickhackDataArray;
    };
    systemReplacementID = EquipmentSystem.GetData(player).GetActiveItem(gamedataEquipmentArea.SystemReplacementCW);
    itemRecord = RPGManager.GetItemRecord(systemReplacementID);
    if EquipmentSystem.IsCyberdeckEquipped(player) {
      itemRecord.ObjectActions(actions);
      i = 0;
      while i < ArraySize(actions) {
        quickhackData = quickhackDataEmpty;
        quickhackData.actionRecord = actions[i];
        quickhackData.quality = itemRecord.Quality().Value();
        ArrayPush(quickhackDataArray, quickhackData);
        i += 1;
      };
      parts = ItemModificationSystem.GetAllSlots(player, systemReplacementID);
      i = 0;
      while i < ArraySize(parts) {
        ArrayClear(actions);
        itemRecord = RPGManager.GetItemRecord(parts[i].installedPart);
        if IsDefined(itemRecord) {
          itemRecord.ObjectActions(actions);
          i1 = 0;
          while i1 < ArraySize(actions) {
            if Equals(actions[i1].ObjectActionType().Type(), gamedataObjectActionType.DeviceQuickHack) || Equals(actions[i1].ObjectActionType().Type(), gamedataObjectActionType.PuppetQuickHack) {
              quickhackData = quickhackDataEmpty;
              quickhackData.actionRecord = actions[i1];
              quickhackData.quality = itemRecord.Quality().Value();
              ArrayPush(quickhackDataArray, quickhackData);
            };
            i1 += 1;
          };
        };
        i += 1;
      };
    };
    ArrayClear(actions);
    itemRecord = RPGManager.GetItemRecord(EquipmentSystem.GetData(player).GetActiveItem(gamedataEquipmentArea.Splinter));
    if IsDefined(itemRecord) {
      itemRecord.ObjectActions(actions);
      i = 0;
      while i < ArraySize(actions) {
        if Equals(actions[i].ObjectActionType().Type(), gamedataObjectActionType.DeviceQuickHack) || Equals(actions[i].ObjectActionType().Type(), gamedataObjectActionType.PuppetQuickHack) {
          quickhackData = quickhackDataEmpty;
          quickhackData.actionRecord = actions[i];
          ArrayPush(quickhackDataArray, quickhackData);
        };
        i += 1;
      };
    };
    RPGManager.RemoveDuplicatedHacks(quickhackDataArray);
    PlayerPuppet.ChacheQuickHackList(player, quickhackDataArray);
    return quickhackDataArray;
  }

  private final static func RemoveDuplicatedHacks(commands: script_ref<array<PlayerQuickhackData>>) -> Void {
    let i1: Int32;
    let indexesToRemove: array<Int32>;
    let i: Int32 = ArraySize(Deref(commands)) - 1;
    while i >= 0 {
      i1 = 0;
      while i1 < i {
        if Equals(Deref(commands)[i].actionRecord.ActionName(), Deref(commands)[i1].actionRecord.ActionName()) && Equals(Deref(commands)[i].actionRecord.ObjectActionType().Type(), Deref(commands)[i1].actionRecord.ObjectActionType().Type()) {
          if Deref(commands)[i].actionRecord.Priority() >= Deref(commands)[i1].actionRecord.Priority() {
            ArrayPush(indexesToRemove, i1);
          } else {
            ArrayPush(indexesToRemove, i);
          };
        };
        i1 += 1;
      };
      i -= 1;
    };
    i = 0;
    while i < ArraySize(indexesToRemove) {
      ArrayErase(Deref(commands), indexesToRemove[i]);
      i += 1;
    };
  }

  private final static func RemoveDuplicatedHacks(deck: script_ref<array<wref<ObjectAction_Record>>>, splinter: script_ref<array<wref<ObjectAction_Record>>>) -> Void {
    let i1: Int32;
    let i: Int32 = ArraySize(Deref(deck)) - 1;
    while i >= 0 {
      i1 = ArraySize(Deref(splinter)) - 1;
      while i1 >= 0 {
        if Equals(Deref(deck)[i].ActionName(), Deref(splinter)[i1].ActionName()) {
          if Deref(deck)[i].Priority() >= Deref(splinter)[i1].Priority() {
            ArrayErase(Deref(splinter), i1);
          } else {
            ArrayErase(Deref(deck), i);
          };
        };
        i1 -= 1;
      };
      i -= 1;
    };
  }

  public final static func GetPlayerCurrentHealthPercent(gi: GameInstance) -> Float {
    let player: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(gi).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if IsDefined(player) {
      return GameInstance.GetStatPoolsSystem(gi).GetStatPoolValue(Cast(player.GetEntityID()), gamedataStatPoolType.Health, true);
    };
    return -1.00;
  }

  public final static func GetStockItemRequirement(record: wref<VendorItem_Record>) -> SItemStackRequirementData {
    let data: SItemStackRequirementData;
    let statPrereq: ref<StatPrereq_Record> = record.AvailabilityPrereq() as StatPrereq_Record;
    if IsDefined(statPrereq) {
      data.statType = IntEnum(Cast(EnumValueFromName(n"gamedataStatType", statPrereq.StatType())));
      data.requiredValue = statPrereq.ValueToCheck();
    } else {
      data.statType = gamedataStatType.Invalid;
      data.requiredValue = -1.00;
    };
    return data;
  }

  public final static func HealPuppetAfterQuickhack(gi: GameInstance, executor: ref<GameObject>) -> Void {
    let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(gi);
    if statSystem.GetStatBoolValue(Cast((executor as ScriptedPuppet).GetEntityID()), gamedataStatType.CanQuickhackHealPuppet) {
      GameInstance.GetStatusEffectSystem(gi).ApplyStatusEffect((executor as ScriptedPuppet).GetEntityID(), t"BaseStatusEffect.QuickhackConsumableHealing");
    };
  }

  public final static func ForceEquipStrongArms(player: ref<PlayerPuppet>) -> Bool {
    let TS: ref<TransactionSystem>;
    let armsCW: ItemID;
    let record: ref<WeaponItem_Record>;
    if !IsDefined(player) {
      return false;
    };
    TS = GameInstance.GetTransactionSystem(player.GetGame());
    armsCW = EquipmentSystem.GetData(player).GetActiveItem(gamedataEquipmentArea.ArmsCW);
    if !IsDefined(TS) || !ItemID.IsValid(armsCW) {
      return false;
    };
    record = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(armsCW));
    if IsDefined(record) && Equals(record.ItemType().Type(), gamedataItemType.Cyb_StrongArms) {
      if TS.IsSlotEmpty(player, t"AttachmentSlots.WeaponRight") && !TS.IsSlotEmpty(player, t"AttachmentSlots.RightArm") {
        TS.RemoveItemFromSlot(player, t"AttachmentSlots.RightArm");
        TS.AddItemToSlot(player, t"AttachmentSlots.RightArm", armsCW);
        return true;
      };
    };
    return false;
  }

  public final static func ForceUnequipStrongArms(player: ref<PlayerPuppet>) -> Bool {
    let TS: ref<TransactionSystem>;
    let armsCW: ItemID;
    let record: ref<WeaponItem_Record>;
    if !IsDefined(player) {
      return false;
    };
    TS = GameInstance.GetTransactionSystem(player.GetGame());
    armsCW = EquipmentSystem.GetData(player).GetActiveItem(gamedataEquipmentArea.ArmsCW);
    if !IsDefined(TS) || !ItemID.IsValid(armsCW) {
      return false;
    };
    record = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(armsCW));
    if IsDefined(record) && Equals(record.ItemType().Type(), gamedataItemType.Cyb_StrongArms) {
      armsCW = ItemID.CreateQuery(record.HolsteredItem().GetID());
      if ItemID.IsValid(armsCW) {
        TS.RemoveItemFromSlot(player, t"AttachmentSlots.RightArm");
        TS.AddItemToSlot(player, t"AttachmentSlots.RightArm", armsCW);
        return true;
      };
    };
    return false;
  }

  public final static func ForceEquipPersonalLink(player: ref<PlayerPuppet>) -> Bool {
    let TS: ref<TransactionSystem>;
    let itemID: ItemID;
    if !IsDefined(player) {
      return false;
    };
    TS = GameInstance.GetTransactionSystem(player.GetGame());
    itemID = ItemID.CreateQuery(t"Items.personal_link");
    if !IsDefined(TS) || !ItemID.IsValid(itemID) {
      return false;
    };
    if !TS.HasItem(player, itemID) {
      TS.GiveItem(player, itemID, 1);
    };
    TS.RemoveItemFromSlot(player, t"AttachmentSlots.PersonalLink");
    TS.AddItemToSlot(player, t"AttachmentSlots.PersonalLink", itemID);
    return true;
  }

  public final static func ForceUnequipPersonalLink(player: ref<PlayerPuppet>) -> Bool {
    let TS: ref<TransactionSystem>;
    if !IsDefined(player) {
      return false;
    };
    TS = GameInstance.GetTransactionSystem(player.GetGame());
    if !IsDefined(TS) {
      return false;
    };
    TS.RemoveItemFromSlot(player, t"AttachmentSlots.PersonalLink");
    return true;
  }
}

public abstract class MathHelper extends IScriptable {

  public final static func PositiveInfinity() -> Float {
    return 100000000.00;
  }

  public final static func NegativeInfinity() -> Float {
    return -100000000.00;
  }

  public final static func EulerNumber() -> Float {
    return 2.72;
  }

  public final static func IsFloatInRange(value: Float, min: Float, max: Float, opt leftClosed: Bool, opt rightClosed: Bool) -> Bool {
    if leftClosed && rightClosed {
      return value >= min && value <= max;
    };
    if leftClosed && !rightClosed {
      return value >= min && value < max;
    };
    if !leftClosed && rightClosed {
      return value > min && value <= max;
    };
    return value > min && value < max;
  }

  public final static func NormalizeF(value: Float, min: Float, max: Float) -> Float {
    let numerator: Float = value - min;
    let denominator: Float = max - min;
    return numerator / denominator;
  }

  public final static func RandFromNormalDist(opt mean: Float, opt stdDev: Float) -> Float {
    let output: Float;
    let randStandardNormal: Float;
    let uniform1: Float;
    let uniform2: Float;
    if stdDev == 0.00 {
      stdDev = 1.00;
    };
    uniform1 = RandF();
    uniform2 = RandF();
    randStandardNormal = SqrtF(-2.00 * LogF(uniform1)) * CosF(2.00 * Pi() * uniform2);
    output = randStandardNormal * stdDev + mean;
    return output;
  }
}

public class StatusEffectTriggerListener extends CustomValueStatPoolsListener {

  public let m_owner: wref<GameObject>;

  public let m_statusEffect: TweakDBID;

  public let m_statPoolType: gamedataStatPoolType;

  public let m_instigator: wref<GameObject>;

  protected cb func OnStatPoolMinValueReached(value: Float) -> Bool {
    let gameInstance: GameInstance;
    let puppet: ref<ScriptedPuppet> = this.m_owner as ScriptedPuppet;
    if IsDefined(puppet) {
      gameInstance = puppet.GetGame();
      GameInstance.GetStatusEffectSystem(gameInstance).ApplyStatusEffect(puppet.GetEntityID(), this.m_statusEffect, GameObject.GetTDBID(this.m_instigator), this.m_instigator.GetEntityID());
      GameInstance.GetStatPoolsSystem(gameInstance).RequestRemovingStatPool(Cast(puppet.GetEntityID()), this.m_statPoolType);
      GameObject.RemoveStatusEffectTriggerListener(puppet, this);
    };
  }
}

public class PhoneCallUploadDurationListener extends CustomValueStatPoolsListener {

  public let m_gameInstance: GameInstance;

  public let m_requesterPuppet: wref<ScriptedPuppet>;

  public let m_requesterID: EntityID;

  public let m_duration: Float;

  @default(PhoneCallUploadDurationListener, gamedataStatPoolType.PhoneCallDuration)
  public let m_statPoolType: gamedataStatPoolType;

  protected cb func OnStatPoolAdded() -> Bool {
    this.SendUploadStartedEvent();
    this.SetRegenBehavior();
  }

  protected func SetRegenBehavior() -> Void {
    let regenMod: StatPoolModifier;
    let activationTime: Float = this.m_duration;
    regenMod.enabled = true;
    regenMod.valuePerSec = 100.00 / activationTime;
    regenMod.rangeEnd = 100.00;
    GameInstance.GetStatPoolsSystem(this.m_gameInstance).RequestSettingModifier(Cast(this.m_requesterID), this.m_statPoolType, gameStatPoolModificationTypes.Regeneration, regenMod);
  }

  protected cb func OnStatPoolRemoved() -> Bool {
    this.SendUploadFinishedEvent();
    this.UnregisterListener();
  }

  protected cb func OnStatPoolMaxValueReached(value: Float) -> Bool {
    if Equals(this.m_statPoolType, gamedataStatPoolType.CallReinforcementProgress) {
      this.m_requesterPuppet.GetPuppetStateBlackboard().SetBool(GetAllBlackboardDefs().PuppetState.HasCalledReinforcements, true);
    };
    this.SendUploadFinishedEvent();
    this.UnregisterListener();
  }

  private final func UnregisterListener() -> Void {
    GameInstance.GetStatPoolsSystem(this.m_gameInstance).RequestUnregisteringListener(Cast(this.m_requesterID), this.m_statPoolType, this);
  }

  private final func SendUploadStartedEvent() -> Void {
    let evt: ref<UploadProgramProgressEvent> = new UploadProgramProgressEvent();
    evt.state = EUploadProgramState.STARTED;
    evt.duration = this.m_duration;
    evt.progressBarType = EProgressBarType.UPLOAD;
    evt.progressBarContext = EProgressBarContext.PhoneCall;
    evt.iconRecord = TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.PhoneCall");
    evt.statPoolType = this.m_statPoolType;
    GameInstance.GetPersistencySystem(this.m_gameInstance).QueueEntityEvent(this.m_requesterID, evt);
  }

  protected final func SendUploadFinishedEvent() -> Void {
    let evt: ref<UploadProgramProgressEvent> = new UploadProgramProgressEvent();
    evt.state = EUploadProgramState.COMPLETED;
    evt.progressBarContext = EProgressBarContext.PhoneCall;
    evt.statPoolType = this.m_statPoolType;
    GameInstance.GetPersistencySystem(this.m_gameInstance).QueueEntityEvent(this.m_requesterID, evt);
  }
}

public class QuickHackDurationListener extends ActionUploadListener {

  protected cb func OnStatPoolAdded() -> Bool {
    this.SendUploadStartedEvent(this.m_action);
    this.SetRegenBehavior();
  }

  protected func SetRegenBehavior() -> Void {
    let regenMod: StatPoolModifier;
    let activationTime: Float = this.m_action.GetDurationValue();
    regenMod.enabled = true;
    regenMod.valuePerSec = 100.00 / activationTime;
    regenMod.rangeEnd = 100.00;
    GameInstance.GetStatPoolsSystem(this.m_gameInstance).RequestSettingModifier(Cast(this.m_action.GetRequesterID()), gamedataStatPoolType.QuickHackDuration, gameStatPoolModificationTypes.Regeneration, regenMod);
  }

  protected cb func OnStatPoolMaxValueReached(value: Float) -> Bool {
    this.m_action.CompleteAction(this.m_gameInstance);
    GameInstance.GetStatPoolsSystem(this.m_gameInstance).RequestRemovingStatPool(Cast(this.m_action.GetRequesterID()), gamedataStatPoolType.QuickHackDuration);
    GameInstance.GetStatPoolsSystem(this.m_gameInstance).RequestUnregisteringListener(Cast(this.m_action.GetRequesterID()), gamedataStatPoolType.QuickHackDuration, this);
    this.SendUploadFinishedEvent();
  }

  protected func SendUploadStartedEvent(action: ref<ScriptableDeviceAction>) -> Void {
    let evt: ref<UploadProgramProgressEvent> = new UploadProgramProgressEvent();
    let uploadDuration: Float = this.m_action.GetDurationValue();
    evt.state = EUploadProgramState.STARTED;
    evt.duration = uploadDuration;
    evt.progressBarType = EProgressBarType.DURATION;
    evt.action = action;
    evt.iconRecord = action.GetInteractionIcon();
    evt.statPoolType = gamedataStatPoolType.QuickHackDuration;
    GameInstance.GetPersistencySystem(this.m_gameInstance).QueueEntityEvent(this.m_action.GetRequesterID(), evt);
  }

  protected final func SendUploadFinishedEvent() -> Void {
    let evt: ref<UploadProgramProgressEvent> = new UploadProgramProgressEvent();
    evt.state = EUploadProgramState.COMPLETED;
    evt.statPoolType = gamedataStatPoolType.QuickHackDuration;
    GameInstance.GetPersistencySystem(this.m_gameInstance).QueueEntityEvent(this.m_action.GetRequesterID(), evt);
  }
}

public class QuickHackUploadListener extends ActionUploadListener {

  protected cb func OnStatPoolAdded() -> Bool {
    if this.m_action.IsQuickHack() {
      this.SendUploadStartedEvent(this.m_action);
      this.PlayQuickHackSound(n"ui_focus_mode_scanning_qh");
    };
    this.SetRegenBehavior();
  }

  protected func SetRegenBehavior() -> Void {
    let regenMod: StatPoolModifier;
    let activationTime: Float = this.m_action.GetActivationTime();
    regenMod.enabled = true;
    regenMod.valuePerSec = 100.00 / activationTime;
    regenMod.rangeEnd = 100.00;
    GameInstance.GetStatPoolsSystem(this.m_gameInstance).RequestSettingModifier(Cast(this.m_action.GetRequesterID()), gamedataStatPoolType.QuickHackUpload, gameStatPoolModificationTypes.Regeneration, regenMod);
  }

  protected cb func OnStatPoolMaxValueReached(value: Float) -> Bool {
    this.m_action.CompleteAction(this.m_gameInstance);
    GameInstance.GetStatPoolsSystem(this.m_gameInstance).RequestRemovingStatPool(Cast(this.m_action.GetRequesterID()), gamedataStatPoolType.QuickHackUpload);
    GameInstance.GetStatPoolsSystem(this.m_gameInstance).RequestUnregisteringListener(Cast(this.m_action.GetRequesterID()), gamedataStatPoolType.QuickHackUpload, this);
    if this.m_action.IsQuickHack() {
      this.SendUploadFinishedEvent();
    };
  }

  protected func SendUploadStartedEvent(action: ref<ScriptableDeviceAction>) -> Void {
    let evt: ref<UploadProgramProgressEvent> = new UploadProgramProgressEvent();
    let uploadDuration: Float = this.m_action.GetActivationTime();
    evt.state = EUploadProgramState.STARTED;
    evt.duration = uploadDuration;
    evt.progressBarType = EProgressBarType.UPLOAD;
    evt.action = action;
    evt.iconRecord = action.GetInteractionIcon();
    evt.statPoolType = gamedataStatPoolType.QuickHackUpload;
    GameInstance.GetPersistencySystem(this.m_gameInstance).QueueEntityEvent(this.m_action.GetRequesterID(), evt);
    if this.m_action.GetExecutor().IsPlayer() {
      this.IncrementQuickHackBlackboard();
    };
    QuickhackModule.RequestRefreshQuickhackMenu(this.m_gameInstance, this.m_action.GetRequesterID());
  }

  protected final func SendUploadFinishedEvent() -> Void {
    let evt: ref<UploadProgramProgressEvent> = new UploadProgramProgressEvent();
    evt.state = EUploadProgramState.COMPLETED;
    evt.statPoolType = gamedataStatPoolType.QuickHackUpload;
    GameInstance.GetPersistencySystem(this.m_gameInstance).QueueEntityEvent(this.m_action.GetRequesterID(), evt);
    this.PlayQuickHackSound(n"ui_focus_mode_scanning_qh_done");
    if this.m_action.GetExecutor().IsPlayer() {
      this.DecrementQuickHackBlackboard();
    };
  }

  protected final func PlayQuickHackSound(eventName: CName) -> Void {
    let flag: audioAudioEventFlags = audioAudioEventFlags.Unique;
    GameObject.PlaySoundEventWithParams(this.m_action.GetExecutor(), eventName, flag);
  }

  private final func IncrementQuickHackBlackboard() -> Void {
    let currValue: Int32;
    let playerBlackboard: ref<IBlackboard>;
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.m_gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if IsDefined(playerPuppet) {
      playerBlackboard = GameInstance.GetBlackboardSystem(this.m_gameInstance).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      currValue = playerBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.IsUploadingQuickHack);
      playerBlackboard.SetInt(GetAllBlackboardDefs().PlayerStateMachine.IsUploadingQuickHack, currValue + 1);
    };
  }

  private final func DecrementQuickHackBlackboard() -> Void {
    let currValue: Int32;
    let playerBlackboard: ref<IBlackboard>;
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.m_gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if IsDefined(playerPuppet) {
      playerBlackboard = GameInstance.GetBlackboardSystem(this.m_gameInstance).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      currValue = playerBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.IsUploadingQuickHack);
      playerBlackboard.SetInt(GetAllBlackboardDefs().PlayerStateMachine.IsUploadingQuickHack, currValue - 1);
    };
  }

  protected final func RemoveLink(owner: wref<ScriptedPuppet>) -> Void {
    let evt: ref<RemoveLinkEvent>;
    if !IsDefined(owner) {
      return;
    };
    evt = new RemoveLinkEvent();
    owner.QueueEvent(evt);
  }

  protected final func RemoveLinkedStatusEffects(owner: wref<ScriptedPuppet>, opt ssAction: Bool) -> Void {
    let evt: ref<RemoveLinkedStatusEffectsEvent>;
    if !IsDefined(owner) {
      return;
    };
    evt = new RemoveLinkedStatusEffectsEvent();
    evt.ssAction = ssAction;
    owner.QueueEvent(evt);
  }
}

public class UploadFromNPCToNPCListener extends QuickHackUploadListener {

  public let m_npcPuppet: wref<ScriptedPuppet>;

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    let uploadEvent: ref<UploadProgramProgressEvent>;
    if !ScriptedPuppet.IsActive(this.m_npcPuppet) {
      this.RemoveLinkedStatusEffects(this.m_npcPuppet);
      GameInstance.GetStatPoolsSystem(this.m_gameInstance).RequestRemovingStatPool(Cast(this.m_action.GetRequesterID()), gamedataStatPoolType.QuickHackUpload);
      GameInstance.GetStatPoolsSystem(this.m_gameInstance).RequestUnregisteringListener(Cast(this.m_action.GetRequesterID()), gamedataStatPoolType.QuickHackUpload, this);
      uploadEvent = new UploadProgramProgressEvent();
      uploadEvent.state = EUploadProgramState.COMPLETED;
      GameInstance.GetPersistencySystem(this.m_gameInstance).QueueEntityEvent(this.m_action.GetRequesterID(), uploadEvent);
    };
  }
}

public class UploadFromNPCToPlayerListener extends QuickHackUploadListener {

  public let m_playerPuppet: wref<ScriptedPuppet>;

  public let m_npcPuppet: wref<ScriptedPuppet>;

  public let m_npcSquad: array<EntityID>;

  public let m_variantHud: HUDProgressBarData;

  public let m_hudBlackboard: wref<IBlackboard>;

  private let m_ssAction: Bool;

  protected cb func OnStatPoolAdded() -> Bool {
    if this.m_action.GetObjectActionID() == t"AIQuickHack.HackRevealPosition" {
      this.m_ssAction = true;
      AISquadHelper.GetSquadmatesID(this.m_npcPuppet, this.m_npcSquad);
    };
    this.SendUploadStartedEvent(this.m_action);
  }

  protected func SendUploadStartedEvent(action: ref<ScriptableDeviceAction>) -> Void {
    this.m_variantHud.active = true;
    this.m_variantHud.header = LocKeyToString(action.GetObjectActionRecord().ObjectActionUI().Caption());
    this.m_hudBlackboard = GameInstance.GetBlackboardSystem(this.m_gameInstance).Get(GetAllBlackboardDefs().UI_HUDProgressBar);
    this.m_hudBlackboard.SetBool(GetAllBlackboardDefs().UI_HUDProgressBar.Active, this.m_variantHud.active);
    this.m_hudBlackboard.SetString(GetAllBlackboardDefs().UI_HUDProgressBar.Header, this.m_variantHud.header);
  }

  protected cb func OnStatPoolMaxValueReached(value: Float) -> Bool {
    let actionEffects: array<wref<ObjectActionEffect_Record>>;
    let targetTracker: wref<TargetTrackingExtension>;
    super.OnStatPoolMaxValueReached(value);
    this.RemoveLink(this.m_npcPuppet);
    ScriptedPuppet.SendActionSignal(this.m_npcPuppet, n"HackingCompleted", 1.00);
    this.m_variantHud.active = false;
    this.m_hudBlackboard.SetBool(GetAllBlackboardDefs().UI_HUDProgressBar.Active, this.m_variantHud.active);
    this.m_action.GetObjectActionRecord().CompletionEffects(actionEffects);
    this.m_npcPuppet.AddLinkedStatusEffect(this.m_npcPuppet.GetEntityID(), this.m_playerPuppet.GetEntityID(), actionEffects);
    this.m_playerPuppet.AddLinkedStatusEffect(this.m_npcPuppet.GetEntityID(), this.m_playerPuppet.GetEntityID(), actionEffects);
    if this.m_ssAction {
      this.m_playerPuppet.RemoveLinkedStatusEffects(true);
      if !TargetTrackingExtension.Get(GameInstance.FindEntityByID(this.m_playerPuppet.GetGame(), this.m_npcSquad[0]) as ScriptedPuppet, targetTracker) {
        if !TargetTrackingExtension.Get(this.m_npcPuppet, targetTracker) {
          return false;
        };
      };
      if AIActionHelper.TryChangingAttitudeToHostile(this.m_npcPuppet, this.m_playerPuppet) {
        targetTracker.AddThreat(this.m_playerPuppet, true, this.m_playerPuppet.GetWorldPosition(), 1.00, -1.00, false);
        this.m_npcPuppet.TriggerSecuritySystemNotification(this.m_playerPuppet.GetWorldPosition(), this.m_playerPuppet, ESecurityNotificationType.COMBAT);
      };
    };
  }

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    let evt: ref<UploadProgramProgressEvent>;
    let immune: Bool;
    let securitySystem: ref<SecuritySystemControllerPS>;
    let securitySystemState: ESecuritySystemState;
    let statValue: Float = GameInstance.GetStatsSystem(this.m_playerPuppet.GetGame()).GetStatValue(Cast(this.m_playerPuppet.GetEntityID()), gamedataStatType.QuickhackShield);
    this.m_variantHud.progress = newValue / 100.00;
    this.m_hudBlackboard.SetFloat(GetAllBlackboardDefs().UI_HUDProgressBar.Progress, this.m_variantHud.progress);
    if newValue > 15.00 && statValue > 0.00 && !StatusEffectSystem.ObjectHasStatusEffect(this.m_playerPuppet, t"BaseStatusEffect.AntiVirusCooldown") {
      StatusEffectHelper.ApplyStatusEffect(this.m_playerPuppet, t"BaseStatusEffect.AntiVirusCooldown");
      immune = true;
    };
    securitySystem = this.m_npcPuppet.GetSecuritySystem();
    securitySystemState = securitySystem.GetSecurityState();
    if this.m_ssAction && (Equals(securitySystemState, ESecuritySystemState.ALERTED) || Equals(securitySystemState, ESecuritySystemState.COMBAT)) {
      return;
    };
    if !this.m_ssAction && (!ScriptedPuppet.IsActive(this.m_npcPuppet) || !ScriptedPuppet.IsActive(this.m_playerPuppet) || StatusEffectSystem.ObjectHasStatusEffect(this.m_npcPuppet, t"AIQuickHackStatusEffect.HackingInterrupted") || StatusEffectSystem.ObjectHasStatusEffect(this.m_npcPuppet, t"BaseStatusEffect.CyberwareMalfunction") || StatusEffectSystem.ObjectHasStatusEffect(this.m_npcPuppet, t"BaseStatusEffect.CyberwareMalfunctionLvl2") || StatusEffectSystem.ObjectHasStatusEffect(this.m_npcPuppet, t"BaseStatusEffect.CyberwareMalfunctionLvl3") || immune) {
      immune = false;
      this.RemoveLinkedStatusEffects(this.m_npcPuppet, this.m_ssAction);
      this.m_variantHud.active = false;
      this.m_hudBlackboard.SetBool(GetAllBlackboardDefs().UI_HUDProgressBar.Active, this.m_variantHud.active);
      GameInstance.GetStatPoolsSystem(this.m_gameInstance).RequestRemovingStatPool(Cast(this.m_action.GetRequesterID()), gamedataStatPoolType.QuickHackUpload);
      GameInstance.GetStatPoolsSystem(this.m_gameInstance).RequestUnregisteringListener(Cast(this.m_action.GetRequesterID()), gamedataStatPoolType.QuickHackUpload, this);
      evt = new UploadProgramProgressEvent();
      evt.state = EUploadProgramState.COMPLETED;
      GameInstance.GetPersistencySystem(this.m_gameInstance).QueueEntityEvent(this.m_action.GetRequesterID(), evt);
    };
  }
}

public static func OperatorGreater(q1: gamedataQuality, q2: gamedataQuality) -> Bool {
  let result: Bool;
  if Equals(q1, gamedataQuality.Invalid) || Equals(q1, gamedataQuality.Count) || Equals(q2, gamedataQuality.Invalid) || Equals(q2, gamedataQuality.Count) {
    return false;
  };
  switch q1 {
    case gamedataQuality.Common:
      return false;
    case gamedataQuality.Uncommon:
      result = Equals(q2, gamedataQuality.Common) ? true : false;
      break;
    case gamedataQuality.Rare:
      result = Equals(q2, gamedataQuality.Common) || Equals(q2, gamedataQuality.Uncommon) ? true : false;
      break;
    case gamedataQuality.Epic:
      result = Equals(q2, gamedataQuality.Common) || Equals(q2, gamedataQuality.Uncommon) || Equals(q2, gamedataQuality.Rare) ? true : false;
      break;
    case gamedataQuality.Legendary:
      result = Equals(q2, gamedataQuality.Common) || Equals(q2, gamedataQuality.Uncommon) || Equals(q2, gamedataQuality.Rare) || Equals(q2, gamedataQuality.Epic) ? true : false;
      break;
    default:
      return false;
  };
  return result;
}

public static func OperatorGreaterEqual(q1: gamedataQuality, q2: gamedataQuality) -> Bool {
  let result: Bool;
  if Equals(q1, gamedataQuality.Invalid) || Equals(q1, gamedataQuality.Count) || Equals(q2, gamedataQuality.Invalid) || Equals(q2, gamedataQuality.Count) {
    return false;
  };
  switch q1 {
    case gamedataQuality.Common:
      result = Equals(q2, gamedataQuality.Common) ? true : false;
      break;
    case gamedataQuality.Uncommon:
      result = Equals(q2, gamedataQuality.Common) || Equals(q2, gamedataQuality.Uncommon) ? true : false;
      break;
    case gamedataQuality.Rare:
      result = Equals(q2, gamedataQuality.Common) || Equals(q2, gamedataQuality.Uncommon) || Equals(q2, gamedataQuality.Rare) ? true : false;
      break;
    case gamedataQuality.Epic:
      result = Equals(q2, gamedataQuality.Common) || Equals(q2, gamedataQuality.Uncommon) || Equals(q2, gamedataQuality.Rare) || Equals(q2, gamedataQuality.Epic) ? true : false;
      break;
    case gamedataQuality.Legendary:
      result = Equals(q2, gamedataQuality.Common) || Equals(q2, gamedataQuality.Uncommon) || Equals(q2, gamedataQuality.Rare) || Equals(q2, gamedataQuality.Epic) || Equals(q2, gamedataQuality.Legendary) ? true : false;
      break;
    default:
      return false;
  };
  return result;
}

public static func OperatorLess(q1: gamedataQuality, q2: gamedataQuality) -> Bool {
  let result: Bool;
  if Equals(q1, gamedataQuality.Invalid) || Equals(q1, gamedataQuality.Count) || Equals(q2, gamedataQuality.Invalid) || Equals(q2, gamedataQuality.Count) {
    return false;
  };
  switch q2 {
    case gamedataQuality.Common:
      return false;
    case gamedataQuality.Uncommon:
      result = Equals(q1, gamedataQuality.Common) ? true : false;
      break;
    case gamedataQuality.Rare:
      result = Equals(q1, gamedataQuality.Common) || Equals(q1, gamedataQuality.Uncommon) ? true : false;
      break;
    case gamedataQuality.Epic:
      result = Equals(q1, gamedataQuality.Common) || Equals(q1, gamedataQuality.Uncommon) || Equals(q1, gamedataQuality.Rare) ? true : false;
      break;
    case gamedataQuality.Legendary:
      result = Equals(q1, gamedataQuality.Common) || Equals(q1, gamedataQuality.Uncommon) || Equals(q1, gamedataQuality.Rare) || Equals(q1, gamedataQuality.Epic) ? true : false;
      break;
    default:
      return false;
  };
  return result;
}

public static func OperatorLessEqual(q1: gamedataQuality, q2: gamedataQuality) -> Bool {
  let result: Bool;
  if Equals(q1, gamedataQuality.Invalid) || Equals(q1, gamedataQuality.Count) || Equals(q2, gamedataQuality.Invalid) || Equals(q2, gamedataQuality.Count) {
    return false;
  };
  switch q2 {
    case gamedataQuality.Common:
      result = Equals(q1, gamedataQuality.Common) ? true : false;
      break;
    case gamedataQuality.Uncommon:
      result = Equals(q1, gamedataQuality.Common) || Equals(q1, gamedataQuality.Uncommon) ? true : false;
      break;
    case gamedataQuality.Rare:
      result = Equals(q1, gamedataQuality.Common) || Equals(q1, gamedataQuality.Uncommon) || Equals(q1, gamedataQuality.Rare) ? true : false;
      break;
    case gamedataQuality.Epic:
      result = Equals(q1, gamedataQuality.Common) || Equals(q1, gamedataQuality.Uncommon) || Equals(q1, gamedataQuality.Rare) || Equals(q1, gamedataQuality.Epic) ? true : false;
      break;
    case gamedataQuality.Legendary:
      result = Equals(q1, gamedataQuality.Common) || Equals(q1, gamedataQuality.Uncommon) || Equals(q1, gamedataQuality.Rare) || Equals(q1, gamedataQuality.Epic) || Equals(q1, gamedataQuality.Legendary) ? true : false;
      break;
    default:
      return false;
  };
  return result;
}

public static exec func ApplyGLP(gameInstance: GameInstance, value: String) -> Void {
  let glpID: TweakDBID = TDBID.Create(value);
  let glpRecord: wref<GameplayLogicPackage_Record> = TweakDBInterface.GetGameplayLogicPackageRecord(glpID);
  if IsDefined(glpRecord) {
    RPGManager.ApplyGLP(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject(), glpRecord);
  };
}
