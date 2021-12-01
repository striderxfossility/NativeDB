
public class QuickMeleeHitExecutor extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let target: ref<Entity> = EffectExecutionScriptContext.GetTarget(applierCtx);
    if IsDefined(target as ScriptedPuppet) {
      GameInstance.GetBlackboardSystem(GetGameInstance()).Get(GetAllBlackboardDefs().QuickMeleeData).SetBool(GetAllBlackboardDefs().QuickMeleeData.NPCHit, true);
    };
    return true;
  }
}
