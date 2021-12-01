
public class StrikeDuration_Debug_VDB extends StrikeDuration_Debug {

  @default(StrikeDuration_Debug_VDB, 1.f)
  private const let UPDATE_DELAY: Float;

  @default(StrikeDuration_Debug_VDB, 1.1f)
  private const let DISPLAY_DURATION: Float;

  private let timeToNextUpdate: Float;

  public final func Process(ctx: EffectScriptContext, durationCtx: EffectDurationModifierScriptContext) -> Float {
    let data: EffectData;
    let dt: Float;
    let factVal: Int32;
    let radius: Float;
    let gi: GameInstance = EffectScriptContext.GetGameInstance(ctx);
    if this.timeToNextUpdate <= 0.00 {
      data = EffectScriptContext.GetSharedData(ctx);
      EffectData.GetFloat(data, GetAllBlackboardDefs().EffectSharedData.radius, radius);
      DebugNPCs_NonExec(gi, FloatToString(this.DISPLAY_DURATION), FloatToString(radius));
      this.timeToNextUpdate = this.UPDATE_DELAY;
    };
    dt = EffectDurationModifierScriptContext.GetTimeDelta(durationCtx);
    this.timeToNextUpdate -= dt;
    factVal = GetFact(gi, n"cheat_vdb_const");
    if factVal == 0 {
      GetPlayer(gi).DEBUG_Visualizer.ClearPuppetVisualization();
      return 0.00;
    };
    return this.UPDATE_DELAY + 0.50;
  }
}
