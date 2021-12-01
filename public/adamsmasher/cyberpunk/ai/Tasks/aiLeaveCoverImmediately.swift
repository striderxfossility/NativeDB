
public class LeaveCoverImmediately extends AIbehaviortaskScript {

  public edit let m_delay: Float;

  public edit let m_completeOnLeave: Bool;

  public let m_timeStamp: Float;

  public let m_triggered: Bool;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_triggered = false;
    this.m_timeStamp = AIBehaviorScriptBase.GetAITime(context);
    if this.m_delay == 0.00 {
      AICoverHelper.LeaveCoverImmediately(AIBehaviorScriptBase.GetPuppet(context));
    };
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    if !this.m_triggered && this.m_delay > 0.00 && this.m_delay + this.m_timeStamp >= AIBehaviorScriptBase.GetAITime(context) {
      this.m_triggered = true;
      AICoverHelper.LeaveCoverImmediately(AIBehaviorScriptBase.GetPuppet(context));
      if this.m_completeOnLeave {
        return AIbehaviorUpdateOutcome.SUCCESS;
      };
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    if this.m_delay < 0.00 {
      AICoverHelper.LeaveCoverImmediately(AIBehaviorScriptBase.GetPuppet(context));
    };
  }
}
