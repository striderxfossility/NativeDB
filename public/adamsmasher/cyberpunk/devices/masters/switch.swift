
public class SimpleSwitch extends InteractiveMasterDevice {

  protected let m_animationType: EAnimationType;

  @default(SimpleSwitch, 1.0)
  protected let m_animationSpeed: Float;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as SimpleSwitchController;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    this.SetDiodeAppearance(true);
    this.PlayAnimation(n"ToggleOn");
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.SetDiodeAppearance(false);
    this.PlayAnimation(n"ToggleOn");
  }

  private final func SetDiodeAppearance(on: Bool) -> Void {
    let lightSettings: ScriptLightSettings;
    let evt: ref<ChangeLightEvent> = new ChangeLightEvent();
    if on {
      lightSettings.color = new Color(25u, 135u, 0u, 255u);
    } else {
      lightSettings.color = new Color(130u, 0u, 0u, 0u);
    };
    lightSettings.strength = 1.00;
    evt.settings = lightSettings;
    this.QueueEvent(evt);
  }

  private final func PlayAnimation(id: CName) -> Void {
    let playEvent: ref<gameTransformAnimationPlayEvent>;
    if Equals(this.m_animationType, EAnimationType.REGULAR) {
    } else {
      if Equals(this.m_animationType, EAnimationType.TRANSFORM) {
        playEvent = new gameTransformAnimationPlayEvent();
        playEvent.animationName = id;
        playEvent.looping = false;
        playEvent.timesPlayed = 1u;
        if this.GetDevicePS().IsON() {
          playEvent.timeScale = this.m_animationSpeed;
        } else {
          if this.GetDevicePS().IsOFF() {
            playEvent.timeScale = this.m_animationSpeed * -1.00;
          };
        };
        this.QueueEvent(playEvent);
      };
    };
  }

  protected final func TurnOnLights() -> Void {
    let evt: ref<ToggleLightEvent> = new ToggleLightEvent();
    evt.toggle = true;
    this.QueueEvent(evt);
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.ControlOtherDevice;
  }
}
