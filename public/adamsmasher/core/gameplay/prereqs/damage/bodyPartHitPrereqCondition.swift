
public class BodyPartHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_bodyPart: CName;

  public let m_attackSubtype: gamedataAttackSubtype;

  public func SetData(recordID: TweakDBID) -> Void {
    this.m_bodyPart = TweakDBInterface.GetCName(recordID + t".bodyPart", n"");
    this.SetData(recordID);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let empty: HitShapeData;
    let result: Bool;
    let shape: HitShapeData = hitEvent.hitRepresentationResult.hitShapes[0];
    if NotEquals(shape, empty) {
      switch this.m_bodyPart {
        case n"Head":
          result = HitShapeUserDataBase.IsHitReactionZoneHead(shape.userData as HitShapeUserDataBase);
          break;
        case n"Torso":
          result = HitShapeUserDataBase.IsHitReactionZoneTorso(shape.userData as HitShapeUserDataBase);
          break;
        case n"Limb":
          result = HitShapeUserDataBase.IsHitReactionZoneLimb(shape.userData as HitShapeUserDataBase);
          break;
        default:
          return false;
      };
      return this.m_invert ? !result : result;
    };
    return false;
  }
}
