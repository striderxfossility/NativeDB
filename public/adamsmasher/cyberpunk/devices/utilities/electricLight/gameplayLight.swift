
public class GameplayLight extends InteractiveDevice {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as GameplayLightController;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func CutPower() -> Void {
    this.TurnOffLights();
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnLights();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffLights();
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    if !this.GetDevicePS().IsON() {
      this.TurnOnLights();
    };
    this.StartBlinking();
  }

  protected func StopGlitching() -> Void {
    if !this.GetDevicePS().IsON() {
      this.TurnOffLights();
    };
    this.StopBlinking();
  }

  private final func TurnOnLights() -> Void {
    let evt: ref<ToggleLightEvent> = new ToggleLightEvent();
    evt.toggle = true;
    this.QueueEvent(evt);
  }

  private final func TurnOffLights() -> Void {
    let evt: ref<ToggleLightEvent> = new ToggleLightEvent();
    evt.toggle = false;
    this.QueueEvent(evt);
  }

  protected final func StartBlinking() -> Void {
    let evt: ref<ChangeCurveEvent> = new ChangeCurveEvent();
    evt.time = 3.00;
    evt.curve = n"BrokenLamp3";
    evt.loop = true;
    this.QueueEvent(evt);
  }

  protected final func StopBlinking() -> Void {
    let evt: ref<ChangeCurveEvent> = new ChangeCurveEvent();
    evt.curve = n"";
    evt.loop = false;
    this.QueueEvent(evt);
  }

  protected func IncludeLightsInVisibilityBoundsScript() -> Bool {
    return true;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }
}
