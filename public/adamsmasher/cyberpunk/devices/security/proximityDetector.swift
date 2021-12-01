
public abstract class ProximityDetector extends Device {

  @default(ProximityDetector, scanningArea)
  protected const let m_scanningAreaName: CName;

  @default(ProximityDetector, surroundingArea)
  protected const let m_surroundingAreaName: CName;

  protected let m_scanningArea: ref<TriggerComponent>;

  protected let m_surroundingArea: ref<TriggerComponent>;

  private let m_securityAreaType: ESecurityAreaType;

  private let m_notifiactionType: ESecurityNotificationType;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, this.m_scanningAreaName, n"gameStaticTriggerAreaComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, this.m_surroundingAreaName, n"gameStaticTriggerAreaComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_scanningArea = EntityResolveComponentsInterface.GetComponent(ri, this.m_scanningAreaName) as TriggerComponent;
    this.m_surroundingArea = EntityResolveComponentsInterface.GetComponent(ri, this.m_surroundingAreaName) as TriggerComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ProximityDetectorController;
  }

  protected func ResolveGameplayState() -> Void {
    let i: Int32;
    let secAreas: array<ref<SecurityAreaControllerPS>>;
    this.ResolveGameplayState();
    secAreas = this.GetDevicePS().GetSecurityAreas();
    if ArraySize(secAreas) == 0 {
      if !IsFinal() {
        LogDevices(this, "NO SECURITY AREAS FOUND", ELogType.WARNING);
      };
      return;
    };
    this.m_securityAreaType = ESecurityAreaType.DISABLED;
    i = 0;
    while i < ArraySize(secAreas) {
      if secAreas[i].GetSecurityAreaType() > this.m_securityAreaType {
        this.m_securityAreaType = secAreas[i].GetSecurityAreaType();
      };
      i += 1;
    };
    if Equals(this.m_securityAreaType, ESecurityAreaType.SAFE) {
      this.LockDevice(false);
    };
    if this.m_securityAreaType > ESecurityAreaType.RESTRICTED {
      this.m_notifiactionType = ESecurityNotificationType.COMBAT;
    } else {
      this.m_notifiactionType = ESecurityNotificationType.ILLEGAL_ACTION;
    };
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let authLevel: ESecurityAccessLevel;
    let whoEntered: EntityID = EntityGameInterface.GetEntity(evt.activator).GetEntityID();
    if Equals(evt.componentName, this.m_surroundingAreaName) {
      if whoEntered == this.GetPlayerMainObject().GetEntityID() && this.GetDevicePS().IsConnectedToSecuritySystem(authLevel) {
        if this.GetDevicePS().GetSecuritySystem().IsUserAuthorized(whoEntered, authLevel) {
          this.LockDevice(false);
          return false;
        };
      };
    };
    if Equals(evt.componentName, this.m_scanningAreaName) {
      if this.GetDevicePS().IsConnectedToSecuritySystem(authLevel) && !this.GetDevicePS().GetSecuritySystem().IsUserAuthorized(whoEntered, authLevel) {
        this.GetDevicePS().TriggerSecuritySystemNotification(EntityGameInterface.GetEntity(evt.activator) as GameObject, EntityGameInterface.GetEntity(evt.activator).GetWorldPosition(), this.m_notifiactionType);
      };
    };
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool {
    let whoLeft: EntityID;
    if NotEquals(evt.componentName, this.m_surroundingAreaName) {
      return IsDefined(null);
    };
    whoLeft = EntityGameInterface.GetEntity(evt.activator).GetEntityID();
    if whoLeft == this.GetPlayerMainObject().GetEntityID() {
      this.LockDevice(true);
    };
  }

  protected cb func OnTargetAssessmentRequest(evt: ref<TargetAssessmentRequest>) -> Bool {
    let secSys: ref<SecuritySystemControllerPS> = this.GetDevicePS().GetSecuritySystem();
    if IsDefined(secSys) {
      if Equals(secSys.GetMostDangerousSecurityAreaForEntityID(this.GetEntityID()).GetSecurityAreaType(), ESecurityAreaType.SAFE) && secSys.IsSystemSafe() {
        this.LockDevice(false);
      } else {
        this.LockDevice(true);
      };
    };
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.ToggleComponents(false);
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    this.ToggleComponents(true);
  }

  private final func ToggleComponents(on: Bool) -> Void {
    this.m_scanningArea.Toggle(on);
    this.m_surroundingArea.Toggle(on);
  }

  protected func LockDevice(enableLock: Bool) -> Void;

  protected cb func OnFullSystemRestart(evt: ref<FullSystemRestart>) -> Bool {
    this.ToggleComponents(false);
    this.LockDevice(false);
  }

  protected cb func OnWakeUpFromRestartEvent(evt: ref<WakeUpFromRestartEvent>) -> Bool {
    this.ToggleComponents(true);
    this.LockDevice(true);
  }
}
