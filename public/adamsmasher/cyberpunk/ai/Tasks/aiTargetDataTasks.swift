
public class GetTargetLastKnownPosition extends AIbehaviortaskScript {

  protected inline edit let m_inTargetObject: ref<AIArgumentMapping>;

  protected inline edit let m_outPosition: ref<AIArgumentMapping>;

  protected inline edit let predictionTime: Float;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let i: Int32;
    let targetLastKnownPosition: Vector4;
    let targetVelocity: Vector4;
    let threats: array<TrackedLocation>;
    let targetObject: wref<GameObject> = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_inTargetObject));
    if !IsDefined(targetObject) {
      LogAIError("[GetTargetLastKnownPosition] Argument \'inTargetObject\' has invalid type. Expected Object, got " + ToString(this.m_inTargetObject.GetClassName()) + ".");
      return;
    };
    targetLastKnownPosition = targetObject.GetWorldPosition();
    threats = AIBehaviorScriptBase.GetPuppet(context).GetTargetTrackerComponent().GetThreats(false);
    i = 0;
    while i < ArraySize(threats) {
      if threats[i].entity.GetEntityID() == targetObject.GetEntityID() {
        targetLastKnownPosition = threats[i].lastKnown.position;
      };
      i += 1;
    };
    if this.predictionTime > 0.00 {
      targetVelocity = (targetObject as gamePuppet).GetVelocity();
      targetVelocity.Z = 0.00;
      targetLastKnownPosition += targetVelocity * this.predictionTime;
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_outPosition, ToVariant(targetLastKnownPosition));
  }
}

public class GetOwnPosition extends AIbehaviortaskScript {

  protected inline edit let m_outPosition: ref<AIArgumentMapping>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetMappingValue(context, this.m_outPosition, ToVariant(ScriptExecutionContext.GetOwner(context).GetWorldPosition()));
  }
}
