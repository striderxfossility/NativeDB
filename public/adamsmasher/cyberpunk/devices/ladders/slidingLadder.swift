
public class SlidingLadder extends BaseAnimatedDevice {

  protected let m_offMeshConnectionDown: ref<OffMeshConnectionComponent>;

  protected let m_offMeshConnectionUp: ref<OffMeshConnectionComponent>;

  protected let m_ladderInteraction: ref<InteractionComponent>;

  private let m_wasShot: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"offMeshConnection_up", n"OffMeshConnectionComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"offMeshConnection_down", n"OffMeshConnectionComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"entrances", n"gameinteractionsComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_offMeshConnectionUp = EntityResolveComponentsInterface.GetComponent(ri, n"offMeshConnection_up") as OffMeshConnectionComponent;
    this.m_offMeshConnectionDown = EntityResolveComponentsInterface.GetComponent(ri, n"offMeshConnection_down") as OffMeshConnectionComponent;
    this.m_ladderInteraction = EntityResolveComponentsInterface.GetComponent(ri, n"entrances") as InteractionComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as SlidingLadderController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    this.ToggleLadder();
  }

  protected cb func OnHitEvent(hit: ref<gameHitEvent>) -> Bool {
    if (this.GetDevicePS() as SlidingLadderControllerPS).IsShootable() && (this.GetDevicePS() as SlidingLadderControllerPS).IsNotActive() {
      super.OnHitEvent(hit);
      this.m_wasShot = true;
      (this.GetDevicePS() as SlidingLadderControllerPS).SetActive();
      this.ToggleState();
    };
  }

  protected cb func OnDelayEvent(evt: ref<DelayEvent>) -> Bool {
    this.ToggleLadder();
    this.RefreshInteraction(gamedeviceRequestType.Direct, GetPlayer(this.GetGame()));
    if this.m_wasShot {
      this.m_wasShot = false;
      this.GetDevicePS().GetDeviceOperationsContainer().Execute(n"DealDamage", this);
    };
  }

  protected func TransformAnimate() -> Void {
    let playEvent: ref<gameTransformAnimationPlayEvent> = new gameTransformAnimationPlayEvent();
    playEvent.looping = false;
    playEvent.timesPlayed = 1u;
    playEvent.timeScale = 1.00;
    let delayEvent: ref<DelayEvent> = new DelayEvent();
    if this.m_wasShot {
      playEvent.timeScale = 3.00;
    };
    if (this.GetDevicePS() as SlidingLadderControllerPS).IsNotActive() {
      playEvent.animationName = n"closing";
    } else {
      playEvent.animationName = n"opening";
    };
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, delayEvent, (this.GetDevicePS() as SlidingLadderControllerPS).GetAnimTime() / playEvent.timeScale);
    this.QueueEvent(playEvent);
  }

  protected func Animate() -> Void {
    let delayEvent: ref<DelayEvent>;
    if (this.GetDevicePS() as SlidingLadderControllerPS).IsActive() {
      AnimationControllerComponent.SetInputBool(this, n"expand", true);
      delayEvent = new DelayEvent();
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, delayEvent, (this.GetDevicePS() as SlidingLadderControllerPS).GetAnimTime());
    } else {
      AnimationControllerComponent.SetInputBool(this, n"expand", false);
    };
  }

  protected final func ToggleLadder() -> Void {
    if IsDefined(this.m_offMeshConnectionUp) && IsDefined(this.m_ladderInteraction) {
      if (this.GetDevicePS() as SlidingLadderControllerPS).IsActive() {
        this.m_offMeshConnectionUp.EnableOffMeshConnection();
        this.m_offMeshConnectionUp.EnableForPlayer();
        this.m_offMeshConnectionDown.EnableOffMeshConnection();
        this.m_offMeshConnectionDown.EnableForPlayer();
        this.m_ladderInteraction.Toggle(true);
      } else {
        this.m_offMeshConnectionUp.DisableOffMeshConnection();
        this.m_offMeshConnectionUp.DisableForPlayer();
        this.m_offMeshConnectionDown.DisableOffMeshConnection();
        this.m_offMeshConnectionDown.DisableForPlayer();
        this.m_ladderInteraction.Toggle(false);
      };
    };
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.ClearPath;
  }
}
