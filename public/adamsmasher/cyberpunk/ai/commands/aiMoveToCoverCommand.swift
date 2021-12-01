
public class MoveToCoverCommandTask extends AIbehaviortaskScript {

  protected inline edit let m_inCommand: ref<AIArgumentMapping>;

  protected let m_currentCommand: wref<AIMoveToCoverCommand>;

  private let m_coverID: Uint64;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let cm: ref<CoverManager>;
    let coverDemandHolder: ref<CoverDemandHolder>;
    let coverID: Uint64;
    let tmpID: Uint64;
    let rawCommand: ref<IScriptable> = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    let typedCommand: ref<AIMoveToCoverCommand> = rawCommand as AIMoveToCoverCommand;
    if !IsDefined(typedCommand) {
      this.m_currentCommand = null;
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if typedCommand == this.m_currentCommand {
      if ScriptExecutionContext.GetArgumentUint64(context, n"CoverID") != this.m_coverID {
        ScriptExecutionContext.DebugLog(context, n"AIMoveToCoverCommand", "Something changed current coverID, repeting command");
        return AIbehaviorUpdateOutcome.FAILURE;
      };
      if this.ShouldInterrupt(context) {
        return AIbehaviorUpdateOutcome.SUCCESS;
      };
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    if IsDefined(this.m_currentCommand) {
      MoveToCoverCommandDelegate.SendGracefulInterruptionSignal(context);
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    cm = GameInstance.GetCoverManager(AIBehaviorScriptBase.GetGame(context));
    if !IsDefined(cm) {
      LogAIError("AIMoveToCoverCommand: CoverManager is NULL!");
    } else {
      coverDemandHolder = cm.GetDemandCoverHolder(typedCommand.coverNodeRef);
      coverID = coverDemandHolder.GetCoverID();
    };
    if coverID == 0u || !cm.IsCoverValid(coverID) {
      ScriptExecutionContext.DebugLog(context, n"AIMoveToCoverCommand", "Trying to select invalid cover or cover with ID == 0!");
      this.m_currentCommand = null;
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    if typedCommand.alwaysUseStealth {
      NPCPuppet.ChangeHighLevelState(ScriptExecutionContext.GetOwner(context), gamedataNPCHighLevelState.Stealth);
    };
    this.m_coverID = coverID;
    tmpID = ScriptExecutionContext.GetArgumentUint64(context, n"CoverID");
    if tmpID != this.m_coverID {
      ScriptExecutionContext.SetArgumentUint64(context, n"CoverID", this.m_coverID);
      GameInstance.GetCoverManager(ScriptExecutionContext.GetOwner(context).GetGame()).NotifyBehaviourCoverArgumentChanged(ScriptExecutionContext.GetOwner(context), n"CoverID", tmpID, this.m_coverID);
    };
    tmpID = ScriptExecutionContext.GetArgumentUint64(context, n"DesiredCoverID");
    if tmpID != this.m_coverID {
      ScriptExecutionContext.SetArgumentUint64(context, n"DesiredCoverID", this.m_coverID);
      GameInstance.GetCoverManager(ScriptExecutionContext.GetOwner(context).GetGame()).NotifyBehaviourCoverArgumentChanged(ScriptExecutionContext.GetOwner(context), n"DesiredCoverID", tmpID, this.m_coverID);
    };
    this.m_currentCommand = typedCommand;
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  private final func Deactivate(context: ScriptExecutionContext) -> Void {
    let aiComponent: ref<AIHumanComponent> = AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent();
    if IsDefined(this.m_currentCommand) && IsDefined(aiComponent) && this.ShouldInterrupt(context) {
      if Equals(this.m_currentCommand.state, AICommandState.Executing) {
        aiComponent.StopExecutingCommand(this.m_currentCommand, true);
      };
    };
    this.m_currentCommand = null;
  }

  public final func ShouldInterrupt(context: ScriptExecutionContext) -> Bool {
    let stopCover: Bool;
    let rawCommand: ref<IScriptable> = ScriptExecutionContext.GetArgumentScriptable(context, n"FollowerTakedownCommand");
    let takedownCommand: ref<AIFollowerTakedownCommand> = rawCommand as AIFollowerTakedownCommand;
    if IsDefined(takedownCommand) && !takedownCommand.approachBeforeTakedown {
      return true;
    };
    stopCover = ScriptExecutionContext.GetArgumentBool(context, n"StopCover");
    if stopCover {
      return true;
    };
    return false;
  }
}

public class MoveToCoverCommandDelegate extends ScriptBehaviorDelegate {

  public inline edit let m_inCommand: ref<AIArgumentMapping>;

  public let releaseSignalOnCoverEnter: Bool;

  public let useSpecialAction: Bool;

  public let useHigh: Bool;

  public let useLeft: Bool;

  public let useRight: Bool;

  public final func ResetVariables(context: ScriptExecutionContext) -> Bool {
    this.releaseSignalOnCoverEnter = false;
    this.useSpecialAction = false;
    this.useLeft = false;
    this.useRight = false;
    this.useHigh = false;
    return true;
  }

  public final func OnActivate(context: ScriptExecutionContext) -> Bool {
    let rawCommand: ref<IScriptable>;
    let typedCommand: ref<AIMoveToCoverCommand>;
    this.ResetVariables(context);
    if IsDefined(this.m_inCommand) {
      rawCommand = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
      typedCommand = rawCommand as AIMoveToCoverCommand;
    };
    if !IsDefined(typedCommand) {
      return false;
    };
    this.releaseSignalOnCoverEnter = false;
    if NotEquals(typedCommand.specialAction, IntEnum(0l)) && ScriptedPuppet.IsPlayerCompanion(ScriptExecutionContext.GetOwner(context)) {
      this.useSpecialAction = true;
      if Equals(this.GetCoverHeight(context), gameCoverHeight.High) {
        this.useHigh = true;
      };
      switch typedCommand.specialAction {
        case ECoverSpecialAction.Left:
          this.useLeft = true;
          break;
        case ECoverSpecialAction.Right:
          this.useRight = true;
          break;
        default:
          this.useSpecialAction = false;
      };
    };
    return true;
  }

  private final func GetCoverHeight(context: ScriptExecutionContext) -> gameCoverHeight {
    let coverID: Uint64 = ScriptExecutionContext.GetArgumentUint64(context, n"CoverID");
    return GameInstance.GetCoverManager(ScriptExecutionContext.GetOwner(context).GetGame()).GetCoverHeight(coverID);
  }

  public final func GracefulInterruption(context: ScriptExecutionContext) -> Bool {
    MoveToCoverCommandDelegate.SendGracefulInterruptionSignal(context);
    return true;
  }

  public final func ResetGracefulInterruption(context: ScriptExecutionContext) -> Bool {
    MoveToCoverCommandDelegate.ResetGracefulInterruptionSignal(context);
    return true;
  }

  public final func StopExecutingCommand(context: ScriptExecutionContext) -> Bool {
    let aiComponent: ref<AIHumanComponent>;
    let commandState: AICommandState;
    let rawCommand: ref<IScriptable>;
    let typedCommand: ref<AIMoveToCoverCommand>;
    if !AIHumanComponent.Get(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, aiComponent) {
      return false;
    };
    rawCommand = ScriptExecutionContext.GetScriptableMappingValue(context, this.m_inCommand);
    typedCommand = rawCommand as AIMoveToCoverCommand;
    if !IsDefined(typedCommand) || this.releaseSignalOnCoverEnter {
      return false;
    };
    commandState = typedCommand.state;
    if Equals(commandState, AICommandState.Executing) {
      aiComponent.StopExecutingCommand(typedCommand, true);
    };
    return true;
  }

  public final static func SendGracefulInterruptionSignal(context: ScriptExecutionContext) -> Void {
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    ScriptedPuppet.SendActionSignal(puppet, n"GracefullyInterruptMoveToCover", 1.00);
  }

  public final static func ResetGracefulInterruptionSignal(context: ScriptExecutionContext) -> Void {
    let puppet: wref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if !IsDefined(puppet) {
      return;
    };
    ScriptedPuppet.ResetActionSignal(puppet, n"GracefullyInterruptMoveToCover");
  }
}
