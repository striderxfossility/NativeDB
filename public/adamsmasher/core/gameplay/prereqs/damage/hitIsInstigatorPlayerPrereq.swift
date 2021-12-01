
public class HitIsInstigatorPlayerPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    if IsDefined(hitEvent.attackData.GetInstigator() as PlayerPuppet) {
      return true;
    };
    return false;
  }
}
