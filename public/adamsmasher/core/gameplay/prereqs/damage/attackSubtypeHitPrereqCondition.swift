
public class AttackSubtypeHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_attackSubtype: gamedataAttackSubtype;

  public func SetData(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".attackSubtype", "");
    let result: gamedataAttackSubtype = IntEnum(Cast(EnumValueFromString("gamedataAttackSubtype", str)));
    if EnumInt(result) < 0 {
      this.m_attackSubtype = gamedataAttackSubtype.Invalid;
    } else {
      this.m_attackSubtype = result;
    };
    this.SetData(recordID);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result: Bool = Equals(hitEvent.attackData.GetAttackSubtype(), this.m_attackSubtype);
    return this.m_invert ? !result : result;
  }
}
