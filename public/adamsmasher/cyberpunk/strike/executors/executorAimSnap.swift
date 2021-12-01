
public class SnapToTargetExecutor extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let target: ref<Entity> = EffectExecutionScriptContext.GetTarget(applierCtx);
    if IsDefined(target as ScriptedPuppet) {
      GameInstance.GetTargetingSystem(EffectScriptContext.GetGameInstance(ctx)).AimSnap(EffectScriptContext.GetInstigator(ctx) as GameObject);
    };
    return true;
  }
}
