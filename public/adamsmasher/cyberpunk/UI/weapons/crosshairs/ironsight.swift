
public class IronsightDetail extends IScriptable {

  public final static func PlaybackCycleInfinite() -> inkAnimOptions {
    let playbackOptions: inkAnimOptions;
    playbackOptions.loopInfinite = true;
    playbackOptions.loopType = inkanimLoopType.Cycle;
    return playbackOptions;
  }

  public final static func PlaybackCycleOnce() -> inkAnimOptions {
    let playbackOptions: inkAnimOptions;
    playbackOptions.loopInfinite = false;
    playbackOptions.loopType = IntEnum(0l);
    return playbackOptions;
  }

  public final static func Fmodf(a: Float, b: Float) -> Float {
    if b == 0.00 {
      return 0.00;
    };
    return a - Cast(FloorF(a / b)) * b;
  }

  public final static func SetSlide(widget: inkWidgetRef, startPosition: Vector2, horizontal: Float, vertical: Float) -> Void {
    let translation: Vector2;
    let widgetSize: Vector2;
    if !inkWidgetRef.IsValid(widget) {
      return;
    };
    widgetSize = inkWidgetRef.GetSize(widget);
    translation.X = startPosition.X + horizontal * widgetSize.X;
    translation.Y = startPosition.Y + vertical * widgetSize.Y;
    inkWidgetRef.SetTranslation(widget, translation);
  }

  public final static func Pitch(forward: Vector4) -> Float {
    return Rad2Deg(AtanF(SqrtF(forward.Y * forward.Y + forward.X * forward.X), forward.Z));
  }
}

public class ChargebarStatsListener extends ScriptStatsListener {

  private let m_controller: wref<ChargebarController>;

  public final func Init(controller: ref<ChargebarController>, stat: gamedataStatType) -> Void {
    this.m_controller = controller;
    this.SetStatType(stat);
  }

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void {
    this.m_controller.OnStatChanged(ownerID, statType, diff, total);
  }
}

public class ChargebarController extends inkLogicController {

  protected edit let m_foreground: inkWidgetRef;

  protected edit let m_midground: inkWidgetRef;

  protected edit let m_background: inkWidgetRef;

  protected edit let m_maxChargeAnimationName: CName;

  protected let m_animationMaxCharge: ref<inkAnimProxy>;

  protected let m_statsSystem: ref<StatsSystem>;

  protected let m_canFullyCharge: Bool;

  protected let m_canOvercharge: Bool;

  protected let m_listenerFullCharge: ref<ChargebarStatsListener>;

  protected let m_listenerOvercharge: ref<ChargebarStatsListener>;

  public final func OnPlayerAttach(player: ref<GameObject>) -> Void {
    this.m_statsSystem = GameInstance.GetStatsSystem(player.GetGame());
    this.m_canFullyCharge = this.m_statsSystem.GetStatBoolValue(Cast(player.GetEntityID()), gamedataStatType.CanFullyChargeWeapon);
    this.m_canOvercharge = this.m_statsSystem.GetStatBoolValue(Cast(player.GetEntityID()), gamedataStatType.CanOverchargeWeapon);
    this.m_listenerFullCharge = new ChargebarStatsListener();
    this.m_listenerFullCharge.Init(this, gamedataStatType.CanFullyChargeWeapon);
    this.m_listenerOvercharge = new ChargebarStatsListener();
    this.m_listenerOvercharge.Init(this, gamedataStatType.CanOverchargeWeapon);
    this.OnChargeValueChanged(0.00);
  }

  public final func OnPlayerDetach(player: ref<GameObject>) -> Void {
    this.m_listenerFullCharge = null;
    this.m_listenerOvercharge = null;
  }

  public final func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void {
    switch statType {
      case gamedataStatType.CanFullyChargeWeapon:
        this.m_canFullyCharge = total > 0.00;
        break;
      case gamedataStatType.CanOverchargeWeapon:
        this.m_canOvercharge = total > 0.00;
    };
  }

  public final func OnTriggerModeChanged(value: Variant) -> Void {
    let record: ref<TriggerMode_Record> = FromVariant(value);
    let isVisible: Bool = Equals(gamedataTriggerMode.Charge, record.Type());
    inkWidgetRef.SetVisible(this.m_foreground, isVisible);
    inkWidgetRef.SetVisible(this.m_midground, isVisible);
    inkWidgetRef.SetVisible(this.m_background, isVisible);
  }

  public final func OnChargeValueChanged(value: Float) -> Void {
    let threshold: Float = this.GetCurrentChargeLimit();
    this.SetBarsSize(value, threshold);
    this.EvalChargeAnimation(value, threshold);
  }

  protected final func GetCurrentChargeLimit() -> Float {
    if this.m_canOvercharge {
      return WeaponObject.GetOverchargeThreshold();
    };
    if this.m_canFullyCharge {
      return WeaponObject.GetFullyChargedThreshold();
    };
    return WeaponObject.GetBaseMaxChargeThreshold();
  }

  protected final func SetBarsSize(value: Float, threshold: Float) -> Void {
    inkWidgetRef.SetVisible(this.m_foreground, value > 0.00);
    inkWidgetRef.SetScale(this.m_foreground, new Vector2(value / threshold, 1.00));
    inkWidgetRef.SetVisible(this.m_midground, value > 0.00);
    inkWidgetRef.SetScale(this.m_midground, new Vector2(WeaponObject.GetFullyChargedThreshold() / threshold, 1.00));
    inkWidgetRef.SetVisible(this.m_background, value > 0.00);
    inkWidgetRef.SetScale(this.m_background, new Vector2(WeaponObject.GetBaseMaxChargeThreshold() / threshold, 1.00));
  }

  protected final func EvalChargeAnimation(value: Float, threshold: Float) -> Void {
    if value >= threshold {
      if !IsDefined(this.m_animationMaxCharge) {
        this.m_animationMaxCharge = this.PlayLibraryAnimation(this.m_maxChargeAnimationName, IronsightDetail.PlaybackCycleInfinite());
      };
    } else {
      if IsDefined(this.m_animationMaxCharge) {
        this.m_animationMaxCharge.Stop();
        this.m_animationMaxCharge = null;
      };
    };
  }
}

public class AltimeterController extends inkLogicController {

  private edit let m_faceUp: inkWidgetRef;

  private edit let m_faceDown: inkWidgetRef;

  private edit let m_textWidget: inkTextRef;

  @default(AltimeterController, 2)
  private edit let m_decimalPrecision: Uint32;

  private let m_faceUpStartPosition: Vector2;

  private let m_faceDownStartPosition: Vector2;

  private let m_playerPuppet: wref<GameObject>;

  @default(AltimeterController, 2.0f)
  private edit let m_warpDistance: Float;

  private let m_alitimeterValue: Float;

  private let m_precisionEpsilon: Float;

  public final func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Void {
    this.m_playerPuppet = playerPuppet;
    this.m_precisionEpsilon = PowF(10.00, -Cast(this.m_decimalPrecision));
  }

  public final func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Void {
    this.m_playerPuppet = null;
  }

  protected cb func OnUpdate() -> Bool {
    this.Update();
  }

  public final func Update() -> Void {
    let valueVertical: Float;
    let worldPosition: Vector4;
    if !IsDefined(this.m_playerPuppet) {
      return;
    };
    worldPosition = this.m_playerPuppet.GetWorldPosition();
    valueVertical = IronsightDetail.Fmodf(worldPosition.Z / this.m_warpDistance, 0.50);
    IronsightDetail.SetSlide(this.m_faceUp, this.m_faceUpStartPosition, 0.00, valueVertical);
    IronsightDetail.SetSlide(this.m_faceDown, this.m_faceDownStartPosition, 0.00, valueVertical);
    if AbsF(worldPosition.Z - this.m_alitimeterValue) > this.m_precisionEpsilon && inkWidgetRef.IsValid(this.m_textWidget) {
      inkTextRef.SetText(this.m_textWidget, FloatToStringPrec(worldPosition.Z, Cast(this.m_decimalPrecision)));
      this.m_alitimeterValue = worldPosition.Z;
    };
  }
}

public class AnimationChain extends IScriptable {

  public let m_data: array<AnimationElement>;

  public let m_name: CName;

  public final func AddAnimation(name: CName, options: inkAnimOptions) -> Void {
    let element: AnimationElement;
    element.m_animation = name;
    element.m_animOptions = options;
    ArrayPush(this.m_data, element);
  }
}

public class AnimationChainPlayer extends IScriptable {

  public let m_animationProxy: ref<inkAnimProxy>;

  public let m_current: ref<AnimationChain>;

  public let m_current_stage: Int32;

  public let m_next: ref<AnimationChain>;

  public let m_owner: wref<inkLogicController>;

  public final func Play(animationChain: ref<AnimationChain>) -> Void {
    if IsDefined(this.m_current) && ArraySize(this.m_current.m_data) > 0 {
      this.m_next = animationChain;
      return;
    };
    this.BeginAnimation(animationChain);
  }

  public final func PlayNow(animationChain: ref<AnimationChain>) -> Void {
    this.Clean();
    this.BeginAnimation(animationChain);
    if IsDefined(this.m_next) {
      ArrayClear(this.m_next.m_data);
      this.m_next.m_name = n"";
    };
  }

  private final func BeginAnimation(animationChain: ref<AnimationChain>) -> Void {
    this.m_current = animationChain;
    this.PlayAnimationStage(0);
  }

  private final func PlayAnimationStage(stage: Int32) -> Void {
    this.m_animationProxy = this.m_owner.PlayLibraryAnimation(this.m_current.m_data[stage].m_animation, this.m_current.m_data[stage].m_animOptions);
    this.m_current_stage = stage;
    if IsDefined(this.m_animationProxy) {
      this.m_animationProxy.RegisterToCallback(this.GetEndEvent(this.m_current.m_data[stage].m_animOptions), this, n"OnNextAnimation");
    } else {
      if ArraySize(this.m_current.m_data) > stage {
        this.OnNextAnimation();
      };
    };
  }

  protected cb func OnNextAnimation(opt anim: ref<inkAnimProxy>) -> Bool {
    if IsDefined(this.m_next) && ArraySize(this.m_next.m_data) > 0 && NotEquals(this.m_next.m_name, this.m_current.m_name) {
      this.HandleInteruption();
    } else {
      if !this.m_current.m_data[this.m_current_stage].m_animOptions.loopInfinite {
        this.Clean();
        if this.m_current_stage + 1 == ArraySize(this.m_current.m_data) {
          ArrayClear(this.m_current.m_data);
        } else {
          this.PlayAnimationStage(this.m_current_stage + 1);
        };
      };
    };
  }

  private final func HandleInteruption() -> Void {
    this.Clean();
    this.BeginAnimation(this.m_next);
  }

  private final func Clean() -> Void {
    if IsDefined(this.m_animationProxy) {
      this.m_animationProxy.UnregisterFromAllCallbacks(this.GetEndEvent(this.m_current.m_data[this.m_current_stage].m_animOptions));
      this.m_animationProxy.Stop();
      this.m_animationProxy = null;
    };
  }

  private final func GetEndEvent(animOptions: inkAnimOptions) -> inkanimEventType {
    return animOptions.loopInfinite ? inkanimEventType.OnEndLoop : inkanimEventType.OnFinish;
  }
}

public class BasicAnimationController extends inkLogicController {

  protected edit let m_showAnimation: CName;

  protected edit let m_idleAnimation: CName;

  protected edit let m_hideAnimation: CName;

  protected let m_animationPlayer: ref<AnimationChainPlayer>;

  protected let m_currentAnimation: CName;

  protected cb func OnInitialize() -> Bool {
    this.m_animationPlayer = new AnimationChainPlayer();
    this.m_animationPlayer.m_owner = this;
  }

  public final func PlayShow(opt immediately: Bool) -> Void {
    let animations: ref<AnimationChain> = new AnimationChain();
    animations.m_name = n"Show";
    animations.AddAnimation(this.m_showAnimation, IronsightDetail.PlaybackCycleOnce());
    animations.AddAnimation(this.m_idleAnimation, IronsightDetail.PlaybackCycleInfinite());
    if immediately {
      this.m_animationPlayer.PlayNow(animations);
    } else {
      this.m_animationPlayer.Play(animations);
    };
  }

  public final func PlayHide(opt immediately: Bool) -> Void {
    let animations: ref<AnimationChain> = new AnimationChain();
    animations.m_name = n"Hide";
    animations.AddAnimation(this.m_hideAnimation, IronsightDetail.PlaybackCycleOnce());
    if immediately {
      this.m_animationPlayer.PlayNow(animations);
    } else {
      this.m_animationPlayer.Play(animations);
    };
  }
}

public class TargetAttitudeAnimationController extends BasicAnimationController {

  private edit let m_hostileShowAnimation: CName;

  private edit let m_hostileIdleAnimation: CName;

  private edit let m_hostileHideAnimation: CName;

  @default(TargetAttitudeAnimationController, EAIAttitude.AIA_Neutral)
  private let m_attitude: EAIAttitude;

  public final func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Void {
    this.m_attitude = EAIAttitude.AIA_Neutral;
  }

  public final func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Void {
    this.m_attitude = EAIAttitude.AIA_Neutral;
  }

  public final func PlayShowHostile() -> Void {
    let animations: ref<AnimationChain> = new AnimationChain();
    animations.m_name = n"ShowH";
    animations.AddAnimation(this.m_hostileShowAnimation, IronsightDetail.PlaybackCycleOnce());
    animations.AddAnimation(this.m_hostileIdleAnimation, IronsightDetail.PlaybackCycleInfinite());
    this.m_animationPlayer.Play(animations);
  }

  private final func PlayHideHostile() -> Void {
    let animations: ref<AnimationChain> = new AnimationChain();
    animations.m_name = n"HideH";
    animations.AddAnimation(this.m_hostileHideAnimation, IronsightDetail.PlaybackCycleOnce());
    this.m_animationPlayer.Play(animations);
  }

  public final func PlayHideToHostile() -> Void {
    let animations: ref<AnimationChain> = new AnimationChain();
    animations.m_name = n"HideToF";
    animations.AddAnimation(this.m_hostileHideAnimation, IronsightDetail.PlaybackCycleOnce());
    animations.AddAnimation(this.m_showAnimation, IronsightDetail.PlaybackCycleOnce());
    animations.AddAnimation(this.m_idleAnimation, IronsightDetail.PlaybackCycleInfinite());
    this.m_animationPlayer.Play(animations);
  }

  public final func PlayHideToFriendly() -> Void {
    let animations: ref<AnimationChain> = new AnimationChain();
    animations.m_name = n"HideToH";
    animations.AddAnimation(this.m_hideAnimation, IronsightDetail.PlaybackCycleOnce());
    animations.AddAnimation(this.m_hostileShowAnimation, IronsightDetail.PlaybackCycleOnce());
    animations.AddAnimation(this.m_hostileIdleAnimation, IronsightDetail.PlaybackCycleInfinite());
    this.m_animationPlayer.Play(animations);
  }

  public final func OnAttitudeChanged(arg: Int32) -> Void {
    let previousAttitude: EAIAttitude;
    let attitude: EAIAttitude = IntEnum(arg);
    if Equals(attitude, this.m_attitude) {
      return;
    };
    previousAttitude = this.m_attitude;
    this.m_attitude = attitude;
    switch attitude {
      case EAIAttitude.AIA_Hostile:
        if Equals(previousAttitude, EAIAttitude.AIA_Friendly) {
          this.PlayHideToHostile();
        } else {
          this.PlayShowHostile();
        };
        break;
      case EAIAttitude.AIA_Friendly:
        if Equals(previousAttitude, EAIAttitude.AIA_Hostile) {
          this.PlayHideToFriendly();
        } else {
          this.PlayShow();
        };
        break;
      default:
        if Equals(previousAttitude, EAIAttitude.AIA_Friendly) {
          this.PlayHide();
        } else {
          if Equals(previousAttitude, EAIAttitude.AIA_Hostile) {
            this.PlayHideHostile();
          };
        };
    };
  }
}

public class AimDownSightController extends BasicAnimationController {

  @default(AimDownSightController, false)
  private let m_isAiming: Bool;

  public final func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Void {
    this.m_isAiming = false;
  }

  public final func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Void {
    this.m_isAiming = false;
  }

  public final func OnAim(isAiming: Bool) -> Void {
    if Equals(isAiming, this.m_isAiming) {
      return;
    };
    this.m_isAiming = isAiming;
    if this.m_isAiming {
      this.PlayShow(true);
    } else {
      this.PlayHide(true);
    };
  }
}

public class CompassController extends inkLogicController {

  private edit let m_faceLeft: inkWidgetRef;

  private edit let m_faceRight: inkWidgetRef;

  private edit let m_textWidget: inkTextRef;

  @default(CompassController, 2)
  private edit let m_decimalPrecision: Uint32;

  private let m_faceRightStartPosition: Vector2;

  private let m_faceLeftStartPosition: Vector2;

  @default(CompassController, false)
  private edit let m_isVertical: Bool;

  private let m_valueFloat: Float;

  private let m_playerPuppet: wref<GameObject>;

  private let m_precisionEpsilon: Float;

  public final func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Void {
    this.m_playerPuppet = playerPuppet;
    this.m_precisionEpsilon = PowF(10.00, -Cast(this.m_decimalPrecision));
  }

  public final func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Void {
    this.m_playerPuppet = null;
  }

  public final func Update() -> Void {
    let cameraForward: Vector4;
    let valueFloat: Float;
    let valueHorizontal: Float;
    let valueVertical: Float;
    if !IsDefined(this.m_playerPuppet) {
      return;
    };
    if this.m_isVertical {
      cameraForward = Matrix.GetDirectionVector((this.m_playerPuppet as PlayerPuppet).GetFPPCameraComponent().GetLocalToWorld());
      valueHorizontal = 0.00;
      valueFloat = 90.00 - IronsightDetail.Pitch(cameraForward);
      valueVertical = valueFloat / 180.00;
    } else {
      valueVertical = 0.00;
      valueHorizontal = this.m_playerPuppet.GetWorldYaw() / 360.00;
      valueFloat = this.m_playerPuppet.GetWorldYaw() + 180.00;
    };
    IronsightDetail.SetSlide(this.m_faceLeft, this.m_faceLeftStartPosition, valueHorizontal, valueVertical);
    IronsightDetail.SetSlide(this.m_faceRight, this.m_faceRightStartPosition, valueHorizontal, valueVertical);
    if AbsF(valueFloat - this.m_valueFloat) > this.m_precisionEpsilon && inkWidgetRef.IsValid(this.m_textWidget) {
      inkTextRef.SetText(this.m_textWidget, FloatToStringPrec(valueFloat, Cast(this.m_decimalPrecision)));
      this.m_valueFloat = valueFloat;
    };
  }
}

public class IronsightTargetHealthChangeListener extends ScriptStatPoolsListener {

  private let m_parentIronsight: wref<IronsightGameController>;

  public final static func Create(parentIronsight: ref<IronsightGameController>) -> ref<IronsightTargetHealthChangeListener> {
    let instance: ref<IronsightTargetHealthChangeListener> = new IronsightTargetHealthChangeListener();
    instance.m_parentIronsight = parentIronsight;
    return instance;
  }

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    let healthEvent: ref<IronsightTargetHealthUpdateEvent>;
    if IsDefined(this.m_parentIronsight) {
      healthEvent = new IronsightTargetHealthUpdateEvent();
      this.m_parentIronsight.QueueEvent(healthEvent);
    };
  }
}

public class IronsightGameController extends gameuiIronsightGameController {

  private let m_playerPuppet: wref<GameObject>;

  private edit let m_dot: inkWidgetRef;

  private edit let m_ammo: inkTextRef;

  private edit let m_ammoSpareCount: inkTextRef;

  private edit let m_range: inkTextRef;

  private edit let m_seeThroughWalls: Bool;

  private edit let m_targetAttitudeFriendly: inkWidgetRef;

  private edit let m_targetAttitudeHostile: inkWidgetRef;

  private edit let m_targetAttitudeEnemyNonHostile: inkWidgetRef;

  private let m_weaponDataBB: wref<IBlackboard>;

  private edit let m_targetHitAnimationName: CName;

  private let m_targetHitAnimation: ref<inkAnimProxy>;

  private let m_weaponDataTargetHitBBID: ref<CallbackHandle>;

  private edit let m_shootAnimationName: CName;

  private let m_shootAnimation: ref<inkAnimProxy>;

  private let m_weaponDataShootBBID: ref<CallbackHandle>;

  @default(IronsightGameController, -1)
  protected let m_currentAmmo: Int32;

  private let m_animIntro: ref<inkAnimProxy>;

  private let m_animLoop: ref<inkAnimProxy>;

  private let m_animReload: ref<inkAnimProxy>;

  private let m_BufferedRosterData: ref<SlotDataHolder>;

  private let m_ActiveWeapon: SlotWeaponData;

  private let m_weaponItemData: InventoryItemData;

  private let m_InventoryManager: ref<InventoryDataManagerV2>;

  private let bb: wref<IBlackboard>;

  private let bbID: ref<CallbackHandle>;

  private let m_target: wref<GameObject>;

  private let m_targetBB: wref<IBlackboard>;

  private let m_targetRange: Float;

  private let m_targetRangeBBID: ref<CallbackHandle>;

  private let m_targetAttitudeBBID: ref<CallbackHandle>;

  private let m_targetAcquiredBBID: ref<CallbackHandle>;

  private let m_targetRangeObstructedBBID: ref<CallbackHandle>;

  private let m_targetAcquiredObstructedBBID: ref<CallbackHandle>;

  @default(IronsightGameController, 2)
  private edit let m_targetRangeDecimalPrecision: Uint32;

  private let m_targetAttitudeAnimator: wref<TargetAttitudeAnimationController>;

  private edit let m_targetAttitudeContainer: inkWidgetRef;

  private let m_targetHealthListener: ref<IronsightTargetHealthChangeListener>;

  private let m_compass: wref<CompassController>;

  private edit let m_compassContainer: inkWidgetRef;

  private let m_compass2: wref<CompassController>;

  private edit let m_compassContainer2: inkWidgetRef;

  private let m_altimeter: wref<AltimeterController>;

  private edit let m_altimeterContainer: inkWidgetRef;

  private let m_weaponBB: wref<IBlackboard>;

  private let m_chargebar: wref<ChargebarController>;

  private edit let m_chargebarContainer: inkWidgetRef;

  private let m_chargebarValueChanged: ref<CallbackHandle>;

  private let m_chargebarTriggerModeChanged: ref<CallbackHandle>;

  private edit let m_ADSContainer: inkWidgetRef;

  private let m_ADSAnimator: wref<AimDownSightController>;

  private let m_playerStateMachineBB: wref<IBlackboard>;

  private let m_playerStateMachineUpperBodyBBID: ref<CallbackHandle>;

  private let m_crosshairStateChanged: ref<CallbackHandle>;

  private let m_crosshairState: gamePSMCrosshairStates;

  private let m_isTargetEnemy: Bool;

  private let m_attitude: EAIAttitude;

  protected final func StopAnimation(anim: ref<inkAnimProxy>) -> Void {
    if IsDefined(anim) {
      anim.Stop();
    };
  }

  private final func ResetTargetData() -> Void {
    this.m_target = null;
    this.m_isTargetEnemy = false;
    this.OnTargetDistanceChanged(0.00);
    this.OnTargetAttitudeChanged(EnumInt(EAIAttitude.AIA_Neutral));
  }

  private final func RegisterTargetCallbacks(register: Bool) -> Void {
    if !IsDefined(this.m_target) || !IsDefined(this.m_targetHealthListener) || !IsDefined(this.m_playerPuppet) {
      return;
    };
    if register {
      GameInstance.GetStatPoolsSystem(this.m_playerPuppet.GetGame()).RequestRegisteringListener(Cast(this.m_target.GetEntityID()), gamedataStatPoolType.Health, this.m_targetHealthListener);
    } else {
      GameInstance.GetStatPoolsSystem(this.m_playerPuppet.GetGame()).RequestUnregisteringListener(Cast(this.m_target.GetEntityID()), gamedataStatPoolType.Health, this.m_targetHealthListener);
    };
  }

  protected final func UpdateTargetAttitudeVisibility() -> Void {
    if inkWidgetRef.IsValid(this.m_targetAttitudeFriendly) {
      inkWidgetRef.SetVisible(this.m_targetAttitudeFriendly, Equals(this.m_attitude, EAIAttitude.AIA_Friendly));
    };
    if inkWidgetRef.IsValid(this.m_targetAttitudeHostile) && inkWidgetRef.IsValid(this.m_targetAttitudeEnemyNonHostile) && this.m_targetAttitudeHostile == this.m_targetAttitudeEnemyNonHostile {
      inkWidgetRef.SetVisible(this.m_targetAttitudeHostile, Equals(this.m_attitude, EAIAttitude.AIA_Hostile) || this.m_isTargetEnemy);
    } else {
      if inkWidgetRef.IsValid(this.m_targetAttitudeHostile) {
        inkWidgetRef.SetVisible(this.m_targetAttitudeHostile, Equals(this.m_attitude, EAIAttitude.AIA_Hostile));
      };
      if inkWidgetRef.IsValid(this.m_targetAttitudeEnemyNonHostile) {
        inkWidgetRef.SetVisible(this.m_targetAttitudeEnemyNonHostile, this.m_isTargetEnemy && NotEquals(this.m_attitude, EAIAttitude.AIA_Hostile));
      };
    };
  }

  protected final func RefreshTargetDistance() -> Void {
    if inkWidgetRef.IsValid(this.m_range) {
      inkTextRef.SetText(this.m_range, IsDefined(this.m_target) ? FloatToStringPrec(this.m_targetRange, Cast(this.m_targetRangeDecimalPrecision)) : "---");
    };
  }

  private final func RefreshTargetHealth() -> Void {
    if !IsDefined(this.m_target) || IronsightGameController.IsDead(this.m_target) {
      this.ResetTargetData();
    };
  }

  private final static func IsDead(obj: ref<GameObject>) -> Bool {
    let puppet: ref<ScriptedPuppet> = obj as ScriptedPuppet;
    let device: ref<Device> = obj as Device;
    return IsDefined(puppet) && puppet.IsDead() || IsDefined(device) && device.GetDevicePS().IsBroken();
  }

  protected cb func OnIronsightTargetHealthUpdateEvent(evt: ref<IronsightTargetHealthUpdateEvent>) -> Bool {
    this.RefreshTargetHealth();
  }

  protected cb func OnTargetDistanceChanged(distance: Float) -> Bool {
    this.m_targetRange = distance;
    this.RefreshTargetDistance();
  }

  protected cb func OnTargetAcquired(targetID: EntityID) -> Bool {
    let puppet: ref<ScriptedPuppet>;
    let target: ref<GameObject>;
    this.RegisterTargetCallbacks(false);
    target = GameInstance.FindEntityByID(this.m_playerPuppet.GetGame(), targetID) as GameObject;
    if IsDefined(target) && !IronsightGameController.IsDead(target) {
      this.m_target = target;
      this.RegisterTargetCallbacks(true);
      this.RefreshTargetDistance();
      puppet = this.m_target as ScriptedPuppet;
      this.m_isTargetEnemy = IsDefined(puppet) && puppet.IsAggressive();
      this.UpdateTargetAttitudeVisibility();
    } else {
      this.ResetTargetData();
    };
  }

  protected cb func OnTargetAttitudeChanged(attitude: Int32) -> Bool {
    this.m_attitude = IntEnum(attitude);
    this.UpdateTargetAttitudeVisibility();
    if IsDefined(this.m_targetAttitudeAnimator) {
      this.m_targetAttitudeAnimator.OnAttitudeChanged(attitude);
    };
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let enableUpdate: Bool = false;
    this.m_playerPuppet = playerPuppet;
    let owner: ref<Entity> = this.GetOwnerEntity();
    let weaponObject: ref<WeaponObject> = owner as WeaponObject;
    this.m_weaponBB = weaponObject.GetSharedData();
    this.m_InventoryManager = new InventoryDataManagerV2();
    this.m_InventoryManager.Initialize(playerPuppet as PlayerPuppet);
    this.bb = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_EquipmentData);
    this.bbID = this.bb.RegisterListenerVariant(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData, this, n"OnWeaponDataChanged");
    this.m_targetBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_TargetingInfo);
    this.m_targetAttitudeBBID = this.m_targetBB.RegisterDelayedListenerInt(GetAllBlackboardDefs().UI_TargetingInfo.VisibleTargetAttitude, this, n"OnTargetAttitudeChanged");
    this.m_targetRangeBBID = this.m_targetBB.RegisterDelayedListenerFloat(GetAllBlackboardDefs().UI_TargetingInfo.VisibleTargetDistance, this, n"OnTargetDistanceChanged");
    this.m_targetAcquiredBBID = this.m_targetBB.RegisterDelayedListenerEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget, this, n"OnTargetAcquired");
    if this.m_seeThroughWalls {
      this.m_targetRangeObstructedBBID = this.m_targetBB.RegisterDelayedListenerFloat(GetAllBlackboardDefs().UI_TargetingInfo.ObstructedTargetDistance, this, n"OnTargetDistanceChanged");
      this.m_targetAcquiredObstructedBBID = this.m_targetBB.RegisterDelayedListenerEntityID(GetAllBlackboardDefs().UI_TargetingInfo.CurrentObstructedTarget, this, n"OnTargetAcquired");
    };
    this.m_weaponDataBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ActiveWeaponData);
    this.m_weaponDataTargetHitBBID = this.m_weaponDataBB.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_ActiveWeaponData.TargetHitEvent, this, n"OnTargetHit");
    this.m_weaponDataShootBBID = this.m_weaponDataBB.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_ActiveWeaponData.ShootEvent, this, n"OnShoot");
    this.ResetTargetData();
    inkTextRef.SetText(this.m_ammo, "");
    this.m_animIntro = this.PlayLibraryAnimation(n"intro", IronsightDetail.PlaybackCycleOnce());
    if IsDefined(this.m_animIntro) {
      this.m_animIntro.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationIntroFinished");
    } else {
      if IsDefined(this.m_targetAttitudeAnimator) {
        this.m_targetAttitudeAnimator.OnAttitudeChanged(this.m_targetBB.GetInt(GetAllBlackboardDefs().UI_TargetingInfo.VisibleTargetAttitude));
      };
    };
    this.m_animLoop = this.PlayLibraryAnimation(n"loop", IronsightDetail.PlaybackCycleInfinite());
    if IsDefined(this.m_compass) {
      this.m_compass.OnPlayerAttach(playerPuppet);
    };
    if IsDefined(this.m_compass2) {
      this.m_compass2.OnPlayerAttach(playerPuppet);
    };
    if IsDefined(this.m_altimeter) {
      this.m_altimeter.OnPlayerAttach(playerPuppet);
    };
    if IsDefined(this.m_chargebar) {
      this.m_chargebar.OnPlayerAttach(playerPuppet);
    };
    if IsDefined(this.m_weaponBB) {
      this.m_chargebarValueChanged = this.m_weaponBB.RegisterDelayedListenerFloat(GetAllBlackboardDefs().Weapon.Charge, this, n"OnChargeValueChanged");
      this.m_chargebarTriggerModeChanged = this.m_weaponBB.RegisterDelayedListenerVariant(GetAllBlackboardDefs().Weapon.TriggerMode, this, n"OnTriggerModeChanged");
    };
    if IsDefined(this.m_targetAttitudeAnimator) {
      this.m_targetAttitudeAnimator.OnPlayerAttach(playerPuppet);
    };
    if IsDefined(this.m_ADSAnimator) {
      this.m_ADSAnimator.OnPlayerAttach(playerPuppet);
    };
    this.m_playerStateMachineBB = this.GetBlackboardSystem().GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    if IsDefined(this.m_playerStateMachineBB) {
      this.m_playerStateMachineUpperBodyBBID = this.m_playerStateMachineBB.RegisterDelayedListenerInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody, this, n"OnUpperBodyChanged");
      enableUpdate = this.m_playerStateMachineBB.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim);
      this.EnableUpdate(enableUpdate);
      this.m_crosshairStateChanged = this.m_playerStateMachineBB.RegisterDelayedListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Crosshair, this, n"OnCrosshairStatStateeChanged");
    };
    this.m_targetHealthListener = IronsightTargetHealthChangeListener.Create(this);
  }

  protected final func OnAnimationIntroFinished(anim: ref<inkAnimProxy>) -> Void {
    this.m_animIntro = null;
    this.m_targetAttitudeAnimator.OnAttitudeChanged(this.m_targetBB.GetInt(GetAllBlackboardDefs().UI_TargetingInfo.VisibleTargetAttitude));
  }

  protected cb func OnInitialize() -> Bool {
    if inkWidgetRef.IsValid(this.m_compassContainer) {
      this.m_compass = inkWidgetRef.GetController(this.m_compassContainer) as CompassController;
    };
    if inkWidgetRef.IsValid(this.m_compassContainer2) {
      this.m_compass2 = inkWidgetRef.GetController(this.m_compassContainer2) as CompassController;
    };
    if inkWidgetRef.IsValid(this.m_altimeterContainer) {
      this.m_altimeter = inkWidgetRef.GetController(this.m_altimeterContainer) as AltimeterController;
    };
    if inkWidgetRef.IsValid(this.m_chargebarContainer) {
      this.m_chargebar = inkWidgetRef.GetController(this.m_chargebarContainer) as ChargebarController;
    };
    if inkWidgetRef.IsValid(this.m_targetAttitudeContainer) {
      this.m_targetAttitudeAnimator = inkWidgetRef.GetController(this.m_targetAttitudeContainer) as TargetAttitudeAnimationController;
    };
    if inkWidgetRef.IsValid(this.m_ADSContainer) {
      this.m_ADSAnimator = inkWidgetRef.GetController(this.m_ADSContainer) as AimDownSightController;
    };
    this.EnableUpdate(false);
  }

  protected cb func OnUninitialize() -> Bool;

  protected cb func OnCompassUpdate() -> Bool {
    if IsDefined(this.m_compass) {
      this.m_compass.Update();
    };
    if IsDefined(this.m_compass2) {
      this.m_compass2.Update();
    };
    if IsDefined(this.m_altimeter) {
      this.m_altimeter.Update();
    };
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_InventoryManager.UnInitialize();
    this.bb.UnregisterListenerVariant(GetAllBlackboardDefs().UI_EquipmentData.EquipmentData, this.bbID);
    this.m_targetBB.UnregisterDelayedListener(GetAllBlackboardDefs().UI_TargetingInfo.VisibleTargetAttitude, this.m_targetAttitudeBBID);
    this.m_targetBB.UnregisterDelayedListener(GetAllBlackboardDefs().UI_TargetingInfo.VisibleTargetDistance, this.m_targetRangeBBID);
    this.m_targetBB.UnregisterDelayedListener(GetAllBlackboardDefs().UI_TargetingInfo.CurrentVisibleTarget, this.m_targetAcquiredBBID);
    if IsDefined(this.m_targetRangeObstructedBBID) {
      this.m_targetBB.UnregisterDelayedListener(GetAllBlackboardDefs().UI_TargetingInfo.ObstructedTargetDistance, this.m_targetRangeObstructedBBID);
    };
    if IsDefined(this.m_targetAcquiredObstructedBBID) {
      this.m_targetBB.UnregisterDelayedListener(GetAllBlackboardDefs().UI_TargetingInfo.CurrentObstructedTarget, this.m_targetAcquiredObstructedBBID);
    };
    this.m_weaponDataBB.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ActiveWeaponData.TargetHitEvent, this.m_weaponDataTargetHitBBID);
    this.m_weaponDataBB.UnregisterDelayedListener(GetAllBlackboardDefs().UI_ActiveWeaponData.ShootEvent, this.m_weaponDataShootBBID);
    this.StopAnimation(this.m_animIntro);
    this.StopAnimation(this.m_animLoop);
    this.StopAnimation(this.m_animReload);
    if IsDefined(this.m_compass) {
      this.m_compass.OnPlayerDetach(playerPuppet);
    };
    if IsDefined(this.m_compass2) {
      this.m_compass2.OnPlayerDetach(playerPuppet);
    };
    if IsDefined(this.m_altimeter) {
      this.m_altimeter.OnPlayerDetach(playerPuppet);
    };
    if IsDefined(this.m_chargebar) {
      this.m_chargebar.OnPlayerDetach(playerPuppet);
    };
    if IsDefined(this.m_weaponBB) {
      this.m_weaponBB.UnregisterDelayedListener(GetAllBlackboardDefs().Weapon.Charge, this.m_chargebarValueChanged);
      this.m_weaponBB.UnregisterDelayedListener(GetAllBlackboardDefs().Weapon.TriggerMode, this.m_chargebarTriggerModeChanged);
    };
    if IsDefined(this.m_targetAttitudeAnimator) {
      this.m_targetAttitudeAnimator.OnPlayerDetach(playerPuppet);
    };
    if IsDefined(this.m_playerStateMachineBB) {
      this.m_playerStateMachineBB.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.UpperBody, this.m_playerStateMachineUpperBodyBBID);
      this.m_playerStateMachineBB.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.Crosshair, this.m_crosshairStateChanged);
    };
    if IsDefined(this.m_ADSAnimator) {
      this.m_ADSAnimator.OnPlayerDetach(playerPuppet);
    };
    this.RegisterTargetCallbacks(false);
    this.m_targetHealthListener = null;
    this.bb = null;
  }

  protected final func OnAmmoCountChanged(value: Int32) -> Void {
    if value == this.m_currentAmmo {
      return;
    };
    this.m_currentAmmo = value;
    inkTextRef.SetText(this.m_ammo, IntToString(this.m_currentAmmo));
    if 0 == this.m_currentAmmo && (!IsDefined(this.m_animReload) || !this.m_animReload.IsPlaying()) {
      this.m_animReload = this.PlayLibraryAnimation(n"reload", IronsightDetail.PlaybackCycleInfinite());
    };
  }

  protected final func OnReloadEndLoop(anim: ref<inkAnimProxy>) -> Void {
    anim.Stop();
    anim.UnregisterFromAllCallbacks(inkanimEventType.OnEndLoop);
  }

  protected cb func OnWeaponDataChanged(value: Variant) -> Bool {
    let item: ref<gameItemData>;
    this.m_BufferedRosterData = FromVariant(value);
    let currentData: SlotWeaponData = this.m_BufferedRosterData.weapon;
    if ItemID.IsValid(currentData.weaponID) {
      this.m_ActiveWeapon = currentData;
      if this.m_ActiveWeapon.weaponID != currentData.weaponID {
        item = this.m_InventoryManager.GetPlayerItemData(this.m_ActiveWeapon.weaponID);
        this.m_weaponItemData = this.m_InventoryManager.GetInventoryItemData(item);
      };
      this.SetRosterSlotData();
    };
  }

  protected cb func OnShoot(arg: Variant) -> Bool {
    if IsDefined(this.m_shootAnimation) {
      this.m_shootAnimation.Stop();
      this.m_shootAnimation = this.PlayLibraryAnimation(this.m_shootAnimationName, IronsightDetail.PlaybackCycleOnce());
    };
  }

  protected cb func OnTargetHit(arg: Variant) -> Bool {
    if IsDefined(this.m_targetHitAnimation) {
      this.m_targetHitAnimation.Stop();
      this.m_targetHitAnimation = this.PlayLibraryAnimation(this.m_targetHitAnimationName, IronsightDetail.PlaybackCycleOnce());
    };
  }

  public final func OnAmmoSpareCountChanged() -> Void {
    let spareAmmo: Int32 = RPGManager.GetAmmoCountValue(this.m_playerPuppet, this.m_ActiveWeapon.weaponID);
    spareAmmo -= this.m_ActiveWeapon.ammoCurrent;
    inkTextRef.SetText(this.m_ammoSpareCount, IntToString(Max(spareAmmo, 0)));
  }

  private final func SetRosterSlotData() -> Void {
    this.OnAmmoCountChanged(this.m_ActiveWeapon.ammoCurrent);
    this.OnAmmoSpareCountChanged();
  }

  protected cb func OnChargeValueChanged(value: Float) -> Bool {
    this.m_chargebar.OnChargeValueChanged(value);
  }

  protected cb func OnTriggerModeChanged(triggerMode: Variant) -> Bool {
    if IsDefined(this.m_chargebar) {
      this.m_chargebar.OnTriggerModeChanged(triggerMode);
    };
  }

  protected cb func OnCrosshairStatStateeChanged(state: Int32) -> Bool {
    let newState: gamePSMCrosshairStates = IntEnum(state);
    switch newState {
      case gamePSMCrosshairStates.Reload:
        if IsDefined(this.m_animReload) && !this.m_animReload.IsPlaying() {
          this.m_animReload = this.PlayLibraryAnimation(n"reload", IronsightDetail.PlaybackCycleInfinite());
        };
        break;
      default:
        if IsDefined(this.m_animReload) && Equals(this.m_crosshairState, gamePSMCrosshairStates.Reload) {
          this.m_animReload.RegisterToCallback(inkanimEventType.OnEndLoop, this, n"OnReloadEndLoop");
          this.m_animReload = null;
        };
    };
    this.m_crosshairState = newState;
  }

  protected cb func OnUpperBodyChanged(state: Int32) -> Bool {
    let isAiming: Bool = state == EnumInt(gamePSMUpperBodyStates.Aim);
    this.EnableUpdate(isAiming);
    if IsDefined(this.m_ADSAnimator) {
      this.m_ADSAnimator.OnAim(isAiming);
    };
  }
}
