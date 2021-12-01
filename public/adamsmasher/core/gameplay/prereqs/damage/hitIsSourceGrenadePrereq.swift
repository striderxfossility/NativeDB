
public class HitIsSourceGrenadePrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    if IsDefined(hitEvent.attackData.GetSource() as WeaponGrenade) {
      return true;
    };
    return false;
  }
}
