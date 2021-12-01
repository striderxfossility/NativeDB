
public class AIBehaviorCallbackExpression extends AIbehaviorexpressionScript {

  protected edit let m_callbackName: CName;

  @default(AIBehaviorCallbackExpression, false)
  protected edit let m_initialValue: Bool;

  @default(AIBehaviorCallbackExpression, ECallbackExpressionActions.SetTrue)
  protected edit let m_callbackAction: ECallbackExpressionActions;

  protected let m_callbackId: Uint32;

  protected let m_value: Bool;

  protected final func Activate(context: ScriptExecutionContext) -> Void {
    this.m_callbackId = ScriptExecutionContext.AddBehaviorCallback(context, this.m_callbackName, this);
    this.m_value = this.m_initialValue;
  }

  protected final func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.RemoveBehaviorCallback(context, this.m_callbackId);
  }

  protected final func CalculateValue(context: ScriptExecutionContext) -> Variant {
    return ToVariant(this.m_value);
  }

  protected func OnBehaviorCallback(cbName: CName, context: ScriptExecutionContext) -> Bool {
    switch this.m_callbackAction {
      case ECallbackExpressionActions.SetTrue:
        this.m_value = true;
        break;
      case ECallbackExpressionActions.SetFalse:
        this.m_value = false;
        break;
      case ECallbackExpressionActions.Toggle:
      default:
        this.m_value = true;
    };
    this.m_value = !this.m_value;
    this.MarkDirty(context);
    return true;
  }
}
