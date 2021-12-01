
public class CandleDevice extends InteractiveDevice {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as CandleController;
  }

  protected func TurnOffDevice() -> Void {
    GameObjectEffectHelper.BreakEffectLoopEvent(this, n"fx_candles_lightup");
    GameObjectEffectHelper.StopEffectEvent(this, n"fx_candles");
  }

  protected func TurnOnDevice() -> Void {
    GameObjectEffectHelper.StartEffectEvent(this, n"fx_candles", false);
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let puppet: wref<ScriptedPuppet>;
    if this.GetDevicePS().IsOFF() {
      return false;
    };
    puppet = EntityGameInterface.GetEntity(evt.activator) as ScriptedPuppet;
    if IsDefined(puppet) && puppet.IsBoss() {
      GameObjectEffectHelper.StartEffectEvent(this, n"fx_candles_lightup", false);
    };
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool {
    let puppet: wref<ScriptedPuppet>;
    if this.GetDevicePS().IsOFF() {
      return false;
    };
    puppet = EntityGameInterface.GetEntity(evt.activator) as ScriptedPuppet;
    if IsDefined(puppet) && puppet.IsBoss() {
      GameObjectEffectHelper.BreakEffectLoopEvent(this, n"fx_candles_lightup");
    };
  }
}
