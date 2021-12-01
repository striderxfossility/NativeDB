
public class sampleSmartBullet extends BaseProjectile {

  private let m_meshComponent: ref<IComponent>;

  private edit let m_effect: EffectRef;

  @default(sampleSmartBullet, 0)
  private let m_countTime: Float;

  private let m_startVelocity: Float;

  private edit let m_lifetime: Float;

  private edit let m_bendTimeRatio: Float;

  private edit let m_bendFactor: Float;

  @default(sampleSmartBullet, false)
  private edit let m_useParabolicPhase: Bool;

  private edit let m_parabolicVelocityMin: Float;

  private edit let m_parabolicVelocityMax: Float;

  private edit let m_parabolicDuration: Float;

  private edit let m_parabolicGravity: Vector4;

  private let m_spiralParams: ref<SpiralControllerParams>;

  private let m_useSpiralParams: Bool;

  @default(sampleSmartBullet, true)
  private let m_alive: Bool;

  @default(sampleSmartBullet, false)
  private let m_hit: Bool;

  private let m_trailName: CName;

  public let m_statsSystem: ref<StatsSystem>;

  public let m_weaponID: EntityID;

  public let m_parabolicPhaseParams: ref<ParabolicTrajectoryParams>;

  public let m_followPhaseParams: ref<FollowCurveTrajectoryParams>;

  public let m_linearPhaseParams: ref<LinearTrajectoryParams>;

  public let m_targeted: Bool;

  public let m_trailStarted: Bool;

  public let m_phase: ESmartBulletPhase;

  public let m_timeInPhase: Float;

  private let m_randStartVelocity: Float;

  private let m_smartGunMissDelay: Float;

  private let m_smartGunHitProbability: Float;

  private let m_smartGunMissRadius: Float;

  private let m_randomWeaponMissChance: Float;

  private let m_randomTargetMissChance: Float;

  private let m_readyToMiss: Bool;

  @default(sampleSmartBullet, false)
  private edit let m_stopAndDropOnTargetingDisruption: Bool;

  private let m_shouldStopAndDrop: Bool;

  private let m_targetID: EntityID;

  private let m_ignoredTargetID: EntityID;

  private let m_owner: wref<GameObject>;

  private let m_weapon: wref<GameObject>;

  private let m_startPosition: Vector4;

  private let m_hasExploded: Bool;

  private let m_attack: ref<IAttack>;

  private let m_BulletCollisionEvaluator: ref<BulletCollisionEvaluator>;

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
    let velVariance: Float;
    this.m_projectileComponent.ToggleAxisRotation(true);
    this.m_projectileComponent.AddAxisRotation(new Vector4(0.00, 1.00, 0.00, 0.00), 100.00);
    this.m_owner = eventData.owner;
    this.m_weapon = eventData.weapon;
    this.m_BulletCollisionEvaluator = new BulletCollisionEvaluator();
    this.m_projectileComponent.SetCollisionEvaluator(this.m_BulletCollisionEvaluator);
    if IsDefined(this.m_weapon) {
      this.m_statsSystem = GameInstance.GetStatsSystem(this.m_weapon.GetGame());
      this.m_weaponID = this.m_weapon.GetEntityID();
      this.m_attack = (this.m_weapon as WeaponObject).GetCurrentAttack();
      this.m_useSpiralParams = this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.SmartGunAddSpiralTrajectory) > 0.00;
      this.m_spiralParams.radius = this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.SmartGunSpiralRadius);
      this.m_spiralParams.cycleTimeMin = this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.SmartGunSpiralCycleTimeMin);
      this.m_spiralParams.cycleTimeMax = this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.SmartGunSpiralCycleTimeMax);
      this.m_spiralParams.randomizeDirection = Cast(this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.SmartGunSpiralRandomizeDirection));
      if eventData.owner.IsNPC() {
        this.m_startVelocity = this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.SmartGunNPCProjectileVelocity);
      } else {
        if eventData.owner.IsPlayer() {
          this.m_startVelocity = this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.SmartGunPlayerProjectileVelocity);
        };
      };
      velVariance = this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.SmartGunProjectileVelocityVariance);
      this.m_randStartVelocity = RandRangeF(this.m_startVelocity - this.m_startVelocity * velVariance, this.m_startVelocity + this.m_startVelocity * velVariance);
      this.m_randStartVelocity = MaxF(1.00, this.m_randStartVelocity);
      this.m_smartGunHitProbability = ClampF(this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.SmartGunHitProbability), 0.00, 1.00);
      if IsDefined(this.m_owner) && IsDefined(this.m_statsSystem) {
        this.m_smartGunHitProbability *= 1.00 + this.m_statsSystem.GetStatValue(Cast(this.m_owner.GetEntityID()), gamedataStatType.SmartGunHitProbabilityMultiplier);
        this.m_smartGunHitProbability = ClampF(this.m_smartGunHitProbability, 0.00, 1.00);
      };
      this.m_smartGunMissDelay = this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.SmartGunMissDelay);
      this.m_smartGunMissRadius = this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.SmartGunMissRadius);
      this.m_smartGunMissRadius = this.m_smartGunMissRadius * RandRangeF(0.66, 1.00);
    } else {
      this.m_spiralParams.enabled = false;
      this.m_spiralParams.radius = 0.01;
      this.m_spiralParams.cycleTimeMin = 0.10;
      this.m_spiralParams.cycleTimeMax = 0.10;
      this.m_randStartVelocity = 50.00;
      this.m_startVelocity = 50.00;
      this.m_useSpiralParams = false;
    };
    this.SetCurrentDamageTrailName();
  }

  private final func StartTrailEffect() -> Void {
    if !this.m_trailStarted {
      GameObjectEffectHelper.StartEffectEvent(this, this.m_trailName, true);
      this.m_trailStarted = true;
    };
  }

  private final func Reset() -> Void {
    this.m_countTime = 0.00;
    this.m_alive = true;
    this.m_hit = false;
    this.m_timeInPhase = 0.00;
    this.m_phase = ESmartBulletPhase.Init;
    this.m_targeted = false;
    this.m_trailStarted = false;
    this.m_readyToMiss = false;
    this.m_hasExploded = false;
    this.m_targetID = EMPTY_ENTITY_ID();
    this.m_ignoredTargetID = EMPTY_ENTITY_ID();
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    this.Reset();
    this.m_targeted = false;
    this.m_startPosition = eventData.startPoint;
    this.SetupCommonParams(eventData.weaponVelocity);
    this.m_followPhaseParams = new FollowCurveTrajectoryParams();
    this.StartNextPhase();
    this.m_projectileComponent.SetOnCollisionAction(gameprojectileOnCollisionAction.Stop);
  }

  private final func SetCurrentDamageTrailName() -> Void {
    this.m_weaponID = this.m_owner.GetEntityID();
    let cachedThreshold: Float = this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.PhysicalDamage);
    this.m_trailName = n"trail";
    if this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.ThermalDamage) > cachedThreshold {
      cachedThreshold = this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.ThermalDamage);
      this.m_trailName = n"trail_thermal";
    };
    if this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.ElectricDamage) > cachedThreshold {
      cachedThreshold = this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.ElectricDamage);
      this.m_trailName = n"trail_electric";
    };
    if this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.ChemicalDamage) > cachedThreshold {
      cachedThreshold = this.m_statsSystem.GetStatValue(Cast(this.m_weaponID), gamedataStatType.ChemicalDamage);
      this.m_trailName = n"trail_chemical";
    };
  }

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    let slotComponent: ref<SlotComponent>;
    let slotTransform: WorldTransform;
    let targetEntity: wref<Entity>;
    this.Reset();
    this.m_targeted = true;
    this.m_startPosition = eventData.startPoint;
    this.m_randomWeaponMissChance = RandF();
    this.m_randomTargetMissChance = RandF();
    if IsDefined(eventData.params.trackedTargetComponent) {
      this.m_targetID = eventData.params.trackedTargetComponent.GetEntity().GetEntityID();
    };
    this.SetupCommonParams(eventData.weaponVelocity);
    this.m_followPhaseParams = new FollowCurveTrajectoryParams();
    this.m_followPhaseParams.targetComponent = eventData.params.trackedTargetComponent;
    this.m_followPhaseParams.targetPosition = eventData.params.targetPosition;
    slotComponent = eventData.params.trackedTargetComponent as SlotComponent;
    if IsDefined(slotComponent) {
      slotComponent.GetSlotTransform(n"Head", slotTransform);
      this.m_followPhaseParams.offset = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform)) - Matrix.GetTranslation(eventData.params.trackedTargetComponent.GetLocalToWorld());
    };
    if IsDefined(this.m_followPhaseParams.targetComponent) {
      targetEntity = this.m_followPhaseParams.targetComponent.GetEntity();
      if IsDefined(targetEntity) {
        this.m_targetID = targetEntity.GetEntityID();
        if this.GetInitialDistanceToTarget() > 4.00 && this.m_randomTargetMissChance < ClampF(this.m_statsSystem.GetStatValue(Cast(this.m_targetID), gamedataStatType.SmartTargetingDisruptionProbability), 0.00, 1.00) {
          this.DisableTargetCollisions(this.m_targetID);
        };
      };
    };
    this.m_followPhaseParams.startVelocity = this.m_randStartVelocity;
    this.m_followPhaseParams.offsetInPlane = eventData.params.smartGunSpreadOnHitPlane;
    this.m_followPhaseParams.returnTimeMargin = 0.00;
    this.m_followPhaseParams.accuracy = 0.01;
    this.m_followPhaseParams.bendTimeRatio = this.m_bendTimeRatio;
    this.m_followPhaseParams.bendFactor = this.m_bendFactor;
    this.m_followPhaseParams.interpolationTimeRatio = 0.10;
    this.m_followPhaseParams.offset += eventData.params.hitPlaneOffset;
    this.StartNextPhase();
    this.m_projectileComponent.SetOnCollisionAction(gameprojectileOnCollisionAction.Stop);
  }

  private final func SetupCommonParams(weaponVel: Vector4) -> Void {
    let randVel: Float = RandRangeF(this.m_parabolicVelocityMin, this.m_parabolicVelocityMax);
    this.m_parabolicPhaseParams = ParabolicTrajectoryParams.GetAccelVelParabolicParams(this.m_parabolicGravity, Vector4.Length(weaponVel) + randVel);
    this.m_linearPhaseParams = new LinearTrajectoryParams();
    this.m_linearPhaseParams.startVel = this.m_randStartVelocity;
    this.m_spiralParams.enabled = false;
    this.m_projectileComponent.SetSpiral(this.m_spiralParams);
  }

  private final func StartPhase(phase: ESmartBulletPhase) -> Void {
    let desiredTransform: Transform;
    let leftSideMiss: Bool;
    let localToWorld: Matrix;
    let missParamsRecord: ref<SmartGunMissParams_Record>;
    let missSpiral: ref<SpiralControllerParams>;
    let prevPhase: ESmartBulletPhase;
    let randomPitch: Float;
    let randomYaw: Float;
    let rotation: EulerAngles;
    if NotEquals(this.m_phase, phase) {
      prevPhase = this.m_phase;
      this.m_phase = phase;
      this.m_projectileComponent.ClearTrajectories();
      this.m_timeInPhase = 0.00;
      if Equals(this.m_phase, ESmartBulletPhase.Parabolic) {
        this.m_projectileComponent.AddParabolic(this.m_parabolicPhaseParams);
        this.m_projectileComponent.LockOrientation(true);
      } else {
        if Equals(this.m_phase, ESmartBulletPhase.Follow) {
          this.m_projectileComponent.AddFollowCurve(this.m_followPhaseParams);
          this.m_projectileComponent.LockOrientation(false);
          if this.m_useSpiralParams {
            this.m_spiralParams.enabled = true;
            this.m_projectileComponent.SetSpiral(this.m_spiralParams);
          };
          this.StartTrailEffect();
        } else {
          if Equals(this.m_phase, ESmartBulletPhase.Linear) {
            this.m_projectileComponent.AddLinear(this.m_linearPhaseParams);
            this.m_projectileComponent.LockOrientation(false);
            this.StartTrailEffect();
          } else {
            if Equals(this.m_phase, ESmartBulletPhase.Miss) {
              missParamsRecord = TweakDBInterface.GetSmartGunMissParamsRecord(t"SmartGun.SmartGunMissParams_Default");
              if this.m_shouldStopAndDrop {
                this.m_parabolicPhaseParams = ParabolicTrajectoryParams.GetAccelVelParabolicParams(new Vector4(0.00, 0.00, missParamsRecord.Gravity(), 0.00), 0.00);
                this.m_projectileComponent.AddParabolic(this.m_parabolicPhaseParams);
                this.m_projectileComponent.LockOrientation(true);
                this.m_shouldStopAndDrop = false;
              } else {
                localToWorld = this.m_projectileComponent.GetLocalToWorld();
                leftSideMiss = RandRange(0, 2) == 0;
                randomYaw = leftSideMiss ? RandRangeF(missParamsRecord.AreaToIgnoreHalfYaw(), missParamsRecord.MaxMissAngleYaw()) : RandRangeF(-missParamsRecord.AreaToIgnoreHalfYaw(), missParamsRecord.MinMissAngleYaw());
                randomPitch = RandRangeF(missParamsRecord.MinMissAnglePitch(), missParamsRecord.MaxMissAnglePitch());
                rotation = Matrix.GetRotation(localToWorld);
                rotation.Yaw += randomYaw;
                rotation.Pitch += randomPitch;
                Transform.SetPosition(desiredTransform, Matrix.GetTranslation(localToWorld));
                Transform.SetOrientationEuler(desiredTransform, rotation);
                this.m_projectileComponent.SetDesiredTransform(desiredTransform);
                if this.m_useSpiralParams {
                  missSpiral = new SpiralControllerParams();
                  missSpiral.enabled = true;
                  missSpiral.rampUpDistanceStart = missParamsRecord.SpiralRampUpDistanceStart();
                  missSpiral.rampUpDistanceEnd = missParamsRecord.SpiralRampUpDistanceEnd();
                  missSpiral.radius = missParamsRecord.SpiralRadius();
                  missSpiral.cycleTimeMin = missParamsRecord.SpiralCycleTimeMin();
                  missSpiral.cycleTimeMax = missParamsRecord.SpiralCycleTimeMax();
                  missSpiral.rampDownDistanceStart = missParamsRecord.SpiralRampDownDistanceStart();
                  missSpiral.rampDownDistanceEnd = missParamsRecord.SpiralRampDownDistanceEnd();
                  missSpiral.rampDownFactor = missParamsRecord.SpiralRampDownFactor();
                  missSpiral.randomizePhase = missParamsRecord.SpiralRandomizePhase();
                  this.m_projectileComponent.SetSpiral(missSpiral);
                  this.m_linearPhaseParams.startVel = this.m_linearPhaseParams.startVel * RandRangeF(0.30, 0.50);
                };
                this.m_projectileComponent.AddLinear(this.m_linearPhaseParams);
                this.m_projectileComponent.LockOrientation(false);
              };
              this.StartTrailEffect();
            };
          };
        };
      };
      if Equals(prevPhase, ESmartBulletPhase.Parabolic) {
        GameObjectEffectHelper.StartEffectEvent(this, n"ignition", true);
      };
    };
  }

  private final func StartNextPhase() -> Void {
    if Equals(this.m_phase, ESmartBulletPhase.Init) {
      if this.m_useParabolicPhase {
        this.StartPhase(ESmartBulletPhase.Parabolic);
      } else {
        if this.m_targeted {
          this.StartPhase(ESmartBulletPhase.Follow);
        } else {
          this.StartPhase(ESmartBulletPhase.Linear);
        };
      };
    } else {
      if Equals(this.m_phase, ESmartBulletPhase.Parabolic) {
        if this.m_targeted {
          this.StartPhase(ESmartBulletPhase.Follow);
        } else {
          this.StartPhase(ESmartBulletPhase.Linear);
        };
      } else {
        if Equals(this.m_phase, ESmartBulletPhase.Follow) {
          if this.m_readyToMiss {
            this.StartPhase(ESmartBulletPhase.Miss);
          } else {
            this.StartPhase(ESmartBulletPhase.Linear);
          };
        };
      };
    };
  }

  protected cb func OnTick(eventData: ref<gameprojectileTickEvent>) -> Bool {
    this.m_countTime += eventData.deltaTime;
    this.m_timeInPhase += eventData.deltaTime;
    if this.m_alive && Equals(this.m_phase, ESmartBulletPhase.Follow) {
      this.UpdateReadyToMiss();
      if this.m_readyToMiss {
        this.StartNextPhase();
      };
    };
    if this.m_alive && Equals(this.m_phase, ESmartBulletPhase.Parabolic) && this.m_timeInPhase >= this.m_parabolicDuration {
      this.StartNextPhase();
    };
    if this.m_countTime >= this.m_lifetime {
      this.BulletRelease();
    } else {
      if this.m_countTime >= 0.07 {
        this.m_meshComponent.Toggle(true);
      };
    };
  }

  protected cb func OnCollision(projectileHitEvent: ref<gameprojectileHitEvent>) -> Bool {
    let explosionAttackRecord: ref<Attack_Record>;
    let gameObj: ref<GameObject>;
    let hitInstance: gameprojectileHitInstance;
    let targetHasJammer: Bool = false;
    let damageHitEvent: ref<gameprojectileHitEvent> = new gameprojectileHitEvent();
    let i: Int32 = 0;
    while i < ArraySize(projectileHitEvent.hitInstances) {
      hitInstance = projectileHitEvent.hitInstances[i];
      if this.m_alive {
        gameObj = hitInstance.hitObject as GameObject;
        targetHasJammer = IsDefined(gameObj) && gameObj.HasTag(n"jammer");
        if !targetHasJammer {
          ArrayPush(damageHitEvent.hitInstances, hitInstance);
        };
        if !gameObj.HasTag(n"bullet_no_destroy") && this.m_BulletCollisionEvaluator.HasReportedStopped() && Equals(hitInstance.position, this.m_BulletCollisionEvaluator.GetStoppedPosition()) {
          this.BulletRelease();
          if !this.m_hasExploded && IsDefined(this.m_attack) {
            this.m_hasExploded = true;
            explosionAttackRecord = ProjectileHelper.FindExplosiveHitAttack(this.m_attack.GetRecord());
            if IsDefined(explosionAttackRecord) {
              ProjectileHelper.SpawnExplosionAttack(explosionAttackRecord, this.m_weapon as WeaponObject, this.m_owner, this, hitInstance.position, 0.05);
            };
          };
          if !targetHasJammer && !gameObj.HasTag(n"MeatBag") {
            this.m_countTime = 0.00;
            this.m_alive = false;
            this.m_hit = true;
          } else {
            i += 1;
          };
        } else {
        };
      };
      i += 1;
    };
    if ArraySize(damageHitEvent.hitInstances) > 0 {
      this.DealDamage(damageHitEvent);
    };
  }

  protected cb func OnAcceleratedMovement(eventData: ref<gameprojectileAcceleratedMovementEvent>) -> Bool;

  protected cb func OnLinearMovement(eventData: ref<gameprojectileLinearMovementEvent>) -> Bool {
    if !IsDefined(this.m_owner) || !this.m_owner.IsPlayer() {
      GameInstance.GetAudioSystem(this.GetGame()).TriggerFlyby(this.GetWorldPosition(), this.GetWorldForward(), this.m_projectileSpawnPoint, this.m_weapon);
    };
  }

  private final func DealDamage(eventData: ref<gameprojectileHitEvent>) -> Void {
    let damageEffect: ref<EffectInstance> = this.m_projectileComponent.GetGameEffectInstance();
    EffectData.SetVariant(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.projectileHitEvent, ToVariant(eventData));
    damageEffect.Run();
  }

  protected cb func OnFollowSuccess(eventData: ref<gameprojectileFollowEvent>) -> Bool {
    if !this.m_hit {
      this.StartNextPhase();
    };
  }

  private final func BulletRelease() -> Void {
    this.m_meshComponent.Toggle(false);
    GameObjectEffectHelper.BreakEffectLoopEvent(this, this.m_trailName);
    this.Release();
  }

  private final func UpdateReadyToMiss() -> Void {
    let ammoID: TweakDBID;
    let audioEventName: CName;
    let bulletDeflectedEvent: ref<SmartBulletDeflectedEvent>;
    let distanceToTarget: Float;
    let projectileLocalToWorld: Matrix;
    let targetMissProbability: Float;
    let targetPosition: Vector4;
    let weaponRecord: ref<WeaponItem_Record>;
    this.m_readyToMiss = false;
    if this.GetInitialDistanceToTarget() > 4.00 {
      this.m_readyToMiss = this.m_randomWeaponMissChance > this.m_smartGunHitProbability;
      if !this.m_readyToMiss && EntityID.IsDefined(this.m_targetID) {
        targetMissProbability = ClampF(this.m_statsSystem.GetStatValue(Cast(this.m_targetID), gamedataStatType.SmartTargetingDisruptionProbability), 0.00, 1.00);
        if this.m_randomTargetMissChance < targetMissProbability {
          projectileLocalToWorld = this.m_projectileComponent.GetLocalToWorld();
          targetPosition = IsDefined(this.m_followPhaseParams.targetComponent) ? Matrix.GetTranslation(this.m_followPhaseParams.targetComponent.GetLocalToWorld()) : this.m_followPhaseParams.targetPosition;
          distanceToTarget = Vector4.Length(targetPosition - Matrix.GetTranslation(projectileLocalToWorld));
          if distanceToTarget < this.m_smartGunMissRadius {
            this.m_readyToMiss = true;
            this.m_shouldStopAndDrop = this.m_stopAndDropOnTargetingDisruption;
            bulletDeflectedEvent = new SmartBulletDeflectedEvent();
            bulletDeflectedEvent.localToWorld = projectileLocalToWorld;
            bulletDeflectedEvent.instigator = this.m_owner;
            bulletDeflectedEvent.weapon = this.m_weapon;
            weaponRecord = TweakDBInterface.GetWeaponItemRecord(GameObject.GetTDBID(this.m_weapon));
            ammoID = weaponRecord.Ammo().GetID();
            audioEventName = n"unknown_bullet_type";
            if ammoID == t"Ammo.SmartHighMissile" {
              audioEventName = n"w_gun_flyby_smart_large_jammed";
            } else {
              if ammoID == t"Ammo.SmartLowMissile" {
                audioEventName = n"w_gun_flyby_smart_small_jammed";
              } else {
                if ammoID == t"Ammo.SmartSplitMissile" {
                  audioEventName = n"w_gun_flyby_smart_shotgun_jammed";
                };
              };
            };
            GameObject.PlaySoundEvent(this, audioEventName);
            this.m_followPhaseParams.targetComponent.GetEntity().QueueEvent(bulletDeflectedEvent);
          };
        };
      };
      if this.m_readyToMiss {
        this.DisableTargetCollisions(this.m_targetID);
      } else {
        this.EnableTargetCollisions(this.m_targetID);
      };
    };
  }

  private final func EnableTargetCollisions(targetID: EntityID) -> Void {
    if EntityID.IsDefined(targetID) && targetID == this.m_ignoredTargetID {
      this.m_projectileComponent.RemoveIgnoredEntity(this.m_ignoredTargetID);
      this.m_ignoredTargetID = EMPTY_ENTITY_ID();
    };
  }

  private final func DisableTargetCollisions(targetID: EntityID) -> Void {
    if EntityID.IsDefined(targetID) && targetID != this.m_ignoredTargetID {
      this.m_ignoredTargetID = targetID;
      this.m_projectileComponent.AddIgnoredEntity(this.m_ignoredTargetID);
    };
  }

  private final func GetInitialDistanceToTarget() -> Float {
    let targetPosition: Vector4 = Matrix.GetTranslation(this.m_followPhaseParams.targetComponent.GetLocalToWorld());
    let distanceToTarget: Float = Vector4.Length(targetPosition - this.m_startPosition);
    return distanceToTarget;
  }
}
