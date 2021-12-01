
public class MonoDisc extends BaseProjectile {

  private let m_throwtype: ThrowType;

  private let m_targetAcquired: Bool;

  private let m_player: wref<GameObject>;

  private let m_disc: wref<GameObject>;

  private let m_target: wref<GameObject>;

  private let m_blackboard: wref<IBlackboard>;

  private let m_discSpawnPoint: Vector4;

  private let m_discPosition: Vector4;

  private let m_collisionCount: Int32;

  private let m_airTime: Float;

  private let m_destroyTimer: Float;

  private let m_returningToPlayer: Bool;

  private let m_catchingPlayer: Bool;

  private let m_discCaught: Bool;

  private let m_discLodgedToSurface: Bool;

  private let m_OnProjectileCaughtCallback: ref<CallbackHandle>;

  @default(MonoDisc, false)
  private let m_wasNPCHit: Bool;

  private let m_animationController: ref<AnimationControllerComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
  }

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool {
    this.m_player = eventData.owner;
    this.m_disc = eventData.weapon;
    this.ResetParameters();
    this.UpdateAnimData();
    this.RegisterForProjectileCaught();
  }

  private final func RegisterForProjectileCaught() -> Void {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().LeftHandCyberware);
    this.m_OnProjectileCaughtCallback = blackboard.RegisterListenerBool(GetAllBlackboardDefs().LeftHandCyberware.ProjectileCaught, this, n"OnProjectileCaught");
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    let angleDist: EulerAngles;
    let quickThrowTarget: ref<IPlacedComponent> = GameInstance.GetTargetingSystem(this.GetGame()).GetComponentClosestToCrosshair(eventData.owner, angleDist, TSQ_EnemyNPC());
    this.GeneralShoot(eventData);
    this.SetTargetComponentQuickThrow(quickThrowTarget);
  }

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    this.GeneralShoot(eventData);
    this.SetTargetComponent(eventData.params.trackedTargetComponent);
  }

  private final func GeneralShoot(eventData: ref<gameprojectileShootEvent>) -> Void {
    this.m_discSpawnPoint = eventData.startPoint;
    let chargeData: gameprojectileWeaponParams = eventData.params;
    let chargeParam: Float = chargeData.charge;
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGame());
    let playerPuppet: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject();
    this.m_blackboard = blackboardSystem.GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    this.GetThrowType(chargeParam);
    this.LaunchDisc(eventData);
  }

  private final func ResetParameters() -> Void {
    this.m_targetAcquired = false;
    this.m_returningToPlayer = false;
    this.m_discLodgedToSurface = false;
    this.m_catchingPlayer = false;
    this.m_collisionCount = 0;
    this.m_discCaught = false;
    this.m_destroyTimer = 0.00;
    this.m_airTime = 0.00;
  }

  private final func GetThrowType(chargeParam: Float) -> Void {
    if chargeParam < 1.00 {
      this.m_throwtype = ThrowType.Quick;
    } else {
      if chargeParam >= 1.00 {
        this.m_throwtype = ThrowType.Charge;
      };
    };
  }

  protected cb func OnProjectileCaught(value: Bool) -> Bool {
    if value {
      AnimationControllerComponent.SetInputBool(this, n"is_caught", true);
      AnimationControllerComponent.SetInputBool(this, n"is_thrown", false);
    };
  }

  private final func LaunchDisc(eventData: ref<gameprojectileShootEvent>) -> Void {
    let distance: Float;
    let height: Float;
    let sideOffset: Float;
    let startVelocity: Float;
    let minPlayerSpeed: Float = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "minPlayerSpeed"), 0.00);
    if Equals(this.m_throwtype, ThrowType.Quick) {
      if !this.IsPlayerInKerenzikov() && this.GetPlayerSpeed() < minPlayerSpeed {
        startVelocity = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "startVel"), 0.00);
        distance = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "fakeDistance"), 0.00);
        sideOffset = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "fakeSideOffset"), 0.00);
        height = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "fakeHeight"), 0.00);
      } else {
        if this.IsPlayerInKerenzikov() || this.GetPlayerSpeed() >= minPlayerSpeed {
          startVelocity = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "startVelFastMovement"), 0.00);
          distance = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "fakeDistanceFastMovement"), 0.00);
          sideOffset = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "fakeSideOffsetFastMovement"), 0.00);
          height = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "fakeHeightFastMovement"), 0.00);
        };
      };
    } else {
      if Equals(this.m_throwtype, ThrowType.Charge) {
        startVelocity = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "startVelCharge"), 0.00);
        distance = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "fakeDistanceCharge"), 0.00);
        sideOffset = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "fakeSideOffsetCharge"), 0.00);
        height = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "fakeHeightCharge"), 0.00);
      };
    };
    this.NoTargetLaunch(eventData.localToWorld, startVelocity, distance, sideOffset, height);
    this.SpawnTrailEffects();
    if IsDefined(this.m_animationController) {
      AnimationControllerComponent.SetInputBool(this, n"is_caught", false);
      AnimationControllerComponent.SetInputBool(this, n"is_thrown", true);
    };
  }

  private final func NoTargetLaunch(localToWorld: Matrix, startVelocity: Float, distance: Float, sideOffset: Float, height: Float) -> Void {
    let fakeTargetPosition: Vector4;
    let followCurveParams: ref<FollowCurveTrajectoryParams> = new FollowCurveTrajectoryParams();
    this.m_projectileComponent.ClearTrajectories();
    followCurveParams.startVelocity = startVelocity;
    followCurveParams.linearTimeRatio = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetLinearTimeRatioNoTarget"), 0.00);
    followCurveParams.interpolationTimeRatio = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetInterpolationTimeRatioNoTarget"), 0.00);
    followCurveParams.returnTimeMargin = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "returnTimeMarginNoTarget"), 0.00);
    followCurveParams.bendTimeRatio = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "bendTimeRatioNoTarget"), 0.00);
    followCurveParams.bendFactor = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "bendFactorNoTarget"), 0.00);
    followCurveParams.accuracy = 0.50;
    followCurveParams.halfLeanAngle = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "halfLeanAngleNoTarget"), 0.00);
    followCurveParams.endLeanAngle = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "endLeanAngleNoTarget"), 0.00);
    followCurveParams.angleInterpolationDuration = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "angleInterpolationDurationNoTarget"), 0.00);
    fakeTargetPosition = Matrix.GetTranslation(localToWorld) + Matrix.GetAxisY(localToWorld) * distance - Matrix.GetAxisX(localToWorld) * sideOffset + Matrix.GetAxisZ(localToWorld) * height;
    followCurveParams.targetPosition = fakeTargetPosition;
    this.m_projectileComponent.AddFollowCurve(followCurveParams);
    this.m_targetAcquired = false;
  }

  private final func GetBlackboardIntVariable(id: BlackboardID_Int) -> Int32 {
    return this.m_blackboard.GetInt(id);
  }

  private final func UpdateAnimData() -> Void {
    AnimationControllerComponent.SetInputFloat(this, n"max_rotation_speed", TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "maxRotationSpeed"), 3000.00));
    AnimationControllerComponent.SetInputFloat(this, n"time_to_max_rotation", TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "timeToMaxRotation"), 0.90));
    AnimationControllerComponent.SetInputFloat(this, n"time_to_max_scale", TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "timeToMaxScale"), 2.00));
  }

  protected cb func OnTick(eventData: ref<gameprojectileTickEvent>) -> Bool {
    let playerPosition: Vector4;
    this.m_discPosition = eventData.position;
    this.m_airTime += eventData.deltaTime;
    playerPosition = this.GetPlayerPosition();
    if !this.m_returningToPlayer && !this.m_targetAcquired && Vector4.Distance(this.m_discSpawnPoint, this.m_discPosition) >= this.GetMaxDistance() {
      this.ReturnToPlayer();
    } else {
      if this.m_returningToPlayer && !this.m_catchingPlayer && !this.m_discLodgedToSurface && Vector4.Distance(playerPosition, this.m_discPosition) <= TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "distanceToStartCatching"), 0.00) {
        this.StartCathingPlayer();
      } else {
        if this.m_returningToPlayer && !this.m_discLodgedToSurface && Vector4.Distance(playerPosition, this.m_discPosition) <= TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "distanceToPlayCatchAnim"), 0.00) {
          this.PlayCatchAnimation();
        } else {
          if !this.m_returningToPlayer && Vector4.Distance(playerPosition, this.m_discPosition) <= TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "distanceToPlayCatchAnim"), 0.00) && this.m_airTime >= TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "minAirTimeToCatchTheDisc"), 0.00) {
            this.PlayCatchAnimation();
            this.Release();
          } else {
            if this.m_discLodgedToSurface {
              this.m_destroyTimer += eventData.deltaTime;
            };
          };
        };
      };
    };
    if this.m_destroyTimer >= TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "maxTimeToDestroy"), 0.00) {
      this.Release();
    };
  }

  private final func GetMaxDistance() -> Float {
    let maxDistanceInAir: Float;
    if Equals(this.m_throwtype, ThrowType.Quick) {
      maxDistanceInAir = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "maxDistanceQuickThrow"), 0.00);
    } else {
      if Equals(this.m_throwtype, ThrowType.Charge) {
        maxDistanceInAir = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "maxDistanceChargeThrow"), 0.00);
      };
    };
    return maxDistanceInAir;
  }

  private final func IsPlayerInKerenzikov() -> Bool {
    let isPlayerInKerenzikov: Bool;
    if IsDefined(this.m_blackboard) {
      isPlayerInKerenzikov = this.GetBlackboardIntVariable(GetAllBlackboardDefs().PlayerStateMachine.Locomotion) == EnumInt(gamePSMLocomotionStates.Kereznikov);
    };
    return isPlayerInKerenzikov;
  }

  private final func GetPlayerSpeed() -> Float {
    let player: ref<PlayerPuppet> = this.m_player as PlayerPuppet;
    let velocity: Vector4 = player.GetVelocity();
    let speed: Float = Vector4.Length2D(velocity);
    return speed;
  }

  private final func GetPlayerPosition() -> Vector4 {
    let positionParameter: Variant = ToVariant(this.m_player.GetWorldPosition());
    let playerPosition: Vector4 = FromVariant(positionParameter);
    return playerPosition;
  }

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool {
    let object: ref<Entity>;
    this.m_collisionCount += 1;
    object = eventData.hitInstances[0].hitObject;
    this.m_target = object as NPCPuppet;
    if !this.m_target.HasTag(n"BossExo") && !this.m_wasNPCHit {
      this.DealDamage(eventData);
      this.m_wasNPCHit = true;
    };
    if !this.m_returningToPlayer && this.m_collisionCount == 1 {
      this.ReturnToPlayer();
    };
    if this.m_returningToPlayer && this.m_collisionCount >= TweakDBInterface.GetInt(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "illegalCollisionCount"), 0) {
      this.LodgeDiscToSurface();
    };
  }

  private final func LodgeDiscToSurface() -> Void {
    if !this.m_discLodgedToSurface {
      GameObject.PlaySoundEvent(this, n"monodisc_projectile_loop_stop");
      this.m_projectileComponent.ClearTrajectories();
      AnimationControllerComponent.SetInputFloat(this, n"max_rotation_speed", 0.00);
      this.m_discLodgedToSurface = true;
    };
  }

  private final func DealDamage(eventData: ref<gameprojectileHitEvent>) -> Void {
    let damage: ref<EffectInstance> = this.m_projectileComponent.GetGameEffectInstance();
    let damageData: EffectData = damage.GetSharedData();
    EffectData.SetVariant(damageData, GetAllBlackboardDefs().EffectSharedData.projectileHitEvent, ToVariant(eventData));
    damage.Run();
  }

  private final func SetTargetComponentQuickThrow(quickThrowTarget: ref<IPlacedComponent>) -> Void {
    let followCurveParams: ref<FollowCurveTrajectoryParams> = new FollowCurveTrajectoryParams();
    if IsDefined(quickThrowTarget) {
      this.m_projectileComponent.ClearTrajectories();
      followCurveParams.startVelocity = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetVel"), 0.00);
      followCurveParams.linearTimeRatio = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetLinearTimeRatio"), 0.00);
      followCurveParams.interpolationTimeRatio = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetInterpolationTimeRatio"), 0.00);
      followCurveParams.returnTimeMargin = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetReturnTimeMargin"), 0.00);
      followCurveParams.bendTimeRatio = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "bendTimeRatio"), 0.00);
      followCurveParams.bendFactor = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "bendFactor"), 0.00);
      followCurveParams.halfLeanAngle = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "halfLeanAngleQuickThrow"), 0.00);
      followCurveParams.endLeanAngle = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "endLeanAngleQuickThrow"), 0.00);
      followCurveParams.angleInterpolationDuration = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "angleInterpolationDurationQuickThrow"), 0.00);
      followCurveParams.targetComponent = quickThrowTarget;
      this.m_projectileComponent.AddFollowCurve(followCurveParams);
      this.m_targetAcquired = true;
    };
  }

  private final func SetTargetComponent(target: ref<IPlacedComponent>) -> Void {
    let followCurveParams: ref<FollowCurveTrajectoryParams> = new FollowCurveTrajectoryParams();
    if IsDefined(target) {
      this.m_projectileComponent.ClearTrajectories();
      followCurveParams.startVelocity = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetVel"), 0.00);
      followCurveParams.linearTimeRatio = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetLinearTimeRatio"), 0.00);
      followCurveParams.interpolationTimeRatio = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetInterpolationTimeRatio"), 0.00);
      followCurveParams.returnTimeMargin = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetReturnTimeMargin"), 0.00);
      followCurveParams.bendTimeRatio = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "bendTimeRatio"), 0.00);
      followCurveParams.bendFactor = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "bendFactor"), 0.00);
      followCurveParams.halfLeanAngle = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "halfLeanAngleChargeThrow"), 0.00);
      followCurveParams.endLeanAngle = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "endLeanAngleChargeThrow"), 0.00);
      followCurveParams.angleInterpolationDuration = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "angleInterpolationDurationChargeThrow"), 0.00);
      followCurveParams.targetComponent = target;
      this.m_projectileComponent.AddFollowCurve(followCurveParams);
      this.m_targetAcquired = true;
    };
  }

  private final func GetPlayerTargetComponent() -> CName {
    let playerTargetingComponent: CName = TweakDBInterface.GetCName(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetComponentName"), n"targeting_cyberarm");
    return playerTargetingComponent;
  }

  private final func ReturnToPlayer() -> Void {
    let followCurveParams: ref<FollowCurveTrajectoryParams> = new FollowCurveTrajectoryParams();
    this.m_projectileComponent.ClearTrajectories();
    followCurveParams.startVelocity = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetVelReturnToPlayer"), 0.00);
    followCurveParams.linearTimeRatio = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetLinearTimeRatio"), 0.00);
    followCurveParams.interpolationTimeRatio = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetInterpolationTimeRatio"), 0.00);
    followCurveParams.returnTimeMargin = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetReturnTimeMargin"), 0.00);
    followCurveParams.halfLeanAngle = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "halfLeanAngleReturn"), 0.00);
    followCurveParams.endLeanAngle = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "endLeanAngleReturn"), 0.00);
    followCurveParams.componentName = this.GetPlayerTargetComponent();
    followCurveParams.target = this.m_player;
    this.m_projectileComponent.AddFollowCurve(followCurveParams);
    this.m_returningToPlayer = true;
  }

  private final func StartCathingPlayer() -> Void {
    let followCurveParams: ref<FollowCurveTrajectoryParams> = new FollowCurveTrajectoryParams();
    this.m_projectileComponent.ClearTrajectories();
    followCurveParams.startVelocity = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetVelToCatchPlayer"), 0.00);
    followCurveParams.linearTimeRatio = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetLinearTimeRatioCatchPlayer"), 0.00);
    followCurveParams.interpolationTimeRatio = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetInterpolationTimeRatioCatchPlayer"), 0.00);
    followCurveParams.returnTimeMargin = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "targetReturnTimeMarginCatchPlayer"), 0.00);
    followCurveParams.accuracy = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "distanceToDestroyDisc"), 0.00);
    followCurveParams.componentName = this.GetPlayerTargetComponent();
    followCurveParams.target = this.m_player;
    followCurveParams.halfLeanAngle = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "halfLeanAngleCatchingPlayer"), 0.00);
    followCurveParams.endLeanAngle = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "endLeanAngleCatchingPlayer"), 0.00);
    followCurveParams.angleInterpolationDuration = TweakDBInterface.GetFloat(TDBID.Create("cyberware." + this.m_tweakDBPath + "." + "angleInterpolationDurationCatchingPlayer"), 0.00);
    this.m_projectileComponent.AddFollowCurve(followCurveParams);
    this.m_catchingPlayer = true;
  }

  protected cb func OnFollowSuccess(eventData: ref<gameprojectileFollowEvent>) -> Bool {
    if IsDefined(this.m_player) && this.m_player == eventData.followObject {
      this.Release();
    } else {
      if !this.m_returningToPlayer && !this.m_targetAcquired {
        this.ReturnToPlayer();
      } else {
        if this.m_targetAcquired {
          this.ReturnToPlayer();
        };
      };
    };
  }

  private final func PlayCatchAnimation() -> Void {
    let psmParam: ref<PSMPostponedParameterInt>;
    if !this.m_discCaught {
      if IsDefined(this.m_animationController) {
        AnimationControllerComponent.SetInputBool(this, n"is_caught", true);
      };
      psmParam = new PSMPostponedParameterInt();
      psmParam.id = n"MonoDiscState";
      psmParam.value = 1;
      this.m_player.QueueEvent(psmParam);
      this.m_discCaught = true;
    };
  }

  private final func SpawnTrailEffects() -> Void {
    let audioSwitchValue: CName;
    if Equals(this.m_throwtype, ThrowType.Charge) {
      this.SpawnVisualEffect(n"trail_charged", this.m_disc);
      this.SpawnVisualEffect(n"spinning", this.m_disc);
      audioSwitchValue = n"monodisc_throw_charged";
    } else {
      this.SpawnVisualEffect(n"trail", this.m_disc);
      audioSwitchValue = n"monodisc_throw_quick";
    };
    GameObject.SetAudioSwitch(this, n"monodisc_throw_type", audioSwitchValue);
  }

  private final func SpawnVisualEffect(effectName: CName, disc: ref<GameObject>) -> Void {
    let spawnEffectEvent: ref<entSpawnEffectEvent> = new entSpawnEffectEvent();
    spawnEffectEvent.effectName = effectName;
    this.QueueEvent(spawnEffectEvent);
  }
}
