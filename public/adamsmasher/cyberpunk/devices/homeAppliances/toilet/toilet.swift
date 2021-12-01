
public class Toilet extends InteractiveDevice {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ToiletController;
  }

  protected cb func OnFlush(evt: ref<Flush>) -> Bool {
    if evt.IsStarted() {
      GameObject.PlaySoundEvent(this, (this.GetDevicePS() as ToiletControllerPS).GetFlushSFX());
      GameObjectEffectHelper.StartEffectEvent(this, (this.GetDevicePS() as ToiletControllerPS).GetFlushVFX());
    } else {
      GameObjectEffectHelper.StopEffectEvent(this, (this.GetDevicePS() as ToiletControllerPS).GetFlushVFX());
    };
    this.UpdateDeviceState();
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.GenericRole;
  }
}
