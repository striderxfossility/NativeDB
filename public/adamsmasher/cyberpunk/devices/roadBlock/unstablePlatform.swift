
public class UnstablePlatform extends BaseAnimatedDevice {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let activator: wref<GameObject>;
    if this.GetDevicePS().IsDisabled() || this.GetDevicePS().IsUnpowered() {
      return false;
    };
    activator = EntityGameInterface.GetEntity(evt.activator) as GameObject;
    if activator.IsPlayer() && this.GetDevicePS().IsActivated() {
      GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.GetDevicePS().GetID(), this.GetDevicePS().GetClassName(), this.GetDevicePS().ActionDeactivateDevice());
    };
  }
}
