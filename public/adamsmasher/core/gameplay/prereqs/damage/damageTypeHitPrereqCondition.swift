
public class DamageTypeHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_damageType: gamedataDamageType;

  public func SetData(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".damageType", "");
    this.m_damageType = IntEnum(Cast(EnumValueFromString("gamedataDamageType", str)));
    this.SetData(recordID);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result: Bool = hitEvent.attackComputed.GetAttackValue(this.m_damageType) > 0.00;
    return this.m_invert ? !result : result;
  }
}
