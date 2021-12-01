
public class TargetKilledPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let target: wref<NPCPuppet> = hitEvent.target as NPCPuppet;
    if !IsDefined(target) {
      return false;
    };
    return target.WasJustKilledOrDefeated();
  }
}

public class TargetKilledPrereq extends GenericHitPrereq {

  protected func Initialize(recordID: TweakDBID) -> Void;
}
