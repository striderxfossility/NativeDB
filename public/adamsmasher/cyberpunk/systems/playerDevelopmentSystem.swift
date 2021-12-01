
public class PlayerDevelopmentData extends IScriptable {

  public let m_owner: wref<GameObject>;

  private persistent let m_ownerID: EntityID;

  private persistent let m_queuedCombatExp: array<SExperiencePoints>;

  private persistent let m_proficiencies: array<SProficiency>;

  private persistent let m_attributes: array<SAttribute>;

  private persistent let m_perkAreas: array<SPerkArea>;

  private persistent let m_traits: array<STrait>;

  private persistent let m_devPoints: array<SDevelopmentPoints>;

  private persistent let m_skillPrereqs: array<ref<SkillCheckPrereqState>>;

  private persistent let m_statPrereqs: array<ref<StatCheckPrereqState>>;

  private persistent let m_knownRecipes: array<ItemRecipe>;

  private persistent let m_highestCompletedMinigameLevel: Int32;

  @default(PlayerDevelopmentData, 1)
  private const let m_startingLevel: Int32;

  @default(PlayerDevelopmentData, 0)
  private const let m_startingExperience: Int32;

  private persistent let m_lifePath: gamedataLifePath;

  @default(PlayerDevelopmentData, true)
  private let m_displayActivityLog: Bool;

  public final func OnAttach() -> Void;

  public final func OnDetach() -> Void;

  public final func OnNewGame() -> Void {
    this.SetProficiencies();
    this.InitializePerkAreas();
    this.InitializeTraits();
    this.SetDevelopmentPoints();
    this.UpdateUIBB();
  }

  public final func OnRestored(gameInstance: GameInstance) -> Void {
    let i: Int32;
    let j: Int32;
    let shouldTraitUnlock: Bool;
    let statMod: ref<gameConstantStatModifierData>;
    let statSys: ref<StatsSystem>;
    let traitIndex: Int32;
    let traitType: gamedataTraitType;
    let type: gamedataProficiencyType;
    if !EntityID.IsDefined(this.m_ownerID) {
      this.m_owner = GetPlayer(gameInstance);
      this.m_ownerID = this.m_owner.GetEntityID();
    } else {
      this.m_owner = GameInstance.FindEntityByID(gameInstance, this.m_ownerID) as GameObject;
    };
    statSys = GameInstance.GetStatsSystem(gameInstance);
    i = 0;
    while i < ArraySize(this.m_proficiencies) {
      type = this.m_proficiencies[i].type;
      if this.GetRemainingExpForLevelUp(type) <= 0 {
        if this.CanGainNextProficiencyLevel(i) {
          this.ModifyProficiencyLevel(type);
          this.UpdateUIBB();
        };
      };
      this.AddProficiencyStat(this.m_proficiencies[i].type, this.m_proficiencies[i].currentLevel);
      this.m_proficiencies[i].maxLevel = this.GetProficiencyMaxLevel(this.m_proficiencies[i].type);
      this.m_proficiencies[i].isAtMaxLevel = this.m_proficiencies[i].maxLevel == this.m_proficiencies[i].currentLevel;
      this.m_proficiencies[i].expToLevel = this.GetRemainingExpForLevelUp(this.m_proficiencies[i].type);
      traitType = RPGManager.GetProficiencyRecord(type).Trait().Type();
      traitIndex = this.GetTraitIndex(traitType);
      if traitIndex >= 0 {
        shouldTraitUnlock = this.IsTraitReqMet(this.m_traits[traitIndex].type);
        if this.m_traits[traitIndex].unlocked && !shouldTraitUnlock {
          this.AddDevelopmentPoints(this.m_traits[traitIndex].currLevel, gamedataDevelopmentPointType.Primary);
          this.m_traits[traitIndex].currLevel = 0;
        };
        this.m_traits[traitIndex].unlocked = shouldTraitUnlock;
        if this.m_traits[traitIndex].unlocked {
          this.ActivateTraitBase(this.m_traits[traitIndex].type);
          this.EvaluateTraitInfiniteData(traitIndex);
        };
      };
      i += 1;
    };
    GameInstance.GetLevelAssignmentSystem(gameInstance).MarkPlayerLevelRestored();
    i = 0;
    while i < ArraySize(this.m_attributes) {
      statMod = new gameConstantStatModifierData();
      statMod.statType = this.m_attributes[i].attributeName;
      statMod.value = Cast(this.m_attributes[i].value);
      statMod.modifierType = gameStatModifierType.Additive;
      statSys.AddModifier(Cast(this.m_owner.GetEntityID()), statMod);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_perkAreas) {
      j = 0;
      while j < ArraySize(this.m_perkAreas[i].boughtPerks) {
        this.ActivatePerkLevelData(i, this.GetPerkIndex(this.m_perkAreas[i].boughtPerks[j].type));
        j += 1;
      };
      i += 1;
    };
  }

  public final func SetOwner(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    this.m_ownerID = owner.GetEntityID();
  }

  public final func GetOwner() -> wref<GameObject> {
    return this.m_owner;
  }

  public final func GetOwnerID() -> EntityID {
    return this.m_ownerID;
  }

  public final const func GetLifePath() -> gamedataLifePath {
    return this.m_lifePath;
  }

  public final const func GetProficiencyLevel(type: gamedataProficiencyType) -> Int32 {
    let profIndex: Int32 = this.GetProficiencyIndexByType(type);
    if profIndex >= 0 {
      return this.m_proficiencies[profIndex].currentLevel;
    };
    return -1;
  }

  public final const func GetProficiencyAbsoluteMaxLevel(type: gamedataProficiencyType) -> Int32 {
    return RPGManager.GetProficiencyRecord(type).MaxLevel();
  }

  public final const func GetCurrentLevelProficiencyExp(type: gamedataProficiencyType) -> Int32 {
    let profIndex: Int32 = this.GetProficiencyIndexByType(type);
    if profIndex >= 0 {
      return this.m_proficiencies[profIndex].currentExp;
    };
    return -1;
  }

  public final const func GetTotalProfExperience(type: gamedataProficiencyType) -> Int32 {
    let colName: CName;
    let curvName: CName;
    let i: Int32;
    let maxLvl: Int32;
    let totalExp: Int32;
    let statDataSys: ref<StatsDataSystem> = GameInstance.GetStatsDataSystem(this.m_owner.GetGame());
    let pIndex: Int32 = this.GetProficiencyIndexByType(type);
    if pIndex < 0 {
      LogDM("GetTotalProfExperience(): Given type doesn\'t exist! Return value equals -1 !");
      return -1;
    };
    this.GetProficiencyExpCurveNames(type, curvName, colName);
    if !IsNameValid(curvName) || !IsNameValid(colName) {
      LogDM("GetTotalProfExperience(): Empty curve name OR column name ! Return value equals - 1 !");
      return -1;
    };
    maxLvl = this.GetProficiencyMaxLevel(type);
    i = 0;
    while i <= maxLvl {
      totalExp += Cast(statDataSys.GetValueFromCurve(curvName, Cast(i), colName));
      i += 1;
    };
    return totalExp;
  }

  public final const func GetRemainingExpForLevelUp(type: gamedataProficiencyType) -> Int32 {
    let exp: Int32;
    let pIndex: Int32 = this.GetProficiencyIndexByType(type);
    if pIndex >= 0 {
      if !this.IsProficiencyMaxLvl(type) {
        exp = this.GetExperienceForNextLevel(type);
        return exp - this.m_proficiencies[pIndex].currentExp;
      };
      LogDM("GetRemainingExpForLevelUp(): Maximum level has been reached. Return value equals to -1 !");
      return -1;
    };
    LogDM("GetRemainingExpForLevelUp(): No proficiency has been found! Return value equals -1 !");
    return -1;
  }

  public final const func GetDominatingCombatProficiency() -> gamedataProficiencyType {
    let dominatingProf: gamedataProficiencyType;
    let highestLevel: Int32;
    let i: Int32;
    let profsToCheck: array<gamedataProficiencyType>;
    ArrayPush(profsToCheck, gamedataProficiencyType.Assault);
    ArrayPush(profsToCheck, gamedataProficiencyType.Gunslinger);
    ArrayPush(profsToCheck, gamedataProficiencyType.Kenjutsu);
    ArrayPush(profsToCheck, gamedataProficiencyType.Brawling);
    ArrayPush(profsToCheck, gamedataProficiencyType.Demolition);
    ArrayPush(profsToCheck, gamedataProficiencyType.Stealth);
    ArrayPush(profsToCheck, gamedataProficiencyType.CombatHacking);
    i = 0;
    while i < ArraySize(this.m_proficiencies) {
      if ArrayContains(profsToCheck, this.m_proficiencies[i].type) {
        if this.m_proficiencies[i].currentLevel > highestLevel {
          highestLevel = this.m_proficiencies[i].currentLevel;
          dominatingProf = this.m_proficiencies[i].type;
        };
      };
      i += 1;
    };
    return dominatingProf;
  }

  public final const func GetHighestCompletedMinigameLevel() -> Int32 {
    return this.m_highestCompletedMinigameLevel;
  }

  public final const func GetProficiencyRecordByIndex(index: Int32) -> ref<Proficiency_Record> {
    let type: gamedataProficiencyType = this.m_proficiencies[index].type;
    return TweakDBInterface.GetProficiencyRecord(TDBID.Create("Proficiencies." + EnumValueToString("gamedataProficiencyType", Cast(EnumInt(type)))));
  }

  private final func SetProficiencies() -> Void {
    let i: Int32;
    if ArraySize(this.m_proficiencies) == EnumInt(gamedataProficiencyType.Count) {
      LogDM(" All m_proficiencies are set!");
      return;
    };
    i = 0;
    while i < EnumInt(gamedataProficiencyType.Count) {
      if this.GetProficiencyIndexByType(IntEnum(i)) < 0 {
        this.AddProficiency(IntEnum(i));
      };
      i += 1;
    };
  }

  public final const func GetProficiencyIndexByType(type: gamedataProficiencyType) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_proficiencies) {
      if Equals(this.m_proficiencies[i].type, type) {
        return i;
      };
      i += 1;
    };
    LogDM("GetProficiencyIndexByType(): No proficiency found! Return value equals -1!");
    return -1;
  }

  private final const func ResetProficiencyLevel(type: gamedataProficiencyType) -> Void {
    let pIndex: Int32 = this.GetProficiencyIndexByType(type);
    if pIndex < 0 {
      LogDM("ResetProficiencyLevel(): Proficiency of given type doesn\'t exist!");
      return;
    };
    this.m_proficiencies[pIndex].currentLevel = this.m_startingLevel;
    this.m_proficiencies[pIndex].currentExp = this.m_startingExperience;
    this.RemoveProficiencyStat(type);
    this.AddProficiencyStat(type, this.m_startingLevel);
  }

  private final const func GetProficiencyMaxLevel(type: gamedataProficiencyType) -> Int32 {
    let absoluteMaxLevel: Int32;
    let attributeInt: Int32;
    let attributeMaxLevel: Int32;
    let attributeRec: ref<Stat_Record>;
    let attributeType: gamedataStatType;
    let attributeValue: Int32;
    let colName: CName;
    let curveSetName: CName;
    let proficiencyRec: ref<Proficiency_Record>;
    let pIndex: Int32 = this.GetProficiencyIndexByType(type);
    if pIndex < 0 {
      LogDM("GetProficiencyMaxLevel(): Proficiency of given type doesn\'t exist!! Return value equals -1 !!");
      return -1;
    };
    this.GetProficiencyExpCurveNames(type, curveSetName, colName);
    if Equals(curveSetName, n"") {
      LogDM("GetProficiencyMaxLevel: Curve name is empty ! return value equals -1 !");
      return -1;
    };
    proficiencyRec = RPGManager.GetProficiencyRecord(type);
    absoluteMaxLevel = proficiencyRec.MaxLevel();
    attributeRec = proficiencyRec.TiedAttribute();
    attributeInt = -1;
    if IsDefined(attributeRec) {
      attributeInt = Cast(EnumValueFromString("gamedataStatType", attributeRec.EnumName()));
    };
    if attributeInt >= 0 {
      attributeType = IntEnum(attributeInt);
      attributeValue = this.m_attributes[this.GetAttributeIndex(attributeType)].value;
      attributeMaxLevel = attributeValue;
      return Max(Min(absoluteMaxLevel, attributeMaxLevel), 1);
    };
    return absoluteMaxLevel;
  }

  private final const func GetProficiencyExpCurveNames(type: gamedataProficiencyType, out curvName: CName, out colName: CName) -> Void {
    let proficiencyRecord: wref<Proficiency_Record>;
    let pIndex: Int32 = this.GetProficiencyIndexByType(type);
    if pIndex < 0 {
      LogDM("GetProficiencyExpCurve(): Given proficiency type doesn\'t exist! Both names will be returned empty!");
      curvName = n"";
      return;
    };
    proficiencyRecord = RPGManager.GetProficiencyRecord(type);
    colName = proficiencyRecord.CurveName();
    curvName = proficiencyRecord.CurveSetName();
  }

  private final const func ModifyProficiencyLevel(type: gamedataProficiencyType) -> Void {
    let i: Int32 = this.GetProficiencyIndexByType(type);
    if i >= 0 {
      this.ModifyProficiencyLevel(i);
      this.EvaluateTrait(type);
    } else {
      LogDM("ModifyProficiencyLevel(): Given proficiency type doesn\'t exist !");
    };
  }

  private final const func ModifyProficiencyLevel(proficiencyIndex: Int32) -> Void {
    let Blackboard: ref<IBlackboard>;
    let effectTags: array<CName>;
    let effects: array<ref<StatusEffect>>;
    let i: Int32;
    let level: LevelUpData;
    let statusEffectSys: ref<StatusEffectSystem>;
    let levelIncrease: Int32 = 1;
    this.m_proficiencies[proficiencyIndex].currentLevel += levelIncrease;
    this.m_proficiencies[proficiencyIndex].currentExp = 0;
    this.m_proficiencies[proficiencyIndex].expToLevel = this.GetRemainingExpForLevelUp(this.m_proficiencies[proficiencyIndex].type);
    this.ModifyDevPoints(this.m_proficiencies[proficiencyIndex].type, this.m_proficiencies[proficiencyIndex].currentLevel);
    level.lvl = this.m_proficiencies[proficiencyIndex].currentLevel;
    level.type = this.m_proficiencies[proficiencyIndex].type;
    level.perkPoints = this.GetDevPoints(gamedataDevelopmentPointType.Primary);
    level.attributePoints = this.GetDevPoints(gamedataDevelopmentPointType.Attribute);
    this.AddProficiencyStat(this.m_proficiencies[proficiencyIndex].type, levelIncrease);
    this.ProcessProficiencyPassiveBonus(proficiencyIndex);
    Blackboard = GameInstance.GetBlackboardSystem(this.m_owner.GetGame()).Get(GetAllBlackboardDefs().UI_LevelUp);
    if IsDefined(Blackboard) && this.m_owner == GameInstance.GetPlayerSystem(this.m_owner.GetGame()).GetLocalPlayerMainGameObject() {
      Blackboard.SetVariant(GetAllBlackboardDefs().UI_LevelUp.level, ToVariant(level));
      Blackboard.SignalVariant(GetAllBlackboardDefs().UI_LevelUp.level);
    };
    this.SetAchievementProgress(proficiencyIndex);
    if this.m_proficiencies[proficiencyIndex].currentLevel == RPGManager.GetProficiencyRecord(this.m_proficiencies[proficiencyIndex].type).MaxLevel() {
      if Equals(this.m_proficiencies[proficiencyIndex].type, gamedataProficiencyType.StreetCred) {
        this.SendMaxStreetCredLevelReachedTrackingRequest();
      } else {
        if NotEquals(this.m_proficiencies[proficiencyIndex].type, gamedataProficiencyType.Level) {
          this.CheckSpecialistAchievement(proficiencyIndex);
        };
      };
    };
    if Equals(this.m_proficiencies[proficiencyIndex].type, gamedataProficiencyType.Level) {
      this.ProcessTutorialFacts();
      if Equals(GameInstance.GetStatsDataSystem(this.m_owner.GetGame()).GetDifficulty(), gameDifficulty.Story) {
        GameInstance.GetStatPoolsSystem(this.m_owner.GetGame()).RequestSettingStatPoolValue(Cast(this.m_owner.GetEntityID()), gamedataStatPoolType.Health, 100.00, this.m_owner);
        statusEffectSys = GameInstance.GetStatusEffectSystem(this.m_owner.GetGame());
        statusEffectSys.GetAppliedEffects(this.m_owner.GetEntityID(), effects);
        i = 0;
        while i < ArraySize(effects) {
          effectTags = effects[i].GetRecord().GameplayTags();
          if effects[i].GetRemainingDuration() > 0.00 && ArrayContains(effectTags, n"Debuff") {
            statusEffectSys.RemoveStatusEffect(this.m_owner.GetEntityID(), effects[i].GetRecord().GetID(), effects[i].GetStackCount());
          };
          i += 1;
        };
      };
    };
  }

  private final const func ProcessTutorialFacts() -> Void {
    let questSys: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_owner.GetGame());
    if questSys.GetFact(n"levelup_tutorial") == 0 && questSys.GetFact(n"disable_tutorials") == 0 {
      questSys.SetFact(n"levelup_tutorial", 1);
    };
  }

  private final const func SendMaxStreetCredLevelReachedTrackingRequest() -> Void {
    let achievementRequest: ref<AddAchievementRequest>;
    let achievement: gamedataAchievement = gamedataAchievement.YouKnowWhoIAm;
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.m_owner.GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    if !dataTrackingSystem.IsAchievementUnlocked(achievement) {
      achievementRequest = new AddAchievementRequest();
      achievementRequest.achievement = achievement;
      dataTrackingSystem.QueueRequest(achievementRequest);
    };
  }

  public final const func CheckSpecialistAchievement(index: Int32) -> Void {
    let achievementRequest: ref<AddAchievementRequest>;
    let achievement: gamedataAchievement = gamedataAchievement.Specialist;
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.m_owner.GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    if dataTrackingSystem.IsAchievementUnlocked(achievement) {
      return;
    };
    achievementRequest = new AddAchievementRequest();
    achievementRequest.achievement = achievement;
    dataTrackingSystem.QueueRequest(achievementRequest);
  }

  private final const func SetAchievementProgress(index: Int32) -> Void {
    let achievement: gamedataAchievement;
    let maxLevel: Int32;
    let setAchievementRequest: ref<SetAchievementProgressRequest> = new SetAchievementProgressRequest();
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.m_owner.GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    if Equals(this.m_proficiencies[index].type, gamedataProficiencyType.StreetCred) {
      achievement = gamedataAchievement.YouKnowWhoIAm;
    } else {
      if NotEquals(this.m_proficiencies[index].type, gamedataProficiencyType.StreetCred) && NotEquals(this.m_proficiencies[index].type, gamedataProficiencyType.Level) {
        achievement = gamedataAchievement.Specialist;
      } else {
        return;
      };
    };
    maxLevel = RPGManager.GetProficiencyRecord(this.m_proficiencies[index].type).MaxLevel();
    setAchievementRequest.achievement = achievement;
    setAchievementRequest.currentValue = this.m_proficiencies[index].currentLevel;
    setAchievementRequest.maxValue = maxLevel;
    dataTrackingSystem.QueueRequest(setAchievementRequest);
  }

  private final const func AddProficiencyStat(type: gamedataProficiencyType, level: Int32) -> Void {
    let gi: GameInstance = this.m_owner.GetGame();
    let statString: String = EnumValueToString("gamedataProficiencyType", Cast(EnumInt(type)));
    let statType: gamedataStatType = IntEnum(Cast(EnumValueFromString("gamedataStatType", statString)));
    let newMod: ref<gameStatModifierData> = RPGManager.CreateStatModifier(statType, gameStatModifierType.Additive, Cast(level));
    GameInstance.GetStatsSystem(gi).AddModifier(Cast(this.m_owner.GetEntityID()), newMod);
  }

  private final const func ProcessProficiencyPassiveBonus(profIndex: Int32) -> Void {
    let bonusRecord: ref<PassiveProficiencyBonus_Record>;
    let effectorRecord: ref<Effector_Record>;
    if this.GetProficiencyRecordByIndex(profIndex).GetPassiveBonusesCount() > 0 {
      bonusRecord = this.GetProficiencyRecordByIndex(profIndex).GetPassiveBonusesItem(this.m_proficiencies[profIndex].currentLevel - 1);
      effectorRecord = bonusRecord.EffectorToTrigger();
      if IsDefined(effectorRecord) {
        GameInstance.GetEffectorSystem(this.m_owner.GetGame()).ApplyEffector(this.m_owner.GetEntityID(), this.m_owner, effectorRecord.GetID());
      };
    };
  }

  private final const func RemoveProficiencyStat(type: gamedataProficiencyType) -> Void {
    let gi: GameInstance = this.m_owner.GetGame();
    let statString: String = EnumValueToString("gamedataProficiencyType", Cast(EnumInt(type)));
    let statType: gamedataStatType = IntEnum(Cast(EnumValueFromString("gamedataStatType", statString)));
    let level: Float = GameInstance.GetStatsSystem(gi).GetStatValue(Cast(this.m_owner.GetEntityID()), statType);
    let newMod: ref<gameStatModifierData> = RPGManager.CreateStatModifier(statType, gameStatModifierType.Additive, -level);
    GameInstance.GetStatsSystem(gi).AddModifier(Cast(this.m_owner.GetEntityID()), newMod);
  }

  private final const func RefreshProficiencyStats() -> Void {
    let pIndex: Int32;
    let profType: gamedataProficiencyType;
    let i: Int32 = 0;
    while i < EnumInt(gamedataProficiencyType.Count) {
      profType = IntEnum(i);
      pIndex = this.GetProficiencyIndexByType(profType);
      if NotEquals(profType, gamedataProficiencyType.Level) && pIndex >= 0 {
        this.AddProficiencyStat(profType, this.m_proficiencies[pIndex].currentLevel);
      };
      i += 1;
    };
  }

  private final const func UpdateProficiencyMaxLevels() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_proficiencies) {
      this.m_proficiencies[i].maxLevel = this.GetProficiencyMaxLevel(this.m_proficiencies[i].type);
      i += 1;
    };
  }

  private final func AddProficiency(type: gamedataProficiencyType) -> Void {
    let newProf: SProficiency;
    newProf.type = type;
    newProf.currentLevel = this.m_startingLevel;
    newProf.currentExp = this.m_startingExperience;
    newProf.maxLevel = this.GetProficiencyMaxLevel(type);
    newProf.expToLevel = this.GetRemainingExpForLevelUp(type);
    ArrayPush(this.m_proficiencies, newProf);
  }

  public final const func AddExperience(amount: Int32, type: gamedataProficiencyType, telemetryGainReason: telemetryLevelGainReason) -> Void {
    let awardedAmount: Int32;
    let proficiencyProgress: ref<ProficiencyProgressEvent>;
    let reqExp: Int32;
    let telemetryEvt: TelemetryLevelGained;
    let pIndex: Int32 = this.GetProficiencyIndexByType(type);
    if pIndex >= 0 && !this.IsProficiencyMaxLvl(type) {
      while amount > 0 && !this.IsProficiencyMaxLvl(type) {
        reqExp = this.GetRemainingExpForLevelUp(type);
        if amount - reqExp >= 0 {
          awardedAmount += reqExp;
          amount -= reqExp;
          this.m_proficiencies[pIndex].currentExp += reqExp;
          this.m_proficiencies[pIndex].expToLevel = this.GetRemainingExpForLevelUp(type);
          if this.CanGainNextProficiencyLevel(pIndex) {
            this.ModifyProficiencyLevel(type);
            this.UpdateUIBB();
            if this.m_owner.IsPlayerControlled() && NotEquals(telemetryGainReason, telemetryLevelGainReason.Ignore) {
              telemetryEvt.playerPuppet = this.m_owner;
              telemetryEvt.proficiencyType = type;
              telemetryEvt.proficiencyValue = this.m_proficiencies[pIndex].currentLevel;
              telemetryEvt.isDebugEvt = Equals(telemetryGainReason, telemetryLevelGainReason.IsDebug);
              telemetryEvt.perkPointsAwarded = this.GetDevPointsForLevel(this.m_proficiencies[pIndex].currentLevel, type, gamedataDevelopmentPointType.Primary);
              telemetryEvt.attributePointsAwarded = this.GetDevPointsForLevel(this.m_proficiencies[pIndex].currentLevel, type, gamedataDevelopmentPointType.Attribute);
              GameInstance.GetTelemetrySystem(this.m_owner.GetGame()).LogLevelGained(telemetryEvt);
            };
          } else {
            return;
          };
        } else {
          this.m_proficiencies[pIndex].currentExp += amount;
          this.m_proficiencies[pIndex].expToLevel = this.GetRemainingExpForLevelUp(type);
          awardedAmount += amount;
          amount -= amount;
        };
      };
      if awardedAmount > 0 {
        if this.m_displayActivityLog {
          if Equals(type, gamedataProficiencyType.StreetCred) && GameInstance.GetQuestsSystem(this.m_owner.GetGame()).GetFact(n"street_cred_tutorial") == 0 && GameInstance.GetQuestsSystem(this.m_owner.GetGame()).GetFact(n"disable_tutorials") == 0 && Equals(telemetryGainReason, telemetryLevelGainReason.Gameplay) && GameInstance.GetQuestsSystem(this.m_owner.GetGame()).GetFact(n"q001_show_sts_tut") > 0 {
            GameInstance.GetQuestsSystem(this.m_owner.GetGame()).SetFact(n"street_cred_tutorial", 1);
          };
        };
        proficiencyProgress = new ProficiencyProgressEvent();
        proficiencyProgress.type = type;
        proficiencyProgress.expValue = this.GetCurrentLevelProficiencyExp(type);
        proficiencyProgress.delta = awardedAmount;
        proficiencyProgress.remainingXP = this.GetRemainingExpForLevelUp(type);
        proficiencyProgress.currentLevel = this.GetProficiencyLevel(type);
        proficiencyProgress.isLevelMaxed = this.GetProficiencyLevel(type) + 1 == this.GetProficiencyAbsoluteMaxLevel(type);
        GameInstance.GetUISystem(this.m_owner.GetGame()).QueueEvent(proficiencyProgress);
        if Equals(type, gamedataProficiencyType.Level) {
          this.UpdatePlayerXP();
        };
      };
    };
  }

  private final const func UpdatePlayerXP() -> Void {
    let gi: GameInstance = this.m_owner.GetGame();
    let m_ownerStatsBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_PlayerStats);
    m_ownerStatsBB.SetInt(GetAllBlackboardDefs().UI_PlayerStats.CurrentXP, this.GetCurrentLevelProficiencyExp(gamedataProficiencyType.Level), true);
  }

  public final func QueueCombatExperience(amount: Float, type: gamedataProficiencyType, entity: EntityID) -> Void {
    let expPackage: SExperiencePoints;
    expPackage.amount = amount;
    expPackage.forType = type;
    expPackage.entity = entity;
    ArrayPush(this.m_queuedCombatExp, expPackage);
  }

  public final func ProcessQueuedCombatExperience(entity: EntityID) -> Void {
    let expAmount: Float;
    let expAwarded: Bool;
    let j: Int32;
    let removeIndex: Int32;
    let toRemove: array<Int32>;
    let i: Int32 = 0;
    while i < EnumInt(gamedataProficiencyType.Count) {
      expAwarded = false;
      expAmount = 0.00;
      j = 0;
      while j < ArraySize(this.m_queuedCombatExp) {
        if this.m_queuedCombatExp[j].entity == entity && EnumInt(this.m_queuedCombatExp[j].forType) == i {
          expAmount += this.m_queuedCombatExp[j].amount;
          expAwarded = true;
          ArrayPush(toRemove, j);
        };
        j += 1;
      };
      j = 0;
      while j < ArraySize(toRemove) {
        removeIndex = ArrayPop(toRemove);
        ArrayErase(this.m_queuedCombatExp, removeIndex);
        j += 1;
      };
      if expAwarded {
        this.AddExperience(Cast(expAmount), IntEnum(i), telemetryLevelGainReason.Gameplay);
      };
      i += 1;
    };
  }

  private final const func CanGainNextProficiencyLevel(pIndex: Int32) -> Bool {
    let tempString: String;
    if pIndex >= 0 {
      if this.GetProficiencyMaxLevel(this.m_proficiencies[pIndex].type) > this.m_proficiencies[pIndex].currentLevel {
        return true;
      };
      tempString = IntToString(EnumInt(this.m_proficiencies[pIndex].type));
      LogDM("CanGainNextProfLevel(): Proficiency " + tempString + " has reached max level!");
      return false;
    };
    LogDM("CanGainNextProfLevel() : No proficiency found! Cannot gain experience to non-existant proficiency!!! Return value equals FALSE");
    return false;
  }

  private final const func GetExperienceForNextLevel(type: gamedataProficiencyType) -> Int32 {
    let colName: CName;
    let curveSetName: CName;
    let pIndex: Int32;
    let val: Int32;
    let statDataSys: ref<StatsDataSystem> = GameInstance.GetStatsDataSystem(this.m_owner.GetGame());
    if this.IsProficiencyMaxLvl(type) {
      LogDM("GetExperienceForNextLevel(): Maximum level has been reached! Return value equals -1 !");
      return -1;
    };
    pIndex = this.GetProficiencyIndexByType(type);
    if pIndex < 0 {
      LogDM("GetExperienceForNextLevel(): There is no proficiency of given type!! Return value equals -1 !!");
      return -1;
    };
    this.GetProficiencyExpCurveNames(type, curveSetName, colName);
    if Equals(curveSetName, n"") || Equals(colName, n"") {
      LogDM("GetTotalProfExperience(): Empty curve name OR column name ! Return value equals - 1 !");
      return -1;
    };
    val = Cast(statDataSys.GetValueFromCurve(curveSetName, Cast(this.m_proficiencies[pIndex].currentLevel + 1), colName));
    return val;
  }

  public final const func GetExperiencePercentage() -> Int32 {
    let pIndex: Int32 = this.GetProficiencyIndexByType(gamedataProficiencyType.Level);
    let maxExp: Int32 = this.m_proficiencies[pIndex].currentExp + this.m_proficiencies[pIndex].expToLevel;
    let expPerc: Int32 = (this.m_proficiencies[pIndex].currentExp * 100) / maxExp;
    return expPerc;
  }

  private final const func AddLevels(type: gamedataProficiencyType, opt amount: Int32) -> Void {
    let i: Int32;
    let pIndex: Int32 = this.GetProficiencyIndexByType(type);
    if amount == 0 {
      amount = 1;
    };
    if pIndex >= 0 {
      i = 0;
      while i <= amount {
        this.AddExperience(this.GetRemainingExpForLevelUp(type), type, telemetryLevelGainReason.IsDebug);
        i += 1;
      };
    };
  }

  public final const func SetLevel(type: gamedataProficiencyType, lvl: Int32, telemetryGainReason: telemetryLevelGainReason) -> Void {
    let i: Int32;
    let tempGainReason: telemetryLevelGainReason;
    let toAdd: Int32;
    let pIndex: Int32 = this.GetProficiencyIndexByType(type);
    if pIndex >= 0 && this.m_proficiencies[pIndex].currentLevel != lvl {
      if lvl < this.m_proficiencies[pIndex].currentLevel {
        this.ResetProficiencyLevel(type);
      };
      toAdd = lvl - this.m_proficiencies[pIndex].currentLevel;
      i = 0;
      while i < toAdd {
        tempGainReason = i == toAdd - 1 ? telemetryGainReason : telemetryLevelGainReason.Ignore;
        this.AddExperience(this.GetRemainingExpForLevelUp(type), type, tempGainReason);
        i += 1;
      };
    };
  }

  public final func BumpNetrunnerMinigameLevel(value: Int32) -> Void {
    if value > this.m_highestCompletedMinigameLevel {
      this.m_highestCompletedMinigameLevel = value;
    };
  }

  public final const func IsProficiencyMaxLvl(type: gamedataProficiencyType) -> Bool {
    let pIndex: Int32 = this.GetProficiencyIndexByType(type);
    if pIndex != -1 && this.m_proficiencies[pIndex].currentLevel == this.GetProficiencyMaxLevel(type) {
      LogDM(" IsProficiencyMaxLvl(): Proficiency " + IntToString(EnumInt(type)) + " has reached max level!");
      return true;
    };
    return false;
  }

  public final const func GetDevPoints(type: gamedataDevelopmentPointType) -> Int32 {
    return this.m_devPoints[this.GetDevPointsIndex(type)].unspent;
  }

  private final const func GetDevPointsIndex(type: gamedataDevelopmentPointType) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_devPoints) {
      if Equals(this.m_devPoints[i].type, type) {
        return i;
      };
      i += 1;
    };
    LogDM("GetDevPointsIndex(): Dev points of given type don\'t exist ! Return value equals -1 !");
    return -1;
  }

  private final func SetDevelopmentPoints() -> Void {
    let devPts: SDevelopmentPoints;
    let i: Int32 = 0;
    while i < EnumInt(gamedataDevelopmentPointType.Count) {
      devPts.type = IntEnum(i);
      devPts.spent = 0;
      devPts.unspent = 0;
      ArrayPush(this.m_devPoints, devPts);
      i += 1;
    };
  }

  private final const func ModifyDevPoints(type: gamedataProficiencyType, level: Int32) -> Void {
    let val: Int32;
    let i: Int32 = 0;
    while i <= EnumInt(gamedataDevelopmentPointType.Count) {
      val = this.GetDevPointsForLevel(level, type, IntEnum(i));
      if val > 0 {
        this.AddDevelopmentPoints(val, IntEnum(i));
      };
      i += 1;
    };
  }

  private final const func GetDevPointsForLevel(level: Int32, profType: gamedataProficiencyType, devPtsType: gamedataDevelopmentPointType) -> Int32 {
    let awardFloat: Float;
    let col: CName;
    let curve: CName;
    let statDataSys: ref<StatsDataSystem> = GameInstance.GetStatsDataSystem(this.m_owner.GetGame());
    let dIndex: Int32 = this.GetDevPointsIndex(devPtsType);
    if dIndex < 0 {
      LogDM(" GetDevPointsForLevel(): Error ! Given type doesn\'t exist ! Return value equals -1 !");
      return -1;
    };
    this.GetProficiencyExpCurveNames(profType, curve, col);
    if Equals(curve, n"") || Equals(col, n"") {
      return -1;
    };
    if Equals(profType, gamedataProficiencyType.Level) {
      if Equals(devPtsType, gamedataDevelopmentPointType.Attribute) && level % 2 == 0 {
        return 1;
      };
      awardFloat = statDataSys.GetValueFromCurve(n"player_levelToXP", Cast(level), n"perk_point_award_from_level");
      return Cast(awardFloat);
    };
    return -1;
  }

  public final const func AddDevelopmentPoints(amount: Int32, type: gamedataDevelopmentPointType) -> Void {
    let dIndex: Int32 = this.GetDevPointsIndex(type);
    if dIndex < 0 {
      LogDM(" AddDevelopmentPoints(): Error ! Given type doesn\'t exist !");
      return;
    };
    this.m_devPoints[dIndex].unspent += amount;
  }

  private final const func SpendDevelopmentPoint(type: gamedataDevelopmentPointType) -> Void {
    let dIndex: Int32 = this.GetDevPointsIndex(type);
    if dIndex < 0 {
      LogDM(" SpendDevelopmentPoint(): Given type doesn\'t exist! ");
      return;
    };
    this.m_devPoints[dIndex].unspent -= 1;
    this.m_devPoints[dIndex].spent += 1;
  }

  private final const func ResetDevelopmentPoints(type: gamedataDevelopmentPointType) -> Void {
    let dIndex: Int32 = this.GetDevPointsIndex(type);
    if dIndex < 0 {
      LogDM("ResetDevelopmentPoints(): Given type doesn\'t exist!");
      return;
    };
    this.m_devPoints[dIndex].unspent += this.m_devPoints[dIndex].spent;
    this.m_devPoints[dIndex].spent = 0;
  }

  private final const func ResetAllDevPoints() -> Void {
    let i: Int32 = 1;
    while i < ArraySize(this.m_devPoints) {
      this.ResetDevelopmentPoints(IntEnum(i));
      i += 1;
    };
  }

  private final const func ClearAllDevPoints() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_devPoints) {
      this.m_devPoints[i].spent = 0;
      this.m_devPoints[i].unspent = 0;
      i += 1;
    };
  }

  private final func InitializePerkAreas() -> Void {
    let i: Int32 = 0;
    while i <= EnumInt(gamedataPerkArea.Count) {
      this.InitializePerkArea(IntEnum(i));
      i += 1;
    };
  }

  private final func InitializePerkArea(areaType: gamedataPerkArea) -> Void {
    let newPerkArea: SPerkArea;
    if this.IsPerkAreaValid(areaType) {
      newPerkArea.type = areaType;
      newPerkArea.unlocked = this.ShouldPerkAreaBeAvailable(areaType);
      ArrayClear(newPerkArea.boughtPerks);
      ArrayPush(this.m_perkAreas, newPerkArea);
    };
  }

  private final const func InitializePerk(perkType: gamedataPerkType) -> SPerk {
    let newPerk: SPerk;
    newPerk.type = perkType;
    newPerk.currLevel = 0;
    return newPerk;
  }

  private final const func IncreasePerkLevel(areaIndex: Int32, perkIndex: Int32) -> Void {
    this.m_perkAreas[areaIndex].boughtPerks[perkIndex].currLevel += 1;
  }

  public final const func RefreshPerkAreas() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_proficiencies) {
      this.EvaluatePerkAreas(this.m_proficiencies[i].type);
      i += 1;
    };
  }

  private final const func EvaluatePerkAreas(prof: gamedataProficiencyType) -> Void {
    let aIndex: Int32;
    let i: Int32;
    let perkAreas: array<wref<PerkArea_Record>>;
    let pIndex: Int32 = this.GetProficiencyIndexByType(prof);
    if pIndex < 0 {
      return;
    };
    RPGManager.GetProficiencyRecord(prof).PerkAreas(perkAreas);
    i = 0;
    while i < ArraySize(perkAreas) {
      aIndex = this.GetPerkAreaIndex(perkAreas[i].Type());
      if aIndex < 0 {
      } else {
        this.m_perkAreas[aIndex].unlocked = this.IsPerkAreaReqMet(perkAreas[i]);
      };
      i += 1;
    };
  }

  public final const func GetPerkAreaIndex(areaType: gamedataPerkArea) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_perkAreas) {
      if Equals(this.m_perkAreas[i].type, areaType) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final const func GetPerkIndex(areaIndex: Int32, perkType: gamedataPerkType) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_perkAreas[areaIndex].boughtPerks) {
      if Equals(this.m_perkAreas[areaIndex].boughtPerks[i].type, perkType) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  public final const func GetPerkIndex(areaType: gamedataPerkArea, perkType: gamedataPerkType) -> Int32 {
    let i: Int32;
    let pAreaIndex: Int32 = this.GetPerkAreaIndex(areaType);
    if pAreaIndex < 0 {
      return -1;
    };
    i = 0;
    while i < ArraySize(this.m_perkAreas[pAreaIndex].boughtPerks) {
      if Equals(this.m_perkAreas[pAreaIndex].boughtPerks[i].type, perkType) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final const func GetPerkIndex(perkType: gamedataPerkType) -> Int32 {
    let pIndex: Int32 = this.GetPerkIndex(this.GetPerkAreaFromPerk(perkType), perkType);
    return pIndex;
  }

  public final const func UnlockPerkArea(areaType: gamedataPerkArea) -> Void {
    let pAreaIndex: Int32 = this.GetPerkAreaIndex(areaType);
    if pAreaIndex < 0 {
      return;
    };
    this.m_perkAreas[pAreaIndex].unlocked = true;
  }

  public final const func LockPerkArea(areaType: gamedataPerkArea) -> Void {
    let pAreaIndex: Int32 = this.GetPerkAreaIndex(areaType);
    if pAreaIndex < 0 {
      return;
    };
    this.m_perkAreas[pAreaIndex].unlocked = false;
  }

  public final const func BuyPerk(perkType: gamedataPerkType) -> Bool {
    let canBeBought: Bool;
    let newPerk: SPerk;
    let pIndex: Int32;
    let profIndex: Int32;
    let pAreaIndex: Int32 = this.GetPerkAreaIndex(this.GetPerkAreaFromPerk(perkType));
    if pAreaIndex < 0 {
      return false;
    };
    pIndex = this.GetPerkIndex(perkType);
    canBeBought = this.CanPerkBeBought(perkType);
    if pIndex < 0 && canBeBought {
      newPerk = this.InitializePerk(perkType);
      ArrayPush(this.m_perkAreas[pAreaIndex].boughtPerks, newPerk);
      pIndex = this.GetPerkIndex(perkType);
    };
    if !this.IsPerkMaxLevel(perkType) && canBeBought {
      profIndex = this.GetProficiencyIndexFromPerkArea(this.m_perkAreas[pAreaIndex].type);
      this.DeactivatePerkLevelData(pAreaIndex, pIndex);
      this.IncreasePerkLevel(pAreaIndex, pIndex);
      this.ActivatePerkLevelData(pAreaIndex, pIndex);
      this.SpendDevelopmentPoint(gamedataDevelopmentPointType.Primary);
      this.m_proficiencies[profIndex].spentPerkPoints += 1;
      this.EvaluatePerkAreas(this.m_proficiencies[profIndex].type);
      return true;
    };
    return false;
  }

  public final const func RemovePerk(perkType: gamedataPerkType) -> Bool {
    let currentPerkLevel: Int32;
    let dIndex: Int32;
    let pIndex: Int32;
    let profIndex: Int32;
    let tempPDevPts: Int32;
    let areaType: gamedataPerkArea = this.GetPerkAreaFromPerk(perkType);
    let pAreaIndex: Int32 = this.GetPerkAreaIndex(areaType);
    if pAreaIndex < 0 {
      return false;
    };
    pIndex = this.GetPerkIndex(perkType);
    if pIndex >= 0 {
      this.DeactivatePerkLevelData(pAreaIndex, pIndex);
      currentPerkLevel = this.m_perkAreas[pAreaIndex].boughtPerks[pIndex].currLevel;
      tempPDevPts = Cast(GameInstance.GetStatsDataSystem(this.m_owner.GetGame()).GetValueFromCurve(this.GetPerkAreaRecord(areaType).Curve().CurveSetName(), Cast(currentPerkLevel), n"Primary"));
      if tempPDevPts > 0 {
        profIndex = this.GetProficiencyIndexFromPerkArea(this.m_perkAreas[pAreaIndex].type);
        dIndex = this.GetDevPointsIndex(gamedataDevelopmentPointType.Primary);
        this.m_devPoints[dIndex].unspent += tempPDevPts;
        this.m_devPoints[dIndex].spent -= tempPDevPts;
        this.m_proficiencies[profIndex].spentPerkPoints -= tempPDevPts;
        this.RemovePerkRecipes(perkType);
      };
      ArrayErase(this.m_perkAreas[pAreaIndex].boughtPerks, pIndex);
      return true;
    };
    return false;
  }

  public final const func RemoveAllPerks() -> Void {
    let i: Int32;
    let perkResetEvent: ref<PerkResetEvent>;
    let perkType: gamedataPerkType;
    GameInstance.GetTransactionSystem(this.m_owner.GetGame()).RemoveItem(this.m_owner, MarketSystem.Money(), this.GetTotalRespecCost());
    i = 0;
    while i < EnumInt(gamedataPerkType.Count) {
      perkType = IntEnum(i);
      if this.HasPerk(perkType) {
        this.RemovePerk(perkType);
      };
      i += 1;
    };
    i = 0;
    while i < EnumInt(gamedataTraitType.Count) {
      this.RemoveTrait(IntEnum(i));
      i += 1;
    };
    perkResetEvent = new PerkResetEvent();
    GameInstance.GetUISystem(this.m_owner.GetGame()).QueueEvent(perkResetEvent);
  }

  public final const func GetTotalRespecCost() -> Int32 {
    let basePrice: Int32 = Cast(TweakDBInterface.GetConstantStatModifierRecord(t"Price.RespecBase").Value());
    let singlePerkPrice: Int32 = Cast(TweakDBInterface.GetConstantStatModifierRecord(t"Price.RespecSinglePerk").Value());
    let cost: Int32 = basePrice + singlePerkPrice * (this.GetSpentPerkPoints() + this.GetSpentTraitPoints());
    return cost;
  }

  public final func CheckPlayerRespecCost() -> Bool {
    let resetCost: Int32 = this.GetTotalRespecCost();
    let userMoney: Int32 = GameInstance.GetTransactionSystem(this.m_owner.GetGame()).GetItemQuantity(this.m_owner, MarketSystem.Money());
    return userMoney >= resetCost;
  }

  private final const func RemovePerkRecipes(perkType: gamedataPerkType) -> Void {
    let addItemsEffector: ref<AddItemsEffector_Record>;
    let craftingSystem: ref<CraftingSystem>;
    let hideRecipeRequest: ref<HideRecipeRequest>;
    let i: Int32;
    let itemsToAdd: array<wref<InventoryItem_Record>>;
    let j: Int32;
    let k: Int32;
    let perkLevelEffectors: array<wref<Effector_Record>>;
    let perkLevels: array<wref<PerkLevelData_Record>>;
    this.GetPerkRecord(perkType).Levels(perkLevels);
    i = 0;
    while i < ArraySize(perkLevels) {
      perkLevels[i].DataPackage().Effectors(perkLevelEffectors);
      j = 0;
      while j < ArraySize(perkLevelEffectors) {
        addItemsEffector = perkLevelEffectors[j] as AddItemsEffector_Record;
        if IsDefined(addItemsEffector) {
          addItemsEffector.ItemsToAdd(itemsToAdd);
          k = 0;
          while k < ArraySize(itemsToAdd) {
            craftingSystem = GameInstance.GetScriptableSystemsContainer(this.m_owner.GetGame()).Get(n"CraftingSystem") as CraftingSystem;
            hideRecipeRequest = new HideRecipeRequest();
            hideRecipeRequest.recipe = (itemsToAdd[k].Item() as ItemRecipe_Record).CraftingResult().Item().GetID();
            craftingSystem.QueueRequest(hideRecipeRequest);
            k += 1;
          };
        };
        j += 1;
      };
      i += 1;
    };
  }

  public final const func GetPerkRecord(perkType: gamedataPerkType) -> ref<Perk_Record> {
    return TweakDBInterface.GetPerkRecord(TDBID.Create("Perks." + EnumValueToString("gamedataPerkType", Cast(EnumInt(perkType)))));
  }

  public final const func GetPerkAreaRecord(areaType: gamedataPerkArea) -> ref<PerkArea_Record> {
    return TweakDBInterface.GetPerkAreaRecord(TDBID.Create("Perks." + EnumValueToString("gamedataPerkArea", Cast(EnumInt(areaType)))));
  }

  public final const func GetPerkPackageTDBID(areaIndex: Int32, perkIndex: Int32) -> TweakDBID {
    let packageID: TweakDBID = this.GetPerkPackageTDBID(this.m_perkAreas[areaIndex].boughtPerks[perkIndex].type);
    return packageID;
  }

  public final const func GetPerkPackageTDBID(perkType: gamedataPerkType) -> TweakDBID {
    let levelsData: array<wref<PerkLevelData_Record>>;
    let pAreaIndex: Int32;
    let pIndex: Int32;
    let packageID: TweakDBID;
    this.GetPerkRecord(perkType).Levels(levelsData);
    pAreaIndex = this.GetPerkAreaIndex(this.GetPerkAreaFromPerk(perkType));
    if pAreaIndex < 0 {
      return TDBID.undefined();
    };
    pIndex = this.GetPerkIndex(pAreaIndex, perkType);
    if pIndex < 0 {
      return TDBID.undefined();
    };
    packageID = levelsData[this.m_perkAreas[pAreaIndex].boughtPerks[pIndex].currLevel - 1].DataPackage().GetID();
    return packageID;
  }

  public final const func HasPerk(perkType: gamedataPerkType) -> Bool {
    let pIndex: Int32 = this.GetPerkIndex(this.GetPerkAreaFromPerk(perkType), perkType);
    return pIndex >= 0;
  }

  public final const func GetInvestedPerkPoints(profType: gamedataProficiencyType) -> Int32 {
    let pIndex: Int32 = this.GetProficiencyIndexByType(profType);
    return this.m_proficiencies[pIndex].spentPerkPoints;
  }

  public final const func ShouldPerkAreaBeAvailable(areaType: gamedataPerkArea) -> Bool {
    let areaRecord: ref<PerkArea_Record> = this.GetPerkAreaRecord(areaType);
    if TDBID.IsValid(areaRecord.GetID()) {
      if this.IsPerkAreaReqMet(areaRecord) {
        return true;
      };
    };
    return false;
  }

  public final const func IsPerkAreaUnlocked(area: gamedataPerkArea) -> Bool {
    let aIndex: Int32 = this.GetPerkAreaIndex(area);
    if aIndex < 0 {
      return false;
    };
    return this.m_perkAreas[aIndex].unlocked;
  }

  public final const func IsPerkAreaUnlocked(aIndex: Int32) -> Bool {
    if aIndex < 0 {
      return false;
    };
    return this.m_perkAreas[aIndex].unlocked;
  }

  private final const func IsPerkAreaValid(areaType: gamedataPerkArea) -> Bool {
    let i: Int32 = 0;
    while i < EnumInt(gamedataPerkArea.Count) {
      if Equals(areaType, IntEnum(i)) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final const func IsPerkMaxLevel(perkType: gamedataPerkType) -> Bool {
    return this.GetPerkLevel(perkType) >= this.GetPerkMaxLevel(perkType);
  }

  public final const func GetPerkMaxLevel(perkType: gamedataPerkType) -> Int32 {
    return this.GetPerkAreaRecord(this.GetPerkAreaFromPerk(perkType)).MaxLevel();
  }

  public final const func GetPerkLevel(perkType: gamedataPerkType) -> Int32 {
    let pIndex: Int32;
    let pAreaIndex: Int32 = this.GetPerkAreaIndex(this.GetPerkAreaFromPerk(perkType));
    if pAreaIndex < 0 {
      return -1;
    };
    pIndex = this.GetPerkIndex(pAreaIndex, perkType);
    if pIndex < 0 {
      return -1;
    };
    return this.m_perkAreas[pAreaIndex].boughtPerks[pIndex].currLevel;
  }

  private final const func CanPerkBeBought(perkType: gamedataPerkType) -> Bool {
    let pIndex: Int32;
    let primDevIndex: Int32;
    let pAreaIndex: Int32 = this.GetPerkAreaIndex(this.GetPerkAreaFromPerk(perkType));
    if pAreaIndex < 0 {
      return false;
    };
    pIndex = this.GetPerkIndex(pAreaIndex, perkType);
    if pIndex >= 0 && this.GetPerkMaxLevel(perkType) <= this.m_perkAreas[pAreaIndex].boughtPerks[pIndex].currLevel {
      LogDM("CanPerkBeBought(): Maximum level reached !");
      return false;
    };
    primDevIndex = this.GetDevPointsIndex(gamedataDevelopmentPointType.Primary);
    if primDevIndex < 0 {
      LogDM(" CanPerkBeBought(): Development points not found!");
      return false;
    };
    if this.m_devPoints[primDevIndex].unspent <= 0 {
      LogDM("CanPerkBeBought(): Not enough development points!!");
      return false;
    };
    return true;
  }

  public final const func CanTraitBeBought() -> Bool {
    let primDevIndex: Int32 = this.GetDevPointsIndex(gamedataDevelopmentPointType.Primary);
    if primDevIndex < 0 {
      LogDM(" CanPerkBeBought(): Development points not found!");
      return false;
    };
    if this.m_devPoints[primDevIndex].unspent <= 0 {
      LogDM("CanPerkBeBought(): Not enough development points!!");
      return false;
    };
    return true;
  }

  public final const func IsPerkAreaReqMet(areaRecord: ref<PerkArea_Record>) -> Bool {
    return this.IsPerkAreaBaseReqMet(areaRecord);
  }

  public final const func IsPerkAreaMasteryReqMet(areaRecord: ref<PerkArea_Record>) -> Bool {
    let prereqID: TweakDBID = areaRecord.MasteryLevel().GetID();
    let prereq: ref<StatPrereq> = IPrereq.CreatePrereq(prereqID) as StatPrereq;
    return prereq.IsFulfilled(this.m_owner.GetGame(), this.m_owner);
  }

  private final const func IsPerkAreaBaseReqMet(areaRecord: ref<PerkArea_Record>) -> Bool {
    let prereqID: TweakDBID = areaRecord.Requirement().GetID();
    let prereq: ref<IPrereq> = IPrereq.CreatePrereq(prereqID);
    return prereq.IsFulfilled(this.m_owner.GetGame(), this.m_owner);
  }

  public final const func GetRemainingRequiredPerkPoints(areaRecord: ref<PerkArea_Record>, out amount: Int32) -> Bool {
    let invested: Int32;
    let required: Int32;
    let prereq: ref<InvestedPerksPrereq> = IPrereq.CreatePrereq(areaRecord.Requirement().GetID()) as InvestedPerksPrereq;
    if IsDefined(prereq) {
      required = prereq.GetRequiredAmount();
      invested = this.GetInvestedPerkPoints(prereq.GetProficiencyType());
      amount = required - invested;
      if amount > 0 {
        return true;
      };
      return false;
    };
    amount = -1;
    return false;
  }

  public final const func GetRemainingRequiredPerkPoints(traitRecord: ref<Trait_Record>, out amount: Int32) -> Bool {
    let invested: Int32;
    let required: Int32;
    let prereq: ref<InvestedPerksPrereq> = IPrereq.CreatePrereq(traitRecord.Requirement().GetID()) as InvestedPerksPrereq;
    if IsDefined(prereq) {
      required = prereq.GetRequiredAmount();
      invested = this.GetInvestedPerkPoints(prereq.GetProficiencyType());
      amount = required - invested;
      if amount > 0 {
        return true;
      };
      return false;
    };
    amount = -1;
    return false;
  }

  public final const func GetPerkAreaFromPerk(perkType: gamedataPerkType) -> gamedataPerkArea {
    let areaString: String = EnumValueToString("gamedataPerkType", Cast(EnumInt(perkType)));
    areaString = StrBeforeFirst(areaString, "_Perk");
    return IntEnum(Cast(EnumValueFromString("gamedataPerkArea", areaString)));
  }

  public final const func GetProficiencyFromPerkArea(perkArea: gamedataPerkArea) -> gamedataProficiencyType {
    let proficiencyString: String = EnumValueToString("gamedataPerkArea", Cast(EnumInt(perkArea)));
    proficiencyString = StrBeforeFirst(proficiencyString, "_Area");
    return IntEnum(Cast(EnumValueFromString("gamedataProficiencyType", proficiencyString)));
  }

  public final const func GetProficiencyIndexFromPerkArea(perkArea: gamedataPerkArea) -> Int32 {
    let pIndex: Int32 = this.GetProficiencyIndexByType(this.GetProficiencyFromPerkArea(perkArea));
    return pIndex;
  }

  private final const func ActivatePerkLevelData(areaIndex: Int32, perkIndex: Int32) -> Void {
    let GLPS: ref<GameplayLogicPackageSystem> = GameInstance.GetGameplayLogicPackageSystem(this.m_owner.GetGame());
    let packageID: TweakDBID = this.GetPerkPackageTDBID(areaIndex, perkIndex);
    GLPS.ApplyPackage(this.m_owner, this.m_owner, packageID);
  }

  private final const func DeactivatePerkLevelData(areaIndex: Int32, perkIndex: Int32) -> Void {
    let GLPS: ref<GameplayLogicPackageSystem> = GameInstance.GetGameplayLogicPackageSystem(this.m_owner.GetGame());
    let packageID: TweakDBID = this.GetPerkPackageTDBID(areaIndex, perkIndex);
    GLPS.RemovePackage(this.m_owner, packageID);
  }

  public final const func GetSpentPerkPoints() -> Int32 {
    let sum: Int32;
    let count: Int32 = ArraySize(this.m_proficiencies);
    let i: Int32 = 0;
    while i < count {
      sum += this.m_proficiencies[i].spentPerkPoints;
      i += 1;
    };
    return sum;
  }

  public final const func GetPerks() -> array<SPerk> {
    let allPerks: array<SPerk>;
    let j: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_perkAreas) {
      j = 0;
      while j < ArraySize(this.m_perkAreas[i].boughtPerks) {
        ArrayPush(allPerks, this.m_perkAreas[i].boughtPerks[j]);
        j += 1;
      };
      i += 1;
    };
    return allPerks;
  }

  private final func InitializeTraits() -> Void {
    let i: Int32 = 0;
    while i < EnumInt(gamedataTraitType.Count) {
      this.AddTrait(IntEnum(i));
      i += 1;
    };
  }

  private final func AddTrait(traitType: gamedataTraitType) -> Void {
    let newTrait: STrait;
    newTrait.type = traitType;
    newTrait.unlocked = false;
    newTrait.currLevel = 0;
    ArrayPush(this.m_traits, newTrait);
  }

  public final const func IncreaseTraitLevel(traitType: gamedataTraitType) -> Bool {
    let primDevIndex: Int32;
    let traitIndex: Int32 = this.GetTraitIndex(traitType);
    if traitIndex < 0 || !this.IsTraitUnlocked(traitIndex) {
      return false;
    };
    if this.CanTraitBeBought() {
      this.m_traits[traitIndex].currLevel += 1;
      primDevIndex = this.GetDevPointsIndex(gamedataDevelopmentPointType.Primary);
      this.m_devPoints[primDevIndex].unspent -= 1;
      this.m_devPoints[primDevIndex].spent += 1;
      this.EvaluateTraitInfiniteData(traitIndex);
      return true;
    };
    return false;
  }

  private final const func RemoveTrait(traitType: gamedataTraitType) -> Bool {
    let primDevIndex: Int32;
    let traitLevel: Int32;
    let traitIndex: Int32 = this.GetTraitIndex(traitType);
    if traitIndex < 0 || !this.IsTraitUnlocked(traitIndex) {
      return false;
    };
    traitLevel = this.m_traits[traitIndex].currLevel;
    if this.m_traits[traitIndex].currLevel > 0 {
      this.ClearTraitInfiniteData(traitIndex);
      this.m_traits[traitIndex].currLevel = 0;
      primDevIndex = this.GetDevPointsIndex(gamedataDevelopmentPointType.Primary);
      this.m_devPoints[primDevIndex].unspent += traitLevel;
      this.m_devPoints[primDevIndex].spent -= traitLevel;
      return true;
    };
    return false;
  }

  public final const func GetSpentTraitPoints() -> Int32 {
    let spentPoints: Int32;
    let i: Int32 = 0;
    while i < EnumInt(gamedataTraitType.Count) {
      if this.IsTraitUnlocked(i) {
        spentPoints += this.GetTraitLevel(i);
      };
      i += 1;
    };
    return spentPoints;
  }

  private final const func EvaluateTraitInfiniteData(traitIndex: Int32) -> Void {
    let GLPS: ref<GameplayLogicPackageSystem> = GameInstance.GetGameplayLogicPackageSystem(this.m_owner.GetGame());
    let traitPackage: TweakDBID = RPGManager.GetTraitRecord(this.m_traits[traitIndex].type).InfiniteTraitData().DataPackage().GetID();
    let traitLevel: Uint32 = Cast(this.m_traits[traitIndex].currLevel);
    GLPS.RemovePackages(this.m_owner, traitPackage, traitLevel);
    GLPS.ApplyPackages(this.m_owner, this.m_owner, traitPackage, traitLevel);
  }

  private final const func ClearTraitInfiniteData(traitIndex: Int32) -> Void {
    let GLPS: ref<GameplayLogicPackageSystem> = GameInstance.GetGameplayLogicPackageSystem(this.m_owner.GetGame());
    let traitPackage: TweakDBID = RPGManager.GetTraitRecord(this.m_traits[traitIndex].type).InfiniteTraitData().DataPackage().GetID();
    let traitLevel: Uint32 = Cast(this.m_traits[traitIndex].currLevel);
    GLPS.RemovePackages(this.m_owner, traitPackage, traitLevel);
  }

  private final const func EvaluateTrait(profType: gamedataProficiencyType) -> Void {
    let traitType: gamedataTraitType = RPGManager.GetProficiencyRecord(profType).Trait().Type();
    let traitIndex: Int32 = this.GetTraitIndex(traitType);
    if traitIndex < 0 || this.IsTraitUnlocked(traitIndex) {
      return;
    };
    if this.IsTraitReqMet(this.m_traits[traitIndex].type) {
      this.m_traits[traitIndex].unlocked = true;
      this.ActivateTraitBase(this.m_traits[traitIndex].type);
    };
  }

  private final const func ActivateTraitBase(traitType: gamedataTraitType) -> Void {
    let traitPackage: TweakDBID = RPGManager.GetTraitRecord(traitType).BaseTraitData().DataPackage().GetID();
    GameInstance.GetGameplayLogicPackageSystem(this.m_owner.GetGame()).ApplyPackage(this.m_owner, this.m_owner, traitPackage);
  }

  public final const func IsTraitUnlocked(traitType: gamedataTraitType) -> Bool {
    return this.IsTraitUnlocked(this.GetTraitIndex(traitType));
  }

  private final const func IsTraitUnlocked(traitIndex: Int32) -> Bool {
    if traitIndex < 0 {
      return false;
    };
    return this.m_traits[traitIndex].unlocked;
  }

  private final const func IsTraitReqMet(traitType: gamedataTraitType) -> Bool {
    let traitRecord: ref<Trait_Record> = this.GetTraitRecord(traitType);
    let prereqID: TweakDBID = traitRecord.Requirement().GetID();
    let prereq: ref<StatPrereq> = IPrereq.CreatePrereq(prereqID) as StatPrereq;
    return prereq.IsFulfilled(this.m_owner.GetGame(), this.m_owner);
  }

  public final const func GetTraitLevel(traitType: gamedataTraitType) -> Int32 {
    return this.GetTraitLevel(this.GetTraitIndex(traitType));
  }

  private final const func GetTraitLevel(traitIndex: Int32) -> Int32 {
    if traitIndex < 0 {
      return 0;
    };
    return this.m_traits[traitIndex].currLevel;
  }

  private final const func GetTraitIndex(traitType: gamedataTraitType) -> Int32 {
    let i: Int32 = 0;
    while Cast(ArraySize(this.m_traits)) {
      if Equals(this.m_traits[i].type, traitType) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final const func GetTraitRecord(traitType: gamedataTraitType) -> ref<Trait_Record> {
    return TweakDBInterface.GetTraitRecord(TDBID.Create("Traits." + EnumValueToString("gamedataTraitType", Cast(EnumInt(traitType)))));
  }

  public final const func BuyAttribute(type: gamedataStatType) -> Bool {
    let cost: Int32;
    let dIndex: Int32 = this.GetDevPointsIndex(gamedataDevelopmentPointType.Attribute);
    if dIndex < 0 {
      return false;
    };
    if !this.CanAttributeBeBought(type) {
      return false;
    };
    cost = this.GetAttributeNextLevelCost(type);
    this.ModifyAttribute(type, 1.00);
    this.m_devPoints[dIndex].unspent -= cost;
    this.m_devPoints[dIndex].spent += cost;
    return true;
  }

  public final const func SetAttribute(type: gamedataStatType, amount: Float) -> Void {
    let statSys: ref<StatsSystem>;
    if !this.IsStatValid(type) {
      LogDM("SetStat(): Given stat type doesn\'t exist!!");
      return;
    };
    if !PlayerDevelopmentData.IsAttribute(type) {
      LogDM("SetAttribute(): Given type is not an attribute!");
      return;
    };
    statSys = GameInstance.GetStatsSystem(this.m_owner.GetGame());
    this.ModifyAttribute(type, -statSys.GetStatValue(Cast(this.m_owner.GetEntityID()), type));
    this.ModifyAttribute(type, amount);
  }

  public final const func GetAttributes() -> array<SAttribute> {
    return this.m_attributes;
  }

  private final func SetAttributes() -> Void {
    let attVal: Float;
    let attribute: SAttribute;
    let ss: ref<StatsSystem> = GameInstance.GetStatsSystem(this.m_owner.GetGame());
    let i: Int32 = 0;
    while i < EnumInt(gamedataStatType.Count) {
      if PlayerDevelopmentData.IsAttribute(IntEnum(i)) {
        if IsDefined(this.m_owner) {
          attVal = ss.GetStatValue(Cast(this.m_owner.GetEntityID()), IntEnum(i));
        } else {
          attVal = 2.00;
        };
        attribute.value = Cast(attVal);
        attribute.attributeName = IntEnum(i);
        attribute.id = TDBID.Create("BaseStats." + ToString(attribute.attributeName));
        ArrayPush(this.m_attributes, attribute);
      };
      i += 1;
    };
  }

  private final const func ModifyAttribute(type: gamedataStatType, amount: Float) -> Void {
    let aIndex: Int32;
    let newMod: ref<gameStatModifierData>;
    let statSys: ref<StatsSystem>;
    if !this.IsStatValid(type) {
      LogDM("AddStat(): Given stat type doesn\'t exist!!");
      return;
    };
    statSys = GameInstance.GetStatsSystem(this.m_owner.GetGame());
    this.UpdateStatPrereqs(type, amount);
    newMod = RPGManager.CreateStatModifier(type, gameStatModifierType.Additive, amount);
    statSys.AddModifier(Cast(this.m_owner.GetEntityID()), newMod);
    aIndex = this.GetAttributeIndex(type);
    this.m_attributes[aIndex].value = Cast(GameInstance.GetStatsSystem(this.m_owner.GetGame()).GetStatValue(Cast(this.m_owner.GetEntityID()), type));
    this.UpdateProficiencyMaxLevels();
    this.RefreshPerkAreas();
  }

  private final const func GetAttributeIndex(type: gamedataStatType) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_attributes) {
      if Equals(this.m_attributes[i].attributeName, type) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private final const func GetAttributeDevCap(type: gamedataStatType) -> Int32 {
    let value: Int32 = Cast(this.GetAttributeRecord(type).Max());
    return value;
  }

  private final const func CanAttributeBeBought(type: gamedataStatType) -> Bool {
    let currVal: Int32;
    let enoughPoints: Bool;
    let maxLvlNotReached: Bool;
    let objectID: StatsObjectID = Cast(this.m_owner.GetEntityID());
    let dIndex: Int32 = this.GetDevPointsIndex(gamedataDevelopmentPointType.Attribute);
    if dIndex < 0 {
      LogDM("CanAttributeBeBought(): Attribute development points don\'t exist! Big error! Returns false!");
      return false;
    };
    currVal = Cast(GameInstance.GetStatsSystem(this.m_owner.GetGame()).GetStatValue(objectID, type));
    enoughPoints = this.m_devPoints[dIndex].unspent >= this.GetAttributeNextLevelCost(type);
    maxLvlNotReached = this.GetAttributeDevCap(type) > currVal;
    if enoughPoints && maxLvlNotReached {
      return true;
    };
    if !enoughPoints {
      LogDM("CanAttributeBeBought(): Not enough dev points!");
    } else {
      LogDM("CanAttributeBeBought(): Attribute " + EnumValueToString("gamedataStatType", EnumInt(type)) + " has reached max level!");
    };
    return false;
  }

  private final const func IsStatValid(type: gamedataStatType) -> Bool {
    if EnumInt(type) >= EnumInt(gamedataStatType.Count) {
      LogDM("IsStatValid(): Given stat type isn\'t valid!!");
      return false;
    };
    return true;
  }

  public final static func IsAttribute(type: gamedataStatType) -> Bool {
    switch type {
      case gamedataStatType.Gunslinger:
      case gamedataStatType.Reflexes:
      case gamedataStatType.TechnicalAbility:
      case gamedataStatType.Cool:
      case gamedataStatType.Intelligence:
      case gamedataStatType.Strength:
        return true;
      default:
        return false;
    };
  }

  private final const func GetAttributeNextLevelCost(type: gamedataStatType) -> Int32 {
    let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.m_owner.GetGame());
    let statDataSystem: ref<StatsDataSystem> = GameInstance.GetStatsDataSystem(this.m_owner.GetGame());
    let objectID: StatsObjectID = Cast(this.m_owner.GetEntityID());
    let level: Float = statSystem.GetStatValue(objectID, type);
    let statName: CName = EnumValueToName(n"gamedataStatType", EnumInt(type));
    let cost: Int32 = Cast(statDataSystem.GetValueFromCurve(n"player_attributeLevelToCostIncrease", level + 1.00, statName));
    return cost;
  }

  public final const func GetAttributeRecord(type: gamedataStatType) -> ref<Stat_Record> {
    if PlayerDevelopmentData.IsAttribute(type) {
      return TweakDBInterface.GetStatRecord(TDBID.Create("BaseStats." + EnumValueToString("gamedataStatType", Cast(EnumInt(type)))));
    };
    return null;
  }

  public final func RegisterSkillCheckPrereq(skillPrereq: ref<SkillCheckPrereqState>) -> Void {
    if !ArrayContains(this.m_skillPrereqs, skillPrereq) {
      ArrayPush(this.m_skillPrereqs, skillPrereq);
    };
  }

  public final func RegisterStatCheckPrereq(statPrereq: ref<StatCheckPrereqState>) -> Void {
    if !ArrayContains(this.m_statPrereqs, statPrereq) {
      ArrayPush(this.m_statPrereqs, statPrereq);
    };
  }

  public final func UnregisterSkillCheckPrereq(skillPrereq: ref<SkillCheckPrereqState>) -> Void {
    ArrayRemove(this.m_skillPrereqs, skillPrereq);
  }

  public final func UnregisterStatCheckPrereq(statPrereq: ref<StatCheckPrereqState>) -> Void {
    ArrayRemove(this.m_statPrereqs, statPrereq);
  }

  private final const func UpdateSkillPrereqs(changedSkill: gamedataProficiencyType, newLevel: Int32) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_skillPrereqs) {
      if Equals(this.m_skillPrereqs[i].GetSkillToCheck(), changedSkill) {
      };
      i += 1;
    };
  }

  private final const func UpdateStatPrereqs(changedStat: gamedataStatType, newValue: Float) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_statPrereqs) {
      if Equals(this.m_statPrereqs[i].GetStatToCheck(), changedStat) {
      };
      i += 1;
    };
  }

  public final func SetProgressionBuild(build: gamedataBuildType) -> Void {
    let buildString: String = EnumValueToString("gamedataBuildType", Cast(EnumInt(build)));
    this.ProcessProgressionBuild(TweakDBInterface.GetProgressionBuildRecord(TDBID.Create("ProgressionBuilds." + buildString)));
  }

  public final func SetProgressionBuild(buildID: TweakDBID) -> Void {
    this.ProcessProgressionBuild(TweakDBInterface.GetProgressionBuildRecord(buildID));
  }

  public final func SetLifePath(lifePath: TweakDBID) -> Void {
    this.ProcessLifePath(TweakDBInterface.GetLifePathRecord(lifePath));
  }

  public final func UpdateAttributes(attributes: array<CharacterCustomizationAttribute>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(attributes) {
      this.SetAttribute(attributes[i].type, Cast(attributes[i].value));
      i += 1;
    };
  }

  private final func ProcessProgressionBuild(buildRecord: ref<ProgressionBuild_Record>) -> Void {
    let buildAttributeSet: wref<BuildAttributeSet_Record>;
    let buildAttributes: array<wref<BuildAttribute_Record>>;
    let buildCraftableItems: wref<Craftable_Record>;
    let buildCyberwareItems: array<wref<BuildCyberware_Record>>;
    let buildCyberwareSet: wref<BuildCyberwareSet_Record>;
    let buildEquipmentItems: array<wref<BuildEquipment_Record>>;
    let buildEquipmentSet: wref<BuildEquipmentSet_Record>;
    let buildItems: array<wref<InventoryItem_Record>>;
    let buildPerkSet: wref<BuildPerkSet_Record>;
    let buildPerks: array<wref<BuildPerk_Record>>;
    let buildProficiencies: array<wref<BuildProficiency_Record>>;
    let buildProficiencySet: wref<BuildProficiencySet_Record>;
    let i: Int32;
    let inventoryItemSet: wref<InventoryItemSet_Record>;
    this.m_displayActivityLog = false;
    let randomizeClothing: Bool = buildRecord.RandomizeClothing();
    this.FlushDevelopment();
    buildAttributeSet = buildRecord.AttributeSet();
    buildProficiencySet = buildRecord.ProficiencySet();
    buildPerkSet = buildRecord.PerkSet();
    inventoryItemSet = buildRecord.InventorySet();
    buildEquipmentSet = buildRecord.EquipmentSet();
    buildCyberwareSet = buildRecord.CyberwareSet();
    if IsDefined(buildAttributeSet) {
      buildAttributeSet.Attributes(buildAttributes);
    };
    if IsDefined(buildProficiencySet) {
      buildProficiencySet.Proficiencies(buildProficiencies);
    };
    if IsDefined(buildPerkSet) {
      buildPerkSet.Perks(buildPerks);
    };
    i = 0;
    while i < buildRecord.GetPerkSetsCount() {
      buildRecord.GetPerkSetsItem(i).Perks(buildPerks);
      i += 1;
    };
    if IsDefined(inventoryItemSet) {
      inventoryItemSet.Items(buildItems);
    };
    if IsDefined(buildEquipmentSet) {
      buildEquipmentSet.Equipment(buildEquipmentItems);
    };
    if IsDefined(buildCyberwareSet) {
      buildCyberwareSet.Cyberware(buildCyberwareItems);
    };
    this.ProcessBuildItems(buildItems);
    this.ProcessBuildAttributes(buildAttributes);
    this.ProcessBuildProficiencies(buildProficiencies);
    this.ProcessBuildPerks(buildPerks);
    this.ProcessBuildEquipment(buildEquipmentItems, randomizeClothing);
    this.ProcessBuildCyberware(buildCyberwareItems);
    buildRecord.StartingAttributes(buildAttributes);
    buildRecord.StartingProficiencies(buildProficiencies);
    buildRecord.StartingPerks(buildPerks);
    buildRecord.StartingItems(buildItems);
    buildRecord.StartingEquipment(buildEquipmentItems);
    buildRecord.StartingCyberware(buildCyberwareItems);
    this.ProcessBuildItems(buildItems);
    this.ProcessBuildAttributes(buildAttributes);
    this.ProcessBuildProficiencies(buildProficiencies);
    this.ProcessBuildPerks(buildPerks);
    this.ProcessBuildEquipment(buildEquipmentItems, randomizeClothing);
    this.ProcessBuildCyberware(buildCyberwareItems);
    buildCraftableItems = buildRecord.CraftBook();
    this.ProcessCraftbook(buildCraftableItems);
    if randomizeClothing {
      this.RandomizeClothing();
    };
    this.ScaleItems();
    this.m_displayActivityLog = true;
  }

  private final func ScaleItems() -> Void {
    let i: Int32;
    let inventory: array<wref<gameItemData>>;
    let itemData: wref<gameItemData>;
    let statMod: ref<gameStatModifierData> = RPGManager.CreateStatModifier(gamedataStatType.PowerLevel, gameStatModifierType.Additive, Cast(this.GetProficiencyLevel(gamedataProficiencyType.Level)));
    GameInstance.GetTransactionSystem(this.m_owner.GetGame()).GetItemList(this.m_owner, inventory);
    i = 0;
    while i < ArraySize(inventory) {
      itemData = inventory[i];
      if !RPGManager.GetItemRecord(itemData.GetID()).IsSingleInstance() {
        GameInstance.GetStatsSystem(this.m_owner.GetGame()).RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.PowerLevel);
        GameInstance.GetStatsSystem(this.m_owner.GetGame()).AddSavedModifier(itemData.GetStatsObjectID(), statMod);
      };
      i += 1;
    };
  }

  private final func FlushDevelopment() -> Void {
    let attributeType: gamedataStatType;
    let clearRequest: ref<ClearEquipmentRequest>;
    let es: ref<EquipmentSystem>;
    let perkType: gamedataPerkType;
    let playerItems: array<wref<gameItemData>>;
    let proficiencyType: gamedataProficiencyType;
    let gi: GameInstance = this.m_owner.GetGame();
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(gi);
    let i: Int32 = 0;
    while i < EnumInt(gamedataStatType.Count) {
      attributeType = IntEnum(i);
      if PlayerDevelopmentData.IsAttribute(attributeType) {
        this.ModifyAttribute(attributeType, -statsSystem.GetStatValue(Cast(this.m_owner.GetEntityID()), attributeType));
      };
      i += 1;
    };
    GameInstance.GetStatsSystem(this.m_owner.GetGame()).RemoveAllModifiers(Cast(this.m_owner.GetEntityID()), gamedataStatType.Level);
    i = 0;
    while i < EnumInt(gamedataProficiencyType.Count) {
      proficiencyType = IntEnum(i);
      this.SetLevel(proficiencyType, 0, telemetryLevelGainReason.Ignore);
      i += 1;
    };
    i = 0;
    while i < EnumInt(gamedataPerkType.Count) {
      perkType = IntEnum(i);
      if this.HasPerk(perkType) {
        this.RemovePerk(perkType);
      };
      i += 1;
    };
    es = GameInstance.GetScriptableSystemsContainer(gi).Get(n"EquipmentSystem") as EquipmentSystem;
    clearRequest = new ClearEquipmentRequest();
    clearRequest.owner = this.m_owner;
    es.QueueRequest(clearRequest);
    GameInstance.GetTransactionSystem(gi).GetItemList(this.m_owner, playerItems);
    i = 0;
    while i < ArraySize(playerItems) {
      if playerItems[i].HasTag(n"base_fists") {
      } else {
        if !playerItems[i].HasTag(n"Quest") {
          GameInstance.GetTransactionSystem(gi).RemoveItem(this.m_owner, playerItems[i].GetID(), playerItems[i].GetQuantity());
        };
      };
      i += 1;
    };
  }

  private final const func ProcessBuildEquipment(equipment: array<wref<BuildEquipment_Record>>, randomizeClothing: Bool) -> Void {
    let currentEquipArea: SEquipArea;
    let drawItemRequest: ref<DrawItemRequest>;
    let equipRequest: ref<GameplayEquipRequest>;
    let itemID: ItemID;
    let skipEquip: Bool;
    let skipThisItemQuery: ItemID;
    let gi: GameInstance = this.m_owner.GetGame();
    let isWeaponEquipped: Bool = false;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gi);
    let es: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"EquipmentSystem") as EquipmentSystem;
    let i: Int32 = 0;
    while i < ArraySize(equipment) {
      itemID = ItemID.FromTDBID(equipment[i].Equipment().GetID());
      if randomizeClothing && EquipmentSystem.IsClothing(itemID) {
      } else {
        currentEquipArea = es.GetEquipAreaFromItemID(this.m_owner, itemID);
        if Equals(currentEquipArea.areaType, gamedataEquipmentArea.BaseFists) || Equals(currentEquipArea.areaType, gamedataEquipmentArea.VDefaultHandgun) {
          skipThisItemQuery = ItemID.CreateQuery(ItemID.GetTDBID(itemID));
          skipEquip = es.GetPlayerData(this.m_owner).IsEquipped(skipThisItemQuery);
        };
        if !skipEquip {
          transactionSystem.GiveItem(this.m_owner, itemID, 1);
          equipRequest = new GameplayEquipRequest();
          equipRequest.owner = this.m_owner;
          equipRequest.itemID = itemID;
          equipRequest.blockUpdateWeaponActiveSlots = true;
          es.QueueRequest(equipRequest);
        };
        if IsMultiplayer() && !isWeaponEquipped {
          if Equals(TweakDBInterface.GetItemRecord(equipment[i].Equipment().GetID()).ItemCategory().Type(), gamedataItemCategory.Weapon) {
            isWeaponEquipped = true;
            drawItemRequest = new DrawItemRequest();
            drawItemRequest.owner = this.m_owner;
            drawItemRequest.itemID = itemID;
            es.QueueRequest(drawItemRequest);
          };
        };
      };
      i += 1;
    };
  }

  private final const func ProcessBuildCyberware(cyberware: array<wref<BuildCyberware_Record>>) -> Void {
    let installModuleRequest: ref<EquipRequest>;
    let gi: GameInstance = this.m_owner.GetGame();
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    let es: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"EquipmentSystem") as EquipmentSystem;
    let i: Int32 = 0;
    while i < ArraySize(cyberware) {
      installModuleRequest = new EquipRequest();
      installModuleRequest.owner = this.m_owner;
      installModuleRequest.itemID = ItemID.FromTDBID(cyberware[i].Cyberware().GetID());
      if !ts.HasItem(this.m_owner, ItemID.CreateQuery(cyberware[i].Cyberware().GetID())) {
        installModuleRequest.addToInventory = true;
      };
      es.QueueRequest(installModuleRequest);
      i += 1;
    };
  }

  private final const func ProcessBuildAttributes(attributes: array<wref<BuildAttribute_Record>>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(attributes) {
      this.ModifyAttribute(attributes[i].Attribute().StatType(), Cast(attributes[i].Level()));
      i += 1;
    };
  }

  private final const func ProcessBuildProficiencies(proficiencies: array<wref<BuildProficiency_Record>>) -> Void {
    let level: Int32;
    let type: gamedataProficiencyType;
    let i: Int32 = 0;
    while i < ArraySize(proficiencies) {
      type = proficiencies[i].Proficiency().Type();
      level = proficiencies[i].Level();
      this.SetLevel(type, level, telemetryLevelGainReason.Ignore);
      i += 1;
    };
  }

  private final func ProcessBuildPerks(perks: array<wref<BuildPerk_Record>>) -> Void {
    let j: Int32;
    let i: Int32 = 0;
    while i < ArraySize(perks) {
      j = 0;
      while j < perks[i].Level() {
        this.BuyPerk(perks[i].Perk().Type());
        j += 1;
      };
      i += 1;
    };
  }

  private final const func ProcessBuildItems(items: array<wref<InventoryItem_Record>>) -> Void {
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    let i: Int32 = 0;
    while i < ArraySize(items) {
      transactionSystem.GiveItemByTDBID(this.m_owner, items[i].Item().GetID(), items[i].Quantity());
      i += 1;
    };
  }

  private final const func ProcessCraftbook(recipes: wref<Craftable_Record>) -> Void {
    let craftingSystem: ref<CraftingSystem> = GameInstance.GetScriptableSystemsContainer(this.m_owner.GetGame()).Get(n"CraftingSystem") as CraftingSystem;
    craftingSystem.GetPlayerCraftBook().InitializeCraftBook(this.m_owner, recipes);
  }

  private final func ProcessLifePath(lifePath: wref<LifePath_Record>) -> Void {
    this.m_lifePath = lifePath.Type();
  }

  private final func RandomizeClothing() -> Void {
    let equipRequest: ref<EquipRequest>;
    let itemID: ItemID;
    let items: array<wref<BuildEquipment_Record>>;
    let random: Int32;
    let setRecord: wref<BuildEquipmentSet_Record>;
    let tdbid: TweakDBID;
    let slots: array<gamedataEquipmentArea> = EquipmentSystem.GetClothingEquipmentAreas();
    let es: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(this.m_owner.GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    let i: Int32 = 0;
    while i < ArraySize(slots) {
      ArrayClear(items);
      tdbid = TDBID.Create("BuildSets." + EnumValueToString("gamedataEquipmentArea", Cast(EnumInt(slots[i]))));
      setRecord = TweakDBInterface.GetBuildEquipmentSetRecord(tdbid);
      setRecord.Equipment(items);
      if ArraySize(items) > 0 {
        random = RandRange(0, ArraySize(items));
        itemID = ItemID.FromTDBID(items[random].Equipment().GetID());
        equipRequest = new EquipRequest();
        equipRequest.owner = this.m_owner;
        equipRequest.itemID = itemID;
        equipRequest.addToInventory = true;
        es.QueueRequest(equipRequest);
      };
      i += 1;
    };
  }

  public final func RefreshDevelopmentSystemOnNewGameStarted() -> Void {
    let charCreationAttributes: array<CharacterCustomizationAttribute>;
    let playerPuppet: ref<PlayerPuppet> = this.m_owner as PlayerPuppet;
    this.RefreshDevelopmentSystem();
    charCreationAttributes = GameInstance.GetCharacterCustomizationSystem(playerPuppet.GetGame()).GetState().GetAttributes();
    this.UpdateAttributes(charCreationAttributes);
    GameInstance.GetCharacterCustomizationSystem(playerPuppet.GetGame()).ClearState();
  }

  public final func RefreshDevelopmentSystem() -> Void {
    this.RefreshProficiencyStats();
    this.SetAttributes();
    this.UpdateProficiencyMaxLevels();
    if Equals(this.GetLifePath(), gamedataLifePath.StreetKid) {
      this.SetProgressionBuild(gamedataBuildType.StreetKidStarting);
    } else {
      if Equals(this.GetLifePath(), gamedataLifePath.Nomad) {
        this.SetProgressionBuild(gamedataBuildType.NomadStarting);
      } else {
        if Equals(this.GetLifePath(), gamedataLifePath.Corporate) {
          this.SetProgressionBuild(gamedataBuildType.CorporateStarting);
        } else {
          this.SetProgressionBuild(gamedataBuildType.StartingBuild);
        };
      };
    };
  }

  public final const func UpdatePerkAreaBB(areaIndex: Int32) -> Void {
    let m_ownerStatsBB: ref<IBlackboard>;
    let gi: GameInstance = this.m_owner.GetGame();
    if this.m_owner == GameInstance.GetPlayerSystem(gi).GetLocalPlayerMainGameObject() {
      m_ownerStatsBB = GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_PlayerStats);
      m_ownerStatsBB.SetVariant(GetAllBlackboardDefs().UI_PlayerStats.ModifiedPerkArea, ToVariant(this.m_perkAreas[areaIndex]), true);
    };
  }

  public final const func UpdateUIBB() -> Void {
    let gi: GameInstance = this.m_owner.GetGame();
    let m_ownerStatsBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_PlayerStats);
    if IsDefined(m_ownerStatsBB) && this.m_owner == GameInstance.GetPlayerSystem(gi).GetLocalPlayerMainGameObject() {
      m_ownerStatsBB.SetInt(GetAllBlackboardDefs().UI_PlayerStats.Level, this.GetProficiencyLevel(gamedataProficiencyType.Level), true);
      m_ownerStatsBB.SetInt(GetAllBlackboardDefs().UI_PlayerStats.CurrentXP, this.GetCurrentLevelProficiencyExp(gamedataProficiencyType.Level), true);
      m_ownerStatsBB.SetInt(GetAllBlackboardDefs().UI_PlayerStats.StreetCredLevel, this.GetProficiencyLevel(gamedataProficiencyType.StreetCred), true);
      m_ownerStatsBB.SetInt(GetAllBlackboardDefs().UI_PlayerStats.StreetCredPoints, this.GetCurrentLevelProficiencyExp(gamedataProficiencyType.StreetCred), true);
      m_ownerStatsBB.SetVariant(GetAllBlackboardDefs().UI_PlayerStats.DevelopmentPoints, ToVariant(this.m_devPoints), true);
      m_ownerStatsBB.SetVariant(GetAllBlackboardDefs().UI_PlayerStats.Proficiency, ToVariant(this.m_proficiencies), true);
      m_ownerStatsBB.SetVariant(GetAllBlackboardDefs().UI_PlayerStats.Perks, ToVariant(this.m_perkAreas), true);
      m_ownerStatsBB.SetVariant(GetAllBlackboardDefs().UI_PlayerStats.Attributes, ToVariant(this.m_attributes), true);
      m_ownerStatsBB.SetInt(GetAllBlackboardDefs().UI_PlayerStats.PhysicalResistance, Cast(GameInstance.GetStatsSystem(gi).GetStatValue(Cast(this.m_owner.GetEntityID()), gamedataStatType.PhysicalResistance)), true);
      m_ownerStatsBB.SetInt(GetAllBlackboardDefs().UI_PlayerStats.ThermalResistance, Cast(GameInstance.GetStatsSystem(gi).GetStatValue(Cast(this.m_owner.GetEntityID()), gamedataStatType.ThermalDamage)), true);
      m_ownerStatsBB.SetInt(GetAllBlackboardDefs().UI_PlayerStats.EnergyResistance, Cast(GameInstance.GetStatsSystem(gi).GetStatValue(Cast(this.m_owner.GetEntityID()), gamedataStatType.ElectricResistance)), true);
      m_ownerStatsBB.SetInt(GetAllBlackboardDefs().UI_PlayerStats.ChemicalResistance, Cast(GameInstance.GetStatsSystem(gi).GetStatValue(Cast(this.m_owner.GetEntityID()), gamedataStatType.ChemicalResistance)), true);
      m_ownerStatsBB.SetInt(GetAllBlackboardDefs().UI_PlayerStats.weightMax, Cast(GameInstance.GetStatsSystem(gi).GetStatValue(Cast(this.m_owner.GetEntityID()), gamedataStatType.CarryCapacity)), true);
    };
  }
}

public class PlayerDevelopmentSystem extends ScriptableSystem {

  private persistent let m_playerData: array<ref<PlayerDevelopmentData>>;

  private persistent let m_ownerData: array<ref<PlayerDevelopmentData>>;

  public final static func GetInstance(owner: ref<GameObject>) -> ref<PlayerDevelopmentSystem> {
    let PDS: ref<PlayerDevelopmentSystem> = GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
    return PDS;
  }

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    let data: ref<PlayerDevelopmentData>;
    let updatePDS: ref<UpdatePlayerDevelopment>;
    LogAssert(this.GetDevelopmentData(request.owner) == null, "[PlayerDevelopmentSystem::OnPlayerAttach] Player already attached!");
    if !IsDefined(this.GetDevelopmentData(request.owner)) {
      data = new PlayerDevelopmentData();
      data.SetOwner(request.owner);
      data.SetLifePath(GameInstance.GetCharacterCustomizationSystem(request.owner.GetGame()).GetState().GetLifePath());
      updatePDS = new UpdatePlayerDevelopment();
      updatePDS.Set(request.owner);
      GameInstance.GetScriptableSystemsContainer(request.owner.GetGame()).Get(n"PlayerDevelopmentSystem").QueueRequest(updatePDS);
      ArrayPush(this.m_playerData, data);
      data.OnNewGame();
    } else {
      data = this.GetDevelopmentData(request.owner);
    };
    data.OnAttach();
  }

  private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_playerData) {
      if this.m_playerData[i].GetOwner() == request.owner {
        this.m_playerData[i].OnDetach();
        return;
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_ownerData) {
      if this.m_ownerData[i].GetOwner() == request.owner {
        this.m_ownerData[i].OnDetach();
        return;
      };
      i += 1;
    };
    LogAssert(false, "[PlayerDevelopmentSystem::OnPlayerDetach] Can\'t find player!");
  }

  private final const func GetDevelopmentData(owner: ref<GameObject>) -> ref<PlayerDevelopmentData> {
    let i: Int32;
    LogAssert(owner != null, "[PlayerDevelopmentSystem::GetDevelopmentData] Owner not defined!");
    i = 0;
    while i < ArraySize(this.m_playerData) {
      if this.m_playerData[i].GetOwner() == owner {
        return this.m_playerData[i];
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_ownerData) {
      if this.m_ownerData[i].GetOwner() == owner {
        return this.m_ownerData[i];
      };
      i += 1;
    };
    LogAssert(false, "[PlayerDevelopmentSystem::GetDevelopmentData] Unable to find player data!");
    return null;
  }

  public final static func GetData(owner: ref<GameObject>) -> ref<PlayerDevelopmentData> {
    let playerDevSystem: ref<PlayerDevelopmentSystem> = GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
    return playerDevSystem.GetDevelopmentData(owner);
  }

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    let gameInstance: GameInstance = this.GetGameInstance();
    let i: Int32 = 0;
    while i < ArraySize(this.m_playerData) {
      this.m_playerData[i].OnRestored(gameInstance);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_ownerData) {
      this.m_ownerData[i].OnRestored(gameInstance);
      i += 1;
    };
  }

  public final const func IsProficiencyMaxLvl(owner: ref<GameObject>, type: gamedataProficiencyType) -> Bool {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.IsProficiencyMaxLvl(type);
  }

  public final const func GetProficiencyLevel(owner: ref<GameObject>, type: gamedataProficiencyType) -> Int32 {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.GetProficiencyLevel(type);
  }

  public final const func GetProficiencyAbsoluteMaxLevel(owner: ref<GameObject>, type: gamedataProficiencyType) -> Int32 {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.GetProficiencyAbsoluteMaxLevel(type);
  }

  public final const func GetCurrentLevelProficiencyExp(owner: ref<GameObject>, type: gamedataProficiencyType) -> Int32 {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.GetCurrentLevelProficiencyExp(type);
  }

  public final const func GetTotalProfExperience(owner: ref<GameObject>, type: gamedataProficiencyType) -> Int32 {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.GetTotalProfExperience(type);
  }

  public final const func GetRemainingExpForLevelUp(owner: ref<GameObject>, type: gamedataProficiencyType) -> Int32 {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.GetRemainingExpForLevelUp(type);
  }

  public final const func GetDominatingCombatProficiency(owner: ref<GameObject>) -> gamedataProficiencyType {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.GetDominatingCombatProficiency();
  }

  public final const func GetDevPoints(owner: ref<GameObject>, type: gamedataDevelopmentPointType) -> Int32 {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.GetDevPoints(type);
  }

  public final const func GetPerkLevel(owner: ref<GameObject>, type: gamedataPerkType) -> Int32 {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.GetPerkLevel(type);
  }

  public final const func GetPerkMaxLevel(owner: ref<GameObject>, type: gamedataPerkType) -> Int32 {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.GetPerkMaxLevel(type);
  }

  public final const func HasPerk(owner: ref<GameObject>, type: gamedataPerkType) -> Bool {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.HasPerk(type);
  }

  public final const func GetPerks(owner: ref<GameObject>) -> array<SPerk> {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.GetPerks();
  }

  public final const func IsPerkImplemented(owner: ref<GameObject>, perk: gamedataPerkType) -> Bool {
    let levelsData: array<wref<PerkLevelData_Record>>;
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    developmentData.GetPerkRecord(perk).Levels(levelsData);
    return ArraySize(levelsData) > 0;
  }

  public final const func BuyAttribute(owner: ref<GameObject>, obj: ref<GameObject>, type: gamedataStatType) -> Bool {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.BuyAttribute(type);
  }

  public final const func SetAttribute(owner: ref<GameObject>, obj: ref<GameObject>, type: gamedataStatType, amount: Float) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.SetAttribute(type, amount);
  }

  public final const func GetAttributes(owner: ref<GameObject>) -> array<SAttribute> {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.GetAttributes();
  }

  public final const func GetHighestCompletedMinigameLevel(owner: ref<GameObject>) -> Int32 {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return developmentData.GetHighestCompletedMinigameLevel();
  }

  public final const func GetLifePath(owner: ref<GameObject>) -> gamedataLifePath {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
    return IsDefined(developmentData) ? developmentData.GetLifePath() : gamedataLifePath.Invalid;
  }

  private final func OnExperienceQueued(request: ref<QueueCombatExperience>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.QueueCombatExperience(request.m_amount, request.m_experienceType, request.m_entity);
  }

  private final func OnProcessQueuedExperience(request: ref<ProcessQueuedCombatExperience>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.ProcessQueuedCombatExperience(request.m_entity);
  }

  private final func OnExperienceAdded(request: ref<AddExperience>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.AddExperience(request.m_amount, request.m_experienceType, request.m_debug ? telemetryLevelGainReason.IsDebug : telemetryLevelGainReason.Gameplay);
  }

  private final func OnSetProficiencyLevel(request: ref<SetProficiencyLevel>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.SetLevel(request.m_proficiencyType, request.m_newLevel, request.m_telemetryLevelGainReason);
  }

  private final func OnPerkBought(request: ref<BuyPerk>) -> Void {
    let perkBoughtEvent: ref<PerkBoughtEvent>;
    let playerStatsBB: ref<IBlackboard>;
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    let buyResult: Bool = developmentData.BuyPerk(request.m_perkType);
    if buyResult {
      perkBoughtEvent = new PerkBoughtEvent();
      perkBoughtEvent.perkType = request.m_perkType;
      playerStatsBB = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_PlayerStats);
      playerStatsBB.SetInt(GetAllBlackboardDefs().UI_PlayerStats.weightMax, Cast(GameInstance.GetStatsSystem(this.GetGameInstance()).GetStatValue(Cast(request.owner.GetEntityID()), gamedataStatType.CarryCapacity)), true);
      GameInstance.GetUISystem(this.GetGameInstance()).QueueEvent(perkBoughtEvent);
      GameInstance.GetTelemetrySystem(this.GetGameInstance()).LogPerkUpgraded(request.m_perkType, developmentData.GetPerkLevel(request.m_perkType));
    };
  }

  private final func OnTraitLevelIncreased(request: ref<IncreaseTraitLevel>) -> Void {
    let traitBoughtEvent: ref<TraitBoughtEvent>;
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    let buyResult: Bool = developmentData.IncreaseTraitLevel(request.m_trait);
    if buyResult {
      traitBoughtEvent = new TraitBoughtEvent();
      traitBoughtEvent.traitType = request.m_trait;
      GameInstance.GetUISystem(this.GetGameInstance()).QueueEvent(traitBoughtEvent);
    };
  }

  private final func OnPerkRemoved(request: ref<RemovePerk>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.RemovePerk(request.m_perkType);
  }

  private final func OnAllPerksRemoved(request: ref<RemoveAllPerks>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.RemoveAllPerks();
  }

  private final func OnUnlockPerkArea(request: ref<UnlockPerkArea>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.UnlockPerkArea(request.m_perkArea);
  }

  private final func OnLockPerkArea(request: ref<LockPerkArea>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.LockPerkArea(request.m_perkArea);
  }

  private final func OnAttributeSet(request: ref<SetAttribute>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.SetAttribute(request.m_attributeType, request.m_statLevel);
  }

  private final func OnAttributeBuy(request: ref<BuyAttribute>) -> Void {
    let attributeBoughtEvent: ref<AttributeBoughtEvent>;
    let result: Bool;
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    if !PlayerDevelopmentData.IsAttribute(request.m_attributeType) {
      return;
    };
    if request.m_grantAttributePoint {
      developmentData.AddDevelopmentPoints(1, gamedataDevelopmentPointType.Attribute);
    };
    result = developmentData.BuyAttribute(request.m_attributeType);
    if result {
      attributeBoughtEvent = new AttributeBoughtEvent();
      attributeBoughtEvent.attributeType = request.m_attributeType;
      GameInstance.GetUISystem(this.GetGameInstance()).QueueEvent(attributeBoughtEvent);
      GameInstance.GetTelemetrySystem(this.GetGameInstance()).LogAttributeUpgraded(request.m_attributeType, RoundF(GameInstance.GetStatsSystem(this.GetGameInstance()).GetStatValue(Cast(request.owner.GetEntityID()), request.m_attributeType)));
    };
  }

  private final func OnDevelopmentPointsAdded(request: ref<AddDevelopmentPoints>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.AddDevelopmentPoints(request.m_amountOfPoints, request.m_developmentPointType);
  }

  private final func OnSkillCheckPrereqModified(request: ref<ModifySkillCheckPrereq>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    if request.m_register {
      developmentData.RegisterSkillCheckPrereq(request.m_skillCheckState);
    } else {
      developmentData.UnregisterSkillCheckPrereq(request.m_skillCheckState);
    };
  }

  private final func OnStatCheckPrereqModified(request: ref<ModifyStatCheckPrereq>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    if request.m_register {
      developmentData.RegisterStatCheckPrereq(request.m_statCheckState);
    } else {
      developmentData.UnregisterStatCheckPrereq(request.m_statCheckState);
    };
  }

  private final func OnUpdatePlayerDevelopment(request: ref<UpdatePlayerDevelopment>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    if !this.WasRestored() {
      developmentData.RefreshDevelopmentSystemOnNewGameStarted();
    };
  }

  private final func OnSetProgressionBuild(request: ref<SetProgressionBuild>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.SetProgressionBuild(request.m_buildType);
  }

  private final func OnSetProgressionBuild(request: ref<questSetProgressionBuildRequest>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.SetProgressionBuild(request.buildID);
  }

  private final func OnSetProgressionBuild(request: ref<gameSetProgressionBuildRequest>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    if !this.WasRestored() {
      developmentData.RefreshDevelopmentSystem();
    };
    developmentData.SetProgressionBuild(request.buildID);
  }

  private final func OnRefreshPerkAreas(request: ref<RefreshPerkAreas>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.RefreshPerkAreas();
  }

  private final func OnSetLifePath(request: ref<questSetLifePathRequest>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.SetLifePath(request.lifePathID);
  }

  private final func OnBumpNetrunnerMinigameLevel(request: ref<BumpNetrunnerMinigameLevel>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.BumpNetrunnerMinigameLevel(request.completedMinigameLevel);
  }

  private final const func GetProficiencyRecord(type: gamedataProficiencyType) -> ref<Proficiency_Record> {
    return TweakDBInterface.GetProficiencyRecord(TDBID.Create("Proficiencies." + EnumValueToString("gamedataProficiencyType", Cast(EnumInt(type)))));
  }

  private final func OnRequestStatsBB(request: ref<RequestStatsBB>) -> Void {
    let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(request.owner);
    developmentData.UpdateUIBB();
  }
}

public static func CreateExpEvent(amount: Int32, type: gamedataProficiencyType) -> ref<ExperiencePointsEvent> {
  let evt: ref<ExperiencePointsEvent> = new ExperiencePointsEvent();
  evt.amount = amount;
  evt.type = type;
  evt.isDebug = true;
  return evt;
}
