
public abstract class AISignalSenderTask extends AIbehaviortaskScript {

  public edit let tags: array<CName>;

  public edit let flags: array<EAIGateSignalFlags>;

  public edit let priority: Float;

  private let m_signalId: Uint32;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.QueueGateSignal(context);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    AIBehaviorScriptBase.GetPuppet(context).GetSignalHandlerComponent().RemoveSignal(this.m_signalId);
  }

  protected final func QueueGateSignal(context: ScriptExecutionContext) -> Void {
    let signal: AIGateSignal;
    signal.priority = this.priority;
    signal.lifeTime = this.GetSignalLifeTime();
    let i: Int32 = 0;
    while i < ArraySize(this.tags) {
      AIGateSignal.AddTag(signal, this.tags[i]);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.flags) {
      AIGateSignal.AddFlag(signal, Cast(this.flags[i]));
      i += 1;
    };
    this.m_signalId = AIBehaviorScriptBase.GetPuppet(context).GetSignalHandlerComponent().AddSignal(signal);
  }

  public func GetSignalLifeTime() -> Float {
    return 0.00;
  }

  protected final func GetSignalTable(context: ScriptExecutionContext) -> ref<gameBoolSignalTable> {
    return AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().GetSignals();
  }
}

public class CustomEventSender extends AISignalSenderTask {

  public final func GetEditorSubCaption() -> String {
    let result: String;
    let i: Int32 = 0;
    while i < ArraySize(this.tags) {
      if i > 0 {
        result += ".";
      };
      result += NameToString(this.tags[i]);
      i += 1;
    };
    result += " (" + this.priority + ")";
    return result;
  }

  public func GetSignalLifeTime() -> Float {
    return 0.50;
  }
}

public class ReactiveEventSender extends AISignalSenderTask {

  public edit let m_behaviorArgumentNameTag: CName;

  public edit let m_behaviorArgumentFloatPriority: CName;

  public edit let m_behaviorArgumentNameFlag: CName;

  public edit let m_reactiveType: CName;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    ArrayResize(this.tags, 3);
    this.tags[0] = n"reactive";
    this.tags[1] = this.m_reactiveType;
    this.tags[2] = ScriptExecutionContext.GetArgumentName(context, this.m_behaviorArgumentNameTag);
    this.priority = ScriptExecutionContext.GetArgumentFloat(context, this.m_behaviorArgumentFloatPriority);
    ArrayResize(this.flags, 1);
    this.flags[0] = this.GateSignalFlagsNameToEnum(ScriptExecutionContext.GetArgumentName(context, this.m_behaviorArgumentNameFlag));
    this.Activate(context);
  }

  public func GetSignalLifeTime() -> Float {
    return 1.00;
  }

  private final func GateSignalFlagsNameToEnum(FlagName: CName) -> EAIGateSignalFlags {
    switch FlagName {
      case n"AIGSF_Undefined":
        return EAIGateSignalFlags.AIGSF_Undefined;
      case n"AIGSF_OverridesSelf":
        return EAIGateSignalFlags.AIGSF_OverridesSelf;
      case n"AIGSF_InterruptsSamePriorityTask":
        return EAIGateSignalFlags.AIGSF_InterruptsSamePriorityTask;
      case n"AIGSF_InterruptsForcedBehavior":
        return EAIGateSignalFlags.AIGSF_InterruptsForcedBehavior;
      case n"AIGSF_AcceptsAdditives":
        return EAIGateSignalFlags.AIGSF_AcceptsAdditives;
      default:
        return EAIGateSignalFlags.AIGSF_Undefined;
    };
  }
}
