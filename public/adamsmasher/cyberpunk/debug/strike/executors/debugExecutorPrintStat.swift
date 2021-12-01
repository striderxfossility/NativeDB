
public class StrikeExecutor_Debug_PrintStat extends StrikeExecutor_Debug {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let data: EffectData;
    let stat: Int32;
    let statType: gamedataStatType;
    let statTypeString: String;
    let value: Float;
    let puppet: ref<ScriptedPuppet> = EffectExecutionScriptContext.GetTarget(applierCtx) as ScriptedPuppet;
    let puppetID: StatsObjectID = Cast(puppet.GetEntityID());
    if IsDefined(puppet) {
      data = EffectScriptContext.GetSharedData(ctx);
      EffectData.GetInt(data, GetAllBlackboardDefs().EffectSharedData.statType, stat);
      statType = IntEnum(stat);
      value = GameInstance.GetStatsSystem(puppet.GetGame()).GetStatValue(puppetID, statType);
      statTypeString = EnumValueToString("gamedataStatType", Cast(stat));
      LogStats("");
      LogStats("---- stat of " + IsDefined(puppet) + " ----");
      LogStats("Stat: " + statTypeString + " Value: " + value);
      LogStats("");
      return true;
    };
    LogStrike("StrikeExecutor_PrintStat.Process(): provided object is not a puppet!");
    return false;
  }
}
