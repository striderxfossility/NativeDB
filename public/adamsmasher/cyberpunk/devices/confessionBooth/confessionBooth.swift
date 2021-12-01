
public class ConfessionBooth extends BasicDistractionDevice {

  private let m_isShortGlitchActive: Bool;

  private let m_shortGlitchDelayID: DelayID;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"worlduiWidgetComponent", false);
    super.OnRequestComponents(ri);
  }

  public func ResavePersistentData(ps: ref<PersistentState>) -> Bool {
    return false;
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ui") as worlduiWidgetComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ConfessionBoothController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    if this.IsUIdirty() && this.m_isInsideLogicArea {
      this.RefreshUI();
    };
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().ConfessionalBlackboard);
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return this.GetDevicePS().GetBlackboardDef();
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnLights();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffLights();
  }

  protected final func TurnOnLights() -> Void {
    let evt: ref<ToggleLightEvent> = new ToggleLightEvent();
    evt.toggle = true;
    this.QueueEvent(evt);
  }

  protected final func TurnOffLights() -> Void {
    let evt: ref<ToggleLightEvent> = new ToggleLightEvent();
    evt.toggle = false;
    this.QueueEvent(evt);
  }

  private final func StartBlinking() -> Void {
    let evt: ref<ChangeCurveEvent> = new ChangeCurveEvent();
    evt.time = 1.00;
    evt.curve = n"blink_01";
    evt.loop = true;
    this.QueueEvent(evt);
  }

  private final func StopBlinking() -> Void {
    let evt: ref<ChangeCurveEvent> = new ChangeCurveEvent();
    this.QueueEvent(evt);
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    let evt: ref<AdvertGlitchEvent>;
    let glitchData: GlitchData;
    glitchData.state = glitchState;
    glitchData.intensity = intensity;
    if intensity == 0.00 {
      intensity = 1.00;
    };
    evt = new AdvertGlitchEvent();
    evt.SetShouldGlitch(intensity);
    this.QueueEvent(evt);
    this.GetBlackboard().SetVariant(this.GetBlackboardDef().GlitchData, ToVariant(glitchData), true);
    this.GetBlackboard().FireCallbacks();
    this.StartBlinking();
  }

  protected func StopGlitching() -> Void {
    let glitchData: GlitchData;
    let evt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    evt.SetShouldGlitch(0.00);
    this.QueueEvent(evt);
    glitchData.state = EGlitchState.NONE;
    this.GetBlackboard().SetVariant(this.GetBlackboardDef().GlitchData, ToVariant(glitchData));
    this.GetBlackboard().FireCallbacks();
    this.StopBlinking();
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

  protected cb func OnConfessionCompleted(evt: ref<ConfessionCompletedEvent>) -> Bool {
    if !this.GetDevicePS().IsGlitching() {
      this.StopBlinking();
    };
    GameObject.StopSound(this, n"dev_confession_booth_confessing");
  }

  protected cb func OnConfess(evt: ref<Confess>) -> Bool {
    if evt.IsCompleted() {
      this.StartConfessing();
      GameObject.PlaySound(this, n"dev_confession_booth_confessing");
    };
  }

  private final func StartConfessing() -> Void {
    this.GetBlackboard().SetBool(this.GetBlackboardDef() as ConfessionalBlackboardDef.IsConfessing, true);
    this.GetBlackboard().FireCallbacks();
    this.StartBlinking();
  }

  private final func StopConfessing() -> Void {
    this.GetBlackboard().SetBool(this.GetBlackboardDef() as ConfessionalBlackboardDef.IsConfessing, false);
    this.GetBlackboard().FireCallbacks();
    this.StopBlinking();
  }
}
