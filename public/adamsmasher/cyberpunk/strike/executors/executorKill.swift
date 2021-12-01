
public class StrikeExecutor_Kill extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let puppet: ref<ScriptedPuppet> = EffectExecutionScriptContext.GetTarget(applierCtx) as ScriptedPuppet;
    if IsDefined(puppet) {
      puppet.Kill();
      return true;
    };
    LogStrike("StrikeExecutor_Kill.Process(): provided object is not a puppet!");
    return true;
  }
}
