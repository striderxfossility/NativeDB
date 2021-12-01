
public class HitIsBodyPartHeadPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let empty: HitShapeData;
    let result: Bool;
    let shape: HitShapeData = hitEvent.hitRepresentationResult.hitShapes[0];
    if NotEquals(shape, empty) {
      result = HitShapeUserDataBase.IsHitReactionZoneHead(shape.userData as HitShapeUserDataBase);
      return result;
    };
    return false;
  }
}