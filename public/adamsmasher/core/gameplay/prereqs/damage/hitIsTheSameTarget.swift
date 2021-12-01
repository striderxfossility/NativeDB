
public class HitIsTheSameTargetPrereqState extends GenericHitPrereqState {

  public let m_previousTarget: wref<GameObject>;

  public let m_previousSource: wref<GameObject>;

  public let m_previousWeapon: wref<WeaponObject>;

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let checkPassed: Bool;
    let prereq: ref<HitIsTheSameTargetPrereq> = this.GetPrereq() as HitIsTheSameTargetPrereq;
    if !hitEvent.target.IsActive() {
      return true;
    };
    if !IsDefined(this.m_previousTarget) || !IsDefined(this.m_previousSource) || !IsDefined(this.m_previousWeapon) {
      this.m_previousTarget = hitEvent.target;
      this.m_previousSource = hitEvent.attackData.GetSource();
      this.m_previousWeapon = hitEvent.attackData.GetWeapon();
      return false;
    };
    checkPassed = this.m_previousTarget == hitEvent.target && this.m_previousSource == hitEvent.attackData.GetSource() && this.m_previousWeapon == hitEvent.attackData.GetWeapon();
    if !checkPassed {
      this.m_previousTarget = hitEvent.target;
      this.m_previousSource = hitEvent.attackData.GetSource();
      this.m_previousWeapon = hitEvent.attackData.GetWeapon();
    };
    if prereq.m_invert {
      checkPassed = !checkPassed;
    };
    return checkPassed;
  }
}

public class HitIsTheSameTargetPrereq extends GenericHitPrereq {

  public let m_isMoving: Bool;

  public let m_object: String;

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }
}
