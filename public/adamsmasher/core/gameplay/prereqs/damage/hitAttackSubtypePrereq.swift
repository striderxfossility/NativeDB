
public class HitAttackSubtypePrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let prereq: ref<HitAttackSubtypePrereq> = this.GetPrereq() as HitAttackSubtypePrereq;
    if NotEquals(prereq.m_attackSubtype, gamedataAttackSubtype.Invalid) {
      if !IsDefined(hitEvent.attackData) {
        return false;
      };
      if Equals(hitEvent.attackData.GetAttackSubtype(), prereq.m_attackSubtype) {
        return true;
      };
    };
    return false;
  }
}

public class HitAttackSubtypePrereq extends GenericHitPrereq {

  public let m_attackSubtype: gamedataAttackSubtype;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let result: Int32;
    let str: String;
    this.Initialize(recordID);
    str = TweakDBInterface.GetString(recordID + t".attackSubtype", "");
    result = Cast(EnumValueFromString("gamedataAttackSubtype", str));
    if result < 0 {
      this.m_attackSubtype = gamedataAttackSubtype.Invalid;
    } else {
      this.m_attackSubtype = IntEnum(result);
    };
  }
}
