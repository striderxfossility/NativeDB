
public class SlotAnimationInProgress extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    return Cast(AIBehaviorScriptBase.GetPuppet(context).GetPuppetStateBlackboard().GetBool(GetAllBlackboardDefs().PuppetState.SlotAnimationInProgress));
  }
}
