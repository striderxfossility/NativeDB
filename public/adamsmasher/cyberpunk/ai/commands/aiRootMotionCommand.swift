
public class RootMotionCommandHandler extends AICommandHandlerBase {

  protected inline edit let m_params: ref<AIArgumentMapping>;

  protected func UpdateCommand(context: ScriptExecutionContext, command: ref<AICommand>) -> AIbehaviorUpdateOutcome {
    let typedCommand: ref<AIRootMotionCommand> = command as AIRootMotionCommand;
    if !IsDefined(typedCommand) {
      LogAIError("Argument \'inCommand\' has invalid type. Expected AIRootMotionCommand, got " + ToString(command.GetClassName()) + ".");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !IsDefined(this.m_params) {
      LogAIError("Argument \'params\' is null. Cannot set motion params.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_params, ToVariant(typedCommand.params));
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}
