
public class AIScriptActionDelegate extends ScriptBehaviorDelegate {

  private edit let actionPackageType: AIactionParamsPackageTypes;

  public final static func GetActionPackageType(context: ScriptExecutionContext) -> AIactionParamsPackageTypes {
    let actionDelegate: ref<AIScriptActionDelegate>;
    let delegate: ref<BehaviorDelegate> = ScriptExecutionContext.GetClosestDelegate(context);
    while IsDefined(delegate) {
      actionDelegate = delegate as AIScriptActionDelegate;
      if IsDefined(actionDelegate) {
        if NotEquals(actionDelegate.actionPackageType, AIactionParamsPackageTypes.Undefined) {
          return actionDelegate.actionPackageType;
        };
      };
      delegate = delegate.GetParent();
    };
    return AIactionParamsPackageTypes.Default;
  }
}
