
public class BaseBullet extends BaseProjectile {

  private let m_meshComponent: ref<IComponent>;

  protected let m_countTime: Float;

  protected edit let m_startVelocity: Float;

  protected edit let m_lifetime: Float;

  @default(BaseBullet, true)
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
    linearParams.startVel = this.m_startVelocity;
    this.m_projectileComponent.AddLinear(linearParams);
    this.m_projectileComponent.ToggleAxisRotation(true);
    this.m_projectileComponent.AddAxisRotation(new Vector4(0.00, 1.00, 0.00, 0.00), 100.00);
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

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool {
    if this.m_alive {
      GameObject.PlaySoundEvent(this, n"Stop_Time_Dilation_Bullet_Trails_bullets_normal");
      this.DealDamage(eventData);
    };
  }

  protected func DealDamage(eventData: ref<gameprojectileHitEvent>) -> Void {
    let i: Int32;
    let object: ref<GameObject>;
    let damageEffect: ref<EffectInstance> = this.m_projectileComponent.GetGameEffectInstance();
    EffectData.SetVariant(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.projectileHitEvent, ToVariant(eventData));
    damageEffect.Run();
    i = 0;
    while i < ArraySize(eventData.hitInstances) {
      object = eventData.hitInstances[i].hitObject as GameObject;
      if !object.HasTag(n"bullet_no_destroy") {
        this.m_countTime = 0.00;
        this.m_alive = false;
        this.m_meshComponent.Toggle(false);
        this.m_projectileComponent.ClearTrajectories();
      } else {
        i += 1;
      };
    };
  }

  protected final func PerformAttack(eventData: ref<gameprojectileHitEvent>) -> Void {
    let attackContext: AttackInitContext;
    let statMods: array<ref<gameStatModifierData>>;
    attackContext.record = TweakDBInterface.GetAttackRecord(t"Attacks.REMOVE_BulletWithDamage");
    attackContext.instigator = this;
    attackContext.source = this;
    let explosionAttack: ref<Attack_GameEffect> = IAttack.Create(attackContext) as Attack_GameEffect;
    let explosionEffect: ref<EffectInstance> = explosionAttack.PrepareAttack(this);
    explosionAttack.GetStatModList(statMods);
    EffectData.SetVariant(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(explosionAttack));
    EffectData.SetVariant(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackStatModList, ToVariant(statMods));
    EffectData.SetVariant(explosionEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.projectileHitEvent, ToVariant(eventData));
    explosionAttack.StartAttack();
  }
}
