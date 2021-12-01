
public class Fan extends BasicDistractionDevice {

  public let m_animationType: EAnimationType;

  @default(Fan, true)
  public let m_rotateClockwise: Bool;

  @default(Fan, false)
  public let m_randomizeBladesSpeed: Bool;

  @default(Fan, 150.f)
  public let m_maxRotationSpeed: Float;

  @default(Fan, 3.f)
  public let m_timeToMaxRotation: Float;

  private let m_animFeature: ref<AnimFeature_RotatingObject>;

  private let m_updateComp: ref<UpdateComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"update", n"UpdateComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"anim", n"AnimatedComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_updateComp = EntityResolveComponentsInterface.GetComponent(ri, n"update") as UpdateComponent;
    super.OnTakeControl(ri);
    this.m_animFeature = new AnimFeature_RotatingObject();
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as FanController;
  }

  protected cb func OnDeviceVisible(evt: ref<gameDeviceVisibilityChangedEvent>) -> Bool {
    super.OnDeviceVisible(evt);
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    this.m_animFeature.rotateClockwise = this.m_rotateClockwise;
    this.m_animFeature.maxRotationSpeed = this.m_maxRotationSpeed;
    this.m_animFeature.timeToMaxRotation = this.m_timeToMaxRotation;
    this.m_animFeature.randomizeBladesRotation = this.m_randomizeBladesSpeed;
    AnimationControllerComponent.ApplyFeature(this, n"rotation", this.m_animFeature);
  }

  public func ResavePersistentData(ps: ref<PersistentState>) -> Bool {
    let fanData: FanResaveData;
    let psDevice: ref<FanControllerPS>;
    this.ResavePersistentData(ps);
    psDevice = ps as FanControllerPS;
    fanData.m_animationType = this.m_animationType;
    fanData.m_rotateClockwise = this.m_rotateClockwise;
    fanData.m_randomizeBladesSpeed = this.m_randomizeBladesSpeed;
    fanData.m_maxRotationSpeed = this.m_maxRotationSpeed;
    fanData.m_timeToMaxRotation = this.m_timeToMaxRotation;
    psDevice.PushResaveData(fanData);
    return true;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func CutPower() -> Void {
    this.StopFan();
  }

  protected func TurnOnDevice() -> Void {
    this.StartFan();
  }

  protected func TurnOffDevice() -> Void {
    this.StopFan();
  }

  private final func StartFan() -> Void {
    if Equals((this.GetDevicePS() as FanControllerPS).GetAnimationType(), EAnimationType.REGULAR) {
      this.PlayRegularAnimation();
    } else {
      if Equals((this.GetDevicePS() as FanControllerPS).GetAnimationType(), EAnimationType.TRANSFORM) {
        this.PLayTransformAnimation();
      };
    };
  }

  private final func StopFan() -> Void {
    if Equals((this.GetDevicePS() as FanControllerPS).GetAnimationType(), EAnimationType.REGULAR) {
      this.StopRegularAnimation();
    } else {
      if Equals((this.GetDevicePS() as FanControllerPS).GetAnimationType(), EAnimationType.TRANSFORM) {
        this.StopTransformAnimation();
      };
    };
  }

  private final func PLayTransformAnimation() -> Void {
    let playEvent: ref<gameTransformAnimationPlayEvent> = new gameTransformAnimationPlayEvent();
    playEvent.animationName = n"SPIN";
    playEvent.looping = true;
    playEvent.timesPlayed = 1u;
    if !(this.GetDevicePS() as FanControllerPS).IsRotatingClockwise() {
      playEvent.timeScale = -1.00;
    } else {
      playEvent.timeScale = 1.00;
    };
    this.QueueEvent(playEvent);
  }

  private final func StopTransformAnimation() -> Void {
    let stopEvent: ref<gameTransformAnimationPauseEvent> = new gameTransformAnimationPauseEvent();
    stopEvent.animationName = n"SPIN";
    this.QueueEvent(stopEvent);
  }

  private final func PlayRegularAnimation() -> Void {
    this.m_animFeature.rotateClockwise = (this.GetDevicePS() as FanControllerPS).IsRotatingClockwise();
    this.m_animFeature.maxRotationSpeed = (this.GetDevicePS() as FanControllerPS).GetMaxRotationSpeed();
    this.m_animFeature.timeToMaxRotation = (this.GetDevicePS() as FanControllerPS).GetTimeToMaxRotation();
    this.m_animFeature.randomizeBladesRotation = (this.GetDevicePS() as FanControllerPS).IsBladesSpeedRandomized();
    AnimationControllerComponent.ApplyFeature(this, n"rotation", this.m_animFeature);
  }

  private final func StopRegularAnimation() -> Void {
    this.m_animFeature.rotateClockwise = false;
    this.m_animFeature.maxRotationSpeed = 0.00;
    this.m_animFeature.timeToMaxRotation = 0.00;
    this.m_animFeature.randomizeBladesRotation = false;
    AnimationControllerComponent.ApplyFeature(this, n"rotation", this.m_animFeature);
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let TDBid: TweakDBID;
    if this.GetDevicePS().IsON() {
      TDBid = t"Attacks.FanBlades";
      if TDBID.IsValid(TDBid) {
        this.DoAttack(TDBid);
      };
    };
  }

  private final func DoAttack(damageType: TweakDBID) -> Void {
    let attack: ref<Attack_GameEffect>;
    let flag: SHitFlag;
    let hitFlags: array<SHitFlag>;
    flag.flag = hitFlag.FriendlyFire;
    flag.source = n"FanDevice";
    ArrayPush(hitFlags, flag);
    attack = RPGManager.PrepareGameEffectAttack(this.GetGame(), this, this, damageType, hitFlags);
    if IsDefined(attack) {
      attack.StartAttack();
    };
  }
}
