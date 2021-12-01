
public class NcartTimetable extends InteractiveDevice {

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
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as NcartTimetableController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    if this.IsUIdirty() && this.m_isInsideLogicArea {
      this.RefreshUI();
    };
  }

  protected cb func OnPersitentStateInitialized(evt: ref<GameAttachedEvent>) -> Bool {
    super.OnPersitentStateInitialized(evt);
    this.InitializeDisplayUpdate();
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().NcartTimetableBlackboard);
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return this.GetDevicePS().GetBlackboardDef();
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
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
    this.GetBlackboard().SetVariant(this.GetBlackboardDef().GlitchData, ToVariant(glitchData));
    this.GetBlackboard().FireCallbacks();
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, n"hack_fx");
  }

  protected func StopGlitching() -> Void {
    let glitchData: GlitchData;
    let evt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    evt.SetShouldGlitch(0.00);
    this.QueueEvent(evt);
    glitchData.state = EGlitchState.NONE;
    this.GetBlackboard().SetVariant(this.GetBlackboardDef().GlitchData, ToVariant(glitchData));
    this.GetBlackboard().FireCallbacks();
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.BreakLoop, n"hack_fx");
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

  protected cb func OnHitEvent(hit: ref<gameHitEvent>) -> Bool {
    super.OnHitEvent(hit);
    this.StartShortGlitch();
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    this.TurnOnScreen();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.TurnOffScreen();
  }

  protected func CutPower() -> Void {
    this.CutPower();
    this.TurnOffScreen();
  }

  private final func TurnOffScreen() -> Void {
    this.m_uiComponent.Toggle(false);
  }

  private final func TurnOnScreen() -> Void {
    this.m_uiComponent.Toggle(true);
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

  private final func InitializeDisplayUpdate() -> Void {
    let evt: ref<NcartTimeTableCounterUpdateEvent> = new NcartTimeTableCounterUpdateEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, (this.GetDevicePS() as NcartTimetableControllerPS).GetUiUpdateFrequency());
    this.UpdateCounterUI();
  }

  private final func UpdateCounterUI() -> Void {
    let counterValue: Int32 = (this.GetDevicePS() as NcartTimetableControllerPS).GetCurrentTimeToDepart();
    this.GetBlackboard().SetInt(GetAllBlackboardDefs().NcartTimetableBlackboard.TimeToDepart, counterValue, true);
    this.GetBlackboard().FireCallbacks();
  }

  protected cb func OnCounterUpdate(evt: ref<NcartTimeTableCounterUpdateEvent>) -> Bool {
    evt = new NcartTimeTableCounterUpdateEvent();
    (this.GetDevicePS() as NcartTimetableControllerPS).UpdateCurrentTimeToDepart();
    this.UpdateCounterUI();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, (this.GetDevicePS() as NcartTimetableControllerPS).GetUiUpdateFrequency());
  }
}
