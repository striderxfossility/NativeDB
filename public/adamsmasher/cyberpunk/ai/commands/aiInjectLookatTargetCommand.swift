
public class InjectLookatTargetCommandTask extends AIbehaviortaskScript {

  protected inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected let m_currentCommand: wref<AIInjectLookatTargetCommand>;

  protected let m_activationTimeStamp: Float;

  protected let m_commandDuration: Float;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let globalRef: GlobalNodeRef;
    let target: wref<GameObject>;
    let rawCommand: ref<IScriptable> = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    let typedCommand: ref<AIInjectLookatTargetCommand> = rawCommand as AIInjectLookatTargetCommand;
    if IsDefined(this.m_currentCommand) && !IsDefined(typedCommand) {
      this.CancelCommand(context);
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    if typedCommand == this.m_currentCommand {
      if this.m_commandDuration > 0.00 && EngineTime.ToFloat(ScriptExecutionContext.GetAITime(context)) > this.m_activationTimeStamp + this.m_commandDuration {
        this.CancelCommand(context);
        if IsDefined(typedCommand) && Equals(typedCommand.state, AICommandState.Executing) {
          AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().StopExecutingCommand(typedCommand, true);
        };
      };
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    this.m_currentCommand = typedCommand;
    this.m_commandDuration = typedCommand.duration;
    this.m_activationTimeStamp = EngineTime.ToFloat(ScriptExecutionContext.GetAITime(context));
    if !GetGameObjectFromEntityReference(typedCommand.targetPuppetRef, ScriptExecutionContext.GetOwner(context).GetGame(), target) {
      globalRef = ResolveNodeRef(typedCommand.targetNodeRef, Cast(GlobalNodeID.GetRoot()));
      target = GameInstance.FindEntityByID(AIBehaviorScriptBase.GetGame(context), Cast(globalRef)) as GameObject;
    };
    if !IsDefined(target) {
      this.CancelCommand(context);
      if IsDefined(typedCommand) && Equals(typedCommand.state, AICommandState.Executing) {
        AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().StopExecutingCommand(typedCommand, true);
      };
    } else {
      ScriptExecutionContext.SetArgumentObject(context, n"CommandAimTarget", target);
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  private final func Deactivate(context: ScriptExecutionContext) -> Void {
    this.CancelCommand(context);
  }

  protected final func CancelCommand(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetArgumentObject(context, n"CommandAimTarget", null);
    ScriptExecutionContext.SetMappingValue(context, this.m_inCommand, ToVariant(null));
    this.m_activationTimeStamp = 0.00;
    this.m_commandDuration = 0.00;
    this.m_currentCommand = null;
  }
}
