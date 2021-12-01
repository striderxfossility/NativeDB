
public class IDisplayData extends IScriptable {

  public func CreateTooltipData(manager: ref<PlayerDevelopmentDataManager>) -> ref<BasePerksMenuTooltipData> {
    return null;
  }
}

public class PerkDisplayData extends BasePerkDisplayData {

  public let m_area: gamedataPerkArea;

  public let m_type: gamedataPerkType;

  public func CreateTooltipData(manager: ref<PlayerDevelopmentDataManager>) -> ref<BasePerksMenuTooltipData> {
    let data: ref<PerkTooltipData> = new PerkTooltipData();
    data.manager = manager;
    data.perkType = this.m_type;
    data.perkArea = this.m_area;
    data.proficiency = this.m_proficiency;
    data.attributeId = this.m_attributeId;
    data.perkData = this;
    return data;
  }
}

public class TraitDisplayData extends BasePerkDisplayData {

  public let m_type: gamedataTraitType;

  public func CreateTooltipData(manager: ref<PlayerDevelopmentDataManager>) -> ref<BasePerksMenuTooltipData> {
    let data: ref<TraitTooltipData> = new TraitTooltipData();
    data.manager = manager;
    data.traitType = this.m_type;
    data.proficiency = this.m_proficiency;
    data.attributeId = this.m_attributeId;
    return data;
  }
}

public class ProficiencyDisplayData extends IDisplayData {

  public let m_attributeId: TweakDBID;

  public let m_proficiency: gamedataProficiencyType;

  public let m_index: Int32;

  public let m_areas: array<ref<AreaDisplayData>>;

  public let m_passiveBonusesData: array<ref<LevelRewardDisplayData>>;

  public let m_traitData: ref<TraitDisplayData>;

  public let m_localizedName: String;

  public let m_localizedDescription: String;

  public let m_level: Int32;

  public let m_maxLevel: Int32;

  public let m_expPoints: Int32;

  public let m_maxExpPoints: Int32;

  public let m_unlockedLevel: Int32;

  public func CreateTooltipData(manager: ref<PlayerDevelopmentDataManager>) -> ref<BasePerksMenuTooltipData> {
    let data: ref<SkillTooltipData> = new SkillTooltipData();
    data.manager = manager;
    data.proficiencyType = this.m_proficiency;
    data.attributeRecord = TweakDBInterface.GetAttributeRecord(this.m_attributeId);
    return data;
  }
}

public class AttributeDisplayData extends IDisplayData {

  public let m_attributeId: TweakDBID;

  public let m_proficiencies: array<ref<ProficiencyDisplayData>>;

  public func CreateTooltipData(manager: ref<PlayerDevelopmentDataManager>) -> ref<BasePerksMenuTooltipData> {
    let data: ref<AttributeTooltipData> = new AttributeTooltipData();
    data.manager = manager;
    data.attributeId = this.m_attributeId;
    data.attributeType = manager.GetAttributeEnumFromRecordID(this.m_attributeId);
    return data;
  }
}

public class AttributeData extends IDisplayData {

  public let label: String;

  public let icon: String;

  public let id: TweakDBID;

  public let value: Int32;

  public let maxValue: Int32;

  public let description: String;

  public let availableToUpgrade: Bool;

  public let type: gamedataStatType;

  public func CreateTooltipData(manager: ref<PlayerDevelopmentDataManager>) -> ref<BasePerksMenuTooltipData> {
    let data: ref<AttributeTooltipData> = new AttributeTooltipData();
    data.manager = manager;
    data.attributeId = this.id;
    data.attributeType = manager.GetAttributeEnumFromRecordID(this.id);
    return data;
  }
}

public class PlayerDevelopmentDataManager extends IScriptable {

  private let m_player: wref<PlayerPuppet>;

  private let m_playerDevSystem: ref<PlayerDevelopmentSystem>;

  private let m_parentGameCtrl: wref<inkGameController>;

  public final func Initialize(player: ref<PlayerPuppet>, parentGameCtrl: ref<inkGameController>) -> Void {
    this.m_parentGameCtrl = parentGameCtrl;
    this.m_player = player;
    this.m_playerDevSystem = PlayerDevelopmentSystem.GetInstance(player);
  }

  public final func GetPlayerDevelopmentSystem() -> wref<PlayerDevelopmentSystem> {
    return this.m_playerDevSystem;
  }

  public final func GetPlayerDevelopmentData() -> wref<PlayerDevelopmentData> {
    return PlayerDevelopmentSystem.GetData(this.m_player);
  }

  public final func GetPlayer() -> wref<PlayerPuppet> {
    return this.m_player;
  }

  public final func GetPerkDisplayData(perkType: gamedataPerkType, perkArea: gamedataPerkArea, proficiency: gamedataProficiencyType, attributeId: TweakDBID, opt playerDevelopmentData: wref<PlayerDevelopmentData>) -> ref<PerkDisplayData> {
    return this.GetPerkDisplayData(perkType, perkArea, proficiency, TweakDBInterface.GetAttributeRecord(attributeId), playerDevelopmentData);
  }

  public final func GetPerkDisplayData(perkType: gamedataPerkType, perkArea: gamedataPerkArea, proficiency: gamedataProficiencyType, attributeRecord: ref<Attribute_Record>, opt playerDevelopmentData: wref<PlayerDevelopmentData>) -> ref<PerkDisplayData> {
    let curPerkDisplayData: ref<PerkDisplayData>;
    let perkCurrLevel: Int32;
    let perkRecord: wref<Perk_Record>;
    if !IsDefined(playerDevelopmentData) {
      playerDevelopmentData = PlayerDevelopmentSystem.GetData(this.m_player);
    };
    perkRecord = playerDevelopmentData.GetPerkRecord(perkType);
    curPerkDisplayData = new PerkDisplayData();
    curPerkDisplayData.m_attributeId = attributeRecord.GetID();
    curPerkDisplayData.m_localizedName = GetLocalizedText(perkRecord.Loc_name_key());
    curPerkDisplayData.m_localizedDescription = GetLocalizedText(perkRecord.Loc_desc_key());
    curPerkDisplayData.m_binkRef = perkRecord.BinkPath();
    curPerkDisplayData.m_type = perkType;
    curPerkDisplayData.m_iconID = perkRecord.EnumName();
    curPerkDisplayData.m_locked = !playerDevelopmentData.IsPerkAreaUnlocked(perkArea);
    perkCurrLevel = this.m_playerDevSystem.GetPerkLevel(this.m_player, curPerkDisplayData.m_type);
    curPerkDisplayData.m_level = perkCurrLevel < 0 ? 0 : perkCurrLevel;
    curPerkDisplayData.m_maxLevel = this.m_playerDevSystem.GetPerkMaxLevel(this.m_player, curPerkDisplayData.m_type);
    curPerkDisplayData.m_proficiency = proficiency;
    curPerkDisplayData.m_area = perkArea;
    return curPerkDisplayData;
  }

  public final func GetTraitDisplayData(traitType: gamedataTraitType, attributeId: TweakDBID, proficiency: gamedataProficiencyType, opt playerDevelopmentData: wref<PlayerDevelopmentData>) -> ref<TraitDisplayData> {
    return this.GetTraitDisplayData(RPGManager.GetTraitRecord(traitType), TweakDBInterface.GetAttributeRecord(attributeId), proficiency, playerDevelopmentData);
  }

  public final func GetTraitDisplayData(traitRecordId: TweakDBID, attributeId: TweakDBID, proficiency: gamedataProficiencyType, opt playerDevelopmentData: wref<PlayerDevelopmentData>) -> ref<TraitDisplayData> {
    return this.GetTraitDisplayData(TweakDBInterface.GetTraitRecord(traitRecordId), TweakDBInterface.GetAttributeRecord(attributeId), proficiency, playerDevelopmentData);
  }

  public final func GetTraitDisplayData(traitRecord: wref<Trait_Record>, attributeRecord: ref<Attribute_Record>, proficiency: gamedataProficiencyType, opt playerDevelopmentData: wref<PlayerDevelopmentData>) -> ref<TraitDisplayData> {
    let traitData: ref<TraitDisplayData>;
    let traitType: gamedataTraitType;
    if !IsDefined(playerDevelopmentData) {
      playerDevelopmentData = PlayerDevelopmentSystem.GetData(this.m_player);
    };
    traitType = traitRecord.Type();
    traitData = new TraitDisplayData();
    traitData.m_attributeId = attributeRecord.GetID();
    traitData.m_localizedName = GetLocalizedText(traitRecord.Loc_name_key());
    traitData.m_localizedDescription = GetLocalizedText(traitRecord.Loc_desc_key());
    traitData.m_type = traitType;
    traitData.m_proficiency = proficiency;
    traitData.m_iconID = traitRecord.EnumName();
    traitData.m_locked = !playerDevelopmentData.IsTraitUnlocked(traitType);
    traitData.m_level = playerDevelopmentData.GetTraitLevel(traitType);
    traitData.m_maxLevel = -1;
    return traitData;
  }

  public final func GetAreaDisplayData(perkArea: gamedataPerkArea, proficiency: gamedataProficiencyType, attributeId: TweakDBID, opt playerDevelopmentData: wref<PlayerDevelopmentData>) -> ref<AreaDisplayData> {
    return this.GetAreaDisplayData(perkArea, proficiency, TweakDBInterface.GetAttributeRecord(attributeId), playerDevelopmentData);
  }

  public final func GetAreaDisplayData(perkArea: gamedataPerkArea, proficiency: gamedataProficiencyType, attributeRecord: ref<Attribute_Record>, opt playerDevelopmentData: wref<PlayerDevelopmentData>) -> ref<AreaDisplayData> {
    let curPerkAreaDisplayData: ref<AreaDisplayData>;
    if !IsDefined(playerDevelopmentData) {
      playerDevelopmentData = PlayerDevelopmentSystem.GetData(this.m_player);
    };
    curPerkAreaDisplayData = new AreaDisplayData();
    curPerkAreaDisplayData.m_attributeId = attributeRecord.GetID();
    curPerkAreaDisplayData.m_locked = !playerDevelopmentData.IsPerkAreaUnlocked(perkArea);
    curPerkAreaDisplayData.m_area = perkArea;
    curPerkAreaDisplayData.m_proficency = proficiency;
    return curPerkAreaDisplayData;
  }

  public final func GetProficiencyDisplayData(proficiency: gamedataProficiencyType, attributeId: TweakDBID) -> ref<ProficiencyDisplayData> {
    return this.GetProficiencyDisplayData(proficiency, TweakDBInterface.GetAttributeRecord(attributeId));
  }

  public final func GetProficiencyDisplayData(proficiency: gamedataProficiencyType, attributeRecord: ref<Attribute_Record>) -> ref<ProficiencyDisplayData> {
    let proficiencyRecord: ref<Proficiency_Record> = this.GetProficiencyRecord(proficiency);
    let attributeData: ref<AttributeData> = this.GetAttribute(attributeRecord.GetID());
    let curProfDisplayData: ref<ProficiencyDisplayData> = new ProficiencyDisplayData();
    curProfDisplayData.m_attributeId = attributeRecord.GetID();
    curProfDisplayData.m_proficiency = proficiency;
    curProfDisplayData.m_traitData = this.GetTraitDisplayData(proficiencyRecord.Trait(), attributeRecord, proficiency);
    curProfDisplayData.m_localizedName = GetLocalizedText(proficiencyRecord.Loc_name_key());
    curProfDisplayData.m_localizedDescription = GetLocalizedText(proficiencyRecord.Loc_desc_key());
    curProfDisplayData.m_level = this.m_playerDevSystem.GetProficiencyLevel(this.m_player, proficiency);
    curProfDisplayData.m_expPoints = this.m_playerDevSystem.GetCurrentLevelProficiencyExp(this.m_player, proficiency);
    curProfDisplayData.m_maxExpPoints = curProfDisplayData.m_expPoints + this.m_playerDevSystem.GetRemainingExpForLevelUp(this.m_player, proficiency);
    curProfDisplayData.m_maxLevel = this.m_playerDevSystem.GetProficiencyAbsoluteMaxLevel(this.m_player, proficiency);
    curProfDisplayData.m_unlockedLevel = attributeData.value;
    curProfDisplayData.m_passiveBonusesData = this.GetPassiveBonusDisplayData(proficiencyRecord);
    return curProfDisplayData;
  }

  public final func GetPassiveBonusDisplayData(proficiencyRecord: ref<Proficiency_Record>) -> array<ref<LevelRewardDisplayData>> {
    let bonusData: wref<PassiveProficiencyBonus_Record>;
    let bonusDisplay: ref<LevelRewardDisplayData>;
    let bonusesDisplay: array<ref<LevelRewardDisplayData>>;
    let bonusIndex: Int32 = 1;
    while bonusIndex < proficiencyRecord.GetPassiveBonusesCount() {
      bonusDisplay = new LevelRewardDisplayData();
      bonusData = proficiencyRecord.GetPassiveBonusesItem(bonusIndex);
      bonusDisplay.level = bonusIndex + 1;
      bonusDisplay.locPackage = UILocalizationDataPackage.FromPassiveUIDataPackage(bonusData.UiData());
      bonusDisplay.description = LocKeyToString(bonusData.UiData().Loc_name_key());
      ArrayPush(bonusesDisplay, bonusDisplay);
      bonusIndex += 1;
    };
    return bonusesDisplay;
  }

  private final func GetAttributeRecordFromProficiency(proficiency: gamedataProficiencyType) -> wref<Attribute_Record> {
    let attributeRecord: ref<Attribute_Record>;
    let j: Int32;
    let proficiencies: array<wref<Proficiency_Record>>;
    let playerDevelopmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    let attributes: array<SAttribute> = playerDevelopmentData.GetAttributes();
    let i: Int32 = 0;
    while i < ArraySize(attributes) {
      attributeRecord = playerDevelopmentData.GetAttributeRecord(attributes[i].attributeName) as Attribute_Record;
      attributeRecord.Proficiencies(proficiencies);
      j = 0;
      while j < ArraySize(proficiencies) {
        if Equals(proficiencies[j].Type(), proficiency) {
          return attributeRecord;
        };
        j += 1;
      };
      i += 1;
    };
    return null;
  }

  private final func GetProficiencyRecord(attributeRecord: wref<Attribute_Record>, proficiency: gamedataProficiencyType) -> wref<Proficiency_Record> {
    let i: Int32;
    let proficiencies: array<wref<Proficiency_Record>>;
    attributeRecord.Proficiencies(proficiencies);
    i = 0;
    while i < ArraySize(proficiencies) {
      if Equals(proficiencies[i].Type(), proficiency) {
        return proficiencies[i];
      };
      i += 1;
    };
    return null;
  }

  private final func GetProficiencyRecord(proficiency: gamedataProficiencyType) -> wref<Proficiency_Record> {
    let attributeRecord: ref<Attribute_Record>;
    let j: Int32;
    let proficiencies: array<wref<Proficiency_Record>>;
    let playerDevelopmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    let attributes: array<SAttribute> = playerDevelopmentData.GetAttributes();
    let i: Int32 = 0;
    while i < ArraySize(attributes) {
      attributeRecord = playerDevelopmentData.GetAttributeRecord(attributes[i].attributeName) as Attribute_Record;
      attributeRecord.Proficiencies(proficiencies);
      j = 0;
      while j < ArraySize(proficiencies) {
        if Equals(proficiencies[j].Type(), proficiency) {
          return proficiencies[j];
        };
        j += 1;
      };
      i += 1;
    };
    return null;
  }

  public final func GetProficiencyWithData(proficiency: gamedataProficiencyType) -> ref<ProficiencyDisplayData> {
    let curPerkArea: wref<PerkArea_Record>;
    let curPerkAreaDisplayData: ref<AreaDisplayData>;
    let curPerkDisplayData: ref<PerkDisplayData>;
    let perkIdx: Int32;
    let playerDevelopmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    let attributeRecord: ref<Attribute_Record> = this.GetAttributeRecordFromProficiency(proficiency);
    let curProficiency: wref<Proficiency_Record> = this.GetProficiencyRecord(attributeRecord, proficiency);
    let curProfDisplayData: ref<ProficiencyDisplayData> = this.GetProficiencyDisplayData(curProficiency.Type(), attributeRecord);
    let areaIdx: Int32 = 0;
    while areaIdx < curProficiency.GetPerkAreasCount() {
      curPerkArea = curProficiency.GetPerkAreasItem(areaIdx);
      curPerkAreaDisplayData = this.GetAreaDisplayData(curPerkArea.Type(), curProficiency.Type(), attributeRecord, playerDevelopmentData);
      ArrayPush(curProfDisplayData.m_areas, curPerkAreaDisplayData);
      perkIdx = 0;
      while perkIdx < curPerkArea.GetPerksCount() {
        curPerkDisplayData = this.GetPerkDisplayData(curPerkArea.GetPerksItem(perkIdx).Type(), curPerkArea.Type(), curProficiency.Type(), attributeRecord, playerDevelopmentData);
        ArrayPush(curPerkAreaDisplayData.m_perks, curPerkDisplayData);
        perkIdx += 1;
      };
      areaIdx += 1;
    };
    return curProfDisplayData;
  }

  public final func GetAttributeData(attributeId: TweakDBID) -> ref<AttributeDisplayData> {
    let areaIdx: Int32;
    let curPerkArea: wref<PerkArea_Record>;
    let curPerkAreaDisplayData: ref<AreaDisplayData>;
    let curPerkDisplayData: ref<PerkDisplayData>;
    let curProfDisplayData: ref<ProficiencyDisplayData>;
    let curProficiency: wref<Proficiency_Record>;
    let perkIdx: Int32;
    let playerDevelopmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    let attributeRecord: ref<Attribute_Record> = TweakDBInterface.GetAttributeRecord(attributeId);
    let attributeDisplayData: ref<AttributeDisplayData> = new AttributeDisplayData();
    attributeDisplayData.m_attributeId = attributeId;
    let profIdx: Int32 = 0;
    while profIdx < attributeRecord.GetProficienciesCount() {
      curProficiency = attributeRecord.GetProficienciesItem(profIdx);
      curProfDisplayData = this.GetProficiencyDisplayData(curProficiency.Type(), attributeRecord);
      areaIdx = 0;
      while areaIdx < curProficiency.GetPerkAreasCount() {
        curPerkArea = curProficiency.GetPerkAreasItem(areaIdx);
        curPerkAreaDisplayData = this.GetAreaDisplayData(curPerkArea.Type(), curProficiency.Type(), attributeRecord, playerDevelopmentData);
        perkIdx = 0;
        while perkIdx < curPerkArea.GetPerksCount() {
          curPerkDisplayData = this.GetPerkDisplayData(curPerkArea.GetPerksItem(perkIdx).Type(), curPerkArea.Type(), curProficiency.Type(), attributeRecord, playerDevelopmentData);
          ArrayPush(curPerkAreaDisplayData.m_perks, curPerkDisplayData);
          perkIdx += 1;
        };
        ArrayPush(curProfDisplayData.m_areas, curPerkAreaDisplayData);
        areaIdx += 1;
      };
      ArrayPush(attributeDisplayData.m_proficiencies, curProfDisplayData);
      profIdx += 1;
    };
    return attributeDisplayData;
  }

  public final func GetAttributes() -> array<ref<AttributeData>> {
    let attributeDataArray: array<ref<AttributeData>>;
    let outData: ref<AttributeData>;
    let sAttribute: SAttribute;
    let sAttributeData: array<SAttribute> = this.m_playerDevSystem.GetAttributes(this.m_player);
    let i: Int32 = 0;
    while i < ArraySize(sAttributeData) {
      sAttribute = sAttributeData[i];
      outData = new AttributeData();
      this.FillAttributeData(sAttribute, outData);
      ArrayPush(attributeDataArray, outData);
      i += 1;
    };
    return attributeDataArray;
  }

  public final func GetAttributeFromType(attributeType: gamedataStatType) -> ref<AttributeData> {
    let outData: ref<AttributeData>;
    let sAttributeData: array<SAttribute> = this.m_playerDevSystem.GetAttributes(this.m_player);
    let i: Int32 = 0;
    while i < ArraySize(sAttributeData) {
      if Equals(sAttributeData[i].attributeName, attributeType) {
        outData = new AttributeData();
        this.FillAttributeData(sAttributeData[i], outData);
      } else {
        i += 1;
      };
    };
    return outData;
  }

  public final func GetAttribute(attributeID: TweakDBID) -> ref<AttributeData> {
    let outData: ref<AttributeData>;
    let sAttributeData: array<SAttribute> = this.m_playerDevSystem.GetAttributes(this.m_player);
    let i: Int32 = 0;
    while i < ArraySize(sAttributeData) {
      if sAttributeData[i].id == attributeID {
        outData = new AttributeData();
        this.FillAttributeData(sAttributeData[i], outData);
      } else {
        i += 1;
      };
    };
    return outData;
  }

  public final func GetAttributeRecordIDFromEnum(attribute: PerkMenuAttribute) -> TweakDBID {
    switch attribute {
      case PerkMenuAttribute.Body:
        return TweakDBInterface.GetStatRecord(t"BaseStats.Strength").GetID();
      case PerkMenuAttribute.Reflex:
        return TweakDBInterface.GetStatRecord(t"BaseStats.Reflexes").GetID();
      case PerkMenuAttribute.Technical_Ability:
        return TweakDBInterface.GetStatRecord(t"BaseStats.TechnicalAbility").GetID();
      case PerkMenuAttribute.Cool:
        return TweakDBInterface.GetStatRecord(t"BaseStats.Cool").GetID();
      case PerkMenuAttribute.Intelligence:
        return TweakDBInterface.GetStatRecord(t"BaseStats.Intelligence").GetID();
    };
    return TDBID.undefined();
  }

  public final func GetAttributeEnumFromRecordID(recordID: TweakDBID) -> PerkMenuAttribute {
    if recordID == t"BaseStats.Strength" {
      return PerkMenuAttribute.Body;
    };
    if recordID == t"BaseStats.Reflexes" {
      return PerkMenuAttribute.Reflex;
    };
    if recordID == t"BaseStats.TechnicalAbility" {
      return PerkMenuAttribute.Technical_Ability;
    };
    if recordID == t"BaseStats.Cool" {
      return PerkMenuAttribute.Cool;
    };
    if recordID == t"BaseStats.Intelligence" {
      return PerkMenuAttribute.Intelligence;
    };
    return PerkMenuAttribute.Johnny;
  }

  private final func FillAttributeData(attribute: SAttribute, out outData: ref<AttributeData>) -> Void {
    outData.label = TweakDBInterface.GetStatRecord(TDBID.Create("BaseStats." + EnumValueToString("gamedataStatType", Cast(EnumInt(attribute.attributeName))))).LocalizedName();
    outData.value = attribute.value;
    outData.maxValue = 20;
    outData.id = attribute.id;
    outData.availableToUpgrade = outData.value < outData.maxValue;
    outData.type = attribute.attributeName;
    outData.description = TweakDBInterface.GetStatRecord(TDBID.Create("BaseStats." + EnumValueToString("gamedataStatType", Cast(EnumInt(attribute.attributeName))))).LocalizedDescription();
  }

  public final func GetSpentPerkPoints() -> Int32 {
    let devData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    return devData.GetSpentPerkPoints();
  }

  public final func GetSpentTraitPoints() -> Int32 {
    let devData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    return devData.GetSpentTraitPoints();
  }

  public final func GetTotalRespecCost() -> Int32 {
    let devData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    return devData.GetTotalRespecCost();
  }

  public final func CheckRespecCost() -> Bool {
    let devData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    return devData.CheckPlayerRespecCost();
  }

  public final func GetPerkPoints() -> Int32 {
    return this.m_playerDevSystem.GetDevPoints(this.m_player, gamedataDevelopmentPointType.Primary);
  }

  public final func GetAttributePoints() -> Int32 {
    return this.m_playerDevSystem.GetDevPoints(this.m_player, gamedataDevelopmentPointType.Attribute);
  }

  public final func GetPerkLevel(type: gamedataPerkType) -> Int32 {
    return this.m_playerDevSystem.GetPerkLevel(this.m_player, type);
  }

  public final static func PerkUtilityToString(utility: gamedataPerkUtility) -> String {
    switch utility {
      case gamedataPerkUtility.ActiveUtility:
        return GetLocalizedText("UI-ScriptExports-Active");
      case gamedataPerkUtility.PassiveUtility:
        return GetLocalizedText("UI-Tooltips-Passive");
      case gamedataPerkUtility.TriggeredUtility:
        return GetLocalizedText("UI-Tooltips-Trigger");
    };
  }

  private final func UpdateData() -> Void {
    let evt: ref<PlayerDevUpdateDataEvent> = new PlayerDevUpdateDataEvent();
    this.m_parentGameCtrl.QueueEvent(evt);
  }

  private final func NotifyAttributeUpdate(attributeId: TweakDBID) -> Void {
    let evt: ref<AttributeUpdatedEvent> = new AttributeUpdatedEvent();
    evt.attributeId = attributeId;
    this.m_parentGameCtrl.QueueEvent(evt);
  }

  public final func UpgradePerk(data: ref<PerkDisplayData>) -> Void {
    let request: ref<BuyPerk> = new BuyPerk();
    request.Set(this.m_player, data.m_type);
    this.m_playerDevSystem.QueueRequest(request);
    this.UpdateData();
  }

  public final func UpgradeTrait(data: ref<TraitDisplayData>) -> Void {
    let request: ref<IncreaseTraitLevel> = new IncreaseTraitLevel();
    request.Set(this.m_player, data.m_type);
    this.m_playerDevSystem.QueueRequest(request);
    this.UpdateData();
  }

  public final func UpgradeAttribute(data: ref<AttributeData>) -> Void {
    let refresh: ref<RefreshPerkAreas>;
    this.UpgradeAttribute(data.type);
    this.NotifyAttributeUpdate(data.id);
    refresh = new RefreshPerkAreas();
    refresh.owner = this.m_player;
    this.m_playerDevSystem.QueueRequest(refresh);
  }

  public final func UpgradeAttribute(type: gamedataStatType) -> Void {
    let request: ref<BuyAttribute> = new BuyAttribute();
    request.Set(this.m_player, type);
    this.m_playerDevSystem.QueueRequest(request);
    this.UpdateData();
  }

  public final func IsPerkUpgradeable(data: ref<BasePerkDisplayData>, opt showNotification: Bool) -> Bool {
    let notificationEvent: ref<UIMenuNotificationEvent>;
    let notificationType: UIMenuNotificationType;
    let isPerkUpgradeable: Bool = true;
    if this.GetPerkPoints() <= 0 {
      notificationType = UIMenuNotificationType.NoPerksPoints;
      isPerkUpgradeable = false;
    };
    if data.m_locked {
      notificationType = UIMenuNotificationType.PerksLocked;
      isPerkUpgradeable = false;
    };
    if data.m_maxLevel > -1 && data.m_level >= data.m_maxLevel {
      notificationType = UIMenuNotificationType.MaxLevelPerks;
      isPerkUpgradeable = false;
    };
    if !isPerkUpgradeable && showNotification {
      notificationEvent = new UIMenuNotificationEvent();
      notificationEvent.m_notificationType = notificationType;
      GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(notificationEvent);
    };
    return isPerkUpgradeable;
  }

  public final func HasAvailableAttributePoints(opt showNotification: Bool) -> Bool {
    let notificationEvent: ref<UIMenuNotificationEvent>;
    let points: Bool = this.GetAttributePoints() > 0;
    if !points && showNotification {
      notificationEvent = new UIMenuNotificationEvent();
      notificationEvent.m_notificationType = UIMenuNotificationType.NoAttributePoints;
      GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(notificationEvent);
    };
    return points;
  }
}
