
public class LowFPSSelectCoverMode extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let osc: ref<ObjectSelectionComponent> = AIBehaviorScriptBase.GetPuppet(context).GetObjectSelectionComponent();
    if !IsDefined(osc) {
      return;
    };
    osc.PauseCoversProcessing(true);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let osc: ref<ObjectSelectionComponent> = AIBehaviorScriptBase.GetPuppet(context).GetObjectSelectionComponent();
    if !IsDefined(osc) {
      return;
    };
    osc.PauseCoversProcessing(false);
  }
}
