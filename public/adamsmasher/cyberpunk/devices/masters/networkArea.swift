
public class NetworkArea extends InteractiveMasterDevice {

  private let m_area: ref<TriggerComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"area", n"TriggerComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_area = EntityResolveComponentsInterface.GetComponent(ri, n"area") as TriggerComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as NetworkAreaController;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let entityID: EntityID = this.ExtractEntityID(evt);
    if this.IsPlayer(entityID) {
      (this.GetDevicePS() as NetworkAreaControllerPS).AreaEntered();
    };
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool {
    let entityID: EntityID = this.ExtractEntityID(evt);
    if this.IsPlayer(entityID) {
      (this.GetDevicePS() as NetworkAreaControllerPS).AreaExited();
    };
  }
}
