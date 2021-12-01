
public class RainMissileProjectile extends BaseProjectile {

  private let m_meshComponent: ref<IComponent>;

  private edit let m_effect: EffectRef;

  private let m_damage: ref<EffectInstance>;

  private let m_owner: wref<GameObject>;

  private let m_weapon: wref<WeaponObject>;

  @default(RainMissileProjectile, 0)
  private let m_countTime: Float;

  private edit let m_startVelocity: Float;

  private edit let m_lifetime: Float;

  @default(RainMissileProjectile, true)
  private let m_alive: Bool;

  @default(RainMissileProjectile, false)
  private let m_hit: Bool;

  @default(RainMissileProjectile, false)
  private let m_arrived: Bool;

  private let m_spawnPosition: Vector4;

  private let m_phase1Duration: Float;

  private edit let m_landIndicatorFX: FxResource;

  private let m_fxInstance: ref<FxInstance>;

  @default(RainMissileProjectile, false)
  private let m_hasExploded: Bool;

  private let m_missileDBID: TweakDBID;

  private let m_missileAttackRecord: wref<Attack_Record>;

  @default(RainMissileProjectile, -1.f)
  private let m_timeToDestory: Float;

  private let m_initialTargetPosition: Vector4;

  private let m_initialTargetOffset: Vector4;

  private let m_finalTargetPosition: Vector4;

  private let m_finalTargetOffset: Vector4;

  private let m_finalTargetPositionCalculationDelay: Float;

  private let m_targetComponent: wref<IPlacedComponent>;

  private let m_followTargetInPhase2: Bool;

  private let m_puppetBroadphaseHitRadiusSquared: Float;

  private let m_phase: EMissileRainPhase;

  private let m_spiralParams: ref<SpiralControllerParams>;

  private let m_useSpiralParams: Bool;

  private let m_randStartVelocity: Float;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"MeshComponent", n"IComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_meshComponent = EntityResolveComponentsInterface.GetComponent(ri, n"MeshComponent");
    this.m_spiralParams = new SpiralControllerParams();
    this.m_spiralParams.rampUpDistanceStart = 0.40;
    this.m_spiralParams.rampUpDistanceEnd = 1.00;
    this.m_spiralParams.rampDownDistanceStart = 7.50;
    this.m_spiralParams.rampDownDistanceEnd = 5.00;
    this.m_spiralParams.rampDownFactor = 1.00;
    this.m_spiralParams.randomizePhase = true;
  }

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool {
    let attackArr: array<ref<IAttack>>;
    let i: Int32;
    let missileDB: wref<Attack_Record>;
    let statsSystem: ref<StatsSystem>;
    let velVariance: Float;
    let weaponID: EntityID;
    super.OnProjectileInitialize(eventData);
    this.m_owner = eventData.owner;
    this.m_weapon = eventData.weapon as WeaponObject;
    attackArr = this.m_weapon.GetAttacks();
    if IsDefined(this.m_weapon) {
      statsSystem = GameInstance.GetStatsSystem(eventData.weapon.GetGame());
      weaponID = eventData.weapon.GetEntityID();
      this.m_useSpiralParams = statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.SmartGunAddSpiralTrajectory) > 0.00;
      this.m_spiralParams.radius = statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.SmartGunSpiralRadius);
      this.m_spiralParams.cycleTimeMin = statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.SmartGunSpiralCycleTimeMin);
      this.m_spiralParams.cycleTimeMax = statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.SmartGunSpiralCycleTimeMax);
      this.m_spiralParams.randomizeDirection = Cast(statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.SmartGunSpiralRandomizeDirection));
      velVariance = statsSystem.GetStatValue(Cast(weaponID), gamedataStatType.SmartGunProjectileVelocityVariance);
      this.m_randStartVelocity = RandRangeF(this.m_startVelocity - this.m_startVelocity * velVariance, this.m_startVelocity + this.m_startVelocity * velVariance);
    } else {
      this.m_spiralParams.enabled = false;
      this.m_spiralParams.radius = 0.01;
      this.m_spiralParams.cycleTimeMin = 0.10;
      this.m_spiralParams.cycleTimeMax = 0.10;
      this.m_randStartVelocity = this.m_startVelocity;
      this.m_useSpiralParams = false;
    };
    i = 0;
    while i < ArraySize(attackArr) {
      missileDB = attackArr[i].GetRecord();
      if Equals(missileDB.AttackName(), "RainMissile") {
        missileDB = attackArr[i].GetRecord();
      };
      i += 1;
    };
    if TDBID.IsValid(missileDB.GetID()) {
      this.m_missileDBID = missileDB.GetID();
      this.m_missileAttackRecord = missileDB;
    };
    this.m_meshComponent.Toggle(false);
    this.m_timeToDestory = -1.00;
    this.m_hasExploded = false;
    this.m_alive = true;
    this.m_hit = false;
    this.m_phase = EMissileRainPhase.Init;
    this.m_countTime = 0.00;
    this.m_initialTargetPosition = Vector4.EmptyVector();
    this.m_initialTargetOffset = Vector4.EmptyVector();
    this.m_finalTargetPositionCalculationDelay = 0.00;
    this.m_finalTargetPosition = Vector4.EmptyVector();
    this.m_finalTargetOffset = Vector4.EmptyVector();
    this.m_followTargetInPhase2 = false;
    this.m_arrived = false;
    this.m_puppetBroadphaseHitRadiusSquared = AITweakParams.GetFloatFromTweak(this.m_missileDBID, "puppetBroadphaseHitRadiusSquared");
  }

  private final func StartTrailEffect() -> Void {
    GameObjectEffectHelper.StartEffectEvent(this, n"trail", true);
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    let linearParams: ref<LinearTrajectoryParams>;
    if this.m_owner.IsPlayer() {
      linearParams = new LinearTrajectoryParams();
      linearParams.startVel = this.m_startVelocity;
      this.m_projectileComponent.SetOnCollisionAction(gameprojectileOnCollisionAction.Stop);
      this.m_projectileComponent.AddLinear(linearParams);
      this.m_projectileComponent.LockOrientation(false);
      this.StartTrailEffect();
    } else {
      Log("RainMissleProjectile : OnShoot called instead of OnShootTarget. This will not set a proper target position. Aborting projectile");
      this.DelayDestroyBullet();
    };
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    this.Explode(evt.hitPosition);
    this.DelayDestroyBullet();
  }

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    if !IsDefined(this.m_weapon) {
      Log("RainMissleProjectile : Projectile has no valid weapon that it is being fired from. Aborting projectile as rest of logic will not work correctly");
      this.DelayDestroyBullet();
    };
    this.m_targetComponent = eventData.params.trackedTargetComponent;
    this.m_initialTargetPosition = eventData.params.targetPosition;
    this.m_initialTargetOffset = eventData.params.hitPlaneOffset;
    this.m_spawnPosition = eventData.startPoint;
    this.m_followTargetInPhase2 = AITweakParams.GetBoolFromTweak(this.m_missileDBID, "followTargetInPhase2");
    this.m_finalTargetPositionCalculationDelay = AITweakParams.GetFloatFromTweak(this.m_missileDBID, "finalTargetPositionCalculationDelay");
    if this.m_finalTargetPositionCalculationDelay == 0.00 {
      this.CalcFinalTargetPositionAndOffset();
    };
    this.StartPhase1(eventData.startPoint);
  }

  protected cb func OnAcceleratedMovement(eventData: ref<gameprojectileAcceleratedMovementEvent>) -> Bool;

  protected cb func OnLinearMovement(eventData: ref<gameprojectileLinearMovementEvent>) -> Bool {
    let distance: Vector4 = Matrix.GetTranslation(this.m_projectileComponent.GetLocalToWorld()) - eventData.targetPosition;
    GameObject.SetAudioParameter(this, n"RTPC_Height_Difference", distance.Z);
    GameObject.PlaySoundEvent(this, n"Smart_21301_bullet_trail_whistle");
  }

  protected cb func OnTick(eventData: ref<gameprojectileTickEvent>) -> Bool {
    this.m_countTime += eventData.deltaTime;
    if Equals(this.m_phase, EMissileRainPhase.Phase1) {
      if this.m_finalTargetPositionCalculationDelay > 0.00 && this.m_countTime >= this.m_finalTargetPositionCalculationDelay {
        this.CalcFinalTargetPositionAndOffset();
      };
      if this.m_countTime >= this.m_phase1Duration {
        this.StartPhase2();
      };
    };
    if this.m_countTime >= this.m_lifetime {
      this.DestroyBullet();
    };
    if this.m_timeToDestory > 0.00 {
      this.m_timeToDestory -= eventData.deltaTime;
      if this.m_timeToDestory <= 0.00 {
        this.DestroyBullet();
      };
    };
    if this.m_arrived {
      if Equals(this.m_phase, EMissileRainPhase.Phase2) {
        this.Explode(Matrix.GetTranslation(this.m_projectileComponent.GetLocalToWorld()));
        this.DelayDestroyBullet();
      };
      this.m_arrived = false;
    };
  }

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool {
    super.OnCollision(eventData);
    this.OnCollideWithEntity(eventData.hitInstances[0].projectilePosition);
  }

  protected cb func OnGameprojectileBroadPhaseHitEvent(eventData: ref<gameprojectileBroadPhaseHitEvent>) -> Bool {
    let hitObject: ref<Entity> = eventData.hitObject;
    let hitPosition: Vector4 = eventData.position;
    if this.m_puppetBroadphaseHitRadiusSquared >= 0.00 && IsDefined(hitObject as ScriptedPuppet) {
      if Vector4.DistanceSquared(hitPosition, hitObject.GetWorldPosition()) > this.m_puppetBroadphaseHitRadiusSquared {
        return false;
      };
    };
    this.OnCollideWithEntity(hitPosition);
  }

  private final func OnCollideWithEntity(projectilePosition: Vector4) -> Void {
    this.Explode(projectilePosition);
    this.DelayDestroyBullet();
  }

  protected final func DelayDestroyBullet() -> Void {
    if this.m_timeToDestory < 0.00 {
      this.m_timeToDestory = 0.20;
    };
  }

  private final func DestroyBullet() -> Void {
    if this.m_alive {
      this.KillLandVFX(this.m_fxInstance);
      this.m_alive = false;
      this.m_meshComponent.Toggle(false);
      this.m_projectileComponent.ClearTrajectories();
      this.m_hasExploded = true;
      this.Release();
    };
  }

  private final func Explode(projectilePosition: Vector4) -> Void {
    let explosionAttackRecord: ref<Attack_Record>;
    if !this.m_hasExploded {
      this.m_hasExploded = true;
      this.m_meshComponent.Toggle(false);
      explosionAttackRecord = ProjectileHelper.FindExplosiveHitAttack(this.m_missileAttackRecord);
      if IsDefined(explosionAttackRecord) {
        ProjectileGameEffectHelper.FillProjectileHitAoEData(this.m_user, this.m_user, projectilePosition, AITweakParams.GetFloatFromTweak(this.m_missileDBID, "explosionRadius"), explosionAttackRecord, this.m_weapon);
        GameInstance.GetAudioSystem(this.GetGame()).PlayShockwave(n"explosion", projectilePosition);
      };
    };
  }

  protected cb func OnFollowSuccess(eventData: ref<gameprojectileFollowEvent>) -> Bool {
    this.m_arrived = true;
  }

  protected final func StartPhase1(targetPos: Vector4) -> Void {
    let forwardOffset: Vector4;
    let lateralOffset: Vector4;
    let orientation: Quaternion;
    let targetDirection: Vector4;
    let followCurveParams: ref<FollowCurveTrajectoryParams> = new FollowCurveTrajectoryParams();
    if NotEquals(EMissileRainPhase.Phase1, this.m_phase) {
      this.m_phase = EMissileRainPhase.Phase1;
      this.m_phase1Duration = RandRangeF(AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1DurationMin"), AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1DurationMax"));
      this.m_meshComponent.Toggle(true);
      targetDirection = this.m_initialTargetPosition - this.m_spawnPosition;
      targetDirection.Z = 0.00;
      orientation = Quaternion.BuildFromDirectionVector(targetDirection);
      forwardOffset.Y = RandRangeF(AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1PositionForwardOffsetMin"), AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1PositionForwardOffsetMax"));
      forwardOffset = Quaternion.Transform(orientation, forwardOffset);
      forwardOffset.Z = 0.00;
      lateralOffset.X = RandRangeF(-AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1PositionLateralOffset"), AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1PositionLateralOffset"));
      lateralOffset = Quaternion.Transform(orientation, lateralOffset);
      lateralOffset.Z = 0.00;
      targetPos += forwardOffset + lateralOffset;
      targetPos.Z += AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1PositionZOffset");
      this.m_projectileComponent.ClearTrajectories();
      followCurveParams.startVelocity = AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1StartVelocity");
      followCurveParams.targetPosition = targetPos;
      followCurveParams.bendTimeRatio = AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1BendTimeRatio");
      followCurveParams.bendFactor = AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1BendFactor");
      followCurveParams.angleInHitPlane = RandRangeF(AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1AngleInHitPlaneMin"), AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1AngleInHitPlaneMax"));
      followCurveParams.angleInVerticalPlane = RandRangeF(-AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1AngleInVerticalPlane"), AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1AngleInVerticalPlane"));
      followCurveParams.snapRadius = AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p1SnapRadius");
      followCurveParams.sendFollowEvent = false;
      this.m_projectileComponent.AddFollowCurve(followCurveParams);
      this.m_projectileComponent.SetOnCollisionAction(gameprojectileOnCollisionAction.Stop);
      this.m_spiralParams.enabled = this.m_useSpiralParams;
      this.m_projectileComponent.SetSpiral(this.m_spiralParams);
      this.StartTrailEffect();
    };
  }

  protected final func StartPhase2() -> Void {
    let followCurveParams: ref<FollowCurveTrajectoryParams> = new FollowCurveTrajectoryParams();
    this.m_phase = EMissileRainPhase.Phase2;
    if this.m_followTargetInPhase2 && IsDefined(this.m_targetComponent) {
      this.CalcFinalTargetPositionAndOffset();
      followCurveParams.target = this.m_targetComponent.GetEntity() as GameObject;
    } else {
      if this.m_countTime < this.m_finalTargetPositionCalculationDelay || this.m_finalTargetPositionCalculationDelay < 0.00 {
        this.CalcFinalTargetPositionAndOffset();
      };
    };
    this.m_projectileComponent.ClearTrajectories();
    followCurveParams.startVelocity = AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p2StartVelocity");
    followCurveParams.targetPosition = this.m_finalTargetPosition;
    followCurveParams.bendTimeRatio = AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p2BendRation");
    followCurveParams.bendFactor = AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p2BendFactor");
    followCurveParams.angleInHitPlane = RandRangeF(AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p2AngleInHitPlaneMin"), AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p2AngleInHitPlaneMax"));
    followCurveParams.angleInVerticalPlane = RandRangeF(-AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p2AngleInVerticalPlane"), AITweakParams.GetFloatFromTweak(this.m_missileDBID, "p2AngleInVerticalPlane"));
    followCurveParams.shouldRotate = AITweakParams.GetBoolFromTweak(this.m_missileDBID, "p2ShouldRotate");
    followCurveParams.accuracy = 1.00;
    followCurveParams.offset = this.m_finalTargetOffset;
    this.m_projectileComponent.AddFollowCurve(followCurveParams);
    this.m_spiralParams.enabled = this.m_useSpiralParams;
    this.m_projectileComponent.SetSpiral(this.m_spiralParams);
    this.StartTrailEffect();
  }

  private final func CalcFinalTargetPositionAndOffset() -> Void {
    let directionOffset: Vector4;
    let offset: Float;
    this.m_finalTargetOffset = this.m_initialTargetOffset;
    if IsDefined(this.m_targetComponent) {
      this.m_finalTargetPosition = this.m_targetComponent.GetEntity().GetWorldPosition();
      this.m_finalTargetOffset.Z = 0.00;
    } else {
      this.m_finalTargetPosition = this.m_initialTargetPosition;
    };
    offset = AITweakParams.GetFloatFromTweak(this.m_missileDBID, "targetPositionOffset");
    if offset > 0.00 {
      directionOffset = this.m_spawnPosition - this.m_finalTargetPosition;
      directionOffset = Vector4.Normalize(directionOffset) * offset;
      this.m_finalTargetOffset.X += directionOffset.X;
      this.m_finalTargetOffset.Y += directionOffset.Y;
      this.m_finalTargetOffset.X += RandRangeF(-AITweakParams.GetFloatFromTweak(this.m_missileDBID, "targetPositionXYAdditive"), AITweakParams.GetFloatFromTweak(this.m_missileDBID, "targetPositionXYAdditive"));
      this.m_finalTargetOffset.Y += RandRangeF(-AITweakParams.GetFloatFromTweak(this.m_missileDBID, "targetPositionXYAdditive"), AITweakParams.GetFloatFromTweak(this.m_missileDBID, "targetPositionXYAdditive"));
    };
    if !this.m_followTargetInPhase2 || !IsDefined(this.m_targetComponent) {
      this.SpawnLandVFXs(this.m_landIndicatorFX, this.m_finalTargetPosition + this.m_finalTargetOffset);
    };
  }

  private final func SpawnLandVFXs(fx: FxResource, fxposition: Vector4) -> Void {
    let position: WorldPosition;
    let transform: WorldTransform;
    if FxResource.IsValid(fx) {
      WorldPosition.SetVector4(position, fxposition);
      WorldTransform.SetWorldPosition(transform, position);
      this.m_fxInstance = this.CreateFxInstance(fx, transform);
    };
  }

  private final func KillLandVFX(fxInstance: ref<FxInstance>) -> Void {
    fxInstance.BreakLoop();
  }

  private final func CreateFxInstance(resource: FxResource, transform: WorldTransform) -> ref<FxInstance> {
    let fxSystem: ref<FxSystem> = GameInstance.GetFxSystem(this.GetGame());
    let fx: ref<FxInstance> = fxSystem.SpawnEffect(resource, transform);
    return fx;
  }
}
