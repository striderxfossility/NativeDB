
public class AlarmLight extends BasicDistractionDevice {

  protected let m_isGlitching: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as AlarmLightController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    this.UpdateLights();
  }

  protected cb func OnSecurityAlarmBreachResponse(evt: ref<SecurityAlarmBreachResponse>) -> Bool {
    this.UpdateLights();
  }

  protected cb func OnQuestForceSecuritySystemSafe(evt: ref<QuestForceSecuritySystemSafe>) -> Bool {
    this.UpdateLights();
  }

  protected cb func OnQuestForceSecuritySystemArmed(evt: ref<QuestForceSecuritySystemArmed>) -> Bool {
    this.UpdateLights();
  }

  protected cb func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> Bool {
    this.UpdateLights();
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    if NotEquals((this.GetDevicePS() as AlarmLightControllerPS).GetAlarmState(), ESecuritySystemState.COMBAT) {
      this.m_isGlitching = true;
      this.TurnOnLights();
      this.StartBlinking();
    };
  }

  protected func StopGlitching() -> Void {
    this.m_isGlitching = false;
    this.StopBlinking();
    this.UpdateLights();
  }

  protected final func UpdateLights() -> Void {
    if !this.m_isGlitching {
      if Equals((this.GetDevicePS() as AlarmLightControllerPS).GetAlarmState(), ESecuritySystemState.COMBAT) {
        this.TurnOnLights();
        this.SendStim();
      } else {
        this.TurnOffLights();
        this.StopStim();
      };
    };
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
    evt.time = 3.00;
    evt.curve = n"alarm";
    evt.loop = true;
    this.QueueEvent(evt);
  }

  protected final func SendStim() -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = this.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.SetSingleActiveStimuli(this, gamedataStimType.SilentAlarm, 10.00);
    };
  }

  protected final func StopStim() -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = this.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.RemoveActiveStimuliByName(this, gamedataStimType.SilentAlarm);
    };
  }

  protected func CutPower() -> Void {
    this.TurnOffLights();
    this.StopStim();
  }

  protected func TurnOnDevice() -> Void {
    this.UpdateLights();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffLights();
    this.StopStim();
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }
}
