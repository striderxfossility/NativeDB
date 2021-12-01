
public class ShootCommandTask extends AIbehaviortaskScript {

  protected inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected let m_currentCommand: wref<AIShootCommand>;

  protected let m_activationTimeStamp: Float;

  protected let m_commandDuration: Float;

  protected let m_target: wref<GameObject>;

  protected let m_targetID: EntityID;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let globalRef: GlobalNodeRef;
    let target: wref<GameObject>;
    let rawCommand: ref<IScriptable> = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    let typedCommand: ref<AIShootCommand> = rawCommand as AIShootCommand;
    if typedCommand == this.m_currentCommand {
      if IsDefined(this.m_currentCommand) {
        if !AIActionHelper.IsCommandCombatTargetValid(context, n"AIShootCommand") {
          this.CancelCommand(context);
          if IsDefined(typedCommand) && Equals(typedCommand.state, AICommandState.Executing) {
            AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().StopExecutingCommand(typedCommand, true);
          };
        } else {
          if EntityID.IsDefined(this.m_targetID) && !IsDefined(this.m_target) {
            this.CancelCommand(context);
            ScriptExecutionContext.DebugLog(context, n"InjectCombatThreatCommand", "Canceling command, entity streamed out");
            if IsDefined(typedCommand) && Equals(typedCommand.state, AICommandState.Executing) {
              AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().StopExecutingCommand(typedCommand, false);
            };
          } else {
            if this.m_commandDuration >= 0.00 && EngineTime.ToFloat(ScriptExecutionContext.GetAITime(context)) > this.m_activationTimeStamp + this.m_commandDuration {
              this.CancelCommand(context);
              ScriptExecutionContext.DebugLog(context, n"AIShootCommand", "Canceling command, duration expired");
              if IsDefined(typedCommand) && Equals(typedCommand.state, AICommandState.Executing) {
                AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().StopExecutingCommand(typedCommand, true);
              };
            };
          };
        };
      };
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    this.m_currentCommand = typedCommand;
    this.m_commandDuration = typedCommand.duration;
    this.m_activationTimeStamp = EngineTime.ToFloat(ScriptExecutionContext.GetAITime(context));
    if !GetGameObjectFromEntityReference(typedCommand.targetOverridePuppetRef, ScriptExecutionContext.GetOwner(context).GetGame(), target) {
      globalRef = ResolveNodeRef(typedCommand.targetOverrideNodeRef, Cast(GlobalNodeID.GetRoot()));
      target = GameInstance.FindEntityByID(AIBehaviorScriptBase.GetGame(context), Cast(globalRef)) as GameObject;
    };
    this.m_target = target;
    this.m_targetID = Cast(globalRef);
    if EntityID.IsDefined(this.m_targetID) && !IsDefined(this.m_target) {
      this.CancelCommand(context);
      ScriptExecutionContext.DebugLog(context, n"AIShootCommand", "Canceling command, entity streamed out");
      if IsDefined(typedCommand) && Equals(typedCommand.state, AICommandState.Executing) {
        AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().StopExecutingCommand(typedCommand, false);
      };
    } else {
      if !AIActionHelper.SetCommandCombatTarget(context, target, EnumInt(PersistenceSource.CommandShoot)) {
        this.CancelCommand(context);
        ScriptExecutionContext.DebugLog(context, n"AIShootCommand", "Canceling command, unable to set CommandCombatTarget");
        if IsDefined(typedCommand) && Equals(typedCommand.state, AICommandState.Executing) {
          AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().StopExecutingCommand(typedCommand, true);
        };
      };
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  private final func Deactivate(context: ScriptExecutionContext) -> Void {
    let rawCommand: ref<IScriptable>;
    let typedCommand: ref<AIShootCommand>;
    if !IsDefined(this.m_currentCommand) {
      return;
    };
    rawCommand = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    typedCommand = rawCommand as AIShootCommand;
    if !IsDefined(typedCommand) {
      this.CancelCommand(context);
    };
  }

  protected final func CancelCommand(context: ScriptExecutionContext) -> Void {
    AIActionHelper.ClearCommandCombatTarget(context, EnumInt(PersistenceSource.CommandShoot));
    ScriptExecutionContext.SetMappingValue(context, this.m_inCommand, ToVariant(null));
    this.m_activationTimeStamp = 0.00;
    this.m_commandDuration = -1.00;
    this.m_currentCommand = null;
    this.m_target = null;
    this.m_targetID = this.m_target.GetEntityID();
  }
}

public class ShootCommandCleanup extends AIbehaviortaskScript {

  protected inline edit let m_inCommand: ref<AIArgumentMapping>;

  private final func Deactivate(context: ScriptExecutionContext) -> Void {
    AIActionHelper.ClearCommandCombatTarget(context, EnumInt(PersistenceSource.CommandShoot));
    ScriptExecutionContext.SetMappingValue(context, this.m_inCommand, ToVariant(null));
  }
}

public class ShootCommandHandler extends AIbehaviortaskScript {

  protected inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected let m_currentCommand: wref<AIShootCommand>;

  private final func Activate(context: ScriptExecutionContext) -> Void {
    this.m_currentCommand = null;
    let rawCommand: ref<IScriptable> = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    let typedCommand: ref<AIShootCommand> = rawCommand as AIShootCommand;
    if IsDefined(typedCommand) {
      this.m_currentCommand = typedCommand;
    };
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let rawCommand: ref<IScriptable> = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    let typedCommand: wref<AIShootCommand> = rawCommand as AIShootCommand;
    if !IsDefined(typedCommand) {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    if IsDefined(this.m_currentCommand) {
      if typedCommand == this.m_currentCommand {
        return AIbehaviorUpdateOutcome.IN_PROGRESS;
      };
      return AIbehaviorUpdateOutcome.SUCCESS;
    };
    this.m_currentCommand = typedCommand;
    return AIbehaviorUpdateOutcome.SUCCESS;
  }
}
