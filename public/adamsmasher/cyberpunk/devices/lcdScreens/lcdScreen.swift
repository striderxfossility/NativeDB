
public class LcdScreen extends InteractiveDevice {

  protected let m_isShortGlitchActive: Bool;

  protected let m_shortGlitchDelayID: DelayID;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"IWorldWidgetComponent", false);
    super.OnRequestComponents(ri);
  }

  public func ResavePersistentData(ps: ref<PersistentState>) -> Bool {
    return false;
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ui") as IWorldWidgetComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as LcdScreenController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    if this.IsUIdirty() && this.m_isInsideLogicArea {
      this.RefreshUI();
    };
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().LcdScreenBlackBoard);
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
    this.GetBlackboard().SetVariant(this.GetBlackboardDef().GlitchData, ToVariant(glitchData), true);
    this.GetBlackboard().FireCallbacks();
  }

  protected func StopGlitching() -> Void {
    let glitchData: GlitchData;
    let evt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    evt.SetShouldGlitch(0.00);
    this.QueueEvent(evt);
    glitchData.state = EGlitchState.NONE;
    this.GetBlackboard().SetVariant(this.GetBlackboardDef().GlitchData, ToVariant(glitchData));
    this.GetBlackboard().FireCallbacks();
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

  public final const func GetMessageRecord() -> ref<ScreenMessageData_Record> {
    let id: TweakDBID = (this.GetDevicePS() as LcdScreenControllerPS).GetMessageRecordID();
    if !TDBID.IsValid(id) {
      return null;
    };
    return TweakDBInterface.GetScreenMessageDataRecord(id);
  }

  public final const func HasCustomNumber() -> Bool {
    return (this.GetDevicePS() as LcdScreenControllerPS).HasCustomNumber();
  }

  public final const func GetCustomNumber() -> Int32 {
    return (this.GetDevicePS() as LcdScreenControllerPS).GetCustomNumber();
  }

  private final func UpdateMessageRecordUI(messageData: ref<ScreenMessageData>) -> Void {
    if messageData == null {
      return;
    };
    if !IsDefined(messageData.m_messageRecord) {
      return;
    };
    if this.GetDevicePS().IsON() {
      this.GetBlackboard().SetVariant(GetAllBlackboardDefs().LcdScreenBlackBoard.MessegeData, ToVariant(messageData));
      this.GetBlackboard().FireCallbacks();
    };
  }

  protected cb func OnSetMessageRecord(evt: ref<SetMessageRecordEvent>) -> Bool {
    let messageData: ref<ScreenMessageData> = new ScreenMessageData();
    messageData.m_messageRecord = TweakDBInterface.GetScreenMessageDataRecord(evt.m_messageRecordID);
    messageData.m_replaceTextWithCustomNumber = evt.m_replaceTextWithCustomNumber;
    messageData.m_customNumber = evt.m_customNumber;
    this.UpdateMessageRecordUI(messageData);
  }
}
