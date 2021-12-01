
public class ProjectileLauncherRoundCollisionEvaluator extends gameprojectileScriptCollisionEvaluator {

  private let m_collisionAction: gamedataProjectileOnCollisionAction;

  @default(ProjectileLauncherRoundCollisionEvaluator, false)
  private let m_projectileStopped: Bool;

  @default(ProjectileLauncherRoundCollisionEvaluator, 0)
  private let m_maxBounceCount: Int32;

  @default(ProjectileLauncherRoundCollisionEvaluator, false)
  private let m_projectileBounced: Bool;

  @default(ProjectileLauncherRoundCollisionEvaluator, false)
  private let m_projectileStopAndStick: Bool;

  @default(ProjectileLauncherRoundCollisionEvaluator, false)
  private let m_projectilePierced: Bool;

  public final func SetCollisionAction(collisionAction: gamedataProjectileOnCollisionAction) -> Void {
    this.m_collisionAction = collisionAction;
  }

  public final func SetNumberOfBounces(maxBounceCount: Int32) -> Void {
    this.m_maxBounceCount = maxBounceCount;
  }

  public final func ProjectileStopped() -> Bool {
    return this.m_projectileStopped;
  }

  public final func ProjectileStopAndStick() -> Bool {
    return this.m_projectileStopAndStick;
  }

  public final func ProjectileBounced() -> Bool {
    return this.m_projectileBounced;
  }

  public final func ProjectilePierced() -> Bool {
    return this.m_projectileBounced;
  }

  public final func projectilePierced() -> Bool {
    return this.m_projectilePierced;
  }

  protected func EvaluateCollision(defaultOnCollisionAction: gameprojectileOnCollisionAction, params: ref<CollisionEvaluatorParams>) -> gameprojectileOnCollisionAction {
    let validBounces: Bool = false;
    validBounces = params.numBounces < Cast(this.m_maxBounceCount);
    if Equals(this.m_collisionAction, gamedataProjectileOnCollisionAction.Stop) || !validBounces && Equals(this.m_collisionAction, gamedataProjectileOnCollisionAction.Bounce) {
      this.m_projectileStopped = true;
      return gameprojectileOnCollisionAction.Stop;
    };
    if Equals(this.m_collisionAction, gamedataProjectileOnCollisionAction.Bounce) {
      this.m_projectileBounced = true;
      return gameprojectileOnCollisionAction.Bounce;
    };
    if Equals(this.m_collisionAction, gamedataProjectileOnCollisionAction.Pierce) {
      this.m_projectilePierced = true;
      return gameprojectileOnCollisionAction.Pierce;
    };
    if Equals(this.m_collisionAction, gamedataProjectileOnCollisionAction.StopAndStick) {
      this.m_projectileStopAndStick = true;
      return gameprojectileOnCollisionAction.StopAndStick;
    };
    if Equals(this.m_collisionAction, gamedataProjectileOnCollisionAction.StopAndStickPerpendicular) {
      this.m_projectileStopAndStick = true;
      return gameprojectileOnCollisionAction.StopAndStickPerpendicular;
    };
    return IntEnum(0l);
  }
}

public class ProjectileLauncherRound extends ItemObject {

  protected let m_projectileComponent: ref<ProjectileComponent>;

  protected let m_user: wref<GameObject>;

  protected let m_projectile: wref<GameObject>;

  protected let m_weapon: wref<WeaponObject>;

  protected let m_projectileSpawnPoint: Vector4;

  protected let m_projectilePosition: Vector4;

  protected let m_launchMode: gamedataProjectileLaunchMode;

  protected let m_projectileLauncherRound: array<SPartSlots>;

  protected let m_partSlots: SPartSlots;

  protected let m_installedPart: ItemID;

  protected let m_initialLaunchVelocity: Float;

  protected let m_projectileLifetime: Float;

  protected let m_installedProjectile: ItemID;

  protected let m_actionType: ELauncherActionType;

  protected let m_attackRecord: ref<Attack_Record>;

  protected let m_lifetimeDelayId: DelayID;

  protected let m_hitEventData: ref<gameprojectileHitEvent>;

  protected let m_projectileTrailName: CName;

  protected let m_projectileCollisionEvaluator: ref<ProjectileLauncherRoundCollisionEvaluator>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"projectileComponent", n"ProjectileComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"StimBroadcaster", n"StimBroadcasterComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"MeshComponent", n"IComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_projectileComponent = EntityResolveComponentsInterface.GetComponent(ri, n"projectileComponent") as ProjectileComponent;
  }

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent>;
    this.m_user = eventData.owner;
    this.m_projectile = eventData.weapon;
    this.m_weapon = this.m_projectile as WeaponObject;
    this.SetCurrentlyInstalledRound();
    this.SetProjectileLauncherAction();
    this.SetCollisionAction();
    broadcaster = eventData.owner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(this, gamedataStimType.WeaponDisplayed);
    };
  }

  protected final func SetCollisionAction() -> Void {
    let collisionAction: CName;
    this.m_projectileCollisionEvaluator = new ProjectileLauncherRoundCollisionEvaluator();
    this.m_projectileComponent.SetCollisionEvaluator(this.m_projectileCollisionEvaluator);
    this.m_projectileComponent.SetEnergyLossFactor(this.GetFloat("energyLossFactor"), this.GetFloat("energyLossFactor"));
    if Equals(this.m_actionType, ELauncherActionType.QuickAction) {
      collisionAction = this.GetCName("collisionAction");
    } else {
      collisionAction = this.GetCName("collisionActionCharged");
    };
    this.m_projectileCollisionEvaluator.SetCollisionAction(this.CollisionActionNameToEnum(collisionAction));
    this.m_projectileCollisionEvaluator.SetNumberOfBounces(this.GetInt("maxBounceCount"));
  }

  protected final func SetCurrentlyInstalledRound() -> Bool {
    let i: Int32;
    let partSlots: SPartSlots;
    let projectileLauncherRound: array<SPartSlots> = ItemModificationSystem.GetAllSlots(this.m_user, this.m_weapon.GetItemID());
    if ArraySize(projectileLauncherRound) == 0 {
      return false;
    };
    i = 0;
    while i < ArraySize(projectileLauncherRound) {
      partSlots = projectileLauncherRound[i];
      if Equals(partSlots.status, ESlotState.Taken) && partSlots.slotID == t"AttachmentSlots.ProjectileLauncherRound" {
        this.m_installedProjectile = partSlots.installedPart;
      };
      i += 1;
    };
    return false;
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    this.GeneralLaunchSetup(eventData);
    this.LinearLaunch(eventData, this.m_initialLaunchVelocity);
  }

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    let targetComponent: ref<IPlacedComponent>;
    let targetEntity: wref<Entity>;
    let isFriendlyNPC: Bool = false;
    this.GeneralLaunchSetup(eventData);
    targetComponent = eventData.params.trackedTargetComponent;
    targetEntity = targetComponent.GetEntity();
    isFriendlyNPC = PlayerPuppet.IsTargetFriendlyNPC(this.m_user as PlayerPuppet, targetEntity);
    if Equals(this.m_launchMode, gamedataProjectileLaunchMode.Tracking) && IsDefined(targetComponent) && !isFriendlyNPC {
      this.CurvedLaunchToTarget(eventData, targetComponent);
    } else {
      this.LinearLaunch(eventData, this.m_initialLaunchVelocity);
    };
  }

  protected final func GeneralLaunchSetup(eventData: ref<gameprojectileShootEvent>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    this.m_projectileSpawnPoint = eventData.startPoint;
    this.SetProjectileLifetime();
    this.SetLaunchModeBasedOnAction();
    this.SetAttackRecordBasedOnAction();
    this.SetLaunchVelocityBasedOnAction();
    this.SetProjectileTrailEffect();
    broadcaster = this.m_user.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(this, gamedataStimType.IllegalAction);
    };
  }

  protected final func CurvedLaunchToTarget(eventData: ref<gameprojectileShootEvent>, opt targetObject: wref<GameObject>, opt targetComponent: ref<IPlacedComponent>) -> Void {
    let linearTimeRatio: Float = this.GetFloat("linearTimeRatio");
    let interpolationTimeRatio: Float = this.GetFloat("interpolationTimeRatio");
    let returnTimeMargin: Float = this.GetFloat("returnTimeMargin");
    let bendTimeRatio: Float = this.GetFloat("bendTimeRatio");
    let bendFactor: Float = this.GetFloat("bendFactor");
    let halfLeanAngle: Float = this.GetFloat("halfLeanAngle");
    let endLeanAngle: Float = this.GetFloat("endLeanAngle");
    let angleInterpolationDuration: Float = this.GetFloat("angleInterpolationDuration");
    this.CurvedLaunch(eventData, targetObject, targetComponent, this.m_initialLaunchVelocity, linearTimeRatio, interpolationTimeRatio, returnTimeMargin, bendTimeRatio, bendFactor, halfLeanAngle, endLeanAngle, angleInterpolationDuration);
  }

  protected final func GetFloat(param: String) -> Float {
    return TDB.GetFloat(ItemID.GetTDBID(this.m_installedProjectile) + t"." + TDBID.Create(param));
  }

  protected final func GetInt(param: String) -> Int32 {
    return TDB.GetInt(ItemID.GetTDBID(this.m_installedProjectile) + t"." + TDBID.Create(param));
  }

  protected final func GetBool(param: String) -> Bool {
    return TDB.GetBool(ItemID.GetTDBID(this.m_installedProjectile) + t"." + TDBID.Create(param));
  }

  protected final func GetCName(param: String) -> CName {
    return TDB.GetCName(ItemID.GetTDBID(this.m_installedProjectile) + t"." + TDBID.Create(param));
  }

  protected final func GetString(param: String) -> String {
    return TDB.GetString(ItemID.GetTDBID(this.m_installedProjectile) + t"." + TDBID.Create(param));
  }

  protected final func GetVector3(param: String) -> Vector3 {
    return TDB.GetVector3(ItemID.GetTDBID(this.m_installedProjectile) + t"." + TDBID.Create(param));
  }

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool {
    if this.m_projectileCollisionEvaluator.ProjectileStopped() {
      this.StopProjectile();
      this.Release();
      if this.GetBool("hideMeshOnCollision") {
        this.SetMeshVisible(false);
      };
    };
    if this.m_projectileCollisionEvaluator.ProjectileStopAndStick() {
      this.StopProjectile();
      this.SetProjectileDetonationTime();
      GameObjectEffectHelper.StartEffectEvent(this, n"detonation_warning", true);
      this.m_hitEventData = eventData;
      this.ProjectileHit(eventData);
    };
    if !this.m_projectileCollisionEvaluator.ProjectileStopAndStick() {
      this.ExecuteGameEffect(eventData);
    };
    this.EvaluateStimBroadcasting(this.CollisionStimTypeNameToEnum(this.GetCName("onCollisionStimType")));
  }

  protected final func ExecuteGameEffect(opt eventData: ref<gameprojectileHitEvent>) -> Void {
    if Equals(this.m_attackRecord.AttackType().Type(), gamedataAttackType.Explosion) {
      this.ProjectileHitAoE(this.m_attackRecord.Range(), this.m_attackRecord);
      if IsDefined(eventData) {
        this.ProjectileHit(eventData);
      };
    } else {
      if IsDefined(eventData) {
        this.ProjectileHit(eventData);
      };
    };
    this.PlayAudio();
    GameObjectEffectHelper.StopEffectEvent(this, n"detonation_warning");
  }

  protected final func PlayAudio() -> Void {
    GameObject.PlayMetadataEvent(this, this.GetCName("onCollisionSound"));
    GameInstance.GetAudioSystem(this.GetGame()).PlayShockwave(this.GetCName("onCollisionSound"), this.m_projectilePosition);
  }

  protected final func EvaluateStimBroadcasting(stimToSend: gamedataStimType) -> Void {
    let broadcastRadius: Float = this.GetFloat("onCollisionStimBroadcastRadius");
    let broadcastLifetime: Float = this.GetFloat("onCollisionStimBroadcastLifetime");
    if broadcastRadius > 0.00 {
      if broadcastLifetime > 0.00 {
        this.TriggerActiveStimuliWithLifetime(stimToSend, broadcastLifetime, broadcastRadius);
      } else {
        this.TriggerSingleStimuli(broadcastRadius, stimToSend);
      };
    };
  }

  protected final func CreateCustomTickEventWithDuration(value: Float) -> Void {
    let projectileTick: ref<ProjectileTickEvent> = new ProjectileTickEvent();
    GameInstance.GetDelaySystem(this.GetGame()).TickOnEvent(this, projectileTick, value);
  }

  protected final func CreateDelayEvent(value: Float) -> Void {
    let projectileDelayEvent: ref<ProjectileDelayEvent> = new ProjectileDelayEvent();
    this.m_lifetimeDelayId = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, projectileDelayEvent, value);
  }

  protected final func CreateDetonationDelayEvent(value: Float) -> Void {
    let projectileDelayEvent: ref<ProjectileLauncherRoundDetonationDelayEvent> = new ProjectileLauncherRoundDetonationDelayEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, projectileDelayEvent, value);
  }

  protected cb func OnMaxLifetimeReached(evt: ref<ProjectileDelayEvent>) -> Bool {
    this.Release();
  }

  protected cb func OnMaxDetonationTimeReached(evt: ref<ProjectileLauncherRoundDetonationDelayEvent>) -> Bool {
    this.ExecuteGameEffect();
    if IsDefined(this.m_hitEventData) {
      this.ProjectileHit(this.m_hitEventData);
    };
    this.Release();
  }

  protected cb func OnTick(eventData: ref<gameprojectileTickEvent>) -> Bool {
    this.m_projectilePosition = eventData.position;
  }

  protected final func SetMeshVisible(value: Bool) -> Void {
    let meshVisualComponent: ref<IComponent>;
    meshVisualComponent.Toggle(value);
  }

  protected final func Release() -> Void {
    let objectPool: ref<ObjectPoolSystem>;
    GameObjectEffectHelper.BreakEffectLoopEvent(this, this.m_projectileTrailName);
    objectPool = GameInstance.GetObjectPoolSystem(this.GetGame());
    objectPool.Release(this);
    GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_lifetimeDelayId);
  }

  protected final func SetProjectileTrailEffect() -> Void {
    switch this.m_attackRecord.DamageType().DamageType() {
      case gamedataDamageType.Physical:
        this.m_projectileTrailName = n"trail";
        break;
      case gamedataDamageType.Thermal:
        this.m_projectileTrailName = n"trail_thermal";
        break;
      case gamedataDamageType.Chemical:
        this.m_projectileTrailName = n"trail_chemical";
        break;
      case gamedataDamageType.Electric:
        this.m_projectileTrailName = n"trail_electric";
        break;
      default:
        this.m_projectileTrailName = n"trail";
    };
    GameObjectEffectHelper.StartEffectEvent(this, this.m_projectileTrailName, true);
  }

  protected final func SetProjectileLifetime() -> Void {
    let lifetime: Float = this.GetFloat("lifetime");
    if lifetime > 0.00 {
      this.CreateDelayEvent(lifetime);
    };
  }

  protected final func SetProjectileDetonationTime() -> Void {
    let detonationDelay: Float = this.GetFloat("detonationDelay");
    if detonationDelay > 0.00 {
      this.CreateDetonationDelayEvent(detonationDelay);
    };
  }

  protected final func HasTrajectory() -> Bool {
    return this.m_projectileComponent.IsTrajectoryEmpty();
  }

  protected final func StopProjectile() -> Void {
    this.m_projectileComponent.ClearTrajectories();
  }

  protected final func SpawnVisualEffect(effectName: CName, opt eventTag: CName) -> Void {
    let spawnEffectEvent: ref<entSpawnEffectEvent> = new entSpawnEffectEvent();
    spawnEffectEvent.effectName = effectName;
    spawnEffectEvent.effectInstanceName = eventTag;
    this.QueueEvent(spawnEffectEvent);
  }

  protected final func BreakVisualEffectLoop(effectName: CName) -> Void {
    let evt: ref<entBreakEffectLoopEvent> = new entBreakEffectLoopEvent();
    evt.effectName = effectName;
    this.QueueEvent(evt);
  }

  protected final func KillVisualEffect(effectName: CName) -> Void {
    let evt: ref<entKillEffectEvent> = new entKillEffectEvent();
    evt.effectName = effectName;
    this.QueueEvent(evt);
  }

  protected final func GetObject(hitInstance: gameprojectileHitInstance) -> wref<GameObject> {
    return ProjectileHitHelper.GetHitObject(hitInstance);
  }

  protected final func GetObjectWorldPosition(object: wref<GameObject>) -> Vector4 {
    return ProjectileTargetingHelper.GetObjectCurrentPosition(object);
  }

  protected final func SetProjectileLauncherAction() -> ELauncherActionType {
    let quickAction: Bool = ProjectileHelper.GetPSMBlackboardIntVariable(this.m_user, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware) == EnumInt(gamePSMLeftHandCyberware.QuickAction);
    let chargeAction: Bool = ProjectileHelper.GetPSMBlackboardIntVariable(this.m_user, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware) == EnumInt(gamePSMLeftHandCyberware.ChargeAction);
    if quickAction {
      this.m_actionType = ELauncherActionType.QuickAction;
    } else {
      if chargeAction {
        this.m_actionType = ELauncherActionType.ChargeAction;
      } else {
        this.m_actionType = IntEnum(2l);
      };
    };
    return this.m_actionType;
  }

  protected final func SetAttackRecordBasedOnAction() -> Void {
    switch this.m_actionType {
      case ELauncherActionType.QuickAction:
        this.m_attackRecord = TweakDBInterface.GetAttackRecord(TDBID.Create(this.GetString("attack")));
        break;
      case ELauncherActionType.ChargeAction:
        this.m_attackRecord = TweakDBInterface.GetAttackRecord(TDBID.Create(this.GetString("secondaryAttack")));
        break;
      default:
    };
  }

  protected final func SetLaunchVelocityBasedOnAction() -> Void {
    switch this.m_actionType {
      case ELauncherActionType.QuickAction:
        this.m_initialLaunchVelocity = this.GetFloat("startVelocity");
        break;
      case ELauncherActionType.ChargeAction:
        this.m_initialLaunchVelocity = this.GetFloat("startVelocityCharged");
        break;
      default:
        this.m_initialLaunchVelocity = -1.00;
    };
  }

  protected final func CollisionActionNameToEnum(collisionAction: CName) -> gamedataProjectileOnCollisionAction {
    switch collisionAction {
      case n"Bounce":
        return gamedataProjectileOnCollisionAction.Bounce;
      case n"Pierce":
        return gamedataProjectileOnCollisionAction.Pierce;
      case n"Stop":
        return gamedataProjectileOnCollisionAction.Stop;
      case n"StopAndStick":
        return gamedataProjectileOnCollisionAction.StopAndStick;
      case n"StopAndStickPerpendicular":
        return gamedataProjectileOnCollisionAction.StopAndStickPerpendicular;
      default:
    };
    return gamedataProjectileOnCollisionAction.Invalid;
  }

  protected final func CollisionStimTypeNameToEnum(onCollisionStimType: CName) -> gamedataStimType {
    switch onCollisionStimType {
      case n"Explosion":
        return gamedataStimType.Explosion;
      case n"ProjectileDistraction":
        return gamedataStimType.ProjectileDistraction;
      case n"SoundDistraction":
        return gamedataStimType.SoundDistraction;
      default:
    };
    return gamedataStimType.Invalid;
  }

  protected final func SetLaunchModeBasedOnAction() -> Void {
    switch this.m_actionType {
      case ELauncherActionType.QuickAction:
        this.m_launchMode = this.LaunchModeNameToEnum(this.GetCName("quickActionlaunchMode"));
        break;
      case ELauncherActionType.ChargeAction:
        this.m_launchMode = this.LaunchModeNameToEnum(this.GetCName("chargeActionlaunchMode"));
        break;
      default:
    };
  }

  protected final func LaunchModeNameToEnum(launchModeName: CName) -> gamedataProjectileLaunchMode {
    switch launchModeName {
      case n"Regular":
        return gamedataProjectileLaunchMode.Regular;
      case n"Tracking":
        return gamedataProjectileLaunchMode.Tracking;
      default:
    };
    return gamedataProjectileLaunchMode.Invalid;
  }

  protected final func TriggerSingleStimuli(radius: Float, stimToSend: gamedataStimType) -> Void {
    let investigationData: stimInvestigateData;
    let broadcaster: ref<StimBroadcasterComponent> = this.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      investigationData.attackInstigator = this.m_user;
      broadcaster.TriggerSingleBroadcast(this, stimToSend, radius, investigationData);
    };
  }

  protected final func TriggerActiveStimuliWithLifetime(stimToSend: gamedataStimType, lifetime: Float, radius: Float) -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = this.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.SetSingleActiveStimuli(this, stimToSend, lifetime, radius);
    };
  }

  protected final func ProjectileHitAoE(attackRadius: Float, opt attackRecord: ref<Attack_Record>) -> Void {
    ProjectileGameEffectHelper.FillProjectileHitAoEData(this, this.m_user, this.m_projectilePosition, attackRadius, attackRecord);
  }

  protected final func ProjectileHit(eventData: ref<gameprojectileHitEvent>) -> Void {
    ProjectileGameEffectHelper.FillProjectileHitData(this, this.m_user, this.m_projectileComponent, eventData);
  }

  protected final func LinearLaunch(eventData: ref<gameprojectileShootEvent>, startVelocity: Float) -> Void {
    ProjectileLaunchHelper.SetLinearLaunchTrajectory(this.m_projectileComponent, startVelocity);
  }

  protected final func ParabolicLaunch(eventData: ref<gameprojectileShootEvent>, gravitySimulation: Float, startVelocity: Float, energyLossFactorAfterCollision: Float) -> Void {
    ProjectileLaunchHelper.SetParabolicLaunchTrajectory(this.m_projectileComponent, gravitySimulation, startVelocity, energyLossFactorAfterCollision);
  }

  protected final func CurvedLaunch(eventData: ref<gameprojectileShootEvent>, opt targetObject: wref<GameObject>, opt targetComponent: ref<IPlacedComponent>, startVelocity: Float, linearTimeRatio: Float, interpolationTimeRatio: Float, returnTimeMargin: Float, bendTimeRatio: Float, bendFactor: Float, halfLeanAngle: Float, endLeanAngle: Float, angleInterpolationDuration: Float) -> Void {
    ProjectileLaunchHelper.SetCurvedLaunchTrajectory(this.m_projectileComponent, targetObject, targetComponent, startVelocity, linearTimeRatio, interpolationTimeRatio, returnTimeMargin, bendTimeRatio, bendFactor, halfLeanAngle, endLeanAngle, angleInterpolationDuration);
  }
}
