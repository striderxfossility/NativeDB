
public class Candle extends GameObject {

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let puppet: wref<ScriptedPuppet> = EntityGameInterface.GetEntity(evt.activator) as ScriptedPuppet;
    if IsDefined(puppet) && puppet.IsBoss() {
      GameObjectEffectHelper.StartEffectEvent(this, n"fx_candles_lightup", false);
    };
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool {
    let puppet: wref<ScriptedPuppet> = EntityGameInterface.GetEntity(evt.activator) as ScriptedPuppet;
    if IsDefined(puppet) && puppet.IsBoss() {
      GameObjectEffectHelper.BreakEffectLoopEvent(this, n"fx_candles_lightup");
    };
  }
}
