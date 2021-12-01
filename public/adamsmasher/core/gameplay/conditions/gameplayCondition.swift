
public abstract class GameplayConditionBase extends IScriptable {

  protected let m_entityID: EntityID;

  public func Evaluate(requester: ref<GameObject>) -> Bool {
    return false;
  }

  public func GetDescription(requester: ref<GameObject>) -> Condition {
    let empty: Condition;
    return empty;
  }

  protected final func GetPlayer(requester: ref<GameObject>) -> ref<GameObject> {
    return GameInstance.GetPlayerSystem(requester.GetGame()).GetLocalPlayerMainGameObject();
  }

  public final func SetEntityID(id: EntityID) -> Void {
    this.m_entityID = id;
  }
}

public class GameplaySkillCondition extends GameplayConditionBase {

  @attrib(customEditor, "TweakDBGroupInheritance;BaseStats.SkillStat")
  public let m_skillToCheck: TweakDBID;

  private let m_difficulty: EGameplayChallengeLevel;

  public func Evaluate(requester: ref<GameObject>) -> Bool {
    if this.GetPlayerSkill(requester) >= this.GetRequiredLevel(requester.GetGame()) {
      return true;
    };
    return false;
  }

  public final func GetRequiredLevel(gi: GameInstance) -> Int32 {
    return RPGManager.CheckDifficultyToStatValue(gi, this.GetStatType(), this.m_difficulty, this.m_entityID);
  }

  public final func GetPlayerSkill(requester: ref<GameObject>) -> Int32 {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(requester.GetGame());
    return Cast(statsSystem.GetStatValue(Cast(GameInstance.GetPlayerSystem(requester.GetGame()).GetLocalPlayerControlledGameObject().GetEntityID()), this.GetStatType()));
  }

  private final func GetStatType() -> gamedataStatType {
    return TweakDBInterface.GetStatRecord(this.m_skillToCheck).StatType();
  }

  public final func SetProperties(sel_skill: EDeviceChallengeSkill, sel_difficulty: EGameplayChallengeLevel) -> Void {
    let skillString: String;
    this.m_difficulty = sel_difficulty;
    if Equals(sel_skill, EDeviceChallengeSkill.Hacking) {
      skillString = "Intelligence";
    } else {
      if Equals(sel_skill, EDeviceChallengeSkill.Engineering) {
        skillString = "TechnicalAbility";
      } else {
        if Equals(sel_skill, EDeviceChallengeSkill.Athletics) {
          skillString = "Strength";
        };
      };
    };
    this.m_skillToCheck = TDBID.Create("BaseStats." + skillString);
  }

  public func GetDescription(requester: ref<GameObject>) -> Condition {
    let description: Condition;
    description.description = this.GetConditionDescription(requester.GetGame());
    description.passed = this.Evaluate(requester);
    return description;
  }

  private final func GetConditionDescription(gi: GameInstance) -> String {
    let skill: String = TweakDBInterface.GetStatRecord(this.m_skillToCheck).EnumName();
    let text: String = "Attribute: " + skill + " " + ToString(this.GetRequiredLevel(gi));
    return text;
  }
}

public class GameplayPerkCondition extends GameplayConditionBase {

  @attrib(customEditor, "TweakDBGroupInheritance;Perk")
  public let m_perkToCheck: TweakDBID;

  public let m_difficulty: EGameplayChallengeLevel;

  public func Evaluate(requester: ref<GameObject>) -> Bool {
    if this.GetPlayerPerk(requester) >= this.GetRequiredLevel() {
      return true;
    };
    return false;
  }

  private final func GetPlayerPerk(requester: ref<GameObject>) -> Int32 {
    let player: ref<GameObject> = this.GetPlayer(requester);
    let playerDevSystem: ref<PlayerDevelopmentSystem> = GameInstance.GetScriptableSystemsContainer(player.GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
    return playerDevSystem.GetPerkLevel(player, this.GetPerkType());
  }

  private final func GetRequiredLevel() -> Int32 {
    return RPGManager.CheckDifficultyToPerkLevel(this.GetPerkType(), this.m_difficulty, this.m_entityID);
  }

  private final func GetPerkType() -> gamedataPerkType {
    return TweakDBInterface.GetPerkRecord(this.m_perkToCheck).Type();
  }

  public func GetDescription(requester: ref<GameObject>) -> Condition {
    let description: Condition;
    description.description = this.GetConditionDescription();
    description.passed = this.Evaluate(requester);
    return description;
  }

  private final func GetConditionDescription() -> String {
    let max: String;
    let perkLevels: array<wref<PerkLevelData_Record>>;
    let text: String;
    let perk: String = TweakDBInterface.GetPerkRecord(this.m_perkToCheck).Loc_name_key();
    TweakDBInterface.GetPerkRecord(this.m_perkToCheck).Levels(perkLevels);
    max = ToString(ArraySize(perkLevels));
    text = "Has perk: " + perk + " " + ToString(this.GetRequiredLevel()) + "/" + max;
    return text;
  }
}

public class GameplayItemCondition extends GameplayConditionBase {

  @attrib(customEditor, "TweakDBGroupInheritance;Item")
  public let m_itemToCheck: TweakDBID;

  public func Evaluate(requester: ref<GameObject>) -> Bool {
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(requester.GetGame());
    let itemID: ItemID = ItemID.FromTDBID(this.m_itemToCheck);
    return transactionSystem.HasItem(this.GetPlayer(requester), itemID);
  }

  public func GetDescription(requester: ref<GameObject>) -> Condition {
    let description: Condition;
    description.description = this.GetConditionDescription();
    description.passed = this.Evaluate(requester);
    return description;
  }

  private final func GetConditionDescription() -> String {
    let item: String = ToString(TweakDBInterface.GetItemRecord(this.m_itemToCheck).DisplayName());
    let text: String = "Has item: " + item;
    return text;
  }
}

public class GameplayCyberwareCondition extends GameplayConditionBase {

  @attrib(customEditor, "TweakDBGroupInheritance;Item")
  public let m_cyberwareToCheck: TweakDBID;

  public func Evaluate(requester: ref<GameObject>) -> Bool {
    let equipmentSystem: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(this.GetPlayer(requester).GetGame()).Get(n"CyberwareSystem") as EquipmentSystem;
    let itemID: ItemID = ItemID.CreateQuery(this.m_cyberwareToCheck);
    return equipmentSystem.GetPlayerData(this.GetPlayer(requester)).IsEquipped(itemID);
  }

  public func GetDescription(requester: ref<GameObject>) -> Condition {
    let description: Condition;
    description.description = this.GetConditionDescription();
    description.passed = this.Evaluate(requester);
    return description;
  }

  private final func GetConditionDescription() -> String {
    let item: String = ToString(TweakDBInterface.GetItemRecord(this.m_cyberwareToCheck).DisplayName());
    let text: String = "Has installed " + item + " cyberware";
    return text;
  }
}

public class GameplayFactCondition extends GameplayConditionBase {

  public let m_factName: CName;

  public let m_value: Int32;

  public let m_comparisonType: ECompareOp;

  @default(GameplayFactCondition, Quest progress)
  public let m_description: String;

  public func Evaluate(requester: ref<GameObject>) -> Bool {
    let factValue: Int32 = GameInstance.GetQuestsSystem(requester.GetGame()).GetFact(this.m_factName);
    return Compare(this.m_comparisonType, factValue, this.m_value);
  }

  public func GetDescription(requester: ref<GameObject>) -> Condition {
    let description: Condition;
    description.description = this.m_description;
    description.passed = this.Evaluate(requester);
    return description;
  }
}

public class GameplayStatCondition extends GameplayConditionBase {

  private let m_statToCheck: TweakDBID;

  private let m_stat: EDeviceChallengeAttribute;

  private let m_difficulty: EGameplayChallengeLevel;

  public func Evaluate(requester: ref<GameObject>) -> Bool {
    if this.GetPlayerStat(requester) >= this.GetRequiredLevel(requester.GetGame()) {
      return true;
    };
    return false;
  }

  public final func GetRequiredLevel(gi: GameInstance) -> Int32 {
    return RPGManager.CheckDifficultyToStatValue(gi, this.GetStatType(), this.m_difficulty, this.m_entityID);
  }

  public final func GetPlayerStat(requester: ref<GameObject>) -> Int32 {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(requester.GetGame());
    return Cast(statsSystem.GetStatValue(Cast(this.GetPlayer(requester).GetEntityID()), this.GetStatType()));
  }

  private final func GetStatType() -> gamedataStatType {
    this.m_statToCheck = TDBID.Create("BaseStats." + ToString(this.m_stat));
    return TweakDBInterface.GetStatRecord(this.m_statToCheck).StatType();
  }

  public func GetDescription(requester: ref<GameObject>) -> Condition {
    let description: Condition;
    description.description = this.GetConditionDescription(requester.GetGame());
    description.passed = this.Evaluate(requester);
    return description;
  }

  private final func GetConditionDescription(gi: GameInstance) -> String {
    let stat: String = TweakDBInterface.GetStatRecord(this.m_statToCheck).EnumName();
    let text: String = "Stat: " + stat + " " + ToString(this.GetRequiredLevel(gi));
    return text;
  }

  public final func SetProperties(sel_stat: EDeviceChallengeAttribute, sel_difficulty: EGameplayChallengeLevel) -> Void {
    this.m_stat = sel_stat;
    this.m_difficulty = sel_difficulty;
  }
}
