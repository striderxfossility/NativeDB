
public class HitFlagPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let prereq: ref<HitFlagPrereq> = this.GetPrereq() as HitFlagPrereq;
    return hitEvent.attackData.HasFlag(prereq.m_flag);
  }
}

public class HitFlagPrereq extends GenericHitPrereq {

  public let m_flag: hitFlag;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String;
    this.Initialize(recordID);
    str = TweakDBInterface.GetString(recordID + t".hitFlag", "");
    this.m_flag = IntEnum(Cast(EnumValueFromString("hitFlag", str)));
  }
}
