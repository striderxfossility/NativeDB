
public class HitIsMovingPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let prereq: ref<HitIsMovingPrereq> = this.GetPrereq() as HitIsMovingPrereq;
    let objectToCheck: wref<gamePuppet> = this.GetObjectToCheck(prereq.m_object, hitEvent) as gamePuppet;
    if IsDefined(objectToCheck) {
      if prereq.m_isMoving {
        return Vector4.Length2D(objectToCheck.GetVelocity()) > 0.40;
      };
      return Vector4.Length2D(objectToCheck.GetVelocity()) <= 0.10;
    };
    return false;
  }
}

public class HitIsMovingPrereq extends GenericHitPrereq {

  public let m_isMoving: Bool;

  public let m_object: String;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_isMoving = TweakDBInterface.GetBool(recordID + t".isMoving", false);
    this.m_object = TweakDBInterface.GetString(recordID + t".object", "");
  }
}
