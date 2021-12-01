
public class BaseGrenade extends WeaponGrenade {

  protected let m_projectileComponent: ref<ProjectileComponent>;

  protected let m_user: wref<GameObject>;

  protected let m_projectileSpawnPoint: Vector4;

  protected let m_shootCollision: ref<SimpleColliderComponent>;

  protected let m_visualComponent: ref<IComponent>;

  protected let m_stickyMeshComponent: ref<IComponent>;

  protected let m_decalsStickyComponent: ref<IComponent>;

  protected let m_homingMeshComponent: ref<IComponent>;

  protected let m_targetingComponent: ref<TargetingComponent>;

  protected let m_resourceLibraryComponent: ref<ResourceLibraryComponent>;

  protected let m_mappinID: NewMappinID;

  protected let m_timeSinceLaunch: Float;

  protected let m_detonationTimer: Float;

  protected let m_stickyTrackerTimeout: Float;

  protected let m_timeOfFreezing: Float;

  protected let m_queueFailDetonationDelayID: DelayID;

  protected let m_delayToDetonate: Float;

  protected let m_detonationTimerActive: Bool;

  @default(BaseGrenade, true)
  protected let m_isAlive: Bool;

  @default(BaseGrenade, false)
  protected let m_delayingDetonation: Bool;

  @default(BaseGrenade, false)
  protected let m_landedOnGround: Bool;

  protected let m_isStuck: Bool;

  protected let m_isTracking: Bool;

  protected let m_isLockingOn: Bool;

  protected let m_isLockedOn: Bool;

  protected let m_readyToTrack: Bool;

  protected let m_lockOnFailed: Bool;

  protected let m_canBeShot: Bool;

  protected let m_shotDownByThePlayer: Bool;

  protected let m_forceExplosion: Bool;

  protected let m_hasClearedIgnoredObject: Bool;

  protected let m_detonateOnImpact: Bool;

  protected let m_setStickyTracker: Bool;

  protected let m_isContinuousEffect: Bool;

  protected let m_additionalAttackOnDetonate: Bool;

  protected let m_additionalAttackOnCollision: Bool;

  @default(BaseGrenade, false)
  protected let m_targetAcquired: Bool;

  protected let m_collidedWithNPC: Bool;

  protected let m_isBroadcastingStim: Bool;

  protected let m_playingFastBeep: Bool;

  protected let m_targetTracker: ref<EffectInstance>;

  protected let m_trackedTargets: array<wref<ScriptedPuppet>>;

  protected let m_potentialHomingTargets: array<GrenadePotentialHomingTarget>;

  protected let m_homingGrenadeTarget: GrenadePotentialHomingTarget;

  protected let m_cuttingGrenadePotentialTargets: array<CuttingGrenadePotentialTarget>;

  protected let m_cuttingGrenadePotentialTarget: CuttingGrenadePotentialTarget;

  protected let m_stickedTarget: wref<ScriptedPuppet>;

  protected let m_drillTargetPosition: Vector4;

  protected let m_attacksSpawned: array<ref<EffectInstance>>;

  protected let m_tweakRecord: ref<Grenade_Record>;

  private edit let m_additionalEffect: FxResource;

  protected let m_landedCooldownActive: Bool;

  protected let m_landedCooldownTimer: Float;

  @default(BaseGrenade, 3.0f)
  protected let m_cpoTimeBeforeRelease: Float;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"projectileComponent", n"ProjectileComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"StimBroadcaster", n"StimBroadcasterComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ShootCollision", n"SimpleColliderComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"GrenadeBody", n"IComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"homing_mesh", n"IComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"sticky_mesh", n"IComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"sticky_decals", n"IComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"targetingComponent", n"TargetingComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ResourceLibrary", n"ResourceLibraryComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_projectileComponent = EntityResolveComponentsInterface.GetComponent(ri, n"projectileComponent") as ProjectileComponent;
    this.m_shootCollision = EntityResolveComponentsInterface.GetComponent(ri, n"ShootCollision") as SimpleColliderComponent;
    this.m_visualComponent = EntityResolveComponentsInterface.GetComponent(ri, n"GrenadeBody");
    this.m_stickyMeshComponent = EntityResolveComponentsInterface.GetComponent(ri, n"sticky_mesh");
    this.m_decalsStickyComponent = EntityResolveComponentsInterface.GetComponent(ri, n"sticky_decals");
    this.m_homingMeshComponent = EntityResolveComponentsInterface.GetComponent(ri, n"homing_mesh");
    this.m_targetingComponent = EntityResolveComponentsInterface.GetComponent(ri, n"targetingComponent") as TargetingComponent;
    this.m_resourceLibraryComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ResourceLibrary") as ResourceLibraryComponent;
  }

  protected final func PreloadAttackResources() -> Void {
    let effectSystem: ref<EffectSystem> = GameInstance.GetGameEffectSystem(this.GetGame());
    PreloadGameEffectAttackResources(this.m_tweakRecord.Attack() as Attack_GameEffect_Record, effectSystem);
    PreloadGameEffectAttackResources(this.m_tweakRecord.AdditionalAttack() as Attack_GameEffect_Record, effectSystem);
    PreloadGameEffectAttackResources(this.m_tweakRecord.EnemyAttack() as Attack_GameEffect_Record, effectSystem);
    PreloadGameEffectAttackResources(TweakDBInterface.GetAttackRecord(t"Attacks.ReconGrenadeBeams") as Attack_GameEffect_Record, effectSystem);
  }

  protected final func ReleaseAttackResources() -> Void {
    let effectSystem: ref<EffectSystem> = GameInstance.GetGameEffectSystem(this.GetGame());
    ReleaseGameEffectAttackResources(this.m_tweakRecord.Attack() as Attack_GameEffect_Record, effectSystem);
    ReleaseGameEffectAttackResources(this.m_tweakRecord.AdditionalAttack() as Attack_GameEffect_Record, effectSystem);
    ReleaseGameEffectAttackResources(this.m_tweakRecord.EnemyAttack() as Attack_GameEffect_Record, effectSystem);
    ReleaseGameEffectAttackResources(TweakDBInterface.GetAttackRecord(t"Attacks.ReconGrenadeBeams") as Attack_GameEffect_Record, effectSystem);
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    if this.IsConnectedWithDrop() {
      this.SetThrowableAnimFeatureOnGrenade(3, this);
    };
  }

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool {
    this.m_user = eventData.owner;
    this.m_tweakRecord = TweakDBInterface.GetGrenadeRecord(ItemID.GetTDBID(this.GetItemID()));
    this.deliveryMethod = this.m_tweakRecord.DeliveryMethod().Type().Type();
    this.Reset();
    this.SetupDeliveryMethodMesh();
    this.m_projectileComponent.SetEnergyLossFactor(this.m_tweakRecord.DeliveryMethod().Bounciness(), 0.11);
    if Cast(GameInstance.GetStatsSystem(this.m_user.GetGame()).GetStatValue(Cast(this.m_user.GetEntityID()), gamedataStatType.CanSeeGrenadeRadius)) {
      this.m_projectileComponent.SetExplosionVisualRadius(this.GetAttackRadius());
    };
    this.PreloadAttackResources();
  }

  protected func Reset() -> Void {
    this.m_isAlive = true;
    this.m_isStuck = false;
    this.m_isTracking = false;
    this.m_timeSinceLaunch = 0.00;
    this.m_hasClearedIgnoredObject = false;
    this.m_isLockingOn = false;
    this.m_isLockedOn = false;
    this.m_lockOnFailed = false;
    this.m_landedCooldownActive = false;
    this.m_shotDownByThePlayer = false;
    this.m_drillTargetPosition = new Vector4(0.00, 0.00, 0.00, 0.00);
    this.lastHitNormal = new Vector4(0.00, 0.00, 0.00, 0.00);
    this.m_isContinuousEffect = TweakDBInterface.GetBool(ItemID.GetTDBID(this.GetItemID()) + t".isContinuousEffect", false);
    this.m_delayToDetonate = TweakDBInterface.GetFloat(ItemID.GetTDBID(this.GetItemID()) + t".delayToDetonate", 0.10);
    this.m_setStickyTracker = TweakDBInterface.GetBool(ItemID.GetTDBID(this.GetItemID()) + t".setStickyTracker", false);
    this.m_stickyTrackerTimeout = TweakDBInterface.GetFloat(ItemID.GetTDBID(this.GetItemID()) + t".stickyTrackerTimeout", 10.00);
    this.m_additionalAttackOnDetonate = TweakDBInterface.GetBool(ItemID.GetTDBID(this.GetItemID()) + t".additionalAttackOnDetonate", false);
    this.m_additionalAttackOnCollision = TweakDBInterface.GetBool(ItemID.GetTDBID(this.GetItemID()) + t".additionalAttackOnCollision", false);
    this.SetCanBeShot(false);
    if IsDefined(this.m_targetingComponent) && IsDefined(this.m_user as NPCPuppet) {
      this.m_targetingComponent.Toggle(true);
    };
    if IsDefined(this.m_visualComponent) {
      this.m_visualComponent.Toggle(true);
    };
    if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Regular) {
      this.m_detonationTimerActive = true;
    };
    if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Sticky) {
      this.m_detonationTimerActive = true;
      this.m_projectileComponent.SetOnCollisionAction(gameprojectileOnCollisionAction.StopAndStick);
    };
    this.m_detonationTimer = 0.00;
    if this.IsGrenadeOfType(EGrenadeType.Piercing) {
      this.m_projectileComponent.SetOnCollisionAction(gameprojectileOnCollisionAction.StopAndStickPerpendicular);
    };
    if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Homing) {
      this.m_timeOfFreezing = (this.m_tweakRecord.DeliveryMethod() as HomingGDM_Record).FreezeDelay();
    };
    this.InitializeRotation();
  }

  protected final func SetupDeliveryMethodMesh() -> Void {
    if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Sticky) {
      this.m_stickyMeshComponent.Toggle(true);
      this.m_decalsStickyComponent.Toggle(true);
    } else {
      if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Homing) {
        this.m_homingMeshComponent.Toggle(true);
      };
    };
  }

  private final func GetAttackRadius() -> Float {
    let data: wref<gameItemData> = this.GetItemData();
    let value: Float = data.GetStatValueByType(gamedataStatType.Range);
    return value;
  }

  public final func GetInitialVelocity(isQuickThrow: Bool) -> Float {
    let initialVelocity: Float;
    let tweakRecord: ref<Grenade_Record> = TweakDBInterface.GetGrenadeRecord(ItemID.GetTDBID(this.GetItemID()));
    if !isQuickThrow {
      initialVelocity = tweakRecord.DeliveryMethod().InitialVelocity();
    } else {
      initialVelocity = tweakRecord.DeliveryMethod().InitialQuickThrowVelocity();
    };
    return initialVelocity;
  }

  public final func GetAccelerationZ() -> Float {
    let tweakRecord: ref<Grenade_Record> = TweakDBInterface.GetGrenadeRecord(ItemID.GetTDBID(this.GetItemID()));
    return tweakRecord.DeliveryMethod().AccelerationZ();
  }

  public final func SetCanBeShot(canBeShot: Bool) -> Void {
    this.m_canBeShot = canBeShot;
    if this.m_shootCollision != null {
      if this.m_canBeShot {
        this.m_shootCollision.Resize(this.GetShootCollisionSize(), 0u);
      };
      this.m_shootCollision.Toggle(this.m_canBeShot);
    };
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    let detonateRequest: ref<GrenadeDetonateRequestEvent>;
    let grenadeData: ref<GrenadeMappinData>;
    let grenadeMappinData: MappinData;
    let grenadeType: EGrenadeType;
    let mappinSystem: ref<MappinSystem>;
    let spawnBlinkEffectRequest: ref<CuttingGrenadeSpawnBlinkEffectEvent>;
    this.m_projectileSpawnPoint = eventData.startPoint;
    GameObject.PlayVoiceOver(eventData.owner, n"grenade_throw", n"Scripts:Grenade_OnShoot");
    this.Reset();
    if this.m_user != null && this.m_mappinID.value == 0u {
      grenadeType = this.GetGrenadeType();
      grenadeData = new GrenadeMappinData();
      grenadeData.m_grenadeType = grenadeType;
      grenadeData.m_iconID = this.GetMappinIconIDForGrenadeType(grenadeType);
      mappinSystem = GameInstance.GetMappinSystem(this.m_user.GetGame());
      grenadeMappinData.mappinType = t"Mappins.InteractionMappinDefinition";
      grenadeMappinData.variant = gamedataMappinVariant.GrenadeVariant;
      grenadeMappinData.active = true;
      grenadeMappinData.scriptData = grenadeData;
      this.m_mappinID = mappinSystem.RegisterGrenadeMappin(grenadeMappinData, this);
    };
    if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Regular) && !this.m_isContinuousEffect {
      this.SetTracking(true);
      if this.m_tweakRecord.DeliveryMethod().TrackingRadius() > 0.00 {
        GameObject.StartReplicatedEffectEvent(this, n"fx_regular_scanning", true, false);
      };
    };
    if this.m_isContinuousEffect {
      spawnBlinkEffectRequest = new CuttingGrenadeSpawnBlinkEffectEvent();
      detonateRequest = new GrenadeDetonateRequestEvent();
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, spawnBlinkEffectRequest, this.m_delayToDetonate - 0.40, true);
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, detonateRequest, this.m_delayToDetonate, true);
    };
    if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Sticky) {
      this.PlayStickyGrenadeLongBeepSound();
    };
    this.PlayNPCGrenadeBeepSound();
  }

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    this.OnShoot(eventData);
  }

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool {
    let impactSpeed: Float;
    let puppetTarget: ref<ScriptedPuppet>;
    let tags: array<CName>;
    let hitInstance: gameprojectileHitInstance = eventData.hitInstances[0];
    if this.m_isAlive {
      puppetTarget = hitInstance.hitObject as ScriptedPuppet;
      this.lastHitNormal = Cast(hitInstance.traceResult.normal);
      if !this.m_landedOnGround && Vector4.GetAngleBetween(this.lastHitNormal, new Vector4(0.00, 0.00, 1.00, 0.00)) < 35.00 {
        this.m_landedOnGround = true;
      };
      if !GameObject.IsCooldownActive(this, n"grenade_impact_sound") {
        impactSpeed = Vector4.Length(hitInstance.velocity);
        GameObject.SetAudioParameter(this, n"ph_impact_velocity", impactSpeed);
        tags = this.m_tweakRecord.Tags();
        if ArrayContains(tags, n"Ozob") {
          GameObject.PlaySound(this, n"gre_impact_solid_ozob");
        } else {
          GameObject.PlaySound(this, n"gre_impact_solid");
        };
        GameObject.StartCooldown(this, n"grenade_impact_sound", 0.20);
      };
      if this.IsGrenadeOfType(EGrenadeType.Piercing) && (NotEquals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Homing) || this.m_targetAcquired) {
        if this.m_additionalAttackOnCollision && IsDefined(puppetTarget) {
          this.SpawnOnPuppetCollisionAttack(this.m_tweakRecord.AdditionalAttack(), puppetTarget);
        } else {
          GameObject.StartReplicatedEffectEvent(this, n"fx_drill", true, true);
        };
        this.DrillThrough(hitInstance);
      } else {
        if this.m_additionalAttackOnCollision && this.m_targetAcquired {
          if IsDefined(puppetTarget) {
            this.SpawnOnPuppetCollisionAttack(this.m_tweakRecord.AdditionalAttack(), puppetTarget);
          };
          this.Detonate(this.lastHitNormal);
        } else {
          if this.m_detonateOnImpact {
            this.Detonate(this.lastHitNormal);
          } else {
            if !this.m_isBroadcastingStim {
              this.TriggerGrenadeLandedStimuli(true);
            };
            if !this.m_collidedWithNPC && IsDefined(puppetTarget) && this.m_tweakRecord.DeliveryMethod().TrackingRadius() == 0.00 {
              this.m_collidedWithNPC = true;
              this.SpawnAttack(this.m_tweakRecord.NpcHitReactionAttack());
            };
            if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Sticky) {
              GameObject.StartReplicatedEffectEvent(this, n"fx_sticky", true, true);
              GameObject.PlaySound(this, n"grenade_stick");
              this.m_isStuck = true;
            };
            if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Homing) && !this.m_isTracking {
              this.m_timeOfFreezing = this.m_timeSinceLaunch + (this.m_tweakRecord.DeliveryMethod() as HomingGDM_Record).FreezeDelayAfterBounce();
            } else {
              if this.IsGrenadeOfType(EGrenadeType.Cutting) && !this.m_isTracking && this.m_delayToDetonate + this.m_tweakRecord.AttackDuration() - this.m_timeSinceLaunch > 0.50 {
                this.m_timeOfFreezing = this.m_timeSinceLaunch + TweakDBInterface.GetFloat(ItemID.GetTDBID(this.GetItemID()) + t".freezeDelayAfterBounce", 0.10);
              };
            };
          };
        };
      };
    };
  }

  protected cb func OnForceActivation(evt: ref<gameprojectileForceActivationEvent>) -> Bool {
    this.m_forceExplosion = true;
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    let detonateRequest: ref<GrenadeDetonateRequestEvent>;
    let instigatorIsPlayer: Bool;
    if this.m_isAlive {
      instigatorIsPlayer = evt.attackData.GetInstigator() == GetPlayer(this.GetGame());
      if instigatorIsPlayer && this.m_canBeShot {
        this.m_shotDownByThePlayer = true;
        this.CheckForGunslingerAchievement(evt.attackData);
        this.Detonate();
      } else {
        if this.m_isStuck && evt.attackData.HasFlag(hitFlag.DetonateGrenades) && !this.m_delayingDetonation {
          detonateRequest = new GrenadeDetonateRequestEvent();
          GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, detonateRequest, Vector4.Distance(this.GetWorldPosition(), evt.attackData.GetAttackPosition()) / 5.00, true);
          this.m_delayingDetonation = true;
        };
      };
    };
  }

  protected final func CheckForGunslingerAchievement(attackData: ref<AttackData>) -> Void {
    let achievementRequest: ref<AddAchievementRequest>;
    let achievement: gamedataAchievement = gamedataAchievement.Gunslinger;
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    if dataTrackingSystem.IsAchievementUnlocked(achievement) {
      return;
    };
    if Equals(WeaponObject.GetWeaponType(attackData.GetWeapon().GetItemID()), gamedataItemType.Wea_Revolver) {
      if Equals(GameObject.GetAttitudeTowards(this.m_user, GetPlayer(this.GetGame())), EAIAttitude.AIA_Hostile) {
        if !this.m_landedOnGround {
          achievementRequest = new AddAchievementRequest();
          achievementRequest.achievement = achievement;
          dataTrackingSystem.QueueRequest(achievementRequest);
        };
      };
    };
  }

  protected cb func OnTick(eventData: ref<gameprojectileTickEvent>) -> Bool {
    if this.m_detonationTimerActive {
      this.m_detonationTimer += eventData.deltaTime;
    };
    if this.m_landedCooldownActive {
      this.m_landedCooldownTimer += eventData.deltaTime;
      if this.m_landedCooldownTimer >= 1.00 {
        this.m_landedCooldownActive = false;
        this.m_landedCooldownTimer = 0.00;
      };
    };
    this.m_timeSinceLaunch += eventData.deltaTime;
    if this.m_isAlive && !this.m_isContinuousEffect {
      if this.m_forceExplosion {
        this.Detonate();
      } else {
        if this.m_detonationTimerActive && this.m_detonationTimer >= this.m_tweakRecord.DeliveryMethod().DetonationTimer() {
          this.Detonate(this.lastHitNormal);
        } else {
          if !this.m_hasClearedIgnoredObject && this.m_timeSinceLaunch >= 0.15 {
            this.m_hasClearedIgnoredObject = true;
            this.m_projectileComponent.ClearIgnoredEntities();
          } else {
            if this.m_tweakRecord.ShootCollisionEnableDelay() >= 0.00 && this.m_shootCollision != null && this.m_timeSinceLaunch >= this.m_tweakRecord.ShootCollisionEnableDelay() && Equals(this.m_canBeShot, false) {
              this.SetCanBeShot(true);
            };
          };
        };
      };
      if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Sticky) {
        if this.m_tweakRecord.DeliveryMethod().DetonationTimer() - this.m_detonationTimer <= 1.00 && !this.m_playingFastBeep {
          this.PlayStickyGrenadeShortBeepSound();
        };
      } else {
        if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Homing) {
          if this.m_timeSinceLaunch >= this.m_timeOfFreezing && !this.m_isLockingOn && !this.m_lockOnFailed {
            this.DelayTargetTrackingStateChange(true, 1.00);
            this.Freeze();
            this.FloatToLockOnAltitude();
            if !this.m_isBroadcastingStim {
              this.TriggerGrenadeLandedStimuli(true);
            };
            GameObject.StartReplicatedEffectEvent(this, n"homing_thrust", true, false);
            this.m_isLockingOn = true;
            this.m_timeOfFreezing += 1.00;
          } else {
            if this.m_isLockingOn && this.m_timeSinceLaunch - this.m_timeOfFreezing >= (this.m_tweakRecord.DeliveryMethod() as HomingGDM_Record).LockOnDelay() && !this.m_readyToTrack {
              this.m_readyToTrack = true;
              if this.m_targetAcquired {
                this.QueueSmartTrajectory((this.m_tweakRecord.DeliveryMethod() as HomingGDM_Record).LockOnDelay());
              };
            } else {
              if this.m_isLockingOn && this.m_timeSinceLaunch - this.m_timeOfFreezing >= (this.m_tweakRecord.DeliveryMethod() as HomingGDM_Record).FreezeDuration() && !this.m_targetAcquired {
                this.DropToFloor();
                this.SetTracking(false);
                this.QueueFailDetonation();
                GameObject.StopReplicatedEffectEvent(this, n"homing_thrust");
                this.m_isLockingOn = false;
                this.m_lockOnFailed = true;
              };
            };
          };
        };
      };
    };
    if this.IsGrenadeOfType(EGrenadeType.Cutting) && this.m_timeOfFreezing > 0.00 && this.m_timeSinceLaunch > this.m_timeOfFreezing && !this.m_isLockingOn {
      this.FloatCuttingGrenadeUp();
      GameObject.StartReplicatedEffectEvent(this, n"homing_thrust", true, false);
      if !this.m_isBroadcastingStim {
        this.TriggerGrenadeLandedStimuli(true);
      };
      this.m_isLockingOn = true;
    };
    if this.m_isContinuousEffect && this.m_timeSinceLaunch >= this.m_tweakRecord.AttackDuration() {
      if this.IsGrenadeOfType(EGrenadeType.Cutting) && !this.m_lockOnFailed {
        this.StopCuttingGrenadeAttack();
      } else {
        if !this.IsGrenadeOfType(EGrenadeType.Cutting) {
          this.Release(true);
        };
      };
    };
    this.OnServerTick(eventData);
  }

  protected final func OnServerTick(eventData: ref<gameprojectileTickEvent>) -> Void {
    if GameInstance.GetRuntimeInfo(this.GetGame()).IsServer() {
      if !this.m_isAlive && this.m_timeSinceLaunch >= this.m_cpoTimeBeforeRelease {
        this.Release();
      };
    };
  }

  protected func Detonate(opt hitNormal: Vector4) -> Void {
    let additionalEffect: ref<EffectInstance>;
    let detonationLocation: Vector4;
    let effect: ref<EffectInstance>;
    let localOffset: Vector4;
    this.SetCanBeShot(false);
    if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Homing) {
      GameObject.StopReplicatedEffectEvent(this, n"fx_homing_freeze");
      GameObject.StopReplicatedEffectEvent(this, n"homing_thrust");
      if IsDefined(this.m_homingGrenadeTarget.entity) {
        GameObject.SendForceRevealObjectEvent(this.m_homingGrenadeTarget.entity, false, n"HomingGrenade");
      };
    } else {
      if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Sticky) {
        this.StopStickyGrenadeSounds();
        if this.m_tweakRecord.RemoveMeshOnDetonation() {
          GameObject.StopReplicatedEffectEvent(this, n"fx_sticky");
        };
      };
    };
    if this.IsGrenadeOfType(EGrenadeType.Cutting) {
      this.SpawnLaserAttack(this.m_tweakRecord.Attack(), 21, this.GetAttackRadius(), this.m_tweakRecord.AttackDuration(), false, 0.04);
    } else {
      effect = this.SpawnAttack(this.m_tweakRecord.Attack(), this.GetAttackRadius(), this.m_tweakRecord.AttackDuration(), hitNormal);
      effect.AttachToEntity(this, GetAllBlackboardDefs().EffectSharedData.position, localOffset);
      if this.IsGrenadeOfType(EGrenadeType.Recon) {
        this.SpawnLaserAttack(TweakDBInterface.GetAttackRecord(t"Attacks.ReconGrenadeBeams"), 7, this.GetAttackRadius(), this.m_tweakRecord.AttackDuration(), true);
        additionalEffect = this.SpawnAttack(this.m_tweakRecord.AdditionalAttack(), this.GetAttackRadius() / 2.00, this.m_tweakRecord.AttackDuration(), hitNormal);
        additionalEffect.AttachToEntity(this, GetAllBlackboardDefs().EffectSharedData.position);
      };
    };
    if this.m_additionalAttackOnDetonate {
      additionalEffect = this.SpawnAttack(this.m_tweakRecord.AdditionalAttack(), this.m_tweakRecord.AdditionalAttack().Range(), 0.00, hitNormal);
      additionalEffect.AttachToEntity(this, GetAllBlackboardDefs().EffectSharedData.position);
    };
    this.SpawnVisualEffectsOnDetonation();
    this.RemoveGrenadeLandedStimuli();
    if !this.IsGrenadeOfType(EGrenadeType.Recon) && !this.IsGrenadeOfType(EGrenadeType.Cutting) {
      this.SendCombatGadgetIsAliveFeature();
    };
    GameObject.PlayMetadataEvent(this, StringToName(this.m_tweakRecord.DetonationSound()));
    GameObject.PlaySound(this, TDB.GetCName(t"rumble.world.heavy_slow"));
    this.StopNPCGrenadeBeepSound();
    GameInstance.GetAudioSystem(this.GetGame()).PlayShockwave(StringToName(this.m_tweakRecord.DetonationSound()), detonationLocation);
    this.TriggerStimuli();
    if IsDefined(this.m_visualComponent) && this.m_tweakRecord.RemoveMeshOnDetonation() {
      this.m_visualComponent.Toggle(false);
    };
    if IsDefined(this.m_stickyMeshComponent) && this.m_tweakRecord.RemoveMeshOnDetonation() {
      this.m_stickyMeshComponent.Toggle(false);
      this.m_decalsStickyComponent.Toggle(false);
    };
    if IsDefined(this.m_homingMeshComponent) && this.m_tweakRecord.RemoveMeshOnDetonation() {
      this.m_homingMeshComponent.Toggle(false);
    };
    this.OnExplosion();
    if this.m_tweakRecord.ReleaseOnDetonation() {
      this.Release();
    };
    if this.m_queueFailDetonationDelayID != GetInvalidDelayID() {
      GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_queueFailDetonationDelayID);
    };
    this.m_delayingDetonation = false;
  }

  protected final func SendCombatGadgetIsAliveFeature() -> Void {
    let animFeature: ref<AnimFeature_CombatGadget> = new AnimFeature_CombatGadget();
    animFeature.isDetonated = true;
    AnimationControllerComponent.ApplyFeature(this, n"Grenade", animFeature);
  }

  protected final func SetThrowableAnimFeatureOnGrenade(newState: Int32, target: wref<GameObject>) -> Void {
    let feature: ref<AnimFeature_Throwable> = new AnimFeature_Throwable();
    feature.state = newState;
    AnimationControllerComponent.ApplyFeature(this, n"CombatGadget", feature);
  }

  protected func SpawnVisualEffectsOnDetonation() -> Void {
    if this.IsGrenadeOfType(EGrenadeType.Incendiary) {
      this.SpawnEffectOnGround(this.m_resourceLibraryComponent.GetResource(n"incendiary_ground_effect"));
    } else {
      if this.IsGrenadeOfType(EGrenadeType.Piercing) {
        this.SpawnPiercingExplosion();
      };
    };
  }

  protected cb func OnCuttingGrenadeSpawnBlinkEffectEvent(evt: ref<CuttingGrenadeSpawnBlinkEffectEvent>) -> Bool {
    GameObject.StartReplicatedEffectEvent(this, n"fx_diode", true, false);
  }

  protected cb func OnCuttingGrenadeDespawnEffectsEvent(evt: ref<CuttingGrenadeDespawnEffectsEvent>) -> Bool {
    GameObjectEffectHelper.BreakEffectLoopEvent(this, n"fx_laser");
  }

  public final static func SendGrenadeAnimFeatureChangeEvent(owner: wref<GameObject>, itemID: ItemID) -> Void {
    let evt: ref<GrenadeAnimFeatureChangeEvent>;
    let item: wref<ItemObject>;
    if !IsDefined(owner) {
      return;
    };
    item = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemInSlotByItemID(owner, itemID);
    if !IsDefined(item) {
      return;
    };
    evt = new GrenadeAnimFeatureChangeEvent();
    evt.newState = 1;
    item = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemInSlotByItemID(owner, itemID);
    item.QueueEvent(evt);
  }

  protected cb func OnGrenadeAnimFeatureChange(evt: ref<GrenadeAnimFeatureChangeEvent>) -> Bool {
    this.SetThrowableAnimFeatureOnGrenade(evt.newState, this);
  }

  protected final func SpawnEffectFromLibrary(key: CName) -> Void {
    let transform: WorldTransform;
    let effect: FxResource = this.m_resourceLibraryComponent.GetResource(key);
    if FxResource.IsValid(effect) {
      WorldTransform.SetPosition(transform, this.GetWorldPosition());
      WorldTransform.SetOrientationFromDir(transform, Quaternion.GetForward(this.GetWorldOrientation()));
      GameInstance.GetFxSystem(this.GetGame()).SpawnEffect(effect, transform);
    };
  }

  protected func SpawnEffectOnGround(groundEffect: FxResource) -> Void {
    let ground: Vector4;
    let transform: WorldTransform;
    if FxResource.IsValid(groundEffect) && IsDefined(this.m_user) {
      WorldTransform.SetPosition(transform, this.GetWorldPosition());
      ground = this.m_user.GetWorldForward();
      ground.Z = 0.00;
      WorldTransform.SetOrientationFromDir(transform, ground);
      GameInstance.GetFxSystem(this.GetGame()).SpawnEffectOnGround(groundEffect, transform, 2.50);
    };
  }

  protected func SpawnPiercingExplosion() -> Void {
    let transform: WorldTransform;
    if FxResource.IsValid(this.m_additionalEffect) && IsDefined(this.m_user) {
      if !Vector4.IsZero(this.m_drillTargetPosition) {
        WorldTransform.SetPosition(transform, this.m_drillTargetPosition);
      } else {
        WorldTransform.SetPosition(transform, this.GetWorldPosition());
      };
      GameInstance.GetFxSystem(this.GetGame()).SpawnEffect(this.m_additionalEffect, transform);
    };
  }

  protected func IsGrenadeOfType(compareType: EGrenadeType) -> Bool {
    let tags: array<CName> = this.m_tweakRecord.Tags();
    switch compareType {
      case EGrenadeType.Frag:
        return ArrayContains(tags, n"FragGrenade");
      case EGrenadeType.Flash:
        return ArrayContains(tags, n"FlashGrenade");
      case EGrenadeType.Piercing:
        return ArrayContains(tags, n"PiercingGrenade");
      case EGrenadeType.EMP:
        return ArrayContains(tags, n"EMPGrenade");
      case EGrenadeType.Biohazard:
        return ArrayContains(tags, n"BiohazardGrenade");
      case EGrenadeType.Incendiary:
        return ArrayContains(tags, n"IncendiaryGrenade");
      case EGrenadeType.Recon:
        return ArrayContains(tags, n"ReconGrenade");
      case EGrenadeType.Cutting:
        return ArrayContains(tags, n"CuttingGrenade");
      case EGrenadeType.Sonic:
        return ArrayContains(tags, n"SonicGrenade");
      default:
        return false;
    };
  }

  protected final func GetGrenadeType() -> EGrenadeType {
    let returnValue: EGrenadeType;
    let tags: array<CName> = this.m_tweakRecord.Tags();
    if ArrayContains(tags, n"FragGrenade") {
      returnValue = EGrenadeType.Frag;
    } else {
      if ArrayContains(tags, n"FlashGrenade") {
        returnValue = EGrenadeType.Flash;
      } else {
        if ArrayContains(tags, n"PiercingGrenade") {
          returnValue = EGrenadeType.Piercing;
        } else {
          if ArrayContains(tags, n"EMPGrenade") {
            returnValue = EGrenadeType.EMP;
          } else {
            if ArrayContains(tags, n"BiohazardGrenade") {
              returnValue = EGrenadeType.Biohazard;
            } else {
              if ArrayContains(tags, n"IncendiaryGrenade") {
                returnValue = EGrenadeType.Incendiary;
              } else {
                if ArrayContains(tags, n"ReconGrenade") {
                  returnValue = EGrenadeType.Recon;
                } else {
                  if ArrayContains(tags, n"CuttingGrenade") {
                    returnValue = EGrenadeType.Cutting;
                  } else {
                    if ArrayContains(tags, n"SonicGrenade") {
                      returnValue = EGrenadeType.Sonic;
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
    return returnValue;
  }

  protected final func GetMappinIconIDForGrenadeType(type: EGrenadeType) -> TweakDBID {
    let iconID: TweakDBID;
    switch type {
      case EGrenadeType.Frag:
        iconID = t"MappinIcons.GrenadeMappin";
        break;
      case EGrenadeType.Flash:
        iconID = t"MappinIcons.FlashbangGrenadeMappin";
        break;
      case EGrenadeType.Piercing:
        iconID = t"MappinIcons.GrenadeMappin";
        break;
      case EGrenadeType.EMP:
        iconID = t"MappinIcons.EMPGrenadeMappin";
        break;
      case EGrenadeType.Biohazard:
        iconID = t"MappinIcons.BiohazardGrenadeMappin";
        break;
      case EGrenadeType.Incendiary:
        iconID = t"MappinIcons.IncendiaryGrenadeMappin";
        break;
      case EGrenadeType.Recon:
        iconID = t"MappinIcons.ReconGrenadeMappin";
        break;
      case EGrenadeType.Cutting:
        iconID = t"MappinIcons.CuttingGrenadeMappin";
        break;
      case EGrenadeType.Sonic:
        iconID = t"MappinIcons.GrenadeMappin";
        break;
      default:
        iconID = t"MappinIcons.GrenadeMappin";
    };
    return iconID;
  }

  protected final func ShouldUsePlayerAttack() -> Bool {
    let player: wref<GameObject> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject();
    if this.m_user == player || Equals(GameObject.GetAttitudeTowards(this.m_user, player), EAIAttitude.AIA_Friendly) {
      return true;
    };
    return false;
  }

  protected cb func OnFollowSuccess(eventData: ref<gameprojectileFollowEvent>) -> Bool {
    if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Homing) {
      if this.m_isLockedOn {
        this.Detonate();
      } else {
        this.m_projectileComponent.ClearTrajectories();
      };
    };
  }

  protected final func TriggerStimuli() -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let investigateData: stimInvestigateData;
    if this.m_tweakRecord.DetonationStimRadius() > 0.00 {
      broadcaster = this.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        investigateData.attackInstigator = this.GetUser();
        investigateData.attackInstigatorPosition = this.GetUser().GetWorldPosition();
        investigateData.revealsInstigatorPosition = true;
        broadcaster.TriggerSingleBroadcast(this, this.m_tweakRecord.DetonationStimType().Type(), this.m_tweakRecord.DetonationStimRadius(), investigateData);
      };
    };
  }

  protected final func TriggerGrenadeLandedStimuli(hasLifeTime: Bool) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let investigateData: stimInvestigateData;
    this.RemoveGrenadeLandedStimuli();
    if hasLifeTime && this.m_tweakRecord.DeliveryMethod().DetonationTimer() - this.m_detonationTimer <= 0.50 {
      hasLifeTime = false;
    };
    broadcaster = this.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Sticky) || this.IsGrenadeOfType(EGrenadeType.Recon) {
        if !this.m_landedCooldownActive {
          investigateData.attackInstigator = this.GetUser();
          broadcaster.TriggerSingleBroadcast(this, gamedataStimType.ProjectileDistraction, 1.50, investigateData);
          this.m_landedCooldownActive = true;
        };
      } else {
        if hasLifeTime {
          broadcaster.AddActiveStimuli(this, gamedataStimType.GrenadeLanded, this.m_tweakRecord.DeliveryMethod().DetonationTimer() - this.m_detonationTimer - 0.15, this.GetAttackRadius() + 2.00);
          this.m_isBroadcastingStim = true;
        } else {
          broadcaster.TriggerSingleBroadcast(this, gamedataStimType.GrenadeLanded, this.GetAttackRadius() + 2.00);
        };
      };
    };
  }

  protected final func RemoveGrenadeLandedStimuli() -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = this.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.RemoveActiveStimuliByName(this, gamedataStimType.GrenadeLanded);
    };
  }

  protected final func DetermineLandedStimType() -> gamedataStimType {
    if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Sticky) || this.IsGrenadeOfType(EGrenadeType.Recon) {
      return gamedataStimType.ProjectileDistraction;
    };
    return gamedataStimType.GrenadeLanded;
  }

  protected final func SpawnAttack(attackRecord: ref<Attack_Record>, opt range: Float, opt duration: Float, opt hitNormal: Vector4, opt position: Vector4) -> ref<EffectInstance> {
    let attackContext: AttackInitContext;
    let effect: ref<EffectInstance>;
    let flag: SHitFlag;
    let hitCooldown: Float;
    let hitFlags: array<SHitFlag>;
    let statMods: array<ref<gameStatModifierData>>;
    attackContext.record = attackRecord;
    attackContext.instigator = this.m_user;
    attackContext.source = this;
    let attack: ref<Attack_GameEffect> = IAttack.Create(attackContext) as Attack_GameEffect;
    attack.GetStatModList(statMods);
    effect = attack.PrepareAttack(this.m_user);
    if !this.m_shotDownByThePlayer {
      flag.flag = hitFlag.CanDamageSelf;
      flag.source = n"GrenadeDetonation";
      ArrayPush(hitFlags, flag);
      EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.flags, ToVariant(hitFlags));
    };
    if range > 0.00 {
      EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, range);
      EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, range);
    };
    if !Vector4.IsZero(position) {
      EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position);
    } else {
      EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, this.GetWorldPosition());
    };
    if duration > 0.00 {
      EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.duration, duration);
    };
    hitCooldown = TweakDBInterface.GetFloat(ItemID.GetTDBID(this.GetItemID()) + t".effectCooldown", 0.00);
    if hitCooldown > 0.00 {
      EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.hitCooldown, hitCooldown);
    };
    if !Vector4.IsZero(hitNormal) {
      EffectData.SetQuat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.rotation, Quaternion.BuildFromDirectionVector(hitNormal, new Vector4(0.00, 0.00, 1.00, 0.00)));
    };
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(attack));
    attack.StartAttack();
    return effect;
  }

  protected final func SpawnLaserAttack(attackRecord: ref<Attack_Record>, numberOfLasers: Int32, opt range: Float, opt duration: Float, playSlotAnimation: Bool, opt delayPerLaser: Float) -> Void {
    let spawnLaserEvent: ref<SpawnLaserAttackEvent>;
    let i: Int32 = 0;
    while i < numberOfLasers {
      if delayPerLaser <= 0.00 {
        this.SpawnLaserAttackSingle(attackRecord, range, duration, i, playSlotAnimation);
      } else {
        spawnLaserEvent = new SpawnLaserAttackEvent();
        spawnLaserEvent.attackRecord = attackRecord;
        spawnLaserEvent.range = range;
        spawnLaserEvent.duration = duration;
        spawnLaserEvent.index = i;
        spawnLaserEvent.playSlotAnimation = playSlotAnimation;
        GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, spawnLaserEvent, delayPerLaser * Cast(i), true);
      };
      i += 1;
    };
  }

  protected cb func OnSpawnLaserAttackEvent(evt: ref<SpawnLaserAttackEvent>) -> Bool {
    this.SpawnLaserAttackSingle(evt.attackRecord, evt.range, evt.duration, evt.index, evt.playSlotAnimation);
  }

  protected final func SpawnLaserAttackSingle(attackRecord: ref<Attack_Record>, range: Float, duration: Float, index: Int32, playSlotAnimation: Bool) -> Void {
    let effect: ref<EffectInstance> = this.SpawnAttack(attackRecord, range, duration);
    effect.AttachToSlot(this, StringToName("beam_" + index), GetAllBlackboardDefs().EffectSharedData.position, GetAllBlackboardDefs().EffectSharedData.forward);
    if playSlotAnimation {
      this.PlayLaserSlotAnimation(index);
    };
    ArrayPush(this.m_attacksSpawned, effect);
  }

  protected final func TerminateCuttingGrenadeAttack() -> Void {
    let i: Int32 = ArraySize(this.m_attacksSpawned);
    while i >= 0 {
      this.m_attacksSpawned[i].Terminate();
      i -= 1;
    };
  }

  protected final func PlayLaserSlotAnimation(index: Int32) -> Void {
    let transformAnimationPlayEvent: ref<gameTransformAnimationPlayEvent> = new gameTransformAnimationPlayEvent();
    transformAnimationPlayEvent.animationName = StringToName("beam_" + index + "_animation");
    transformAnimationPlayEvent.looping = true;
    transformAnimationPlayEvent.timeScale = 1.00;
    this.GetOwner().QueueEvent(transformAnimationPlayEvent);
  }

  protected func GetShootCollisionSize() -> Vector4 {
    return new Vector4(0.30, 0.30, 0.30, 0.00);
  }

  protected final func RequestGrenadeRelease(delay: Float) -> Void {
    let releaseRequestEvent: ref<GrenadeReleaseRequestEvent> = new GrenadeReleaseRequestEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, releaseRequestEvent, delay, true);
  }

  protected cb func OnReleaseRequestEvent(evt: ref<GrenadeReleaseRequestEvent>) -> Bool {
    this.Release(true);
  }

  protected final func Release(opt isInstant: Bool) -> Void {
    let delay: Float;
    let despawnRequest: ref<GrenadeDespawnRequestEvent>;
    if this.m_mappinID.value != 0u && this.m_user != null {
      GameInstance.GetMappinSystem(this.m_user.GetGame()).UnregisterMappin(this.m_mappinID);
      this.m_mappinID.value = 0u;
    };
    this.SetTracking(false);
    this.m_projectileComponent.ClearTrajectories();
    if !GameInstance.GetRuntimeInfo(this.GetGame()).IsMultiplayer() || this.MultiplayerCanRelease() {
      despawnRequest = new GrenadeDespawnRequestEvent();
      delay = this.m_tweakRecord.AttackDuration() > 0.00 ? this.m_tweakRecord.AttackDuration() : 1.50;
      if isInstant {
        delay = 0.00;
      };
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, despawnRequest, delay, false);
      this.m_isAlive = false;
    };
    this.ReleaseAttackResources();
  }

  protected final func MultiplayerCanRelease() -> Bool {
    return GameInstance.GetRuntimeInfo(this.GetGame()).IsServer() && this.m_timeSinceLaunch >= this.m_cpoTimeBeforeRelease;
  }

  protected cb func OnDespawnRequest(evt: ref<GrenadeDespawnRequestEvent>) -> Bool {
    let transactionSystem: ref<TransactionSystem>;
    let animFeature: ref<AnimFeature_CombatGadget> = new AnimFeature_CombatGadget();
    if !this.m_tweakRecord.RemoveMeshOnDetonation() {
      GameObject.StopReplicatedEffectEvent(this, n"fx_sticky");
      this.SpawnEffectFromLibrary(n"despawn_effect");
    };
    transactionSystem = GameInstance.GetTransactionSystem(this.GetGame());
    transactionSystem.ReleaseItem(this.GetOwner(), this);
    this.SetThrowableAnimFeatureOnGrenade(0, this);
    animFeature.isDetonated = false;
    AnimationControllerComponent.ApplyFeature(this, n"Grenade", animFeature);
  }

  private final func InitializeRotation() -> Void {
    let axis: Vector4;
    let i: Int32;
    let randomRotationAxes: Int32;
    let rotationAxesSpeeds: array<Float>;
    let rotationAxesX: array<Float>;
    let rotationAxesY: array<Float>;
    let rotationAxesZ: array<Float>;
    let rotationSpeedMax: Float;
    let rotationSpeedMin: Float;
    let seed: Int32;
    let timeSystem: ref<TimeSystem>;
    let useSeed: Bool;
    let x: Float;
    let y: Float;
    let z: Float;
    this.m_projectileComponent.ToggleAxisRotation(true);
    timeSystem = GameInstance.GetTimeSystem(this.GetGame());
    rotationAxesX = this.m_tweakRecord.RotationAxesX();
    rotationAxesY = this.m_tweakRecord.RotationAxesY();
    rotationAxesZ = this.m_tweakRecord.RotationAxesZ();
    rotationAxesSpeeds = this.m_tweakRecord.RotationAxesSpeeds();
    randomRotationAxes = this.m_tweakRecord.RandomRotationAxes();
    rotationSpeedMin = this.m_tweakRecord.RotationSpeedMin();
    rotationSpeedMax = this.m_tweakRecord.RotationSpeedMax();
    useSeed = this.m_tweakRecord.UseSeed();
    seed = this.m_tweakRecord.Seed();
    if !useSeed {
      seed = Cast(timeSystem.GetGameTimeStamp());
    };
    i = 0;
    while i < ArraySize(rotationAxesX) {
      axis = new Vector4(rotationAxesX[i], rotationAxesY[i], rotationAxesZ[i], 0.00);
      this.m_projectileComponent.AddAxisRotation(axis, rotationAxesSpeeds[i]);
      i += 1;
    };
    i = 0;
    while i < randomRotationAxes {
      x = RandNoiseF(seed, 1.00, -1.00);
      y = RandNoiseF(seed, 1.00, -1.00);
      z = RandNoiseF(seed, 1.00, -1.00);
      axis = new Vector4(x, y, z, 0.00);
      this.m_projectileComponent.AddAxisRotation(axis, RandNoiseF(seed, rotationSpeedMax, rotationSpeedMin));
      i += 1;
    };
  }

  protected final func Freeze() -> Void {
    this.m_projectileComponent.ClearTrajectories();
    GameObject.StartReplicatedEffectEvent(this, n"fx_homing_freeze", true, false);
  }

  protected final func DrillThrough(collisionEventData: gameprojectileHitInstance) -> Void {
    let drillDuration: Float;
    let detonateRequest: ref<GrenadeDetonateRequestEvent> = new GrenadeDetonateRequestEvent();
    let stopDrillingRequest: ref<GrenadeStopDrillingRequestEvent> = new GrenadeStopDrillingRequestEvent();
    this.m_projectileComponent.ClearTrajectories();
    this.m_visualComponent.Toggle(false);
    this.m_shootCollision.Toggle(false);
    this.m_drillTargetPosition = this.GetDrillTargetPosition(collisionEventData.position, Cast(collisionEventData.traceResult.normal));
    if IsDefined(collisionEventData.hitObject as ScriptedPuppet) {
      this.m_drillTargetPosition = this.GetWorldPosition() + (this.m_drillTargetPosition - this.GetWorldPosition()) / 2.00;
    };
    drillDuration = Vector4.Length(this.GetWorldPosition() - this.m_drillTargetPosition);
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, detonateRequest, drillDuration + 2.50, true);
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, stopDrillingRequest, drillDuration, true);
    this.m_detonationTimerActive = false;
    this.m_delayingDetonation = true;
  }

  protected final func SpawnOnPuppetCollisionAttack(attackRecord: ref<Attack_Record>, opt targetEntity: ref<ScriptedPuppet>) -> ref<EffectInstance> {
    let attackContext: AttackInitContext;
    let effect: ref<EffectInstance>;
    let statMods: array<ref<gameStatModifierData>>;
    attackContext.record = attackRecord;
    attackContext.instigator = this.m_user;
    attackContext.source = this;
    let attack: ref<Attack_GameEffect> = IAttack.Create(attackContext) as Attack_GameEffect;
    attack.GetStatModList(statMods);
    effect = attack.PrepareAttack(this.m_user);
    if IsDefined(targetEntity) {
      EffectData.SetEntity(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, targetEntity);
    };
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(attack));
    effect.AttachToEntity(this, GetAllBlackboardDefs().EffectSharedData.position);
    attack.StartAttack();
    return effect;
  }

  protected final func GetDrillTargetPosition(currentPosition: Vector4, hitNormal: Vector4) -> Vector4 {
    let geometryDescription: ref<GeometryDescriptionQuery>;
    let geometryDescriptionResult: ref<GeometryDescriptionResult>;
    let staticQueryFilter: QueryFilter;
    let targetPosition: Vector4;
    QueryFilter.AddGroup(staticQueryFilter, n"Static");
    QueryFilter.AddGroup(staticQueryFilter, n"AI");
    geometryDescription = new GeometryDescriptionQuery();
    geometryDescription.refPosition = currentPosition + Vector4.Normalize(hitNormal) * 0.10;
    geometryDescription.refDirection = -hitNormal;
    geometryDescription.filter = staticQueryFilter;
    geometryDescription.primitiveDimension = new Vector4(0.10, 0.10, 0.10, 0.00);
    geometryDescription.maxDistance = 5.00;
    geometryDescription.maxExtent = 5.00;
    geometryDescription.probingPrecision = 0.05;
    geometryDescription.probingMaxDistanceDiff = 5.00;
    geometryDescription.AddFlag(worldgeometryDescriptionQueryFlags.ObstacleDepth);
    geometryDescriptionResult = GameInstance.GetSpatialQueriesSystem(this.GetGame()).GetGeometryDescriptionSystem().QueryExtents(geometryDescription);
    if Equals(geometryDescriptionResult.queryStatus, worldgeometryDescriptionQueryStatus.OK) && Equals(geometryDescriptionResult.obstacleDepthStatus, IntEnum(0l)) {
      targetPosition = currentPosition - Vector4.Normalize(hitNormal) * (geometryDescriptionResult.obstacleDepth + 0.10);
    } else {
      targetPosition = currentPosition;
    };
    return targetPosition;
  }

  protected cb func OnDetonateRequest(evt: ref<GrenadeDetonateRequestEvent>) -> Bool {
    this.Detonate();
  }

  protected cb func OnStopDrillingRequest(evt: ref<GrenadeStopDrillingRequestEvent>) -> Bool {
    GameObject.BreakReplicatedEffectLoopEvent(this, n"fx_drill");
  }

  protected final func FloatCuttingGrenadeUp() -> Void {
    let accelerateTowardsParameters: wref<AccelerateTowardsParameters_Record>;
    let currentVelocityNormalized: Vector4;
    let distanceToFloat: Float;
    let targetPosition: Vector4;
    let accelerateTowardsTrajectoryParams: ref<AccelerateTowardsTrajectoryParams> = new AccelerateTowardsTrajectoryParams();
    let addAxisRotationEvent: ref<CuttingGrenadeAddAxisRotationEvent> = new CuttingGrenadeAddAxisRotationEvent();
    let freezingDuration: Float = TweakDBInterface.GetFloat(ItemID.GetTDBID(this.GetItemID()) + t".freezingDuration", 1.00);
    let minimumDistanceFromFloor: Float = TweakDBInterface.GetFloat(ItemID.GetTDBID(this.GetItemID()) + t".minimumDistanceFromFloor", 2.00);
    let currentDistanceFromFloor: Float = this.GetDistanceFromFloor();
    let currentSpeed: Float = Vector4.Length(this.m_projectileComponent.GetPrintVelocity());
    if currentDistanceFromFloor < 0.00 || currentDistanceFromFloor > minimumDistanceFromFloor {
      currentVelocityNormalized = Vector4.Normalize(this.m_projectileComponent.GetPrintVelocity());
      targetPosition = this.GetWorldPosition() + currentVelocityNormalized * currentSpeed * freezingDuration;
      targetPosition = this.GetWorldPosition() + Vector4.Normalize(this.lastHitNormal) * currentSpeed * freezingDuration;
    } else {
      currentVelocityNormalized = Vector4.Normalize(this.m_projectileComponent.GetPrintVelocity() * new Vector4(1.00, 1.00, 0.00, 1.00));
      distanceToFloat = minimumDistanceFromFloor - currentDistanceFromFloor;
      targetPosition = this.GetWorldPosition() + currentVelocityNormalized * currentSpeed * freezingDuration + new Vector4(0.00, 0.00, distanceToFloat, 0.00);
    };
    this.m_projectileComponent.ClearTrajectories();
    accelerateTowardsParameters = TweakDBInterface.GetAccelerateTowardsParametersRecord(t"AccelerateTowardsParameters.cuttingGrenadeFreezeParameters");
    accelerateTowardsTrajectoryParams.targetPosition = targetPosition;
    accelerateTowardsTrajectoryParams.accuracy = accelerateTowardsParameters.Accuracy();
    accelerateTowardsTrajectoryParams.maxSpeed = currentSpeed * accelerateTowardsParameters.MaxSpeed();
    accelerateTowardsTrajectoryParams.decelerateTowardsTargetPositionDistance = accelerateTowardsParameters.DecelerateTowardsTargetPositionDistance();
    accelerateTowardsTrajectoryParams.maxRotationSpeed = accelerateTowardsParameters.MaxRotationSpeed();
    accelerateTowardsTrajectoryParams.minRotationSpeed = accelerateTowardsParameters.MinRotationSpeed();
    this.m_projectileComponent.AddAccelerateTowards(accelerateTowardsTrajectoryParams);
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, addAxisRotationEvent, 0.10, true);
  }

  protected cb func OnAddAxisRotationEvent(evt: ref<CuttingGrenadeAddAxisRotationEvent>) -> Bool {
    let axis: Vector4;
    let addAxisRotationEvent: ref<CuttingGrenadeAddAxisRotationEvent> = new CuttingGrenadeAddAxisRotationEvent();
    if this.m_projectileComponent.IsTrajectoryEmpty() {
      return IsDefined(null);
    };
    axis = new Vector4(RandRangeF(0.00, 1.00), RandRangeF(0.00, 1.00), RandRangeF(0.00, 1.00), 0.00);
    this.m_projectileComponent.AddAxisRotation(axis, RandRangeF(TweakDBInterface.GetFloat(ItemID.GetTDBID(this.GetItemID()) + t".addAxisRotationSpeedMin", 20.00), TweakDBInterface.GetFloat(ItemID.GetTDBID(this.GetItemID()) + t".addAxisRotationSpeedMax", 45.00)));
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, addAxisRotationEvent, TweakDBInterface.GetFloat(ItemID.GetTDBID(this.GetItemID()) + t".addAxisRotationDelay", 0.70), true);
  }

  protected final func FloatToLockOnAltitude() -> Void {
    let currentVelocityNormalized: Vector4;
    let homingParameters: wref<AccelerateTowardsParameters_Record>;
    let targetOffset: Vector4;
    let targetPosition: Vector4;
    let accelerateTowardsTrajectoryParams: ref<AccelerateTowardsTrajectoryParams> = new AccelerateTowardsTrajectoryParams();
    let forwardOffsetValue: Float = 0.30;
    let distanceToFloat: Float = this.GetDistanceToFloat();
    if distanceToFloat <= 0.00 {
      return;
    };
    homingParameters = (this.m_tweakRecord.DeliveryMethod() as HomingGDM_Record).FlyUpParameters();
    currentVelocityNormalized = Vector4.Normalize(this.m_projectileComponent.GetPrintVelocity() * new Vector4(1.00, 1.00, 0.00, 1.00));
    targetOffset = currentVelocityNormalized * forwardOffsetValue;
    this.m_projectileComponent.ClearTrajectories();
    targetPosition = this.GetWorldPosition() + new Vector4(0.00, 0.00, distanceToFloat, 0.00) + targetOffset;
    accelerateTowardsTrajectoryParams.targetPosition = targetPosition;
    accelerateTowardsTrajectoryParams.accuracy = homingParameters.Accuracy();
    accelerateTowardsTrajectoryParams.decelerateTowardsTargetPositionDistance = homingParameters.DecelerateTowardsTargetPositionDistance();
    accelerateTowardsTrajectoryParams.maxRotationSpeed = homingParameters.MaxRotationSpeed();
    accelerateTowardsTrajectoryParams.minRotationSpeed = homingParameters.MinRotationSpeed();
    this.m_projectileComponent.AddAccelerateTowards(accelerateTowardsTrajectoryParams);
  }

  protected final func GetDistanceFromFloor() -> Float {
    let currentPosition: Vector4;
    let distanceFromFloor: Float;
    let geometryDescription: ref<GeometryDescriptionQuery>;
    let geometryDescriptionResult: ref<GeometryDescriptionResult>;
    let staticQueryFilter: QueryFilter;
    QueryFilter.AddGroup(staticQueryFilter, n"Static");
    currentPosition = this.GetWorldPosition();
    geometryDescription = new GeometryDescriptionQuery();
    geometryDescription.refPosition = currentPosition;
    geometryDescription.refDirection = new Vector4(0.00, 0.00, -1.00, 0.00);
    geometryDescription.filter = staticQueryFilter;
    geometryDescription.primitiveDimension = new Vector4(0.10, 0.10, 0.20, 0.00);
    geometryDescriptionResult = GameInstance.GetSpatialQueriesSystem(this.GetGame()).GetGeometryDescriptionSystem().QueryExtents(geometryDescription);
    if NotEquals(geometryDescriptionResult.queryStatus, worldgeometryDescriptionQueryStatus.OK) {
      return -1.00;
    };
    distanceFromFloor = AbsF(geometryDescriptionResult.distanceVector.Z);
    return distanceFromFloor;
  }

  protected final func GetDistanceToFloat() -> Float {
    let lockOnAltitude: Float = (this.m_tweakRecord.DeliveryMethod() as HomingGDM_Record).LockOnAltitude();
    let distanceFromFloor: Float = this.GetDistanceFromFloor();
    if distanceFromFloor < 0.00 {
      return 0.00;
    };
    return lockOnAltitude - distanceFromFloor;
  }

  protected final func QueueSmartTrajectory(delay: Float) -> Void {
    let triggerSmartTrajectoryEvent: ref<GrenadeTriggerSmartTrajectoryEvent>;
    this.m_homingGrenadeTarget = this.ChooseSmartTrajectoryTarget();
    GameObject.SendForceRevealObjectEvent(this.m_homingGrenadeTarget.entity, true, n"HomingGrenade");
    this.m_projectileComponent.SetWasTrajectoryStopped(true);
    triggerSmartTrajectoryEvent = new GrenadeTriggerSmartTrajectoryEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, triggerSmartTrajectoryEvent, delay, true);
  }

  protected final func ChooseSmartTrajectoryTarget() -> GrenadePotentialHomingTarget {
    let affiliation: gamedataAffiliation;
    let puppet: ref<NPCPuppet>;
    let score: Float;
    let topPickIndex: Int32;
    let topPickScore: Float;
    let i: Int32 = 0;
    while i < ArraySize(this.m_potentialHomingTargets) {
      puppet = this.m_potentialHomingTargets[i].entity as NPCPuppet;
      if !IsDefined(puppet) {
      } else {
        score = 0.00;
        score += 1.00 / Vector4.Distance(this.GetWorldPosition(), puppet.GetWorldPosition());
        affiliation = TweakDBInterface.GetCharacterRecord(puppet.GetRecordID()).Affiliation().Type();
        score *= Equals(affiliation, gamedataAffiliation.NCPD) ? 0.25 : 1.00;
        if score > topPickScore {
          topPickIndex = i;
          topPickScore = score;
        };
      };
      i += 1;
    };
    return this.m_potentialHomingTargets[topPickIndex];
  }

  protected cb func OnTriggerSmartTrajectory(evt: ref<GrenadeTriggerSmartTrajectoryEvent>) -> Bool {
    this.SetTracking(false);
    this.ActivateSmartTrajectory();
  }

  protected final func StopCuttingGrenadeAttack() -> Void {
    let stopAttackEvent: ref<CuttingGrenadeStopAttackEvent>;
    this.TerminateCuttingGrenadeAttack();
    GameObject.BreakReplicatedEffectLoopEvent(this, n"homing_thrust");
    this.m_lockOnFailed = true;
    stopAttackEvent = new CuttingGrenadeStopAttackEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, stopAttackEvent, TweakDBInterface.GetFloat(ItemID.GetTDBID(this.GetItemID()) + t".stopAttackDelay", 1.00), true);
  }

  protected cb func OnCuttingGrenadeStopAttackEvent(evt: ref<CuttingGrenadeStopAttackEvent>) -> Bool {
    this.DropToFloor();
    GameObject.PlaySound(this, n"grenade_laser_stop");
    this.RequestGrenadeRelease(2.50);
  }

  protected final func DropToFloor() -> Void {
    let parabolicTrajectoryParams: ref<ParabolicTrajectoryParams> = ParabolicTrajectoryParams.GetAccelVelParabolicParams(new Vector4(0.00, 0.00, -9.81, 0.00), 0.00, 20.00);
    this.m_projectileComponent.ClearTrajectories();
    this.m_projectileComponent.SetEnergyLossFactor(0.30, 0.11);
    this.m_projectileComponent.AddParabolic(parabolicTrajectoryParams);
  }

  protected final func QueueFailDetonation() -> Void {
    let detonateRequestEvent: ref<GrenadeDetonateRequestEvent> = new GrenadeDetonateRequestEvent();
    this.m_queueFailDetonationDelayID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, detonateRequestEvent, (this.m_tweakRecord.DeliveryMethod() as HomingGDM_Record).LockOnFailDetonationDelay(), true);
    GameObject.BreakReplicatedEffectLoopEvent(this, n"fx_homing_freeze");
  }

  protected final func ActivateSmartTrajectory() -> Void {
    let homingParameters: wref<AccelerateTowardsParameters_Record>;
    let offset: Vector4;
    let slotComponent: ref<SlotComponent>;
    let slotTransform: WorldTransform;
    let accelerateTowardsTrajectoryParams: ref<AccelerateTowardsTrajectoryParams> = new AccelerateTowardsTrajectoryParams();
    GameObject.BreakReplicatedEffectLoopEvent(this, n"fx_homing_freeze");
    if ArraySize(this.m_potentialHomingTargets) < 1 {
      return;
    };
    homingParameters = (this.m_tweakRecord.DeliveryMethod() as HomingGDM_Record).FlyToTargetParameters();
    this.m_isLockedOn = true;
    this.m_detonateOnImpact = true;
    this.m_projectileComponent.ClearTrajectories();
    slotComponent = this.m_homingGrenadeTarget.entity.GetHitRepresantationSlotComponent();
    if NotEquals(this.m_homingGrenadeTarget.targetSlot, n"") && slotComponent.GetSlotTransform(this.m_homingGrenadeTarget.targetSlot, slotTransform) {
      offset = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform)) - Matrix.GetTranslation(slotComponent.GetLocalToWorld());
    } else {
      if slotComponent.GetSlotTransform(n"Chest", slotTransform) || slotComponent.GetSlotTransform(n"Center", slotTransform) {
        offset = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform)) - Matrix.GetTranslation(slotComponent.GetLocalToWorld());
      };
    };
    accelerateTowardsTrajectoryParams.targetComponent = slotComponent;
    accelerateTowardsTrajectoryParams.targetOffset = offset;
    accelerateTowardsTrajectoryParams.accelerationSpeed = homingParameters.AccelerationSpeed();
    accelerateTowardsTrajectoryParams.maxSpeed = homingParameters.MaxSpeed();
    accelerateTowardsTrajectoryParams.maxRotationSpeed = homingParameters.MaxRotationSpeed();
    accelerateTowardsTrajectoryParams.minRotationSpeed = homingParameters.MinRotationSpeed();
    accelerateTowardsTrajectoryParams.accuracy = homingParameters.Accuracy();
    this.m_projectileComponent.AddAccelerateTowards(accelerateTowardsTrajectoryParams);
    this.m_projectileComponent.SetOnCollisionAction(gameprojectileOnCollisionAction.Stop);
  }

  protected final func SetTracking(state: Bool) -> Void {
    let attackRecord: ref<Attack_Record>;
    let attackRecordPath: TweakDBID;
    if Equals(this.m_isTracking, state) {
      return;
    };
    if !this.m_isTracking {
      if IsDefined(this.m_shootCollision) && this.m_canBeShot {
        this.m_shootCollision.Resize(new Vector4(0.05, 0.06, 0.05, 0.00), 0u);
      };
      attackRecordPath = t"Attacks.GrenadeTargetTracker";
      attackRecord = TweakDBInterface.GetAttack_GameEffectRecord(attackRecordPath);
      this.m_targetTracker = this.SpawnAttack(attackRecord, this.m_tweakRecord.DeliveryMethod().TrackingRadius());
      this.m_targetTracker.AttachToEntity(this, GetAllBlackboardDefs().EffectSharedData.position);
      this.m_isTracking = true;
    } else {
      this.m_targetTracker.Terminate();
      this.m_targetTracker.AttachToEntity(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject(), GetAllBlackboardDefs().EffectSharedData.position);
      this.m_targetTracker = null;
      this.m_isTracking = false;
      GameObject.BreakReplicatedEffectLoopEvent(this, n"fx_regular_scanning");
      if IsDefined(this.m_shootCollision) && this.m_canBeShot {
        this.m_shootCollision.Resize(this.GetShootCollisionSize(), 0u);
      };
    };
  }

  protected final func ProcessProximityTargets() -> Bool {
    let i: Int32;
    if ArraySize(this.m_potentialHomingTargets) == 0 || this.m_timeSinceLaunch < 0.10 {
      return false;
    };
    i = 0;
    while i < ArraySize(this.m_potentialHomingTargets) {
      if this.m_potentialHomingTargets[i].entity == GetPlayer(this.GetGame()) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  protected final func CheckRegularDeliveryMethodConditions() -> Bool {
    return Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Regular) && this.ProcessProximityTargets();
  }

  protected final func CheckStickyDeliveryMethodConditions() -> Bool {
    return Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Sticky) && this.m_isStuck && this.ProcessProximityTargets();
  }

  protected final func PlayNPCGrenadeBeepSound() -> Void {
    if IsDefined(this.m_user as NPCPuppet) {
      GameObject.PlaySound(this, StringToName("gre_npc_beep_lp"));
    };
  }

  protected final func StopNPCGrenadeBeepSound() -> Void {
    if IsDefined(this.m_user as NPCPuppet) {
      GameObject.StopSound(this, StringToName("grenade_charge_start"));
      GameObject.PlaySound(this, StringToName("gre_npc_beep_lp_stop"));
    };
  }

  protected final func PlayStickyGrenadeLongBeepSound() -> Void {
    GameObject.PlaySound(this, n"grenade_charge_start");
  }

  protected final func PlayStickyGrenadeShortBeepSound() -> Void {
    GameObject.PlaySound(this, n"grenade_charge_1s");
  }

  protected final func StopStickyGrenadeSounds() -> Void {
    GameObject.StopSound(this, n"grenade_charge_start");
    GameObject.StopSound(this, n"grenade_charge_1s");
  }

  protected cb func OnTargetAcquired(evt: ref<GrenadeTrackerTargetAcquiredEvent>) -> Bool {
    let i: Int32;
    let newPotentialTarget: GrenadePotentialHomingTarget;
    if this.IsGrenadeOfType(EGrenadeType.Cutting) {
      this.NewCuttingGrenadeHit(evt);
    } else {
      i = 0;
      while i < ArraySize(this.m_potentialHomingTargets) {
        if this.m_potentialHomingTargets[i].entity == evt.target {
          return IsDefined(null);
        };
        i += 1;
      };
      newPotentialTarget.entity = evt.target;
      newPotentialTarget.targetSlot = evt.targetSlot;
      ArrayPush(this.m_potentialHomingTargets, newPotentialTarget);
      if this.CheckRegularDeliveryMethodConditions() || this.CheckStickyDeliveryMethodConditions() {
        this.SetTracking(false);
        this.Detonate();
      };
      if Equals(this.deliveryMethod, gamedataGrenadeDeliveryMethodType.Homing) && !this.m_targetAcquired && this.m_readyToTrack {
        this.QueueSmartTrajectory((this.m_tweakRecord.DeliveryMethod() as HomingGDM_Record).LockOnDelay());
      };
      this.m_targetAcquired = true;
    };
  }

  protected final func NewCuttingGrenadeHit(evt: ref<GrenadeTrackerTargetAcquiredEvent>) -> Void {
    let hitsDoneToTarget: Int32;
    let isExistingTarget: Bool;
    let newPotentialTarget: CuttingGrenadePotentialTarget;
    let hitsNeededForAdditionalAttack: Int32 = TweakDBInterface.GetInt(ItemID.GetTDBID(this.GetItemID()) + t".numberOfHitsForAdditionalAttack", 3);
    let i: Int32 = 0;
    while i < ArraySize(this.m_cuttingGrenadePotentialTargets) {
      if this.m_cuttingGrenadePotentialTargets[i].entity == evt.target {
        this.m_cuttingGrenadePotentialTargets[i].hits += 1;
        isExistingTarget = true;
        hitsDoneToTarget = this.m_cuttingGrenadePotentialTargets[i].hits;
        if hitsDoneToTarget > hitsNeededForAdditionalAttack {
          return;
        };
      };
      i += 1;
    };
    if !isExistingTarget {
      newPotentialTarget.entity = evt.target;
      newPotentialTarget.hits = 1;
      ArrayPush(this.m_cuttingGrenadePotentialTargets, newPotentialTarget);
      hitsDoneToTarget = 1;
    };
    if hitsDoneToTarget == hitsNeededForAdditionalAttack {
      this.SpawnAttack(this.m_tweakRecord.AdditionalAttack(), this.m_tweakRecord.AdditionalAttack().Range(), evt.target.GetWorldPosition());
    };
  }

  protected cb func OnTargetLost(evt: ref<GrenadeTrackerTargetLostEvent>) -> Bool {
    let i: Int32 = ArraySize(this.m_potentialHomingTargets) - 1;
    while i >= 0 {
      if this.m_potentialHomingTargets[i].entity == evt.target {
        ArrayErase(this.m_potentialHomingTargets, i);
        if ArraySize(this.m_potentialHomingTargets) == 0 {
          this.m_targetAcquired = false;
        };
      } else {
        i -= 1;
      };
    };
  }

  protected final func DelayTargetTrackingStateChange(newState: Bool, delay: Float) -> Void {
    let changeStateEvent: ref<GrenadeSetTargetTrackerStateEvent> = new GrenadeSetTargetTrackerStateEvent();
    changeStateEvent.state = newState;
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, changeStateEvent, delay, true);
  }

  protected cb func OnTargetTrackerStateSet(evt: ref<GrenadeSetTargetTrackerStateEvent>) -> Bool {
    this.SetTracking(evt.state);
  }

  public final func GetUser() -> wref<GameObject> {
    return this.m_user;
  }

  public final func GetLastHitNormal() -> Vector4 {
    return this.lastHitNormal;
  }

  public final func GetDeliveryMethod() -> gamedataGrenadeDeliveryMethodType {
    return this.deliveryMethod;
  }
}
