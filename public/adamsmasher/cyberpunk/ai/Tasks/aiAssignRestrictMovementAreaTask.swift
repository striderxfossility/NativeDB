
public class AssignRestrictMovementAreaTask extends AIbehaviortaskScript {

  public inline edit let m_restrictMovementAreaRef: ref<AIArgumentMapping>;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let restrictMovementArea: NodeRef;
    let gam: ref<RestrictMovementAreaManager> = GameInstance.GetRestrictMovementAreaManager(AIBehaviorScriptBase.GetGame(context));
    if !IsDefined(gam) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !IsDefined(this.m_restrictMovementAreaRef) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    restrictMovementArea = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_restrictMovementAreaRef));
    if gam.AssignRestrictMovementArea(AIBehaviorScriptBase.GetPuppet(context).GetEntityID(), restrictMovementArea) {
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    return AIbehaviorUpdateOutcome.FAILURE;
  }
}

public class AssignRestrictMovementAreaHandler extends AIbehaviortaskScript {

  public inline edit let m_inCommand: ref<AIArgumentMapping>;

  @default(AssignRestrictMovementAreaHandler, AIbehaviorCompletionStatus.FAILURE)
  public inline edit let m_resultOnNoChange: AIbehaviorCompletionStatus;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let gam: ref<RestrictMovementAreaManager>;
    let rawCommand: ref<IScriptable>;
    let restrictMovementArea: NodeRef;
    let typedCommand: ref<AIAssignRestrictMovementAreaCommand>;
    if !IsDefined(this.m_inCommand) {
      LogAIError("Assign Restrict Movement Area command argument mapping is null.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    rawCommand = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    typedCommand = rawCommand as AIAssignRestrictMovementAreaCommand;
    if !IsDefined(typedCommand) {
      LogAIError("\'inCommand\' doesn\'t have type \'AIAssignRestrictMovementAreaCommand\'.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    restrictMovementArea = typedCommand.restrictMovementAreaRef;
    gam = GameInstance.GetRestrictMovementAreaManager(AIBehaviorScriptBase.GetGame(context));
    if !IsDefined(gam) {
      LogAIError("Could not get Restrict Movement Area manager.");
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if !gam.AssignRestrictMovementArea(AIBehaviorScriptBase.GetPuppet(context).GetEntityID(), restrictMovementArea) {
      LogAIError("Assigned Restrict Movement Area did not change.");
      if Equals(this.m_resultOnNoChange, AIbehaviorCompletionStatus.SUCCESS) {
        return AIbehaviorUpdateOutcome.SUCCESS;
      };
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}
