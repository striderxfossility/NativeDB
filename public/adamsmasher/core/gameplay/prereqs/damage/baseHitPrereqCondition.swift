
public class BaseHitPrereqCondition extends IScriptable {

  public let m_invert: Bool;

  public func SetData(recordID: TweakDBID) -> Void {
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    return false;
  }

  protected final func GetObjectToCheck(obj: CName, hitEvent: ref<gameHitEvent>) -> wref<GameObject> {
    switch obj {
      case n"Instigator":
        return hitEvent.attackData.GetInstigator();
      case n"Source":
        return hitEvent.attackData.GetSource();
      case n"Target":
        return hitEvent.target;
      default:
        return null;
    };
  }
}
