
public class DamageTypePrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let prereq: ref<DamageTypePrereq> = this.GetPrereq() as DamageTypePrereq;
    return hitEvent.attackComputed.GetAttackValue(prereq.m_damageType) > 0.00;
  }
}

public class DamageTypePrereq extends GenericHitPrereq {

  public let m_damageType: gamedataDamageType;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let str: String;
    this.Initialize(recordID);
    str = TweakDBInterface.GetString(recordID + t".damageType", "");
    this.m_damageType = IntEnum(Cast(EnumValueFromString("gamedataDamageType", str)));
  }
}
