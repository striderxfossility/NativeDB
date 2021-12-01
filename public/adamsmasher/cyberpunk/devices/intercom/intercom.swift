
public class Intercom extends InteractiveDevice {

  private let m_isShortGlitchActive: Bool;

  private let m_shortGlitchDelayID: DelayID;

  @default(Intercom, dev_radio_ditraction_glitching)
  protected let m_distractionSound: CName;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"terminalui", n"worlduiWidgetComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"terminalui") as worlduiWidgetComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as IntercomController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    if this.IsUIdirty() && this.m_isInsideLogicArea {
      this.RefreshUI();
    };
  }

  protected func OnVisibilityChanged() -> Void {
    if this.IsReadyForUI() && this.IsUIdirty() {
      this.RefreshUI();
    };
  }

  protected cb func OnQuestPickUpCall(evt: ref<QuestPickUpCall>) -> Bool {
    this.UpdateDisplayUI(IntercomStatus.TALKING);
    this.UpdateDeviceState();
  }

  protected cb func OnQuestHangUpCall(evt: ref<QuestHangUpCall>) -> Bool {
    this.UpdateDisplayUI(IntercomStatus.CALL_ENDED);
    this.UpdateDeviceState();
  }

  protected cb func OnStartCall(evt: ref<StartCall>) -> Bool {
    if evt.IsStarted() {
      this.UpdateDisplayUI(IntercomStatus.CALLING);
    } else {
      this.UpdateDisplayUI(IntercomStatus.CALL_MISSED);
    };
    this.UpdateDeviceState();
  }

  protected cb func OnResetIntercom(evt: ref<DelayEvent>) -> Bool {
    this.UpdateDisplayUI(IntercomStatus.DEFAULT);
    this.UpdateDeviceState();
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
    this.GetBlackboard().SetVariant(GetAllBlackboardDefs().TVDeviceBlackboard.GlitchData, ToVariant(glitchData));
    this.GetBlackboard().FireCallbacks();
    GameObject.PlaySoundEvent(this, this.m_distractionSound);
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, n"hack_fx");
  }

  protected func StopGlitching() -> Void {
    let glitchData: GlitchData;
    let evt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    evt.SetShouldGlitch(0.00);
    this.QueueEvent(evt);
    glitchData.state = EGlitchState.NONE;
    this.GetBlackboard().SetVariant(GetAllBlackboardDefs().TVDeviceBlackboard.GlitchData, ToVariant(glitchData));
    this.GetBlackboard().FireCallbacks();
    GameObject.StopSoundEvent(this, this.m_distractionSound);
  }

  protected cb func OnStopShortGlitch(evt: ref<StopShortGlitchEvent>) -> Bool {
    this.m_isShortGlitchActive = false;
    if !this.GetDevicePS().IsGlitching() {
      this.StopGlitching();
    };
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

  protected cb func OnHitEvent(hit: ref<gameHitEvent>) -> Bool {
    super.OnHitEvent(hit);
    this.StartShortGlitch();
  }

  protected final func UpdateDisplayUI(status: IntercomStatus) -> Void {
    this.GetBlackboard().SetVariant(GetAllBlackboardDefs().IntercomBlackboard.Status, ToVariant(status), true);
    this.GetBlackboard().FireCallbacks();
    this.m_isUIdirty = true;
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().IntercomBlackboard);
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return this.GetDevicePS().GetBlackboardDef();
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }
}
