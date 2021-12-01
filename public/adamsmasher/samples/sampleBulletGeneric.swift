
public class sampleBulletGeneric extends BaseProjectile {

  private let m_meshComponent: ref<IComponent>;

  private let m_damage: ref<EffectInstance>;

  private let m_countTime: Float;

  private edit let m_startVelocity: Float;

  private edit let m_lifetime: Float;

  @default(sampleBulletGeneric, true)
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
  }

  private final func StartTrailEffect() -> Void {
    this.m_projectileComponent.SpawnTrailVFX();
    GameObject.PlaySoundEvent(this, n"Time_Dilation_Bullet_Trails_bullets_normal");
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    this.Reset();
    this.StartTrailEffect();
  }

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    this.Reset();
    this.StartTrailEffect();
  }

  protected cb func OnTick(eventData: ref<gameprojectileTickEvent>) -> Bool {
    this.m_countTime += eventData.deltaTime;
    if this.m_countTime > this.m_lifetime || !this.m_alive {
      this.Release();
    };
  }

  protected cb func OnCollision(projectileHitEvent: ref<gameprojectileHitEvent>) -> Bool {
    let attackContext: AttackInitContext;
    let explosionAttack: ref<Attack_GameEffect>;
    let explosionEffect: ref<EffectInstance>;
    let hitInstance: gameprojectileHitInstance;
    let i: Int32;
    let object: ref<GameObject>;
    let statMods: array<ref<gameStatModifierData>>;
    let damageHitEvent: ref<gameprojectileHitEvent> = new gameprojectileHitEvent();
    if this.m_alive {
      attackContext.source = this;
      attackContext.record = TweakDBInterface.GetAttackRecord(t"Attacks.REMOVE_BulletWithDamage");
      attackContext.instigator = this.m_user;
      explosionAttack = IAttack.Create(attackContext) as Attack_GameEffect;
      explosionEffect = explosionAttack.PrepareAttack(this.m_user);
      explosionAttack.GetStatModList(statMods);
      EffectData.SetVariant(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(explosionAttack));
      EffectData.SetVariant(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackStatModList, ToVariant(statMods));
    };
    i = 0;
    while i < ArraySize(projectileHitEvent.hitInstances) {
      hitInstance = projectileHitEvent.hitInstances[i];
      object = hitInstance.hitObject as GameObject;
      if this.m_alive {
        ArrayPush(damageHitEvent.hitInstances, hitInstance);
        if !object.HasTag(n"bullet_no_destroy") {
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
      EffectData.SetVariant(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.projectileHitEvent, ToVariant(damageHitEvent));
      explosionAttack.StartAttack();
    };
  }
}
