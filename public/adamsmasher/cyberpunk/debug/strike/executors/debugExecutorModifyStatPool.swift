
public class StrikeExecutor_Debug_ModifyStatPool extends StrikeExecutor_Debug {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let data: EffectData;
    let isPercent: Bool;
    let statPool: Int32;
    let statPoolType: gamedataStatPoolType;
    let value: Float;
    let puppet: ref<ScriptedPuppet> = EffectExecutionScriptContext.GetTarget(applierCtx) as ScriptedPuppet;
    let puppetID: StatsObjectID = Cast(puppet.GetEntityID());
    if IsDefined(puppet) {
      data = EffectScriptContext.GetSharedData(ctx);
      EffectData.GetInt(data, GetAllBlackboardDefs().EffectSharedData.statType, statPool);
      EffectData.GetFloat(data, GetAllBlackboardDefs().EffectSharedData.value, value);
      EffectData.GetBool(data, GetAllBlackboardDefs().EffectSharedData.debugBool, isPercent);
      statPoolType = IntEnum(statPool);
      GameInstance.GetStatPoolsSystem(puppet.GetGame()).RequestSettingStatPoolValue(puppetID, statPoolType, value, null, isPercent);
      return true;
    };
    LogStrike("StrikeExecutor_ModifyStat.Process(): provided object is not a puppet!");
    return false;
  }
}
