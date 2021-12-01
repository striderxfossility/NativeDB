
public class BaseProjectile extends ItemObject {

  protected let m_projectileComponent: ref<ProjectileComponent>;

  protected let m_user: wref<GameObject>;

  protected let m_projectile: wref<GameObject>;

  protected let m_projectileSpawnPoint: Vector4;

  protected let m_projectilePosition: Vector4;

  @default(BaseProjectile, 0.f)
  protected let m_initialLaunchVelocity: Float;

  @default(BaseProjectile, 0.f)
  protected let m_lifeTime: Float;

  public edit let m_tweakDBPath: String;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"projectileComponent", n"ProjectileComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"StimBroadcaster", n"StimBroadcasterComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_projectileComponent = EntityResolveComponentsInterface.GetComponent(ri, n"projectileComponent") as ProjectileComponent;
  }

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool {
    this.m_user = eventData.owner;
    this.m_projectile = eventData.weapon;
    let broadcaster: ref<StimBroadcasterComponent> = eventData.owner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(this, gamedataStimType.WeaponDisplayed);
    };
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent>;
    this.SetProjectileLifetime();
    this.SetInitialVelocityBasedOnActionType(this.m_user);
    this.LinearLaunch(eventData, this.m_initialLaunchVelocity);
    GameObjectEffectHelper.StartEffectEvent(this.m_projectile, n"trail", true);
    broadcaster = this.m_user.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(this, gamedataStimType.IllegalAction);
    };
  }

  protected final func CurvedLaunchToTarget(eventData: ref<gameprojectileShootEvent>, opt targetObject: wref<GameObject>, opt targetComponent: ref<IPlacedComponent>) -> Void {
    let linearTimeRatio: Float = this.GetProjectileTweakDBFloatParameter("linearTimeRatio");
    let interpolationTimeRatio: Float = this.GetProjectileTweakDBFloatParameter("interpolationTimeRatio");
    let returnTimeMargin: Float = this.GetProjectileTweakDBFloatParameter("returnTimeMargin");
    let bendTimeRatio: Float = this.GetProjectileTweakDBFloatParameter("bendTimeRatio");
    let bendFactor: Float = this.GetProjectileTweakDBFloatParameter("bendFactor");
    let halfLeanAngle: Float = this.GetProjectileTweakDBFloatParameter("halfLeanAngle");
    let endLeanAngle: Float = this.GetProjectileTweakDBFloatParameter("endLeanAngle");
    let angleInterpolationDuration: Float = this.GetProjectileTweakDBFloatParameter("angleInterpolationDuration");
    this.CurvedLaunch(eventData, targetObject, targetComponent, this.m_initialLaunchVelocity, linearTimeRatio, interpolationTimeRatio, returnTimeMargin, bendTimeRatio, bendFactor, halfLeanAngle, endLeanAngle, angleInterpolationDuration);
  }

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    let actionType: EActionType;
    let targetComponent: ref<IPlacedComponent>;
    this.GeneralLaunchSetup(eventData);
    this.SetInitialVelocityBasedOnActionType(this.m_user);
    targetComponent = eventData.params.trackedTargetComponent;
    actionType = this.GetLeftHandCyberwareAction(this.m_user);
    if IsDefined(targetComponent) && (Equals(actionType, EActionType.QuickAction) || Equals(actionType, EActionType.ChargeAction)) {
      this.CurvedLaunchToTarget(eventData, targetComponent);
    } else {
      this.LinearLaunch(eventData, this.m_initialLaunchVelocity);
    };
  }

  protected final func GeneralLaunchSetup(eventData: ref<gameprojectileShootEvent>) -> Void {
    this.m_projectileSpawnPoint = eventData.startPoint;
    ProjectileHelper.SpawnTrailVFX(this.m_projectileComponent);
    this.SetProjectileLifetime();
  }

  protected final func SetProjectileLifetime() -> Void {
    this.m_lifeTime = this.GetProjectileTweakDBFloatParameter("lifetime");
    if this.m_lifeTime > 0.00 {
      this.CreateDelayEvent(this.m_lifeTime);
    };
  }

  protected final func ProjectileBreachDevice(hitInstance: gameprojectileHitInstance, value: Float) -> Void {
    this.CreateProjectileDeviceBreachEvent(hitInstance, value);
  }

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool;

  protected final func CreateCustomTickEventWithDuration(value: Float) -> Void {
    let projectileTick: ref<ProjectileTickEvent> = new ProjectileTickEvent();
    GameInstance.GetDelaySystem(this.GetGame()).TickOnEvent(this, projectileTick, value);
  }

  protected final func CreateDelayEvent(value: Float) -> Void {
    let projectileDelayEvent: ref<ProjectileDelayEvent> = new ProjectileDelayEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, projectileDelayEvent, value);
  }

  protected final func CreateProjectileDeviceBreachEvent(hitInstance: gameprojectileHitInstance, value: Float) -> Void {
    let projectileBreachEvent: ref<ProjectileBreachEvent> = new ProjectileBreachEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this.GetObject(hitInstance), projectileBreachEvent, value);
  }

  protected cb func OnMaxLifetimeReached(evt: ref<ProjectileDelayEvent>) -> Bool {
    this.Release();
  }

  protected cb func OnUpdate(evt: ref<ProjectileTickEvent>) -> Bool;

  protected final func SetMeshVisible(value: Bool) -> Void {
    let meshVisualComponent: ref<IComponent>;
    meshVisualComponent.Toggle(value);
  }

  protected final func Release() -> Void {
    let objectPool: ref<ObjectPoolSystem>;
    GameObject.PlaySoundEvent(this, n"Stop_Time_Dilation_Bullet_Trails_bullets_normal");
    objectPool = GameInstance.GetObjectPoolSystem(this.GetGame());
    objectPool.Release(this);
  }

  protected final func HasTrajectory() -> Bool {
    return this.m_projectileComponent.IsTrajectoryEmpty();
  }

  protected final func StopProjectile() -> Void {
    this.m_projectileComponent.ClearTrajectories();
  }

  protected final func CanBounceAfterCollision(value: Bool) -> Void {
    if value {
      this.m_projectileComponent.SetOnCollisionAction(gameprojectileOnCollisionAction.Bounce);
    } else {
      this.m_projectileComponent.SetOnCollisionAction(gameprojectileOnCollisionAction.Stop);
    };
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

  protected final func GetLeftHandCyberwareAction(user: wref<GameObject>) -> EActionType {
    let actionType: EActionType;
    let quickAction: Bool = ProjectileHelper.GetPSMBlackboardIntVariable(user, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware) == EnumInt(gamePSMLeftHandCyberware.QuickAction);
    let chargeAction: Bool = ProjectileHelper.GetPSMBlackboardIntVariable(user, GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware) == EnumInt(gamePSMLeftHandCyberware.ChargeAction);
    if quickAction {
      actionType = EActionType.QuickAction;
    } else {
      if chargeAction {
        actionType = EActionType.ChargeAction;
      } else {
        actionType = IntEnum(2l);
      };
    };
    return actionType;
  }

  protected final func GetProjectileTweakDBFloatParameter(param: String) -> Float {
    return TweakDBInterface.GetFloat(TDBID.Create("projectile." + this.m_tweakDBPath + "." + param), -1.00);
  }

  protected final func SetInitialVelocityBasedOnActionType(user: wref<GameObject>) -> Void {
    switch this.GetLeftHandCyberwareAction(user) {
      case EActionType.QuickAction:
        this.m_initialLaunchVelocity = this.GetProjectileTweakDBFloatParameter("startVelocity");
        break;
      case EActionType.ChargeAction:
        this.m_initialLaunchVelocity = this.GetProjectileTweakDBFloatParameter("startVelocityCharged");
        break;
      default:
        this.m_initialLaunchVelocity = -1.00;
    };
  }

  protected final func TriggerSingleStimuli(hitInstance: gameprojectileHitInstance, stimToSend: gamedataStimType) -> Void {
    let investigateData: stimInvestigateData;
    let broadcaster: ref<StimBroadcasterComponent> = this.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      investigateData.attackInstigator = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject();
      broadcaster.TriggerSingleBroadcast(this, stimToSend, investigateData);
    };
  }

  protected final func TriggerActiveStimuliWithLifetime(hitInstance: gameprojectileHitInstance, stimToSend: gamedataStimType, lifetime: Float, radius: Float) -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = this.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.SetSingleActiveStimuli(this, stimToSend, lifetime, radius);
    };
  }

  protected final func ProjectileHitAoE(hitInstance: gameprojectileHitInstance, attackRadius: Float, opt attackRecord: ref<Attack_Record>) -> Void {
    ProjectileGameEffectHelper.FillProjectileHitAoEData(this, this.m_user, hitInstance.position, attackRadius, attackRecord);
    GameInstance.GetAudioSystem(this.GetGame()).PlayShockwave(n"explosion", this.m_projectilePosition);
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
