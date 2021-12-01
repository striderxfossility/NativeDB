
public class sampleBullet extends BaseProjectile {

  private let m_meshComponent: ref<IComponent>;

  private let m_countTime: Float;

  private edit let m_startVelocity: Float;

  private edit let m_lifetime: Float;

  private let m_BulletCollisionEvaluator: ref<BulletCollisionEvaluator>;

  @default(sampleBullet, true)
  private let m_alive: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"MeshComponent", n"IComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_meshComponent = EntityResolveComponentsInterface.GetComponent(ri, n"MeshComponent");
  }

  private final func Reset() -> Void {
    this.m_countTime = 0.00;
    this.m_alive = true;
    this.m_meshComponent.Toggle(true);
  }

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool {
    let linearParams: ref<LinearTrajectoryParams> = new LinearTrajectoryParams();
    super.OnProjectileInitialize(eventData);
    linearParams.startVel = this.m_startVelocity;
    this.m_projectileComponent.AddLinear(linearParams);
    this.m_BulletCollisionEvaluator = new BulletCollisionEvaluator();
    this.m_projectileComponent.SetCollisionEvaluator(this.m_BulletCollisionEvaluator);
  }

  private final func StartTrailEffect() -> Void {
    this.m_projectileComponent.SpawnTrailVFX();
    GameObject.PlaySoundEvent(this, n"Time_Dilation_Bullet_Trails_bullets_normal");
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    this.m_BulletCollisionEvaluator.SetWeaponParams(eventData.params);
    this.Reset();
    this.StartTrailEffect();
  }

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    this.m_BulletCollisionEvaluator.SetWeaponParams(eventData.params);
    this.Reset();
    this.StartTrailEffect();
  }

  protected cb func OnTick(eventData: ref<gameprojectileTickEvent>) -> Bool {
    this.m_countTime += eventData.deltaTime;
    if this.m_countTime > this.m_lifetime || !this.m_alive {
      this.Release();
    };
    this.m_projectileComponent.LogDebugVariable(n"Lifetime", FloatToString(this.m_countTime));
  }

  protected cb func OnCollision(projectileHitEvent: ref<gameprojectileHitEvent>) -> Bool {
    let hitInstance: gameprojectileHitInstance;
    let object: ref<GameObject>;
    let damageHitEvent: ref<gameprojectileHitEvent> = new gameprojectileHitEvent();
    let isUserPlayer: Bool = this.m_user == GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject();
    let i: Int32 = 0;
    while i < ArraySize(projectileHitEvent.hitInstances) {
      hitInstance = projectileHitEvent.hitInstances[i];
      object = hitInstance.hitObject as GameObject;
      if this.m_alive && !(isUserPlayer && object.HasTag(n"ignore_player_bullets")) {
        ArrayPush(damageHitEvent.hitInstances, hitInstance);
        if !object.HasTag(n"bullet_no_destroy") && this.m_BulletCollisionEvaluator.HasReportedStopped() && Equals(hitInstance.position, this.m_BulletCollisionEvaluator.GetStoppedPosition()) {
          this.m_countTime = 0.00;
          this.m_alive = false;
          this.m_meshComponent.Toggle(false);
          this.m_projectileComponent.ClearTrajectories();
        } else {
          i += 1;
        };
      } else {
      };
      i += 1;
    };
    if ArraySize(damageHitEvent.hitInstances) > 0 {
      this.DealDamage(damageHitEvent);
    };
  }

  private final func DealDamage(eventData: ref<gameprojectileHitEvent>) -> Void {
    let damageEffect: ref<EffectInstance> = this.m_projectileComponent.GetGameEffectInstance();
    EffectData.SetVariant(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.projectileHitEvent, ToVariant(eventData));
    damageEffect.Run();
  }
}

public class BulletCollisionEvaluator extends gameprojectileScriptCollisionEvaluator {

  @default(BulletCollisionEvaluator, false)
  private let m_hasStopped: Bool;

  private let m_stoppedPosition: Vector4;

  private let m_weaponParams: gameprojectileWeaponParams;

  @default(BulletCollisionEvaluator, false)
  private let m_isExplodingBullet: Bool;

  public final func SetIsExplodingBullet(isExplodingBullet: Bool) -> Void {
    this.m_isExplodingBullet = isExplodingBullet;
  }

  public final func SetWeaponParams(params: gameprojectileWeaponParams) -> Void {
    this.m_weaponParams = params;
  }

  public final func HasReportedStopped() -> Bool {
    return this.m_hasStopped;
  }

  public final func GetStoppedPosition() -> Vector4 {
    return this.m_stoppedPosition;
  }

  protected func EvaluateCollision(defaultOnCollisionAction: gameprojectileOnCollisionAction, params: ref<CollisionEvaluatorParams>) -> gameprojectileOnCollisionAction {
    let validAngle: Bool = false;
    let validBounces: Bool = false;
    let validRand: Bool = false;
    if !this.m_isExplodingBullet && params.isPiercableSurface {
      return gameprojectileOnCollisionAction.Pierce;
    };
    if IsDefined(params.target as ScriptedPuppet) || IsDefined(params.target as Device) {
      this.m_hasStopped = true;
      this.m_stoppedPosition = params.position;
      return gameprojectileOnCollisionAction.Stop;
    };
    if this.m_isExplodingBullet && (Equals(params.projectilePenetration, n"Any") || params.isTechPiercing && params.isPiercableSurface) {
      return gameprojectileOnCollisionAction.Pierce;
    };
    validAngle = this.m_weaponParams.ricochetData.minAngle < params.angle && this.m_weaponParams.ricochetData.maxAngle > params.angle;
    validBounces = params.numBounces < Cast(this.m_weaponParams.ricochetData.count);
    validRand = RandRangeF(0.00, 1.00) < this.m_weaponParams.ricochetData.chance;
    if !validAngle || !validBounces || !validRand {
      this.m_hasStopped = true;
      this.m_stoppedPosition = params.position;
      return gameprojectileOnCollisionAction.Stop;
    };
    return gameprojectileOnCollisionAction.Bounce;
  }
}
