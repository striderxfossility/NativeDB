
public class AIPatrolCommandPrologue extends AICommandHandlerBase {

  public inline edit let outPatrolPath: ref<AIArgumentMapping>;

  protected func UpdateCommand(context: ScriptExecutionContext, command: ref<AICommand>) -> AIbehaviorUpdateOutcome {
    let typedCommand: ref<AIPatrolCommand> = command as AIPatrolCommand;
    if !IsDefined(typedCommand) {
      LogAIError("\'inCommand\' doesn\'t have type \'AIPatrolCommand\'.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !IsDefined(typedCommand.pathParams) {
      LogAIError("Patrol command has null \'pathParams\'.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !ScriptExecutionContext.SetMappingValue(context, this.outPatrolPath, ToVariant(typedCommand.pathParams)) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}
