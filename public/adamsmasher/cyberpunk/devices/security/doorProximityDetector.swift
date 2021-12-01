
public class DoorProximityDetector extends ProximityDetector {

  private let m_debugIsBlinkOn: Bool;

  private let m_triggeredAlarmID: DelayID;

  @default(DoorProximityDetector, 2.0f)
  private let m_blinkInterval: Float;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as DoorProximityDetectorController;
  }

  protected cb func OnGameAttached() -> Bool {
    let secSys: ref<SecuritySystemControllerPS>;
    if this.m_debugIsBlinkOn {
      this.TriggerAlarmBehavior(true);
    };
    secSys = this.GetDevicePS().GetSecuritySystem();
    if IsDefined(secSys) {
      if !secSys.IsSystemSafe() {
        this.TriggerAlarmBehavior(true);
      };
    };
  }

  protected cb func OnDetach() -> Bool {
    this.TriggerAlarmBehavior(false);
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.SetMeshAppearance(n"off");
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    this.LockDevice(true);
  }

  protected func LockDevice(shouldLock: Bool) -> Void {
    let meshName: CName;
    if shouldLock {
      meshName = n"on";
    } else {
      meshName = n"green";
    };
    this.SetMeshAppearance(meshName);
  }

  private final func TriggerAlarmBehavior(yes: Bool) -> Void {
    let alarm: ref<AlarmEvent>;
    let ds: ref<DelaySystem>;
    if this.GetDevicePS().GetSecuritySystem().IsRestarting() {
      this.LockDevice(false);
      return;
    };
    ds = GameInstance.GetDelaySystem(this.GetGame());
    if !IsDefined(ds) {
      return;
    };
    if yes {
      if !this.IsAlarmTriggered() {
        alarm = new AlarmEvent();
        this.m_triggeredAlarmID = ds.DelayEvent(this, alarm, this.m_blinkInterval);
      };
    } else {
      if this.IsAlarmTriggered() {
        this.CancelAlarmCallback();
        if this.GetDevicePS().GetSecuritySystem().IsRestarting() {
          this.LockDevice(false);
        } else {
          this.LockDevice(true);
        };
      };
    };
  }

  protected cb func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> Bool {
    if Equals(evt.GetCachedSecurityState(), ESecuritySystemState.COMBAT) {
      this.TriggerAlarmBehavior(true);
    } else {
      this.TriggerAlarmBehavior(false);
    };
  }

  private final func IsAlarmTriggered() -> Bool {
    let nullID: DelayID;
    if this.m_triggeredAlarmID == nullID {
      return false;
    };
    return true;
  }

  protected cb func OnAlarmBlink(evt: ref<AlarmEvent>) -> Bool {
    if this.GetDevicePS().GetSecuritySystem().IsRestarting() {
      this.CancelAlarmCallback();
      this.TriggerAlarmBehavior(false);
      return false;
    };
    if evt.isValid {
      this.SetMeshAppearance(n"bars");
    } else {
      this.SetMeshAppearance(n"alarm");
    };
    evt.isValid = !evt.isValid;
    this.m_triggeredAlarmID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, this.m_blinkInterval);
  }

  private final func CancelAlarmCallback() -> Void {
    let emptyID: DelayID;
    let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGame());
    if !IsDefined(ds) {
      return;
    };
    ds.CancelCallback(this.m_triggeredAlarmID);
    ds.CancelDelay(this.m_triggeredAlarmID);
    this.m_triggeredAlarmID = emptyID;
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    this.SetMeshAppearance(n"glitch");
  }

  protected func StopGlitching() -> Void {
    this.LockDevice(true);
  }
}
