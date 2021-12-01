
public class CheckThreat extends AIbehaviorconditionScript {

  public inline edit let m_targetObjectMapping: ref<AIArgumentMapping>;

  protected let m_targetThreat: wref<GameObject>;

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let i: Int32;
    let threats: array<TrackedLocation>;
    this.m_targetThreat = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_targetObjectMapping));
    let trackerComponent: ref<TargetTrackerComponent> = AIBehaviorScriptBase.GetPuppet(context).GetTargetTrackerComponent();
    if !IsDefined(trackerComponent) {
      return Cast(false);
    };
    if !IsDefined(this.m_targetThreat) {
      return Cast(false);
    };
    threats = trackerComponent.GetThreats(true);
    if ArraySize(threats) == 0 {
      return Cast(false);
    };
    i = 0;
    while i < ArraySize(threats) {
      if threats[i].entity == this.m_targetThreat {
        return Cast(AIActionHelper.TryChangingAttitudeToHostile(AIBehaviorScriptBase.GetPuppet(context), this.m_targetThreat));
      };
      i += 1;
    };
    return Cast(false);
  }
}

public class CheckDroppedThreat extends CheckThreat {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let threatData: DroppedThreatData;
    let tte: ref<TargetTrackingExtension> = AIBehaviorScriptBase.GetPuppet(context).GetTargetTrackerComponent() as TargetTrackingExtension;
    if IsDefined(tte) && tte.GetDroppedThreat(ScriptExecutionContext.GetOwner(context).GetGame(), threatData) {
      return Cast(true);
    };
    return Cast(false);
  }
}
