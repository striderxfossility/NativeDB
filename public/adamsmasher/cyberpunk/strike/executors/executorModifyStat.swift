
public class StrikeExecutor_ModifyStat extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let data: EffectData;
    let stat: Int32;
    let value: Float;
    let puppet: ref<ScriptedPuppet> = EffectExecutionScriptContext.GetTarget(applierCtx) as ScriptedPuppet;
    if IsDefined(puppet) {
      data = EffectScriptContext.GetSharedData(ctx);
      EffectData.GetInt(data, GetAllBlackboardDefs().EffectSharedData.statType, stat);
      EffectData.GetFloat(data, GetAllBlackboardDefs().EffectSharedData.value, value);
      return this.ModStatPuppet(puppet, IntEnum(stat), value, EffectScriptContext.GetSource(ctx));
    };
    LogStrike("StrikeExecutor_ModifyStat.Process(): provided object is not a puppet!");
    return false;
  }

  public final func ModStatPuppet(puppet: ref<ScriptedPuppet>, stat: gamedataStatType, value: Float, source: ref<Entity>) -> Bool {
    let puppetID: StatsObjectID = Cast(puppet.GetEntityID());
    let mod: ref<gameConstantStatModifierData> = new gameConstantStatModifierData();
    mod.value = value;
    mod.statType = stat;
    mod.modifierType = gameStatModifierType.Additive;
    return GameInstance.GetStatsSystem(puppet.GetGame()).AddModifier(puppetID, mod);
  }
}
