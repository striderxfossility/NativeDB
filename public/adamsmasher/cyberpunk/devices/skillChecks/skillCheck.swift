
public abstract class SkillCheckBase extends IScriptable {

  @attrib(customEditor, "TweakDBGroupInheritance;Interactions.InteractionChoice;Interactions.MountChoice")
  public let m_alternativeName: TweakDBID;

  public let m_difficulty: EGameplayChallengeLevel;

  public inline let m_additionalRequirements: ref<GameplayConditionContainer>;

  public let m_duration: Float;

  protected persistent let m_isActive: Bool;

  protected persistent let m_wasPassed: Bool;

  protected let m_skillCheckPerformed: Bool;

  @default(DemolitionSkillCheck, EDeviceChallengeSkill.Athletics)
  @default(EngineeringSkillCheck, EDeviceChallengeSkill.Engineering)
  @default(HackingSkillCheck, EDeviceChallengeSkill.Hacking)
  protected let m_skillToCheck: EDeviceChallengeSkill;

  protected let m_baseSkill: ref<GameplaySkillCondition>;

  protected persistent let m_isDynamic: Bool;

  public func Initialize() -> Void {
    this.m_baseSkill = new GameplaySkillCondition();
    if NotEquals(this.m_difficulty, EGameplayChallengeLevel.NONE) {
      this.m_isActive = true;
      this.m_baseSkill.SetProperties(this.m_skillToCheck, this.m_difficulty);
    };
  }

  public final func SetDynamic(isDynamic: Bool) -> Void {
    this.m_isDynamic = isDynamic;
  }

  public final const func IsDynamic() -> Bool {
    return this.m_isDynamic;
  }

  public const func Evaluate(requester: ref<GameObject>) -> Bool {
    let skillCheckPassed: Bool;
    if this.IsActive() {
      if IsDefined(this.m_additionalRequirements) && this.m_additionalRequirements.GetGroupsAmount() > 0 {
        if Equals(this.m_additionalRequirements.GetOperator(), ELogicOperator.AND) {
          skillCheckPassed = this.m_baseSkill.Evaluate(requester) && this.m_additionalRequirements.Evaluate(requester);
        } else {
          if Equals(this.m_additionalRequirements.GetOperator(), ELogicOperator.OR) {
            skillCheckPassed = this.m_baseSkill.Evaluate(requester) || this.m_additionalRequirements.Evaluate(requester);
          };
        };
      } else {
        skillCheckPassed = this.m_baseSkill.Evaluate(requester);
      };
    };
    return skillCheckPassed;
  }

  public final const func GetDifficulty() -> EGameplayChallengeLevel {
    return this.m_difficulty;
  }

  public final func SetIsActive(value: Bool) -> Void {
    this.m_isActive = value;
  }

  public final func SetIsPassed(value: Bool) -> Void {
    this.m_wasPassed = value;
  }

  public final const func IsActive() -> Bool {
    return this.m_isActive;
  }

  public final const func IsPassed() -> Bool {
    return this.m_wasPassed;
  }

  public final func GetSkill() -> EDeviceChallengeSkill {
    return this.m_skillToCheck;
  }

  public final const func GetBaseSkill() -> ref<GameplaySkillCondition> {
    return this.m_baseSkill;
  }

  public final func CheckPerformed() -> Void {
    this.m_skillCheckPerformed = true;
  }

  public final const func WasPerformed() -> Bool {
    return this.m_skillCheckPerformed;
  }

  public final const func GetAlternativeName() -> TweakDBID {
    return this.m_alternativeName;
  }

  public final const func GetDuration() -> Float {
    return this.m_duration;
  }

  public final func SetDuration(duration: Float) -> Void {
    this.m_duration = duration;
  }
}
