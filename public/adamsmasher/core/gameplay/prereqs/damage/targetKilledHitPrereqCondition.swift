
public class TargetKilledHitPrereqCondition extends BaseHitPrereqCondition {

  private let m_lastTarget: wref<GameObject>;

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result: Bool;
    let target: wref<NPCPuppet> = hitEvent.target as NPCPuppet;
    if !IsDefined(target) || this.m_lastTarget == target {
      return false;
    };
    result = target.WasJustKilledOrDefeated();
    if result {
      this.m_lastTarget = target;
    };
    return this.m_invert ? !result : result;
  }
}
