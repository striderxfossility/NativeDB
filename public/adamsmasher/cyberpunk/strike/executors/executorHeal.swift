
public class StrikeExecutor_Heal extends EffectExecutor_Scripted {

  private edit let healthPerc: Float;

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let puppet: ref<ScriptedPuppet> = EffectExecutionScriptContext.GetTarget(applierCtx) as ScriptedPuppet;
    let puppetID: StatsObjectID = Cast(puppet.GetEntityID());
    if IsDefined(puppet) {
      GameInstance.GetStatPoolsSystem(puppet.GetGame()).RequestChangingStatPoolValue(puppetID, gamedataStatPoolType.Health, this.healthPerc, puppet, false);
      return true;
    };
    LogStrike("StrikeExecutor_Heal.Process(): provided object is not a puppet!");
    return false;
  }
}
