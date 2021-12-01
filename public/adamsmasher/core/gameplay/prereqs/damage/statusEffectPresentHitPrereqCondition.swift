
public class StatusEffectPresentHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_checkType: CName;

  public let m_statusEffectParam: CName;

  public let m_tag: CName;

  @default(StatusEffectPresentHitPrereqCondition, Target)
  public let m_objectToCheck: CName;

  public func SetData(recordID: TweakDBID) -> Void {
    this.m_statusEffectParam = TweakDBInterface.GetCName(recordID + t".statusEffect", n"");
    this.m_checkType = TweakDBInterface.GetCName(recordID + t".checkType", n"");
    this.m_tag = TweakDBInterface.GetCName(recordID + t".tagToCheck", n"");
    this.m_objectToCheck = TweakDBInterface.GetCName(recordID + t".objectToCheck", n"");
    this.SetData(recordID);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result: Bool;
    let statusEffectType: gamedataStatusEffectType;
    let objectToCheck: wref<gamePuppet> = this.GetObjectToCheck(this.m_objectToCheck, hitEvent) as gamePuppet;
    if IsDefined(objectToCheck) {
      switch this.m_checkType {
        case n"TAG":
          result = StatusEffectSystem.ObjectHasStatusEffectWithTag(objectToCheck, this.m_tag);
          break;
        case n"TYPE":
          statusEffectType = IntEnum(Cast(EnumValueFromName(n"gamedataStatusEffectType", this.m_statusEffectParam)));
          result = StatusEffectSystem.ObjectHasStatusEffectOfType(objectToCheck, statusEffectType);
          break;
        case n"RECORD":
          result = StatusEffectSystem.ObjectHasStatusEffect(objectToCheck, TDBID.Create("BaseStatusEffect." + NameToString(this.m_statusEffectParam)));
          break;
        default:
          return false;
      };
    };
    return this.m_invert ? !result : result;
  }
}
