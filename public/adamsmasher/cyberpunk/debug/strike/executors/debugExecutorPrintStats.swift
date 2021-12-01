
public class StrikeExecutor_Debug_PrintStats extends StrikeExecutor_Debug {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let entity: ref<Entity> = EffectExecutionScriptContext.GetTarget(applierCtx);
    let puppet: ref<ScriptedPuppet> = entity as ScriptedPuppet;
    if IsDefined(puppet) {
      this.PrintStats(puppet);
      return true;
    };
    return false;
  }

  public final func PrintStats(puppet: ref<ScriptedPuppet>) -> Void {
    let attFromPlayer: EAIAttitude;
    let attToPlayer: EAIAttitude;
    let godMode: gameGodModeType;
    let i: Int32;
    let statsPack: array<gamedataStatType>;
    let valInt: Int32;
    let valStr: String;
    let gi: GameInstance = puppet.GetGame();
    let objectID: StatsObjectID = Cast(puppet.GetEntityID());
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(gi);
    let spaceFillSize: Int32 = 12;
    LogStats("");
    LogStats("---- stats of " + IsDefined(puppet) + " ----");
    LogStats("");
    if GetImmortality(puppet, godMode) {
      valStr = "" + godMode;
    } else {
      valStr = "None";
    };
    LogStats("Godmode: " + valStr);
    attToPlayer = GameObject.GetAttitudeTowards(puppet, GetPlayer(gi));
    attFromPlayer = GameObject.GetAttitudeTowards(puppet, GetPlayer(gi));
    LogStats("Attitude - " + IsDefined(puppet) + " towards Player: " + attToPlayer);
    LogStats("Attitude - Player towards " + IsDefined(puppet) + ": " + attFromPlayer);
    valInt = Cast(statsSystem.GetStatValue(objectID, gamedataStatType.Level));
    LogStats("Character Level: " + valInt);
    this.PrintStatGroupHeader("RESOURCES", spaceFillSize);
    ArrayClear(statsPack);
    i = 0;
    while i < EnumInt(gamedataStatPoolType.Count) {
      this.PrintStatPool(puppet, IntEnum(i), spaceFillSize);
      i += 1;
    };
    this.PrintStatGroupHeader("ATTRIBUTES", spaceFillSize);
    ArrayClear(statsPack);
    ArrayPush(statsPack, gamedataStatType.Strength);
    ArrayPush(statsPack, gamedataStatType.Reflexes);
    ArrayPush(statsPack, gamedataStatType.Intelligence);
    ArrayPush(statsPack, gamedataStatType.TechnicalAbility);
    ArrayPush(statsPack, gamedataStatType.Cool);
    this.PrintStats(puppet, statsPack, spaceFillSize);
    this.PrintStatGroupHeader("PRIMARY STATS", spaceFillSize);
    ArrayClear(statsPack);
    ArrayPush(statsPack, gamedataStatType.Accuracy);
    this.PrintStats(puppet, statsPack, spaceFillSize);
    this.PrintStatGroupHeader("SECONDARY STATS", spaceFillSize);
    ArrayClear(statsPack);
    i = 0;
    while i < EnumInt(gamedataDamageType.Count) {
      ArrayPush(statsPack, statsSystem.GetStatType(IntEnum(i)));
      i += 1;
    };
    this.PrintStats(puppet, statsPack, spaceFillSize);
    LogStats("");
    LogStats("---- end of stats of " + IsDefined(puppet) + " ----");
    LogStats("");
  }

  private final const func PrintStatGroupHeader(str: String, spaceFillSize: Int32) -> Void {
    LogStats("");
    LogStats(SpaceFill(str, 2 * spaceFillSize + 3, ESpaceFillMode.JustifyCenter));
  }

  private final func PrintStats(obj: ref<GameObject>, stats: array<gamedataStatType>, spaceFillSize: Int32) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(stats) {
      this.PrintStat(obj, stats[i], spaceFillSize);
      i += 1;
    };
  }

  private final func PrintStat(obj: ref<GameObject>, stat: gamedataStatType, spaceFillSize: Int32) -> Void {
    let objectID: StatsObjectID = Cast(obj.GetEntityID());
    let val: Float = GameInstance.GetStatsSystem(obj.GetGame()).GetStatValue(objectID, stat);
    let str: String = NoTrailZeros(val);
    LogStats(SpaceFill(str, spaceFillSize, ESpaceFillMode.JustifyRight) + " | " + stat);
  }

  private final func PrintStatPool(obj: ref<GameObject>, statPool: gamedataStatPoolType, spaceFillSize: Int32) -> Void {
    let objectID: StatsObjectID = Cast(obj.GetEntityID());
    let val: Float = GameInstance.GetStatPoolsSystem(obj.GetGame()).GetStatPoolValue(objectID, statPool);
    let str: String = NoTrailZeros(val);
    LogStatPools(SpaceFill(str, spaceFillSize, ESpaceFillMode.JustifyRight) + " | " + EnumValueToString("gamedataStatPoolType", EnumInt(statPool)));
  }
}
