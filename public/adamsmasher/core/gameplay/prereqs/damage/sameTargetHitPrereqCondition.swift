
public class SameTargetHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_previousTarget: wref<GameObject>;

  public let m_previousSource: wref<GameObject>;

  public let m_previousWeapon: wref<WeaponObject>;

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let checkPassed: Bool;
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
    return this.m_invert ? !checkPassed : checkPassed;
  }
}
