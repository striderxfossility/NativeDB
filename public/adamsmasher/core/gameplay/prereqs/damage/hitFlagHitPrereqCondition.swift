
public class HitFlagHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_hitFlag: hitFlag;

  public func SetData(recordID: TweakDBID) -> Void {
    let str: String = TweakDBInterface.GetString(recordID + t".hitFlag", "");
    this.m_hitFlag = IntEnum(Cast(EnumValueFromString("hitFlag", str)));
    this.SetData(recordID);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result: Bool = hitEvent.attackData.HasFlag(this.m_hitFlag);
    return this.m_invert ? !result : result;
  }
}
