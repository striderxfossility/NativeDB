
public class SecurityGate extends InteractiveMasterDevice {

  private let m_sideA: ref<TriggerComponent>;

  private let m_sideB: ref<TriggerComponent>;

  private let m_scanningArea: ref<TriggerComponent>;

  private let m_trespassersDataList: array<TrespasserEntry>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"sideA", n"gameStaticTriggerAreaComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"sideB", n"gameStaticTriggerAreaComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"scanningArea", n"gameStaticTriggerAreaComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_sideA = EntityResolveComponentsInterface.GetComponent(ri, n"sideA") as TriggerComponent;
    this.m_sideB = EntityResolveComponentsInterface.GetComponent(ri, n"sideB") as TriggerComponent;
    this.m_scanningArea = EntityResolveComponentsInterface.GetComponent(ri, n"scanningArea") as TriggerComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as SecurityGateController;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    (this.GetDevicePS() as SecurityGateControllerPS).UpdateTrespassersList(evt, true);
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool {
    (this.GetDevicePS() as SecurityGateControllerPS).UpdateTrespassersList(evt, false);
  }

  protected cb func OnSecurityGateResponse(evt: ref<SecurityGateResponse>) -> Bool {
    GameObjectEffectHelper.BreakEffectLoopEvent(this, n"scan");
  }

  protected cb func OnInitiateScanner(evt: ref<InitiateScanner>) -> Bool {
    GameObjectEffectHelper.StartEffectEvent(this, n"scan");
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    this.GetDevicePS().TurnAuthorizationModuleOFF();
    GameObjectEffectHelper.StartEffectEvent(this, n"fx_distraction");
  }

  protected func StopGlitching() -> Void {
    this.GetDevicePS().TurnAuthorizationModuleON();
    GameObjectEffectHelper.BreakEffectLoopEvent(this, n"fx_distraction");
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Alarm;
  }
}
