
public class TrafficZebra extends TrafficLight {

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as TrafficZebraController;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnTrafficLightChangeEvent(evt: ref<TrafficLightChangeEvent>) -> Bool {
    if NotEquals(this.m_lightState, evt.lightColor) && this.GetDevicePS().IsInitialized() {
      this.m_lightState = evt.lightColor;
      if Equals(evt.lightColor, worldTrafficLightColor.GREEN) {
        this.HandleGreenLight();
      } else {
        this.HandleRedLight();
      };
    };
  }

  private final func HandleRedLight() -> Void {
    this.SetMeshAppearance(n"stop");
  }

  private final func HandleGreenLight() -> Void {
    this.SetMeshAppearance(n"default");
  }
}
