
public class UseWorkspotCommandHandler extends AICommandHandlerBase {

  protected inline edit let m_outMoveToWorkspot: ref<AIArgumentMapping>;

  protected inline edit let m_outForceEntryAnimName: ref<AIArgumentMapping>;

  protected inline edit let m_outContinueInCombat: ref<AIArgumentMapping>;

  protected func UpdateCommand(context: ScriptExecutionContext, command: ref<AICommand>) -> AIbehaviorUpdateOutcome {
    let typedCommand: ref<AIBaseUseWorkspotCommand> = command as AIBaseUseWorkspotCommand;
    if !IsDefined(typedCommand) {
      LogAIError("Argument \'inCommand\' has invalid type. Expected AIBaseUseWorkspotCommand, got " + ToString(command.GetClassName()) + ".");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_outMoveToWorkspot, ToVariant(typedCommand.moveToWorkspot));
    ScriptExecutionContext.SetMappingValue(context, this.m_outForceEntryAnimName, ToVariant(typedCommand.forceEntryAnimName));
    ScriptExecutionContext.SetMappingValue(context, this.m_outContinueInCombat, ToVariant(typedCommand.continueInCombat));
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }
}
