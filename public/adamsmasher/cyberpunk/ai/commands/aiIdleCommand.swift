
public class HoldPositionCommandTask extends AIbehaviortaskScript {

  protected inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected let m_currentCommand: wref<AIHoldPositionCommand>;

  protected let m_activationTimeStamp: Float;

  protected let m_commandDuration: Float;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let rawCommand: ref<IScriptable> = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    let typedCommand: ref<AIHoldPositionCommand> = rawCommand as AIHoldPositionCommand;
    if IsDefined(this.m_currentCommand) && !IsDefined(typedCommand) {
      this.CancelCommand(context, typedCommand);
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    if typedCommand == this.m_currentCommand {
      if this.m_commandDuration >= 0.00 && EngineTime.ToFloat(ScriptExecutionContext.GetAITime(context)) > this.m_activationTimeStamp + this.m_commandDuration {
        this.CancelCommand(context, typedCommand);
        if IsDefined(typedCommand) && Equals(typedCommand.state, AICommandState.Executing) {
          AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().StopExecutingCommand(typedCommand, true);
        };
      };
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    this.m_currentCommand = typedCommand;
    this.m_commandDuration = typedCommand.duration;
    this.m_activationTimeStamp = EngineTime.ToFloat(ScriptExecutionContext.GetAITime(context));
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  protected final func CancelCommand(context: ScriptExecutionContext, typedCommand: ref<AIHoldPositionCommand>) -> Void {
    ScriptExecutionContext.SetMappingValue(context, this.m_inCommand, ToVariant(null));
    this.m_activationTimeStamp = 0.00;
    this.m_commandDuration = -1.00;
    this.m_currentCommand = null;
  }
}
