
public class SpiderbotHeavyProjectile extends BaseProjectile {

  private let m_meshComponent: ref<IComponent>;

  private edit let m_effect: EffectRef;

  private edit let m_startVelocity: Float;

  private edit let m_lifetime: Float;

  @default(SpiderbotHeavyProjectile, true)
  private let m_alive: Bool;

  @default(SpiderbotHeavyProjectile, false)
  private let m_hit: Bool;

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_meshComponent = EntityResolveComponentsInterface.GetComponent(ri, n"MeshComponent");
  }

  private final func Reset() -> Void {
    this.m_alive = true;
    this.m_hit = false;
    this.m_meshComponent.Toggle(true);
  }

  protected cb func OnShoot(eventData: ref<gameprojectileShootEvent>) -> Bool {
    this.SetInitialVelocityBasedOnActionType(this.m_user);
    this.ParabolicLaunch(eventData, -10.00, 15.00, 0.00);
  }

  protected cb func OnShootTarget(eventData: ref<gameprojectileShootTargetEvent>) -> Bool {
    let parabolicParams: ref<ParabolicTrajectoryParams>;
    this.Reset();
    parabolicParams = ParabolicTrajectoryParams.GetAccelTargetAngleParabolicParams(new Vector4(0.00, 0.00, -10.00, 0.00), eventData.params.targetPosition, 30.00);
    this.m_projectileComponent.SetEnergyLossFactor(0.10, 0.10);
    this.m_projectileComponent.AddParabolic(parabolicParams);
    this.m_projectileComponent.SetOnCollisionAction(gameprojectileOnCollisionAction.Stop);
  }

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool {
    if this.m_alive {
      GameObject.PlaySoundEvent(this, n"Stop_Time_Dilation_Bullet_Trails_bullets_normal");
      this.Explode(eventData.hitInstances[0]);
    };
  }

  protected func Explode(hitInstance: gameprojectileHitInstance) -> Void {
    let effect: ref<EffectInstance>;
    let damageHitEvent: ref<gameprojectileHitEvent> = new gameprojectileHitEvent();
    ArrayPush(damageHitEvent.hitInstances, hitInstance);
    effect = this.m_projectileComponent.GetGameEffectInstance();
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.projectileHitEvent, ToVariant(damageHitEvent));
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, hitInstance.position);
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, 5.00);
    effect.Run();
    this.m_alive = false;
    this.m_meshComponent.Toggle(false);
    this.m_projectileComponent.ClearTrajectories();
  }
}
