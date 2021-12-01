
public class UseCoverCommandTask extends AIbehaviortaskScript {

  protected inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected let m_currentCommand: wref<AIUseCoverCommand>;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let cm: ref<CoverManager>;
    let coverDemandHolder: ref<CoverDemandHolder>;
    let coverID: Uint64;
    let tmpID: Uint64;
    let rawCommand: ref<IScriptable> = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    let typedCommand: ref<AIUseCoverCommand> = rawCommand as AIUseCoverCommand;
    let aiComponent: ref<AIHumanComponent> = AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent();
    if !IsDefined(typedCommand) {
      if IsDefined(this.m_currentCommand) {
        this.CancelCommand(context, typedCommand, aiComponent);
      };
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    if typedCommand == this.m_currentCommand {
      if typedCommand.oneTimeSelection && AIActionTarget.GetCurrentCoverID(context, coverID) && coverID == ScriptExecutionContext.GetArgumentUint64(context, n"CommandCoverID") {
        this.CancelCommand(context, typedCommand, aiComponent);
        if IsDefined(typedCommand) && Equals(typedCommand.state, AICommandState.Executing) {
          aiComponent.StopExecutingCommand(typedCommand, true);
        };
      };
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    cm = GameInstance.GetCoverManager(AIBehaviorScriptBase.GetGame(context));
    if !IsDefined(cm) {
      LogAIError("CoverManager is NULL in UseCoverCommandTask!");
    } else {
      coverDemandHolder = cm.GetDemandCoverHolder(typedCommand.coverNodeRef);
      if IsDefined(coverDemandHolder) {
        coverID = coverDemandHolder.GetCoverID();
      };
    };
    if coverID == 0u || !cm.IsCoverValid(coverID) {
      ScriptExecutionContext.DebugLog(context, n"AIUseCoverCommand", "Trying to select invalid cover or cover with ID == 0!");
      this.CancelCommand(context, typedCommand, aiComponent);
      if IsDefined(typedCommand) && Equals(typedCommand.state, AICommandState.Executing) {
        aiComponent.StopExecutingCommand(typedCommand, true);
      };
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    tmpID = ScriptExecutionContext.GetArgumentUint64(context, n"CommandCoverID");
    if tmpID != coverID {
      ScriptExecutionContext.SetArgumentUint64(context, n"CommandCoverID", coverID);
      cm.NotifyBehaviourCoverArgumentChanged(ScriptExecutionContext.GetOwner(context), n"CommandCoverID", tmpID, coverID);
    };
    AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().GetCoverBlackboard().SetVariant(GetAllBlackboardDefs().AICover.commandExposureMethods, ToVariant(typedCommand.limitToTheseExposureMethods));
    ScriptExecutionContext.SetArgumentBool(context, n"StopCover", false);
    ScriptExecutionContext.SetArgumentName(context, n"ForcedEntryAnimation", typedCommand.forcedEntryAnimation);
    this.m_currentCommand = typedCommand;
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  private final func Deactivate(context: ScriptExecutionContext) -> Void {
    let aiComponent: ref<AIHumanComponent>;
    let rawCommand: ref<IScriptable>;
    let typedCommand: ref<AIUseCoverCommand>;
    if !IsDefined(this.m_currentCommand) {
      return;
    };
    rawCommand = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    typedCommand = rawCommand as AIUseCoverCommand;
    AIHumanComponent.Get(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, aiComponent);
    if !IsDefined(typedCommand) {
      this.CancelCommand(context, typedCommand, aiComponent);
    } else {
      if ScriptExecutionContext.GetArgumentBool(context, n"StopCover") {
        if IsDefined(typedCommand) && Equals(typedCommand.state, AICommandState.Executing) && IsDefined(aiComponent) {
          aiComponent.StopExecutingCommand(typedCommand, true);
        };
        this.CancelCommand(context, typedCommand, aiComponent);
      };
    };
  }

  protected final func CancelCommand(context: ScriptExecutionContext, typedCommand: ref<AIUseCoverCommand>, aiComponent: ref<AIHumanComponent>) -> Void {
    let tmpID: Uint64 = ScriptExecutionContext.GetArgumentUint64(context, n"CommandCoverID");
    if tmpID != 0u {
      ScriptExecutionContext.SetArgumentUint64(context, n"CommandCoverID", 0u);
      GameInstance.GetCoverManager(ScriptExecutionContext.GetOwner(context).GetGame()).NotifyBehaviourCoverArgumentChanged(ScriptExecutionContext.GetOwner(context), n"CommandCoverID", tmpID, 0u);
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_inCommand, ToVariant(null));
    if IsDefined(this.m_currentCommand) {
      this.m_currentCommand = null;
    };
    if IsDefined(aiComponent) {
      aiComponent.GetCoverBlackboard().SetVariant(GetAllBlackboardDefs().AICover.commandExposureMethods, ToVariant(null));
    };
  }
}

public class UseCoverCommandHandler extends AIbehaviortaskScript {

  protected inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected let m_currentCommand: wref<AIUseCoverCommand>;

  private final func Activate(context: ScriptExecutionContext) -> Void {
    this.m_currentCommand = null;
    let rawCommand: ref<IScriptable> = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    let typedCommand: ref<AIUseCoverCommand> = rawCommand as AIUseCoverCommand;
    if IsDefined(typedCommand) {
      this.m_currentCommand = typedCommand;
    };
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let aiComponent: ref<AIHumanComponent>;
    let waitBeforeExit: Bool;
    let rawCommand: ref<IScriptable> = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    let typedCommand: ref<AIUseCoverCommand> = rawCommand as AIUseCoverCommand;
    if !IsDefined(typedCommand) {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    if IsDefined(this.m_currentCommand) {
      waitBeforeExit = GameInstance.GetCoverManager(AIBehaviorScriptBase.GetGame(context)).IsEnteringOrLeavingCover(ScriptExecutionContext.GetOwner(context));
      if typedCommand == this.m_currentCommand {
        aiComponent = AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent();
        if aiComponent.GetCoverBlackboard().GetBool(GetAllBlackboardDefs().AICover.commandCoverOverride) && !waitBeforeExit {
          aiComponent.GetCoverBlackboard().SetBool(GetAllBlackboardDefs().AICover.commandCoverOverride, false);
          return AIbehaviorUpdateOutcome.SUCCESS;
        };
        return AIbehaviorUpdateOutcome.IN_PROGRESS;
      };
      if !waitBeforeExit {
        return AIbehaviorUpdateOutcome.SUCCESS;
      };
      aiComponent = AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent();
      aiComponent.GetCoverBlackboard().SetBool(GetAllBlackboardDefs().AICover.commandCoverOverride, true);
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    this.m_currentCommand = typedCommand;
    return AIbehaviorUpdateOutcome.SUCCESS;
  }

  private final func WaitBeforeExit(context: ScriptExecutionContext) -> Bool {
    let aiComponent: ref<AIHumanComponent> = AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent();
    if GameInstance.GetCoverManager(AIBehaviorScriptBase.GetGame(context)).IsEnteringOrLeavingCover(ScriptExecutionContext.GetOwner(context)) {
      return true;
    };
    if aiComponent.GetCoverBlackboard().GetBool(GetAllBlackboardDefs().AICover.currentlyExposed) {
      return true;
    };
    return false;
  }
}
