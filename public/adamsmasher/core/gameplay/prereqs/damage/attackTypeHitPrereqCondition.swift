
public class AttackTypeHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_attackType: gamedataAttackType;

  public func SetData(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".attackType", "");
    let result: gamedataAttackType = IntEnum(Cast(EnumValueFromString("gamedataAttackType", str)));
    if EnumInt(result) < 0 {
      this.m_attackType = gamedataAttackType.Invalid;
    } else {
      this.m_attackType = result;
    };
    this.SetData(recordID);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result: Bool = Equals(hitEvent.attackData.GetAttackType(), this.m_attackType);
    return this.m_invert ? !result : result;
  }
}
