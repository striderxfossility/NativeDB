
public class SecurityGateLock extends InteractiveDevice {

  private let m_enteringArea: ref<TriggerComponent>;

  private let m_centeredArea: ref<TriggerComponent>;

  private let m_leavingArea: ref<TriggerComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"enteringArea", n"gameStaticTriggerAreaComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"centeredArea", n"gameStaticTriggerAreaComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"leavingArea", n"gameStaticTriggerAreaComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_enteringArea = EntityResolveComponentsInterface.GetComponent(ri, n"enteringArea") as TriggerComponent;
    this.m_centeredArea = EntityResolveComponentsInterface.GetComponent(ri, n"centeredArea") as TriggerComponent;
    this.m_leavingArea = EntityResolveComponentsInterface.GetComponent(ri, n"leavingArea") as TriggerComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as SecurityGateLockController;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    (this.GetDevicePS() as SecurityGateLockControllerPS).UpdateTrespassersList(evt, true);
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool {
    (this.GetDevicePS() as SecurityGateLockControllerPS).UpdateTrespassersList(evt, false);
  }

  protected cb func OnUpdateGatePosition(evt: ref<UpdateGatePosition>) -> Bool {
    this.UpdateGatePosition();
  }

  private final func UpdateGatePosition() -> Void {
    let animationName: CName;
    let playEvent: ref<gameTransformAnimationPlayEvent> = new gameTransformAnimationPlayEvent();
    if (this.GetDevicePS() as SecurityGateLockControllerPS).IsLocked() {
      animationName = n"lock";
    } else {
      animationName = n"unlock";
    };
    playEvent.timeScale = 1.00;
    playEvent.looping = false;
    playEvent.timesPlayed = 1u;
    playEvent.animationName = animationName;
    this.QueueEvent(playEvent);
  }
}
