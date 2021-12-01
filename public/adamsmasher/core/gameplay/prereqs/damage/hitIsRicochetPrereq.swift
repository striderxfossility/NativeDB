
public class HitIsRicochetPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result: Bool = hitEvent.attackData.GetNumRicochetBounces() > 0;
    return result;
  }
}
