
public class DismembermentTriggeredHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_dotType: gamedataStatusEffectType;

  public func SetData(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".dotType", "");
    this.m_dotType = IntEnum(Cast(EnumValueFromString("gamedataStatusEffectType", str)));
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let attackRecord: ref<Attack_GameEffect_Record>;
    let attackTag: CName;
    let result: Bool;
    if Equals(hitEvent.attackData.GetAttackType(), gamedataAttackType.Effect) {
      attackRecord = hitEvent.attackData.GetAttackDefinition().GetRecord() as Attack_GameEffect_Record;
      if IsDefined(attackRecord) {
        attackTag = attackRecord.AttackTag();
      };
      result = Equals(IntEnum(Cast(EnumValueFromName(n"gamedataStatusEffectType", attackTag))), this.m_dotType);
      return result;
    };
    return false;
  }
}
