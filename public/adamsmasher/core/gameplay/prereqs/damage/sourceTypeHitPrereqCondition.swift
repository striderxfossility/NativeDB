
public class SourceTypeHitPrereqCondition extends BaseHitPrereqCondition {

  public let m_source: CName;

  public func SetData(recordID: TweakDBID) -> Void {
    this.m_source = TweakDBInterface.GetCName(recordID + t".source", n"");
    this.SetData(recordID);
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result: Bool;
    let target: wref<ScriptedPuppet> = hitEvent.target as ScriptedPuppet;
    if !IsDefined(target) {
      return false;
    };
    switch this.m_source {
      case n"Grenade":
        result = IsDefined(hitEvent.attackData.GetSource() as WeaponGrenade);
        break;
      default:
        return false;
    };
    return this.m_invert ? !result : result;
  }
}
