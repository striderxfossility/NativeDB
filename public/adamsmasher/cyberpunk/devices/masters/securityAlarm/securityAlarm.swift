
public class SecurityAlarm extends InteractiveMasterDevice {

  protected let m_workingAlarm: ref<MeshComponent>;

  protected let m_destroyedAlarm: ref<MeshComponent>;

  protected let m_isGlitching: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"alarm", n"MeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"alarm_destroyed", n"MeshComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_workingAlarm = EntityResolveComponentsInterface.GetComponent(ri, n"alarm") as MeshComponent;
    this.m_destroyedAlarm = EntityResolveComponentsInterface.GetComponent(ri, n"alarm_destroyed") as MeshComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as SecurityAlarmController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    this.DetermineState();
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnToggleAlarm(evt: ref<ToggleAlarm>) -> Bool {
    this.DetermineState();
  }

  protected cb func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> Bool {
    super.OnSecuritySystemOutput(evt);
    this.DetermineState();
  }

  protected cb func OnSecurityAlarmBreachResponse(evt: ref<SecurityAlarmBreachResponse>) -> Bool {
    this.DetermineState();
  }

  protected cb func OnTargetAssessmentRequest(evt: ref<TargetAssessmentRequest>) -> Bool {
    this.DetermineState();
  }

  protected cb func OnQuestForceSecuritySystemSafe(evt: ref<QuestForceSecuritySystemSafe>) -> Bool {
    this.DetermineState();
  }

  protected cb func OnQuestForceSecuritySystemArmed(evt: ref<QuestForceSecuritySystemArmed>) -> Bool {
    this.DetermineState();
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    if NotEquals((this.GetDevicePS() as SecurityAlarmControllerPS).GetAlarmState(), ESecuritySystemState.COMBAT) {
      this.m_isGlitching = true;
      this.TurnOnLights();
      this.StartBlinking();
    };
  }

  protected func StopGlitching() -> Void {
    this.m_isGlitching = false;
    this.StopBlinking();
    this.DetermineState();
  }

  protected final func DetermineState() -> Void {
    if !this.m_isGlitching {
      this.DeactivateState();
      if Equals((this.GetDevicePS() as SecurityAlarmControllerPS).GetAlarmState(), ESecuritySystemState.COMBAT) {
        this.SetCombatState();
      };
    };
  }

  protected final func SetCombatState() -> Void {
    if this.GetDevicePS().IsON() {
      this.TurnOnLights();
      this.PlaySound();
      this.SendStim();
    };
  }

  protected final func DeactivateState() -> Void {
    this.TurnOffLights();
    this.StopSound();
    this.StopStim();
  }

  protected final func PlaySound() -> Void {
    if (this.GetDevicePS() as SecurityAlarmControllerPS).UsesSound() {
      GameObject.PlaySound(this, (this.GetDevicePS() as SecurityAlarmControllerPS).AlarmSound());
    };
  }

  protected final func StopSound() -> Void {
    if (this.GetDevicePS() as SecurityAlarmControllerPS).UsesSound() {
      GameObject.StopSound(this, (this.GetDevicePS() as SecurityAlarmControllerPS).AlarmSound());
    };
  }

  protected final func SendStim() -> Void {
    let stimType: gamedataStimType = (this.GetDevicePS() as SecurityAlarmControllerPS).UsesSound() ? gamedataStimType.Alarm : gamedataStimType.SilentAlarm;
    let broadcaster: ref<StimBroadcasterComponent> = this.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.SetSingleActiveStimuli(this, stimType, 20.00);
    };
  }

  protected final func StopStim() -> Void {
    let stimType: gamedataStimType = (this.GetDevicePS() as SecurityAlarmControllerPS).UsesSound() ? gamedataStimType.Alarm : gamedataStimType.SilentAlarm;
    let broadcaster: ref<StimBroadcasterComponent> = this.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.RemoveActiveStimuliByName(this, stimType);
    };
  }

  protected func TurnOffLights() -> Void {
    let evt: ref<ToggleLightEvent> = new ToggleLightEvent();
    evt.toggle = false;
    this.QueueEvent(evt);
  }

  protected final func TurnOnLights() -> Void {
    let evt: ref<ToggleLightEvent> = new ToggleLightEvent();
    evt.toggle = true;
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
    evt.time = 3.00;
    evt.curve = n"alarm";
    evt.loop = true;
    this.QueueEvent(evt);
  }

  protected func TurnOnDevice() -> Void {
    this.DetermineState();
  }

  protected func TurnOffDevice() -> Void {
    this.DeactivateState();
  }

  protected func CutPower() -> Void {
    this.DeactivateState();
  }

  protected func DeactivateDevice() -> Void {
    this.DeactivateDevice();
    this.GetDevicePS().GetDeviceOperationsContainer().Execute(n"death_VFX", this);
    this.m_workingAlarm.Toggle(false);
    this.m_destroyedAlarm.Toggle(true);
  }

  protected func ActivateDevice() -> Void {
    this.ActivateDevice();
    this.m_workingAlarm.Toggle(true);
    this.m_destroyedAlarm.Toggle(false);
  }

  protected func BreakDevice() -> Void {
    this.DeactivateState();
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Alarm;
  }
}
