
public class HitIsHumanPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let prereq: ref<HitIsHumanPrereq> = this.GetPrereq() as HitIsHumanPrereq;
    let objectToCheck: wref<ScriptedPuppet> = hitEvent.target as ScriptedPuppet;
    let result: Bool = Equals(objectToCheck.GetNPCType(), gamedataNPCType.Human);
    if prereq.m_invert {
      return !result;
    };
    return result;
  }
}

public class HitIsHumanPrereq extends GenericHitPrereq {

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }
}
