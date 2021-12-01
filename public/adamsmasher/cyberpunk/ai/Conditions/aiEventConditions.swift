
public abstract class AISignalCondition extends AIbehaviorconditionScript {

  public edit const let m_requiredFlags: array<AISignalFlags>;

  @default(AISignalCondition, true)
  public edit let m_consumesSignal: Bool;

  private let m_activated: Bool;

  protected let m_executingSignal: AIGateSignal;

  protected let m_executingSignalId: Uint32;

  protected func GetSignalName() -> CName {
    return n"";
  }

  protected func GetSignalEvaluationOutcome() -> Bool {
    return false;
  }

  public func GetEditorSubCaption() -> String {
    return "Signal Name:  " + NameToString(this.GetSignalName());
  }

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_activated = false;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    this.m_activated = false;
  }

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    if !this.m_activated {
      if !this.StartExecuting(context) {
        return Cast(false);
      };
      this.m_activated = true;
    } else {
      if !this.KeepExecuting(context) {
        return Cast(false);
      };
    };
    return Cast(true);
  }

  protected final func CheckFlagRequirements(gateSignal: script_ref<AIGateSignal>, checkAgainst: AISignalFlags) -> Bool {
    if ArrayContains(this.m_requiredFlags, checkAgainst) {
      if !AIGateSignal.IsEmpty(Deref(gateSignal)) && AIGateSignal.HasFlag(Deref(gateSignal), checkAgainst) {
        return true;
      };
    };
    return false;
  }

  protected final func IsActivated() -> Bool {
    return this.m_activated;
  }

  protected final func GetSignalHandler(context: ScriptExecutionContext) -> ref<AISignalHandlerComponent> {
    return AIBehaviorScriptBase.GetPuppet(context).GetSignalHandlerComponent();
  }

  protected final func GetSignalTable(context: ScriptExecutionContext) -> ref<gameBoolSignalTable> {
    return AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().GetSignals();
  }

  private final func StartExecuting(context: ScriptExecutionContext) -> Bool {
    let signalHandler: ref<AISignalHandlerComponent>;
    let signalId: Uint32;
    if !this.GetSignalHandler(context).IsHighestPriority(this.GetSignalName(), signalId) {
      return false;
    };
    signalHandler = this.GetSignalHandler(context);
    this.m_executingSignalId = signalId;
    signalHandler.GetSignal(this.m_executingSignalId, this.m_executingSignal);
    if this.m_consumesSignal {
      signalHandler.ConsumeSignal(this.GetSignalName());
    };
    return true;
  }

  private final func KeepExecuting(context: ScriptExecutionContext) -> Bool {
    let signal: AIGateSignal;
    let signalId: Uint32;
    if this.GetSignalHandler(context).GetHighestPrioritySignal(signal, signalId) {
      if signal.priority > this.m_executingSignal.priority {
        return false;
      };
      if (AIGateSignal.HasFlag(signal, AISignalFlags.OverridesSelf) || AIGateSignal.HasFlag(signal, AISignalFlags.InterruptsSamePriorityTask)) && signalId != this.m_executingSignalId && signal.priority >= this.m_executingSignal.priority && AIGateSignal.HasTag(signal, this.GetSignalName()) {
        return false;
      };
    };
    return true;
  }
}

public class CustomEventCondition extends AISignalCondition {

  public edit let m_eventName: CName;

  protected func GetSignalName() -> CName {
    return this.m_eventName;
  }

  public func GetDescription(context: ScriptExecutionContext) -> String {
    if !this.IsActivated() {
      return "GateSignal(" + ToString(this.GetSignalName()) + ")";
    };
    return "GateSignal(" + ToString(this.GetSignalName()) + ", activated=" + this.IsActivated() ? "true" : "false" + ", prio=" + ToString(this.m_executingSignal.priority) + ")";
  }
}

public class PriorityCheckEventCondition extends AISignalCondition {

  protected func GetSignalEvaluationOutcome() -> Bool {
    return true;
  }
}

public class HighestPrioritySignalCondition extends AIbehaviorexpressionScript {

  public edit let m_signalName: CName;

  protected let m_cbId: Uint32;

  protected let m_lastValue: Bool;

  public final func Activate(context: ScriptExecutionContext) -> Void {
    this.m_cbId = ScriptExecutionContext.AddBehaviorCallback(context, n"OnHighestPrioritySignalBecameDirty", this);
    this.m_lastValue = false;
  }

  public final func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_cbId);
  }

  public final func CalculateValue(context: ScriptExecutionContext) -> Variant {
    let signal: AIGateSignal;
    let signalId: Uint32;
    if this.GetSignalHandler(context).GetHighestPrioritySignal(signal, signalId) {
      if AIGateSignal.HasTag(signal, this.m_signalName) {
        this.m_lastValue = true;
        return ToVariant(true);
      };
      this.m_lastValue = false;
      return ToVariant(false);
    };
    return ToVariant(this.m_lastValue);
  }

  protected final func GetSignalHandler(context: ScriptExecutionContext) -> ref<AISignalHandlerComponent> {
    return AIBehaviorScriptBase.GetPuppet(context).GetSignalHandlerComponent();
  }

  public final func GetEditorSubCaption() -> String {
    return "GateSignal(" + ToString(this.m_signalName) + ")";
  }
}
