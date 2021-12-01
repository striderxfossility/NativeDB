
public class AgentMovingHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_isMoving: Bool;

  public let m_object: CName;

  public func SetData(recordID: TweakDBID) -> Void {
    this.SetData(recordID);
    this.m_isMoving = TweakDBInterface.GetBool(recordID + t".isMoving", false);
    this.m_object = TweakDBInterface.GetCName(recordID + t".object", n"");
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result: Bool;
    let objectToCheck: wref<gamePuppet> = this.GetObjectToCheck(this.m_object, hitEvent) as gamePuppet;
    if IsDefined(objectToCheck) {
      if this.m_isMoving {
        result = Vector4.Length2D(objectToCheck.GetVelocity()) > 0.40;
      } else {
        result = Vector4.Length2D(objectToCheck.GetVelocity()) <= 0.10;
      };
    };
    return this.m_invert ? !result : result;
  }
}
