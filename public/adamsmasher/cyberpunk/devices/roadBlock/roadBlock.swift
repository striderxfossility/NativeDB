
public class RoadBlock extends InteractiveDevice {

  @attrib(category, "AnimationSetup")
  @default(RoadBlock, 2.0f)
  public let m_openingSpeed: Float;

  protected let m_animationController: ref<AnimationControllerComponent>;

  protected let m_offMeshConnection: ref<OffMeshConnectionComponent>;

  private let m_animFeature: ref<AnimFeature_RoadBlock>;

  protected edit let m_animationType: EAnimationType;

  protected let m_forceEnableLink: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"animController", n"AnimationControllerComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"offMeshConnection", n"OffMeshConnectionComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_animationController = EntityResolveComponentsInterface.GetComponent(ri, n"animController") as AnimationControllerComponent;
    this.m_offMeshConnection = EntityResolveComponentsInterface.GetComponent(ri, n"offMeshConnection") as OffMeshConnectionComponent;
    if !IsDefined(this.m_animationController) {
      LogError("AnimationControllerComponent is missing from the road block entity.");
    };
    if !IsDefined(this.m_offMeshConnection) {
      LogError("OffMeshConnectionComponent is missing from the road block entity.");
    };
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as RoadBlockController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    this.m_animFeature = new AnimFeature_RoadBlock();
    this.m_animFeature.initOpen = (this.GetDevicePS() as RoadBlockControllerPS).IsBlocking() ^ (this.GetDevicePS() as RoadBlockControllerPS).NegateAnim();
    this.ToggleBlockade(true);
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnToggleBlockade(evt: ref<ToggleBlockade>) -> Bool {
    this.ToggleBlockade(false);
    this.UpdateDeviceState();
  }

  protected cb func OnQuickHackToggleBlockade(evt: ref<QuickHackToggleBlockade>) -> Bool {
    this.ToggleBlockade(false);
    this.UpdateDeviceState();
  }

  protected cb func OnQuestForceRoadBlockadeActivate(evt: ref<QuestForceRoadBlockadeActivate>) -> Bool {
    this.ToggleBlockade(false);
    this.UpdateDeviceState();
  }

  protected cb func OnQuestForceRoadBlockadeDeactivate(evt: ref<QuestForceRoadBlockadeDeactivate>) -> Bool {
    this.ToggleBlockade(false);
    this.UpdateDeviceState();
  }

  protected cb func OnActivateDevice(evt: ref<ActivateDevice>) -> Bool {
    this.ToggleBlockade(false);
  }

  protected cb func OnDeactivateDevice(evt: ref<DeactivateDevice>) -> Bool {
    this.ToggleBlockade(false);
  }

  protected cb func OnPhysicalDestructionEvent(evt: ref<PhysicalDestructionEvent>) -> Bool {
    this.ToggleOffMeshConnection(true);
    this.m_forceEnableLink = true;
  }

  protected func DeactivateDevice() -> Void {
    this.DeactivateDevice();
    this.m_animationController.Toggle(false);
  }

  protected func ActivateDevice() -> Void {
    this.ActivateDevice();
    if IsDefined(this.m_animationController) {
      this.m_animationController.Toggle(true);
    };
  }

  protected final func ToggleBlockade(immediate: Bool) -> Void {
    if Equals(this.m_animationType, EAnimationType.REGULAR) {
      this.Animate(immediate);
    } else {
      if Equals(this.m_animationType, EAnimationType.TRANSFORM) {
        this.TransformAnimate(immediate);
      };
    };
  }

  protected final func Animate(immediate: Bool) -> Void {
    if (this.GetDevicePS() as RoadBlockControllerPS).IsBlocking() {
      this.m_animFeature.isOpening = !(this.GetDevicePS() as RoadBlockControllerPS).NegateAnim();
      this.m_animFeature.duration = this.m_openingSpeed;
      this.ToggleOffMeshConnection(false);
    } else {
      this.m_animFeature.isOpening = (this.GetDevicePS() as RoadBlockControllerPS).NegateAnim();
      this.m_animFeature.duration = this.m_openingSpeed;
      this.ToggleOffMeshConnection(true);
    };
    if immediate {
      this.m_animFeature.duration /= 1000.00;
    };
    AnimationControllerComponent.ApplyFeature(this, n"Road_block", this.m_animFeature);
  }

  protected final func TransformAnimate(immediate: Bool) -> Void {
    let skipEvent: ref<gameTransformAnimationSkipEvent>;
    let playEvent: ref<gameTransformAnimationPlayEvent> = new gameTransformAnimationPlayEvent();
    playEvent.looping = false;
    playEvent.timesPlayed = 1u;
    playEvent.timeScale = 1.00;
    if (this.GetDevicePS() as RoadBlockControllerPS).IsNotBlocking() {
      playEvent.animationName = n"closing";
      this.ToggleOffMeshConnection(true);
    } else {
      playEvent.animationName = n"opening";
      this.ToggleOffMeshConnection(false);
    };
    this.QueueEvent(playEvent);
    if immediate {
      skipEvent = new gameTransformAnimationSkipEvent();
      skipEvent.skipToEnd = true;
      skipEvent.animationName = playEvent.animationName;
      this.QueueEvent(skipEvent);
    };
  }

  protected final func ToggleOffMeshConnection(toggle: Bool) -> Void {
    if IsDefined(this.m_offMeshConnection) && !this.m_forceEnableLink {
      if toggle {
        this.m_offMeshConnection.EnableOffMeshConnection();
        this.m_offMeshConnection.EnableForPlayer();
      } else {
        this.m_offMeshConnection.DisableOffMeshConnection();
        this.m_offMeshConnection.DisableForPlayer();
      };
    };
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.ClearPath;
  }
}
