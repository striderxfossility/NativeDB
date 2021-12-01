
public class SetTemporaryIndividualTimeDilation extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let reason: CName;
    let puppet: ref<gamePuppet> = EffectExecutionScriptContext.GetTarget(applierCtx) as gamePuppet;
    if IsDefined(puppet) {
      TimeDilationHelper.SetIndividualTimeDilation(puppet, reason, 0.05, 2.50, n"Linear", n"DiveEaseOut");
      return true;
    };
    return false;
  }
}
