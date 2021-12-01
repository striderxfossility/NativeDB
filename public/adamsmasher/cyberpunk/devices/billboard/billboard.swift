
public class BillboardDevice extends InteractiveDevice {

  protected let m_advUiComponent: ref<IComponent>;

  private let m_isShortGlitchActive: Bool;

  private let m_shortGlitchDelayID: DelayID;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"AdvertisementWidgetComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_advUiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ui");
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as BillboardDeviceController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    if this.ShouldRegisterToHUD() {
      this.RegisterToHUDManagerByTask(true);
    };
    if (this.GetDevicePS() as BillboardDeviceControllerPS).IsUsingDeviceAppearence() {
      this.SetMeshAppearance(n"default_device");
    };
  }

  protected func CutPower() -> Void {
    this.CutPower();
    this.TurnOffScreen();
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    this.TurnOnScreen();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.TurnOffScreen();
  }

  protected func BreakDevice() -> Void {
    this.BreakDevice();
    this.TurnOffScreen();
  }

  private final func TurnOffScreen() -> Void {
    if this.m_advUiComponent != null {
      this.m_advUiComponent.Toggle(false);
      this.ToggleLights(false);
    };
  }

  private final func TurnOnScreen() -> Void {
    if this.m_advUiComponent != null {
      this.m_advUiComponent.Toggle(true);
      this.ToggleLights(true);
    };
  }

  protected final func ToggleLights(on: Bool) -> Void {
    let evt: ref<ToggleLightEvent>;
    let i: Int32;
    let settEvt: ref<AdvanceChangeLightEvent>;
    let settings: array<EditableGameLightSettings>;
    if !(this.GetDevicePS() as BillboardDeviceControllerPS).IsUsingLights() {
      return;
    };
    evt = new ToggleLightEvent();
    evt.toggle = on;
    this.QueueEvent(evt);
    if on {
      settings = (this.GetDevicePS() as BillboardDeviceControllerPS).GetLightsSettings();
      i = 0;
      while i < ArraySize(settings) {
        settEvt = new AdvanceChangeLightEvent();
        settEvt.settings = settings[i];
        this.QueueEvent(settEvt);
        i += 1;
      };
    };
  }

  protected const func ShouldRegisterToHUD() -> Bool {
    if !this.ShouldRegisterToHUD() {
      return false;
    };
    if this.m_wasVisible {
      return true;
    };
    return false;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    let evt: ref<AdvertGlitchEvent>;
    if intensity == 0.00 {
      intensity = 1.00;
    };
    evt = new AdvertGlitchEvent();
    evt.SetShouldGlitch(intensity);
    this.QueueEvent(evt);
    GameObject.PlaySound(this, (this.GetDevicePS() as BillboardDeviceControllerPS).GetGlitchSFX());
    this.UpdateDeviceState();
  }

  protected func StopGlitching() -> Void {
    let evt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    evt.SetShouldGlitch(0.00);
    this.QueueEvent(evt);
    GameObject.StopSound(this, (this.GetDevicePS() as BillboardDeviceControllerPS).GetGlitchSFX());
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }

  protected func ApplyActiveStatusEffect(target: EntityID, statusEffect: TweakDBID) -> Void {
    if this.IsActiveStatusEffectValid() && this.GetDevicePS().IsGlitching() {
      GameInstance.GetStatusEffectSystem(this.GetGame()).ApplyStatusEffect(target, statusEffect);
    };
  }

  protected func UploadActiveProgramOnNPC(targetID: EntityID) -> Void {
    let evt: ref<ExecutePuppetActionEvent>;
    if this.IsActiveProgramToUploadOnNPCValid() && this.GetDevicePS().IsGlitching() {
      evt = new ExecutePuppetActionEvent();
      evt.actionID = this.GetActiveProgramToUploadOnNPC();
      this.QueueEventForEntityID(targetID, evt);
    };
  }

  protected cb func OnHitEvent(hit: ref<gameHitEvent>) -> Bool {
    super.OnHitEvent(hit);
    this.StartShortGlitch();
  }

  private final func StartShortGlitch() -> Void {
    let evt: ref<StopShortGlitchEvent>;
    if this.GetDevicePS().IsGlitching() {
      return;
    };
    if !this.m_isShortGlitchActive {
      evt = new StopShortGlitchEvent();
      this.StartGlitching(EGlitchState.DEFAULT, 1.00);
      this.m_shortGlitchDelayID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, 0.25);
      this.m_isShortGlitchActive = true;
    };
  }

  protected cb func OnStopShortGlitch(evt: ref<StopShortGlitchEvent>) -> Bool {
    this.m_isShortGlitchActive = false;
    if !this.GetDevicePS().IsGlitching() {
      this.StopGlitching();
    };
  }

  protected cb func OnPhysicalDestructionEvent(evt: ref<PhysicalDestructionEvent>) -> Bool {
    this.GetDevicePS().ForceDisableDevice();
  }
}
