
public class InstigatorTypeHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_instigatorType: CName;

  public func SetData(recordID: TweakDBID) -> Void {
    this.m_instigatorType = TweakDBInterface.GetCName(recordID + t".instigatorType", n"");
    this.SetData(recordID);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result: Bool;
    switch this.m_instigatorType {
      case n"Player":
        result = IsDefined(hitEvent.attackData.GetInstigator() as PlayerPuppet);
        break;
      case n"Puppet":
        result = IsDefined(hitEvent.attackData.GetInstigator() as ScriptedPuppet);
        break;
      default:
        return false;
    };
    return this.m_invert ? !result : result;
  }
}
