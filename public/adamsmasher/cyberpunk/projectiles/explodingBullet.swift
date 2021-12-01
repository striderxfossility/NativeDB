
public class ExplodingBullet extends BaseBullet {

  public edit let explosionTime: Float;

  public edit let effectReference: EffectRef;

  public let hasExploded: Bool;

  public let m_initialPosition: Vector4;

  public let m_trailStarted: Bool;

  public let m_weapon: wref<WeaponObject>;

  public let m_attack_record: ref<Attack_Record>;

  public let m_attackID: TweakDBID;

  public edit let colliderBox: Vector4;

  public edit let rotation: Quaternion;

  public edit let range: Float;

  @default(ExplodingBullet, true)
  public edit let explodeAfterRangeTravelled: Bool;

  private let m_attack: ref<IAttack>;

  private let m_BulletCollisionEvaluator: ref<BulletCollisionEvaluator>;

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool {
    super.OnProjectileInitialize(eventData);
    this.hasExploded = false;
    this.m_countTime = 0.00;
    this.m_user = eventData.owner;
    this.m_trailStarted = false;
    this.m_weapon = eventData.weapon as WeaponObject;
    this.m_attack = this.m_weapon.GetCurrentAttack();
    this.m_attack_record = this.m_attack.GetRecord();
    this.m_attackID = this.m_attack_record.GetID();
    this.m_BulletCollisionEvaluator = new BulletCollisionEvaluator();
    this.m_projectileComponent.SetCollisionEvaluator(this.m_BulletCollisionEvaluator);
    this.m_BulletCollisionEvaluator.SetIsExplodingBullet(true);
  }

  protected cb func OnTick(eventData: ref<gameprojectileTickEvent>) -> Bool {
    this.m_countTime += eventData.deltaTime;
    if !this.m_trailStarted {
      GameObjectEffectHelper.StartEffectEvent(this, n"trail", true);
      this.m_trailStarted = true;
    };
    if this.hasExploded {
      this.Release();
    };
    if this.m_countTime > this.explosionTime && !this.hasExploded {
      this.Explode();
    };
    if Vector4.IsZero(this.m_initialPosition) {
      this.m_initialPosition = this.GetWorldPosition();
    };
    if !this.hasExploded && (!IsDefined(this.m_user) || !this.m_user.IsPlayer()) {
      GameInstance.GetAudioSystem(this.GetGame()).TriggerFlyby(this.GetWorldPosition(), this.GetWorldForward(), this.m_initialPosition, this.m_weapon);
    };
  }

  protected cb func OnCollision(projectileHitEvent: ref<gameprojectileHitEvent>) -> Bool {
    let damage: ref<EffectInstance>;
    let hitInstance: gameprojectileHitInstance;
    let object: ref<GameObject>;
    let damageHitEvent: ref<gameprojectileHitEvent> = new gameprojectileHitEvent();
    let isUserPlayer: Bool = this.m_user == GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject();
    let i: Int32 = 0;
    while i < ArraySize(projectileHitEvent.hitInstances) {
      hitInstance = projectileHitEvent.hitInstances[i];
      object = hitInstance.hitObject as GameObject;
      if !(isUserPlayer && object.HasTag(n"ignore_player_bullets")) {
        ArrayPush(damageHitEvent.hitInstances, hitInstance);
        if !object.HasTag(n"bullet_no_destroy") && this.m_BulletCollisionEvaluator.HasReportedStopped() && Equals(hitInstance.position, this.m_BulletCollisionEvaluator.GetStoppedPosition()) {
          if this.explodeAfterRangeTravelled && Vector4.Distance(this.m_initialPosition, hitInstance.position) > this.range {
            this.Explode(hitInstance.projectilePosition);
          } else {
            if this.explodeAfterRangeTravelled {
              this.Release();
              GameObjectEffectHelper.BreakEffectLoopEvent(this, n"trail");
            } else {
              this.Explode(hitInstance.projectilePosition);
            };
          };
        } else {
          i += 1;
        };
      } else {
      };
      i += 1;
    };
    if ArraySize(damageHitEvent.hitInstances) > 0 {
      damage = this.m_projectileComponent.GetGameEffectInstance();
      EffectData.SetVariant(damage.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.projectileHitEvent, ToVariant(damageHitEvent));
      damage.Run();
    };
  }

  protected final func Explode(opt position: Vector4) -> Void {
    let explosionAttackRecord: ref<Attack_Record>;
    if !this.hasExploded {
      this.hasExploded = true;
      if IsDefined(this.m_attack) {
        explosionAttackRecord = ProjectileHelper.FindExplosiveHitAttack(this.m_attack_record);
        if IsDefined(explosionAttackRecord) {
          if Vector4.IsZero(position) {
            position = Matrix.GetTranslation(this.m_projectileComponent.GetLocalToWorld());
          };
          ProjectileHelper.SpawnExplosionAttack(explosionAttackRecord, this.m_weapon, this.m_user, this, position, 0.05);
        };
      };
      GameObjectEffectHelper.BreakEffectLoopEvent(this, n"trail");
    };
  }

  protected final func RunGameEffect() -> Void {
    let effect: ref<EffectInstance> = this.m_projectileComponent.GetGameEffectInstance();
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, Matrix.GetTranslation(this.m_projectileComponent.GetLocalToWorld()));
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, this.range);
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, this.range);
    effect.Run();
  }

  protected func DealDamage(eventData: ref<gameprojectileHitEvent>) -> Void {
    this.PerformAttack(eventData);
    this.DealDamage(eventData);
  }
}
