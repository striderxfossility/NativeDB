
public class TeleportCommandHandler extends AICommandHandlerBase {

  protected inline edit let m_position: ref<AIArgumentMapping>;

  protected inline edit let m_rotation: ref<AIArgumentMapping>;

  protected inline edit let m_doNavTest: ref<AIArgumentMapping>;

  protected func UpdateCommand(context: ScriptExecutionContext, command: ref<AICommand>) -> AIbehaviorUpdateOutcome {
    let typedCommand: ref<AITeleportCommand> = command as AITeleportCommand;
    if !IsDefined(typedCommand) {
      LogAIError("Argument \'inCommand\' has invalid type. Expected AITeleportCommand, got " + ToString(command.GetClassName()) + ".");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !this.CheckArgument(this.m_position, n"position") || !this.CheckArgument(this.m_rotation, n"rotation") || !this.CheckArgument(this.m_doNavTest, n"doNavTest") {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_position, ToVariant(typedCommand.position));
    ScriptExecutionContext.SetMappingValue(context, this.m_rotation, ToVariant(typedCommand.rotation));
    ScriptExecutionContext.SetMappingValue(context, this.m_doNavTest, ToVariant(typedCommand.doNavTest));
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }
}
