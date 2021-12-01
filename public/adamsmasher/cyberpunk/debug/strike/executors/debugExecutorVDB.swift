
public class StrikeExecutor_Debug_VDB extends StrikeExecutor_Debug {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let data: EffectData;
    let duration: Float;
    let infiniteDuration: Bool;
    let puppets: array<ref<ScriptedPuppet>>;
    let entity: ref<Entity> = EffectExecutionScriptContext.GetTarget(applierCtx);
    let puppet: ref<ScriptedPuppet> = entity as ScriptedPuppet;
    if IsDefined(puppet) {
      data = EffectScriptContext.GetSharedData(ctx);
      EffectData.GetFloat(data, GetAllBlackboardDefs().EffectSharedData.duration, duration);
      EffectData.GetBool(data, GetAllBlackboardDefs().EffectSharedData.infiniteDuration, infiniteDuration);
      ArrayPush(puppets, puppet);
      GetPlayer(puppet.GetGame()).DEBUG_Visualizer.VisualizePuppets(puppets, infiniteDuration, duration);
      return true;
    };
    return false;
  }
}
