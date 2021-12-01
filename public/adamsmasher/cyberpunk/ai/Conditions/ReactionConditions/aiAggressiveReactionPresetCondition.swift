
public class AIAggressiveReactionPresetCondition extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if IsDefined(AIBehaviorScriptBase.GetPuppet(context)) {
      return Cast(AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetReactionPreset().IsAggressive());
    };
    return Cast(false);
  }
}
