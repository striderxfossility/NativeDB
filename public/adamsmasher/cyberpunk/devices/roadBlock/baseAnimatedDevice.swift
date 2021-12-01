
public class BaseAnimatedDevice extends InteractiveDevice {

  @attrib(category, "AnimationSetup")
  @default(BaseAnimatedDevice, 2.0f)
  public let m_openingSpeed: Float;

  @attrib(category, "AnimationSetup")
  @default(BaseAnimatedDevice, 2.0f)
  public let m_closingSpeed: Float;

  protected let m_animationController: ref<AnimationControllerComponent>;

  protected let m_animFeature: ref<AnimFeature_RoadBlock>;

  protected edit let m_animationType: EAnimationType;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"animController", n"AnimationControllerComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_animationController = EntityResolveComponentsInterface.GetComponent(ri, n"animController") as AnimationControllerComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as BaseAnimatedDeviceController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    if Equals(this.m_animationType, EAnimationType.REGULAR) {
      this.m_animFeature = new AnimFeature_RoadBlock();
      this.m_animFeature.initOpen = (this.GetDevicePS() as BaseAnimatedDeviceControllerPS).IsActive();
    };
    this.ToggleState();
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnQuickHackToggleActivate(evt: ref<QuickHackToggleActivate>) -> Bool {
    this.ToggleState();
    this.UpdateDeviceState();
  }

  protected cb func OnActivateDevice(evt: ref<ActivateDevice>) -> Bool {
    this.ToggleState();
    this.UpdateDeviceState();
  }

  protected cb func OnDeactivateDevice(evt: ref<DeactivateDevice>) -> Bool {
    this.ToggleState();
    this.UpdateDeviceState();
  }

  protected func DeactivateDevice() -> Void {
    this.DeactivateDevice();
    this.m_animationController.Toggle(false);
  }

  protected func ActivateDevice() -> Void {
    this.ActivateDevice();
    this.m_animationController.Toggle(true);
  }

  protected func ToggleState() -> Void {
    if Equals(this.m_animationType, EAnimationType.REGULAR) {
      this.Animate();
    } else {
      if Equals(this.m_animationType, EAnimationType.TRANSFORM) {
        this.TransformAnimate();
      };
    };
  }

  protected func Animate() -> Void {
    if (this.GetDevicePS() as BaseAnimatedDeviceControllerPS).IsActive() {
      this.m_animFeature.isOpening = true;
      this.m_animFeature.duration = this.m_openingSpeed;
    } else {
      this.m_animFeature.isOpening = false;
      this.m_animFeature.duration = this.m_closingSpeed;
    };
    AnimationControllerComponent.ApplyFeature(this, n"Road_block", this.m_animFeature);
  }

  protected func TransformAnimate() -> Void {
    let playEvent: ref<gameTransformAnimationPlayEvent> = new gameTransformAnimationPlayEvent();
    playEvent.looping = false;
    playEvent.timesPlayed = 1u;
    if (this.GetDevicePS() as BaseAnimatedDeviceControllerPS).Randomize() {
      playEvent.timeScale = RandRangeF(0.80, 1.20);
    } else {
      playEvent.timeScale = 1.00;
    };
    if (this.GetDevicePS() as BaseAnimatedDeviceControllerPS).IsNotActive() {
      playEvent.animationName = n"closing";
    } else {
      playEvent.animationName = n"opening";
    };
    this.QueueEvent(playEvent);
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.ClearPath;
  }
}
