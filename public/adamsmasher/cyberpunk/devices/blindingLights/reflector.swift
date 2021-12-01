
public class Reflector extends BlindingLight {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ReflectorController;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  protected cb func OnDistraction(evt: ref<Distraction>) -> Bool {
    if evt.IsStarted() {
      this.StartDistraction(true);
    } else {
      this.StopDistraction();
    };
    this.RefreshInteraction(gamedeviceRequestType.Direct, GetPlayer(this.GetGame()));
  }
}
