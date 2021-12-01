
public class AIStackSignalCondition extends AIbehaviorStackScriptPassiveExpressionDefinition {

  public edit let m_signalName: CName;

  public final func OnActivate(context: ScriptExecutionContext, data: script_ref<AIStackSignalConditionData>) -> Void {
    Deref(data).m_callbackId = this.AddBehaviorCallback(context, n"OnHighestPrioritySignalBecameDirty");
    Deref(data).m_lastValue = false;
  }

  public final func OnDeactivate(context: ScriptExecutionContext, data: script_ref<AIStackSignalConditionData>) -> Void {
    this.RemoveBehaviorCallback(context, Deref(data).m_callbackId);
  }

  public final func CalculateValue(context: ScriptExecutionContext, data: script_ref<AIStackSignalConditionData>) -> Variant {
    let signal: AIGateSignal;
    let signalId: Uint32;
    if this.GetSignalHandler(context).GetHighestPrioritySignal(signal, signalId) {
      if AIGateSignal.HasTag(signal, this.m_signalName) {
        Deref(data).m_lastValue = true;
        return ToVariant(true);
      };
      Deref(data).m_lastValue = false;
      return ToVariant(false);
    };
    return ToVariant(Deref(data).m_lastValue);
  }

  protected final func GetSignalHandler(context: ScriptExecutionContext) -> ref<AISignalHandlerComponent> {
    return AIStackSignalCondition.GetPuppet(context).GetSignalHandlerComponent();
  }

  public final static func GetPuppet(context: ScriptExecutionContext) -> ref<ScriptedPuppet> {
    return ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
  }

  public final func GetEditorSubCaption() -> String {
    return "GateSignal(" + ToString(this.m_signalName) + ")";
  }
}

public class AIGateSignalSender extends AIbehaviortaskStackScript {

  public edit let tags: array<CName>;

  public edit let flags: array<EAIGateSignalFlags>;

  public edit let priority: Float;

  public func GetInstanceTypeName() -> CName {
    return n"script_ref:Uint32";
  }

  public final func OnActivate(context: ScriptExecutionContext, signalId: script_ref<Uint32>) -> Void {
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
    signalId = AIBehaviorScriptBase.GetPuppet(context).GetSignalHandlerComponent().AddSignal(signal);
  }

  public final func OnDeactivate(context: ScriptExecutionContext, signalId: script_ref<Uint32>) -> Void {
    AIBehaviorScriptBase.GetPuppet(context).GetSignalHandlerComponent().RemoveSignal(Deref(signalId));
  }

  public func GetSignalLifeTime() -> Float {
    return 0.50;
  }

  public final func GetEditorSubCaption() -> String {
    let result: String;
    let i: Int32 = 0;
    while i < ArraySize(this.tags) {
      if i > 0 {
        result += ".";
      };
      result += ToString(this.tags[i]);
      i += 1;
    };
    result += " (" + this.priority + ")";
    return result;
  }
}
